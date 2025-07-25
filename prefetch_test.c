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

cacheline_t* alloc_mem(size_t len) {
  void* ptr = mmap(NULL, len, PROT_READ | PROT_WRITE,
                   MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB, -1, 0);
  if (ptr == MAP_FAILED) {
    perror("mmap failed");
    exit(1);
  }
  return (cacheline_t*)ptr;
}

#define PREFETCHW(addr) __builtin_prefetch((const void*)(addr), 1, 0)

#if defined(PREFETCH_L1)
#define PREFETCH1(addr) _mm_prefetch((const char*)(addr), HINT_L1)
#elif defined(PREFETCH_L2)
#define PREFETCH1(addr) _mm_prefetch((const char*)(addr), HINT_L2)
#elif defined(PREFETCH_W)
#define PREFETCH1(addr) __builtin_prefetch((const void*)(addr), 1, 0)
#else
#define PREFETCH1(addr) _mm_prefetch((const char*)(addr), HINT_L1)
#endif

#define PREFETCH2(addr) \
  PREFETCH1(addr);      \
  PREFETCH1(addr)
#define PREFETCH4(addr) \
  PREFETCH2(addr);      \
  PREFETCH2(addr)
#define PREFETCH8(addr) \
  PREFETCH4(addr);      \
  PREFETCH4(addr)
#define PREFETCH16(addr) \
  PREFETCH8(addr);       \
  PREFETCH8(addr)

// we can figure out lfb size by issuing prefetch instruction continuously.
// Plot num requests vs cycles per op, you should observe a sudden cycle jump
// due to lfb  saturation.
uint64_t lfb_experiment(cacheline_t* mem, uint64_t lfb_size) {
  uint64_t start_cycles, end_cycles;

  for (uint64_t i = 0; i <= lfb_size; i++) {
    _mm_clflush(&mem[i]);
  }
  _mm_mfence();
  asm volatile("" ::: "memory");
  start_cycles = RDTSC_START();
  for (uint64_t i = 0; i < lfb_size; i++) {
    _mm_prefetch((const char*)&mem[i], HINT_L1);
  }
  end_cycles = RDTSCP();
  asm volatile("" ::: "memory");
  return (end_cycles - start_cycles) / lfb_size;
}

/*
conflicting prefetch + load

  prefetch takes port resources. prefetch is translated into ld micro-ops, which
  takes up load port. The amount of performance lost should be directly related
to number of conflicting prefetch issued per loop iteration.

  You can observe this by ploting cycle per op vs number of conflicting prefetch
issued per iteration. Since prefetch and load are issuing into same memory
address, lfb should squash the same request into one. Thus load only really just
needs to wait for its requests to finish. Thus only the resources port is
affected.

nonconflicting prefetch + load

  non-conflicting prefetch takes up lfb buffer slot, thus now there is
  a extra request in lfb per iteration. This causes more performance degradation
b ecause lfb will be more satruated. You should observe almost double of the
performance as load will need to wait for non-related prefetches to complete in
order to enter lfb. Compare cycles difference between load vs nonconflicting
prefetch + load.

conflicing prefetch + store

  regular(cacheable) store will issue two requests one to RFO, and another to
write into DRAM.

  since store is retired upon entering store buffer. conflicting prefetch will
actually help store by requesting exclusive ownership cacheline ahead of time,
thus speed up the following store. When store request enters store buffer, it
consults lfb which sees a exclusive ownership of the cacheline. Thus resulting
the store request getting commited immediately (leave store buffer). Compare
cycles difference between store vs conflicting prefetch + store.

non-conflicting prefetch + store

  similar to nonconflicting prefetch + load cases, non-conflicting prefetch will
hurt performance of store by taking up more slots in lfb. This eventually clogs
up the store buffer, thus preventing store even enter store buffer. Compare
cycles difference between store vs nonconflicting prefetch + store.

why is regular store so slow ? 21 cycles per op.

in a regular store loop, a load request generated by a store to mem addr X
will not be issued until a store enters the store buffer.

But once store buffer is saturated, a load request for this store can't be
issued until it enters store buffer. It must wait until one entry in the store
buffer to retire, which in turns waits for the LFB request to complete.

However, with prefetch, even when store buffer is saturated, the load request
for a store can still be issued as long as lfb slot is freed. The load request
is issued parallelly at this point. Note that store will still stall, waiting to
enter. But when it enters, it is likely that the cacheline is already ready to
go, thus leaving store buffer immediately. This is not true in the case of
continuous stores.
*/
uint64_t experiment(cacheline_t* mem, uint64_t mem_len, uint64_t op) {
  uint64_t start_cycles = 0, end_cycles = 0;

  memset(mem, 0, mem_len * CACHELINE_SIZE);
  // flush all
  for (uint64_t i = 0; i < mem_len; i++) {
#if defined(WORKLOAD_IN_L1)
    _mm_prefetch((const void*)&mem[i], HINT_L1);
#elif defined(WORKLOAD_IN_L2)
    _mm_prefetch((const void*)&mem[i], HINT_L2);
#else
    _mm_clflush(&mem[i]);
#endif
  }

  _mm_mfence();

  sleep_ms(1);

  uint64_t idx = 0;
  uint64_t msk = (mem_len - 1);

  // prevent compiler reordering bs.
  asm volatile("" ::: "memory");
  start_cycles = RDTSC_START();

  for (uint64_t i = 0; i < op; i++) {
#ifdef RANDOM_ACCESS
    asm volatile(
        "xor %%eax, %%eax\n\t"
        "crc32q %[input], %%rax\n\t"
        "and %[mask], %%rax\n\t"
        : "=&a"(idx)                       // output: 'idx' in RAX
        : [input] "r"(i), [mask] "r"(msk)  // inputs
        : "cc"                             // clobbers condition codes
    );
#else
    idx = i;
#endif

#if defined(CONFLICT_PREFETCH)
    PREFETCH1(&mem[idx]);
#elif defined(NONCONFLICT_PREFETCH)
    PREFETCH1(&mem[op + idx]);
#endif

#ifdef LOAD_TEST
    // issue a single load
    asm volatile("movq (%0), %%rbx\n\t" : : "r"(&mem[idx]) : "%rbx", "memory");
#endif

#ifdef STORE_TEST
    mem[i].data[0] = 0xff;
    // PREFETCHW(&mem[i]);
    //__sync_bool_compare_and_swap((uint64_t*)&mem[i], 0, 0xff);
#endif
  } 

  end_cycles = RDTSCP();
  asm volatile("" ::: "memory");

  return (end_cycles - start_cycles) / op;
}

uint64_t multi_experiment(cacheline_t* mem, cacheline_t* l2, cacheline_t* l1,
                          uint64_t op) {
  uint64_t start_cycles = 0, end_cycles = 0;

  memset(mem, 0, L1_CACHE_SZ_IN_LINE * CACHELINE_SIZE);
  memset(l2, 0, L1_CACHE_SZ_IN_LINE * CACHELINE_SIZE);
  memset(l1, 0, L1_CACHE_SZ_IN_LINE * CACHELINE_SIZE);

  // prepare
  for (uint64_t i = 0; i < L1_CACHE_SZ_IN_LINE; i++) {
    _mm_clflush(&mem[i]);
  }

  for (uint64_t i = 0; i < L1_CACHE_SZ_IN_LINE; i++) {
    _mm_prefetch((const void*)&l2[i], HINT_L2);
  }

  for (uint64_t i = 0; i < L1_CACHE_SZ_IN_LINE; i++) {
    _mm_prefetch((const void*)&l1[i], HINT_L1);
  }

  _mm_mfence();

  sleep_ms(1);

  uint64_t idx = 0;
  uint64_t msk = (L1_CACHE_SZ_IN_LINE - 1);

  // prevent compiler reordering bs.
  asm volatile("" ::: "memory");
  start_cycles = RDTSC_START();

  for (uint64_t i = 0; i < op; i++) {
#ifdef RANDOM_ACCESS
    asm volatile(
        "xor %%eax, %%eax\n\t"
        "crc32q %[input], %%rax\n\t"
        "and %[mask], %%rax\n\t"
        : "=&a"(idx)                       // output: 'idx' in RAX
        : [input] "r"(i), [mask] "r"(msk)  // inputs
        : "cc"                             // clobbers condition codes
    );
#else
    idx = i;
#endif

    _mm_prefetch((const void*)&mem[idx], HINT_L1);
    //_mm_prefetch((const void*)&l2[idx], HINT_L1);

#ifdef LOAD_TEST
    // issue a single load
    asm volatile("movq (%0), %%rbx\n\t" : : "r"(&l1[idx]) : "%rbx", "memory");
#endif

#ifdef STORE_TEST
    l1[i].data[0] = 0xff;
#endif
  }

  end_cycles = RDTSCP();
  asm volatile("" ::: "memory");

  return (end_cycles - start_cycles) / op;
}

// #define LFB_TEST
int main(int argc, char** argv) {
  if (argc < 3) {
    printf("provide number of iterations and cacheline number\n");
    return 1;
  }

  uint64_t iter = strtoull(argv[1], NULL, 10);
  uint64_t op = 0;
#ifdef MULTI
  op = L1_CACHE_SZ_IN_LINE;
  cacheline_t* l1 = alloc_mem(L1_CACHE_SZ_IN_LINE * CACHELINE_SIZE);
  cacheline_t* l2 = alloc_mem(L1_CACHE_SZ_IN_LINE * CACHELINE_SIZE);
  cacheline_t* mem = alloc_mem(L1_CACHE_SZ_IN_LINE * CACHELINE_SIZE);
#else
  op = strtoull(argv[2], NULL, 10);
  uint64_t mem_len = op * 2;
  cacheline_t* mem = alloc_mem(mem_len * CACHELINE_SIZE);
#endif
  uint64_t exp_cycle = 0;
  uint64_t avg_exp_cycle = 0;

  exp_cycle = 0;
  for (int i = 0; i < iter; i++) {
#ifdef MULTI
    exp_cycle += multi_experiment(mem, l2, l1, op);
#else
    exp_cycle += experiment(mem, mem_len, op);
#endif
    sleep_ms(10);
  }
  avg_exp_cycle = exp_cycle / iter;
  printf("%lu,%lu,%.2f\n", op, avg_exp_cycle,
         (double)(avg_exp_cycle / CPU_FREQ_GHZ));

#ifdef LFB_TEST
  for (uint64_t lfb_size = 5; lfb_size <= 30; lfb_size += 1) {
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
