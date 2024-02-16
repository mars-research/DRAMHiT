#ifndef TESTS_KMERTEST_HPP
#define TESTS_KMERTEST_HPP

#include <barrier>
#include <memory>

#include "hashtables/base_kht.hpp"
#include "input_reader/fastq.hpp"
#include "types.hpp"


namespace kmercounter {

class KmerTest {
 public:
  void count_kmer(Shard *sh, const Configuration &config, BaseHashTable *ht,
                  std::barrier<VoidFn> *barrier);

  void count_kmer_radix(Shard *sh, const Configuration &config,
                        std::barrier<VoidFn> *barrier, RadixContext &context);
                        
  void count_kmer_radix_custom(Shard *sh, const Configuration &config,
                               std::barrier<VoidFn> *barrier,
                               RadixContext &context);

  void count_kmer_radix_jerry(Shard *sh, const Configuration &config,
                              std::barrier<VoidFn> *barrier,
                               RadixContext &context, BaseHashTable *ht);
};

}  // namespace kmercounter

#endif  // TESTS_KMERTEST_HPP
