#ifndef TESTS_KMERTEST_HPP
#define TESTS_KMERTEST_HPP

#include "hashtables/base_kht.hpp"
#include "types.hpp"

namespace kmercounter {

class KmerTest {
 public:
  static OpTimings shard_thread(Shard *sh, const Configuration &cfg, BaseHashTable *kmer_ht, bool insert);
};

}  // namespace kmercounter

#endif // TESTS_KMERTEST_HPP
