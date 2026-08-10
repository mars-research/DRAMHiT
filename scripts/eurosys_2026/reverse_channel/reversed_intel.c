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
#define PROCESSOR_FREQ_GHZ 2.5

typedef char cacheline_t[CACHE_LINE_SIZE];

// Global synchronization barrier
pthread_barrier_t sync_barrier;

// Thread argument structure
typedef struct {
    int thread_id;
    uint64_t *my_workload;      // Pointer to this thread's chunk of the workload array
    uint64_t workload_len;      // How many cachelines this thread will process
    int iterations;             // How many times to loop over the workload
    cacheline_t *mem_space;     // Pointer to the 1GB Hugepage
    uint64_t elapsed_cycles;
    uint64_t accumulator;
} thread_args_t;

uint64_t get_12mb_cycle_offset(void *vaddr) {
    int fd = open("/proc/self/pagemap", O_RDONLY);
    if (fd < 0) {
        perror("Failed to open pagemap (Run as root!)");
        exit(EXIT_FAILURE);
    }

    uint64_t page_size = sysconf(_SC_PAGESIZE);
    uint64_t vpn = (uint64_t)vaddr / page_size;
    uint64_t pfn_item;

    if (pread(fd, &pfn_item, sizeof(pfn_item), vpn * sizeof(pfn_item)) != sizeof(pfn_item)) {
        perror("Failed to read pagemap");
        exit(EXIT_FAILURE);
    }
    close(fd);

    if ((pfn_item & (1ULL << 63)) == 0) {
        fprintf(stderr, "Page not present in physical memory.\n");
        exit(EXIT_FAILURE);
    }

    uint64_t pfn = pfn_item & ((1ULL << 55) - 1);
    uint64_t phys_addr = pfn * page_size + ((uint64_t)vaddr % page_size);

    printf("[*] HugePage Physical Address: 0x%lx\n", phys_addr);

    return 0;
}

static inline int is_block0_owner_cacheline(uint64_t line_idx, uint64_t cycle_offset) {
    uint64_t addr = line_idx * 64;

    uint8_t a8  = (addr >> 8) & 1;
    uint8_t a9  = (addr >> 9) & 1;
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

    uint8_t target_imc = (c2 << 2) | (c1 << 1) | c0;

    return (target_imc == 0);
}

// The worker function executed by each thread
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
                uint64_t prefetch_line = workload[i + 64];
                const char *prefetch_addr = &mem[prefetch_line][0];
                _mm_prefetch(prefetch_addr, _MM_HINT_T0);
            }

            uint64_t target_line = workload[i];
            char *addr = &mem[target_line][0];

            // 1. Read from Memory
            local_acc += *addr;

            // 2. Flush Optimized (Evict clean line immediately so next iteration hits DRAM)
            _mm_clflushopt(addr);
        }

        // Ensure all flushes from this iteration are globally visible
        // before starting the next pass
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
    if (argc < 3) {
        fprintf(stderr, "Usage: %s <num_threads> <iterations>\n", argv[0]);
        return EXIT_FAILURE;
    }
    int num_threads = atoi(argv[1]);
    int num_iterations = atoi(argv[2]);

    if (num_threads <= 0 || num_iterations <= 0) {
        fprintf(stderr, "Error: Threads and iterations must be >= 1\n");
        return EXIT_FAILURE;
    }

    pthread_barrier_init(&sync_barrier, NULL, num_threads);

    if (numa_available() < 0) {
        fprintf(stderr, "Error: NUMA library not supported.\n");
        return EXIT_FAILURE;
    }
    struct bitmask *mask = numa_allocate_nodemask();
    numa_bitmask_setbit(mask, 0);
    numa_bind(mask);
    numa_free_nodemask(mask);

    void *ptr = mmap(NULL, ONE_GB, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | (30 << MAP_HUGE_SHIFT), -1, 0);
    if (ptr == MAP_FAILED) {
        perror("mmap 1GB hugepage failed.");
        return EXIT_FAILURE;
    }

    struct bitmask *nodemask = numa_allocate_nodemask();
    numa_bitmask_setbit(nodemask, 0);
    if (mbind(ptr, ONE_GB, MPOL_BIND, nodemask->maskp, nodemask->size + 1, 0) < 0) {
        perror("mbind failed");
        return EXIT_FAILURE;
    }
    numa_free_nodemask(nodemask);

    cacheline_t *mem_space = (cacheline_t *)ptr;

    printf("[*] Initializing Hugepage memory...\n");
    memset(ptr, 1, ONE_GB);
    for (uint64_t i = 0; i < TOTAL_LINES; i++) {
        _mm_clflushopt(&mem_space[i][0]);
    }
    _mm_sfence();

    printf("[*] Sweeping 1GB physical space to find iMC 0 cachelines...\n");

    uint64_t max_possible_lines = TOTAL_LINES / 2;
    uint64_t *master_workload = malloc(max_possible_lines * sizeof(uint64_t));

    uint64_t hardware_shift = get_12mb_cycle_offset(ptr);
    uint64_t imc0_found_count = 0;

    for (uint64_t i = 0; i < TOTAL_LINES; i++) {
        if (is_block0_owner_cacheline(i, hardware_shift)) {
            master_workload[imc0_found_count] = i;
            imc0_found_count++;
        }
    }

    // --- RESTORED DEBUGGING STATEMENT ---
    srand(time(NULL));
    printf("[DEBUG] 20 Random Sample Points from Workload Array:\n");
    if (imc0_found_count > 0) {
        for (int i = 0; i < 20; i++) {
            uint64_t random_index = rand() % imc0_found_count;
            printf("%lu", master_workload[random_index]);
            if (i < 19) {
                printf(", ");
            }
        }
    } else {
        printf("No cachelines found for iMC 0.");
    }
    printf("\n");
    // ------------------------------------

    printf("[*] Sweep complete. Found %lu cachelines belonging to iMC 0.\n", imc0_found_count);

    uint64_t lines_per_thread = imc0_found_count / num_threads;

    pthread_t *threads = malloc(num_threads * sizeof(pthread_t));
    thread_args_t *args = malloc(num_threads * sizeof(thread_args_t));

    for (int i = 0; i < num_threads; i++) {
        args[i].thread_id = i;
        args[i].my_workload = &master_workload[i * lines_per_thread];
        args[i].workload_len = (i == num_threads - 1) ?
                               (imc0_found_count - (i * lines_per_thread)) : lines_per_thread;
        args[i].iterations = num_iterations;
        args[i].mem_space = mem_space;
        args[i].elapsed_cycles = 0;
        args[i].accumulator = 0;
    }

    printf("[*] Spawning %d threads for %d iterations...\n", num_threads, num_iterations);
    for (int i = 0; i < num_threads; i++) {
        pthread_attr_t attr;
        pthread_attr_init(&attr);

        cpu_set_t cpuset;
        CPU_ZERO(&cpuset);
        CPU_SET(i, &cpuset);

        pthread_attr_setaffinity_np(&attr, sizeof(cpu_set_t), &cpuset);
        pthread_create(&threads[i], &attr, memory_worker, &args[i]);
        pthread_attr_destroy(&attr);
    }

    for (int i = 0; i < num_threads; i++) {
        pthread_join(threads[i], NULL);
    }

    uint64_t max_cycles = 0;
    uint64_t avg_cycles = 0;
    uint64_t total_acc = 0;

    printf("\n--- Per-Thread Metrics ---\n");
    for (int i = 0; i < num_threads; i++) {
        total_acc += args[i].accumulator;
        if (args[i].elapsed_cycles > max_cycles) {
            max_cycles = args[i].elapsed_cycles;
        }
        avg_cycles += args[i].elapsed_cycles;

        double total_lines_processed = (double)args[i].workload_len * num_iterations;
        double cpc = (double)args[i].elapsed_cycles / total_lines_processed;

        printf("Thread %2d : %10lu cycles | %8.2f cycles/cacheline\n",
               args[i].thread_id, args[i].elapsed_cycles, cpc);
    }
    avg_cycles = avg_cycles / num_threads;

    double time_seconds = (double)max_cycles / (PROCESSOR_FREQ_GHZ * 1000000000.0);

    // Calculate Pure Read Data Transfer
    double total_bytes_accessed = (double)imc0_found_count * CACHE_LINE_SIZE * num_iterations;
    double read_traffic_gb = total_bytes_accessed / 1000000000.0;

    // Read Bandwidth
    double bandwidth_gb_s = read_traffic_gb / time_seconds;

    printf("\n--- Aggregate Performance Metrics ---\n");
    printf("iMC 0 Cachelines : %lu\n", imc0_found_count);
    printf("Logical Data Size: %.2f MB\n", (double)(imc0_found_count * CACHE_LINE_SIZE) / (1024 * 1024));
    printf("Iterations       : %d\n", num_iterations);
    printf("Total Read Vol   : %.2f GB\n", read_traffic_gb);
    printf("Elapsed Time     : %.6f seconds\n", time_seconds);
    printf("Total Accumulator: %lu\n", total_acc);
    printf("Avg Cycles       : %lu \n", avg_cycles);
    printf("Read Bandwidth   : %.2f GB/s\n", bandwidth_gb_s);
    printf("-------------------------------------\n");

    pthread_barrier_destroy(&sync_barrier);
    free(threads);
    free(args);
    free(master_workload);
    munmap(ptr, ONE_GB);

    return 0;
}
