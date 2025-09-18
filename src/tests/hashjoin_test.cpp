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

extern ExecPhase cur_phase;
extern bool g_app_record_start;

using JoinArrayElement = std::array<uint64_t, 3>;

using MaterializeVector = std::vector<JoinArrayElement>;

/// Perform hashjoin on relation `t1` and `t2`.
/// `t1` is the primary key relation and `t2` is the foreign key relation.
void hashjoin(Shard* sh, input_reader::SizedInputReader<KeyValuePair>* t1,
              input_reader::SizedInputReader<KeyValuePair>* t2,
              std::tuple<KeyValuePair*, uint32_t> relation_r,
              std::tuple<KeyValuePair*, uint32_t> relation_s,
              BaseHashTable* ht,
              MaterializeVector* mvec,
              bool materialize, std::barrier<std::function<void()>>* barrier) {
  // Build hashtable from t1.
  HTBatchRunner batch_runner(ht);
  collector_type *const collector{};
  auto [rel_r, rel_r_size] = relation_r;
  auto [rel_s, rel_s_size] = relation_s;

#ifdef ITERATOR
  for (KeyValuePair kv; t1->next(&kv);) {
#else
  for (auto i = 0; i < rel_r_size; i++) {
    KeyValuePair kv = rel_r[i];
#endif
    batch_runner.insert(kv);
  }
  batch_runner.flush_insert();

  barrier->arrive_and_wait();


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
#ifdef ITERATOR
  for (KeyValuePair kv; t2->next(&kv);) {
#else
  for (auto i = 0; i < rel_s_size; i++) {
    KeyValuePair kv = rel_s[i];
#endif
    value_type val = kv.value;
    KeyValuePair *f_kv = (KeyValuePair*) batch_runner.find(kv);
  }
  batch_runner.flush_find();

  barrier->arrive_and_wait();

}


#define REPEAT 100
void HashjoinTest::join_relations_generated(Shard* sh,
                                            const Configuration& config,
                                            BaseHashTable* ht,
                                            bool materialize,
                                            std::barrier<VoidFn>* barrier) {
  input_reader::PartitionedEthRelationGenerator t1(
      "r.tbl", DEFAULT_R_SEED, config.relation_r_size, sh->shard_idx,
      config.num_threads, config.relation_r_size);
  input_reader::PartitionedEthRelationGenerator t2(
      "s.tbl", DEFAULT_S_SEED, config.relation_s_size, sh->shard_idx,
      config.num_threads, config.relation_r_size);  



#ifndef ITERATOR
  input_reader::SizedInputReader<KeyValuePair>* _t2 = &t2;
  input_reader::SizedInputReader<KeyValuePair>* _t1 = &t1;
  auto s = _rdtsc();
  auto sum = 0;

  std::tuple<KeyValuePair*, uint32_t> relation_r;
  std::tuple<KeyValuePair*, uint32_t> relation_s;

  KeyValuePair *rel_r;
  posix_memalign((void **)&rel_r, 64, t1.size() * sizeof(KeyValuePair));

  KeyValuePair *rel_s;
  posix_memalign((void **)&rel_s, 64, t2.size() * sizeof(KeyValuePair));

  auto i = 0u;

  for (KeyValuePair kv; _t2->next(&kv);) {
    rel_s[i].key = kv.key;
    rel_s[i].value = kv.value;
    i++;
  }

  i = 0;

  for (KeyValuePair kv; _t1->next(&kv);) {
    rel_r[i].key = kv.key;
    rel_r[i].value = kv.value;
    i++;
  }

  relation_r = std::make_tuple(rel_r, t1.size());
  relation_s = std::make_tuple(rel_s, t2.size());
#else

  std::tuple<KeyValuePair*, uint32_t> relation_r;
  std::tuple<KeyValuePair*, uint32_t> relation_s;

  relation_r = std::make_tuple(nullptr, t1.size());
  relation_s = std::make_tuple(nullptr, t2.size());
#endif

  std::uint64_t start {}, end {};
  std::chrono::time_point<std::chrono::steady_clock> start_ts, end_ts;

  MaterializeVector *mt{};
  if (materialize)
    mt = new MaterializeVector(t1.size());

  // Wait for all readers finish initializing.

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::recording;
    g_app_record_start = true;
  }
  barrier->arrive_and_wait();
  
  // Run hashjoin

    hashjoin(sh, &t1, &t2, relation_r, relation_s, ht, mt, materialize, barrier);

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::recording;
    g_app_record_start = false;
  }
  barrier->arrive_and_wait();

  sh->stats->insertions.op_count = t1.size();
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
  hashjoin(sh, &t1, &t2,
      std::make_tuple(nullptr, t1.size()),
      std::make_tuple(nullptr, t2.size()),
      ht, NULL, false, barrier);
}

}  // namespace kmercounter
