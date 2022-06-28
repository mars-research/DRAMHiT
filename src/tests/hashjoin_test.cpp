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
  uint64_t k = 0;
  __attribute__((aligned(64)))
  InsertFindArgument arguments[HT_TESTS_FIND_BATCH_LENGTH] = {0};
  const auto t1_start = RDTSC_START();
  for (KeyValuePair kv; t1->next(&kv);) {
    arguments[k].key = kv.key;
    arguments[k].value = kv.value;
    // PLOG_INFO << "Left " << arguments[k] << arguments[k].id;
    if (++k == HT_TESTS_BATCH_LENGTH) {
      ht->insert_batch(KeyPairs(arguments));
      k = 0;
    }
  }
  // Insert any remaining values.
  if (k != 0) {
    ht->insert_batch(KeyPairs(arguments, k));
    k = 0;
  }
  ht->flush_insert_queue();

  {
    const auto duration = RDTSCP() - t1_start;
    sh->stats->num_inserts = t1->size();
    sh->stats->insertion_cycles = duration;
  }

  // Make sure insertions is finished before probing.
  barrier->arrive_and_wait();

  // Helper function for checking the result of the batch finds.
  // std::ofstream output_file(std::to_string((int)sh->shard_idx) +
  // "_join.tbl");
  const auto t2_start = RDTSC_START();
  uint64_t num_output = 0;
  auto join_rows = [&num_output](const ValuePairs& vp) {
    // PLOG_DEBUG << "Found " << vp.first << " arguments";
    num_output += vp.first;
    for (uint32_t i = 0; i < vp.first; i++) {
      // const Values& value = vp.second[i];
      // PLOG_INFO << "We found " << value;
      // const uint64_t left_row = value.value;
      // const uint64_t right_row = value.id;
      // PLOG_INFO << "Left row " << left_row;
      // PLOG_INFO << "Right row " << right_row;
      // output_file << left_row << "|" << right_row << "\n";
    }
  };

  // Probe.
  __attribute__((aligned(64)))
  FindResult results[HT_TESTS_FIND_BATCH_LENGTH] = {};
  for (KeyValuePair kv; t2->next(&kv);) {
    arguments[k].key = kv.key;
    arguments[k].id = kv.value;
    // arguments[k].part_id = (uint64_t)row.c_str();
    // PLOG_INFO << "Right " << arguments[k];
    if (++k == HT_TESTS_BATCH_LENGTH) {
      ValuePairs valuepairs{0, results};
      ht->find_batch(KeyPairs(arguments), valuepairs);
      join_rows(valuepairs);
      k = 0;
    }
  }
  // Find any remaining values.
  if (k != 0) {
    ValuePairs valuepairs{0, results};
    ht->find_batch(KeyPairs(arguments, k), valuepairs);
    k = 0;
    join_rows(valuepairs);
  }

  // Flush the rest of the queue.
  ValuePairs valuepairs{0, results};
  do {
    valuepairs.first = 0;
    ht->flush_find_queue(valuepairs);
    join_rows(valuepairs);
  } while (valuepairs.first);

  {
    const auto t2_end = RDTSCP();
    const auto duration = t2_end - t2_start;
    const auto total_duration = t2_end - t1_start;

    // Piggy back the total on find.
    sh->stats->num_finds = num_output;
    sh->stats->find_cycles = total_duration;

    std::osyncstream(std::cout)
        << "Thread " << (int)sh->shard_idx << " takes " << duration
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
