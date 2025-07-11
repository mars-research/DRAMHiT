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


cacheline_t* alloc_mem(size_t len) {
  void* ptr = mmap(NULL, len, PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
  if (ptr == MAP_FAILED) {
    perror("mmap failed");
    exit(1);
  }
  return (cacheline_t*)ptr;
}



#define ITER 100

cacheline_t* mem; 

uint64_t experiment() {
  uint64_t start_cycles = 0, end_cycles = 0;

  for (uint64_t i = 0; i < ARRAY_LEN; i++) {
    _mm_clflush(&mem[i]);
  }

  sleep_ms(1);

  // prevent compiler reordering bs.
  asm volatile("" ::: "memory");
  start_cycles = RDTSC_START();

#include "generated_prefetches.h"

  end_cycles = RDTSCP();
  asm volatile("" ::: "memory");

  return (end_cycles - start_cycles) / ARRAY_LEN;
}


int main() {

  mem = alloc_mem(ARRAY_LEN * CACHELINE_SIZE);

  uint64_t exp_cycle = 0;
  uint64_t avg_exp_cycle = 0;

  exp_cycle = 0;
  for (int i = 0; i < ITER; i++) {
    exp_cycle += experiment();
    sleep_ms(10);
  }
  avg_exp_cycle = exp_cycle / ITER;
  printf("%u,%lu,%.2f\n", ARRAY_LEN, avg_exp_cycle,
         (double)(avg_exp_cycle / CPU_FREQ_GHZ));

  return 0;
}