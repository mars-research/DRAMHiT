/// This file implements Hash Join.
// Relevant resources:
// * Hash join: https://dev.mysql.com/worklog/task/?id=2241
// * Add support for hash outer, anti and semi join:
// https://dev.mysql.com/worklog/task/?id=13377
// * Optimize hash table in hash join:
// https://dev.mysql.com/worklog/task/?id=13459

#include <unistd.h>
#include <atomic>
#include <barrier>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>     // Required for std::abort()
#include <filesystem>  // Required for checking file existence and size
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
#include "misc_lib.h"
#include "plog/Log.h"
#include "print_stats.h"
#include "queues/section_queues.hpp"
#include "sync.h"
#include "tests/HashjoinTest.hpp"
#include "types.hpp"
#include "utils/hugepage_allocator.hpp"
#include "zipf_distribution.hpp"

// #define DEBUG_HJ
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

#define PREFETCH_AHEAD_X_CACHELINE 4
#define MATERIALIZE

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

void init_hashjoin_dist(double skew, int64_t seed, uint64_t r_size,
                        uint64_t s_size) {
  uint64_t total_size = r_size + s_size;
  size_t expected_bytes = total_size * sizeof(key_type);

  // Clean up if re-initializing
  if (g_zipf_values != nullptr) {
    delete g_zipf_values;
    PLOGE.printf("g_zipf_values should be null");
    abort();
  }

  // Allocate the global vector
  g_zipf_values = new std::vector<key_type>(total_size);

  // ---------------------------------------------------------
  // Dynamically generate the filename based on parameters
  // ---------------------------------------------------------
  std::ostringstream filename_stream;
  filename_stream << "hashjoin"
                  << "_r" << r_size << "_s" << s_size << "_skew" << skew
                  << "_seed" << seed << ".bin";

  std::string filename = filename_stream.str();
  // ---------------------------------------------------------
  // STEP 1: Attempt to load from disk
  // ---------------------------------------------------------
  if (std::filesystem::exists(filename)) {
    // Validate file size to ensure our parameters haven't changed
    if (std::filesystem::file_size(filename) == expected_bytes) {
      std::cout << "Loading cached dataset from disk (" << filename << ")..."
                << std::endl;

      std::ifstream infile(filename, std::ios::binary);
      if (infile) {
        // Read the entire binary block directly into the vector's memory
        infile.read(reinterpret_cast<char*>(g_zipf_values->data()),
                    expected_bytes);
        return;  // Successfully loaded, exit function early
      }
    } else {
      std::cout << "Cache size mismatch (parameters changed?). Regenerating..."
                << std::endl;
    }
  }

  // ---------------------------------------------------------
  // STEP 2: Generate from scratch (Cache miss)
  // ---------------------------------------------------------
  std::cout << "Generating new Zipfian dataset..." << std::endl;

  std::uint64_t keyrange_width = (1ull << 63);
  if constexpr (std::is_same_v<key_type, std::uint32_t>) {
    keyrange_width = (1ull << 31);
  }
  zipf_distribution_apache distribution(keyrange_width, skew, seed);

  // Populate R (Unique)
  std::unordered_set<key_type> unique_keys;
  unique_keys.reserve(r_size);

  uint64_t r_index = 0;
  while (r_index < r_size) {
    key_type k = distribution.sample();
    if (unique_keys.insert(k).second) {
      (*g_zipf_values)[r_index] = k;
      r_index++;
    }
  }

  // Populate S (Non-unique)
  for (uint64_t s_index = 0; s_index < s_size; ++s_index) {
    (*g_zipf_values)[r_size + s_index] = distribution.sample();
  }

  // ---------------------------------------------------------
  // STEP 3: Save to disk for next time
  // ---------------------------------------------------------
  std::cout << "Saving dataset to disk..." << std::endl;
  std::ofstream outfile(filename, std::ios::binary);
  if (outfile) {
    // Write the entire vector memory block to disk
    outfile.write(reinterpret_cast<const char*>(g_zipf_values->data()),
                  expected_bytes);
  } else {
    std::cerr << "Warning: Failed to open file for writing!" << std::endl;
  }
}

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

  FindResult* prefetched_results = new FindResult[batch_len];
  ValuePairs prefetched_vp = std::make_pair(0, prefetched_results);

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
#ifdef NOPREFETCH_JOINRESULT
    for (int i = 0; i < vp.first; i++) {
      ASSERT_TRUE(vp.first <= batch_len);
      result = vp.second[i];
      ASSERT_TRUE(result.id < workload.size());
      probe_elem =
          workload[result.id];  // basically random reads if r and s overlaps
      ASSERT_TRUE(probe_elem.key != 0);
      mvec[m_idx] = {probe_elem.key, probe_elem.value, result.value};
      m_idx++;
    }
#else
    for (int i = 0; i < prefetched_vp.first; i++) {
      result = prefetched_vp.second[i];
      probe_elem =
          workload[result.id];  // basically random reads if r and s overlaps
      mvec[m_idx] = {probe_elem.key, probe_elem.value, result.value};
      m_idx++;
    }

    for (int i = 0; i < vp.first; i++) {
      ASSERT_TRUE(vp.first <= batch_len);
      result = vp.second[i];
      ASSERT_TRUE(result.id < workload.size());
      __builtin_prefetch(&workload[result.id], false, 3);
      __builtin_prefetch(&mvec[(m_idx + i)], true, 3);
    }

    prefetched_vp.first = vp.first;
    prefetched_vp.second = vp.second;
#endif
#endif
  }

#ifndef NOPREFETCH_JOINRESULT
  // last iteration of loop will not actually saving last batch of the result
  for (int i = 0; i < prefetched_vp.first; i++) {
    result = prefetched_vp.second[i];
    probe_elem =
        workload[result.id];  // basically random reads if r and s overlaps
    mvec[m_idx] = {probe_elem.key, probe_elem.value, result.value};
    m_idx++;
  }
#endif

  // The rest are corner cases, don't need performance boost as bad. keep it
  // simple in case batch size is not divisible
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
  delete prefetched_results;
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
              std::barrier<std::function<void()>>* barrier) {
  BaseHashTable* ht = init_ht(config.relation_r_size, sh->shard_idx);
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
  sh->stats->found = found;
  sh->stats->ht_fill = ht->get_fill();
  sh->stats->ht_capacity = ht->get_capacity();
}


std::vector<BaseHashTable*> Global_HashTables;

// Partition Join
// 64-Byte Cache Line aligned buffer
struct alignas(64) CacheLineBuffer {
  Element tuples[4];
  uint32_t count = 0;

  inline void flush_nt(void* addr) {
    __m512i data = _mm512_load_si512(reinterpret_cast<const __m512i*>(tuples));
    _mm512_stream_si512(reinterpret_cast<__m512i*>(addr), data);
    count = 0;
  }
};

class RadixBucket {
 public:
  HugepageVec v;
  CacheLineBuffer buffer;
  uint64_t write_idx;
  uint64_t size;
  RadixBucket(uint64_t estimate) : write_idx(0), size(0) {
      v.resize(estimate);
      size = estimate;
  }

  inline void insert(Element& e) {
    buffer.tuples[buffer.count++] = e;

    // Once we have a full cache-line (4 tuples), flush it
    if (buffer.count == 4) {
      buffer.flush_nt(&v[write_idx]);
      write_idx += 4;
    }
  }

  // Crucial: Flush any remaining tuples at the end of the partition phase
  inline void flush() {
    for (uint32_t i = 0; i < buffer.count; ++i) {
      v[write_idx++] = buffer.tuples[i];
    }
    buffer.count = 0;

    // write idx is always right
    if(write_idx != size){
        v.resize(write_idx);
    }
  }
};

std::vector<std::vector<RadixBucket*>> Global_R_Buckets;
std::vector<std::vector<RadixBucket*>> Global_S_Buckets;
void radixjoin2016(Shard* sh, HugepageVec& build, HugepageVec& probe,
                             JoinVec& mvec,
                             std::barrier<std::function<void()>>* barrier) {
  uint64_t partition_num = 1 << 10;
  uint64_t radix_mask = partition_num - 1;
  uint64_t tid = sh->shard_idx;

  if (tid == 0) {
    cur_phase = ExecPhase::none;
    Global_HashTables.resize(partition_num);
    Global_R_Buckets.resize(config.num_threads);
    Global_S_Buckets.resize(config.num_threads);
  }

  std::vector<RadixBucket*> local_r;
  std::vector<RadixBucket*> local_s;
  local_r.resize(partition_num);
  local_s.resize(partition_num);

  uint64_t estimate_r_size = build.size() / config.num_threads * 1.2;
  uint64_t estimate_s_size = probe.size() / config.num_threads * 1.2;
  for (size_t i = 0; i < partition_num; ++i) {
    local_r[i] = new RadixBucket(estimate_r_size);
    local_s[i] = new RadixBucket(estimate_s_size);
  }

  Element e;
  uint64_t bucket_id;
  for (size_t i = 0; i < build.size(); ++i) {
    e = build[i];
    bucket_id = e.key & radix_mask;
    local_r[i]->insert(e);
  }

  for (size_t i = 0; i < probe.size(); ++i) {
    e = probe[i];
    bucket_id = e.key & radix_mask;
    local_s[i]->insert(e);
  }

  for (size_t i = 0; i < partition_num; ++i) {
      local_r[i]->flush();
      local_s[i]->flush();
  }

  Global_R_Buckets[tid] = local_r;
  Global_S_Buckets[tid] = local_s;

  barrier->arrive_and_wait();

  // Join
  for (int part_id = tid; part_id < partition_num;
       part_id += config.num_threads) {
    uint64_t ht_sz = 0;
    for (uint64_t thread_i = 0; thread_i < config.num_threads; ++thread_i) {
      ht_sz += Global_R_Buckets[thread_i][part_id]->write_idx;
    }

    BaseHashTable* ht = init_ht(ht_sz, tid);

    for (uint64_t thread_i = 0; thread_i < config.num_threads; ++thread_i) {
      RadixBucket* b = Global_R_Buckets[thread_i][part_id];
      ht_do_insert(ht, b->v);
    }

    for (uint64_t thread_i = 0; thread_i < config.num_threads; ++thread_i) {
      RadixBucket* b = Global_S_Buckets[thread_i][part_id];
      ht_do_find(ht, b->v, mvec);
    }

    Global_HashTables[part_id] = ht;
  }

  barrier->arrive_and_wait();

  for(BaseHashTable* ht: Global_HashTables){
     delete ht;
  }
}
// num_partitions
std::vector<std::vector<uint64_t>> Global_Histogram;
void radixjoin(Shard* sh, HugepageVec& build, HugepageVec& probe,
                  JoinVec& mvec, std::barrier<std::function<void()>>* barrier) {
  uint64_t partition_num = 1 << 10;
  uint64_t radix_mask = partition_num - 1;
  uint64_t tid = sh->shard_idx;

  if (tid == 0) {
    cur_phase = ExecPhase::none;
    Global_HashTables.resize(partition_num);
    Global_Histogram.resize(config.num_threads);
  }
  barrier->arrive_and_wait();

  std::vector<uint64_t> histogram(partition_num);

  Element e;
  uint64_t bucket_id;
  for (size_t i = 0; i < build.size(); ++i) {
    e = build[i];
    bucket_id = e.key & radix_mask;
    histogram[bucket_id]++;
  }

  Global_Histogram[tid] = histogram;
  barrier->arrive_and_wait();

  for (int part_id = tid; part_id < partition_num;
       part_id += config.num_threads) {
    uint64_t ht_sz = 0;
    for (uint64_t thread_i = 0; thread_i < config.num_threads; ++thread_i) {
      ht_sz += Global_Histogram[thread_i][part_id];
    }
    Global_HashTables[part_id] = init_ht(ht_sz, tid);
  }
  barrier->arrive_and_wait();

  // Insert
  uint64_t r_hash;
  for (size_t i = 0; i < build.size(); ++i) {
    e = build[i];
    r_hash = e.key & radix_mask;
    // Global_HashTables[r_hash]->insert(e);
  }

  barrier->arrive_and_wait();

  // Find
  for (size_t i = 0; i < probe.size(); ++i) {
    e = probe[i];
    r_hash = e.key & radix_mask;
    // Global_HashTables[r_hash]->find(e);
  }
  barrier->arrive_and_wait();

  for(BaseHashTable* ht: Global_HashTables){
     delete ht;
  }
}


#define HJ

void HashjoinTest::join_relations_generated(Shard* sh,
                                            const Configuration& config,
                                            BaseHashTable* ht, bool materialize,
                                            std::barrier<VoidFn>* barrier) {
  // global zipf value first populate relation_r, then append relation_s.
  uint64_t partition_sz_r = config.relation_r_size / config.num_threads;
  uint64_t partition_sz_s = config.relation_s_size / config.num_threads;

  if (sh->shard_idx == config.num_threads - 1) {
    partition_sz_r += config.relation_r_size % config.num_threads;
    partition_sz_s += config.relation_s_size % config.num_threads;
  }

  // This is slow as we need to copy.
  // But it ensures huge page and numa correctness.
  // This is good enough for generated workload,
  // if it aint broke, don't fix it....
  HugepageVec build_relation(partition_sz_r, hugepage_alloc_inst_relation);
  HugepageVec probe_relation(partition_sz_s, hugepage_alloc_inst_relation);
  JoinVec join_relation(partition_sz_s, hugepage_alloc_inst_join);
  // Copy data from global vec into hugepage back vec.
  Element e;
  uint64_t workload_idx = 0;
  uint64_t offset = config.relation_r_size / config.num_threads * sh->shard_idx;
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
  offset = config.relation_r_size +
           config.relation_s_size / config.num_threads * sh->shard_idx;
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

  #ifdef HJ
  hashjoin(sh, build_relation, probe_relation, join_relation, barrier);
  #elif RJ16
  radixjoin2016(sh, build_relation, probe_relation, join_relation, barrier);
  #elif RJ
  radixjoin(sh, build_relation, probe_relation, join_relation, barrier);
  #else
  #endif
}

void HashjoinTest::join_relations_from_files(Shard* sh,
                                             const Configuration& config,
                                             BaseHashTable* ht,
                                             std::barrier<VoidFn>* barrier) {
  input_reader::KeyValueCsvPreloadReader t1(config.relation_r, sh->shard_idx,
                                            config.num_threads, "|");
  input_reader::KeyValueCsvPreloadReader t2(config.relation_s, sh->shard_idx,
                                            config.num_threads, "|");
}

}  // namespace kmercounter
