#ifndef __HASHJOIN_TEST_HPP__
#define __HASHJOIN_TEST_HPP__

#include <barrier>
#include <functional>

#include "hashtables/base_kht.hpp"
#include "types.hpp"

namespace kmercounter {

class HashjoinTest {
 public:
  void part_join_partsupp(const Shard &sh, const Configuration &config,
                          BaseHashTable *ht, std::barrier<> *barrier);
  void join_r_s(Shard *sh, const Configuration &config, BaseHashTable *ht,
                std::barrier<std::function<void()>> *barrier);
};

}  // namespace kmercounter

#endif  // __HASHJOIN_TEST_HPP__