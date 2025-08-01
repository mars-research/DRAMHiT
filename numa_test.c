/*
 * numa_experiment_rdtsc.c
 *
 * Experiment steps:
 * 1. Allocate a table of size TABLE_SIZE on NUMA node 0, with each element
 * 64-byte aligned and occupying one cache line.
 * 2. Bind the memory to node 0.
 * 3. Run a thread on node 0 that pseudo-randomly walks the table using
 * prefetch, measuring cycles via RDTSC.
 * 4. Repeat: after binding, spawn a helper thread on node 1 to prefetch the
 * entire table (ensuring a remote copy). Then run the walker thread on node 0
 * and measure cycles again.
 *
 * Compile with: gcc -O1 -pthread -lnuma -march=native -o numa_test numa_test.c
 * -I/opt/intel/oneapi/vtune/latest/include
 * /opt/intel/oneapi/vtune/latest/lib64/libittnotify.a
 */

#define _GNU_SOURCE
#include <errno.h>
#include <ittnotify.h>
#include <numa.h>
#include <numaif.h>
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>
#include <x86intrin.h>

#define TABLE_SIZE (1 << 24)  // number of elements (~512M cache lines => ~32GB)
#define ITERATIONS 50000000   // number of traversal rounds
#define ALIGNMENT 64          // 64-byte alignment (cache line size)
#define CACHELINE_SIZE 64     // cache line size in bytes
#define RANDOM_ACCESS

#define LOCAL 0
#define REMOTE 1

__itt_event local;
__itt_event remote;
__itt_event flush;

typedef struct {
  uint64_t value;
  char pad[CACHELINE_SIZE - sizeof(uint64_t)];
} cacheline_t;
cacheline_t *table;

typedef struct {
  int node;
  int tid;
  int cpu;
} thread_arg_t;

// Bind current thread to a NUMA node
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

// Pseudo-random walk with prefetch, using CRC32 for next index
void *walk_table(void *arg) {
  thread_arg_t *t = (thread_arg_t *)arg;

  int cpu = t->cpu;
  int tid = t->tid;
  int node = t->node;

  pin_self_to_cpu(cpu);

  if (cpu != sched_getcpu()) {
    printf("cpu doesnt match expected: %d sched: %d\n", cpu, sched_getcpu());
    pthread_exit(NULL);
  }

  uint64_t sum = 0;
  uint64_t idx;
  for (uint64_t i = 0; i < ITERATIONS; i++) {
#if defined(RANDOM_ACCESS)
    idx = _mm_crc32_u64(0xffffffff, i + (node * ITERATIONS)) & (TABLE_SIZE - 1);
#else
    idx = i & (TABLE_SIZE - 1);
#endif

    sum += table[idx].value;
  }

  printf("sum %lu from cpu %d node %d\n", sum, cpu, node);

  return NULL;
}

int spawn_threads(int node, int num_threads) {
  int success = 0;

  pthread_t *threads = (pthread_t *)malloc(num_threads * sizeof(pthread_t));
  thread_arg_t *args =
      (thread_arg_t *)malloc(sizeof(thread_arg_t) * num_threads);
  int *cpus = (int *)malloc(num_threads * sizeof(int));
  int count = get_numa_cpuids(node, cpus, num_threads);

  if (count < num_threads) {
    printf("not enough physical cpus on node %d, max cpu %d, requested %d\n",
           node, count, num_threads);
    goto cleanup;
  }

  for (int i = 0; i < num_threads; i++) {
    args[i].tid = i;
    args[i].cpu = cpus[i];
    args[i].node = node;

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

int spawn_threads_numa(int local_c, int remote_c) {
  int success = 0;

  int num_threads = local_c + remote_c;

  pthread_t *threads = (pthread_t *)malloc(num_threads * sizeof(pthread_t));
  thread_arg_t *args =
      (thread_arg_t *)malloc(sizeof(thread_arg_t) * num_threads);
  int *local_cpus = (int *)malloc(local_c * sizeof(int));
  int *remote_cpus = (int *)malloc(remote_c * sizeof(int));

  int count = get_numa_cpuids(LOCAL, local_cpus, local_c);
  count = get_numa_cpuids(REMOTE, remote_cpus, remote_c);

  for (int i = 0; i < num_threads; i++) {
    args[i].tid = i;

    if (i < local_c) {
      args[i].cpu = local_cpus[i];
      args[i].node = LOCAL;
    } else {
      args[i].cpu = remote_cpus[(i - local_c)];
      args[i].node = REMOTE;
    }

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
  free(local_cpus);
    free(remote_cpus);


  return success;
}

// A -> I condition
// I -> A -> I
void experiment_0() {
  __itt_event_start(local);
  // if (spawn_threads(LOCAL, 16) == 0) {
  //   printf("spawn threads failed\n");
  // }

  if (spawn_threads_numa(2, 2) == 0) {
    printf("spawn threads failed\n");
  }
  __itt_event_end(local);

  // sleep(1);

  // __itt_event_start(remote);
  // if (spawn_threads(REMOTE, 16) == 0) {
  //   printf("spawn threads failed\n");
  // }
  // __itt_event_end(remote);

  // sleep(1);

  // __itt_event_start(local);
  // if (spawn_threads(LOCAL, 16) == 0) {
  //   printf("spawn threads failed\n");
  // }
  // __itt_event_end(local);
}

int main() {
  if (numa_available() < 0) {
    fprintf(stderr, "NUMA is not available\n");
    return EXIT_FAILURE;
  }

  local = __itt_event_create("local", strlen("local"));
  remote = __itt_event_create("remote", strlen("remote"));
  flush = __itt_event_create("flush", strlen("flush"));

  srand(time(NULL));

  // Set policy to allocate on node 0
  numa_set_preferred(0);

  table = aligned_alloc(ALIGNMENT, TABLE_SIZE * sizeof(cacheline_t));
  if (table == NULL) {
    perror("aligned_alloc");
    return EXIT_FAILURE;
  }

  // Touch pages and initialize one value per cache line
  for (size_t i = 0; i < TABLE_SIZE; i++) {
    table[i].value = i;
  }

  sleep(1);

  experiment_0();

  free(table);
  return 0;
}
