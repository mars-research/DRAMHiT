// imc_probe.c -- instrumented generalisation of reverse_channel/reversed_intel.c
//
// Same experiment as reversed_intel.c: take one 1 GiB hugepage on node 0, use the
// reverse-engineered hash to pick out the cachelines that the hash says belong to
// ONE iMC channel, and stream reads over just those lines (clflushopt after every
// read so every access has to go to DRAM).
//
// Three things are added, all of which the original hardcodes:
//   1. the target channel is an argument, not 0.  Verifying only channel 0 tells
//      you a subset of lines lands on one controller; sweeping k = 0..7 and
//      showing the 8 predicted classes map onto 8 *distinct* controllers is what
//      actually verifies the hash.
//   2. threads are pinned to an explicit cpu list.  The original does CPU_SET(i),
//      and on this box node 0 is the EVEN cpus, so "16 threads" in the original
//      straddles both sockets and half the traffic leaves socket 0 over UPI.
//   3. CLOCK_MONOTONIC marks around the access loop, so a `perf stat -I` series
//      can be cut down to exactly the steady-state window.  Without this the 1 GiB
//      memset+flush init is counted too, and it lands on all 8 channels.
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/mman.h>
#include <unistd.h>
#include <pthread.h>
#include <numa.h>
#include <numaif.h>
#include <x86intrin.h>
#include <string.h>
#include <fcntl.h>
#include <time.h>
#include <sched.h>

#define ONE_GB (1024ULL * 1024ULL * 1024ULL)
#define CACHE_LINE_SIZE 64
#define TOTAL_LINES (ONE_GB / CACHE_LINE_SIZE)
#define PROCESSOR_FREQ_GHZ 2.5   // invariant TSC rate = base clock of the 6548Y+

typedef char cacheline_t[CACHE_LINE_SIZE];

pthread_barrier_t sync_barrier;

typedef struct {
    int thread_id;
    int cpu;
    uint64_t *my_workload;
    uint64_t workload_len;
    int iterations;
    cacheline_t *mem_space;
    uint64_t elapsed_cycles;
    uint64_t accumulator;
} thread_args_t;

static double mono_now(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec / 1e9;
}

// Physical address of a mapping, via /proc/self/pagemap.  Needs root.
static uint64_t phys_addr_of(void *vaddr) {
    int fd = open("/proc/self/pagemap", O_RDONLY);
    if (fd < 0) { perror("open pagemap (run as root)"); exit(EXIT_FAILURE); }

    uint64_t page_size = sysconf(_SC_PAGESIZE);
    uint64_t vpn = (uint64_t)vaddr / page_size;
    uint64_t item;
    if (pread(fd, &item, sizeof(item), vpn * sizeof(item)) != sizeof(item)) {
        perror("pread pagemap"); exit(EXIT_FAILURE);
    }
    close(fd);
    if ((item & (1ULL << 63)) == 0) {
        fprintf(stderr, "page not present\n"); exit(EXIT_FAILURE);
    }
    uint64_t pfn = item & ((1ULL << 55) - 1);
    return pfn * page_size + ((uint64_t)vaddr % page_size);
}

// The reverse-engineered hash, verbatim from reversed_intel.c but returning the
// channel id instead of comparing it to 0.
//
// It is a function of physical address bits 8..25 only.  A 1 GiB hugepage is
// 1 GiB-aligned, so phys = base + line_idx*64 agrees with line_idx*64 on every
// bit below 30 -- which is why the original can get away with hashing the page
// offset and ignoring the base it prints.
static inline uint8_t imc_of_line(uint64_t line_idx) {
    uint64_t addr = line_idx * 64;

    uint8_t a8  = (addr >> 8)  & 1;
    uint8_t a9  = (addr >> 9)  & 1;
    uint8_t a11 = (addr >> 11) & 1;
    uint8_t a14 = (addr >> 14) & 1;
    uint8_t a15 = (addr >> 15) & 1;
    uint8_t a17 = (addr >> 17) & 1;
    uint8_t a22 = (addr >> 22) & 1;
    uint8_t a23 = (addr >> 23) & 1;
    uint8_t a25 = (addr >> 25) & 1;

    uint8_t c0 = a9 ^ a15 ^ a23;
    uint8_t c1 = a8 ^ a14 ^ a22;
    uint8_t c2 = a8 ^ a11 ^ a17 ^ a25;

    return (uint8_t)((c2 << 2) | (c1 << 1) | c0);
}

void *memory_worker(void *arg) {
    thread_args_t *t = (thread_args_t *)arg;
    uint64_t local_acc = 0;

    uint64_t len = t->workload_len;
    int iters = t->iterations;
    uint64_t *workload = t->my_workload;
    cacheline_t *mem = t->mem_space;

    pthread_barrier_wait(&sync_barrier);

    _mm_mfence();
    uint64_t start_tsc = __rdtsc();
    _mm_lfence();

    for (int iter = 0; iter < iters; iter++) {
        for (uint64_t i = 0; i < len; i++) {
            if (i + 64 < len) {
                _mm_prefetch(&mem[workload[i + 64]][0], _MM_HINT_T0);
            }
            char *addr = &mem[workload[i]][0];
            local_acc += *addr;
            _mm_clflushopt(addr);   // line is clean, so this invalidates; no writeback
        }
        _mm_sfence();
    }

    _mm_mfence();
    uint64_t end_tsc = __rdtsc();
    _mm_lfence();

    pthread_barrier_wait(&sync_barrier);

    t->elapsed_cycles = end_tsc - start_tsc;
    t->accumulator = local_acc;
    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc < 5) {
        fprintf(stderr,
            "usage: %s <target_imc 0-7> <num_threads> <iterations> <cpu,cpu,...>\n",
            argv[0]);
        return EXIT_FAILURE;
    }
    int target_imc   = atoi(argv[1]);
    int num_threads  = atoi(argv[2]);
    int num_iters    = atoi(argv[3]);

    if (target_imc < 0 || target_imc > 7 || num_threads <= 0 || num_iters <= 0) {
        fprintf(stderr, "bad arguments\n");
        return EXIT_FAILURE;
    }

    int *cpus = malloc(num_threads * sizeof(int));
    {
        int n = 0;
        char *dup = strdup(argv[4]);
        for (char *tok = strtok(dup, ","); tok && n < num_threads; tok = strtok(NULL, ",")) {
            cpus[n++] = atoi(tok);
        }
        free(dup);
        if (n != num_threads) {
            fprintf(stderr, "cpu list has %d entries, need %d\n", n, num_threads);
            return EXIT_FAILURE;
        }
    }

    if (numa_available() < 0) { fprintf(stderr, "no numa\n"); return EXIT_FAILURE; }
    struct bitmask *mask = numa_allocate_nodemask();
    numa_bitmask_setbit(mask, 0);
    numa_bind(mask);
    numa_free_nodemask(mask);

    void *ptr = mmap(NULL, ONE_GB, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | (30 << MAP_HUGE_SHIFT),
                     -1, 0);
    if (ptr == MAP_FAILED) { perror("mmap 1GB hugepage"); return EXIT_FAILURE; }

    struct bitmask *nodemask = numa_allocate_nodemask();
    numa_bitmask_setbit(nodemask, 0);
    if (mbind(ptr, ONE_GB, MPOL_BIND, nodemask->maskp, nodemask->size + 1, 0) < 0) {
        perror("mbind"); return EXIT_FAILURE;
    }
    numa_free_nodemask(nodemask);

    cacheline_t *mem_space = (cacheline_t *)ptr;

    memset(ptr, 1, ONE_GB);
    for (uint64_t i = 0; i < TOTAL_LINES; i++) _mm_clflushopt(&mem_space[i][0]);
    _mm_sfence();

    uint64_t phys = phys_addr_of(ptr);

    uint64_t *workload = malloc((TOTAL_LINES / 8 + 8) * sizeof(uint64_t));
    uint64_t found = 0;
    for (uint64_t i = 0; i < TOTAL_LINES; i++) {
        if (imc_of_line(i) == (uint8_t)target_imc) workload[found++] = i;
    }

    printf("phys_base 0x%lx\n", phys);
    printf("phys_1gb_aligned %d\n", (phys % ONE_GB) == 0);
    printf("target_imc %d\n", target_imc);
    printf("lines %lu\n", found);
    printf("num_threads %d\n", num_threads);
    printf("iterations %d\n", num_iters);
    fflush(stdout);

    uint64_t per_thread = found / num_threads;

    pthread_barrier_init(&sync_barrier, NULL, num_threads);
    pthread_t *threads = malloc(num_threads * sizeof(pthread_t));
    thread_args_t *args = malloc(num_threads * sizeof(thread_args_t));

    for (int i = 0; i < num_threads; i++) {
        args[i].thread_id     = i;
        args[i].cpu           = cpus[i];
        args[i].my_workload   = &workload[i * per_thread];
        args[i].workload_len  = (i == num_threads - 1)
                                ? (found - (uint64_t)i * per_thread) : per_thread;
        args[i].iterations    = num_iters;
        args[i].mem_space     = mem_space;
        args[i].elapsed_cycles = 0;
        args[i].accumulator    = 0;
    }

    double t_loop_start = mono_now();
    printf("MARK loop_start %.6f\n", t_loop_start);
    fflush(stdout);

    for (int i = 0; i < num_threads; i++) {
        pthread_attr_t attr;
        pthread_attr_init(&attr);
        cpu_set_t cpuset;
        CPU_ZERO(&cpuset);
        CPU_SET(cpus[i], &cpuset);
        pthread_attr_setaffinity_np(&attr, sizeof(cpu_set_t), &cpuset);
        pthread_create(&threads[i], &attr, memory_worker, &args[i]);
        pthread_attr_destroy(&attr);
    }
    for (int i = 0; i < num_threads; i++) pthread_join(threads[i], NULL);

    double t_loop_end = mono_now();
    printf("MARK loop_end %.6f\n", t_loop_end);

    uint64_t max_cycles = 0, total_acc = 0;
    for (int i = 0; i < num_threads; i++) {
        total_acc += args[i].accumulator;
        if (args[i].elapsed_cycles > max_cycles) max_cycles = args[i].elapsed_cycles;
    }

    double secs  = (double)max_cycles / (PROCESSOR_FREQ_GHZ * 1e9);
    double bytes = (double)found * CACHE_LINE_SIZE * num_iters;
    double bw    = (bytes / 1e9) / secs;

    printf("bytes %.0f\n", bytes);
    printf("sec %.6f\n", secs);
    printf("bw %.4f GB/s\n", bw);
    printf("acc %lu\n", total_acc);
    printf("cpus %s\n", argv[4]);

    pthread_barrier_destroy(&sync_barrier);
    free(threads); free(args); free(workload); free(cpus);
    munmap(ptr, ONE_GB);
    return 0;
}
