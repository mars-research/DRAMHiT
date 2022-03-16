#pragma once

#include "queue.hpp"
#include <tuple>
#include <map>
#include <assert.h>
#include <x86intrin.h>
#include <cstring>

#define OPTIMIZE_BACKTRACKING2

namespace kmercounter {

class BQueueAligned {
  private:
    size_t batch_size;
    size_t queue_size;
    clock_t start_time;
    clock_t end_time;
    double queue_time;

  public:
    const uint64_t CONGESTION_PENALTY = 250 / 2;
    static const uint64_t BQ_MAGIC_64BIT = 0xD221A6BE96E04673UL;

    typedef struct {
      volatile uint32_t head;
      volatile uint32_t batch_head;
      uint32_t num_enq_failures;
      data_t* data;
    } prod_queue_t;

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
    } cons_queue_t;

    std::map<std::tuple<int, int>, prod_queue_t*> pqueue_map;
    std::map<std::tuple<int, int>, cons_queue_t*> cqueue_map;

    prod_queue_t **all_pqueues;
    cons_queue_t **all_cqueues;
    uint32_t nprod;
    uint32_t ncons;

    void init_prod_queues() {
      // map queues and producer_metadata
      for (auto p = 0u; p < nprod; p++) {
        // Queue Allocation
        auto pqueues = (prod_queue_t *)utils::zero_aligned_alloc(
            FIPC_CACHE_LINE_SIZE, ncons * sizeof(prod_queue_t));
        all_pqueues[p] = pqueues;
        for (auto c = 0u; c < ncons; c++) {
          prod_queue_t *pq = &pqueues[c];
          pqueue_map.insert({std::make_tuple(p, c), pq});
        }
      }
    }

    void init_cons_queues() {
      // map queues and consumer_metadata
      for (auto c = 0u; c < ncons; c++) {
        auto cqueues = (cons_queue_t *)utils::zero_aligned_alloc(
            FIPC_CACHE_LINE_SIZE, nprod * sizeof(cons_queue_t));
        all_cqueues[c] = cqueues;
        for (auto p = 0u; p < nprod; p++) {
          cons_queue_t *cq = &cqueues[p];
          cqueue_map.insert({std::make_tuple(p, c), cq});
        }
      }
    }

    void init_data() {
      for (auto p = 0u; p < nprod; p++) {
        for (auto c = 0u; c < ncons; c++) {
          data_t *data =
            (data_t *)utils::zero_aligned_alloc(4096, this->queue_size * sizeof(data_t));

          auto it = pqueue_map.find(std::make_tuple(p, c));
          if (it != pqueue_map.end()) {
            prod_queue_t *pq = pqueue_map.at(std::make_tuple(p, c));
            cons_queue_t *cq = cqueue_map.at(std::make_tuple(p, c));
            pq->data = cq->data = data;
          } else {
            for (auto &e : pqueue_map) {
              auto &[p, c] = e.first;
              PLOGI.printf("p %u c %u pq %p", p, c, e.second);
            }
            exit(-1);
          }
        }
      }
    }

    void teardown_all_queues() {
      for (auto p = 0u; p < nprod; p++) {
        free(this->all_pqueues[p]);
      }

      for (auto c = 0u; c < ncons; c++) {
        auto cq = this->all_cqueues[c];
        free(cq->data);
        free(cq);
      }
    }


  public:
    explicit BQueueAligned(uint32_t nprod, uint32_t ncons, size_t queue_size) {
      assert((queue_size & (queue_size - 1)) == 0);
      this->queue_size = queue_size;
      this->batch_size = this->queue_size / 16;
      this->nprod = nprod;
      this->ncons = ncons;

      this->all_pqueues = (prod_queue_t **)utils::zero_aligned_alloc(
        FIPC_CACHE_LINE_SIZE, nprod * sizeof(prod_queue_t*));

      this->all_cqueues = (cons_queue_t **)utils::zero_aligned_alloc(
        FIPC_CACHE_LINE_SIZE, ncons * sizeof(cons_queue_t*));

      this->init_prod_queues();
      this->init_cons_queues();
      this->init_data();
      this->start_time = clock();
    }

    int enqueue(uint32_t p, uint32_t c, data_t value) {
      auto pq = &this->all_pqueues[p][c];
      uint32_t tmp_head;
      if (pq->head == pq->batch_head) {
        tmp_head = pq->head + this->batch_size;
        if (tmp_head >= this->queue_size) tmp_head = 0;

        if (pq->data[tmp_head]) {
          fipc_test_time_wait_ticks(CONGESTION_PENALTY);
          return RETRY;
        }
        pq->batch_head = tmp_head;
      }

      //printf("enqueuing at pq->head %u | val %lu\n", pq->head, value);
      pq->data[pq->head] = value;
      pq->head = pq->head + 1;
      if (pq->head >= this->queue_size) {
        pq->head = 0;
      }

      return SUCCESS;
    }

    inline void prefetch(uint32_t p, uint32_t c, bool is_prod) {
      if (is_prod) {
        auto pq = &this->all_pqueues[p][c];
        if (((pq->head + 4) & 7) == 0) {
          auto next_1 = (pq->head + 8) & (this->queue_size - 1);
          __builtin_prefetch(&pq->data[next_1], 1, 3);
        }
      } else {
        if (p >= nprod) p = 0;
        auto ncq = &this->all_cqueues[c][p];

        auto next_1 = (ncq->tail + 8) & (queue_size - 1);
        auto next_2 = (ncq->tail + 16) & (queue_size - 1);
        __builtin_prefetch(&ncq->data[ncq->tail], 1, 3);
        __builtin_prefetch(&ncq->data[next_1], 1, 3);
        __builtin_prefetch(&ncq->data[next_2], 1, 3);
      }
    }

    inline int backtracking(cons_queue_t *q) {
      uint32_t tmp_tail;
      tmp_tail = q->tail + this->batch_size - 1;
      if (tmp_tail >= queue_size) {
        tmp_tail = 0;
      }

      unsigned long batch_size = this->batch_size;
#if defined(OPTIMIZE_BACKTRACKING2)
      if ((!q->data[tmp_tail]) && !q->backtrack_flag) {
        fipc_test_time_wait_ticks(CONGESTION_PENALTY);
        return -1;
      }
#endif

      while (!(q->data[tmp_tail])) {
        if (batch_size > 1) {
          batch_size = batch_size >> 1;
          tmp_tail = q->tail + batch_size - 1;
          if (tmp_tail >= queue_size) tmp_tail = 0;
        } else
          return -1;
      }

      if (tmp_tail == q->tail) {
        tmp_tail = (tmp_tail + 1) >= queue_size ? 0 : tmp_tail + 1;
      }
      q->batch_tail = tmp_tail;

      return 0;
    }

    static inline void fipc_test_time_wait_ticks(uint64_t ticks) {
      uint64_t current_time;
      uint64_t time = _rdtsc();
      time += ticks;
      do {
        current_time = _rdtsc();
      } while (current_time < time);
    }

    int dequeue(uint32_t p, uint32_t c, data_t *value) {
      auto cq = &this->all_cqueues[c][p];

      if (cq->tail == cq->batch_tail) {
        if (backtracking(cq) != 0) return RETRY;
      }

      *value = cq->data[cq->tail];
      //printf("dequeuing at cq->head %u | val %lu\n", cq->tail, *value);
      cq->data[cq->tail] = 0;
      cq->tail = cq->tail + 1;
      if (cq->tail >= this->queue_size) cq->tail = 0;

      return SUCCESS;
    }

    void push_done(uint32_t p, uint32_t c) {
      auto pq = &this->all_pqueues[p][c];
      auto cq = &this->all_cqueues[c][p];

      cq->backtrack_flag = 1;

      while (enqueue(p, c, (data_t)BQ_MAGIC_64BIT) != 0)
      ;

    }

    void pop_done(uint32_t p, uint32_t c) { }

    void finalize(uint32_t p, uint32_t c) {
      this->end_time = clock();
      this->queue_time = (double)(end_time - start_time) / (2 * CLOCKS_PER_SEC);

    }

    uint64_t get_time(uint32_t p, uint32_t c) { return this->queue_time; }

    ~BQueueAligned() {
      teardown_all_queues();
    }

};

} // namespace
