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
  // Be care of the `K` here; it's a compile time constant.
  auto reader = input_reader::MakeFastqKMerPreloadReader(config.K, config.in_file, sh->shard_idx, config.num_threads);
  HTBatchRunner batch_runner(ht);

  // Wait for all readers finish initializing.
  barrier->arrive_and_wait();

  // start timers
  std::uint64_t start {}, end {};
  std::chrono::time_point<std::chrono::steady_clock> start_ts, end_ts;
  if (sh->shard_idx == 0) {
    start = _rdtsc();
    start_ts = std::chrono::steady_clock::now();
  }

  // Inser Kmers into hashtable
  for (uint64_t kmer; reader->next(&kmer);) {
    batch_runner.insert(kmer, 0 /* we use the aggr tables so no value */);
  }
  batch_runner.flush_insert();
  barrier->arrive_and_wait();

  // done; calc stats
  if (sh->shard_idx == 0) {
    end = _rdtsc();
    end_ts = std::chrono::steady_clock::now();
    PLOG_INFO.printf("Kmer insertion took %llu us (%llu cycles)",
        chrono::duration_cast<chrono::microseconds>(end_ts - start_ts).count(),
        end - start);
  }
}

} // namespace kmercounter