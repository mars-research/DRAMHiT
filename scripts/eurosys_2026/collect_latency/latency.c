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
#include <xmmintrin.h> // Required for _mm_prefetch

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

// Node structure: 64 bytes total.
// We now store both next_idx and lookahead_idx in the same cacheline.
typedef struct {
    uint64_t next_idx;
    uint64_t lookahead_idx;
    uint8_t padding[CACHELINE_SIZE - 2 * sizeof(uint64_t)];
} __attribute__((aligned(CACHELINE_SIZE))) Node;

volatile uint64_t global_counter = 0;
atomic_bool keep_running = true;

// Loader thread arguments
typedef struct {
    int cpu_id;
    int mem_node;
} LoaderArgs;

// Helper to determine the unique physical core ID of a logical CPU
uint64_t get_physical_core_id(int cpu) {
    char path[256];
    int core_id = -1, pkg_id = -1;

    snprintf(path, sizeof(path), "/sys/devices/system/cpu/cpu%d/topology/core_id", cpu);
    FILE *f = fopen(path, "r");
    if (f) { fscanf(f, "%d", &core_id); fclose(f); }

    snprintf(path, sizeof(path), "/sys/devices/system/cpu/cpu%d/topology/physical_package_id", cpu);
    f = fopen(path, "r");
    if (f) { fscanf(f, "%d", &pkg_id); fclose(f); }

    if (core_id == -1) return (uint64_t)cpu;
    if (pkg_id == -1) pkg_id = 0;

    return ((uint64_t)pkg_id << 32) | (uint32_t)core_id;
}

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

    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(cpu, &cpuset);
    if (pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset) != 0) {
        perror("Loader failed to set CPU affinity");
        return NULL;
    }

    int mmap_flags = MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | MAP_HUGE_2MB;
    uint64_t *ptr = mmap(NULL, SIZE_128MB, PROT_READ | PROT_WRITE, mmap_flags, -1, 0);
    if (ptr == MAP_FAILED) {
        perror("Loader mmap failed");
        return NULL;
    }

    unsigned long nodemask = (1UL << mem_node);
    if (mbind(ptr, SIZE_128MB, MPOL_BIND, &nodemask, sizeof(nodemask)*8, MPOL_MF_STRICT | MPOL_MF_MOVE) != 0) {
        perror("Loader mbind failed");
        munmap(ptr, SIZE_128MB);
        return NULL;
    }

    uint64_t num_elements = SIZE_128MB / sizeof(uint64_t);
    uint64_t mask = num_elements - 1;
    uint64_t idx = 0;
    uint64_t dummy_counter = 0;

    while (atomic_load(&keep_running)) {
        idx = (idx * 1103515245ULL + 12345ULL) & mask;
        dummy_counter += ptr[idx];
        ptr[idx] = dummy_counter + 1;
    }

    munmap(ptr, SIZE_128MB);
    return NULL;
}

int main(int argc, char *argv[]) {
    if (argc != 7) {
        fprintf(stderr, "Usage: %s <mem_numa_node> <cpu_numa_node> <iterations> <loaded: 0|1> <lookahead> <prefetch_type>\n", argv[0]);
        fprintf(stderr, "Prefetch types:\n");
        fprintf(stderr, "  0 = None\n");
        fprintf(stderr, "  1 = _MM_HINT_T0  (All cache levels)\n");
        fprintf(stderr, "  2 = _MM_HINT_T1  (L2 and higher)\n");
        fprintf(stderr, "  3 = _MM_HINT_T2  (L3 and higher)\n");
        fprintf(stderr, "  4 = _MM_HINT_NTA (Non-temporal)\n");
        exit(EXIT_FAILURE);
    }

    int mem_node = atoi(argv[1]);
    int cpu_node = atoi(argv[2]);
    uint64_t iterations = strtoull(argv[3], NULL, 10);
    int loaded = atoi(argv[4]);
    uint64_t lookahead = (uint64_t)atoi(argv[5]);
    int prefetch_type = atoi(argv[6]);

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

    uint64_t main_core = get_physical_core_id(main_cpu);

    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(main_cpu, &cpuset);
    if (sched_setaffinity(0, sizeof(cpu_set_t), &cpuset) != 0) {
        perror("Failed to pin main thread");
        exit(EXIT_FAILURE);
    }
    printf("[*] Pinned latency thread to CPU %d (Physical Core ID: 0x%lx)\n", main_cpu, main_core);

    // 2. Spawn loader threads if requested
    pthread_t *loader_threads = NULL;
    int num_loaders = 0;

    if (loaded) {
        struct bitmask *mem_node_cpus = numa_allocate_cpumask();
        numa_node_to_cpus(mem_node, mem_node_cpus);

        loader_threads = malloc(mem_node_cpus->size * sizeof(pthread_t));

        for (int i = 0; i < mem_node_cpus->size; i++) {
            if (numa_bitmask_isbitset(mem_node_cpus, i)) {
                uint64_t curr_core = get_physical_core_id(i);

                if (curr_core == main_core) {
                    continue;
                }

                LoaderArgs *args = malloc(sizeof(LoaderArgs));
                args->cpu_id = i;
                args->mem_node = mem_node;
                pthread_create(&loader_threads[num_loaders], NULL, loader_thread_func, args);

                num_loaders++;
            }
        }

        printf("[*] Spawned %d loader threads on NUMA node %d\n", num_loaders, mem_node);
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

    unsigned long nodemask = (1UL << mem_node);
    if (mbind(ptr, SIZE_1GB, MPOL_BIND, &nodemask, sizeof(nodemask)*8, MPOL_MF_STRICT | MPOL_MF_MOVE) != 0) {
        perror("mbind failed to bind memory to NUMA node");
        atomic_store(&keep_running, false);
        exit(EXIT_FAILURE);
    }
    printf("[*] Allocated 1GB hugepage memory on NUMA node %d\n", mem_node);

    // 4. Initialize Random Sequence with Embedded Lookahead
    uint64_t num_elements = SIZE_1GB / CACHELINE_SIZE;
    uint64_t mask = num_elements - 1;
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

    // Embed both next_idx and lookahead_idx directly into the array nodes
    for (uint64_t i = 0; i < num_elements; i++) {
        array[indices[i]].next_idx = indices[(i + 1) & mask];
        array[indices[i]].lookahead_idx = indices[(i + lookahead) & mask];
    }

    // We no longer need the indices array during the traversal! Free it now.
    free(indices);

    printf("[*] Initialization complete. Starting memory traversal.\n");
    printf("[*] Lookahead: %lu cachelines | Prefetch Type: %d\n\n", lookahead, prefetch_type);

    // 5. Measure latency across iterations
    uint64_t curr = 0; // Starts at index 0
    uint64_t sum = 0;
    uint64_t *samples = malloc(iterations * sizeof(uint64_t));
    if (!samples) {
        perror("Failed to allocate samples array");
        atomic_store(&keep_running, false);
        exit(EXIT_FAILURE);
    }

    for (uint64_t it = 0; it < iterations; it++) {
        uint64_t start_tsc = rdtsc();

        switch(prefetch_type) {
            case 1: // T0
                for (uint64_t i = 0; i < num_elements; i++) {
                    _mm_prefetch((const char *)&array[array[curr].lookahead_idx], _MM_HINT_T0);
                    curr = array[curr].next_idx;
                    sum += curr;
                }
                break;
            case 2: // T1
                for (uint64_t i = 0; i < num_elements; i++) {
                    _mm_prefetch((const char *)&array[array[curr].lookahead_idx], _MM_HINT_T1);
                    curr = array[curr].next_idx;
                    sum += curr;
                }
                break;
            case 3: // T2
                for (uint64_t i = 0; i < num_elements; i++) {
                    _mm_prefetch((const char *)&array[array[curr].lookahead_idx], _MM_HINT_T2);
                    curr = array[curr].next_idx;
                    sum += curr;
                }
                break;
            case 4: // NTA
                for (uint64_t i = 0; i < num_elements; i++) {
                    _mm_prefetch((const char *)&array[array[curr].lookahead_idx], _MM_HINT_NTA);
                    curr = array[curr].next_idx;
                    sum += curr;
                }
                break;
            case 0: // No prefetch
            default:
                for (uint64_t i = 0; i < num_elements; i++) {
                    curr = array[curr].next_idx;
                    sum += curr;
                }
                break;
        }

        uint64_t end_tsc = rdtsc();
        samples[it] = end_tsc - start_tsc;
        global_counter += num_elements;
        printf("sample %lu, curr %lu, sum %lu\n",it, curr, sum);
    }

    // Stop the loaders
    atomic_store(&keep_running, false);

    // Double layer of protection against Dead Code Elimination
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

    // This print statement is crucial: it forces the compiler to evaluate 'curr'
    // and thus prevents it from optimizing out the pointer-chasing loop entirely.
    printf("\n[Anti-Optimization] Final curr value: %lu\n", curr);

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
