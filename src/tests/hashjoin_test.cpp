/// This file implements Hash Join.
// Relevant resources:
// * Hash join: https://dev.mysql.com/worklog/task/?id=2241
// * Add support for hash outer, anti and semi join:
// https://dev.mysql.com/worklog/task/?id=13377
// * Optimize hash table in hash join:
// https://dev.mysql.com/worklog/task/?id=13459

#include <atomic>
#include <barrier>
#include <fstream>
#include <functional>
#include <iostream>
#include <optional>
#include <syncstream>
#include <unordered_set>

#include "constants.hpp"
#include "hashtables/base_kht.hpp"
#include "hashtables/batch_runner/batch_runner.hpp"
#include "hashtables/kvtypes.hpp"
#include "input_reader/csv.hpp"
#include "input_reader/eth_rel_gen.hpp"
#include "plog/Log.h"
#include "sync.h"
#include "tests/HashjoinTest.hpp"
#include "types.hpp"

namespace kmercounter {
namespace {
/// Perform hashjoin on relation `t1` and `t2`.
/// `t1` is the primary key relation and `t2` is the foreign key relation.
void hashjoin(Shard* sh, input_reader::SizedInputReader<KeyValuePair>* t1,
              input_reader::SizedInputReader<KeyValuePair>* t2,
              BaseHashTable* ht, std::barrier<std::function<void()>>* barrier) {
  // Build hashtable from t1.
  HTBatchRunner batch_runner(ht);
  const auto t1_start = RDTSC_START();
  for (KeyValuePair kv; t1->next(&kv);) {
    batch_runner.insert(kv);
  }
  batch_runner.flush_insert();

  {
    const auto duration = RDTSCP() - t1_start;
    sh->stats->num_inserts = t1->size();
    sh->stats->insertion_cycles = duration;
  }

  // Make sure insertions is finished before probing.
  barrier->arrive_and_wait();

  // Helper function for checking the result of the batch finds.
  uint64_t num_output = 0;
  auto join_row = [&num_output](const FindResult& _result) { num_output++; };
  batch_runner.set_callback(join_row);

  // Probe.
  const auto t2_start = RDTSC_START();
  for (KeyValuePair kv; t2->next(&kv);) {
    batch_runner.find(kv.key, kv.value);
  }
  batch_runner.flush_find();

  {
    const auto t2_end = RDTSCP();
    const auto duration = t2_end - t2_start;
    const auto total_duration = t2_end - t1_start;
    num_output = t2->size();

    // Piggy back the total on find.
    sh->stats->num_finds = num_output;
    sh->stats->find_cycles = total_duration;

    std::osyncstream(std::cout)
        << "Thread " << (int)sh->shard_idx << " took " << duration
        << " to join t2 with size " << t2->size() << ". Output " << num_output
        << " rows. Average " << duration / std::max(1ul, num_output)
        << " cycles per probe, " << total_duration / std::max(1ul, num_output)
        << " cycles per output." << std::endl;
  }
}
}  // namespace

void HashjoinTest::join_relations_generated(Shard* sh,
                                            const Configuration& config,
                                            BaseHashTable* ht,
                                            std::barrier<VoidFn>* barrier) {
  input_reader::PartitionedEthRelationGenerator t1(
      "r.tbl", DEFAULT_R_SEED, config.relation_r_size, sh->shard_idx,
      config.num_threads);
  input_reader::PartitionedEthRelationGenerator t2(
      "s.tbl", DEFAULT_S_SEED, config.relation_r_size, sh->shard_idx,
      config.num_threads);

  // Wait for all readers finish initializing.
  barrier->arrive_and_wait();

  // Run hashjoin
  hashjoin(sh, &t1, &t2, ht, barrier);
}

void HashjoinTest::join_relations_from_files(Shard* sh,
                                             const Configuration& config,
                                             BaseHashTable* ht,
                                             std::barrier<VoidFn>* barrier) {
  input_reader::KeyValueCsvPreloadReader t1(config.relation_r, sh->shard_idx,
                                            config.num_threads, "|");
  input_reader::KeyValueCsvPreloadReader t2(config.relation_s, sh->shard_idx,
                                            config.num_threads, "|");
  PLOG_INFO << "Shard " << (int)sh->shard_idx << "/" << config.num_threads
            << " t1 " << t1.size() << " t2 " << t2.size();

  // Wait for all readers finish initializing.
  barrier->arrive_and_wait();

  // Run hashjoin
  hashjoin(sh, &t1, &t2, ht, barrier);
}

}  // namespace kmercounter
