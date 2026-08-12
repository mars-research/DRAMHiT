#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <time.h>
#include <pthread.h>
#include <sched.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <x86intrin.h>
#include <immintrin.h>
#include <numa.h>   // Required for libnuma bitmasks (numa_allocate_cpumask, etc.)
#include <numaif.h> // Required for mbind()

#if !defined(RANDOM) && !defined(SEQUENTIAL) && !defined(SEQUANTIAL)
#define RANDOM
#endif

#define CACHELINE_SIZE 64
// 8 GB Total Memory
#define MEMORY_SIZE (8ULL * 1024 * 1024 * 1024)
#define NUM_CACHELINES (MEMORY_SIZE / CACHELINE_SIZE)

// 128 MB for Busyworker Threads
#define BUSY_MEM_SIZE (128ULL * 1024 * 1024)

int prefetch_ahead = 128;

#ifndef MAP_HUGE_1GB
#define MAP_HUGE_1GB (30 << MAP_HUGE_SHIFT)
#endif

#if defined(RANDOM)
    #define GET_IDX(idx_var, i, state_var) \
        uint64_t idx_var = _mm_crc32_u64(state_var, (uint64_t)(i)) & (NUM_CACHELINES - 1); \
        (void)idx_var
    #define GET_LOOKAHEAD_IDX(idx_var, i, state_var) \
        uint64_t idx_var = _mm_crc32_u64(state_var, (uint64_t)((i) + prefetch_ahead)) & (NUM_CACHELINES - 1); \
        (void)idx_var
#elif defined(SEQUENTIAL) || defined(SEQUANTIAL)
    #define GET_IDX(idx_var, i, state_var) \
        uint64_t idx_var = (i) & (NUM_CACHELINES - 1); \
        (void)idx_var
    #define GET_LOOKAHEAD_IDX(idx_var, i, state_var) \
        uint64_t idx_var = ((i) + prefetch_ahead) & (NUM_CACHELINES - 1); \
        (void)idx_var
#else
    #define GET_IDX(idx_var, i, state_var) \
        uint64_t idx_var = workload[i]; \
        (void)idx_var
    #define GET_LOOKAHEAD_IDX(idx_var, i, state_var) \
        uint64_t idx_var = workload[(i) + prefetch_ahead]; \
        (void)idx_var
#endif

typedef struct __attribute__((aligned(64))) {
    char data[CACHELINE_SIZE];
} cacheline_t;

typedef enum {
    INST_LOAD = 0,
    INST_AVX512_LOAD,
    INST_PREFETCH_T0,
    INST_PREFETCH_T1,
    INST_PREFETCH_T2,
    INST_PREFETCH_NTA
} instruction_type_t;

typedef struct {
    int thread_id;
    int logical_cpu;
    uint64_t ops;
    instruction_type_t inst_type;
    cacheline_t* mem;
    uint64_t* workload;
    uint64_t duration_cycles;
    uint64_t dummy_accumulator;
} thread_ctx_t;

typedef struct {
    int logical_cpu;
    volatile int* stop_flag;
} busyworker_ctx_t;

static inline uint64_t RDTSC_START(void) {
    unsigned cycles_low, cycles_high;
    asm volatile(
        "CPUID\n\t"
        "RDTSC\n\t"
        "mov %%edx, %0\n\t"
        "mov %%eax, %1\n\t"
        : "=r"(cycles_high), "=r"(cycles_low)::"%rax", "%rbx", "%rcx", "%rdx");
    return ((uint64_t)cycles_high << 32) | cycles_low;
}

static inline uint64_t RDTSCP(void) {
    unsigned cycles_low, cycles_high;
    asm volatile(
        "RDTSCP\n\t"
        "mov %%edx, %0\n\t"
        "mov %%eax, %1\n\t"
        "CPUID\n\t"
        : "=r"(cycles_high), "=r"(cycles_low)::"%rax", "%rbx", "%rcx", "%rdx");
    return ((uint64_t)cycles_high << 32) | cycles_low;
}

cacheline_t* alloc_8gb_memory(int numa_node) {
    printf("Attempting to allocate 8GB using 1GB Hugepages...\n");
    void* ptr = mmap(NULL, MEMORY_SIZE, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | MAP_HUGE_1GB, -1, 0);

    if (ptr == MAP_FAILED) {
        printf("  -> [WARN] 1GB Hugepages failed. Trying 2MB Hugepages...\n");
        ptr = mmap(NULL, MEMORY_SIZE, PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
        if (ptr == MAP_FAILED) {
            printf("  -> [WARN] 2MB Hugepages failed. Falling back to 4KB pages.\n");
            ptr = mmap(NULL, MEMORY_SIZE, PROT_READ | PROT_WRITE,
                       MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
            if (ptr == MAP_FAILED) {
                perror("Fatal: Memory allocation failed entirely");
                exit(1);
            }
        } else {
            printf("  -> Success with 2MB Hugepages.\n");
        }
    } else {
        printf("  -> Success with 1GB Hugepages.\n");
    }

    if (numa_node >= 0) {
        unsigned long nodemask = 1UL << numa_node;
        if (mbind(ptr, MEMORY_SIZE, MPOL_BIND, &nodemask, 64, 0) != 0) {
            perror("  -> [ERROR] mbind failed to bind memory to NUMA node");
        } else {
            printf("  -> Successfully bound allocation to NUMA node %d.\n", numa_node);
        }
    }

    printf("  -> Faulting memory...\n");
    memset(ptr, 1, MEMORY_SIZE);
    return ptr;
}

// Get the physical core ID of a logical CPU
int get_physical_core_id(int cpu_id) {
    char path[256];
    snprintf(path, sizeof(path), "/sys/devices/system/cpu/cpu%d/topology/core_id", cpu_id);
    FILE *f = fopen(path, "r");
    if (f) {
        int core_id = -1;
        if (fscanf(f, "%d", &core_id) == 1) {
            fclose(f);
            return core_id;
        }
        fclose(f);
    }
    return cpu_id; // Fallback to logical ID if unavailable
}

// Find measurement cores within the specified NUMA node using libnuma
int get_measurement_cpus(int target_node, int* core_a, int* core_b) {
    *core_a = -1;
    *core_b = -1;

    struct bitmask *node_cpus = numa_allocate_cpumask();
    if (numa_node_to_cpus(target_node, node_cpus) != 0) {
        numa_free_cpumask(node_cpus);
        return -1;
    }

    // Find the first available CPU in the node
    for (int i = 0; i < node_cpus->size; i++) {
        if (numa_bitmask_isbitset(node_cpus, i)) {
            if (*core_a == -1) {
                *core_a = i;
            } else {
                // Check if this CPU shares the same physical core (hyperthread sibling)
                if (get_physical_core_id(i) == get_physical_core_id(*core_a)) {
                    *core_b = i;
                    break;
                }
            }
        }
    }

    // If no hyperthread was found, grab the next available core in the same NUMA node
    if (*core_a != -1 && *core_b == -1) {
        for (int i = *core_a + 1; i < node_cpus->size; i++) {
            if (numa_bitmask_isbitset(node_cpus, i)) {
                *core_b = i;
                break;
            }
        }
    }

    numa_free_cpumask(node_cpus);
    return (*core_a != -1) ? 0 : -1;
}

void* busyworker_thread(void* arg) {
    busyworker_ctx_t* ctx = (busyworker_ctx_t*)arg;

    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(ctx->logical_cpu, &cpuset);
    pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset);

    cacheline_t* mem = mmap(NULL, BUSY_MEM_SIZE, PROT_READ | PROT_WRITE,
                            MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
    if (mem == MAP_FAILED) {
        mem = mmap(NULL, BUSY_MEM_SIZE, PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
        if (mem == MAP_FAILED) return NULL;
    }

    memset(mem, 1, BUSY_MEM_SIZE);

    uint64_t num_lines = BUSY_MEM_SIZE / CACHELINE_SIZE;
    uint64_t mask = num_lines - 1;
    uint64_t dummy = 0;
    uint64_t state = _mm_crc32_u64((uint64_t)time(NULL), (uint64_t)ctx->logical_cpu);

    uint64_t i = 0;
    while (!*(ctx->stop_flag)) {
        for (int b = 0; b < 1024; b++, i++) {
            // Generate distinct random indices for current execution and lookahead
            uint64_t idx = _mm_crc32_u64(state, i) & mask;
            uint64_t idx_lookahead = _mm_crc32_u64(state, i + prefetch_ahead) & mask;

            // Issue Prefetch T1 for the lookahead cacheline
            _mm_prefetch((const char*)&mem[idx_lookahead], _MM_HINT_T1);

            // Perform actual load to force evaluation
            dummy += mem[idx].data[0];
        }
    }

    asm volatile("" : : "g"(dummy) : "memory");
    munmap(mem, BUSY_MEM_SIZE);

    return NULL;
}

__attribute__((target("avx512f,sse4.2")))
void* worker_thread(void* arg) {
    thread_ctx_t* ctx = (thread_ctx_t*)arg;

    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    CPU_SET(ctx->logical_cpu, &cpuset);
    if (pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset) != 0) {
        perror("pthread_setaffinity_np failed");
    }

    uint64_t ops = ctx->ops;
    cacheline_t* mem = ctx->mem;
    uint64_t* workload = ctx->workload;
    uint64_t dummy = 0;

    uint64_t state = _mm_crc32_u64((uint64_t)time(NULL) ^ ctx->thread_id, (uint64_t)random());

    asm volatile("" ::: "memory");
    uint64_t start = RDTSC_START();

    switch (ctx->inst_type) {
        case INST_LOAD:
            for (uint64_t i = 0; i < ops; i++) {
                GET_IDX(idx, i, state);
#ifndef NONE_BIND
                dummy += mem[idx].data[0];
#endif
            }
            break;
        case INST_AVX512_LOAD:
            for (uint64_t i = 0; i < ops; i++) {
                GET_IDX(idx, i, state);
                __m512i vec = _mm512_loadu_si512((const void*)&mem[idx]);
#ifndef NONE_BIND
                dummy += ((uint8_t*)&vec)[0];
#else
                (void)vec;
#endif
            }
            break;
        case INST_PREFETCH_T0:
            for (uint64_t i = 0; i < ops; i++) {
                GET_IDX(idx, i, state);
                GET_LOOKAHEAD_IDX(idx_lookahead, i, state);
                _mm_prefetch((const char*)&mem[idx_lookahead], _MM_HINT_T0);
#ifndef NONE_BIND
                dummy += mem[idx].data[0];
#endif
            }
            break;
        case INST_PREFETCH_T1:
            for (uint64_t i = 0; i < ops; i++) {
                GET_IDX(idx, i, state);
                GET_LOOKAHEAD_IDX(idx_lookahead, i, state);
                _mm_prefetch((const char*)&mem[idx_lookahead], _MM_HINT_T1);
#ifndef NONE_BIND
                dummy += mem[idx].data[0];
#endif
            }
            break;
        case INST_PREFETCH_T2:
            for (uint64_t i = 0; i < ops; i++) {
                GET_IDX(idx, i, state);
                GET_LOOKAHEAD_IDX(idx_lookahead, i, state);
                _mm_prefetch((const char*)&mem[idx_lookahead], _MM_HINT_T2);
#ifndef NONE_BIND
                dummy += mem[idx].data[0];
#endif
            }
            break;
        case INST_PREFETCH_NTA:
            for (uint64_t i = 0; i < ops; i++) {
                GET_IDX(idx, i, state);
                GET_LOOKAHEAD_IDX(idx_lookahead, i, state);
                _mm_prefetch((const char*)&mem[idx_lookahead], _MM_HINT_NTA);
#ifndef NONE_BIND
                dummy += mem[idx].data[0];
#endif
            }
            break;
    }

    uint64_t end = RDTSCP();
    asm volatile("" ::: "memory");

    ctx->duration_cycles = end - start;
    ctx->dummy_accumulator = dummy;

    return NULL;
}

void print_usage(const char* prog_name) {
    fprintf(stderr, "Usage: %s -inst_type <0-5> -ops <count> [options]\n", prog_name);
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "  -inst_type <0-5>   Instruction type (0: Load, 1: AVX512 Load, 2: PF_T0, 3: PF_T1, 4: PF_T2, 5: PF_NTA)\n");
    fprintf(stderr, "  -ops <count>       Number of operations to perform\n");
    fprintf(stderr, "  -threads <1-2>     Number of threads (default: 1)\n");
    fprintf(stderr, "  -mem_node <node>   NUMA node for memory allocation (default: 0)\n");
    fprintf(stderr, "  -cpu_node <node>   NUMA node for thread execution (default: 0)\n");
    fprintf(stderr, "  -ahead <count>     Prefetch lookahead distance (default: 128)\n");
    fprintf(stderr, "  -loaded <0/1>      Enable loaded background workers (default: 0)\n");
}

int main(int argc, char** argv) {
    if (numa_available() < 0) {
        fprintf(stderr, "System does not support NUMA API.\n");
        return 1;
    }

    // Default arguments
    int enable_loaded = 0;
    int cpu_node = 0;
    int mem_numa_node = 0;
    int num_threads = 1;
    int inst_type = -1;
    uint64_t num_ops = 0;

    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-ahead") == 0 && i + 1 < argc) {
            prefetch_ahead = atoi(argv[++i]);
        } else if (strcmp(argv[i], "-loaded") == 0 && i + 1 < argc) {
            enable_loaded = atoi(argv[++i]);
        } else if (strcmp(argv[i], "-cpu_node") == 0 && i + 1 < argc) {
            cpu_node = atoi(argv[++i]);
        } else if (strcmp(argv[i], "-inst_type") == 0 && i + 1 < argc) {
            inst_type = atoi(argv[++i]);
        } else if (strcmp(argv[i], "-ops") == 0 && i + 1 < argc) {
            num_ops = strtoull(argv[++i], NULL, 10);
        } else if (strcmp(argv[i], "-threads") == 0 && i + 1 < argc) {
            num_threads = atoi(argv[++i]);
        } else if (strcmp(argv[i], "-mem_node") == 0 && i + 1 < argc) {
            mem_numa_node = atoi(argv[++i]);
        } else {
            fprintf(stderr, "Unknown or incomplete argument: %s\n", argv[i]);
            print_usage(argv[0]);
            return 1;
        }
    }

    // Validate required arguments
    if (inst_type < 0 || inst_type > 5 || num_ops == 0) {
        fprintf(stderr, "Error: -inst_type and -ops are required.\n\n");
        print_usage(argv[0]);
        return 1;
    }

    if (num_threads < 1 || num_threads > 2) {
        fprintf(stderr, "Error: -threads must be 1 or 2.\n");
        return 1;
    }

    const char* inst_names[] = {"Load", "AVX512 Load", "Prefetch T0", "Prefetch T1", "Prefetch T2", "Prefetch NTA"};
    printf("Execute Type: %s (Lookahead: %d)\n", inst_names[inst_type], prefetch_ahead);

    int core_a, core_b;
    if (get_measurement_cpus(cpu_node, &core_a, &core_b) != 0) {
        fprintf(stderr, "Fatal: Could not find any valid CPUs for CPU Node %d.\n", cpu_node);
        return 1;
    }

    if (num_threads == 2 && core_b == -1) {
        fprintf(stderr, "[WARN] Could not find secondary CPU in Node %d for thread 2. Using CPU 2 as fallback.\n", cpu_node);
        core_b = 2;
    }

    cacheline_t* mem = alloc_8gb_memory(mem_numa_node);

    pthread_t threads[2];
    thread_ctx_t ctx[2];

    printf("\n--- Setup ---\n");
    for (int t = 0; t < num_threads; t++) {
        ctx[t].thread_id = t;
        ctx[t].logical_cpu = (t == 0) ? core_a : core_b;
        ctx[t].ops = num_ops;
        ctx[t].inst_type = inst_type;
        ctx[t].mem = mem;

        printf("Initializing workload for Thread %d (Pinned to CPU %d in Node %d)...\n", t, ctx[t].logical_cpu, cpu_node);

#if !defined(RANDOM) && !defined(SEQUENTIAL) && !defined(SEQUANTIAL)
        ctx[t].workload = malloc((num_ops + prefetch_ahead) * sizeof(uint64_t));
        srandom(time(NULL) ^ (t * 19937));
        for (uint64_t i = 0; i < num_ops; i++) ctx[t].workload[i] = ((uint64_t)random() | ((uint64_t)random() << 31)) % NUM_CACHELINES;
        for (uint64_t i = 0; i < prefetch_ahead; i++) ctx[t].workload[num_ops + i] = ctx[t].workload[i];
#else
        ctx[t].workload = NULL;
#endif
    }

    volatile int stop_busyworkers = 0;
    pthread_t* busy_threads = NULL;
    busyworker_ctx_t* busy_ctxs = NULL;
    int num_busy_threads = 0;

    if (enable_loaded == 1) {
        struct bitmask *cpu_node_cpus = numa_allocate_cpumask();
        numa_node_to_cpus(cpu_node, cpu_node_cpus);

        busy_threads = malloc(cpu_node_cpus->size * sizeof(pthread_t));
        busy_ctxs = malloc(cpu_node_cpus->size * sizeof(busyworker_ctx_t));

        int main_core = get_physical_core_id(core_a);

        printf("\n--- Spawning Memory Loading Workers ---\n");
        for (int i = 0; i < cpu_node_cpus->size; i++) {
            if (numa_bitmask_isbitset(cpu_node_cpus, i)) {
                int curr_core = get_physical_core_id(i);

                // Skip logical CPUs that belong to the measurement thread's physical core
                if (curr_core == main_core) {
                    continue;
                }

                busy_ctxs[num_busy_threads].logical_cpu = i;
                busy_ctxs[num_busy_threads].stop_flag = &stop_busyworkers;
                pthread_create(&busy_threads[num_busy_threads], NULL, busyworker_thread, &busy_ctxs[num_busy_threads]);
                num_busy_threads++;
            }
        }

        printf("[*] Spawned %d loader threads on NUMA node %d\n", num_busy_threads, cpu_node);
        numa_free_cpumask(cpu_node_cpus);
    }

    printf("\n--- Executing Benchmark ---\n");
    for (int t = 0; t < num_threads; t++) pthread_create(&threads[t], NULL, worker_thread, &ctx[t]);
    for (int t = 0; t < num_threads; t++) pthread_join(threads[t], NULL);

    if (enable_loaded == 1) {
        stop_busyworkers = 1;
        for (int i = 0; i < num_busy_threads; i++) pthread_join(busy_threads[i], NULL);
        free(busy_threads);
        free(busy_ctxs);
    }

    printf("\n--- Results ---\n");
    for (int t = 0; t < num_threads; t++) {
        double cpo = (double)ctx[t].duration_cycles / num_ops;
        printf("Thread %d (CPU %d):\n", t, ctx[t].logical_cpu);
        printf("  Total Cycles: %lu\n", ctx[t].duration_cycles);
        printf("  Cycles/Op:    %.2f\n", cpo);
        printf("  (Dummy: %lu)\n", ctx[t].dummy_accumulator);
        free(ctx[t].workload);
    }

    munmap(mem, MEMORY_SIZE);
    return 0;
}
