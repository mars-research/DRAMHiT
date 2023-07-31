#ifndef __HASHJOIN_TEST_HPP__
#define __HASHJOIN_TEST_HPP__

#include <barrier>
#include <functional>

#include "hashtables/base_kht.hpp"
#include "types.hpp"

namespace kmercounter {

class HashjoinTest {
 public:
  /// Generate and join two relations.
  void join_relations_generated(Shard *sh, const Configuration &config,
                                BaseHashTable *ht, bool materialize,
                                std::barrier<VoidFn> *barrier);
  /// Load and join two tables from filesystem.
  void join_relations_from_files(Shard *sh, const Configuration &config,
                                 BaseHashTable *ht,
                                 std::barrier<VoidFn> *barrier);
};

}  // namespace kmercounter

#endif  // __HASHJOIN_TEST_HPP__