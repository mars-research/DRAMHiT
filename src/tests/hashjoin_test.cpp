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
#include "queues/section_queues.hpp"
#include "sync.h"
#include "tests/HashjoinTest.hpp"
#include "types.hpp"
#include "utils/hugepage_allocator.hpp"

#define ITERATOR
namespace kmercounter {

extern ExecPhase cur_phase;
extern bool g_app_record_start;

extern std::vector<key_type> *g_zipf_values;

using JoinArrayElement = std::array<uint64_t, 3>;

using MaterializeVector = std::vector<JoinArrayElement>;

using Element = KeyValuePair;
using HugepageAlloc = huge_page_allocator<Element>;
using HugepageVec = std::vector<Element, HugepageAlloc>;
HugepageAlloc hugepage_alloc_inst_hj;

#define PREFETCH_AHEAD_X_CACHELINE 4

void ht_do_insert(BaseHashTable *ht, HugepageVec &workload, uint32_t partition_offset) {
    uint32_t requests_num = workload.size();
    uint32_t batch_len = config.batch_len;
    collector_type *const collector{};
    InsertFindArgument *items = (InsertFindArgument *)aligned_alloc(64, sizeof(InsertFindArgument) * batch_len);
    KeyValuePair kv;
    size_t batch_num = requests_num / batch_len;
    size_t ele_num_per_cache_line = CACHELINE_SIZE / sizeof(KeyValuePair);
    assert(ele_num_per_cache_line % 2 == 0);
    size_t idx = 0;

    // force ele_num_per_cache_line pow of 2. 2 < 16
    for (unsigned int n = 0; n < batch_num; n++) {
      // on each batch, populate find args
      for (int i = 0; i < batch_len; i++) {
        if ((idx & ele_num_per_cache_line) && (idx + ele_num_per_cache_line < workload.size())) {
          // fetch next line
          __builtin_prefetch(&workload.at(idx + ele_num_per_cache_line), false, 2);
        }

        // kv = workload.at(idx);  // len 1024,  zipf[2 * 1024]
        items[i].key = kv.key;
        items[i].value = kv.value;
        items[i].id = idx + partition_offset; // as long as we know per batch differneces
        idx++;
      }

      ht->insert_batch(InsertFindArguments(items, batch_len), collector);
    }

    // in case batch size is not divisible
    size_t residule_num = requests_num - batch_len * batch_num;
    if (residule_num > 0) {
      for (int i = 0; i < residule_num; i++) {
        if ((idx & ele_num_per_cache_line) && (idx + ele_num_per_cache_line < workload.size())) {
            __builtin_prefetch(&workload.at(idx + ele_num_per_cache_line), false, 2);
        }
        // kv = workload.at(idx);
        items[i].key = kv.key;
        items[i].value = kv.value;
        items[i].id = idx;
        idx++;
      }
      ht->insert_batch(InsertFindArguments(items, residule_num), collector);
    }

    ht->flush_insert_queue(collector);
    free(items);
}

void ht_do_find(BaseHashTable *ht, HugepageVec &workload, uint32_t partition_offset) {
    uint32_t found = 0;
    uint32_t requests_num = workload.size();

    uint32_t batch_len = config.batch_len;
    collector_type *const collector{};
    FindResult *results = new FindResult[batch_len];
    ValuePairs vp = std::make_pair(0, results);
    InsertFindArgument *items = (InsertFindArgument *)aligned_alloc(64, sizeof(InsertFindArgument) * batch_len);
    Element e;
    size_t batch_num = requests_num / batch_len;
    size_t ele_num_per_cache_line = CACHELINE_SIZE / sizeof(Element);
    size_t prefetches_ahead = ele_num_per_cache_line * PREFETCH_AHEAD_X_CACHELINE;
    size_t idx = 0;

    // force ele_num_per_cache_line pow of 2. 2 < 16
    for (unsigned int n = 0; n < batch_num; n++) {
      // on each batch, populate find args
      for (int i = 0; i < batch_len; i++) {
        if (!(idx & (ele_num_per_cache_line-1)) && (idx + prefetches_ahead < requests_num)) {
            __builtin_prefetch(&workload.at(idx + prefetches_ahead), false, 3);
        }
        e = workload.at(idx);
        items[i].key = e.key;
        items[i].id = idx + partition_offset; // as long as we know per batch differneces
        idx++;
      }

      vp.first = 0;
      ht->find_batch(InsertFindArguments(items, batch_len), vp, collector);
      found += vp.first;
    }

    // in case batch size is not divisible
    // size_t residule_num = requests_num - batch_len * batch_num;
    // if (residule_num > 0) {
    //   for (int i = 0; i < residule_num; i++) {
    //     if ((idx & ele_num_per_cache_line) && (idx + ele_num_per_cache_line < workload.size())) {
    //         __builtin_prefetch(&workload.at(idx + ele_num_per_cache_line), false, 2);
    //     }
    //     kv = workload.at(idx);
    //     items[i].key = kv.key;
    //     items[i].id = idx + partition_offset;
    //     idx++;
    //   }
    //   vp.first = 0;
    //   ht->find_batch(InsertFindArguments(items, residule_num), vp, collector);
    //   found += vp.first;
    // }

    // Now do whatever is left
    vp.first = 0;
    while (ht->flush_find_queue(vp, collector) > 0) {
      found += vp.first;
      vp.first = 0;
    }

    free(items);
}

/// Perform hashjoin on relation `t1` and `t2`.
/// `t1` is the primary key relation and `t2` is the foreign key relation.
void hashjoin(Shard* sh, HugepageVec& t1, HugepageVec& t2,
              BaseHashTable* ht, MaterializeVector* mvec, bool materialize,
              std::barrier<std::function<void()>>* barrier) {
  uint64_t offset = t1.size() * sh->shard_idx;
  // ht_do_insert(ht, t1, offset);
  // if (sh->shard_idx == 0) {
  //   cur_phase = ExecPhase::none;
  // }
  // barrier->arrive_and_wait();
  ht_do_find(ht, t2, offset);
  // Build hashtable from t1.
 // HTBatchRunner batch_runner(ht);

  //for(uint64_t i = 0; i < t1.size(); i++) {
  //    batch_runner.insert(t1[i]);
  //}
  //batch_runner.flush_insert();

  //if (sh->shard_idx == 0) {
  //  cur_phase = ExecPhase::none;
  //}
  //barrier->arrive_and_wait();

  // uint64_t num_output = 0;

  // auto join_row = [&num_output, &mvec, &materialize](const FindResult& res) {
  //   if (materialize) {
  //     JoinArrayElement elem = {res.id, res.value, res.value};
  //     mvec->push_back(elem);
  //   }
  //   num_output++;
  // };
  // batch_runner.set_callback(join_row);

  // Probe.
  //

}

void HashjoinTest::join_relations_generated(Shard* sh,
                                            const Configuration& config,
                                            BaseHashTable* ht, bool materialize,
                                            std::barrier<VoidFn>* barrier) {
  // input_reader::PartitionedEthRelationGenerator t1(
  //     "r.tbl", DEFAULT_R_SEED, config.relation_r_size, sh->shard_idx,
  //     config.num_threads, config.relation_r_size);

  // input_reader::PartitionedEthRelationGenerator t2(
  //     "s.tbl", DEFAULT_S_SEED, config.relation_r_size, sh->shard_idx,
  //     config.num_threads, config.relation_r_size);

  // input_reader::SizedInputReader<KeyValuePair>* r1 = (input_reader::SizedInputReader<KeyValuePair>*)&t1;
  // input_reader::SizedInputReader<KeyValuePair>* r2  = (input_reader::SizedInputReader<KeyValuePair>*)&t2;

  uint64_t partition_sz = config.relation_r_size / config.num_threads;
  HugepageVec build_relation(
     partition_sz,
     hugepage_alloc_inst_hj
  );

  //std::vector<KeyValuePair, huge_page_allocator<KeyValuePair>> read_relation(
  //   partition_sz,
  //   hugepage_alloc_inst_hj
  //);

  uint64_t ri = 0;

  Element e;
  for(int i=0; i<partition_sz; i++){
      key_type v = g_zipf_values->at(i+partition_sz*sh->shard_idx);
      e.key = v;
      e.value = 0xff;
      build_relation.at(i) = e;
  }

  // for (KeyValuePair kv; r1->next(&kv);) {
  //     if(ri >= build_relation.size()) {
  //         PLOGE.printf("huge vector lendth is too small");
  //         return;
  //     }
  //     build_relation.at(ri) = kv;
  //     ri++;
  // }

  // ri = 0;
  // for (KeyValuePair kv; r2->next(&kv);) {
  //     if(ri >= read_relation.size()) {
  //         PLOGE.printf("huge vector lendth is too small");
  //         return;
  //     }
  //     read_relation.at(ri) = kv;
  //     ri++;
  // }

  MaterializeVector* mt{};
  // if (materialize) mt = new MaterializeVector(t1.size());

  // Wait for all readers finish initializing.

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::recording;
    g_app_record_start = true;
  }
  barrier->arrive_and_wait();

  hashjoin(sh, build_relation, build_relation, ht, mt, materialize, barrier);

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::recording;
    g_app_record_start = false;
  }
  barrier->arrive_and_wait();
  sh->stats->insertions.op_count = partition_sz; // join this many elements for this shard

  if (sh->shard_idx == 0) {
    PLOGI.printf("get fill %.3f",
                 (double)ht->get_fill() / ht->get_capacity());
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
}  // namespace kmercounter

}
