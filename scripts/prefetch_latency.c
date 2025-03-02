#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <x86intrin.h>
#include <sched.h>
#include <unistd.h>
#include <time.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>

uint32_t ARRAY_SIZE = 2147483648; // 2G, larger than most LLC sizes
#define STRIDE 64                    // Cache line size (64B for most x86 CPUs)
#define NUM_TRIALS 10000              // Number of repetitions for each wait_iters value
#define NUM_ELEMENTS 16           // Number of random elements to prefetch & access

// MSR definitions per your specification
#define IA32_MISC_ENABLE 0x1A4
#define DISABLE_HW_PREFETCHER_BIT 0xf

void bind_to_cpu(int cpu) {
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(cpu, &cpuset);
    if (sched_setaffinity(getpid(), sizeof(cpuset), &cpuset) != 0) {
        perror("sched_setaffinity");
        exit(EXIT_FAILURE);
    }
}

uint64_t rdtsc() {
    return __rdtsc();
}

#ifdef __linux__
// Disable the hardware prefetcher on CPU 0 (requires root and msr module)
void disable_hw_prefetcher() {
    int fd = open("/dev/cpu/0/msr", O_RDWR);
    if (fd < 0) {
        perror("open /dev/cpu/0/msr");
        return;
    }
    uint64_t msr;
    if (pread(fd, &msr, sizeof(msr), IA32_MISC_ENABLE) != sizeof(msr)) {
        perror("pread IA32_MISC_ENABLE");
        close(fd);
        return;
    }
    printf("Original MSR (0x%x) value: 0x%llx\n", IA32_MISC_ENABLE, msr);
    msr |= DISABLE_HW_PREFETCHER_BIT;
    if (pwrite(fd, &msr, sizeof(msr), IA32_MISC_ENABLE) != sizeof(msr)) {
        perror("pwrite IA32_MISC_ENABLE");
        close(fd);
        return;
    }
    printf("Hardware prefetcher disabled on CPU 0. New MSR value: 0x%llx\n", msr);
    close(fd);
}

// Restore the hardware prefetcher by writing 0x0 to the MSR.
void restore_hw_prefetcher() {
    int fd = open("/dev/cpu/0/msr", O_RDWR);
    if (fd < 0) {
        perror("open /dev/cpu/0/msr");
        return;
    }
    uint64_t msr;
    if (pread(fd, &msr, sizeof(msr), IA32_MISC_ENABLE) != sizeof(msr)) {
        perror("pread IA32_MISC_ENABLE");
        close(fd);
        return;
    }
    printf("Before restoring, MSR (0x%x) value: 0x%llx\n", IA32_MISC_ENABLE, msr);
    msr = 0x0;  // Restore prefetcher by writing 0x0
    if (pwrite(fd, &msr, sizeof(msr), IA32_MISC_ENABLE) != sizeof(msr)) {
        perror("pwrite IA32_MISC_ENABLE (restore)");
        close(fd);
        return;
    }
    printf("Hardware prefetcher restored on CPU 0. New MSR value: 0x%llx\n", msr);
    close(fd);
}
#else
void disable_hw_prefetcher() {}
void restore_hw_prefetcher() {}
#endif

int main() {
    bind_to_cpu(0); // Bind to CPU 0 to avoid migration effects

    // Disable the hardware prefetcher (requires root privileges)
    disable_hw_prefetcher();

    // Allocate memory using huge pages
    uint8_t *array = mmap(NULL, ARRAY_SIZE, PROT_READ | PROT_WRITE,
                          MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
    if (array == MAP_FAILED) {
        perror("mmap");
        return 1;
    }

    // Initialize memory to prevent page faults during measurement
    for (size_t i = 0; i < ARRAY_SIZE; i += STRIDE) {
        array[i] = (uint8_t)i;
    }

    // Seed random number generator
    srand(time(NULL));

    // For each wait time, repeat the experiment NUM_TRIALS times
    for (int wait_iters = 0; wait_iters <= 16; wait_iters += 1) {
        uint64_t total_wait_cycles = 0;
        uint64_t total_prefetch_cycles = 0;
        uint64_t total_access_latency = 0;
        for (int trial = 0; trial < NUM_TRIALS; trial++) {
            // Create an array to hold NUM_ELEMENTS random indices (each aligned)
            size_t indices[NUM_ELEMENTS];
            for (int j = 0; j < NUM_ELEMENTS; j++) {
                indices[j] = (rand() % (ARRAY_SIZE / STRIDE)) * STRIDE;
            }

            // Measure prefetch overhead for all NUM_ELEMENTS together
            uint64_t pf_start = rdtsc();
            for (int j = 0; j < NUM_ELEMENTS; j++) {
                __builtin_prefetch(&array[indices[j]], 0, 3);
            }
            uint64_t pf_end = rdtsc();
            total_prefetch_cycles += (pf_end - pf_start);

            // Measure access latency for all NUM_ELEMENTS together
            uint64_t access_start = rdtsc();
            for (int j = 0; j < NUM_ELEMENTS; j++) {
                volatile uint8_t temp = array[indices[j]];
                temp = temp & 0xff;
            }
            uint64_t access_end = rdtsc();
            total_access_latency += (access_end - access_start);
        }
        printf("Nominal wait iterations: %d, Avg prefetch instr cycles: %llu, "
               "Avg measured wait cycles: %llu, Avg access latency: %llu cycles\n",
               wait_iters,
               total_prefetch_cycles / (NUM_TRIALS*NUM_ELEMENTS),
               total_wait_cycles / NUM_TRIALS,
               total_access_latency / (NUM_TRIALS*NUM_ELEMENTS));
    }

    // Release the huge pages
    if (munmap(array, ARRAY_SIZE) != 0) {
        perror("munmap");
        return 1;
    }

    // Restore the hardware prefetcher after the experiment
    restore_hw_prefetcher();

    return 0;
}

