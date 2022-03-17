#pragma once

#include "queue.hpp"
#include <tuple>
#include <map>
#include <assert.h>

namespace kmercounter {

class SectionQueue;

static const uint64_t SECTION_SIZE = 4096 * 2;

struct SectionQueueInner {
    struct prod_queue {
      CACHE_ALIGNED data_t *enqPtr;
      data_t * volatile deqLocalPtr;
      data_t *data;
      data_t *queue_end;
    };

    struct cons_queue {
      CACHE_ALIGNED data_t *deqPtr;
      data_t * volatile enqLocalPtr;
      data_t *data;
      bool pop_done;

      CACHE_ALIGNED data_t *queue_end;

      CACHE_ALIGNED data_t * volatile enqSharedPtr;
      //CACHE_ALIGNED data_t * volatile deqSharedPtr;
      data_t * volatile deqSharedPtr;

      //CACHE_ALIGNED size_t numEnqueueSpins;
      //CACHE_ALIGNED size_t numDequeueSpins;
    };

    data_t *QUEUE;
    data_t *QUEUE_END;
    size_t num_sections;
    size_t queue_size;
    size_t section_size;
    struct prod_queue *pq;
    struct cons_queue *cq;

    void dump(void) {
      PLOGI.printf("{ prod state }");
      PLOGI.printf("enqPtr:          %p", pq->enqPtr);
      PLOGI.printf("deqLocalPtr:       %p", pq->deqLocalPtr);

      PLOGI.printf("{ cons state }");
      PLOGI.printf("deqPtr:          %p", cq->deqPtr);
      PLOGI.printf("enqLocalPtr:       %p", cq->enqLocalPtr);
      PLOGI.printf("enqSharedPtr:       %p", cq->enqSharedPtr);
      PLOGI.printf("deqSharedPtr:    %p", cq->deqSharedPtr);

      PLOGI.printf("QUEUE:      %p", QUEUE);
      PLOGI.printf("QUEUE_END:      %p", QUEUE_END);
      PLOGI.printf("queue_size:     0x%lx", queue_size);
      PLOGI.printf("queue_mask:     0x%lx", ~queue_size);
      PLOGI.printf("QUEUE_SECTION_SIZE:  0x%lx", section_size);
    }

    explicit SectionQueueInner(size_t queue_size, struct prod_queue *pq, struct cons_queue *cq) {
      this->queue_size = queue_size;
      this->QUEUE = pq->data;
      this->QUEUE_END = pq->data + queue_size / sizeof(data_t);
      cq->queue_end = pq->queue_end = this->QUEUE_END;
      this->section_size = kmercounter::SECTION_SIZE;
      this->num_sections = this->queue_size / this->section_size;
      this->pq = pq;
      this->cq = cq;
    }
};

class SectionQueue {
  public:
    typedef struct SectionQueueInner queue_t;
    typedef struct SectionQueueInner::prod_queue prod_queue_t;
    typedef struct SectionQueueInner::cons_queue cons_queue_t;

    prod_queue_t **all_pqueues;
    cons_queue_t **all_cqueues;
    static const uint64_t BQ_MAGIC_64BIT = 0xD221A6BE96E04673UL;
    static const uint64_t SECTION_MASK = SECTION_SIZE - 1;

  private:
    size_t num_sections;
    size_t queue_size;
    size_t section_size;
    uint32_t nprod;
    uint32_t ncons;

    std::map<std::tuple<int, int>, prod_queue_t*> pqueue_map;
    std::map<std::tuple<int, int>, cons_queue_t*> cqueue_map;
    queue_t ***queues;

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
            (data_t *)utils::zero_aligned_alloc(queue_size << 1, this->queue_size);// * sizeof(data_t));
            //(data_t *)utils::zero_aligned_alloc(queue_size << 1, this->queue_size * sizeof(data_t));
            //(data_t *)utils::zero_aligned_alloc((queue_size * sizeof(data_t)) << 1, this->queue_size * sizeof(data_t));

          auto it = pqueue_map.find(std::make_tuple(p, c));
          if (it != pqueue_map.end()) {
            prod_queue_t *pq = pqueue_map.at(std::make_tuple(p, c));
            cons_queue_t *cq = cqueue_map.at(std::make_tuple(p, c));
            pq->data = cq->data = data;
            pq->enqPtr = pq->data;
            pq->deqLocalPtr = data;

            cq->enqLocalPtr = data;
            cq->enqSharedPtr = data;

            cq->deqPtr = data;
            cq->deqSharedPtr = data;

            //cq->ROTATE_MASK = (size_t)data + (this->queue_size * sizeof(data_t) - 1);
            //cq->SECTION_MASK = this->section_size - 1;
            PLOG_INFO.printf("enqPtr %p | deqPtr %p | data %p | section_mask %lx",
                pq->enqPtr, cq->deqPtr, cq->data, SECTION_MASK);
                //pq->enqPtr, cq->deqPtr, cq->data, cq->ROTATE_MASK, cq->SECTION_MASK);


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

    void teardown_prod_queues() {
      for (auto p = 0u; p < nprod; p++) {
        free(this->all_pqueues[p]);
      }
    }
    void teardown_cons_queues() {
      for (auto c = 0u; c < ncons; c++) {
        auto cq = this->all_cqueues[c];
        free(cq->data);
      }
    }

  public:
    explicit SectionQueue(int nprod, int ncons, size_t num_sections) {
      printf("%s, numsections %zu\n", __func__, num_sections);
      assert((num_sections & (num_sections - 1)) == 0);
      this->num_sections = num_sections;

      this->queue_size = SECTION_SIZE * this->num_sections;
      this->section_size = this->queue_size / this->num_sections;
      this->nprod = nprod;
      this->ncons = ncons;

      this->all_pqueues = (prod_queue_t **)utils::zero_aligned_alloc(
        FIPC_CACHE_LINE_SIZE, nprod * sizeof(prod_queue_t));

      this->all_cqueues = (cons_queue_t **)utils::zero_aligned_alloc(
        FIPC_CACHE_LINE_SIZE, ncons * sizeof(cons_queue_t));

      this->init_prod_queues();
      this->init_cons_queues();
      this->init_data();

      this->queues = (queue_t ***)calloc(1, nprod * sizeof(queue_t*));
      for (auto p = 0u; p < nprod; p++) {
        //this->queues[p] = (queue_t **)aligned_alloc(
        //    FIPC_CACHE_LINE_SIZE, ncons * sizeof(queue_t*));
        this->queues[p] = (queue_t **)calloc(1, ncons * sizeof(queue_t*));
        printf("allocating %zu bytes %p\n", ncons * sizeof(queue_t*), this->queues[p]);
        for (auto c = 0u; c < ncons; c++) {
          printf("%s, &queues[%d][%d] %p\n", __func__, p, c, &queues[p][c]);
          prod_queue_t *pq = pqueue_map.at(std::make_tuple(p, c));
          cons_queue_t *cq = cqueue_map.at(std::make_tuple(p, c));
          queues[p][c] = new queue_t(queue_size, pq, cq);
        }
      }
      queues[0][0]->dump();

    }

    int enqueue(uint32_t p, uint32_t c, data_t value) {
      auto pq = &this->all_pqueues[p][c];

      *pq->enqPtr = value;
      pq->enqPtr += 1;

      if (((data_t)pq->enqPtr & SECTION_MASK) == 0) {

        if (pq->enqPtr == pq->queue_end) {
          pq->enqPtr = pq->data;
        }

        auto cq = &this->all_cqueues[c][p];
        while (pq->enqPtr == pq->deqLocalPtr) {
          pq->deqLocalPtr = cq->deqSharedPtr;
          //pq->numEnqueueSpins++;
          //asm volatile("" ::: "memory");
          asm volatile("pause");
        }

        cq->enqSharedPtr = pq->enqPtr;
      }
      return SUCCESS;
    }

    int dequeue(uint32_t p, uint32_t c, data_t *value) {
      auto cq = &this->all_cqueues[c][p];

      if ((((data_t)cq->deqPtr & SECTION_MASK) == 0) || (cq->pop_done)) {
        if (cq->pop_done) {
          return -2;
        }

        if (cq->deqPtr == cq->queue_end) {
          cq->deqPtr = cq->data;
        }

        cq->deqSharedPtr = cq->deqPtr;
        while (cq->deqPtr == cq->enqLocalPtr) {
          cq->enqLocalPtr = cq->enqSharedPtr;
          /*if (cq->enqLocalPtr == (data_t*) 0xdeadbeef) {
            cq->numDequeueSpins++;
          }*/
          asm volatile("pause");
        }
      }
      *value = *((data_t *) cq->deqPtr);
      //cq->numDequeues++;
      cq->deqPtr += 1;

      return SUCCESS;
    }

    void dump_stats(uint32_t p, uint32_t c) {
      auto cq = &all_cqueues[c][p];
      //printf("[%u][%u] numdequeue spins %lu | enqLocalPtr %p\n", p, c, cq->numDequeueSpins, cq->enqLocalPtr);
    }
#define CACHELINE_SIZE  64
#define CACHELINE_MASK (CACHELINE_SIZE - 1)
    inline void prefetch(uint32_t p, uint32_t c, bool is_prod)  {
      if (is_prod) {
        auto pq = &all_pqueues[p][c];
        if (((uint64_t)pq->enqPtr & CACHELINE_MASK) == 0) {
          __builtin_prefetch(pq->enqPtr + 8, 1, 3);
        }
      } else {
        auto np = ((p + 1) >= nprod) ? 0 : (p + 1);
        auto np1 = ((np + 1) >= nprod) ? 0 : (np + 1);
        auto cq = &all_cqueues[c][np];
        __builtin_prefetch(cq, 1, 3);

        auto cq1 = &all_cqueues[c][np1];
        auto addr = cq1->deqPtr;
        __builtin_prefetch(addr +  0, 1, 3);
        __builtin_prefetch(addr +  8, 1, 3);
      }
    }

    inline void push_done(uint32_t p, uint32_t c) {
      //PLOGD.printf("PUSH DONE");
      auto cq = &this->all_cqueues[c][p];
      enqueue(p, c, BQ_MAGIC_64BIT);
      cq->enqSharedPtr = (data_t*)0xdeadbeef;
    }

    void pop_done(uint32_t p, uint32_t c) {
      auto cq = &this->all_cqueues[c][p];
      cq->pop_done = true;
    }

    ~SectionQueue() {
      teardown_prod_queues();
      teardown_cons_queues();
    }
};
}
