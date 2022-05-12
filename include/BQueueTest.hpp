#ifndef __BQUEUE_TEST_HPP__
#define __BQUEUE_TEST_HPP__

#include <thread>

#include "base_kht.hpp"
#include "bqueue.h"
#include "numa.hpp"
#include "types.hpp"

namespace kmercounter {

class BQueueTest {
  std::vector<std::thread> prod_threads;
  std::vector<std::thread> cons_threads;
  std::vector<BaseHashTable *> *ht_vec;
  Shard *shards;
  Configuration *cfg;
  Numa *n;
  NumaPolicyQueues *npq;

  std::vector<numa_node> nodes;
  queue_t ***prod_queues;
  queue_t ***cons_queues;

 public:
  void run_find_test(Configuration *cfg, Numa *n, NumaPolicyQueues *npq);
  void insert_with_bqueues(Configuration *cfg, Numa *n, NumaPolicyQueues *npq);
  void no_bqueues(Shard *sh, BaseHashTable *kmer_ht);
  void run_test(Configuration *cfg, Numa *n, NumaPolicyQueues *npq);
  void producer_thread(int tid, int n_prod, int n_cons, bool main_thread, double skew);
  void consumer_thread(int tid, uint32_t num_nops);
  void find_thread(int tid, int n_prod, int n_cons, bool main_thread);
  void init_queues(uint32_t nprod, uint32_t ncons);
};

}  // namespace kvstore

#endif  // __BQUEUE_TEST_HPP__
