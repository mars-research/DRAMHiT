#ifndef __RW_RATIO_TEST_HPP__
#define __RW_RATIO_TEST_HPP__

#include "base_kht.hpp"
#include "types.hpp"

namespace kmercounter {
class RWRatioTest {
 public:
  void run(Shard& shard, BaseHashTable& hashtable, double reads_per_write,
           unsigned int total_ops, unsigned int bq_writer_count);
};
}  // namespace kmercounter

#endif
