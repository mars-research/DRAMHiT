#define _GNU_SOURCE
#include <assert.h>
#include <errno.h>
#include <numa.h>
#include <numaif.h>
#include <pthread.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
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
#define TABLE_SIZE (uint64_t)(1 << 28)
#define ALIGNMENT 64       // 64-byte alignment (cache line size)
#define CACHELINE_SIZE 64  // cache line size in bytes
#define STRIDE 1024

#define LOCAL 0
#define REMOTE 1

// numa node 0 and 1 are physical socket 0.
#define SUB_CLUSTER_LOCAL 3 // Binary 0011 (Nodes 0 and 1)

#define CACHELOCAL 1
#define CACHEREMOTE 0

typedef struct {
  uint64_t value;
  char pad[CACHELINE_SIZE - sizeof(uint64_t)];
} cacheline_t;
cacheline_t *table;

typedef struct {
  unsigned long nodemask; // Changed to support multiple nodes
  int tid;
  int cpu;
  int iter;
  int num_threads;
  uint64_t sum;
  pthread_barrier_t *barrier;
} thread_arg_t;


// NEW: Binds the calling thread's execution affinity to all CPUs across the requested nodes
void bind_to_nodemask(unsigned long nodemask) {
  struct bitmask *mask = numa_allocate_nodemask();

  // Set the bits in the numa bitmask based on our unsigned long nodemask
  for (int i = 0; i < sizeof(nodemask) * 8; i++) {
    if (nodemask & (1UL << i)) {
      numa_bitmask_setbit(mask, i);
    }
  }

  // Allow execution on any CPU within the specified nodes
  if (numa_run_on_node_mask(mask) != 0) {
    perror("numa_run_on_node_mask");
    exit(EXIT_FAILURE);
  }

  numa_free_nodemask(mask);
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

// UPDATED: Balances the requested CPUs evenly across all nodes in the nodemask
int get_numa_cpuids(unsigned long nodemask, int *cpu_ids, int max_len) {
  if (numa_available() < 0) {
    fprintf(stderr, "NUMA is not available.\n");
    return -1;
  }

  int max_node = numa_max_node();
  int active_nodes = 0;

  // 1. Count how many nodes were requested in the mask
  for (int i = 0; i <= max_node; i++) {
    if (nodemask & (1UL << i)) {
      active_nodes++;
    }
  }

  if (active_nodes == 0) return 0;

  // 2. Calculate how many CPUs to take from each node
  int base_cpus_per_node = max_len / active_nodes;
  int remainder = max_len % active_nodes; // In case total threads isn't perfectly divisible

  int count = 0;

  // 3. Fetch the exact balanced amount from each requested node
  for (int node = 0; node <= max_node; node++) {
    if (nodemask & (1UL << node)) {

      // Distribute the remainder evenly if (max_len % active_nodes != 0)
      int cpus_to_get = base_cpus_per_node + (remainder > 0 ? 1 : 0);
      if (remainder > 0) remainder--;

      struct bitmask *cpumask = numa_allocate_cpumask();

      if (numa_node_to_cpus(node, cpumask) == 0) {
        int node_cpus_collected = 0;

        // Collect CPUs until we hit the balanced limit for THIS node
        for (int i = 0; i < cpumask->size && node_cpus_collected < cpus_to_get; i++) {
          if (numa_bitmask_isbitset(cpumask, i)) {
            cpu_ids[count++] = i;
            node_cpus_collected++;
          }
        }

        // Safety check if the node has fewer physical cores than requested
        if (node_cpus_collected < cpus_to_get) {
          fprintf(stderr, "Warning: Node %d only has %d available CPUs, but %d were requested for balance.\n",
                  node, node_cpus_collected, cpus_to_get);
        }
      } else {
        perror("numa_node_to_cpus");
      }

      numa_free_cpumask(cpumask);
    }
  }

  return count;
}

void *walk_table(void *arg) {
  thread_arg_t *t = (thread_arg_t *)arg;
  int cpu = t->cpu;
  int tid = t->tid;
  unsigned long nodemask = t->nodemask;
  int iter = t->iter;
  int num_threads = t->num_threads;
  uint64_t WORKLOAD_PER_THREAD = TABLE_SIZE / num_threads;
  uint64_t offset = tid * WORKLOAD_PER_THREAD;
  uint64_t seed = 0xdeadbeaf; //iter + 0xdeadbeaf + tid;

  pin_self_to_cpu(cpu);

  //printf("thread %lu to cpu %lu\n", tid, cpu);

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
    idx = _mm_crc32_u64(seed, i + offset) & (TABLE_SIZE - 1);
#else
    idx = (i + offset) & (TABLE_SIZE - 1);
#endif

// Completed memory operations
#if defined(READ)
    sum += table[idx].value;
#elif defined(WRITE)
    table[idx].value = sum;
#elif defined(PREFETCH_T0)
    _mm_prefetch((const void *)&table[idx], _MM_HINT_T0);
#elif defined(PREFETCH_T1)
    _mm_prefetch((const void *)&table[idx], _MM_HINT_T1);
#elif defined(PREFETCH_T2)
    _mm_prefetch((const void *)&table[idx], _MM_HINT_T2);
#elif defined(PREFETCH_NTA)
    _mm_prefetch((const void *)&table[idx], _MM_HINT_NTA);
#else
    // Default fallback to READ
    sum += table[idx].value;
#endif
  }

  t->sum = sum;

  return NULL;
}

// UPDATED: Accepts nodemask instead of node
int spawn_threads(unsigned long nodemask, int num_threads, int iter) {
  int success = 0;

  pthread_t *threads = (pthread_t *)malloc(num_threads * sizeof(pthread_t));
  thread_arg_t *args =
      (thread_arg_t *)malloc(sizeof(thread_arg_t) * num_threads);
  int *cpus = (int *)malloc(num_threads * sizeof(int));

  // Fetch CPUs across all nodes specified in the mask
  int count = get_numa_cpuids(nodemask, cpus, num_threads);

  if (count < num_threads) {
    printf(
        "not enough physical cpus on requested nodes, max cpu %d, requested: "
        "%d\n",
        count, num_threads);
    goto cleanup;
  }

  pthread_barrier_t barrier;
  pthread_barrier_init(&barrier, NULL, num_threads);

  for (int i = 0; i < num_threads; i++) {
    args[i].tid = i;
    args[i].cpu = cpus[i];
    args[i].nodemask = nodemask; // Track the mask
    args[i].barrier = &barrier;
    args[i].iter = iter;
    args[i].num_threads = (uint32_t)num_threads;
    args[i].sum = 0;

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

// Ensure MAP_HUGE_1GB is defined, as it might be missing in older glibc headers
#ifndef MAP_HUGE_1GB
#define MAP_HUGE_1GB (30 << 26)  // 26 is MAP_HUGE_SHIFT
#endif

// To interleave across node 0 and 1, pass: (1UL << 0) | (1UL << 1) which is 3
void *alloc_table(size_t size, unsigned long nodemask) {
  // Set page size to 1GB
  size_t page_sz = 1ULL << 30;
  size_t obj_sz = ((size + page_sz - 1) / page_sz) * page_sz;

  printf("allocate %lu gb pages\n", (size / page_sz));

  // Allocate memory using mmap with 1GB hugepages
  void *mem =
      mmap(NULL, obj_sz, PROT_READ | PROT_WRITE,
           MAP_PRIVATE | MAP_ANONYMOUS | MAP_HUGETLB | MAP_HUGE_1GB, -1, 0);

  // mmap returns MAP_FAILED on error, not NULL
  assert(mem != MAP_FAILED);

  // Use MPOL_INTERLEAVE instead of MPOL_BIND
  assert(mbind(mem, obj_sz, MPOL_INTERLEAVE, &nodemask, 64,
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

  // UPDATED: Bind the master process execution affinity to all requested nodes
  bind_to_nodemask(SUB_CLUSTER_LOCAL);

  // Allocate the 16GB table interleaved over the nodes
  table = (cacheline_t *)alloc_table(TABLE_SIZE * sizeof(cacheline_t), SUB_CLUSTER_LOCAL);

  if (table == NULL) {
    perror("alloc table failed");
    return EXIT_FAILURE;
  }

  for (int i = 0; i < TABLE_SIZE; i++) table[i].value = 1;

  uint64_t duration = RDTSC_START();

  // UPDATED: Spawn threads passing the cluster mask
  for (int i = 0; i < iter; i++) spawn_threads(SUB_CLUSTER_LOCAL, num_threads, iter);

  duration = RDTSCP() - duration;
  double sec = (double)((duration / CPU_FREQ) / 1000000000);
  uint64_t cachelines = (uint64_t)TABLE_SIZE * (uint64_t)iter;
  double bwf =
      (double)(cachelines * sizeof(cacheline_t) * (double)CPU_FREQ) / duration;
  printf(
      "duration %lu\n"
      "sec %.3f\n"
      "cachelines %lu\n"
      "bw %.1f GB/s\n",
      duration, sec, cachelines, bwf);

  munmap(table, TABLE_SIZE * sizeof(cacheline_t));

  return 0;
}
