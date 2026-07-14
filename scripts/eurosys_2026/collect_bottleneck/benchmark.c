#define _GNU_SOURCE // Required for pthread_barrier and CPU affinity
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <sched.h>
#include <sys/mman.h>
#include <numa.h>
#include <numaif.h>
#include <unistd.h>
#include <stdint.h>
#include <time.h>
#include <immintrin.h> // Required for _mm_prefetch, AVX-512, and _mm_crc32_u64
#include <smmintrin.h> // specifically for SSE4.2 CRC32
#include <x86intrin.h> // NEW: Required for __rdtsc()

#define HUGE_PAGE_SIZE (2 * 1024 * 1024) // 2MB
#ifndef MAP_HUGE_2MB
#define MAP_HUGE_2MB (21 << 26)
#endif

#define MAX_PATTERNS 64
#define MAX_REGIONS 64
#define NUM_ITERATIONS 100 // Adjust as needed

// Topology Limits
#define MAX_NUMA_NODES 128
#define MAX_CPUS_PER_NODE 1024

// ---------------------------------------------------------
// Compile-Time Access Pattern Macros
// ---------------------------------------------------------
#if defined(RANDOM)
    #define GET_IDX(idx_var, i, state_var) \
        uint64_t idx_var = _mm_crc32_u64(state_var, (uint64_t)(i)) & (NUM_CACHELINES - 1); \
        (void)idx_var
    #define GET_LOOKAHEAD_IDX(idx_var, i, state_var) \
        uint64_t idx_var = _mm_crc32_u64(state_var, (uint64_t)((i) + PREFETCH_AHEAD)) & (NUM_CACHELINES - 1); \
        (void)idx_var
#elif defined(SEQUENTIAL) || defined(SEQUANTIAL)
    #define GET_IDX(idx_var, i, state_var) \
        uint64_t idx_var = (i) & (NUM_CACHELINES - 1); \
        (void)idx_var
    #define GET_LOOKAHEAD_IDX(idx_var, i, state_var) \
        uint64_t idx_var = ((i) + PREFETCH_AHEAD) & (NUM_CACHELINES - 1); \
        (void)idx_var
#else
    #define GET_IDX(idx_var, i, state_var) \
        uint64_t idx_var = workload[i]; \
        (void)idx_var
    #define GET_LOOKAHEAD_IDX(idx_var, i, state_var) \
        uint64_t idx_var = workload[(i) + PREFETCH_AHEAD]; \
        (void)idx_var
#endif
// ---------------------------------------------------------

typedef enum {
    INST_LOAD,
    INST_AVX512_LOAD,
    INST_PREFETCH_T0,
    INST_PREFETCH_T1,
    INST_PREFETCH_T2,
    INST_PREFETCH_NTA
} inst_type_t;

typedef struct {
    int cpu_node;
    int mem_node;
    int num_threads;
} pattern_t;

typedef struct {
    int thread_id;
    int cpu_id;
    int mem_node;
    size_t chunk_size;
    uint64_t *buffer;
    inst_type_t inst_type;
    uint64_t lookahead;
    uint64_t elapsed_cycles; // NEW: Store cycles taken by this thread
} thread_arg_t;

// Global Synchronization Barriers
pthread_barrier_t init_barrier;
pthread_barrier_t start_barrier;
pthread_barrier_t end_barrier;

// Global dummy variable to prevent compiler from optimizing away the reads
volatile uint64_t global_sink = 0;

size_t parse_size(const char *str) {
    char *endptr;
    double val = strtod(str, &endptr);
    if (*endptr != '\0') {
        if (*endptr == 'k' || *endptr == 'K') val *= 1024;
        else if (*endptr == 'm' || *endptr == 'M') val *= 1024 * 1024;
        else if (*endptr == 'g' || *endptr == 'G') val *= 1024 * 1024 * 1024;
    }
    return (size_t)val;
}

// Worker Thread: Allocation, Binding, Initialization, and Reading
void *mem_worker(void *arg) {
    thread_arg_t *t = (thread_arg_t *)arg;

    // Pin Thread strictly to the exact assigned CPU ID
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(t->cpu_id, &cpuset);
    if (pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset) != 0) {
        perror("pthread_setaffinity_np failed");
        pthread_exit(NULL);
    }

    // Delayed Allocation
    t->buffer = mmap(NULL, t->chunk_size, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | MAP_HUGE_2MB, -1, 0);
    if (t->buffer == MAP_FAILED) {
        perror("mmap failed");
        pthread_exit(NULL);
    }

    // Bind strictly to the target memory NUMA node
    unsigned long nodemask = (1UL << t->mem_node);
    if (mbind(t->buffer, t->chunk_size, MPOL_BIND, &nodemask, sizeof(nodemask)*8, MPOL_MF_STRICT | MPOL_MF_MOVE) != 0) {
        perror("mbind failed");
        pthread_exit(NULL);
    }

    memset(t->buffer, 1, t->chunk_size);

    // ==========================================
    pthread_barrier_wait(&init_barrier);
    pthread_barrier_wait(&start_barrier);
    // ==========================================

    // Variables required by the macros
    uint64_t NUM_CACHELINES = t->chunk_size / 64;
    uint64_t PREFETCH_AHEAD = t->lookahead;
    uint64_t state_var = t->thread_id + 0xDEADBEEF; // Constant seed for stateless hash
    uint64_t *workload = NULL; // Included just to satisfy the fallback macro compile branch if used

    uint64_t ops = NUM_CACHELINES;
    uint64_t local_dummy = 0;

    // NEW: Start cycle counter
    uint64_t start_tsc = __rdtsc();

    // The Read-Only Benchmark Loop
    for (int iter = 0; iter < NUM_ITERATIONS; iter++) {
        switch (t->inst_type) {
            case INST_LOAD:
                for (uint64_t i = 0; i < ops; i++) {
                    GET_IDX(idx, i, state_var);
                    local_dummy += t->buffer[idx * 8]; // *8 because buffer is uint64_t (8 bytes). 8 * 8 = 64 bytes (cacheline)
                }
                break;

            case INST_AVX512_LOAD:
                for (uint64_t i = 0; i < ops; i++) {
                    GET_IDX(idx, i, state_var);
                    __m512i vec = _mm512_loadu_si512((const void*)&t->buffer[idx * 8]);
                    local_dummy += _mm_cvtsi128_si32(_mm512_castsi512_si128(vec));
                }
                break;

            case INST_PREFETCH_T0:
                for (uint64_t i = 0; i < ops; i++) {
                    GET_IDX(idx, i, state_var);
                    GET_LOOKAHEAD_IDX(idx_lookahead, i, state_var);
                    _mm_prefetch((const char*)&t->buffer[idx_lookahead * 8], _MM_HINT_T0);
                    local_dummy += t->buffer[idx * 8];
                }
                break;

            case INST_PREFETCH_T1:
                for (uint64_t i = 0; i < ops; i++) {
                    GET_IDX(idx, i, state_var);
                    GET_LOOKAHEAD_IDX(idx_lookahead, i, state_var);
                    _mm_prefetch((const char*)&t->buffer[idx_lookahead * 8], _MM_HINT_T1);
                    local_dummy += t->buffer[idx * 8];
                }
                break;

            case INST_PREFETCH_T2:
                for (uint64_t i = 0; i < ops; i++) {
                    GET_IDX(idx, i, state_var);
                    GET_LOOKAHEAD_IDX(idx_lookahead, i, state_var);
                    _mm_prefetch((const char*)&t->buffer[idx_lookahead * 8], _MM_HINT_T2);
                    local_dummy += t->buffer[idx * 8];
                }
                break;

            case INST_PREFETCH_NTA:
                for (uint64_t i = 0; i < ops; i++) {
                    GET_IDX(idx, i, state_var);
                    GET_LOOKAHEAD_IDX(idx_lookahead, i, state_var);
                    _mm_prefetch((const char*)&t->buffer[idx_lookahead * 8], _MM_HINT_NTA);
                    local_dummy += t->buffer[idx * 8];
                }
                break;
        }

        // Forces the compiler to forget all cached memory state, preventing loop hoisting!
        __asm__ volatile("" ::: "memory");
    }

    // NEW: Stop cycle counter and record
    uint64_t end_tsc = __rdtsc();
    t->elapsed_cycles = end_tsc - start_tsc;

    __sync_fetch_and_add(&global_sink, local_dummy);

    // ==========================================
    pthread_barrier_wait(&end_barrier);
    // ==========================================

    munmap(t->buffer, t->chunk_size);
    pthread_exit(NULL);
}

int main(int argc, char *argv[]) {
    if (numa_available() < 0) {
        fprintf(stderr, "Error: NUMA support is not available.\n");
        return -1;
    }

    size_t raw_per_thread_size = 0;
    char *pattern_str = NULL;
    inst_type_t inst = INST_LOAD;
    uint64_t lookahead = 16;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-m") == 0 && i + 1 < argc) raw_per_thread_size = parse_size(argv[++i]);
        else if (strcmp(argv[i], "-pattern") == 0 && i + 1 < argc) pattern_str = argv[++i];
        else if (strcmp(argv[i], "-inst") == 0 && i + 1 < argc) {
            i++;
            if (strcmp(argv[i], "load") == 0) inst = INST_LOAD;
            else if (strcmp(argv[i], "avx512") == 0) inst = INST_AVX512_LOAD;
            else if (strcmp(argv[i], "t0") == 0) inst = INST_PREFETCH_T0;
            else if (strcmp(argv[i], "t1") == 0) inst = INST_PREFETCH_T1;
            else if (strcmp(argv[i], "t2") == 0) inst = INST_PREFETCH_T2;
            else if (strcmp(argv[i], "nta") == 0) inst = INST_PREFETCH_NTA;
            else { fprintf(stderr, "Unknown instruction type: %s\n", argv[i]); return -1; }
        }
        else if (strcmp(argv[i], "-lookahead") == 0 && i + 1 < argc) lookahead = atoi(argv[++i]);
    }

    if (raw_per_thread_size == 0 || pattern_str == NULL) {
        fprintf(stderr, "Usage: %s -m <per_thread_size> -pattern \"n0a0t4...\" [-inst <load|avx512|t0|t1|t2|nta>] [-lookahead <lines>]\n", argv[0]);
        return -1;
    }

    int max_node = numa_max_node();
    if (max_node >= MAX_NUMA_NODES) max_node = MAX_NUMA_NODES - 1;

    int available_cpus[MAX_NUMA_NODES][MAX_CPUS_PER_NODE];
    int next_cpu_idx[MAX_NUMA_NODES] = {0};
    int total_cpus_in_node[MAX_NUMA_NODES] = {0};

    for (int n = 0; n <= max_node; n++) {
        struct bitmask *cpus = numa_allocate_cpumask();
        if (numa_node_to_cpus(n, cpus) == 0) {
            for (int c = 0; c < cpus->size; c++) {
                if (numa_bitmask_isbitset(cpus, c)) {
                    if (total_cpus_in_node[n] < MAX_CPUS_PER_NODE) {
                        available_cpus[n][total_cpus_in_node[n]++] = c;
                    }
                }
            }
        }
        numa_bitmask_free(cpus);
    }

    // Parse Patterns
    pattern_t patterns[MAX_PATTERNS];
    int num_patterns = 0;
    int total_threads = 0;

    char *pattern_copy = strdup(pattern_str);
    char *token = strtok(pattern_copy, ", ");

    while (token != NULL && num_patterns < MAX_PATTERNS) {
        if (sscanf(token, "n%da%dt%d", &patterns[num_patterns].cpu_node,
                   &patterns[num_patterns].mem_node, &patterns[num_patterns].num_threads) == 3) {
            total_threads += patterns[num_patterns].num_threads;
            num_patterns++;
        }
        token = strtok(NULL, ", ");
    }
    free(pattern_copy);

    pthread_barrier_init(&init_barrier, NULL, total_threads + 1);
    pthread_barrier_init(&start_barrier, NULL, total_threads + 1);
    pthread_barrier_init(&end_barrier, NULL, total_threads + 1);

    pthread_t threads[256];
    thread_arg_t thread_args[256];
    int t_idx = 0;
    size_t actual_total_allocated = 0;

    // ---> POWER OF 2 & 2MB ALIGNMENT CLAMPING <---
    size_t chunk_per_thread = HUGE_PAGE_SIZE;
    while ((chunk_per_thread * 2) <= raw_per_thread_size) {
        chunk_per_thread *= 2;
    }

    printf("Requested per-thread size : ~%zu MB\n", raw_per_thread_size / (1024*1024));
    printf("Clamped per-thread size   : %zu MB (Power of 2 & 2MB Aligned)\n\n", chunk_per_thread / (1024*1024));

    for (int p = 0; p < num_patterns; p++) {
        for (int t = 0; t < patterns[p].num_threads; t++) {
            int node = patterns[p].cpu_node;

            if (next_cpu_idx[node] >= total_cpus_in_node[node]) {
                fprintf(stderr, "Error: Not enough CPUs available on NUMA node %d!\n", node);
                exit(EXIT_FAILURE);
            }

            int assigned_cpu_id = available_cpus[node][next_cpu_idx[node]++];

            thread_args[t_idx].thread_id = t_idx;
            thread_args[t_idx].cpu_id = assigned_cpu_id;
            thread_args[t_idx].mem_node = patterns[p].mem_node;
            thread_args[t_idx].chunk_size = chunk_per_thread;
            thread_args[t_idx].inst_type = inst;
            thread_args[t_idx].lookahead = lookahead;
            thread_args[t_idx].elapsed_cycles = 0; // Initialize cycles

            actual_total_allocated += chunk_per_thread;

            printf("Spawning Thread %d -> Pinned to CPU %d (Node %d), Target Memory Node %d\n",
                   t_idx, assigned_cpu_id, node, patterns[p].mem_node);

            pthread_create(&threads[t_idx], NULL, mem_worker, &thread_args[t_idx]);
            t_idx++;
        }
    }

    printf("\nSetup: Spawning %d threads.\n", total_threads);
    printf("Total memory allocated across all threads: %zu MB.\n\n", actual_total_allocated / (1024*1024));

    pthread_barrier_wait(&init_barrier);
    printf("-> [1/2] All threads allocated, wrote to local 2MB huge pages, and pinned to cores.\n");

    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    printf("-> [2/2] Timer started. Beginning reads.\n");
    pthread_barrier_wait(&start_barrier);

    pthread_barrier_wait(&end_barrier);
    clock_gettime(CLOCK_MONOTONIC, &end);

    for (int i = 0; i < total_threads; i++) {
        pthread_join(threads[i], NULL);
    }

    double time_taken = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
    size_t total_bytes_read = actual_total_allocated * NUM_ITERATIONS;
    double gb_read = (double)total_bytes_read / (1024.0 * 1024.0 * 1024.0);
    double bandwidth = gb_read / time_taken;

    printf("\n============================================\n");
    printf("Configuration   : Inst: %d | Lookahead: %lu\n", inst, lookahead);
#if defined(RANDOM)
    printf("Mode            : RANDOM (CRC32 Stateless Hash)\n");
#elif defined(SEQUENTIAL) || defined(SEQUANTIAL)
    printf("Mode            : SEQUENTIAL\n");
#else
    printf("Mode            : CUSTOM ARRAY\n");
#endif
    printf("Total Data Read : %.2f GB\n", gb_read);
    printf("Time Taken      : %.4f seconds\n", time_taken);
    printf("Bandwidth       : %.2f GB/s\n", bandwidth);
    printf("dummy value     : %lu\n", global_sink);

    // NEW: Calculate and print Per-Thread Cycles/Op
    printf("--------------------------------------------\n");
    printf("Cycles Per Operation (per thread):\n");
    uint64_t total_ops_per_thread = (chunk_per_thread / 64) * NUM_ITERATIONS;


    double aggr_cpo = 0;
    for (int i = 0; i < total_threads; i++) {
        double cycles_per_op = (double)thread_args[i].elapsed_cycles / total_ops_per_thread;
        printf("  Thread %2d (CPU %3d) : %7.2f cycles/op\n",
               thread_args[i].thread_id, thread_args[i].cpu_id, cycles_per_op);
        aggr_cpo += cycles_per_op;
    }
    printf("============================================\n");

    printf("Average cycle per operation: %.2f cycles/op\n", aggr_cpo/total_threads);
    printf("Predicted peak banwidth: %.2f GB/s\n", (double) 3.25 * 64 * total_threads * total_threads / aggr_cpo);

    pthread_barrier_destroy(&init_barrier);
    pthread_barrier_destroy(&start_barrier);
    pthread_barrier_destroy(&end_barrier);
    return 0;
}
