#ifndef __RW_RATIO_TEST_HPP__
#define __RW_RATIO_TEST_HPP__

#include <atomic>
#include <vector>

#include "base_kht.hpp"
#include "types.hpp"

namespace kmercounter {
class RWRatioTest {
 public:
  void run(Shard& shard, BaseHashTable& hashtable, unsigned int total_ops);

 private:
  std::atomic_uint16_t next_producer{};
  std::atomic_uint16_t next_consumer{};
  std::atomic_bool start{};
  std::atomic_uint16_t ready{};
};
}  // namespace kmercounter

#endif
