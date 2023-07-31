#include <algorithm>
#include <cstdint>
#include <thread>

#include "batch_inserter.hpp"
#include "constants.hpp"
#include "hashtables/base_kht.hpp"
#include "hashtables/kvtypes.hpp"
#include "plog/Log.h"
#include "print_stats.h"
#include "sync.h"
#include "tests/SynthTest.hpp"
#include "utils/profiler.hpp"

namespace kmercounter {

extern Configuration config;
extern uint64_t HT_TESTS_HT_SIZE;
extern uint64_t HT_TESTS_NUM_INSERTS;

OpTimings SynthTest::synth_run(BaseHashTable *ktable, uint8_t start) {
  auto inserted = 0lu;

  HTBatchInserter<HT_TESTS_BATCH_LENGTH> inserter(ktable);

  Profiler profiler(std::string(ht_type_strings[config.ht_type]) +
                    "_insertions");

  uint64_t count =
      std::max(static_cast<uint64_t>(1), HT_TESTS_NUM_INSERTS * start);

  for (uint64_t value; reader.next(&value); /* noop */) {
  }

  const auto duration = profiler.end();

  return {duration, HT_TESTS_NUM_INSERTS * config.insert_factor};
}

void SynthTest::synth_run_exec(Shard *sh, BaseHashTable *kmer_ht) {
  PLOG_INFO << "Synth test run: thread " << sh->shard_idx;

  const auto [duration, op_count] = synth_run(kmer_ht, sh->shard_idx);
  PLOG_INFO << "Quick stats: thread:" << sh->shard_idx
            << ", cycles per "
               "insertion:"
            << duration / op_count
#ifdef CALC_STATS
            << ", reprobes: " << kmer_ht->num_reprobes
            << "soft_reprobes: " << kmer_ht->num_soft_reprobes
#endif
      ;

  sh->stats->insertions.duration = insert_times.duration;
  sh->stats->num_inserts = insert_times.op_count;

  const auto find_times = synth_run_get(kmer_ht, sh->shard_idx);

  sh->finds.duration = find_times.duration;
  sh->finds.op_count = find_times.op_count;

  if (find_times.op_count > 0)
    PLOG_INFO.printf("thread %u | num_finds %" PRIu64 " | rdtsc_diff %" PRIu64
                     " | cycles per get: %" PRIu64 "",
                     sh->shard_idx, find_times.op_count, find_times.duration,
                     find_times.duration / find_times.op_count);

#ifndef WITH_PAPI_LIB
  get_ht_stats(sh, kmer_ht);
  // kmer_ht->display();
#endif
}

}  // namespace kmercounter
