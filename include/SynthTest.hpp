#ifndef __SYNTH_TEST_HPP__
#define __SYNTH_TEST_HPP__

#include "base_kht.hpp"
#include "types.hpp"

namespace kvstore {

class SynthTest {
 public:
  void synth_run_exec(Shard *sh, BaseHashTable *kmer_ht);
  OpTimings synth_run(BaseHashTable *ktable, uint8_t start);
  OpTimings synth_run_get(BaseHashTable *ktable, uint8_t start);
};

}  // namespace kvstore

#endif  // __SYNTH_TEST_HPP__
