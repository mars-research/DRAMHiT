/*
 *
 * Compile with: gcc -O1 -pthread -lnuma -march=native -o numa_test numa_test.c
 * -I/opt/intel/oneapi/vtune/latest/include
 * /opt/intel/oneapi/vtune/latest/lib64/libittnotify.a
 */

#define _GNU_SOURCE
#include <assert.h>
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
#define TABLE_SIZE (1 << 26)  // 8 GB
#define ALIGNMENT 64          // 64-byte alignment (cache line size)
#define CACHELINE_SIZE 64     // cache line size in bytes
//#define RANDOM_ACCESS
#define READ
#define STRIDE 1024


#define LOCAL 0
#define REMOTE 1

#define CACHELOCAL 1
#define CACHEREMOTE 0

__itt_event local;
__itt_event remote;
__itt_event share;
__itt_event dowork;


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

pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
int ready = 1;

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
  uint32_t WORKLOAD_PER_THREAD = TABLE_SIZE/num_threads; 

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


  uint64_t start, end;
  start = RDTSC_START();
  for (uint64_t j = 0; j < iter; j++) {
    for (uint64_t i = 0; i < TABLE_SIZE; i++) {
#if defined(RANDOM_ACCESS)
        idx = _mm_crc32_u64(0xffffffff, i+(tid * WORKLOAD_PER_THREAD)) & (TABLE_SIZE - 1);
#else
        idx = i+(tid * WORKLOAD_PER_THREAD) & (TABLE_SIZE - 1);
#endif
        //sum += table[idx].value;

        _mm_prefetch(&table[idx], 1);
    }
  }
  end = RDTSCP();

  printf("total op %u sum %lu from cpu %d node %d duration %lu\n",
         iter * TABLE_SIZE, sum, cpu, node, end - start);

  return NULL;
}

// Pseudo-random walk with prefetch, using CRC32 for next index
void *walk_table_sync(void *arg) {
  thread_arg_t *t = (thread_arg_t *)arg;

  int cpu = t->cpu;
  int tid = t->tid;
  int node = t->node;
  int iter = t->iter;

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

  __itt_event_start(dowork);
  for (uint64_t j = 0; j < iter; j++) {
    for (uint64_t i = 0; i < TABLE_SIZE; i += STRIDE) {
      pthread_mutex_lock(&mutex);

      while (node == 0 && ready != 1) {
        pthread_cond_wait(&cond, &mutex);
      }

      while (node == 1 && ready != 0) {
        pthread_cond_wait(&cond, &mutex);
      }

      pthread_mutex_unlock(&mutex);

      for (uint64_t k = 0; k < STRIDE; k++) {
        idx = (i + k) & (TABLE_SIZE - 1);
        sum += table[idx].value;
      }

      pthread_mutex_lock(&mutex);

      if (node == 1) {
        ready = 1;
        pthread_cond_signal(&cond);
      } else {
        ready = 0;
        pthread_cond_signal(&cond);
      }

      pthread_mutex_unlock(&mutex);
    }
  }

  __itt_event_end(dowork);

  printf("total op %u sum %lu from cpu %d node %d\n", iter * TABLE_SIZE, sum,
         cpu, node);

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

int spawn_threads_numa(int local_c, int remote_c, int iter) {
  int success = 0;

  int num_threads = local_c + remote_c;

  pthread_t *threads = (pthread_t *)malloc(num_threads * sizeof(pthread_t));
  thread_arg_t *args =
      (thread_arg_t *)malloc(sizeof(thread_arg_t) * num_threads);

  int NUM_CPUS = 32;
  int *local_cpus = (int *)malloc(NUM_CPUS * sizeof(int));
  int *remote_cpus = (int *)malloc(NUM_CPUS * sizeof(int));

  int count = get_numa_cpuids(LOCAL, local_cpus, NUM_CPUS);
  int remote_count = get_numa_cpuids(REMOTE, remote_cpus, NUM_CPUS);

  pthread_barrier_t barrier;
  pthread_barrier_init(&barrier, NULL, num_threads);

  for (int i = 0; i < num_threads; i++) {
    args[i].tid = i;
    args[i].barrier = &barrier;
    args[i].iter = iter;

    int cpu = rand() % NUM_CPUS;
    if (i < local_c) {
      args[i].cpu = local_cpus[cpu];
      args[i].node = LOCAL;
    } else {
      args[i].cpu = remote_cpus[cpu];
      args[i].node = REMOTE;
    }

    if (pthread_create(&threads[i], NULL, walk_table_sync, &args[i]) != 0) {
      perror("pthread_create failed");
      goto cleanup;
    }
  }

  for (int i = 0; i < num_threads; i++) {
    pthread_join(threads[i], NULL);
  }

  success = 1;
cleanup:
  pthread_barrier_destroy(&barrier);

  free(threads);
  free(args);
  free(local_cpus);
  free(remote_cpus);

  return success;
}

void reach_s() {
  spawn_threads(0, 1, 2);
  sleep(1);

  ready = CACHELOCAL;  // S
  if (spawn_threads_numa(1, 1, 1) == 0) {
    printf("spawn threads failed\n");
  }
  sleep(1);

  spawn_threads(0, 1, 2);
}

void remote_walk() {
  __itt_event_start(remote);

  spawn_threads(1, 1, 1);
  __itt_event_end(remote);

  sleep(1);
}

void remote_walk_64() {
  __itt_event_start(remote);

  spawn_threads(1, 64, 1);
  __itt_event_end(remote);

  sleep(1);
}

void local_walk() {
  __itt_event_start(local);
  spawn_threads(0, 1, 1);
  __itt_event_end(local);

  sleep(1);
}



void local_walk_64() {
  __itt_event_start(local);
  spawn_threads(0, 64, 1);
  __itt_event_end(local);

  sleep(1);
}

void sync_walk() {
  __itt_event_start(share);
  ready = CACHELOCAL;
  if (spawn_threads_numa(1, 1, 1) == 0) {
    printf("spawn threads failed\n");
  }

  __itt_event_end(share);
  sleep(1);
}

void experiment() {
 
  local_walk();  // Initilize to I
  local_walk_64();

  remote_walk(); // DIR A 
  remote_walk_64();

  printf("Reading A state from Local socket\n");
  local_walk();  

  sync_walk(); // DIR S
  printf("Reading S state from Local socket\n");
  local_walk();  
  local_walk_64();

  printf("Reading S state from remote socket\n");
  remote_walk();  
  remote_walk_64();
}

void rpq_test() 
{
  //[1, 2, 4, 8, 16, 32, 64]

  static __itt_event evt1 = __itt_event_create("1", 1);
  __itt_event_start(evt1);
  spawn_threads(0, 1 , 1);
  __itt_event_end(evt1);
  __itt_event_destroy(evt1);
  
  static __itt_event evt2 = __itt_event_create("2", 1);
  static __itt_event evt3 = __itt_event_create("4", 1);
  static __itt_event evt4 = __itt_event_create("8", 1);
  static __itt_event evt5 = __itt_event_create("16", 2);
  static __itt_event evt6 = __itt_event_create("32", 2);
  static __itt_event evt7 = __itt_event_create("64", 2);

  // spawn_threads(0, 32, 2);

  // __itt_event_start(local);
  // spawn_threads(0, 2, 2);
  // __itt_event_end(local);
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

int main() {
  if (numa_available() < 0) {
    fprintf(stderr, "NUMA is not available\n");
    return EXIT_FAILURE;
  }

  local = __itt_event_create("local", strlen("local"));
  remote = __itt_event_create("remote", strlen("remote"));
  share = __itt_event_create("share", strlen("share"));
  dowork = __itt_event_create("dowork", strlen("dowork"));


  srand(time(NULL));

  bind_to_node(0);

  table = (cacheline_t *)alloc_table(TABLE_SIZE * sizeof(cacheline_t), LOCAL);

  if (table == NULL) {
    perror("alloc table failed");
    return EXIT_FAILURE;
  }

  for (int i = 0; i < TABLE_SIZE; i++) table[i].value = 1;

  printf("allocating and writing to table %p from node %u\n", table, LOCAL);
  sleep(1);

  rpq_test();

  pthread_mutex_destroy(&mutex);
  pthread_cond_destroy(&cond);
  free(table);
  return 0;
}
