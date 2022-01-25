#ifndef __RW_RATIO_TEST_HPP__
#define __RW_RATIO_TEST_HPP__

#include <atomic>
#include <vector>

#include "base_kht.hpp"
#include "bqueue.h"
#include "types.hpp"

namespace kmercounter {
class RWRatioTest {
 public:
  void run(Shard& shard, BaseHashTable& hashtable, double reads_per_write,
           unsigned int total_ops, unsigned int n_consumers,
           unsigned int n_threads);

 private:
  std::atomic_bool start{};
  std::atomic_uint16_t ready{};
  std::vector<data_array_t> data_arrays{};
  std::vector<prod_queue_t> producer_queues{};
  std::vector<cons_queue_t> consumer_queues{};

  void init_queues(unsigned int n_clients, unsigned int n_writers);
};
}  // namespace kmercounter

#endif
