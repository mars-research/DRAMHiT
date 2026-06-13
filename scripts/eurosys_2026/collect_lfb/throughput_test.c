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
// 1 GB Memory per Thread
#define MEMORY_SIZE_1GB (1ULL * 1024 * 1024 * 1024)
#define NUM_CACHELINES_1GB (MEMORY_SIZE_1GB / CACHELINE_SIZE)

// 1GB / 64B = 16,777,216 cachelines (which is 2^24).
// Mask is 0xFFFFFF to ensure random indices stay strictly within bounds.
#define CACHELINE_MASK (NUM_CACHELINES_1GB - 1)

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
    uint64_t ops;
    instruction_type_t inst_type;
    cacheline_t* mem;
    uint64_t duration_cycles;
    uint64_t dummy_accumulator;
} thread_ctx_t;

// Global coordination barrier
pthread_barrier_t init_barrier;

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

// Thread-local Memory Allocation
cacheline_t* alloc_1gb_memory() {
    void* ptr = mmap(NULL, MEMORY_SIZE_1GB, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | MAP_HUGE_1GB, -1, 0);

    // Fallback to 2MB, then standard 4KB pages silently
    if (ptr == MAP_FAILED) {
        ptr = mmap(NULL, MEMORY_SIZE_1GB, PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
        if (ptr == MAP_FAILED) {
            ptr = mmap(NULL, MEMORY_SIZE_1GB, PROT_READ | PROT_WRITE,
                       MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
            if (ptr == MAP_FAILED) {
                perror("Fatal: Memory allocation failed entirely");
                exit(1);
            }
        }
    }

    // Touch memory to ensure physical page allocation
    cacheline_t* mem = (cacheline_t*)ptr;
    for (uint64_t i = 0; i < NUM_CACHELINES_1GB; i += (4096 / CACHELINE_SIZE)) {
        mem[i].data[0] = 1;
    }
    return mem;
}

// Thread payload loop
__attribute__((target("avx512f,sse4.2")))
void* worker_thread(void* arg) {
    thread_ctx_t* ctx = (thread_ctx_t*)arg;

    // Phase 1: Initialize local 1GB memory
    ctx->mem = alloc_1gb_memory();

    // Phase 2: Synchronization
    // Wait for all worker threads (and the main thread) to finish initialization
    pthread_barrier_wait(&init_barrier);

    uint64_t ops = ctx->ops;
    cacheline_t* mem = ctx->mem;
    uint64_t dummy = 0;

    // Constant base seed for this thread
    const uint64_t seed = (uint64_t)time(NULL) ^ (ctx->thread_id * 0xDEADBEEF);

    asm volatile("" ::: "memory");
    uint64_t start = RDTSC_START();

    // Loop separated by instruction. Random generation is inline without evolving the seed.
    switch (ctx->inst_type) {
        case INST_LOAD:
            for (uint64_t i = 0; i < ops; i++) {
                uint64_t idx = _mm_crc32_u64(seed, i);
                dummy += mem[idx & CACHELINE_MASK].data[0];
            }
            break;
        case INST_AVX512_LOAD:
            for (uint64_t i = 0; i < ops; i++) {
                uint64_t idx = _mm_crc32_u64(seed, i);
                __m512i vec = _mm512_loadu_si512((const void*)&mem[idx & CACHELINE_MASK]);
                dummy += ((uint8_t*)&vec)[0];
            }
            break;
        case INST_PREFETCH_T0:
            for (uint64_t i = 0; i < ops; i++) {
                uint64_t idx = _mm_crc32_u64(seed, i);
                _mm_prefetch((const char*)&mem[idx & CACHELINE_MASK], _MM_HINT_T0);
            }
            break;
        case INST_PREFETCH_T1:
            for (uint64_t i = 0; i < ops; i++) {
                uint64_t idx = _mm_crc32_u64(seed, i);
                _mm_prefetch((const char*)&mem[idx & CACHELINE_MASK], _MM_HINT_T1);
            }
            break;
        case INST_PREFETCH_T2:
            for (uint64_t i = 0; i < ops; i++) {
                uint64_t idx = _mm_crc32_u64(seed, i);
                _mm_prefetch((const char*)&mem[idx & CACHELINE_MASK], _MM_HINT_T2);
            }
            break;
        case INST_PREFETCH_NTA:
            for (uint64_t i = 0; i < ops; i++) {
                uint64_t idx = _mm_crc32_u64(seed, i);
                _mm_prefetch((const char*)&mem[idx & CACHELINE_MASK], _MM_HINT_NTA);
            }
            break;
    }

    uint64_t end = RDTSCP();
    asm volatile("" ::: "memory");

    ctx->duration_cycles = end - start;
    ctx->dummy_accumulator = dummy;

    return NULL;
}

int main(int argc, char** argv) {
    if (argc != 4) {
        fprintf(stderr, "Usage: %s <Inst_Type_0-5> <Num_Ops> <Num_Threads>\n", argv[0]);
        fprintf(stderr, "Instruction Types:\n  0: Load\n  1: AVX512 Load\n  2: Prefetch T0\n");
        fprintf(stderr, "  3: Prefetch T1\n  4: Prefetch T2\n  5: Prefetch NTA\n");
        return 1;
    }

    int inst_type = atoi(argv[1]);
    uint64_t num_ops = strtoull(argv[2], NULL, 10);
    int num_threads = atoi(argv[3]);

    if (num_threads < 1) {
        fprintf(stderr, "Error: Number of threads must be at least 1.\n");
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

    // Print experiment details
    printf("Experiment Info: Instruction Type = %s, Threads = %d, Ops/Thread = %lu\n",
           inst_names[inst_type], num_threads, num_ops);

    // Init barrier for (num_threads + 1) so the main thread can coordinate the print statements
    pthread_barrier_init(&init_barrier, NULL, num_threads + 1);

    pthread_t* threads = malloc(num_threads * sizeof(pthread_t));
    thread_ctx_t* ctx = malloc(num_threads * sizeof(thread_ctx_t));

    // Spawn workers
    for (int t = 0; t < num_threads; t++) {
        ctx[t].thread_id = t;
        ctx[t].ops = num_ops;
        ctx[t].inst_type = inst_type;
        pthread_create(&threads[t], NULL, worker_thread, &ctx[t]);
    }

    // Wait for all worker threads to allocate and set up memory
    pthread_barrier_wait(&init_barrier);

    // All threads are synchronized and about to drop into their benchmark loops
    printf("Benchmark execution starts.\n");

    // Wait for all workers to finish their workload
    for (int t = 0; t < num_threads; t++) {
        pthread_join(threads[t], NULL);
    }

    // Program must end with this string
    printf("Benchmark execution ends.\n");

    // Cleanup
    for (int t = 0; t < num_threads; t++) {
        munmap(ctx[t].mem, MEMORY_SIZE_1GB);
    }

    free(threads);
    free(ctx);
    pthread_barrier_destroy(&init_barrier);

    return 0;
}
