#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <time.h>
#include <unistd.h>
#include <sys/mman.h>
#include <x86intrin.h>
#include <immintrin.h>

// Macro toggle defaults if none are passed via -D
#if defined(USE_AVX512_LOAD)
    #define MODE_STR "AVX512_LOAD"
#elif defined(USE_PREFETCH_L1)
    #define MODE_STR "PREFETCH_L1"
#elif defined(USE_PREFETCH_L2)
    #define MODE_STR "PREFETCH_L2"
#elif defined(USE_PREFETCH_L3)
    #define MODE_STR "PREFETCH_L3"
#elif defined(USE_PREFETCH_NTA)
    #define MODE_STR "PREFETCH_NTA"
#else
    #define MODE_STR "REGULAR_LOAD"
#endif

// Hardware CRC32 Hash Macro for random access indexing
#define HASH_CRC32(seed, val) __builtin_ia32_crc32di(seed, val)

#define CACHELINE_SIZE 64
#define HUGE_PAGE_SIZE (2ULL * 1024 * 1024)
#define ALIGN_TO_HUGE_PAGE(x) (((x) + HUGE_PAGE_SIZE - 1) & ~(HUGE_PAGE_SIZE - 1))

typedef struct __attribute__((aligned(64))) {
    char data[CACHELINE_SIZE];
} cacheline_t;

// Structure to hold comprehensive batch statistics
typedef struct {
    uint64_t min;
    uint64_t max;
    uint64_t avg;
    uint64_t median;
} stats_t;

// Sorting helper for computing the median
int cmp_uint64(const void* a, const void* b) {
    uint64_t arg1 = *(const uint64_t*)a;
    uint64_t arg2 = *(const uint64_t*)b;
    if (arg1 < arg2) return -1;
    if (arg1 > arg2) return 1;
    return 0;
}

void sleep_ms(int milliseconds) {
    struct timespec ts;
    ts.tv_sec = milliseconds / 1000;
    ts.tv_nsec = (milliseconds % 1000) * 1000000;
    nanosleep(&ts, NULL);
}

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

cacheline_t* alloc_mem(size_t len) {
    size_t aligned_len = ALIGN_TO_HUGE_PAGE(len);
    void* ptr = mmap(NULL, aligned_len, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
    if (ptr == MAP_FAILED) {
        perror("mmap with huge pages failed, attempting fallback to regular pages");
        ptr = mmap(NULL, aligned_len, PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
        if (ptr == MAP_FAILED) {
            perror("Fallback mmap failed entirely");
            exit(1);
        }
    }
    return (cacheline_t*)ptr;
}

void free_mem(cacheline_t* ptr, size_t len) {
    size_t aligned_len = ALIGN_TO_HUGE_PAGE(len);
    munmap((void*)ptr, aligned_len);
}

void evict_cache(cacheline_t* mem, uint64_t len) {
    for (uint64_t i = 0; i < len; i++) {
        _mm_clflush((const void*)&mem[i]);
    }
}

uint64_t ITER = 1000; // Default iterations, overridden by CLI
uint64_t DUMMY = 0;

// Target attributes ensure explicit compilation matching for hardware features
__attribute__((target("avx512f,sse4.2")))
uint64_t lfb_experiment(cacheline_t* mem, uint64_t batch_sz, uint32_t* workload) {
    uint64_t start_cycles, end_cycles;
    uint32_t idx = 0;

    asm volatile("" ::: "memory");
    start_cycles = RDTSC_START();

    for (uint64_t i = 0; i < batch_sz; i++) {
        idx = workload[i];
        #if defined(USE_AVX512_LOAD)
            __m512i vec = _mm512_loadu_si512((const void*)&mem[idx]);
            DUMMY += ((uint8_t*)&vec)[0];
        #elif defined(USE_PREFETCH_L1)
            _mm_prefetch((const char*)&mem[idx], _MM_HINT_T0);
        #elif defined(USE_PREFETCH_L2)
            _mm_prefetch((const char*)&mem[idx], _MM_HINT_T1);
        #elif defined(USE_PREFETCH_L3)
            _mm_prefetch((const char*)&mem[idx], _MM_HINT_T2);
        #elif defined(USE_PREFETCH_NTA)
            _mm_prefetch((const char*)&mem[idx], _MM_HINT_NTA);
        #else
            DUMMY += (uint8_t)(mem[idx].data[0]);
        #endif
    }

    end_cycles = RDTSCP();
    asm volatile("" ::: "memory");

    return (end_cycles - start_cycles);
}

int main(int argc, char** argv) {
    srandom(time(NULL));
    uint32_t min_batch = 5;
    uint32_t max_batch = 40;
    char* file_path = "data.csv";

    // Command-line parsing: supports <min> <max> <iter> <file> OR <min-max> <iter> <file>
    if (argc >= 2) {
        if (strchr(argv[1], '-')) {
            if (sscanf(argv[1], "%u-%u", &min_batch, &max_batch) != 2) {
                fprintf(stderr, "Invalid format string. Use Min-Max (e.g. 10-20)\n");
                return 1;
            }
            if (argc >= 3) ITER = strtoull(argv[2], NULL, 10);
            if (argc >= 4) file_path = argv[3];
        } else {
            min_batch = atoi(argv[1]);
            if (argc >= 3) max_batch = atoi(argv[2]);
            if (argc >= 4) ITER = strtoull(argv[3], NULL, 10);
            if (argc >= 5) file_path = argv[4];
        }
    }

    if (min_batch < 1) min_batch = 1;
    if (max_batch < min_batch) max_batch = min_batch;
    if (ITER == 0) ITER = 1; // Prevent division by zero

    uint64_t mem_len = 131072; // Map to larger baseline (8MB+) to guarantee L2/L3 misses
    cacheline_t* mem = alloc_mem(mem_len * CACHELINE_SIZE);
    for (uint64_t i = 0; i < mem_len; i++) {
        mem[i].data[0] = 'p';
    }

    uint32_t* workload = malloc(sizeof(uint32_t) * (max_batch + 1));
    stats_t* batch_stats = calloc(max_batch + 1, sizeof(stats_t));
    uint64_t* sample_buffer = malloc(sizeof(uint64_t) * ITER);

    printf("Executing benchmark using mode: [%s]\n", MODE_STR);
    printf("Evaluating batch spectrum from size %u to %u across %lu iterations...\n\n", min_batch, max_batch, ITER);

    // To compute the marginal value of the lower limit, we record min_batch - 1
    uint32_t start_loop_sz = (min_batch > 1) ? (min_batch - 1) : 1;

    for (uint32_t batch_sz = start_loop_sz; batch_sz <= max_batch; batch_sz++) {
        uint64_t sum_cycles = 0;

        for (uint64_t i = 0; i < ITER; i++) {
            uint64_t seed = random();
            evict_cache(mem, mem_len);
            for (uint32_t j = 0; j < batch_sz; j++) {
                // Populate random workload utilizing hardware CRC32 instruction
                workload[j] = HASH_CRC32(seed, j) % mem_len;
            }
            sleep_ms(2);

            uint64_t duration = lfb_experiment(mem, batch_sz, workload);
            sample_buffer[i] = duration;
            sum_cycles += duration;
        }

        // Sort collected sample buffer to easily find min, max, and median
        qsort(sample_buffer, ITER, sizeof(uint64_t), cmp_uint64);

        batch_stats[batch_sz].min = sample_buffer[0];
        batch_stats[batch_sz].max = sample_buffer[ITER - 1];
        batch_stats[batch_sz].avg = sum_cycles / ITER;

        if (ITER % 2 == 0) {
            batch_stats[batch_sz].median = (sample_buffer[ITER / 2 - 1] + sample_buffer[ITER / 2]) / 2;
        } else {
            batch_stats[batch_sz].median = sample_buffer[ITER / 2];
        }
    }

    // Prepare and open CSV output file
    FILE* csv_file = fopen(file_path, "w");
    if (!csv_file) {
        perror("Failed to create CSV output file");
        return 1;
    }

    // Write file and stdout headers
    const char* header = "mode,batch_size,min,max,avg,median,marg_min,marg_max,marg_avg,marg_median";
    fprintf(csv_file, "%s\n", header);
    printf("--- CSV Results Output ---\n");
    printf("%s\n", header);

    for (uint32_t b = min_batch; b <= max_batch; b++) {
        // Marginal calculations (current state minus previous state)
        int64_t m_min = 0, m_max = 0, m_avg = 0, m_med = 0;

        if (b > 1) {
            m_min = (int64_t)batch_stats[b].min - (int64_t)batch_stats[b - 1].min;
            m_max = (int64_t)batch_stats[b].max - (int64_t)batch_stats[b - 1].max;
            m_avg = (int64_t)batch_stats[b].avg - (int64_t)batch_stats[b - 1].avg;
            m_med = (int64_t)batch_stats[b].median - (int64_t)batch_stats[b - 1].median;
        } else {
            m_min = batch_stats[b].min;
            m_max = batch_stats[b].max;
            m_avg = batch_stats[b].avg;
            m_med = batch_stats[b].median;
        }

        // Guard against slight background variances making the marginal delta negative
        if (m_min < 0) m_min = 0;
        if (m_max < 0) m_max = 0;
        if (m_avg < 0) m_avg = 0;
        if (m_med < 0) m_med = 0;

        // Stream results simultaneously to stdout and file
        fprintf(csv_file, "%s,%u,%lu,%lu,%lu,%lu,%ld,%ld,%ld,%ld\n",
                MODE_STR, b,
                batch_stats[b].min, batch_stats[b].max, batch_stats[b].avg, batch_stats[b].median,
                m_min, m_max, m_avg, m_med);

        printf("%s,%u,%lu,%lu,%lu,%lu,%ld,%ld,%ld,%ld\n",
                MODE_STR, b,
                batch_stats[b].min, batch_stats[b].max, batch_stats[b].avg, batch_stats[b].median,
                m_min, m_max, m_avg, m_med);
    }

    fclose(csv_file);
    free(workload);
    free(sample_buffer);
    free(batch_stats);
    free_mem(mem, mem_len * CACHELINE_SIZE);

    // Keep dummy logic valid to clear compiler optimizers
    if (DUMMY == 0xFFFFFFFFFFFFFFFFULL) printf("%lu\n", DUMMY);

    return 0;
}
