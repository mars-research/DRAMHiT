#include <iostream>
#include <vector>
#include <cstring>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <linux/perf_event.h>
#include <linux/hw_breakpoint.h>
#include <errno.h>
#include <stdint.h>
#include <chrono>

class BandwidthCounter {
private:
    struct Counter {
        int fd;
        long long value;
    };

    std::vector<Counter> counters;
    int num_channels;

    static int perf_event_open(struct perf_event_attr *hw_event,
                               pid_t pid, int cpu,
                               int group_fd, unsigned long flags) {
        return syscall(__NR_perf_event_open, hw_event, pid, cpu,
                       group_fd, flags);
    }

public:
    BandwidthCounter(int channels = 8) : num_channels(channels) {
        counters.resize(num_channels, {-1, 0});
    }

    bool bw_open() {
        for (int i = 0; i < num_channels; i++) {
            struct perf_event_attr pea;
            memset(&pea, 0, sizeof(pea));
            pea.type = 86 + i;                // uncore_imc_0 .. uncore_imc_7
            pea.size = sizeof(pea);
            pea.config = 0xff05;              // unc_m_cas_count.all
            pea.disabled = 1;
            pea.inherit = 1;
            pea.exclude_kernel = 0;
            pea.exclude_hv = 0;
            pea.read_format = PERF_FORMAT_TOTAL_TIME_ENABLED |
                              PERF_FORMAT_TOTAL_TIME_RUNNING;

            counters[i].fd = perf_event_open(&pea, -1, 0, -1, 0);
            if (counters[i].fd == -1) {
                std::cerr << "Failed to open counter for channel " << i
                          << ": " << strerror(errno) << "\n";
                return false;
            }
            ioctl(counters[i].fd, PERF_EVENT_IOC_RESET, 0);
        }
        return true;
    }

    void start() {
        for (auto &c : counters)
            ioctl(c.fd, PERF_EVENT_IOC_ENABLE, 0);
    }

    void stop() {
        for (auto &c : counters) {
            ioctl(c.fd, PERF_EVENT_IOC_DISABLE, 0);

            struct {
                uint64_t value;
                uint64_t time_enabled;
                uint64_t time_running;
            } read_buf;

            if (read(c.fd, &read_buf, sizeof(read_buf)) == -1) {
                perror("read");
                c.value = 0;
            } else {
                // Scale count by actual time running
                c.value = read_buf.value *
                          ((double)read_buf.time_enabled / read_buf.time_running);
            }
        }
    }

    double get_bw_in_gb(double elapsed_sec) {
        long long total = 0;
        for (auto &c : counters) total += c.value;

        double bytes = total * 64.0;  // each CAS = 64B
        std::cout << "bytes collected: " << bytes << " secs: " << elapsed_sec << std::endl;
        double gb = bytes / 1e9;
        return gb / elapsed_sec;       // GB/s
    }

    void bw_close() {
        for (auto &c : counters) {
            if (c.fd != -1) close(c.fd);
            c.fd = -1;
        }
    }
};

// ---------------- Example usage ----------------
int main() {
    BandwidthCounter bw(8);

    if (!bw.bw_open())
        return 1;

    auto start = std::chrono::high_resolution_clock::now();
    bw.start();

    // ---- code section to measure ----
    static const size_t N = 100000;
    volatile int *arr = new int[N];
    for (size_t i = 0; i < N; i++) arr[i] = i;
    delete[] arr;
    // --------------------------------

    bw.stop();
    auto end = std::chrono::high_resolution_clock::now();

    double elapsed_sec =
        std::chrono::duration<double>(end - start).count();

    std::cout << "Aggregated Bandwidth = "
              << bw.get_bw_in_gb(elapsed_sec)
              << " GB/s\n";

    bw.bw_close();
    return 0;
}
