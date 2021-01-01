#ifndef __SYNTH_TEST_HPP__
#define __SYNTH_TEST_HPP__

#include "base_kht.hpp"
#include "types.hpp"

namespace kmercounter {

class SynthTest {
 public:
  void synth_run_exec(Shard *sh, BaseHashTable *kmer_ht);
  uint64_t synth_run(BaseHashTable *ktable, uint8_t);
  uint64_t synth_run_thrd(BaseHashTable *ktable, uint8_t);
};

}  // namespace kmercounter

#endif  // __SYNTH_TEST_HPP__
