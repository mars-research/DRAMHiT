#pragma once

#include <thread>

#include "hashtables/base_kht.hpp"
#include "queues/queue.hpp"
#include "numa.hpp"
#include "types.hpp"

namespace kmercounter {

template <typename T>
class QueueTest {
  std::vector<std::thread> prod_threads;
  std::vector<std::thread> cons_threads;
  std::vector<BaseHashTable *> *ht_vec;
  Shard *shards;
  Configuration *cfg;
  Numa *n;
  NumaPolicyQueues *npq;

  T *queues;

  std::vector<numa_node> nodes;

  uint64_t completed_producers = 0;
  uint64_t completed_consumers = 0;
  uint64_t ready_consumers = 0;
  uint64_t ready_producers = 0;
  uint64_t test_ready = 0;
  uint64_t test_finished = 0;


 public:
  const unsigned _QUEUE_SIZE = (1 << 20);
  static const uint64_t BQ_MAGIC_64BIT = 0xD221A6BE96E04673UL;

  void run_find_test(Configuration *cfg, Numa *n, NumaPolicyQueues *npq);

  void run_test(Configuration *cfg, Numa *n, NumaPolicyQueues *npq);

  void insert_with_queues(Configuration *cfg, Numa *n, NumaPolicyQueues *npq);

  void producer_thread(const uint32_t tid, const uint32_t n_prod,
                       const uint32_t n_cons, const bool main_thread,
                       const double skew);

  void consumer_thread(const uint32_t tid, const uint32_t n_prod,
                       const uint32_t n_cons, const uint32_t num_nops);
  void find_thread(int tid, int n_prod, int n_cons, bool main_thread);

  void init_queues(uint32_t nprod, uint32_t ncons);
};

}  // namespace kmercounter
