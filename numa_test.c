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
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <x86intrin.h>

#define TABLE_SIZE (1 << 26)  // number of elements (~512M cache lines => ~32GB)
#define ITERATIONS 5          // number of traversal rounds
#define ALIGNMENT 64          // 64-byte alignment (cache line size)
#define CACHELINE_SIZE 64     // cache line size in bytes

__itt_event local;
__itt_event remote;
__itt_event flush;

typedef struct {
  uint64_t value;
  char pad[CACHELINE_SIZE - sizeof(uint64_t)];
} cacheline_t;

typedef struct {
  cacheline_t *table;
  size_t size;
  int node;
} thread_arg_t;

// Bind current thread to a NUMA node
void bind_to_node(int node) {
  if (numa_run_on_node(node) != 0) {
    perror("numa_run_on_node");
    exit(EXIT_FAILURE);
  }
  numa_set_preferred(node);
}

// Pseudo-random walk with prefetch, using CRC32 for next index
void *walk_table(void *arg) {
  thread_arg_t *t = (thread_arg_t *)arg;
  bind_to_node(t->node);

  cacheline_t *table = t->table;
  size_t size = t->size;
  uint64_t idx = 0;

  for (int iter = 0; iter < ITERATIONS; iter++) {
    for (size_t i = 0; i < size; i++) {
      idx = _mm_crc32_u64(i, 0xdeadbeef) & (size - 1);
      __builtin_prefetch(&table[idx], 0, 3);
    }
  }

  return NULL;
}

void spawn_threads(thread_arg_t arg, int num_threads) {
  pthread_t *threads = (pthread_t *)malloc(num_threads * sizeof(pthread_t));

  for (int i = 0; i < num_threads; i++) {
    pthread_create(&threads[i], NULL, walk_table, &arg);
  }

  for (int i = 0; i < num_threads; i++) {
    pthread_join(threads[i], NULL);
  }

  free(threads);
}

int main() {
  if (numa_available() < 0) {
    fprintf(stderr, "NUMA is not available\n"); 
    return EXIT_FAILURE;
  }

  local = __itt_event_create("local", strlen("local"));
  remote = __itt_event_create("remote", strlen("remote"));
  flush = __itt_event_create("flush", strlen("flush"));

  // Set policy to allocate on node 0
  numa_set_preferred(0);

  size_t bytes = (size_t)TABLE_SIZE * sizeof(cacheline_t);
  cacheline_t *table = aligned_alloc(ALIGNMENT, bytes);
  if (table == NULL) {
    perror("aligned_alloc");
    return EXIT_FAILURE;
  }

  // Touch pages and initialize one value per cache line
  for (size_t i = 0; i < TABLE_SIZE; i++) {
    table[i].value = i;
  }

  thread_arg_t local_thread_arg = {table, TABLE_SIZE, 0};
  thread_arg_t remote_thread_arg = {table, TABLE_SIZE, 1};

  __itt_event_start(local);
  spawn_threads(local_thread_arg, 1);
  __itt_event_end(local);

  sleep(1);

  __itt_event_start(remote);

  spawn_threads(remote_thread_arg, 1);
  __itt_event_end(remote);

  sleep(1);
  __itt_event_start(local);

  spawn_threads(local_thread_arg, 16);
  __itt_event_end(local);

  free(table);
  return 0;
}
