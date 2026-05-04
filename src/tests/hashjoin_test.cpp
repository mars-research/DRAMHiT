/// This file implements Hash Join.
// Relevant resources:
// * Hash join: https://dev.mysql.com/worklog/task/?id=2241
// * Add support for hash outer, anti and semi join:
// https://dev.mysql.com/worklog/task/?id=13377
// * Optimize hash table in hash join:
// https://dev.mysql.com/worklog/task/?id=13459
#include <unistd.h>

#include <algorithm>
#include <atomic>
#include <barrier>
#include <chrono>
#include <cmath>
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
#include "eth_hashjoin/src/types.h"
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

//#define DEBUG_HJ
//#define MATERIALIZE
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
JoinHugepageAlloc hugepage_alloc_inst_join_element;

using Element = KeyValuePair;
using HugepageAlloc = huge_page_allocator<Element>;
using HugepageVec = std::vector<Element, HugepageAlloc>;
HugepageAlloc hugepage_alloc_inst_element;


#define ELE_NUM_PER_CACHE_LINE ((CACHELINE_SIZE) / sizeof(Element))
#define PREFETCHES_AHEAD ((ELE_NUM_PER_CACHE_LINE) * (PREFETCH_AHEAD_X_CACHELINE))


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
  size_t batch_num = requests_num / batch_len;
  size_t idx = 0;

  // force ELE_NUM_PER_CACHE_LINE pow of 2. 2 < 16
  for (unsigned int n = 0; n < batch_num; n++) {
    // on each batch, populate find args
    for (unsigned int i = 0; i < batch_len; i++) {
      if (!(idx & (ELE_NUM_PER_CACHE_LINE - 1)) &&
          (idx + PREFETCHES_AHEAD < requests_num)) {
        __builtin_prefetch(&workload[idx + PREFETCHES_AHEAD], false, 3);
      }

      Element& e = workload[idx];
      items[i].key = e.key;
      items[i].value = e.value;
      items[i].id = idx;
      idx++;
    }

    ht->insert_batch(InsertFindArguments(items, batch_len), collector);
  }

  // in case batch size is not divisible
  size_t residue_num = requests_num - batch_len * batch_num;
  if (residue_num > 0) {
    for (size_t i = 0; i < residue_num; i++) {
      if (!(idx & (ELE_NUM_PER_CACHE_LINE - 1)) &&
          (idx + PREFETCHES_AHEAD < requests_num)) {
        __builtin_prefetch(&workload[idx + PREFETCHES_AHEAD], false, 3);
      }
      Element& e = workload[idx];
      items[i].key = e.key;
      items[i].value = e.value;
      items[i].id = idx;
      idx++;
    }

    ht->insert_batch(InsertFindArguments(items, residue_num), collector);
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

  size_t batch_num = requests_num / batch_len;
  size_t idx = 0;
  size_t m_idx = 0;

  ASSERT_TRUE(batch_len % 2 == 0 && batch_len > 0);

  FindResult* prefetched_results = new FindResult[batch_len];
  ValuePairs prefetched_vp = std::make_pair(0, prefetched_results);

  // force ELE_NUM_PER_CACHE_LINE pow of 2. 2 < 16
  for (unsigned int n = 0; n < batch_num; n++) {
    // on each batch, populate find args
    for (unsigned int i = 0; i < batch_len; i++) {
      if (!(idx & (ELE_NUM_PER_CACHE_LINE - 1)) &&
          (idx + PREFETCHES_AHEAD < requests_num)) {
        __builtin_prefetch(&workload[idx + PREFETCHES_AHEAD], false, 3);
      }
      Element& e = workload[idx];
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
      FindResult& result = vp.second[i];
      ASSERT_TRUE(result.id < workload.size());
      Element& probe_elem =
          workload[result.id];  // basically random reads if r and s overlaps
      ASSERT_TRUE(probe_elem.key != 0);
      mvec[m_idx] = {probe_elem.key, probe_elem.value, result.value};
      m_idx++;
    }
#else
    for (unsigned int i = 0; i < prefetched_vp.first; i++) {
      FindResult& result = prefetched_vp.second[i];
      Element& probe_elem =
          workload[result.id];  // basically random reads if r and s overlaps
      mvec[m_idx] = {probe_elem.key, probe_elem.value, result.value};
      m_idx++;
    }

    for (unsigned int i = 0; i < vp.first; i++) {
      ASSERT_TRUE(vp.first <= batch_len);
      FindResult& result = vp.second[i];
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
  for (unsigned int i = 0; i < prefetched_vp.first; i++) {
    FindResult& result = prefetched_vp.second[i];
    // basically random reads if r and s overlaps
    Element& probe_elem = workload[result.id];
    mvec[m_idx] = {probe_elem.key, probe_elem.value, result.value};
    m_idx++;
  }
#endif

  // The rest are corner cases, don't need performance boost as bad. keep it
  // simple in case batch size is not divisible
  size_t residue_num = requests_num - batch_len * batch_num;
  if (residue_num > 0) {
    for (size_t i = 0; i < residue_num; i++) {
      if (!(idx & (ELE_NUM_PER_CACHE_LINE - 1)) &&
          (idx + PREFETCHES_AHEAD < requests_num)) {
        __builtin_prefetch(&workload[idx + PREFETCHES_AHEAD], false, 3);
      }
      Element& e = workload[idx];
      items[i].key = e.key;
      items[i].id = idx;
      idx++;
    }
    vp.first = 0;
    ht->find_batch(InsertFindArguments(items, residue_num), vp, collector);
    found += vp.first;
#ifdef MATERIALIZE
    for (unsigned int i = 0; i < vp.first; i++) {
      ASSERT_TRUE(vp.first <= batch_len);
      FindResult& result = vp.second[i];
      ASSERT_TRUE(result.id < workload.size());
      Element& probe_elem = workload[result.id];  // basically random reads
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
    for (unsigned int i = 0; i < vp.first; i++) {
      ASSERT_TRUE(vp.first <= batch_len);
      FindResult& result = vp.second[i];
      ASSERT_TRUE(result.id < workload.size());
      Element& probe_elem = workload[result.id];  // basically random reads
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
  uint64_t ht_size = config.relation_r_size * 100 / config.ht_fill;
  BaseHashTable* ht = init_ht(ht_size, sh->shard_idx);
  // config.ht_size = utils::next_pow2(config.ht_size);
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

  if (sh->shard_idx == 0) {
    uint64_t fill = ht->get_fill();
    uint64_t capacity = ht->get_capacity();
    PLOGI.printf("hashtable fill %lu out of %lu", fill, capacity);
  }
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
  Element* v;  // v_offset to v_offset + size
  CacheLineBuffer buffer;
  uint64_t v_start;
  uint64_t v_end;
  uint64_t v_idx;
  uint64_t v_len;
  size_t v_id;
  RadixBucket(uint64_t start, uint64_t end, uint64_t len, Element* v_ref,
              size_t id)
      : v(v_ref),
        v_idx(start),
        v_start(start),
        v_end(end),
        v_len(len),
        v_id(id) {}

  inline void insert(Element& e) {
    buffer.tuples[buffer.count++] = e;
    // Once we have a full cache-line (4 tuples), flush it
    if (buffer.count == 4) {
      // PLOGI.printf("id %u writing to v[%lu] v_end %lu", v_id, v_idx, v_end);
      ASSERT_TRUE(v_idx + 4 <= v_end);
      ASSERT_TRUE(v_idx % 4 == 0);  // alignment
      buffer.flush_nt(&v[v_idx]);
      v_idx += 4;
    }
  }

  // Crucial: Flush any remaining tuples at the end of the partition phase
  inline void flush() {
    for (uint32_t i = 0; i < buffer.count; ++i) {
      ASSERT_TRUE(v_idx <= v_end);
      v[v_idx++] = buffer.tuples[i];
    }
    // PLOGI.printf("id %u flushed v_start %lu v_end %lu v_idx %lu v_len %lu",
    // v_id, v_start, v_enKV* d, v_idx, v_len);
    buffer.count = 0;
  }
};

class RadixArrayHashTable {
 public:
  Element* vec;
  uint64_t size;
  static const key_type empty_key = 0;
  static const value_type empty_value = 0;
  Hasher hasher;
  RadixArrayHashTable(uint64_t sz, Element* v_ref) : size(sz), vec(v_ref) {}

  uint64_t hash(key_type k) { return (hasher(&k, 64) & (size - 1)); }

  void insert(Element& e) {
    uint64_t idx = hash(e.key);
    while (1) {
      ASSERT_TRUE(idx < size);
      if (vec[idx].key == empty_key) {
        vec[idx] = e;
        return;
      }

      if (vec[idx].key == e.key) {
        vec[idx].value = e.value;
        return;
      }
      idx++;
      idx = idx & (size - 1);
    }
  }

  value_type find(Element& e) {
    uint64_t idx = hash(e.key);
    while (1) {
      ASSERT_TRUE(idx < size);
      if (vec[idx].key == empty_key) {
        return empty_value;
      }

      if (vec[idx].key == e.key) {
        return vec[idx].value;
      }
      idx++;
      idx = idx & (size - 1);
    }
  }
};

std::vector<std::vector<RadixBucket*>> Global_R_Buckets;
std::vector<std::vector<RadixBucket*>> Global_S_Buckets;
std::vector<std::vector<uint64_t>> Global_Histogram;

inline void print_histogram_stats(const std::vector<uint64_t>& histogram,
                                  int tid, char* str) {
  if (histogram.empty()) {
    PLOGI.printf("[tid: %d] Histogram is empty.\n", tid);
    return;
  }

  uint64_t min_val = std::numeric_limits<uint64_t>::max();
  uint64_t max_val = 0;
  uint64_t sum = 0;

  // Pass 1: Get Min, Max, and Sum for the Average
  for (uint64_t val : histogram) {
    min_val = std::min(min_val, val);
    max_val = std::max(max_val, val);
    sum += val;
  }

  double avg = static_cast<double>(sum) / histogram.size();

  // Pass 2: Calculate the sum of squared differences for Variance
  double variance_sum = 0.0;
  for (uint64_t val : histogram) {
    double diff = static_cast<double>(val) - avg;
    variance_sum += (diff * diff);  // Square the difference
  }

  // Calculate Variance and Standard Deviation
  double variance = variance_sum / histogram.size();
  double std_dev = std::sqrt(variance);

  // --- Construct the atomic output string ---
  std::string output;
  char buffer[512];  // Buffer for formatting individual lines

  // Append stats
  snprintf(buffer, sizeof(buffer),
           "\n%s [tid: %d] min: %lu, max: %lu, avg: %.1f, std_dev: %.2f\n", str,
           tid, min_val, max_val, avg, std_dev);
  output += buffer;

  // Append histogram header
  snprintf(buffer, sizeof(buffer),
           "--- Histogram Visualization [tid: %d] ---\n", tid);
  output += buffer;

  const int MAX_BAR_LENGTH = 30;

  // Append each bucket's visual bar
  for (size_t i = 0; i < histogram.size(); ++i) {
    uint64_t val = histogram[i];

    int num_asterisks = 0;
    if (max_val > 0) {
      num_asterisks = static_cast<int>((static_cast<double>(val) / max_val) *
                                       MAX_BAR_LENGTH);
    }

    std::string bar(num_asterisks, '*');

    snprintf(buffer, sizeof(buffer), "Bucket %3zu | %-50s (%lu)\n", i,
             bar.c_str(), val);
    output += buffer;
  }

  output += "-----------------------------------------\n";

  // Single atomic log call to prevent thread interleaving
  PLOGI.printf("%s", output.c_str());
}

void radixjoin2016(Shard* sh, HugepageVec& build, HugepageVec& probe,
                   JoinVec& mvec,
                   std::barrier<std::function<void()>>* barrier) {
  uint64_t partition_num = 1 << config.radix;
  uint64_t radix_mask = partition_num - 1;
  uint64_t tid = sh->shard_idx;

  std::vector<RadixBucket*> local_r(partition_num);
  std::vector<RadixBucket*> local_s(partition_num);
  std::vector<uint64_t> r_histogram(partition_num);
  std::vector<uint64_t> s_histogram(partition_num);
  for (size_t i = 0; i < partition_num; ++i) {
    r_histogram[i] = 0;
    s_histogram[i] = 0;
  }

  if (tid == 0) {
   // Global_HashTables.resize(partition_num);
    Global_R_Buckets.resize(config.num_threads);
    Global_S_Buckets.resize(config.num_threads);
   // Global_Histogram.resize(config.num_threads);

    cur_phase = ExecPhase::insertions;
    g_app_record_start = true;
    PLOGI.printf("partition num %lu %u", partition_num, config.radix);
  }
  barrier->arrive_and_wait();


  if (tid == 0) {
    cur_phase = ExecPhase::finds;
    g_app_record_start = true;
  }
  barrier->arrive_and_wait();
  uint64_t bucket_id;
  for (size_t i = 0; i < build.size(); ++i) {
    Element& e = build[i];
    bucket_id = e.key & radix_mask;
    ASSERT_TRUE(bucket_id < partition_num);
    r_histogram[bucket_id]++;
  }

  for (size_t i = 0; i < probe.size(); ++i) {
    Element& e = probe[i];
    bucket_id = e.key & radix_mask;
    ASSERT_TRUE(bucket_id < partition_num);
    s_histogram[bucket_id]++;
  }

  uint64_t phrase1_cycle = 0;
  if (tid == 0) {
    cur_phase = ExecPhase::finds;
    g_app_record_start = false;
  }
  barrier->arrive_and_wait();
  if(tid == 0) {
      phrase1_cycle = g_find_end - g_find_start;
      PLOGI.printf("took %lu cycles for phrase1", phrase1_cycle);
  }

  // 1. Calculate the total padded sizes first
  uint64_t total_build_capacity = 0;
  uint64_t total_probe_capacity = 0;

  for (size_t i = 0; i < partition_num; ++i) {
    // (x + 3) & ~3ULL rounds up to the nearest multiple of 4
    total_build_capacity += (r_histogram[i] + 3) & ~3ULL;
    total_probe_capacity += (s_histogram[i] + 3) & ~3ULL;
  }

  uint64_t duration;
  if(tid == 0){
      duration = RDTSC_START();
  }
  // 2. Allocate memory for buckets, this is avoid frequent mmap call
  Element* build_storage = hugepage_alloc_inst_element.allocate(total_build_capacity);
  Element* probe_storage = hugepage_alloc_inst_element.allocate(total_probe_capacity);

  if(tid == 0){
      duration = RDTSCP() - duration;
      PLOGI.printf("took %lu cycles for allocation", duration);
  }
  // 3. Set up the buckets
  uint64_t r_offset = 0;
  uint64_t s_offset = 0;

  for (size_t i = 0; i < partition_num; ++i) {
    // --- BUILD (R) ---
    uint64_t r_length = r_histogram[i];
    uint64_t r_capacity = (r_length + 3) & ~3ULL;  // Padded to multiple of 4

    // Pass the capacity boundary so your ASSERT_TRUE(v_idx+4 <= v_end) doesn't
    // fail when you flush the final cache line with padding.
    local_r[i] = new RadixBucket(r_offset, r_offset + r_capacity, r_length,
                                 build_storage, i);

    r_offset += r_capacity;  // Advance by the aligned capacity

    // --- PROBE (S) ---
    uint64_t s_length = s_histogram[i];
    uint64_t s_capacity = (s_length + 3) & ~3ULL;  // Padded to multiple of 4

    local_s[i] = new RadixBucket(s_offset, s_offset + s_capacity, s_length,
                                 probe_storage, i);

    s_offset += s_capacity;  // Advance by the aligned capacity
  }

  if (tid == 0) {
    cur_phase = ExecPhase::finds;
    g_app_record_start = true;
  }
  barrier->arrive_and_wait();

  for (size_t i = 0; i < build.size(); ++i) {
    Element& e = build[i];
    bucket_id = e.key & radix_mask;
    ASSERT_TRUE(bucket_id < partition_num);
    local_r[bucket_id]->insert(e);
  }

  for (size_t i = 0; i < probe.size(); ++i) {
    Element& e = probe[i];
    bucket_id = e.key & radix_mask;
    ASSERT_TRUE(bucket_id < partition_num);
    local_s[bucket_id]->insert(e);
  }

  for (size_t i = 0; i < partition_num; ++i) {
    local_r[i]->flush();
    local_s[i]->flush();
    ASSERT_TRUE(local_r[i]->v_start + local_r[i]->v_len == local_r[i]->v_idx);
    ASSERT_TRUE(local_s[i]->v_start + local_s[i]->v_len == local_s[i]->v_idx);
  }

  Global_R_Buckets[tid] = local_r;
  Global_S_Buckets[tid] = local_s;

  uint64_t phrase3_cycle = 0;
  if (tid == 0) {
    cur_phase = ExecPhase::finds;
    g_app_record_start = false;
  }
  barrier->arrive_and_wait();
  if(tid == 0) {
      phrase3_cycle = g_find_end - g_find_start;
      PLOGI.printf("took %lu cycles for phrase3", phrase3_cycle);
  }

  // Completion of partition phrase
  if (tid == 0) {
    cur_phase = ExecPhase::insertions;
    g_app_record_start = false;
  }
  barrier->arrive_and_wait();
  sh->stats->insertions.duration = g_insert_end - g_insert_start;
  sh->stats->insertions.op_count = build.size() + probe.size();

#ifdef DEBUG_HJ
  print_histogram_stats(r_histogram, tid, "r");
  print_histogram_stats(s_histogram, tid, "s");
#endif

  // Join Phase
  if (tid == 0) {
    cur_phase = ExecPhase::finds;
    g_app_record_start = true;
  }
  barrier->arrive_and_wait();


  uint64_t found = 0;
#ifdef RADIX_DO_JOIN
  for (size_t part_id = tid; part_id < partition_num;
       part_id += config.num_threads) {
    uint64_t build_sz = 0;
    for (uint64_t thread_i = 0; thread_i < config.num_threads; ++thread_i) {
      RadixBucket* b = Global_R_Buckets[thread_i][part_id];
      build_sz += (b->v_end - b->v_start);
    }
    // BaseHashTable* ht = init_ht(ht_sz, tid);

    uint64_t ht_sz = build_sz * 100 / config.ht_fill;
    ht_sz = kmercounter::utils::next_pow2(ht_sz);
#ifdef DEBUG_HJ
    //PLOGI.printf("part id %lu hashtable sz %lu MB, build_sz %lu MB", part_id,
    //             (ht_sz * sizeof(Element) / (1024 * 1024)), build_sz * sizeof(Element)/(1024 * 1024));
#endif
    HugepageVec ht_storage(ht_sz, hugepage_alloc_inst_element);
    for(uint64_t i = 0; i<ht_sz; i++)
        ht_storage[i].key = ht_storage[i].value = 0;
    RadixArrayHashTable ht(ht_sz, ht_storage);

    // std::unordered_set<key_type> ht(ht_sz);
    for (uint64_t thread_i = 0; thread_i < config.num_threads; ++thread_i) {
      RadixBucket* b = Global_R_Buckets[thread_i][part_id];
      // ht_do_insert(ht, b->v);
      for (uint32_t i = b->v_start; i < b->v_start + b->v_len; i++) {
        // ht.insert(b->v[i]);
      }
    }

    #ifdef DEBUG_HJ
       // PLOGI.printf("part id %lu insertion done", part_id);
    #endif
    // find
    for (uint64_t thread_i = 0; thread_i < config.num_threads; ++thread_i) {
      RadixBucket* b = Global_S_Buckets[thread_i][part_id];
      // ht_do_find(ht, b->v, mvec);
      for (uint32_t i = b->v_start; i < b->v_start + b->v_len; i++) {
        //if (ht.find(b->v[i]) > 0) found++;
      }
    }

    // Global_HashTables[part_id] = ht;
  }
#endif

  if (tid == 0) {
    cur_phase = ExecPhase::finds;
    g_app_record_start = false;
  }
  barrier->arrive_and_wait();

  sh->stats->finds.duration = g_find_end - g_find_start;
  sh->stats->finds.op_count = build.size() + probe.size();
  sh->stats->found = found;

  //for (BaseHashTable* ht : Global_HashTables) {
  //  delete ht;
  //}

  for (size_t i = 0; i < partition_num; ++i) {
    delete local_r[i];
    delete local_s[i];
  }
}
// num_partitions
void radixjoin(Shard* sh, HugepageVec& build, HugepageVec& probe, JoinVec& mvec,
               std::barrier<std::function<void()>>* barrier) {
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

  for (uint64_t part_id = tid; part_id < partition_num;
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

  for (BaseHashTable* ht : Global_HashTables) {
    delete ht;
  }
}

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
  HugepageVec build_relation(partition_sz_r, hugepage_alloc_inst_element);
  HugepageVec probe_relation(partition_sz_s, hugepage_alloc_inst_element);
  JoinVec join_relation(partition_sz_s, hugepage_alloc_inst_join_element);
  // Copy data from global vec into hugepage back vec.
  Element e;
  uint64_t workload_idx = 0;
  uint64_t offset = config.relation_r_size / config.num_threads * sh->shard_idx;
  for (uint64_t i = 0; i < partition_sz_r; i++) {
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
  for (uint64_t i = 0; i < partition_sz_s; i++) {
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

  if (config.mode == HASHJOIN) {
    hashjoin(sh, build_relation, probe_relation, join_relation, barrier);
  } else if (config.mode == PARTITIONJOINV1) {
    radixjoin2016(sh, build_relation, probe_relation, join_relation, barrier);
  } else if (config.mode == PARTITIONJOINV2) {
    radixjoin(sh, build_relation, probe_relation, join_relation, barrier);
  } else {
    PLOGE.printf("Unsupported mode for join");
    abort();
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
}

}  // namespace kmercounter
