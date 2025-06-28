

/**

The idea of this experiment is to verify the claim:

prefetch can affect normal load/store (non conflicting) retirement time because
it takes up lfb slot.

from my understanding:

prefetch essentially retires immediately after it has entered lfb.
In contrast to normal load that has to wait until lfb request get fullfilled
before retirement.

If we can saturate lfb with memory request (let us say 100 cycles.), that
means our load following load would take a long time because it can't enter lfb.

The problem is that would cpuid (serializing inst) ensure that all lfb request
finishes ? If it does, then our exepriemnt will always measure ld instruction
when lfb are flushed. It shouldn't, because prefetch retires after it enters
lfb.

*/
#include <xmmintrin.h>
#define _GNU_SOURCE
#include <cpuid.h>  // for __get_cpuid and cache info
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <time.h>
#include <x86intrin.h>  // for _mm_prefetch and __builtin_ia32_crc32di
#include <unistd.h>

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
      : "=r"(cycles_high), "=r"(cycles_low)::"%rax", "%rbx", "%rcx", "%rdx");

  return ((uint64_t)cycles_high << 32) | cycles_low;
}

#define HINT_L1 3
#define HINT_L2 2
#define HINT_L3 1
#define HINT_NTA 0

#define CPU_FREQ_GHZ 2.5

#define CACHELINE_SIZE 64
#define MEM_SIZE (1UL << 30)  // 1 GB
#define CACHELINE_NUM (MEM_SIZE / CACHELINE_SIZE)
#define ARR_MSK (CACHELINE_NUM - 1)

#define L1_CACHE_SZ 48 * 1024  // 48 kb
#define L1_CACHE_SZ_IN_LINE (L1_CACHE_SZ / 64)

#define L2_CACHE_SZ 2 * 1024 * 1024  // 2 mb
#define L2_CACHE_SZ_IN_LINE (L2_CACHE_SZ / 64)

// deduce from lfb experiment.
#define LFB_SIZE 16

#define NUM_PREFETCH_START 0
#define NUM_PREFETCH_END LFB_SIZE * 8
#define NUM_PREFETCH_STEP LFB_SIZE

#define NUM_LD 100

typedef struct {
  char data[CACHELINE_SIZE];
} cacheline_t;

uint64_t crc32(uint64_t val) {
  static uint64_t seed = 0xdeadbeef;
  seed = __builtin_ia32_crc32di(seed, val);
  return seed;
}

cacheline_t* alloc_mem() {
  void* ptr = mmap(NULL, MEM_SIZE, PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
  if (ptr == MAP_FAILED) {
    perror("mmap failed");
    exit(1);
  }
  return (cacheline_t*)ptr;
}

// we can figure out lfb size by issuing prefetch instruction.
// base on loop size, if we see cycle increases, then it probably means lfb is
// full.
uint64_t lfb_experiment(cacheline_t* mem, uint64_t lfb_size) {

  uint64_t start_cycles, end_cycles;

  for (uint64_t i = 0; i <= lfb_size; i++) {
    _mm_clflush(&mem[i]);
  }
  _mm_mfence();
  asm volatile("" ::: "memory");
  start_cycles = RDTSC_START();
  for (uint64_t i = 0; i < lfb_size; i++)
    _mm_prefetch((const char*)&mem[i], HINT_L1);
  end_cycles = RDTSCP();
  asm volatile("" ::: "memory");
  return (end_cycles - start_cycles)/lfb_size;
}

uint64_t load_experiment(cacheline_t* mem, uint64_t num_prefetch) {
  uint64_t read = 0, start_cycles = 0, end_cycles = 0;
  uint64_t loadidx = ARR_MSK;
  _mm_clflush(&mem[loadidx]);

  // flush requests so following prefetch will saturate lfb.
  for (uint64_t i = 0; i <= num_prefetch; i++) {
    _mm_clflush(&mem[i]);
  }

  _mm_mfence();

  // prefetch
  for (uint64_t i = 0; i < num_prefetch; i++) {
    _mm_prefetch((const char*)&mem[i], HINT_L1);
  }

  // prevent compiler reordering bs.
  asm volatile("" ::: "memory");
  start_cycles = RDTSC_START();

  // issue a single load
  asm volatile(
      "movq (%1), %%rax\n\t"
      "movq %%rax, %0\n\t"
      : "=r"(read)
      : "r"(&mem[loadidx])
      : "%rax", "memory");

  end_cycles = RDTSCP();
  asm volatile("" ::: "memory");

  return (end_cycles - start_cycles);
}

// store gets retired when it enters store buffer and 
// commited when it leaves store buffer.
// so, this should not have differences in performance.
uint64_t store_experiment(cacheline_t* mem, uint64_t num_prefetch) {
  uint64_t start_cycles = 0, end_cycles = 0;
  uint64_t stidx = ARR_MSK;
  _mm_clflush(&mem[stidx]);

  // flush requests so following prefetch will saturate lfb.
  for (uint64_t i = 0; i <= num_prefetch; i++) {
    _mm_clflush(&mem[i]);
  }

  _mm_mfence();

  // prefetch
  for (uint64_t i = 0; i < num_prefetch; i++) {
    _mm_prefetch((const char*)&mem[i], HINT_L1);
  }

  // prevent compiler reordering bs.
  asm volatile("" ::: "memory");
  start_cycles = RDTSC_START();

  // issue a single store with asm.
  mem[stidx].data[0] = 0x1;

  end_cycles = RDTSCP();
  asm volatile("" ::: "memory");

  return (end_cycles - start_cycles);
}

#define LFB_TEST
//#define LOAD_TEST
//#define STORE_TEST


int main(int argc, char** argv) {
  if (argc < 2) {
    printf("provide number of iterations for experiment to repeat\n");
    return 1;
  }

  cacheline_t* mem = alloc_mem();
  uint64_t iter = strtoull(argv[1], NULL, 10);
  uint64_t exp_cycle = 0;
  uint64_t avg_exp_cycle = 0;

#ifdef LOAD_TEST
    uint64_t num_prefetch = 0;
    exp_cycle = 0;

    for (int i = 0; i < iter; i++) {
      exp_cycle += load_experiment(mem, num_prefetch);
    }
    avg_exp_cycle = exp_cycle / iter;
    printf("%lu,%lu,%.2f\n", num_prefetch, avg_exp_cycle,
           (double)(avg_exp_cycle / CPU_FREQ_GHZ));

    num_prefetch = LFB_SIZE;
    exp_cycle = 0;
    for (int i = 0; i < iter; i++) {
      exp_cycle += load_experiment(mem, num_prefetch);
    } 
    avg_exp_cycle = exp_cycle / iter;
    printf("%lu,%lu,%.2f\n", num_prefetch, avg_exp_cycle,
           (double)(avg_exp_cycle / CPU_FREQ_GHZ));
  
#endif

#ifdef LFB_TEST
  for (uint64_t lfb_size = 8; lfb_size <= 50; lfb_size += 1) {
    exp_cycle = 0;
    for (int i = 0; i < iter; i++) {
      exp_cycle += lfb_experiment(mem, lfb_size);
      sleep_ms(10);
    }
    avg_exp_cycle = exp_cycle / iter;
    printf("%lu,%lu\n", lfb_size, avg_exp_cycle);
  }
#endif
  return 0;
}
