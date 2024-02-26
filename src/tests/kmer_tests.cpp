#include <plog/Log.h>

#include <algorithm>
#include <atomic>
#include <barrier>
#include <cstdint>

#include "constants.hpp"
#include "hashtables/base_kht.hpp"
#include "hashtables/batch_runner/batch_runner.hpp"
#include "hashtables/kvtypes.hpp"
#include "input_reader/counter.hpp"
#include "input_reader/fastq.hpp"
#include "print_stats.h"
#include "sync.h"
#include "tests/KmerTest.hpp"
#include "types.hpp"

namespace kmercounter {


void KmerTest::count_kmer(Shard* sh, const Configuration& config,
                          BaseHashTable* ht, std::barrier<VoidFn>* barrier) {
  // Be care of the `K` here; it's a compile time constant.
  auto reader = input_reader::FastqReader(
      config.in_file, sh->shard_idx, config.num_threads);
  HTBatchRunner batch_runner(ht);

  // Wait for all readers finish initializing.
  barrier->arrive_and_wait();

  // start timers
  std::uint64_t start{}, end{};
  std::uint64_t start_cycles{}, end_cycles{};
  std::uint64_t num_kmers{};
  std::chrono::time_point<std::chrono::steady_clock> start_ts, end_ts;
  start = _rdtsc();

  if (sh->shard_idx == 0) {
    start_ts = std::chrono::steady_clock::now();
    start_cycles = _rdtsc();
  }

  string_view sv; 
  const char* data;
  Kmer kmer;
  uint32_t k = config.K;

  while(reader.next(&sv))
  {
    size_t len = sv.size();

    for(int i=0; i<(len-k+1); i++) {
        data = sv.substr(i, k).data();
        kmer = packkmer(data, k); 
        batch_runner.insert(kmer, 0 /* we use the aggr tables so no value */);
        num_kmers++;
    }
  }

  // // Inser Kmers into hashtable
  // for (uint64_t kmer; reader->next(&kmer);) {
  //   batch_runner.insert(kmer, 0 /* we use the aggr tables so no value */);
  //   num_kmers++;
  // }
  batch_runner.flush_insert();
  barrier->arrive_and_wait();

  sh->stats->insertions.duration = _rdtsc() - start;
  sh->stats->insertions.op_count = num_kmers;

  // done; calc stats
  if (sh->shard_idx == 0) {
    end_ts = std::chrono::steady_clock::now();
    end_cycles = _rdtsc();
    PLOG_INFO.printf(
        "Kmer insertion took %llu us (%llu cycles)",
        chrono::duration_cast<chrono::microseconds>(end_ts - start_ts).count(),
        end_cycles - start_cycles);
  }
  PLOGV.printf("[%d] Num kmers %llu", sh->shard_idx, num_kmers);

  get_ht_stats(sh, ht);
}

}  // namespace kmercounter