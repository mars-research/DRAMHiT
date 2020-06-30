#ifndef __PREFETCH_TEST_HPP__
#define __PREFETCH_TEST_HPP__

#include "types.hpp"
#include "hashtables/simple_kht.hpp"

namespace kmercounter {

class PrefetchTest {
 public:
  void prefetch_test_run_exec(__shard *sh, KmerHashTable *kmer_ht);
  uint64_t prefetch_test_run(SimpleKmerHashTable *ktable);
};

}  // namespace kmercounter

#endif  // __PREFETCH_TEST_HPP__
