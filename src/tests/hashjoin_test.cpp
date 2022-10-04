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
#include <chrono>

namespace kmercounter {
namespace {

using namespace std;
using JoinArrayElement = std::array<uint64_t, 3>;

using MaterializeVector = std::vector<JoinArrayElement>;

/// Perform hashjoin on relation `t1` and `t2`.
/// `t1` is the primary key relation and `t2` is the foreign key relation.
void hashjoin(Shard* sh, input_reader::SizedInputReader<KeyValuePair>* t1,
              input_reader::SizedInputReader<KeyValuePair>* t2,
              BaseHashTable* ht,
              MaterializeVector* mvec,
              bool materialize, std::barrier<std::function<void()>>* barrier) {
  // Build hashtable from t1.
  HTBatchRunner batch_runner(ht);
  const auto t1_start = RDTSC_START();

  std::chrono::time_point<std::chrono::steady_clock> start_build_ts, end_build_ts, end_probe_ts;

  if (sh->shard_idx == 0) {
    start_build_ts = std::chrono::steady_clock::now();
  }

  for (KeyValuePair kv; t1->next(&kv);) {
    batch_runner.insert(kv);
  }
  batch_runner.flush_insert();

  if (0)
  {
    const auto duration = RDTSCP() - t1_start;
    sh->stats->insertions.op_count = t1->size();
    sh->stats->insertions.duration = duration;
  }

  // Make sure insertions is finished before probing.
  barrier->arrive_and_wait();

  if (sh->shard_idx == 0) {
    end_build_ts = std::chrono::steady_clock::now();
  }

  // Helper function for checking the result of the batch finds.
  uint64_t num_output = 0;

  auto join_row = [&num_output, &mvec, &materialize](const FindResult& res) {
    //MaterializeTable mt{res.id, res.value, res.value};
    if (materialize) {
      JoinArrayElement elem = {res.id, res.value, res.value};
      mvec->push_back(elem);
    }
    num_output++;
  };
  batch_runner.set_callback(join_row);

  // Probe.
  const auto t2_start = RDTSC_START();
  for (KeyValuePair kv; t2->next(&kv);) {
    batch_runner.find(kv.key, kv.value);
  }
  batch_runner.flush_find();

  // Make sure insertions is finished before probing.
  barrier->arrive_and_wait();


  if (sh->shard_idx == 0) {
    end_probe_ts = std::chrono::steady_clock::now();

    PLOG_INFO.printf("Build phase took %llu us, probe phase took %llu us",
        chrono::duration_cast<chrono::microseconds>(end_build_ts - start_build_ts).count(),
        chrono::duration_cast<chrono::microseconds>(end_probe_ts - end_build_ts).count());
  }

  if (0)
  {
    const auto t2_end = RDTSCP();
    const auto duration = t2_end - t2_start;
    const auto total_duration = t2_end - t1_start;
    num_output = t2->size();

    // Piggy back the total on find.
    sh->stats->finds.op_count = num_output;
    sh->stats->finds.duration = total_duration;

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
                                            bool materialize,
                                            std::barrier<VoidFn>* barrier) {
  input_reader::PartitionedEthRelationGenerator t1(
      "r.tbl", DEFAULT_R_SEED, config.relation_r_size, sh->shard_idx,
      config.num_threads);
  input_reader::PartitionedEthRelationGenerator t2(
      "s.tbl", DEFAULT_S_SEED, config.relation_r_size, sh->shard_idx,
      config.num_threads);

  std::uint64_t start {}, end {};
  std::chrono::time_point<std::chrono::steady_clock> start_ts, end_ts;

  MaterializeVector *mt{};
  if (materialize)
    mt = new MaterializeVector(t1.size());

  // Wait for all readers finish initializing.
  barrier->arrive_and_wait();

  if (sh->shard_idx == 0) {
    start = _rdtsc();
    start_ts = std::chrono::steady_clock::now();
  }

  // Run hashjoin
  hashjoin(sh, &t1, &t2, ht, mt, materialize, barrier);

  barrier->arrive_and_wait();

  if (sh->shard_idx == 0) {
    end = _rdtsc();
    end_ts = std::chrono::steady_clock::now();
    PLOG_INFO.printf("Hashjoin took %llu us (%llu cycles)",
        chrono::duration_cast<chrono::microseconds>(end_ts - start_ts).count(),
        end - start);
    if (mt) {
      for (const auto &e: *mt) {
        PLOGV.printf("k: %llu, v1: %llu, v2: %llu\n", e.at(0), e.at(1), e.at(2));
      }
    }
  }
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
  hashjoin(sh, &t1, &t2, ht, NULL, false, barrier);
}

}  // namespace kmercounter
