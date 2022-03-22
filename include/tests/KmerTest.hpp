#ifndef TESTS_KMERTEST_HPP
#define TESTS_KMERTEST_HPP

#include <memory>

#include "hashtables/base_kht.hpp"
#include "types.hpp"
#include "input_reader/fastq.hpp"

namespace kmercounter {

class KmerTest {
 public:
  static OpTimings shard_thread(Shard *sh, const Configuration &cfg, BaseHashTable *kmer_ht, bool insert, input_reader::FastqKMerPreloadReader<KMER_LEN> reader);
};

}  // namespace kmercounter

#endif // TESTS_KMERTEST_HPP
