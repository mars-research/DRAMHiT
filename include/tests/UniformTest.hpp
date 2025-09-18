#ifndef __UNIFORM_TEST_HPP__
#define __UNIFORM_TEST_HPP__

#include <barrier>
#include "hashtables/base_kht.hpp"
#include "types.hpp"
#include "hashtables/cas_kht.hpp"
#include "print_stats.h"
namespace kmercounter {

class UniformTest {
 public:
  void run(Shard *sh, BaseHashTable *kmer_ht, std::barrier<std::function<void ()>>*);
};

}  // namespace kmercounter

#endif 