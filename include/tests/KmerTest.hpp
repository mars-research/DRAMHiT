#ifndef TESTS_KMERTEST_HPP
#define TESTS_KMERTEST_HPP

#include <barrier>
#include <memory>

#include "hashtables/base_kht.hpp"
#include "types.hpp"
#include "input_reader/fastq.hpp"

namespace kmercounter {

class KmerTest {
 public:
  void count_kmer(Shard *sh, const Configuration &config,
                  BaseHashTable *ht,
                  std::barrier<VoidFn> *barrier);
};

}  // namespace kmercounter

#endif // TESTS_KMERTEST_HPP
