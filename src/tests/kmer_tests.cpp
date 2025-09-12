#include "tests/KmerTest.hpp"

#include <algorithm>
#include <atomic>
#include <barrier>
#include <cstdint>
#include <plog/Log.h>

#include "constants.hpp"
#include "hashtables/base_kht.hpp"
#include "hashtables/batch_runner/batch_runner.hpp"
#include "hashtables/kvtypes.hpp"
#include "sync.h"
#include "input_reader/fastq.hpp"
#include "input_reader/counter.hpp"
#include "types.hpp"
#include "print_stats.h"

namespace kmercounter {
void KmerTest::count_kmer(Shard* sh,
                              const Configuration& config,
                              BaseHashTable* ht,
                              std::barrier<VoidFn>* barrier){
  uint64_t num_kmers = 0;
  // Be care of the `K` here; it's a compile time constant.
  auto reader = input_reader::MakeFastqKMerPreloadReader(config.K, config.in_file, sh->shard_idx, config.num_threads);
  HTBatchRunner batch_runner(ht);

  barrier->arrive_and_wait();
  for (uint64_t kmer; reader->next(&kmer);) {
    batch_runner.insert(kmer, 0 /* we use the aggr tables so no value */);
    num_kmers++;
  }
  batch_runner.flush_insert();
  barrier->arrive_and_wait();

  get_ht_stats(sh, ht);
}

} // namespace kmercounter