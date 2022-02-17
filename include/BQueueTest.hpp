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
  std::vector<BaseHashTable *> ht_vec;
  Shard *shards;
  Configuration *cfg;
  Numa *n;
  NumaPolicyQueues *npq;

  std::vector<numa_node> nodes;
#ifdef CONFIG_ALIGN_BQUEUE_METADATA
  std::map<std::tuple<int, int>, prod_queue_t *> pqueue_map;
  std::map<std::tuple<int, int>, cons_queue_t *> cqueue_map;
#else
  std::map<std::tuple<int, int>, queue_t *> queue_map;
#endif

 public:
  void run_find_test(Configuration *cfg, Numa *n, NumaPolicyQueues *npq);
  void insert_with_bqueues(Configuration *cfg, Numa *n, NumaPolicyQueues *npq);
  void no_bqueues(Shard *sh, BaseHashTable *kmer_ht);
  void run_test(Configuration *cfg, Numa *n, NumaPolicyQueues *npq);
  void producer_thread(const uint32_t tid, const uint32_t n_prod,
                       const uint32_t n_cons, const bool main_thread,
                       const double skew);

  void consumer_thread(const uint32_t tid, const uint32_t n_prod,
                       const uint32_t n_cons, const uint32_t num_nops);

  void consumer_thread_main(uint64_t cons_id, BaseHashTable &kmer_ht,
                            Shard &shard,
                            const std::vector<cons_queue_t *> &queues,
                            const uint32_t n_prod, const uint32_t n_cons,
                            const uint32_t num_nops, bool last_test);
                            
  void find_thread(int tid, int n_prod, int n_cons, bool main_thread);
  void init_queues(uint32_t nprod, uint32_t ncons);
};

}  // namespace kmercounter

#endif  // __BQUEUE_TEST_HPP__
