/// This file implements Hash Join.
// Relevant resources:
// * Hash join: https://dev.mysql.com/worklog/task/?id=2241
// * Add support for hash outer, anti and semi join:
// https://dev.mysql.com/worklog/task/?id=13377
// * Optimize hash table in hash join:
// https://dev.mysql.com/worklog/task/?id=13459

#include <atomic>
#include <barrier>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>  // Required for std::abort()
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
#include "print_stats.h"
#include "queues/section_queues.hpp"
#include "sync.h"
#include "tests/HashjoinTest.hpp"
#include "types.hpp"
#include "utils/hugepage_allocator.hpp"

#define DEBUG_HJ
#ifdef DEBUG_HJ

#define ASSERT_TRUE(expr)                                            \
  do {                                                               \
    if (!(expr)) {                                                   \
      PLOGE.printf("Assertion failed: %s at %s:%d", #expr, __FILE__, \
                   __LINE__);                                        \
      std::abort();                                                  \
    }                                                                \
  } while (false)

#else

#define ASSERT_TRUE(expr)

#endif

namespace kmercounter {

extern ExecPhase cur_phase;
extern bool g_app_record_start;
extern std::vector<key_type>* g_zipf_values;
extern uint64_t g_insert_start, g_insert_end;
extern uint64_t g_find_start, g_find_end;

using JoinElement = struct {
  key_type k;
  value_type v1;
  value_type v2;
};
using JoinHugepageAlloc = huge_page_allocator<JoinElement>;
using JoinVec = std::vector<JoinElement, JoinHugepageAlloc>;
JoinHugepageAlloc hugepage_alloc_inst_join;

using Element = KeyValuePair;
using HugepageAlloc = huge_page_allocator<Element>;
using HugepageVec = std::vector<Element, HugepageAlloc>;
HugepageAlloc hugepage_alloc_inst_relation;

#define PREFETCH_AHEAD_X_CACHELINE 4
#define MATERIALIZE

bool hj_test_contains(HugepageVec& vec, key_type k, value_type v) {
  for (const auto& e : vec) {
    if (e.key == k && e.value == v) {
      return true;
    }
  }

  return false;
}

void ht_do_insert(BaseHashTable* ht, HugepageVec& workload) {
  uint32_t requests_num = workload.size();
  uint32_t batch_len = config.batch_len;
  collector_type* const collector{};
  InsertFindArgument* items = (InsertFindArgument*)aligned_alloc(
      64, sizeof(InsertFindArgument) * batch_len);
  Element e;
  size_t batch_num = requests_num / batch_len;
  size_t ele_num_per_cache_line = CACHELINE_SIZE / sizeof(Element);
  size_t prefetches_ahead = ele_num_per_cache_line * PREFETCH_AHEAD_X_CACHELINE;
  size_t idx = 0;

  // force ele_num_per_cache_line pow of 2. 2 < 16
  for (unsigned int n = 0; n < batch_num; n++) {
    // on each batch, populate find args
    for (int i = 0; i < batch_len; i++) {
      if (!(idx & (ele_num_per_cache_line - 1)) &&
          (idx + prefetches_ahead < requests_num)) {
        __builtin_prefetch(&workload.at(idx + prefetches_ahead), false, 3);
      }

      e = workload.at(idx);
      items[i].key = e.key;
      items[i].value = e.value;
      items[i].id = idx;
      idx++;
    }

    ht->insert_batch(InsertFindArguments(items, batch_len), collector);
  }

  // in case batch size is not divisible
  size_t residule_num = requests_num - batch_len * batch_num;
  if (residule_num > 0) {
    for (int i = 0; i < residule_num; i++) {
      if (!(idx & (ele_num_per_cache_line - 1)) &&
          (idx + prefetches_ahead < requests_num)) {
        __builtin_prefetch(&workload.at(idx + prefetches_ahead), false, 3);
      }
      e = workload.at(idx);
      items[i].key = e.key;
      items[i].value = e.value;
      items[i].id = idx;
      idx++;
    }
    ht->insert_batch(InsertFindArguments(items, residule_num), collector);
  }

  ht->flush_insert_queue(collector);
  free(items);
}

uint64_t ht_do_find(BaseHashTable* ht, HugepageVec& workload, JoinVec& mvec) {
  uint64_t found = 0;
  uint32_t requests_num = workload.size();
  uint32_t batch_len = config.batch_len;

  collector_type* const collector{};
  FindResult* results = new FindResult[batch_len];
  ValuePairs vp = std::make_pair(0, results);
  InsertFindArgument* items = (InsertFindArgument*)aligned_alloc(
      64, sizeof(InsertFindArgument) * batch_len);

  Element e;
  size_t batch_num = requests_num / batch_len;
  size_t ele_num_per_cache_line = CACHELINE_SIZE / sizeof(Element);
  size_t prefetches_ahead = ele_num_per_cache_line * PREFETCH_AHEAD_X_CACHELINE;
  size_t idx = 0;
  size_t m_idx = 0;

  Element probe_elem;
  FindResult result;
  uint32_t batch_idx = 0;
  ASSERT_TRUE(batch_len % 2 == 0 && batch_len > 0);

  // force ele_num_per_cache_line pow of 2. 2 < 16
  for (unsigned int n = 0; n < batch_num; n++) {
    // on each batch, populate find args
    for (int i = 0; i < batch_len; i++) {
      if (!(idx & (ele_num_per_cache_line - 1)) &&
          (idx + prefetches_ahead < requests_num)) {
        __builtin_prefetch(&workload.at(idx + prefetches_ahead), false, 3);
      }
      e = workload.at(idx);
      items[i].key = e.key;
      ASSERT_TRUE(e.key != 0);
      items[i].id = idx;  // keep track of which request this is.
      idx++;
    }

    vp.first = 0;
    ht->find_batch(InsertFindArguments(items, batch_len), vp, collector);
    found += vp.first;
    // do actual join, might have to prefetch this as well ....
#ifdef MATERIALIZE
    for (int i = 0; i < vp.first; i++) {
      ASSERT_TRUE(vp.first <= batch_len);
      result = vp.second[i];
      ASSERT_TRUE(result.id < workload.size());
      probe_elem = workload[result.id];  // basically random reads
      ASSERT_TRUE(probe_elem.key != 0);
      mvec[m_idx] = {probe_elem.key, probe_elem.value, result.value};
      m_idx++;
    }
#endif
  }

  // in case batch size is not divisible
  size_t residule_num = requests_num - batch_len * batch_num;
  if (residule_num > 0) {
    for (int i = 0; i < residule_num; i++) {
      if (!(idx & (ele_num_per_cache_line - 1)) &&
          (idx + prefetches_ahead < requests_num)) {
        __builtin_prefetch(&workload.at(idx + prefetches_ahead), false, 3);
      }
      e = workload.at(idx);
      items[i].key = e.key;
      items[i].id = idx;
      idx++;
    }
    vp.first = 0;
    ht->find_batch(InsertFindArguments(items, residule_num), vp, collector);
    found += vp.first;
#ifdef MATERIALIZE
    for (int i = 0; i < vp.first; i++) {
      ASSERT_TRUE(vp.first <= batch_len);
      result = vp.second[i];
      ASSERT_TRUE(result.id < workload.size());
      probe_elem = workload[result.id];  // basically random reads
      ASSERT_TRUE(probe_elem.key != 0);
      mvec[m_idx] = {probe_elem.key, probe_elem.value, result.value};
      m_idx++;
    }
#endif
  }

  // Flush internal queues
  while (true) {
    vp.first = 0;
    size_t cur_queue_sz = ht->flush_find_queue(vp, collector);
    if (vp.first == 0 && cur_queue_sz == 0) {
      break;
    }
    found += vp.first;
#ifdef MATERIALIZE
    for (int i = 0; i < vp.first; i++) {
      ASSERT_TRUE(vp.first <= batch_len);
      result = vp.second[i];
      ASSERT_TRUE(result.id < workload.size());
      probe_elem = workload[result.id];  // basically random reads
      ASSERT_TRUE(probe_elem.key != 0);
      mvec[m_idx] = {probe_elem.key, probe_elem.value, result.value};
      m_idx++;
    }
#endif
  }

  free(items);
  delete results;
  return found;
}

void dump_workloads(HugepageVec& build, HugepageVec& probe, JoinVec& mvec) {
  PLOGI.printf("build size: %lu, probe size: %lu, mvec size: %lu", build.size(),
               probe.size(), mvec.size());
  for (size_t i = 0; i < build.size(); i++) {
    PLOGI.printf("build[%lu] key: %lu, value: %lu", i, build[i].key,
                 build[i].value);
  }
  for (size_t i = 0; i < probe.size(); i++) {
    PLOGI.printf("probe[%lu] key: %lu, value: %lu", i, probe[i].key,
                 probe[i].value);
  }
  for (size_t i = 0; i < mvec.size(); i++) {
    PLOGI.printf("mvec[%lu] key: %lu, value1: %lu, value2: %lu", i, mvec[i].k,
                 mvec[i].v1, mvec[i].v2);
  }
}

/// Perform hashjoin on relation `t1` and `t2`.
/// `t1` is the primary key relation and `t2` is the foreign key relation.
void hashjoin(Shard* sh, HugepageVec& build, HugepageVec& probe, JoinVec& mvec,
              BaseHashTable* ht, std::barrier<std::function<void()>>* barrier) {
  // Measure Build
  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::insertions;
    g_app_record_start = true;
  }
  barrier->arrive_and_wait();

  ht_do_insert(ht, build);

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::insertions;
    g_app_record_start = false;
  }
  barrier->arrive_and_wait();

  sh->stats->insertions.op_count = build.size();
  sh->stats->insertions.duration = g_insert_end - g_insert_start;

  // Measure Probe
  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::finds;
    g_app_record_start = true;
  }
  barrier->arrive_and_wait();

  uint64_t found = ht_do_find(ht, probe, mvec);

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::finds;
    g_app_record_start = false;
  }
  barrier->arrive_and_wait();

  sh->stats->finds.op_count = probe.size();
  sh->stats->finds.duration = g_find_end - g_find_start;

  // test, for each element in join relation, probe k, probe value, build value
  // the probe key should exists in build relation.

#ifdef DEBUG_HJ

  PLOGI.printf("get fill %.3f", (double)ht->get_fill() / ht->get_capacity());
  PLOGI.printf("joined %lu out %lu, %.2f", found, probe.size(),
               found * 100.0 / probe.size());

  // functional correctness
  ASSERT_TRUE(mvec.size() == probe.size());
  uint64_t matched_count = 0;
  for (const auto& be : build) {
    for (const auto& pe : probe) {
      if (pe.key == be.key) {
        matched_count++;
      }
    }
  }
  PLOGI.printf("matched_count %lu", matched_count);

  dump_workloads(build, probe, mvec);
  ASSERT_TRUE(found == matched_count);

  JoinElement je;
  for (int i = 0; i < found; i++) {
    ASSERT_TRUE(found <= mvec.size());
    je = mvec[i];
    if (!hj_test_contains(probe, je.k, je.v1)) {
      PLOGE.printf(
          "@ mvec[%lu] probe didn't find key %lu, value1: %lu, value2: %lu", i,
          je.k, je.v1, je.v2);
      dump_workloads(build, probe, mvec);
      abort();
    }

    if (!hj_test_contains(build, je.k, je.v2)) {
      PLOGE.printf(
          "@ mvec[%lu] build didn't find key %lu, value1: %lu, value2: %lu", i,
          je.k, je.v1, je.v2);
      dump_workloads(build, probe, mvec);
      abort();
    }
  }
#endif
}

void HashjoinTest::join_relations_generated(Shard* sh,
                                            const Configuration& config,
                                            BaseHashTable* ht, bool materialize,
                                            std::barrier<VoidFn>* barrier) {
  // global zipf value first populate relation_r, then append relation_s.
  uint64_t partition_sz_r = config.relation_r_size / config.num_threads;
  uint64_t partition_sz_s = config.relation_s_size / config.num_threads;

  // Why do we do this ? on numa machine, we can ensure workload are local
  // access.
  HugepageVec build_relation(partition_sz_r, hugepage_alloc_inst_relation);
  HugepageVec probe_relation(partition_sz_s, hugepage_alloc_inst_relation);
  JoinVec join_relation(partition_sz_s, hugepage_alloc_inst_join);

  // Copy data from global vec into hugepage back vec.
  Element e;
  uint64_t workload_idx = 0;
  uint64_t offset = partition_sz_r * sh->shard_idx;
  for (int i = 0; i < partition_sz_r; i++) {
    workload_idx = i + offset;
    if (workload_idx >= g_zipf_values->size()) {
      PLOGE.printf("hj workload_idx %lu out of bounds", workload_idx);
      return;
    }
    key_type v = g_zipf_values->at(workload_idx);
    e.key = v;
    e.value = 0xef;
    build_relation.at(i) = e;
  }

  workload_idx = 0;
  offset = config.relation_r_size + partition_sz_s * sh->shard_idx;
  for (int i = 0; i < partition_sz_s; i++) {
    workload_idx = i + offset;
    if (workload_idx >= g_zipf_values->size()) {
      PLOGE.printf("hj workload_idx %lu out of bounds", workload_idx);
      return;
    }
    key_type v = g_zipf_values->at(workload_idx);
    e.key = v;
    e.value = 0xde;
    probe_relation.at(i) = e;
  }

  hashjoin(sh, build_relation, probe_relation, join_relation, ht, barrier);
}

void HashjoinTest::join_relations_from_files(Shard* sh,
                                             const Configuration& config,
                                             BaseHashTable* ht,
                                             std::barrier<VoidFn>* barrier) {
  input_reader::KeyValueCsvPreloadReader t1(config.relation_r, sh->shard_idx,
                                            config.num_threads, "|");
  input_reader::KeyValueCsvPreloadReader t2(config.relation_s, sh->shard_idx,
                                            config.num_threads, "|");
}  // namespace kmercounter

}  // namespace kmercounter
