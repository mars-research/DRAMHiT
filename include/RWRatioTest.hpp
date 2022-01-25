#ifndef __RW_RATIO_TEST_HPP__
#define __RW_RATIO_TEST_HPP__

#include <atomic>
#include <vector>

#include "base_kht.hpp"
#include "bqueue.h"
#include "numa.hpp"
#include "types.hpp"

namespace kmercounter {
class RWRatioTest {
 public:
  void run(Shard& shard, BaseHashTable& hashtable, double reads_per_write,
           unsigned int total_ops, unsigned int n_consumers);

 private:
  std::atomic_uint16_t next_producer{};
  std::atomic_uint16_t next_consumer{};
  std::atomic_bool start{};
  std::atomic_uint16_t ready{};
  std::vector<std::vector<data_array_t>> data_arrays{};
  std::vector<std::vector<prod_queue_t>> producer_queues{};
  std::vector<std::vector<cons_queue_t>> consumer_queues{};

  void init_queues(unsigned int n_clients, unsigned int n_writers);
};
}  // namespace kmercounter

#endif
