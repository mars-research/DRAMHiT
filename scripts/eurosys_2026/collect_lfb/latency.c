#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <time.h>
#include <numa.h>
#include <numaif.h>
#include <sys/mman.h>
#include <unistd.h>
#include <pthread.h>
#include <sched.h>
#include <stdatomic.h>

// Hugepage sizes
#define SIZE_1GB (1ULL * 1024 * 1024 * 1024)
#define SIZE_128MB (128ULL * 1024 * 1024)
#define CACHELINE_SIZE 64

#ifndef MAP_HUGE_1GB
#define MAP_HUGE_1GB (30 << MAP_HUGE_SHIFT)
#endif

#ifndef MAP_HUGE_2MB
#define MAP_HUGE_2MB (21 << MAP_HUGE_SHIFT)
#endif

// Node structure: 64 bytes total to perfectly align with a cacheline.
typedef struct {
    uint64_t next_idx;
    uint8_t padding[CACHELINE_SIZE - sizeof(uint64_t)];
} __attribute__((aligned(CACHELINE_SIZE))) Node;

volatile uint64_t global_counter = 0;
atomic_bool keep_running = true;

// Loader thread arguments
typedef struct {
    int cpu_id;
    int mem_node;
} LoaderArgs;

// RDTSC helper to read CPU cycle counter
static inline uint64_t rdtsc() {
    unsigned int lo, hi;
    __asm__ __volatile__ ("rdtsc" : "=a" (lo), "=d" (hi));
    return ((uint64_t)hi << 32) | lo;
}

// Background thread function to overload the memory controller
void* loader_thread_func(void* arg) {
    LoaderArgs* args = (LoaderArgs*)arg;
    int cpu = args->cpu_id;
    int mem_node = args->mem_node;
    free(args);

    // 1. Pin this loader thread to the assigned CPU
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(cpu, &cpuset);
    if (pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset) != 0) {
        perror("Loader failed to set CPU affinity");
        return NULL;
    }

    // 2. Allocate 128MB using 2MB Hugepages
    int mmap_flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | MAP_HUGE_2MB;
    uint64_t *ptr = mmap(NULL, SIZE_128MB, PROT_READ | PROT_WRITE, mmap_flags, -1, 0);
    if (ptr == MAP_FAILED) {
        perror("Loader mmap failed (Ensure 2MB hugepages are allocated in the OS)");
        return NULL;
    }

    // 3. Bind memory to the specified NUMA memory node
    unsigned long nodemask = (1UL << mem_node);
    if (mbind(ptr, SIZE_128MB, MPOL_BIND, &nodemask, sizeof(nodemask)*8, MPOL_MF_STRICT | MPOL_MF_MOVE) != 0) {
        perror("Loader mbind failed");
        munmap(ptr, SIZE_128MB);
        return NULL;
    }

    uint64_t num_elements = SIZE_128MB / sizeof(uint64_t);
    // Mask works because 128MB / 8 bytes = 16,777,216 (which is a power of 2)
    uint64_t mask = num_elements - 1;

    uint64_t idx = 0;
    uint64_t dummy_counter = 0;

    // 4. Infinite loop of random accesses until the measurement thread finishes
    while (atomic_load(&keep_running)) {
        // Linear Congruential Generator for fast, pseudo-random cacheline jumps
        idx = (idx * 1103515245ULL + 12345ULL) & mask;

        // Read, modify, write to heavily utilize memory bandwidth
        dummy_counter += ptr[idx];
        ptr[idx] = dummy_counter + 1;
    }

    munmap(ptr, SIZE_128MB);
    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc != 5) {
        fprintf(stderr, "Usage: %s <mem_numa_node> <cpu_numa_node> <iterations> <loaded: 0|1>\n", argv[0]);
        exit(EXIT_FAILURE);
    }

    int mem_node = atoi(argv[1]);
    int cpu_node = atoi(argv[2]);
    uint64_t iterations = strtoull(argv[3], NULL, 10);
    int loaded = atoi(argv[4]);

    if (iterations == 0) {
        fprintf(stderr, "Iterations must be > 0\n");
        exit(EXIT_FAILURE);
    }

    if (numa_available() < 0) {
        fprintf(stderr, "System does not support NUMA API.\n");
        exit(EXIT_FAILURE);
    }

    // 1. Identify a single CPU in cpu_node for the main latency thread
    struct bitmask *cpu_node_cpus = numa_allocate_cpumask();
    numa_node_to_cpus(cpu_node, cpu_node_cpus);

    int main_cpu = -1;
    for (int i = 0; i < cpu_node_cpus->size; i++) {
        if (numa_bitmask_isbitset(cpu_node_cpus, i)) {
            main_cpu = i;
            break;
        }
    }
    numa_free_cpumask(cpu_node_cpus);

    if (main_cpu == -1) {
        fprintf(stderr, "No CPUs found in CPU NUMA node %d\n", cpu_node);
        exit(EXIT_FAILURE);
    }

    // Pin main thread to the selected single CPU
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(main_cpu, &cpuset);
    if (sched_setaffinity(0, sizeof(cpu_set_t), &cpuset) != 0) {
        perror("Failed to pin main thread");
        exit(EXIT_FAILURE);
    }
    printf("[*] Pinned latency measurement thread to CPU %d (NUMA node %d)\n", main_cpu, cpu_node);

    // 2. Spawn loader threads if requested
    pthread_t *loader_threads = NULL;
    int num_loaders = 0;

    if (loaded) {
        struct bitmask *mem_node_cpus = numa_allocate_cpumask();
        numa_node_to_cpus(mem_node, mem_node_cpus);

        // Count eligible CPUs (all in mem_node except the main thread's CPU)
        for (int i = 0; i < mem_node_cpus->size; i++) {
            if (numa_bitmask_isbitset(mem_node_cpus, i) && i != main_cpu) {
                num_loaders++;
            }
        }

        if (num_loaders > 0) {
            loader_threads = malloc(num_loaders * sizeof(pthread_t));
            int t_idx = 0;
            for (int i = 0; i < mem_node_cpus->size; i++) {
                if (numa_bitmask_isbitset(mem_node_cpus, i) && i != main_cpu) {
                    LoaderArgs *args = malloc(sizeof(LoaderArgs));
                    args->cpu_id = i;
                    args->mem_node = mem_node;
                    pthread_create(&loader_threads[t_idx++], NULL, loader_thread_func, args);
                }
            }
            printf("[*] Spawned %d loader threads on NUMA node %d\n", num_loaders, mem_node);
        } else {
            printf("[!] Loaded mode requested, but no free CPUs available on node %d\n", mem_node);
        }
        numa_free_cpumask(mem_node_cpus);
    }

    // 3. Allocate 1GB using 1GB Hugepages for latency testing
    int mmap_flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | MAP_HUGE_1GB;
    void *ptr = mmap(NULL, SIZE_1GB, PROT_READ | PROT_WRITE, mmap_flags, -1, 0);
    if (ptr == MAP_FAILED) {
        perror("mmap failed (Ensure 1GB hugepages are allocated in the OS)");
        atomic_store(&keep_running, false);
        exit(EXIT_FAILURE);
    }

    // Bind memory to the specified NUMA memory node
    unsigned long nodemask = (1UL << mem_node);
    if (mbind(ptr, SIZE_1GB, MPOL_BIND, &nodemask, sizeof(nodemask)*8, MPOL_MF_STRICT | MPOL_MF_MOVE) != 0) {
        perror("mbind failed to bind memory to NUMA node");
        atomic_store(&keep_running, false);
        exit(EXIT_FAILURE);
    }
    printf("[*] Allocated 1GB hugepage memory on NUMA node %d\n", mem_node);

    // 4. Initialize Random Sequence (Pointer Chasing setup)
    uint64_t num_elements = SIZE_1GB / CACHELINE_SIZE;
    Node *array = (Node *)ptr;

    printf("[*] Initializing %lu cachelines with a random permutation...\n", num_elements);
    uint64_t *indices = malloc(num_elements * sizeof(uint64_t));
    if (!indices) {
        perror("Failed to allocate index array");
        atomic_store(&keep_running, false);
        exit(EXIT_FAILURE);
    }

    for (uint64_t i = 0; i < num_elements; i++) {
        indices[i] = i;
    }

    srand(time(NULL));
    for (uint64_t i = num_elements - 1; i > 0; i--) {
        uint64_t r = ((uint64_t)rand() << 31) | rand();
        uint64_t j = r % (i + 1);

        uint64_t temp = indices[i];
        indices[i] = indices[j];
        indices[j] = temp;
    }

    for (uint64_t i = 0; i < num_elements - 1; i++) {
        array[indices[i]].next_idx = indices[i + 1];
    }
    array[indices[num_elements - 1]].next_idx = indices[0];

    free(indices);
    printf("[*] Initialization complete. Starting memory traversal.\n\n");

    // 5. Measure latency across iterations
    uint64_t curr = 0;
    uint64_t *samples = malloc(iterations * sizeof(uint64_t));
    if (!samples) {
        perror("Failed to allocate samples array");
        atomic_store(&keep_running, false);
        exit(EXIT_FAILURE);
    }

    for (uint64_t it = 0; it < iterations; it++) {
        uint64_t start_tsc = rdtsc();

        for (uint64_t i = 0; i < num_elements; i++) {
            curr = array[curr].next_idx;
            global_counter++;
        }

        uint64_t end_tsc = rdtsc();
        samples[it] = end_tsc - start_tsc;
    }

    // Stop the loaders
    atomic_store(&keep_running, false);

    asm volatile("" : : "r"(curr), "r"(global_counter) : "memory");

    // 6. Compute Statistics
    uint64_t min_cycles = UINT64_MAX;
    uint64_t max_cycles = 0;
    uint64_t sum_cycles = 0;

    printf("--- Sample Points ---\n");
    for (uint64_t it = 0; it < iterations; it++) {
        double cycles_per_access = (double)samples[it] / num_elements;
        printf("Sample %3lu : Total Cycles = %12lu | Cycles / Cacheline = %6.2f\n",
               it, samples[it], cycles_per_access);

        if (samples[it] < min_cycles) min_cycles = samples[it];
        if (samples[it] > max_cycles) max_cycles = samples[it];
        sum_cycles += samples[it];
    }

    double mean_cycles = (double)sum_cycles / iterations;
    double mean_cpa = mean_cycles / num_elements;
    double min_cpa = (double)min_cycles / num_elements;
    double max_cpa = (double)max_cycles / num_elements;

    printf("\n--- Final Statistics ---\n");
    printf("Total Iterations  : %lu\n", iterations);
    printf("Accesses per Iter : %lu\n", num_elements);
    printf("Total Accesses    : %lu\n\n", global_counter);

    printf("Sample Min        : %12lu cycles (%.2f cycles/cacheline)\n", min_cycles, min_cpa);
    printf("Sample Max        : %12lu cycles (%.2f cycles/cacheline)\n", max_cycles, max_cpa);
    printf("Sample Mean / Avg : %12.2f cycles (%.2f cycles/cacheline)\n", mean_cycles, mean_cpa);

    // 7. Cleanup
    if (loaded && num_loaders > 0) {
        printf("\n[*] Waiting for %d loader threads to exit...\n", num_loaders);
        for (int i = 0; i < num_loaders; i++) {
            pthread_join(loader_threads[i], NULL);
        }
        free(loader_threads);
    }

    free(samples);
    munmap(ptr, SIZE_1GB);
    return 0;
}
