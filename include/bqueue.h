/**
 * @File     : bqueue.h
 * @Author   : Abdullah Younis
 *
 * CITE: https://github.com/olibre/B-Queue/blob/master/
 */

#pragma once

#include <stdint.h>
#include <string.h>
#include <unistd.h>

#define Q_BATCH_HISTORY     q->batch_history
#define Q_BACKTRACK_FLAG    q->backtrack_flag
#define Q_HEAD              q->head
#define Q_BATCH_HEAD        q->batch_head
#define Q_TAIL              q->tail
#define Q_BATCH_TAIL        q->batch_tail

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

#ifndef PACKED
#define PACKED __attribute__((packed))
#endif

// Types
typedef uint64_t data_t;

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

#ifdef CONFIG_ALIGN_BQUEUE_METADATA

#define QUEUE_SIZE (2048)  // 8192
#define BATCH_SIZE 512

#define CONS_BATCH_SIZE BATCH_SIZE  // 512
#define PROD_BATCH_SIZE BATCH_SIZE  // 512
#define BATCH_INCREMENT (BATCH_SIZE / 2)

#define CONGESTION_PENALTY (1000) /* cycles */
#define CONS_CONGESTION_PENALTY (CONGESTION_PENALTY / 2)

// #define ADAPTIVE
#define BACKTRACKING
#define PROD_BATCH
#define CONS_BATCH
//#define OPTIMIZE_BACKTRACKING
#define OPTIMIZE_BACKTRACKING2

typedef struct {
  data_t data[QUEUE_SIZE] __attribute__((aligned(64)));
} data_array_t;

// 16 bytes | 4 elements in a cacheline
typedef struct {
  volatile uint16_t head;
  volatile uint16_t batch_head;
  uint32_t num_enq_failures;
  data_t* data;
} PACKED prod_queue_t;

// 17 bytes
typedef struct {
  volatile uint16_t tail;
  volatile uint16_t batch_tail;
  // used for backtracking in the consumer
#if defined(ADAPTIVE)
  uint16_t batch_history;
#endif
#if defined(OPTIMIZE_BACKTRACKING)
  uint32_t backtrack_count;
#endif
  uint32_t num_deq_failures;
  uint8_t backtrack_flag;
  data_t* data;
} PACKED cons_queue_t;

int init_queue(cons_queue_t* q);
int free_queue(cons_queue_t* q);
int enqueue(prod_queue_t* q, data_t d);
int dequeue(cons_queue_t* q, data_t* d);

// Request Types
#define MSG_ENQUEUE 1
#define MSG_HALT 2

#else  // CONFIG_ALIGN_BQUEUE_METADATA

#define QUEUE_SIZE (2048)
#define BATCH_SIZE (QUEUE_SIZE / 16)
#define CONS_BATCH_SIZE BATCH_SIZE
#define PROD_BATCH_SIZE BATCH_SIZE
#define BATCH_INCREMENT (BATCH_SIZE / 2)

#define CONGESTION_PENALTY (1000) /* cycles */

#define ADAPTIVE 1
#define BACKTRACKING 1
#define PROD_BATCH 1
#define CONS_BATCH 1

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

  /* accessed by both producer and comsumer */
  data_t data[QUEUE_SIZE] __attribute__((aligned(64)));
} __attribute__((aligned(64))) queue_t;

int init_queue(queue_t* q);
int free_queue(queue_t* q);
int enqueue(queue_t* q, data_t d);
int dequeue(queue_t* q, data_t* d);

#endif  // CONFIG_ALIGN_BQUEUE_METADATA
