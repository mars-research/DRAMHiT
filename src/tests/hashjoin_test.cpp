/// This file implements Hash Join.
// Relevant resources:
// * Hash join: https://dev.mysql.com/worklog/task/?id=2241
// * Add support for hash outer, anti and semi join:
// https://dev.mysql.com/worklog/task/?id=13377
// * Optimize hash table in hash join:
// https://dev.mysql.com/worklog/task/?id=13459
#include <sys/mman.h>
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
// #include "input_reader/eth_rel_gen.hpp"
#include "misc_lib.h"
#include "plog/Log.h"
// #include "print_stats.h"
// #include "queues/section_queues.hpp"
#include "hasher.hpp"
#include "helper.hpp"
#include "sync.h"
#include "tests/HashjoinTest.hpp"
#include "types.hpp"
#include "utils/hugepage_allocator.hpp"
#include "utils/hugepage_arena.hpp"
#include "zipf_distribution.hpp"
#include "hashtables/cas_kht_st.hpp"
// #include "hashtables/cas_kht_st.hpp"
// #define DEBUG_HJ
// #define MATERIALIZE
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

using Element = KeyValuePair;
using HugepageAlloc = huge_page_allocator<Element>;
using HugepageVec = std::vector<Element, HugepageAlloc>;

JoinHugepageAlloc hugepage_alloc_inst_join_element;
HugepageAlloc hugepage_alloc_inst_element;

#define CACHELINE_SIZE 64
#define ELE_NUM_PER_CACHE_LINE ((CACHELINE_SIZE) / sizeof(Element))
#define PREFETCHES_AHEAD \
  ((ELE_NUM_PER_CACHE_LINE) * (PREFETCH_AHEAD_X_CACHELINE))

//#define RADIX_KNUTH
inline uint64_t radix_hash(uint64_t k, uint64_t r_mask) {
#ifdef RADIX_KNUTH
  return (k * 11400714819323198485ULL) & r_mask;
#else
  return (k)&r_mask;
#endif
}

void init_hashjoin_dist(double skew, double hit_rate, int64_t seed,
                        uint64_t r_size, uint64_t s_size) {
  uint64_t total_size = r_size + s_size;
  size_t expected_bytes = total_size * sizeof(key_type);

  if (g_zipf_values != nullptr) {
    delete g_zipf_values;
    PLOGE.printf("g_zipf_values should be null");
    abort();
  }

  g_zipf_values = new std::vector<key_type>(total_size);

  // Update filename to include hit_rate
  std::ostringstream filename_stream;
  filename_stream << "/opt/DRAMHiT/cache/" << "hashjoin"
                  << "_r" << r_size << "_s" << s_size << "_skew" << skew
                  << "_hit" << hit_rate << "_seed" << seed << ".bin";

  std::string filename = filename_stream.str();

  if (std::filesystem::exists(filename)) {
    if (std::filesystem::file_size(filename) == expected_bytes) {
      std::cout << "Loading cached dataset from disk (" << filename << ")..."
                << std::endl;
      std::ifstream infile(filename, std::ios::binary);
      if (infile) {
        infile.read(reinterpret_cast<char*>(g_zipf_values->data()),
                    expected_bytes);
        return;
      }
    } else {
      std::cout << "Cache size mismatch. Regenerating..." << std::endl;
    }
  }

  std::cout << "Generating hashjoin dataset..." << std::endl;

  // Multiplier to scatter sequential IDs into pseudo-random unique keys
  constexpr uint64_t GOLDEN_PRIME = 0x9E3779B97F4A7C15ULL;

  // ---------------------------------------------------------
  // 1. Populate Build Relation R (Guaranteed Unique & Seeded)
  // ---------------------------------------------------------

  // Set up an RNG specifically for the build phase using the passed seed
  std::mt19937_64 build_rng(seed);
  std::uniform_int_distribution<uint64_t> offset_dist(1, 1000000000ULL);
  uint64_t seed_offset = offset_dist(build_rng);

  for (uint64_t r_index = 0; r_index < r_size; ++r_index) {
    // Generate a unique, pseudo-random key influenced by the seed offset
    // Because GOLDEN_PRIME is odd, this is a perfect bijection (no collisions possible)
    (*g_zipf_values)[r_index] = (r_index + seed_offset) * GOLDEN_PRIME;
  }

  // ---------------------------------------------------------
  // 2. Populate Probe Relation S (Skewed + Configurable Hit Rate)
  // ---------------------------------------------------------
  std::uint64_t keyrange_width = (1ull << 63);
  if constexpr (std::is_same_v<key_type, std::uint32_t>) {
    keyrange_width = (1ull << 31);
  }
  zipf_distribution_apache distribution(keyrange_width, skew, seed);

  std::mt19937_64 rng(seed);
  std::uniform_real_distribution<double> match_prob(0.0, 1.0);

  for (uint64_t s_index = 0; s_index < s_size; ++s_index) {
    uint64_t zipf_val = distribution.sample();

    if (match_prob(rng) <= hit_rate) {
      // MATCH: Use the Zipf value to pick a skewed index inside R
      uint64_t r_target_idx = zipf_val % r_size;
      (*g_zipf_values)[r_size + s_index] = (*g_zipf_values)[r_target_idx];
    } else {
      // NO MATCH: Generate a key strictly outside of R's domain.
      // Since R uses bases 1 to r_size, we use bases > r_size.
      // We still use zipf_val so the unmatched keys also exhibit skew!
      (*g_zipf_values)[r_size + s_index] =
          zipf_val;  // (zipf_val + 1) * GOLDEN_PRIME;
    }
  }

  std::cout << "Saving dataset to disk..." << std::endl;
  std::ofstream outfile(filename, std::ios::binary);
  if (outfile) {
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

void ht_do_insert(BaseHashTable* ht, Element* workload, uint64_t len) {
  uint64_t requests_num = len;
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

uint64_t ht_do_find(BaseHashTable* ht, Element* workload, JoinElement* mvec, uint64_t len) {
  uint64_t found = 0;
  uint64_t requests_num = len;
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
      ASSERT_TRUE(result.id < len);
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
      ASSERT_TRUE(result.id < len);
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
      ASSERT_TRUE(result.id < len);
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
      ASSERT_TRUE(result.id < len);
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


/// Perform hashjoin on relation `t1` and `t2`.
/// `t1` is the primary key relation and `t2` is the foreign key relation.
void hashjoin(Shard* sh, Element* build, Element* probe, JoinElement* mvec,
              std::barrier<std::function<void()>>* barrier, uint64_t partition_sz_r, uint64_t partition_sz_s) {
  uint64_t ht_size = config.relation_r_size * 100 / config.ht_fill;
  BaseHashTable* ht = init_ht(ht_size, sh->shard_idx);

  // Measure Build
  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::insertions;
    g_app_record_start = true;
  }
  barrier->arrive_and_wait();

  ht_do_insert(ht, build, partition_sz_r);

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::insertions;
    g_app_record_start = false;
  }
  barrier->arrive_and_wait();

  sh->stats->insertions.op_count = partition_sz_r;
  sh->stats->insertions.duration = g_insert_end - g_insert_start;

  // Measure Probe
  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::finds;
    g_app_record_start = true;
  }
  barrier->arrive_and_wait();

  uint64_t found = ht_do_find(ht, probe, mvec, partition_sz_s);

  if (sh->shard_idx == 0) {
    cur_phase = ExecPhase::finds;
    g_app_record_start = false;
  }
  barrier->arrive_and_wait();

  sh->stats->finds.op_count = partition_sz_s;
  sh->stats->finds.duration = g_find_end - g_find_start;
  sh->stats->found = found;
#ifdef CALC_STATS
  sh->stats->num_reprobes = ht->num_reprobes;
#endif

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
  uint64_t count = 0;

  inline void flush_nt(void* addr) {
    __m512i data = _mm512_load_si512(reinterpret_cast<const __m512i*>(tuples));
    _mm512_stream_si512(reinterpret_cast<__m512i*>(addr), data);
    count = 0;
  }
};

class alignas(64) RadixBucket {
public:
  CacheLineBuffer buffer;
  Element* v;        // Pointer to the EXACT start of this bucket's slice
  uint64_t v_idx;    // Local write index, always starts at 0
  uint64_t v_cap;    // The padded capacity (replaces v_end for boundary checks)
  uint64_t v_len;    // The actual number of tuples
  size_t v_id;

  RadixBucket(Element* slice_start, uint64_t capacity, uint64_t len, size_t id)
      : v(slice_start),
        v_idx(0),
        v_cap(capacity),
        v_len(len),
        v_id(id) {}

  inline void insert(Element& e) {
    buffer.tuples[buffer.count++] = e;
    // Once we have a full cache-line (4 tuples), flush it
    if (buffer.count == 4) {
      // v_idx is local now, so we check it against capacity
      ASSERT_TRUE(v_idx + 4 <= v_cap);
      ASSERT_TRUE(v_idx % 4 == 0);  // alignment

      buffer.flush_nt(&v[v_idx]);
      v_idx += 4;
    }
  }

  // Crucial: Flush any remaining tuples at the end of the partition phase
  inline void flush() {
    for (uint32_t i = 0; i < buffer.count; ++i) {
      ASSERT_TRUE(v_idx < v_cap); // Check against capacity
      v[v_idx++] = buffer.tuples[i];
    }
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

  RadixArrayHashTable(uint64_t sz, Element* v_ref) : vec(v_ref), size(sz) {
    // Best practice: Ensure size is actually a power of 2
    // so that `idx & (size - 1)` actually works correctly.
  }

  // FIXED: Read exactly the bytes of the key, no more.
  inline uint64_t hash(key_type k) {
    return (hasher(&k, sizeof(key_type)) & (size - 1));
  }

  inline void insert(const Element& e) {
    uint64_t idx = hash(e.key);
    vec[idx] = e;
    return;
    uint64_t probes = 0;  // Guard against infinite loops

    while (probes < size) {
      // Assuming ASSERT_TRUE compiles out in Release
      ASSERT_TRUE(idx < size);

      if (vec[idx].key == empty_key) {
        vec[idx] = e;
        return;
      }

      if (vec[idx].key == e.key) {
        vec[idx].value = e.value;
        return;
      }

      idx = (idx + 1) & (size - 1);
      probes++;
    }

    // If you reach here, the table is 100% full.
    throw std::runtime_error("HashTable is full!");
  }

  inline value_type find(const Element& e) {
    uint64_t idx = hash(e.key);
    return vec[idx].value;

    uint64_t probes = 0;

    while (probes < size) {
      ASSERT_TRUE(idx < size);

      if (vec[idx].key == empty_key) {
        return empty_value;
      }

      if (vec[idx].key == e.key) {
        return vec[idx].value;
      }

      idx = (idx + 1) & (size - 1);
      probes++;
    }

    return empty_value;
  }
};

RadixBucket** Global_R_Buckets;
RadixBucket** Global_S_Buckets;

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

void radixjoin2016(Shard* sh, Element* build, Element* probe,
                   JoinElement* mvec,
                   std::barrier<std::function<void()>>* barrier, uint64_t partition_sz_r,
                   uint64_t partition_sz_s) {
  uint64_t partition_num = 1 << config.radix;
  uint64_t radix_mask = partition_num - 1;
  uint64_t tid = sh->shard_idx;

  huge_page_allocator<RadixBucket> bucket_allocator;
  huge_page_allocator<char> byte_allocator;
  RadixBucket* local_r = bucket_allocator.allocate(partition_num);
  RadixBucket* local_s = bucket_allocator.allocate(partition_num);
  std::vector<uint64_t> r_histogram(partition_num);
  std::vector<uint64_t> s_histogram(partition_num);
  for (size_t i = 0; i < partition_num; ++i) {
    r_histogram[i] = 0;
    s_histogram[i] = 0;
  }

  // Arena mmap hugepages and zero them.
  // This is done so that because radix must
  // first do a histogram building to determine
  // size of radix buckets.
  // In a more realistic system like db,
  // there will be some allocator that essentially
  // will keep system memory warm.
  HugepageArena<Element> arena(1, 2);

  if (tid == 0) {
    Global_R_Buckets = (RadixBucket**) byte_allocator.allocate(sizeof(RadixBucket*) * config.num_threads);
    Global_S_Buckets = (RadixBucket**) byte_allocator.allocate(sizeof(RadixBucket*) * config.num_threads);
    cur_phase = ExecPhase::insertions;
    g_app_record_start = true;
    PLOGI.printf("partition num %lu %u", partition_num, config.radix);
  }
  barrier->arrive_and_wait();

  // if (tid == 0) {
  //   cur_phase = ExecPhase::finds;
  //   g_app_record_start = true;
  // }
  // barrier->arrive_and_wait();
  uint64_t bucket_id;
  for (size_t i = 0; i < partition_sz_r ; ++i) {
    Element& e = build[i];
    bucket_id = radix_hash(e.key, radix_mask);
    ASSERT_TRUE(bucket_id < partition_num);
    r_histogram[bucket_id]++;
  }

  for (size_t i = 0; i < partition_sz_s; ++i) {
    Element& e = probe[i];
    bucket_id = radix_hash(e.key, radix_mask);
    ASSERT_TRUE(bucket_id < partition_num);
    s_histogram[bucket_id]++;
  }

  // uint64_t phrase1_cycle = 0;
  // if (tid == 0) {
  //   cur_phase = ExecPhase::finds;
  //   g_app_record_start = false;
  // }
  // barrier->arrive_and_wait();
  // if (tid == 0) {
  //   phrase1_cycle = g_find_end - g_find_start;
  //   PLOGI.printf("took %lu cycles for phrase1", phrase1_cycle);
  // }

  // 1. Calculate the total padded sizes first
  uint64_t total_build_capacity = 0;
  uint64_t total_probe_capacity = 0;

  for (size_t i = 0; i < partition_num; ++i) {
    // (x + 3) & ~3ULL rounds up to the nearest multiple of 4
    total_build_capacity += (r_histogram[i] + 3) & ~3ULL;
    total_probe_capacity += (s_histogram[i] + 3) & ~3ULL;
  }

  // uint64_t duration;
  // if (tid == 0) {
  //   duration = RDTSC_START();
  // }
  // 2. Allocate memory for buckets
  //Element* build_storage = arena.aligned_alloc(total_build_capacity, 64);
  //Element* probe_storage = arena.aligned_alloc(total_probe_capacity, 64);

  // if (tid == 0) {
  //   duration = RDTSCP() - duration;
  //   PLOGI.printf("took %lu cycles for allocation", duration);
  // }

  // 3. Set up the buckets
  uint64_t r_offset = 0;
  uint64_t s_offset = 0;

  // This add paddings, so each partition bucket is align to cacheline sized
  for (size_t i = 0; i < partition_num; ++i) {
    // --- BUILD (R) ---
    uint64_t r_length = r_histogram[i];
    uint64_t r_capacity = (r_length + 3) & ~3ULL;  // Padded to multiple of 4

    Element* build_storage = arena.aligned_alloc(r_capacity, 64);
    new (&local_r[i])
        RadixBucket(build_storage, r_capacity, r_length, i);

    // Pass the exact starting pointer of the slice, and the local capacity
    //new (&local_r[i])
    //    RadixBucket(build_storage + r_offset, r_capacity, r_length, i);
    // r_offset += r_capacity;

    // --- PROBE (S) ---
    uint64_t s_length = s_histogram[i];
    uint64_t s_capacity = (s_length + 3) & ~3ULL;  // Padded to multiple of 4

    Element* probe_storage = arena.aligned_alloc(s_capacity, 64);
    new (&local_s[i])
        RadixBucket(probe_storage, s_capacity, s_length, i);
    //new (&local_s[i])
    //    RadixBucket(probe_storage + s_offset, s_capacity, s_length, i);
    // s_offset += s_capacity;
  }

  // if (tid == 0) {
  //   cur_phase = ExecPhase::finds;
  //   g_app_record_start = true;
  // }
  // barrier->arrive_and_wait();

  for (size_t i = 0; i < partition_sz_r; ++i) {
    Element& e = build[i];
    bucket_id = radix_hash(e.key, radix_mask);
    ASSERT_TRUE(bucket_id < partition_num);
    local_r[bucket_id].insert(e);
  }

  for (size_t i = 0; i < partition_sz_s; ++i) {
    Element& e = probe[i];
    bucket_id = radix_hash(e.key, radix_mask);
    ASSERT_TRUE(bucket_id < partition_num);
    local_s[bucket_id].insert(e);
  }

  for (size_t i = 0; i < partition_num; ++i) {
    local_r[i].flush();
    local_s[i].flush();
    ASSERT_TRUE(local_r[i].v_start + local_r[i].v_len == local_r[i].v_idx);
    ASSERT_TRUE(local_s[i].v_start + local_s[i].v_len == local_s[i].v_idx);
  }

  Global_R_Buckets[tid] = local_r;
  Global_S_Buckets[tid] = local_s;

  // uint64_t phrase3_cycle = 0;
  // if (tid == 0) {
  //   cur_phase = ExecPhase::finds;
  //   g_app_record_start = false;
  // }
  // barrier->arrive_and_wait();
  // if (tid == 0) {
  //   phrase3_cycle = g_find_end - g_find_start;
  //   PLOGI.printf("took %lu cycles, %lu cycle per item phrase3", phrase3_cycle,
  //                phrase3_cycle / (partition_sz_r + partition_sz_s));
  // }

  // Completion of partition phrase
  if (tid == 0) {
    cur_phase = ExecPhase::insertions;
    g_app_record_start = false;
  }
  barrier->arrive_and_wait();
  sh->stats->insertions.duration = g_insert_end - g_insert_start;
  sh->stats->insertions.op_count = partition_sz_r + partition_sz_s;

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
  uint64_t avg_ht_sz = 0;
  uint64_t num_ht_build = 0;

  for (size_t part_id = tid; part_id < partition_num;
       part_id += config.num_threads) {
    uint64_t build_sz = 0;
    for (uint64_t thread_i = 0; thread_i < config.num_threads; ++thread_i) {
      RadixBucket* b = &Global_R_Buckets[thread_i][part_id];
      build_sz += (b->v_len);
    }

    uint64_t ht_sz = build_sz * 100 / config.ht_fill;
    ht_sz = utils::next_pow2(ht_sz);
    num_ht_build++;
    avg_ht_sz += ht_sz;


    Element* ht_storage = arena.aligned_alloc(ht_sz, CACHELINE_SIZE);
    RadixArrayHashTable ht(ht_sz, ht_storage);

    // for (size_t i = 0; i < ht_sz; i += ELE_NUM_PER_CACHE_LINE) {
    //     __builtin_prefetch(&ht_storage[i], 1, 2);
    // }

    static_assert(sizeof(Item) == sizeof(Element),
                   "Size mismatch between Item and Element");
    static_assert(alignof(Item) == alignof(Element),
                   "Alignment mismatch between Item and Element");

    //BaseHashTable* cas_ht;
    //cas_ht = new CASHashTableSingleThread<Item, ItemQueue>(ht_sz, config.find_queue_sz, (Item*) ht_storage);
    // if (tid == 0) {
    //   PLOGI.printf("part id %lu hashtable sz %lu KB, build_sz %lu KB", part_id,
    //                (ht_sz * sizeof(Element)) / (1024),
    //                (build_sz * sizeof(Element)) / (1024));
    //   duration = RDTSC_START();
    // }

    for (uint64_t thread_i = 0; thread_i < config.num_threads; ++thread_i) {
      RadixBucket* b = &Global_R_Buckets[thread_i][part_id];
      Element* const __restrict__ tuples = b->v;
      const uint32_t start = 0;
      const uint32_t end = b->v_len;

      // ht_do_insert((BaseHashTable*) cas_ht, tuples, end);
      for (uint32_t i = start; i < end; i++) {
        ht.insert(tuples[i]);
      }
    }

     // if (tid == 0) {
     //  duration = RDTSCP() - duration;
     //  PLOGI.printf("part id %lu insertion done, duration %lu, cpo %lu", part_id,
     //                 duration, duration / build_sz);
     // }

    // if (tid == 0) {
    //   duration = RDTSC_START();
    // }

    uint64_t find_issued = 0;
    for (uint64_t thread_i = 0; thread_i < config.num_threads; ++thread_i) {
      RadixBucket* b = &Global_S_Buckets[thread_i][part_id];

      Element* const __restrict__ tuples = b->v;
      const uint32_t start = 0;
      const uint32_t end = b->v_len;

      //ht_do_find((BaseHashTable*) cas_ht, tuples, mvec, end);
      // if (start < end) {
      //   __builtin_prefetch(&tuples[start], 0,
      //                      2);  // 0 = read, 1 = low temporal locality
      // }

      for (uint32_t i = start; i < end; i++) {
        find_issued++;
       if (ht.find(tuples[i]) > 0) found++;
      }
    }

    // if (tid == 0) {
    //   duration = RDTSCP() - duration;
    //   PLOGI.printf("part id %lu, find duration %lu, cpo %lu", part_id, duration,
    //                duration / find_issued);
    // }
  }

  avg_ht_sz = avg_ht_sz / num_ht_build;

  if (tid == 0) {
    PLOGI.printf("average_hashtable_sz: %lu MB",
                 (avg_ht_sz * sizeof(Element) / (1024 * 1024)));
  }

  if (tid == 0) {
    cur_phase = ExecPhase::finds;
    g_app_record_start = false;
  }
  barrier->arrive_and_wait();

  sh->stats->finds.duration = g_find_end - g_find_start;
  sh->stats->finds.op_count = partition_sz_s + partition_sz_r;
  sh->stats->found = found;

  if (tid == 0) {
    byte_allocator.deallocate((char*) Global_R_Buckets, config.num_threads * sizeof(RadixBucket*));
    byte_allocator.deallocate((char*) Global_S_Buckets, config.num_threads * sizeof(RadixBucket*));
  }

  bucket_allocator.deallocate(local_r, partition_num);
  bucket_allocator.deallocate(local_s, partition_num);
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
  //HugepageVec build_relation(partition_sz_r, hugepage_alloc_inst_element);
  //HugepageVec probe_relation(partition_sz_s, hugepage_alloc_inst_element);
  //JoinVec join_relation(partition_sz_s, hugepage_alloc_inst_join_element);


  Element* build_relation = hugepage_alloc_inst_element.allocate(partition_sz_r);
  Element* probe_relation = hugepage_alloc_inst_element.allocate(partition_sz_s);
  JoinElement* join_relation = hugepage_alloc_inst_join_element.allocate(partition_sz_s);

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
    build_relation[i] = e;
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
    probe_relation[i] = e;
  }

  if (config.mode == HASHJOIN) {
    hashjoin(sh, build_relation, probe_relation, join_relation, barrier, partition_sz_r, partition_sz_s);
  } else if (config.mode == PARTITIONJOINV1) {
    radixjoin2016(sh, build_relation, probe_relation, join_relation, barrier, partition_sz_r, partition_sz_s);
  } else if (config.mode == PARTITIONJOINV2) {
    // radixjoin(sh, build_relation, probe_relation, join_relation, barrier);
  } else {
    PLOGE.printf("Unsupported mode for join");
    abort();
  }

  hugepage_alloc_inst_element.deallocate(build_relation, partition_sz_r);
  hugepage_alloc_inst_element.deallocate(probe_relation, partition_sz_s);
  hugepage_alloc_inst_join_element.deallocate(join_relation, partition_sz_s);
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
