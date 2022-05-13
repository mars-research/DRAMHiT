#ifndef __HASHJOIN_TEST_HPP__
#define __HASHJOIN_TEST_HPP__

#include <barrier>

#include "hashtables/base_kht.hpp"
#include "types.hpp"

namespace kmercounter {

class HashjoinTest {
 public:
  void part_join_partsupp(const Shard &sh, const Configuration &config,
                          BaseHashTable *ht, std::barrier<> *barrier);
};

}  // namespace kmercounter

#endif  // __HASHJOIN_TEST_HPP__