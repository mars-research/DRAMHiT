#ifndef TESTS_KMERTEST_HPP
#define TESTS_KMERTEST_HPP

#include <barrier>
#include <memory>

#include "hashtables/base_kht.hpp"
#include "input_reader/fastq.hpp"
#include "types.hpp"

namespace kmercounter {

class KmerTest {
//  private:
//   Kmer packkmer(const char* s, int k);
//   uint64_t radix_partition(RadixContext* context,
//                            BufferedPartition** local_partitions,
//                            int id, int k);

 public:
  void count_kmer(Shard* sh, const Configuration& config, BaseHashTable* ht,
                  std::barrier<VoidFn>* barrier);

  void count_kmer_radix_partition_global(Shard* sh, const Configuration& config,
                                         std::barrier<VoidFn>* barrier,
                                         RadixContext* context,
                                         BaseHashTable* ht);

  void count_kmer_baseline(Shard* sh, const Configuration& config,
                           std::barrier<VoidFn>* barrier, BaseHashTable* ht);
};

}  // namespace kmercounter

#endif  // TESTS_KMERTEST_HPP
