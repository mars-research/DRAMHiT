

// This is used to show upi maxium throughput is 240GB/s as we expected
// This essentilly spawn all threads in system, and force them to do remote 
// memory access.
// Compile: gcc -O1 -o upi upi_test.c -lnuma -lpthread
// Monitor this under vtune to see max bandwidth upi.

#define _GNU_SOURCE
#include <numa.h>
#include <numaif.h>
#include <pthread.h>
#include <sched.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <x86intrin.h>

#define THREADS_PER_SOCKET 64
#define ITERATIONS (100000000)               // 1_000_000_000UL
#define MEM_SIZE (2UL * 1024 * 1024 * 1024)  // 2 GB

#define TOTAL_THREADS (2 * THREADS_PER_SOCKET)
#define CACHELINE 64
#define NUM_LINES (MEM_SIZE / CACHELINE)
#define WORKLOAD_PER_THREAD (NUM_LINES / THREADS_PER_SOCKET)

uint8_t *mem_node0;
uint8_t *mem_node1;

pthread_barrier_t barrier;

typedef struct {
  int id;
  int cpu;
} thread_arg_t;

void pin_thread_to_cpu(int cpu_id) {
  cpu_set_t cpuset;
  CPU_ZERO(&cpuset);
  CPU_SET(cpu_id, &cpuset);

  pthread_t thread = pthread_self();
  int s = pthread_setaffinity_np(thread, sizeof(cpu_set_t), &cpuset);
  if (s != 0) {
    perror("pthread_setaffinity_np");
    exit(1);
  }
}

void *thread_worker(void *arg) {
  thread_arg_t *targ = (thread_arg_t *)arg;

  int tid = targ->id;
  int cpu = targ->id;

  pin_thread_to_cpu(cpu);

  if (cpu != sched_getcpu()) {
    printf("cpu doesnt match expected: %d sched: %d\n", cpu, sched_getcpu());
    pthread_exit(NULL);
  }

  int node = numa_node_of_cpu(cpu);
  if (node < 0) {
    perror("numa_node_of_cpu failed");
    pthread_exit(NULL);
  }

  printf("tid %d node %d cpu %d\n", tid, node, cpu);
  // Determine which memory to access (remote)
  uint8_t *mem = (node == 0) ? mem_node1 : mem_node0;

  // Barrier: wait for all threads before starting the benchmark loop
  int rc = pthread_barrier_wait(&barrier);
  if (rc != 0 && rc != PTHREAD_BARRIER_SERIAL_THREAD) {
    perror("pthread_barrier_wait failed");
    pthread_exit(NULL);
  }

  uint64_t sum = 0;
  // Begin benchmark, random walk about the table
  for (uint64_t i = 0; i < ITERATIONS; i++) {
    uint32_t idx = _mm_crc32_u32(0xffffffff, i + (tid * WORKLOAD_PER_THREAD)) &
                   (NUM_LINES - 1);
    sum += mem[(idx << 6)];
  }

  printf("sum: %lu\n", sum);

  return NULL;
}

void *alloc_on_node(size_t size, int node) {
  long page_size = sysconf(_SC_PAGESIZE);
  void *ptr = aligned_alloc(page_size, size);
  if (!ptr) {
    perror("aligned_alloc");
    return NULL;
  }

  // Create nodemask with only the target node
  unsigned long nodemask = 1UL << node;

  // Bind the memory to the NUMA node
  if (mbind(ptr, size, MPOL_MF_MOVE | MPOL_MF_STRICT, &nodemask,
            sizeof(nodemask) * 8, 0) != 0) {
    perror("mbind");
    free(ptr);
    return NULL;
  }

  return ptr;
}

int main() {
  if (numa_available() < 0) {
    fprintf(stderr, "NUMA not supported.\n");
    return 1;
  }

  // Allocate memory pinned to node 0 and node 1
  mem_node0 = alloc_on_node(MEM_SIZE, 0);
  mem_node1 = alloc_on_node(MEM_SIZE, 1);

  printf("mem 0 allocated at %p\nmem 1 allocated at %p\n", mem_node0,
         mem_node1);

  // Initialize barrier for TOTAL_THREADS threads
  if (pthread_barrier_init(&barrier, NULL, TOTAL_THREADS) != 0) {
    perror("pthread_barrier_init failed");
    return 1;
  }

  memset(mem_node0, 1, MEM_SIZE);
  memset(mem_node1, 2, MEM_SIZE);

  // Create threads
  pthread_t threads[TOTAL_THREADS];
  thread_arg_t args[TOTAL_THREADS];

  for (int t = 0; t < TOTAL_THREADS; t++) {
    int cpu = t % THREADS_PER_SOCKET;
    args[t].id = t;
    args[t].cpu = cpu;

    if (pthread_create(&threads[t], NULL, thread_worker, &args[t]) != 0) {
      perror("pthread_create failed");
      exit(1);
    }
  }

  for (int t = 0; t < TOTAL_THREADS; t++) {
    pthread_join(threads[t], NULL);
  }

  // Cleanup
  pthread_barrier_destroy(&barrier);
  numa_free(mem_node0, MEM_SIZE);
  numa_free(mem_node1, MEM_SIZE);

  return 0;
}
