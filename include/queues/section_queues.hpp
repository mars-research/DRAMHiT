#pragma once

#include "queue.hpp"
#include <tuple>
#include <map>
#include <assert.h>

class SectionQueue {
  private:
    size_t num_sections;
    size_t queue_size;
    size_t section_size;

    struct prod_queue_t {
      data_t *enqPtr;
      data_t *deqLocalPtr;
      data_t *data;
    };

    struct cons_queue_t {
      data_t *deqPtr;
      data_t *enqLocalPtr;

      CACHE_ALIGNED data_t *enqSharedPtr;
      data_t *deqSharedPtr;

      CACHE_ALIGNED size_t ROTATE_MASK;
      size_t SECTION_MASK;
      bool backtrack_flag;

      CACHE_ALIGNED size_t numEnqueues;
      CACHE_ALIGNED size_t numDequeues;

      CACHE_ALIGNED data_t *data;
    };

    std::map<std::tuple<int, int>, prod_queue_t*> pqueue_map;
    std::map<std::tuple<int, int>, cons_queue_t*> cqueue_map;

    prod_queue_t **all_pqueues;
    cons_queue_t **all_cqueues;
    int nprod;
    int ncons;

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
          data_array_t *data_array =
            (data_array_t *)utils::zero_aligned_alloc(4096, sizeof(data_array_t));

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

            cq->ROTATE_MASK = (size_t)data + (this->queue_size * sizeof(data_t) - 1);
            cq->SECTION_MASK = (this->section_size * sizeof(data_t) - 1);
            PLOG_INFO.printf("enqPtr %p | deqPtr %p | data %p | rotate_mask %lx | section_mask %lx",
                pq->enqPtr, cq->deqPtr, cq->data, cq->ROTATE_MASK, cq->SECTION_MASK);


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
    SectionQueue(int nprod, int ncons, size_t num_sections) {
      assert(num_sections & (num_sections - 1) == 0);
      this->queue_size = 8192 * this->num_sections;
      this->section_size = this->queue_size / this->num_sections;
      this->nprod = nprod;
      this->ncons = ncons;

      this->all_pqueues = (prod_queue_t **)utils::zero_aligned_alloc(
        FIPC_CACHE_LINE_SIZE, nprod * sizeof(prod_queue_t));

      this->all_cqueues = (cons_queue_t **)utils::zero_aligned_alloc(
        FIPC_CACHE_LINE_SIZE, ncons * sizeof(cons_queue_t));

    }

    int enqueue(int p, int c, data_t value) override {
      auto pq = &this->all_pqueues[p][c];
      auto cq = &this->all_cqueues[c][p];

      *pq->enqPtr = value;
      //this->numEnqueues++;
      PLOG_DEBUG.printf("enqueueing %lu at %p", value, this->enqPtr);
      pq->enqPtr += 1;
      if (pq->enqPtr > (pq->data + this->queue_size)) {
        pq->enqPtr = pq->data;
      }
      //PLOG_DEBUG.printf("moving pq->enqPtr %p", pq->enqPtr);

      if (((data_t)pq->enqPtr & cq->SECTION_MASK) == 0) {
        while (pq->enqPtr == pq->deqLocalPtr) {
          PLOG_DEBUG.printf("waiting for section lock");
          pq->deqLocalPtr = cq->deqSharedPtr;
        }
        cq->enqSharedPtr = pq->enqPtr;
      }
      return SUCCESS;
    }

    int dequeue(int p, int c, data_t *value) override {
      // sync
      auto cq = &this->all_cqueues[c][p];
      auto pq = &this->all_pqueues[p][c];

      PLOG_DEBUG.printf("cq->deqPtr %p | mask %lx | & %lx", cq->deqPtr,
          cq->SECTION_MASK, (data_t) cq->deqPtr & (this->section_size *
            sizeof(data_t) - 1));
      if (((data_t)cq->deqPtr & cq->SECTION_MASK) == 0) {
        cq->deqSharedPtr = cq->deqPtr;
        while (cq->deqPtr == cq->enqLocalPtr) {
          cq->enqLocalPtr = cq->enqSharedPtr;
          PLOG_DEBUG.printf("waiting for section lock");
          if (cq->backtrack_flag) {
            // producer is done. it's ok to read the section
            PLOG_INFO.printf("producer is done!");
            break;
          }
        }
      }

      PLOG_DEBUG.printf("cq->deqPtr %p", cq->deqPtr);
      *value = *((data_t *) cq->deqPtr);
      *((data_t *) cq->deqPtr) = 0;
      //cq->numDequeues++;
      cq->deqPtr += 1;
      if (cq->deqPtr > (cq->data + this->queue_size)) {
        cq->deqPtr = cq->data;
      }

      return SUCCESS;
    }

    ~SectionQueue() {
      teardown_prod_queues();
      teardown_cons_queues();
    }
};
