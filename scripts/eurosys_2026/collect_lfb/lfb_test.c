#include <xmmintrin.h>
#define _GNU_SOURCE
#include <cpuid.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <time.h>
#include <unistd.h>
#include <x86intrin.h>

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

/**
 * CITE:
 * http://www.intel.com/content/www/us/en/embedded/training/ia-32-ia-64-benchmark-code-execution-paper.html
 */
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

#define HINT_L1 3
#define HINT_L2 2
#define HINT_L3 1
#define HINT_NTA 0

#define CPU_FREQ_GHZ 2.5

#define CACHELINE_SIZE 64
#define MEM_SIZE CACHELINE_SIZE * 1024
#define CACHELINE_NUM (MEM_SIZE / CACHELINE_SIZE)
#define ARR_MSK (CACHELINE_NUM - 1)

// deduce from lfb experiment.
#define LFB_SIZE 16
#define L1_CACHE_SZ 48 * 1024  // 48 kb
#define L1_CACHE_SZ_IN_LINE (L1_CACHE_SZ / 64)
#define L2_CACHE_SZ 2 * 1024 * 1024  // 2 mb
#define L2_CACHE_SZ_IN_LINE (L2_CACHE_SZ / 64)

typedef struct {
  char data[CACHELINE_SIZE];
} cacheline_t;

#define crc32(val) __builtin_ia32_crc32di(0xdeadbeef, val)

// Define 2MB in bytes
#define HUGE_PAGE_SIZE (2ULL * 1024 * 1024)

// Macro to round up to the nearest huge page boundary
#define ALIGN_TO_HUGE_PAGE(x) (((x) + HUGE_PAGE_SIZE - 1) & ~(HUGE_PAGE_SIZE - 1))

cacheline_t* alloc_mem(size_t len) {
    // 1. Align the requested length to a 2MB boundary
    size_t aligned_len = ALIGN_TO_HUGE_PAGE(len);

    // 2. Map the memory using the aligned length
    void* ptr = mmap(NULL, aligned_len, PROT_READ | PROT_WRITE,
                     MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);

    if (ptr == MAP_FAILED) {
        perror("mmap failed");
        exit(1);
    }

    printf("mmap size %lu\n", aligned_len);

    return (cacheline_t*)ptr;
}

void free_mem(cacheline_t* ptr, size_t len) {
    // 1. Align the length using the exact same logic
    size_t aligned_len = ALIGN_TO_HUGE_PAGE(len);

    // 2. Unmap using the aligned length
    if (munmap((void*)ptr, aligned_len) == -1) {
        perror("Error unmapping memory");
    }
}

static inline uint32_t hash_knuth(uint32_t x) { return x * 2654435761u; }


uint64_t ITER = 100000;
uint64_t MAX_BATCH_SZ = 50;
uint64_t DUMMY = 0;

uint64_t get_overhead(uint64_t batch_sz, uint32_t* workload) {
  uint64_t duration = 0;
  uint64_t start_cycles, end_cycles;

  for (int j = 0; j < ITER; j++) {
    start_cycles = RDTSC_START();
    uint32_t idx = 0;
    for (uint64_t i = 0; i < batch_sz; i++) {
      idx = workload[i];
      DUMMY += idx; // Make sure load actually happens
    }
    end_cycles = RDTSCP();
    duration += end_cycles - start_cycles;
  }

  duration = duration / ITER;
  return duration;
}

uint64_t lfb_experiment(cacheline_t* mem, uint64_t batch_sz, uint32_t* workload) {
  uint64_t start_cycles, end_cycles;

  asm volatile("" ::: "memory");
  start_cycles = RDTSC_START();
  uint32_t idx = 0;
  for (uint64_t i = 0; i < batch_sz; i++) {
    idx = workload[i];
    _mm_prefetch((const char*)&mem[idx], HINT_L2);
    // DUMMY += (uint8_t) (mem[idx].data[0]);
  }
  end_cycles = RDTSCP();
  asm volatile("" ::: "memory");

  uint64_t duration = end_cycles - start_cycles;
  return duration;
}

void evict_cache(cacheline_t* mem, uint64_t len)
{
    for (int i = 0; i < len; i++) {
      _mm_clflush((const void*)&mem[i]);
    }
}

int main(int argc, char** argv) {
  uint64_t mem_len = 4096;  // 4k
  uint64_t exp_cycle = 0;
  cacheline_t* mem = alloc_mem(mem_len * CACHELINE_SIZE);
  for(int i=0; i<mem_len;i++)
      mem[i].data[0] = 'p';

  uint32_t* workload = malloc(sizeof(uint32_t) * MAX_BATCH_SZ);
  for (int i = 0; i < MAX_BATCH_SZ; i++) {
    workload[i] = hash_knuth(i) % mem_len;
  }
  uint64_t overhead = 0;
  for (uint32_t batch_sz = 5; batch_sz <= MAX_BATCH_SZ; batch_sz++) {
    exp_cycle = 0;
    overhead = get_overhead(batch_sz, workload); //overhead of accessing workload
    for (int i = 0; i < ITER; i++) {
      evict_cache(mem, mem_len); // make sure the loads are not hitting caches.
      // sleep_ms(1);
      exp_cycle += lfb_experiment(mem, batch_sz, workload);
    }
    exp_cycle = exp_cycle / ITER;

    if(exp_cycle < overhead) exp_cycle = overhead;
    printf("batch_sz: %u, duration: %lu, overhead: %lu, cycle_per_op: %lu\n", batch_sz, exp_cycle, overhead, (exp_cycle - overhead)/batch_sz);
  }

  free_mem(mem, mem_len * CACHELINE_SIZE);
  return 0;
}
