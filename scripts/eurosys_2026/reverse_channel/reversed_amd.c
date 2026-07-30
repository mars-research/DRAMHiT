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
#include <unistd.h>
#include <time.h>
#include <sched.h>

#define ONE_GB (1024ULL * 1024ULL * 1024ULL)
#define CACHE_LINE_SIZE 64
#define TOTAL_LINES (ONE_GB / CACHE_LINE_SIZE)
#define PROCESSOR_FREQ_GHZ 3.25

typedef char cacheline_t[CACHE_LINE_SIZE];

// Global synchronization barrier
pthread_barrier_t sync_barrier;

// Thread argument structure
typedef struct {
    int thread_id;
    uint64_t *my_workload;      // Pointer to this thread's chunk of the workload array
    uint64_t workload_len;      // How many cachelines this thread will process
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

    // A standard page frame is 4KB
    uint64_t page_size = sysconf(_SC_PAGESIZE);
    uint64_t vpn = (uint64_t)vaddr / page_size;
    uint64_t pfn_item;

    if (pread(fd, &pfn_item, sizeof(pfn_item), vpn * sizeof(pfn_item)) != sizeof(pfn_item)) {
        perror("Failed to read pagemap");
        exit(EXIT_FAILURE);
    }
    close(fd);

    // Check if page is present (Bit 63)
    if ((pfn_item & (1ULL << 63)) == 0) {
        fprintf(stderr, "Page not present in physical memory.\n");
        exit(EXIT_FAILURE);
    }

    // Extract Physical Frame Number (Bits 0-54)
    uint64_t pfn = pfn_item & ((1ULL << 55) - 1);
    uint64_t phys_addr = pfn * page_size + ((uint64_t)vaddr % page_size);

    // Calculate which 1MB Region (0 through 11) this physical address starts at
    uint64_t start_mb = phys_addr / (1024 * 1024);
    uint64_t offset_in_12mb = start_mb % 12;

    printf("[*] HugePage Physical Address: 0x%lx\n", phys_addr);
    printf("[*] HugePage starts at 12MB Cycle Region: %lu\n", offset_in_12mb);

    return offset_in_12mb;
}

static inline int is_block0_owner_cacheline(uint64_t line_idx, uint64_t cycle_offset) {
    // 1. MACRO LEVEL: Find absolute 1MB region inside the 12MB cycle
    uint64_t rem_12mb = line_idx % 196608;
    uint64_t local_M = rem_12mb / 16384;

    // Apply the HugePage physical shift
    uint64_t absolute_M = (local_M + cycle_offset) % 12;

    // 2. MACRO STATE: AMD's Megabyte shift sequence
    uint64_t base_state = ((absolute_M / 2) * 5 + (absolute_M % 2) * 4) % 6;

    // 3. MICRO LEVEL: Find 16KB chunk and calculate shift
    uint64_t chunk_in_mb = (rem_12mb % 16384) / 256;
    uint64_t G = chunk_in_mb / 4;   // 64KB Group
    uint64_t I = chunk_in_mb % 4;   // 16KB Index inside Group
    uint64_t micro_shift = G + I;

    // 4. THE UNIFIED STATE
    uint64_t final_state = (base_state + micro_shift) % 6;

    // 5. BLOCK RESOLUTION: Are we Even or Odd?
    uint64_t block_in_chunk = (rem_12mb % 256) / 4;
    int is_even_block = (block_in_chunk % 2 == 0);

    // 6. BLOCK 0 OWNER ROUTING TABLE
    // Based on empirical data: Block 0 is State 0, Even Block.
    // The MC that owns this slot follows this exact sequence:
    if (final_state == 0 || final_state == 5) {
        return is_even_block;  // Target MC owns the Even blocks here
    } else if (final_state == 2 || final_state == 3) {
        return !is_even_block; // Target MC owns the Odd blocks here
    } else {
        return 0;              // Target MC gets 0 blocks in states 1 and 4
    }
}

// The worker function executed by each thread
void *memory_worker(void *arg) {
    thread_args_t *t = (thread_args_t *)arg;
    uint64_t local_acc = 0;

    // Pull variables into registers to avoid pointer chasing overhead in the loop
    uint64_t len = t->workload_len;
    uint64_t *workload = t->my_workload;
    cacheline_t *mem = t->mem_space;

    // Wait for all threads to be spawned and initialized
    pthread_barrier_wait(&sync_barrier);

    // Barrier to prevent pre-fetching or out-of-order execution before the timer starts
    _mm_mfence();
    uint64_t start_tsc = __rdtsc();
    _mm_lfence();

    // Critical timed loop: pure memory access
    // for (uint64_t i = 0; i < len; i++) {
    //     uint64_t target_line = workload[i];
    //     char *addr = &mem[target_line][0];

    //     // read, accumulate, modify, and flush
    //     local_acc += *addr;
    // }
    for (uint64_t i = 0; i < len; i++) {
        // Prefetch 16 elements ahead, guarded by an if statement
        if (i + 16 < len) {
            uint64_t prefetch_line = workload[i + 16];
            const char *prefetch_addr = &mem[prefetch_line][0];

            // _MM_HINT_T1 issues the prefetcht1 instruction
            _mm_prefetch(prefetch_addr, _MM_HINT_T1);
        }

        uint64_t target_line = workload[i];
        char *addr = &mem[target_line][0];

        // read, accumulate, modify, and flush
        local_acc += *addr;
    }

    _mm_mfence(); // Wait for all memory operations to retire
    uint64_t end_tsc = __rdtsc();
    _mm_lfence();

    // Wait for all threads to finish their loops before concluding the workload phase
    pthread_barrier_wait(&sync_barrier);

    t->elapsed_cycles = end_tsc - start_tsc;
    t->accumulator = local_acc;

    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        fprintf(stderr, "Usage: %s <num_threads>\n", argv[0]);
        return EXIT_FAILURE;
    }
    int num_threads = atoi(argv[1]);
    if (num_threads <= 0) {
        fprintf(stderr, "Error: Number of threads must be >= 1\n");
        return EXIT_FAILURE;
    }

    // Initialize the synchronization barrier
    pthread_barrier_init(&sync_barrier, NULL, num_threads);

    // 1. Force execution to NUMA Node 0
    if (numa_available() < 0) {
        fprintf(stderr, "Error: NUMA library not supported.\n");
        return EXIT_FAILURE;
    }
    struct bitmask *mask = numa_allocate_nodemask();
    numa_bitmask_setbit(mask, 0);
    numa_bind(mask);
    numa_free_nodemask(mask);

    // 2. Allocate 1GB Hugepage strictly on NUMA Node 0
    void *ptr = mmap(NULL, ONE_GB, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | (30 << MAP_HUGE_SHIFT), -1, 0);
    if (ptr == MAP_FAILED) {
        perror("mmap 1GB hugepage failed. Ensure 1GB pages are reserved.");
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

    // 3. Initialize memory space
    printf("[*] Initializing Hugepage memory...\n");
    memset(ptr, 1, ONE_GB);
    for (uint64_t i = 0; i < TOTAL_LINES; i++) {
        _mm_clflush(&mem_space[i][0]);
    }
    _mm_sfence();

    // 4. Precompute Workload Array via Sequential Sweep
    printf("[*] Sweeping 1GB physical space to find UMC 1 cachelines...\n");

    // Allocate space for up to half the page just in case
    uint64_t max_possible_lines = TOTAL_LINES / 2;
    uint64_t *master_workload = malloc(max_possible_lines * sizeof(uint64_t));
    if (!master_workload) {
        perror("Failed to allocate workload array");
        return EXIT_FAILURE;
    }

    uint64_t hardware_shift = get_12mb_cycle_offset(ptr);
    uint64_t umc1_found_count = 0;

    for (uint64_t i = 0; i < TOTAL_LINES; i++) {
        if (is_block0_owner_cacheline(i, hardware_shift)) {
            master_workload[umc1_found_count] = i;
            umc1_found_count++;
        }
    }

    srand(time(NULL));

    printf("[DEBUG] 20 Random Sample Points from Workload Array:\n");
    for (int i = 0; i < 20; i++) {
        // Pick a random index between 0 and the total number of UMC1 cachelines found
        uint64_t random_index = rand() % umc1_found_count;

        // Print the cacheline number at that random index
        printf("%lu", master_workload[random_index]);

        // Print a comma unless it's the last item
        if (i < 19) {
            printf(", ");
        }
    }
    printf("\n");

    printf("[*] Sweep complete. Found %lu cachelines belonging to UMC 1.\n", umc1_found_count);

    // 5. Calculate workload distribution
    uint64_t lines_per_thread = umc1_found_count / num_threads;

    pthread_t *threads = malloc(num_threads * sizeof(pthread_t));
    thread_args_t *args = malloc(num_threads * sizeof(thread_args_t));

    for (int i = 0; i < num_threads; i++) {
        args[i].thread_id = i;
        args[i].my_workload = &master_workload[i * lines_per_thread];

        // The last thread picks up any remainder
        args[i].workload_len = (i == num_threads - 1) ?
                               (umc1_found_count - (i * lines_per_thread)) : lines_per_thread;

        args[i].mem_space = mem_space;
        args[i].elapsed_cycles = 0;
        args[i].accumulator = 0;
    }

    // 6. Execute Workload
    printf("[*] Spawning %d threads to blast UMC 1...\n", num_threads);
    for (int i = 0; i < num_threads; i++) {
        // Set up the CPU affinity attributes
        pthread_attr_t attr;
        pthread_attr_init(&attr);

        cpu_set_t cpuset;
        CPU_ZERO(&cpuset);
        CPU_SET(i, &cpuset); // Hard-lock this thread to CPU core 'i'

        if (pthread_attr_setaffinity_np(&attr, sizeof(cpu_set_t), &cpuset) != 0) {
            fprintf(stderr, "Warning: Failed to set thread affinity for CPU %d\n", i);
        }

        pthread_create(&threads[i], &attr, memory_worker, &args[i]);

        // Clean up attribute object after creation
        pthread_attr_destroy(&attr);
    }

    for (int i = 0; i < num_threads; i++) {
        pthread_join(threads[i], NULL);
    }
    printf("[*] All threads finished execution.\n");

    // 7. Aggregate Results and Print Per-Thread Metrics
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

        double cpc = (double)args[i].elapsed_cycles / (double)args[i].workload_len;

        printf("Thread %2d : %10lu cycles | %8lu lines | %6.2f cycles/cacheline\n",
               args[i].thread_id, args[i].elapsed_cycles, args[i].workload_len, cpc);
    }
    avg_cycles = avg_cycles / num_threads;

    // 8. Calculate Aggregate Bandwidth
    double time_seconds = (double)max_cycles / (PROCESSOR_FREQ_GHZ * 1000000000.0);
    double time_ns = (double)avg_cycles / (PROCESSOR_FREQ_GHZ * 1.0);
    double total_bytes_accessed = (double)umc1_found_count * CACHE_LINE_SIZE;

    // Using x2 because a flush modifies the line, requiring Read + Writeback
    double logical_payload_gb = total_bytes_accessed / 1000000000.0;
    double bus_traffic_gb = logical_payload_gb * 2;

    double bandwidth_gb_s = total_bytes_accessed / time_ns;
    double global_cpc = (double)max_cycles / (double)(umc1_found_count / num_threads);

    printf("\n--- Aggregate Performance Metrics ---\n");
    printf("UMC 1 Cachelines : %lu\n", umc1_found_count);
    printf("Logical Data Size: %.2f MB\n", total_bytes_accessed / (1024 * 1024));
    printf("Max Thread Cycles: %lu\n", max_cycles);
    printf("Elapsed Time     : %.6f seconds\n", time_seconds);
    printf("Total Accumulator: %lu\n", total_acc);
    printf("Avg Cycles/Line  : %.2f (based on longest thread)\n", global_cpc);
    printf("Bus Bandwidth    : %.2f GB/s\n", bandwidth_gb_s);
    printf("-------------------------------------\n");

    // Cleanup
    pthread_barrier_destroy(&sync_barrier);
    free(threads);
    free(args);
    free(master_workload);
    munmap(ptr, ONE_GB);

    return 0;
}
