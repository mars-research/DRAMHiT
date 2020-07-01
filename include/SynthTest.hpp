#ifndef __SYNTH_TEST_HPP__
#define __SYNTH_TEST_HPP__

#include "types.hpp"
#include "base_kht.hpp"

namespace kmercounter {

class SynthTest {
 public:
  void synth_run_exec(Shard *sh, KmerHashTable *kmer_ht);
  uint64_t synth_run(KmerHashTable *ktable);
};

}  // namespace kmercounter

#endif  // __SYNTH_TEST_HPP__
