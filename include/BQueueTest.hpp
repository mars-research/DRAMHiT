#ifndef __BQUEUE_TEST_HPP__
#define __BQUEUE_TEST_HPP__

#include "types.hpp"
#include "bqueue.h"
#include <thread>
#include "base_kht.hpp"
#include "numa.hpp"

namespace kmercounter {

class BQueueTest {
  std::thread *prod_threads;
  std::thread *cons_threads;
  Shard *shards;
  Configuration *cfg;
  Numa *n;
  NumaPolicyQueues *npq;

  std::vector<numa_node> nodes;
  queue_t*** prod_queues;
  queue_t*** cons_queues;

 public:
  void no_bqueues(Shard *sh, KmerHashTable *kmer_ht);
  void run_test(Configuration *cfg, Numa *n, NumaPolicyQueues *npq);
  void producer_thread(int tid);
  void consumer_thread(int tid);
  void init_queues(uint32_t nprod, uint32_t ncons);
};

}  // namespace kmercounter

#endif  // __BQUEUE_TEST_HPP__
