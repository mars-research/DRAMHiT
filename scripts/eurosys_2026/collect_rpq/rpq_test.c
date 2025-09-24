#define _GNU_SOURCE
#include <assert.h>
#include <errno.h>
// #include <ittnotify.h>
#include <numa.h>
#include <numaif.h>
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <x86intrin.h>
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
// 1024 * 1024
#define TABLE_SIZE (uint64_t) (1 << 26)  // 4 GB
#define ALIGNMENT 64          // 64-byte alignment (cache line size)
#define CACHELINE_SIZE 64     // cache line size in bytes
// #define RANDOM_ACCESS
#define READ
#define STRIDE 1024

#define LOCAL 0
#define REMOTE 1

#define CACHELOCAL 1
#define CACHEREMOTE 0

typedef struct {
  uint64_t value;
  char pad[CACHELINE_SIZE - sizeof(uint64_t)];
} cacheline_t;
cacheline_t *table;

typedef struct {
  int node;
  int tid;
  int cpu;
  int iter;
  int num_threads;
  pthread_barrier_t *barrier;
} thread_arg_t;

void bind_to_node(int node) {
  if (numa_run_on_node(node) != 0) {
    perror("numa_run_on_node");
    exit(EXIT_FAILURE);
  }
  numa_set_preferred(node);
}

int pin_self_to_cpu(int cpu) {
  cpu_set_t cpuset;
  CPU_ZERO(&cpuset);
  CPU_SET(cpu, &cpuset);

  // Pin this thread to the given CPU
  if (pthread_setaffinity_np(pthread_self(), sizeof(cpu_set_t), &cpuset) != 0) {
    perror("pthread_setaffinity_np failed");
    return 1;
  }

  return 0;
}

int get_numa_cpuids(int node, int *cpu_ids, int max_len) {
  if (numa_available() < 0) {
    fprintf(stderr, "NUMA is not available.\n");
    return -1;
  }

  struct bitmask *cpumask = numa_allocate_cpumask();
  if (numa_node_to_cpus(node, cpumask) != 0) {
    perror("numa_node_to_cpus");
    numa_free_cpumask(cpumask);
    return -1;
  }

  int count = 0;
  for (int i = 0; i < cpumask->size && count < max_len; i++) {
    if (numa_bitmask_isbitset(cpumask, i)) {
      cpu_ids[count++] = i;
    }
  }

  numa_free_cpumask(cpumask);
  return count;
}

void *walk_table(void *arg) {
  thread_arg_t *t = (thread_arg_t *)arg;

  int cpu = t->cpu;
  int tid = t->tid;
  int node = t->node;
  int iter = t->iter;
  int num_threads = t->num_threads;
  uint32_t WORKLOAD_PER_THREAD = TABLE_SIZE / num_threads;
  uint32_t offset = tid * WORKLOAD_PER_THREAD;

  pin_self_to_cpu(cpu);

  if (cpu != sched_getcpu()) {
    printf("cpu doesnt match expected: %d sched: %d\n", cpu, sched_getcpu());
    pthread_exit(NULL);
  }

  uint64_t sum = 0;
  uint64_t idx;

  if (t->barrier != NULL) {
    pthread_barrier_wait(t->barrier);
  }

  for (uint64_t i = 0; i < WORKLOAD_PER_THREAD; i++) {
#if defined(RANDOM_ACCESS)
    idx = _mm_crc32_u64(0xffffffff, i + offset) & (TABLE_SIZE - 1);
#else
    idx = (i + offset) & (TABLE_SIZE - 1);
#endif
    _mm_prefetch(&table[idx], 1);
  }

  return NULL;
}

int spawn_threads(int node, int num_threads, int iter) {
  int success = 0;

  pthread_t *threads = (pthread_t *)malloc(num_threads * sizeof(pthread_t));
  thread_arg_t *args =
      (thread_arg_t *)malloc(sizeof(thread_arg_t) * num_threads);
  int *cpus = (int *)malloc(num_threads * sizeof(int));
  int count = get_numa_cpuids(node, cpus, num_threads);

  if (count < num_threads) {
    printf(
        "not enough physical cpus on node %d, max cpu %d, requesoftwarested "
        "%d\n",
        node, count, num_threads);
    goto cleanup;
  }

  pthread_barrier_t barrier;
  pthread_barrier_init(&barrier, NULL, num_threads);

  for (int i = 0; i < num_threads; i++) {
    args[i].tid = i;
    args[i].cpu = cpus[i];
    args[i].node = node;
    args[i].barrier = &barrier;
    args[i].iter = iter;
    args[i].num_threads = (uint32_t)num_threads;

    if (pthread_create(&threads[i], NULL, walk_table, &args[i]) != 0) {
      perror("pthread_create failed");
      goto cleanup;
    }
  }

  for (int i = 0; i < num_threads; i++) {
    pthread_join(threads[i], NULL);
  }

  success = 1;
cleanup:
  free(threads);
  free(args);
  free(cpus);

  return success;
}



void *alloc_table(size_t size, size_t numa_node) {
  size_t page_sz = 4096;
  size_t obj_sz = ((size + page_sz - 1) / page_sz) * page_sz;
  void *mem = aligned_alloc(page_sz, obj_sz);
  assert(mem != NULL);
  unsigned long nodemask = 1UL << numa_node;
  assert(mbind(mem, obj_sz, MPOL_BIND, &nodemask, sizeof(nodemask) * 8,
               MPOL_MF_MOVE | MPOL_MF_STRICT) == 0);
  return mem;
}

#define CPU_FREQ 2.5

int main(int argc, char **argv) {
  uint32_t iter = 10;         // default
  uint32_t num_threads = 10;  // default

  if (argc > 1) {
    iter = (uint32_t)strtoul(argv[1], NULL, 10);
  }
  if (argc > 2) {
    num_threads = (uint32_t)strtoul(argv[2], NULL, 10);
  }

  printf("iter %u\n", iter);
  printf("num_threads %u\n", num_threads);

  if (numa_available() < 0) {
    fprintf(stderr, "NUMA is not available\n");
    return EXIT_FAILURE;
  }
  srand(time(NULL));

  bind_to_node(0);

  table = (cacheline_t *)alloc_table(TABLE_SIZE * sizeof(cacheline_t), LOCAL);

  if (table == NULL) {
    perror("alloc table failed");
    return EXIT_FAILURE;
  }

  for (int i = 0; i < TABLE_SIZE; i++) table[i].value = 1;


  uint64_t duration = RDTSC_START();

  for (int i = 0; i < iter; i++) spawn_threads(0, num_threads, iter);

  duration = RDTSCP() - duration;
  double sec = (double)((duration / CPU_FREQ)/1000000000);
  uint64_t cachelines = (uint64_t)TABLE_SIZE * (uint64_t)iter;
  uint64_t bw = cachelines * sizeof(cacheline_t) / ((1 << 30) * sec) ;
  printf(
      "duration %lu\nsec %.3f\ncachelines %lu\nbw %lu "
      "GB/s\n",
      duration, sec, cachelines, bw);
  free(table);
  return 0;
}
