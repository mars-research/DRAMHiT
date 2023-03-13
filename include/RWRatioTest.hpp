#ifndef __RW_RATIO_TEST_HPP__
#define __RW_RATIO_TEST_HPP__

#include <atomic>
#include <barrier>
#include <vector>

#include "hashtables/base_kht.hpp"
#include "types.hpp"

namespace kmercounter {
class RWRatioTest {
 public:
  void run(Shard& shard, BaseHashTable& hashtable, unsigned int total_ops,
                             std::barrier<std::function<void()>> *sync_barrier);
};
}  // namespace kmercounter

#endif
