#ifndef __ZIPFIAN_TEST_HPP__
#define __ZIPFIAN_TEST_HPP__

#include <barrier>
#include "hashtables/base_kht.hpp"
#include "types.hpp"

namespace kmercounter {

class ZipfianTest {
 public:
  void run(Shard *sh, BaseHashTable *kmer_ht, double skew, unsigned int count, std::barrier<std::function<void ()>>*);
};

}  // namespace kmercounter

#endif  // __SYNTH_TEST_HPP__
