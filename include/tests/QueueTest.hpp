#pragma once

#include <barrier>
#include <thread>

#include "hashtables/base_kht.hpp"
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

  uint64_t QUEUE_SIZE = 0;

 public:
  const unsigned LYNX_QUEUE_SIZE = (1 << 12) * 8;
  const unsigned BQ_QUEUE_SIZE = 4096;
  static const uint64_t BQ_MAGIC_64BIT = 0xD221A6BE96E04673UL;

  void run_find_test(Configuration *cfg, Numa *n, bool is_join, NumaPolicyQueues *npq);

  void run_test(Configuration *cfg, Numa *n, bool, NumaPolicyQueues *npq);

  void insert_with_queues(Configuration *cfg, Numa *n, bool is_join, NumaPolicyQueues *npq);

  void producer_thread(const uint32_t tid, const uint32_t n_prod,
                       const uint32_t n_cons, const bool main_thread,
                       const double skew,
                       bool is_join,
                       std::barrier<std::function<void()>>* barrier
                       );

  void consumer_thread(const uint32_t tid, const uint32_t n_prod,
                       const uint32_t n_cons, const uint32_t num_nops,
                       std::barrier<std::function<void()>>* barrier
                       );
  void find_thread(int tid, int n_prod, int n_cons,
                       bool is_join,
                       std::barrier<std::function<void()>>* barrier);

  void init_queues(uint32_t nprod, uint32_t ncons);
};

}  // namespace kmercounter
