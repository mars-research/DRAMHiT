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

#define CACHELINE_SIZE 64
// 8 GB Total Memory
#define MEMORY_SIZE (8ULL * 1024 * 1024 * 1024)
#define NUM_CACHELINES (MEMORY_SIZE / CACHELINE_SIZE)

// Hugepage flags
#ifndef MAP_HUGE_1GB
#define MAP_HUGE_1GB (30 << MAP_HUGE_SHIFT)
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

// Cycle counting functions
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

// Memory Allocation with Hugepage fallbacks
cacheline_t* alloc_8gb_memory() {
    printf("Attempting to allocate 8GB using 1GB Hugepages...\n");
    void* ptr = mmap(NULL, MEMORY_SIZE, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | MAP_HUGE_1GB, -1, 0);

    if (ptr == MAP_FAILED) {
        printf("  -> [WARN] 1GB Hugepages failed (ensure OS is configured). Trying 2MB Hugepages...\n");
        ptr = mmap(NULL, MEMORY_SIZE, PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
        if (ptr == MAP_FAILED) {
            printf("  -> [WARN] 2MB Hugepages failed. Falling back to regular 4KB pages.\n");
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

    // Touch memory to ensure physical allocation
    cacheline_t* mem = (cacheline_t*)ptr;
    #pragma omp parallel for
    for (uint64_t i = 0; i < NUM_CACHELINES; i += (4096 / CACHELINE_SIZE)) {
        mem[i].data[0] = 1;
    }
    return mem;
}

// Thread payload loop
__attribute__((target("avx512f,sse4.2")))
void* worker_thread(void* arg) {
    thread_ctx_t* ctx = (thread_ctx_t*)arg;

    // Pin to specific logical CPU
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

    asm volatile("" ::: "memory");
    uint64_t start = RDTSC_START();

    // Loop separated by instruction to avoid branch prediction overhead in the critical path
    switch (ctx->inst_type) {
        case INST_LOAD:
            for (uint64_t i = 0; i < ops; i++) {
                dummy += mem[workload[i]].data[0];
            }
            break;
        case INST_AVX512_LOAD:
            for (uint64_t i = 0; i < ops; i++) {
                __m512i vec = _mm512_loadu_si512((const void*)&mem[workload[i]]);
                dummy += ((uint8_t*)&vec)[0];
            }
            break;
        case INST_PREFETCH_T0:
            for (uint64_t i = 0; i < ops; i++) {
                _mm_prefetch((const char*)&mem[workload[i]], _MM_HINT_T0);
            }
            break;
        case INST_PREFETCH_T1:
            for (uint64_t i = 0; i < ops; i++) {
                _mm_prefetch((const char*)&mem[workload[i]], _MM_HINT_T1);
            }
            break;
        case INST_PREFETCH_T2:
            for (uint64_t i = 0; i < ops; i++) {
                _mm_prefetch((const char*)&mem[workload[i]], _MM_HINT_T2);
            }
            break;
        case INST_PREFETCH_NTA:
            for (uint64_t i = 0; i < ops; i++) {
                _mm_prefetch((const char*)&mem[workload[i]], _MM_HINT_NTA);
            }
            break;
    }

    uint64_t end = RDTSCP();
    asm volatile("" ::: "memory");

    ctx->duration_cycles = end - start;
    ctx->dummy_accumulator = dummy;

    return NULL;
}

// Helper to find the hyperthread sibling of CPU 1
void get_cpu1_siblings(int* cpu_a, int* cpu_b) {
    *cpu_a = 1;
    *cpu_b = -1; // Default if no HT found

    FILE *f = fopen("/sys/devices/system/cpu/cpu1/topology/thread_siblings_list", "r");
    if (f) {
        int c1, c2;
        // Format is usually "1,33" or "1-2" depending on kernel version/topology
        if (fscanf(f, "%d,%d", &c1, &c2) == 2) {
            *cpu_b = c2;
        } else {
            rewind(f);
            if (fscanf(f, "%d-%d", &c1, &c2) == 2) {
                *cpu_b = c2;
            }
        }
        fclose(f);
    }
}

int main(int argc, char** argv) {
    if (argc != 4) {
        fprintf(stderr, "Usage: %s <Inst_Type_0-5> <Num_Ops> <Num_Threads_1-2>\n", argv[0]);
        fprintf(stderr, "Instruction Types:\n  0: Load\n  1: AVX512 Load\n  2: Prefetch T0\n");
        fprintf(stderr, "  3: Prefetch T1\n  4: Prefetch T2\n  5: Prefetch NTA\n");
        return 1;
    }

    int inst_type = atoi(argv[1]);
    uint64_t num_ops = strtoull(argv[2], NULL, 10);
    int num_threads = atoi(argv[3]);
    if (num_threads < 1 || num_threads > 2) {
        fprintf(stderr, "Error: Number of threads must be 1 or 2.\n");
        return 1;
    }

    const char* inst_names[] = {
            "Load",
            "AVX512 Load",
            "Prefetch T0",
            "Prefetch T1",
            "Prefetch T2",
            "Prefetch NTA"
        };

        // Print the indication of the execute type
        printf("Execute Type: %s\n", inst_names[inst_type]);
    int core_a, core_b;
    get_cpu1_siblings(&core_a, &core_b);

    if (num_threads == 2 && core_b == -1) {
        fprintf(stderr, "[WARN] Could not find hyperthread sibling for CPU 1 in sysfs. Using CPU 2 as fallback.\n");
        core_b = 2;
    }

    cacheline_t* mem = alloc_8gb_memory();

    pthread_t threads[2];
    thread_ctx_t ctx[2];

    printf("\n--- Setup ---\n");
    for (int t = 0; t < num_threads; t++) {
        ctx[t].thread_id = t;
        ctx[t].logical_cpu = (t == 0) ? core_a : core_b;
        ctx[t].ops = num_ops;
        ctx[t].inst_type = inst_type;
        ctx[t].mem = mem;

        printf("Initializing workload for Thread %d (Pinned to Logical CPU %d)...\n", t, ctx[t].logical_cpu);

        // Allocate and populate thread-specific random workload
        ctx[t].workload = malloc(num_ops * sizeof(uint64_t));
        srandom(time(NULL) ^ (t * 19937)); // Different seed per thread

        for (uint64_t i = 0; i < num_ops; i++) {
            // Generates a 31-bit random index across the cacheline space
            uint64_t rand_idx = ((uint64_t)random() | ((uint64_t)random() << 31)) % NUM_CACHELINES;
            ctx[t].workload[i] = rand_idx;
        }
    }

    printf("\n--- Executing Benchmark ---\n");
    for (int t = 0; t < num_threads; t++) {
        pthread_create(&threads[t], NULL, worker_thread, &ctx[t]);
    }

    for (int t = 0; t < num_threads; t++) {
        pthread_join(threads[t], NULL);
    }

    printf("\n--- Results ---\n");
    for (int t = 0; t < num_threads; t++) {
        double cpo = (double)ctx[t].duration_cycles / num_ops;
        printf("Thread %d (CPU %d):\n", t, ctx[t].logical_cpu);
        printf("  Total Cycles: %lu\n", ctx[t].duration_cycles);
        printf("  Cycles/Op:    %.2f\n", cpo);

        // Anti-optimization bypass
        if (ctx[t].dummy_accumulator == 0xDEADBEEF) {
            printf("  (Dummy: %lu)\n", ctx[t].dummy_accumulator);
        }
        free(ctx[t].workload);
    }

    munmap(mem, MEMORY_SIZE);
    return 0;
}
