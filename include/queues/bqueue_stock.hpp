#pragma once

class BQueueStock {
  private:
    size_t batch_size;
    size_t queue_size;

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

    queue_t **queues;
    int nprod;
    int ncons;

    void teardown_all_queues() {
      for (auto p = 0u; p < nprod; p++) {
        std::aligned_free(this->queues);
      }
    }

  public:

    explicit BQueueStock(int prod, int cons, size_t queue_size) {
      assert(queue_size & (queue_size - 1) == 0);
      this->queue_size = queue_size;
      this->bactch_size = this->queue_size / 16;
      this->nprod = nprod;
      this->ncons = ncons;

      this->queues = (queue_t **)utils::zero_aligned_alloc(
        FIPC_CACHE_LINE_SIZE, nprod * ncons * sizeof(queue_t*));

      for (auto c = 0u; c < ncons; c++) {
        for (auto p = 0u; p < nprod; p++) {
          queue_t *q = (queue_t *)utils::zero_aligned_alloc(
              FIPC_CACHE_LINE_SIZE, sizeof(queue_t));
          queue_map.insert({std::make_tuple(p, c), q});
        }
      }
      for (auto &e : queue_map) {
        auto &[p, c] = e.first;
        PLOGI.printf("p %u c %u pq %p", p, c, e.second);
      }
    }

    int enqueue(int p, int c, data_t value) override {
      auto q = &queues[p][c];
      uint32_t tmp_head;
      if (q->head == q->batch_head) {
        tmp_head = q->head + PROD_BATCH_SIZE;
        if (tmp_head >= QUEUE_SIZE) tmp_head = 0;

        if (q->data[tmp_head]) {
          fipc_test_time_wait_ticks(CONGESTION_PENALTY);
          return BUFFER_FULL;
        }

        q->batch_head = tmp_head;
      }
      q->data[q->head] = value;
      q->head++;
      if (q->head >= QUEUE_SIZE) {
        q->head = 0;
      }

      return SUCCESS;
    }

    int dequeue(int p, int c, data_t *value) override {
      auto cq = this->all_cqueues[c][p];

      return SUCCESS;
    }

    ~BQueueStock() {
      teardown_all_queues();
    }
};
