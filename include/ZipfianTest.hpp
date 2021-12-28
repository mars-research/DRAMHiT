#ifndef __ZIPFIAN_TEST_HPP__
#define __ZIPFIAN_TEST_HPP__

#include "base_kht.hpp"
#include "types.hpp"

namespace kvstore {

class ZipfianTest {
 public:
  void run(Shard *sh, BaseHashTable *kmer_ht, double skew, unsigned int count);
};

}  // namespace kvstore

#endif  // __SYNTH_TEST_HPP__