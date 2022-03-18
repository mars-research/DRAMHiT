#ifndef TESTS_KMERTEST_HPP
#define TESTS_KMERTEST_HPP

#include <memory>

#include "hashtables/base_kht.hpp"
#include "types.hpp"
#include "input_reader/fastq.hpp"

namespace kmercounter {

constexpr size_t K = 32;
class KmerTest {
 public:
  static OpTimings shard_thread(Shard *sh, const Configuration &cfg, BaseHashTable *kmer_ht, bool insert, input_reader::FastqKMerPreloadReader<K> reader);
};

}  // namespace kmercounter

#endif // TESTS_KMERTEST_HPP
