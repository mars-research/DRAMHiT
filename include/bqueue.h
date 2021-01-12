/**
 * @File     : bqueue.h
 * @Author   : Abdullah Younis
 *
 * CITE: https://github.com/olibre/B-Queue/blob/master/
 */

#ifndef LIBFIPC_TEST_QUEUE
#define LIBFIPC_TEST_QUEUE

//#include "libfipc/libfipc_test.h"
#include <stdint.h>
#include <string.h>
#include <unistd.h>

#define QUEUE_SIZE (2048)  // 8192
//#define BATCH_SIZE (QUEUE_SIZE / 8)  // 512
#define BATCH_SIZE 512

#define CONS_BATCH_SIZE BATCH_SIZE  // 512
#define PROD_BATCH_SIZE BATCH_SIZE  // 512
#define BATCH_INCREMENT (BATCH_SIZE / 2)

//#define CONGESTION_PENALTY (1000) /* cycles */
// Try to move to the next queue instead of penalizing
#define CONGESTION_PENALTY (0) /* cycles */

// Error Values
#define SUCCESS 0
#define NO_MEMORY 1
#define EMPTY_COLLECTION 2
#define BUFFER_FULL -1
#define BUFFER_EMPTY -2

// Assumed cache line size, in bytes
#ifndef FIPC_CACHE_LINE_SIZE
#define FIPC_CACHE_LINE_SIZE 64
#endif

#ifndef CACHE_ALIGNED
#define CACHE_ALIGNED __attribute__((aligned(FIPC_CACHE_LINE_SIZE)))
#endif

// Types
typedef uint64_t data_t;

typedef struct node {
  uint64_t field;
} CACHE_ALIGNED node_t;

#define ADAPTIVE 1
#define BACKTRACKING 1
#define PROD_BATCH 1
#define CONS_BATCH 1

#if defined(CONS_BATCH) || defined(PROD_BATCH)

typedef struct queue_t {
  /* Mostly accessed by producer. */
  volatile uint32_t head;
  volatile uint32_t batch_head;

  /* Mostly accessed by consumer. */
  volatile uint32_t tail __attribute__((aligned(64)));
  volatile uint32_t batch_tail;
  unsigned long batch_history;

  /* readonly data */
  uint64_t start_c __attribute__((aligned(64)));
  uint64_t stop_c;

  uint64_t backtrack_count;
  /* accessed by both producer and comsumer */
  data_t data[QUEUE_SIZE] __attribute__((aligned(64)));
} __attribute__((aligned(64))) queue_t;

#else

typedef struct queue_t {
  /* Mostly accessed by producer. */
  volatile uint32_t head;

  /* Mostly accessed by consumer. */
  volatile uint32_t tail __attribute__((aligned(64)));

  /* readonly data */
  uint64_t start_c __attribute__((aligned(64)));
  uint64_t stop_c;

  /* accessed by both producer and comsumer */
  data_t data[QUEUE_SIZE] __attribute__((aligned(64)));
} __attribute__((aligned(64))) queue_t;

#endif

#if 0

typedef struct CACHE_ALIGNED queue_t
{
	/* Mostly accessed by producer. */
	volatile	uint64_t	head;
	volatile	uint64_t	batch_head;

	/* Mostly accessed by consumer. */
	volatile	uint64_t	tail CACHE_ALIGNED;
	volatile	uint64_t	batch_tail;
	unsigned long	batch_history;

	/* accessed by both producer and comsumer */
	data_t	data[QUEUE_SIZE] CACHE_ALIGNED;

} queue_t;

#endif

int init_queue(queue_t* q);
int free_queue(queue_t* q);
int enqueue(queue_t* q, data_t d);
int dequeue(queue_t* q, data_t* d);
void prefetch_queue(queue_t* q, bool producer);
void prefetch_queue_data(queue_t* q, bool producer);

// Request Types
#define MSG_ENQUEUE 1
#define MSG_HALT 2

// Thread Locks
[[maybe_unused]] static uint64_t completed_producers = 0;
[[maybe_unused]] static uint64_t completed_consumers = 0;
[[maybe_unused]] static uint64_t ready_consumers = 0;
[[maybe_unused]] static uint64_t ready_producers = 0;
[[maybe_unused]] static uint64_t test_ready = 0;
[[maybe_unused]] static uint64_t test_finished = 0;

/**
 * This function returns a time stamp with no preceding fence instruction.
 */
static inline uint64_t fipc_test_time_get_timestamp(void) {
  unsigned int low, high;

  asm volatile("rdtsc" : "=a"(low), "=d"(high));

  return low | ((uint64_t)high) << 32;
}

/**
 * This function waits for atleast ticks clock cycles.
 */
static inline void fipc_test_time_wait_ticks(uint64_t ticks) {
  uint64_t current_time;
  uint64_t time = fipc_test_time_get_timestamp();
  time += ticks;
  do {
    current_time = fipc_test_time_get_timestamp();
  } while (current_time < time);
}
#endif
