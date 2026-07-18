#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <time.h>
#include <unistd.h>
#include <getopt.h>
#include <sys/mman.h>
#include <x86intrin.h>
#include <immintrin.h>

// Runtime Instruction Modes
typedef enum {
    MODE_REGULAR_LOAD = 0,
    MODE_AVX512_LOAD,
    MODE_PREFETCH_L1,
    MODE_PREFETCH_L2,
    MODE_PREFETCH_L3,
    MODE_PREFETCH_NTA
} inst_mode_t;

const char* get_mode_str(inst_mode_t mode) {
    switch(mode) {
        case MODE_AVX512_LOAD: return "AVX512_LOAD";
        case MODE_PREFETCH_L1: return "PREFETCH_L1";
        case MODE_PREFETCH_L2: return "PREFETCH_L2";
        case MODE_PREFETCH_L3: return "PREFETCH_L3";
        case MODE_PREFETCH_NTA: return "PREFETCH_NTA";
        case MODE_REGULAR_LOAD:
        default: return "REGULAR_LOAD";
    }
}

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
        mem[i].data[0] = 0; // demand write to ensure physical cache line useless bit are reset.
        _mm_clflush((const void*)&mem[i]);
    }
}

uint64_t ITER = 1000;
uint64_t DUMMY = 0;

__attribute__((target("avx512f,sse4.2")))
uint64_t lfb_experiment(cacheline_t* mem, uint64_t batch_sz, uint64_t seed, uint64_t mask, inst_mode_t mode) {
    uint64_t start_cycles, end_cycles;
    uint64_t idx = 0;

    asm volatile("" ::: "memory");
    start_cycles = RDTSC_START();

    switch (mode) {
        case MODE_AVX512_LOAD:
            for (uint64_t i = 0; i < batch_sz; i++) {
                idx = HASH_CRC32(seed, i) & mask;
                __m512i vec = _mm512_loadu_si512((const void*)&mem[idx]);
                DUMMY += ((uint8_t*)&vec)[0];
            }
            break;
        case MODE_PREFETCH_L1:
            for (uint64_t i = 0; i < batch_sz; i++) {
                idx = HASH_CRC32(seed, i) & mask;
                _mm_prefetch((const char*)&mem[idx], _MM_HINT_T0);
            }
            break;
        case MODE_PREFETCH_L2:
            for (uint64_t i = 0; i < batch_sz; i++) {
                idx = HASH_CRC32(seed, i) & mask;
                _mm_prefetch((const char*)&mem[idx], _MM_HINT_T1);
            }
            break;
        case MODE_PREFETCH_L3:
            for (uint64_t i = 0; i < batch_sz; i++) {
                idx = HASH_CRC32(seed, i) & mask;
                _mm_prefetch((const char*)&mem[idx], _MM_HINT_T2);
            }
            break;
        case MODE_PREFETCH_NTA:
            for (uint64_t i = 0; i < batch_sz; i++) {
                idx = HASH_CRC32(seed, i) & mask;
                _mm_prefetch((const char*)&mem[idx], _MM_HINT_NTA);
            }
            break;
        case MODE_REGULAR_LOAD:
        default:
            for (uint64_t i = 0; i < batch_sz; i++) {
                idx = HASH_CRC32(seed, i) & mask;
                DUMMY += (uint8_t)(mem[idx].data[0]);
            }
            break;
    }

    end_cycles = RDTSCP();
    asm volatile("" ::: "memory");

    for (uint64_t i = 0; i < batch_sz; i++) {
        idx = HASH_CRC32(seed, i) & mask;
        DUMMY += (uint8_t)(mem[idx].data[0]);
    }

    return (end_cycles - start_cycles);
}

void print_help(const char* prog_name) {
    printf("Usage: %s [OPTIONS]\n\n", prog_name);
    printf("Options:\n");
    printf("  -h          Print this help message\n");
    printf("  -m MODE     Select instruction mode (default: 0)\n");
    printf("                 0: REGULAR_LOAD\n");
    printf("                 1: AVX512_LOAD\n");
    printf("                 2: PREFETCH_L1\n");
    printf("                 3: PREFETCH_L2\n");
    printf("                 4: PREFETCH_L3\n");
    printf("                 5: PREFETCH_NTA\n");
    printf("  -b MIN-MAX  Set batch size range (e.g., 5-40, default: 5-40)\n");
    printf("  -i ITER     Number of iterations (default: 1000)\n");
    printf("  -o FILE     Output CSV file path (default: data.csv)\n");
}

int main(int argc, char** argv) {
    srandom(time(NULL));
    uint32_t min_batch = 5;
    uint32_t max_batch = 40;
    char* file_path = "data.csv";
    inst_mode_t mode = MODE_REGULAR_LOAD;
    int opt;

    while ((opt = getopt(argc, argv, "hm:b:i:o:")) != -1) {
        switch (opt) {
            case 'h':
                print_help(argv[0]);
                return 0;
            case 'm':
                mode = (inst_mode_t)atoi(optarg);
                if (mode < 0 || mode > 5) {
                    fprintf(stderr, "Error: Invalid mode selected.\n");
                    return 1;
                }
                break;
            case 'b':
                if (sscanf(optarg, "%u-%u", &min_batch, &max_batch) == 1) {
                    max_batch = min_batch;
                }
                break;
            case 'i':
                ITER = strtoull(optarg, NULL, 10);
                break;
            case 'o':
                file_path = optarg;
                break;
            default:
                print_help(argv[0]);
                return 1;
        }
    }

    if (min_batch < 1) min_batch = 1;
    if (max_batch < min_batch) max_batch = min_batch;
    if (ITER == 0) ITER = 1;

    uint64_t mem_len = 16896; // size of l1 + l2 cache.
    uint64_t mask = mem_len - 1;

    cacheline_t* mem = alloc_mem(mem_len * CACHELINE_SIZE);
    for (uint64_t i = 0; i < mem_len; i++) {
        mem[i].data[0] = 'p';
    }

    stats_t* batch_stats = calloc(max_batch + 1, sizeof(stats_t));
    uint64_t* sample_buffer = malloc(sizeof(uint64_t) * ITER);

    printf("Executing benchmark using mode: [%s]\n", get_mode_str(mode));
    printf("Evaluating batch spectrum from size %u to %u across %lu iterations...\n\n", min_batch, max_batch, ITER);

    for (uint32_t batch_sz = min_batch; batch_sz <= max_batch; batch_sz++) {
        uint64_t sum_cycles = 0;

        for (uint64_t i = 0; i < ITER; i++) {
            uint64_t seed = (uint64_t)random();
            evict_cache(mem, mem_len);
            sleep_ms(2);

            uint64_t duration = lfb_experiment(mem, batch_sz, seed, mask, mode);
            sample_buffer[i] = duration;
            sum_cycles += duration;
        }

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

    FILE* csv_file = fopen(file_path, "w");
    if (!csv_file) {
        perror("Failed to create CSV output file");
        return 1;
    }

    const char* header = "mode,batch_size,min,max,avg,median";
    fprintf(csv_file, "%s\n", header);
    printf("--- CSV Results Output ---\n");
    printf("%s\n", header);

    for (uint32_t b = min_batch; b <= max_batch; b++) {
        fprintf(csv_file, "%s,%u,%lu,%lu,%lu,%lu\n",
                get_mode_str(mode), b,
                batch_stats[b].min, batch_stats[b].max, batch_stats[b].avg, batch_stats[b].median);

        printf("%s,%u,%lu,%lu,%lu,%lu\n",
                get_mode_str(mode), b,
                batch_stats[b].min, batch_stats[b].max, batch_stats[b].avg, batch_stats[b].median);
    }

    fclose(csv_file);
    free(sample_buffer);
    free(batch_stats);
    free_mem(mem, mem_len * CACHELINE_SIZE);

    if (DUMMY == 0xFFFFFFFFFFFFFFFFULL) printf("%lu\n", DUMMY);

    return 0;
}
