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
#include <cstdlib>  // Required for std::abort()
#include <cstring>
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
#include "hashtables/cas_kht_st.hpp"
#include "helper.hpp"
#include "print_stats.h"
#include "sync.h"
#include "tests/HashjoinTest.hpp"
#include "types.hpp"
#include "utils/hugepage_allocator.hpp"
#include "utils/hugepage_arena.hpp"
#include "utils/vtune.hpp"
#include "zipf_distribution.hpp"
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

// #define RADIX_KNUTH
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
    // Because GOLDEN_PRIME is odd, this is a perfect bijection (no collisions
    // possible)
    (*g_zipf_values)[r_index] = (r_index + seed_offset) * GOLDEN_PRIME;
    printf("r[%lu] = %lu\n", r_index, g_zipf_values->at(r_index));
  }

  // ---------------------------------------------------------
  // 2. Populate Probe Relation S (Skewed + Configurable Hit Rate)
  // ---------------------------------------------------------
  std::uint64_t keyrange_width = (1ull << 53) - 1;
  if constexpr (std::is_same_v<key_type, std::uint32_t>) {
    keyrange_width = (1ull << 31);
  }
  zipf_distribution_apache distribution(keyrange_width, skew, seed);

  std::mt19937_64 rng(seed);
  std::uniform_real_distribution<double> match_prob(0.0, 1.0);

  for (uint64_t s_index = 0; s_index < s_size; ++s_index) {
    uint64_t zipf_val = distribution.sample();

    printf("zipf_val = %lu\n", zipf_val);
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

    printf("s[%lu] = %lu\n", s_index, g_zipf_values->at(r_size + s_index));
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

uint64_t ht_do_find(BaseHashTable* ht, Element* workload, JoinElement* mvec,
                    uint64_t len) {
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
              std::barrier<std::function<void()>>* barrier,
              uint64_t partition_sz_r, uint64_t partition_sz_s) {
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

struct alignas(64) CacheLineBuffer {
  Element tuples[4];
  uint64_t counter;

  inline bool insert(Element& e) {
    tuples[counter & 0x3] = e;
    counter++;

    // if counter is multiple of 4, after increment, time to flush
    return ((counter & 0x3) == 0);
  }

  inline void reset() { counter = 0; }

  inline void flush_nt(Element* bucket) {
    void* addr = &bucket[counter - 4];
    __m512i data = _mm512_load_si512(reinterpret_cast<const __m512i*>(tuples));
    _mm512_stream_si512(reinterpret_cast<__m512i*>(addr), data);
  }
};

class RadixArrayHashTable {
 public:
  Element* vec;
  uint64_t size;
  static const key_type empty_key = 0;
  static const value_type empty_value = 0;
  Hasher hasher;
  uint64_t found;

  RadixArrayHashTable(Element* v_ref) : vec(v_ref) {}

  // FIXED: Read exactly the bytes of the key, no more.
  inline uint64_t hash(key_type k) {
    return (hasher(&k, sizeof(key_type)) & (size - 1));
  }

  void insert(const Element& e) {
    uint64_t idx = hash(e.key);

  try_insert:
    if (vec[idx].key == empty_key) {
      vec[idx] = e;
      return;
    }

    if (vec[idx].key == e.key) {
      vec[idx].value = e.value;
      return;
    }

    idx = (idx + 1) & (size - 1);

    goto try_insert;
  }

  bool find(const Element& e, value_type& v) {
    uint64_t idx = hash(e.key);

  try_find:
    if (vec[idx].key == e.key) {
      v = vec[idx].value;
      found++;
      return 1;
    }

    if (vec[idx].key == empty_key) {
      return 0;
    }

    idx = (idx + 1) & (size - 1);

    if (idx & 0x3 == 0) {
      return 0;
    }
    goto try_find;
  }
};

#ifdef WITH_VTUNE_LIB
const auto histogram_event =
    __itt_event_create("histogram", strlen("histogram"));
const auto partition_event =
    __itt_event_create("partition", strlen("partition"));
const auto join_event = __itt_event_create("join", strlen("join"));
#endif

struct RelationInfo {
  Element* workload;
  uint64_t workload_sz;

  uint64_t partition_num;
  uint64_t r_msk;

  // below array are all partition_num length
  Element** buckets;

  // buckets second level length is indicated by histogram
  uint64_t* histogram;

  // shared by R and S
  CacheLineBuffer* swbs;
};

void preallocate_phase(RelationInfo& info, HugepageArena& arena) {
  uint64_t* histogram = info.histogram;
  for (size_t i = 0; i < info.workload_sz; ++i) {
    Element& e = info.workload[i];
    uint64_t bucket_id = radix_hash(e.key, info.r_msk);
    histogram[bucket_id]++;
  }

  for (size_t i = 0; i < info.partition_num; ++i) {
    // round up to 4
    uint64_t capacity = (histogram[i] + 3) & ~3ULL;
    info.buckets[i] =
        (Element*)arena.aligned_alloc(capacity * sizeof(Element), 64);
  }
}

// partition s
void partition_phase(RelationInfo& info) {
  uint64_t bucket_id;
  CacheLineBuffer* buffer;

  for (size_t i = 0; i < info.workload_sz; ++i) {
    Element& e = info.workload[i];
    bucket_id = radix_hash(e.key, info.r_msk);
    buffer = &info.swbs[bucket_id];
    if (buffer->insert(e)) {
      buffer->flush_nt(info.buckets[bucket_id]);
    }
  }

  for (size_t i = 0; i < info.partition_num; ++i) {
    uint64_t counter = info.swbs[i].counter;
    uint8_t left = counter & 0x3;

    // Calculate the absolute index where the leftovers should start
    uint64_t base_idx = counter & ~3ULL;

    for (uint8_t j = 0; j < left; j++) {
      // Write to base_idx + j, NOT just j
      info.buckets[i][base_idx + j] = info.swbs[i].tuples[j];
    }
    info.swbs[i].reset();
  }
}

struct GlobalRelationInfo {
  Element** r_buckets;
  uint64_t* r_histogram;

  Element** s_buckets;
  uint64_t* s_histogram;
};

GlobalRelationInfo* global_info;
uint64_t join_phrase(HugepageArena& arena, uint64_t tid,
                     uint64_t partition_num) {
  uint64_t max_ht_sz = 0;
  uint64_t max_probe_sz = 0;
  uint64_t max_build_sz = 0;

  uint64_t ht_nums =
      (partition_num + config.num_threads - 1) / config.num_threads;
  uint64_t* ht_szs =
      (uint64_t*)arena.aligned_alloc(sizeof(uint64_t) * ht_nums, 64);
  uint64_t ht_id = 0;

  // Aggregate statistics
  for (size_t part_id = tid; part_id < partition_num;
       part_id += config.num_threads) {
    uint64_t build_sz = 0;
    uint64_t probe_sz = 0;

    for (uint64_t thread_i = 0; thread_i < config.num_threads; ++thread_i) {
      build_sz += global_info[thread_i].r_histogram[part_id];
      probe_sz += global_info[thread_i].s_histogram[part_id];
    }

    uint64_t ht_sz = build_sz * 100 / config.ht_fill;
    ht_sz = utils::next_pow2(ht_sz);

    if (max_ht_sz < ht_sz) max_ht_sz = ht_sz;
    if (max_probe_sz < probe_sz) max_probe_sz = probe_sz;
    if (max_build_sz < build_sz) max_build_sz = build_sz;

    ht_szs[ht_id] = ht_sz;
    ht_id++;
  }

  Element* ht_array = (Element*)arena.aligned_alloc(sizeof(Element) * max_ht_sz, 64);
  //Element* r = (Element*)arena.aligned_alloc(sizeof(Element) * max_probe_sz, 64);
  //Element* s = (Element*)arena.aligned_alloc(sizeof(Element) * max_build_sz, 64);
  RadixArrayHashTable ht(ht_array);


  PLOGI.printf("tid% lu, array size %lu kb, max_probe_sz %lu, max_build_sz %lu",tid, sizeof(Element) * max_ht_sz / 1024, max_probe_sz, max_build_sz);
  ht_id = 0;
  uint64_t found = 0;
  for (size_t part_id = tid; part_id < partition_num;
       part_id += config.num_threads) {

    // uint64_t part_duration;
    //if(tid == 0) part_duration = RDTSC_START();

    // reset hashtable
    uint64_t ht_sz = ht_szs[ht_id];
    ht_id++;
    ht.size = ht_sz;
    ht.found = 0;

    memset(ht_array, 0, ht_sz * sizeof(Element));

    uint64_t duration;
    // Element* src;
    // uint64_t offset_s = 0;
    // uint64_t offset_r = 0;
    // uint64_t chunk_sz;

    // for (uint64_t thread_i = 0; thread_i < config.num_threads; ++thread_i) {
    //   src = global_info[thread_i].r_buckets[part_id];
    //   chunk_sz = global_info[thread_i].r_histogram[part_id];
    //   memcpy(r + offset_r, src, chunk_sz * sizeof(Element));
    //   offset_r += chunk_sz;
    // }
    // for (uint64_t thread_i = 0; thread_i < config.num_threads; ++thread_i) {
    //   src = global_info[thread_i].s_buckets[part_id];
    //   chunk_sz = global_info[thread_i].s_histogram[part_id];
    //   memcpy(s + offset_s, src, chunk_sz * sizeof(Element));
    //   offset_s += chunk_sz;
    // }

    // if(tid == 0){
    //     duration = RDTSCP() - duration;
    //     PLOGI.printf("set up duration %lu operation %lu, %lu cycles per tuple", duration, offset_r+offset_s, duration/(offset_r+offset_s));
    // }

    // if(tid == 0) duration = RDTSC_START();

    // for(uint64_t i = 0; i<offset_r; i++){
    //     ht.insert(r[i]);
    // }

    // if(tid == 0){
    //     duration = RDTSCP() - duration;
    //     PLOGI.printf("insertion duration %lu operation %lu, %lu cycles per tuple", duration, offset_r, duration/offset_r);
    // }

    // if(tid == 0) duration = RDTSC_START();

    // for(uint64_t i = 0; i<offset_s; i++){
    //     uint64_t ret_v;
    //     ht.find(s[i], ret_v);
    // }

    // if(tid == 0){
    //     duration = RDTSCP() - duration;
    //     PLOGI.printf("find duration %lu operation %lu, %lu cycles per tuple", duration, offset_s, duration/offset_s);
    // }


    // if(tid == 0) duration = RDTSC_START();

    uint64_t op_issued = 0;
    for (uint64_t thread_i = 0; thread_i < config.num_threads; ++thread_i) {
      uint64_t sz = global_info[thread_i].r_histogram[part_id];
      Element* tuples = global_info[thread_i].r_buckets[part_id];
      for (uint32_t i = 0; i < sz; i++) {
          op_issued++;
        ht.insert(tuples[i]);
      }
    }
    // if(tid == 0){
    //     duration = RDTSCP() - duration;
    //     PLOGI.printf("insertion duration %lu operation %lu, %lu cycles per tuple", duration, op_issued, duration/op_issued);
    // }

   //  if(tid == 0) duration = RDTSC_START();
    for (uint64_t thread_i = 0; thread_i < config.num_threads; ++thread_i) {
      uint64_t sz = global_info[thread_i].s_histogram[part_id];
      Element* tuples = global_info[thread_i].s_buckets[part_id];
      uint64_t ret_v;
      for (uint32_t i = 0; i < sz; i++) {
          op_issued++;
        ht.find(tuples[i], ret_v);
      }
    }
    found += ht.found;
    // if(tid == 0){
    //     duration = RDTSCP() - duration;
    //     PLOGI.printf("find duration %lu operation %lu, %lu cycles per tuple", duration, op_issued, duration/op_issued);
    // }

    // if(tid == 0){
    //     part_duration = RDTSCP() - part_duration;
    //     PLOGI.printf("took %lu cycles for partition %lu", part_duration, part_id);
    // }
  }

  return found;
}

void radixjoin2016(Shard* sh, Element* build, Element* probe, JoinElement* mvec,
                   std::barrier<std::function<void()>>* barrier,
                   uint64_t partition_sz_r, uint64_t partition_sz_s) {
  uint64_t partition_num = 1 << config.radix;
  uint64_t radix_mask = partition_num - 1;
  uint64_t tid = sh->shard_idx;
  // TODO, estimate per thread needed memory and break into GB and mb.
  // also look at per thread memory quota from filesystem, so it doesn't
  // try to allocate over the limits
  HugepageArena arena(1, 10);

  // they can share swbs.
  CacheLineBuffer* swbs = (CacheLineBuffer*)arena.aligned_alloc(
      sizeof(CacheLineBuffer) * partition_num, 64);

  RelationInfo r_info;
  r_info.r_msk = radix_mask;
  r_info.partition_num = partition_num;
  r_info.buckets =
      (Element**)arena.aligned_alloc(sizeof(Element*) * partition_num, 64);
  r_info.histogram =
      (uint64_t*)arena.aligned_alloc(sizeof(uint64_t) * partition_num, 64);
  r_info.workload = build;
  r_info.workload_sz = partition_sz_r;
  r_info.swbs = swbs;

  RelationInfo s_info;
  s_info.r_msk = radix_mask;
  s_info.partition_num = partition_num;
  s_info.buckets =
      (Element**)arena.aligned_alloc(sizeof(Element*) * partition_num, 64);
  s_info.histogram =
      (uint64_t*)arena.aligned_alloc(sizeof(uint64_t) * partition_num, 64);
  s_info.workload = probe;
  s_info.workload_sz = partition_sz_s;
  s_info.swbs = swbs;

  if (tid == 0) {
    // should be smaller than a page
    global_info = (GlobalRelationInfo*)aligned_alloc(
        64, sizeof(GlobalRelationInfo) * config.num_threads);

#ifdef WITH_VTUNE_LIB
    __itt_event_start(partition_event);
#endif
    cur_phase = ExecPhase::insertions;
    g_app_record_start = true;
    PLOGI.printf("Partition phase start\n partition num %lu", partition_num);
  }
  barrier->arrive_and_wait();

  // partition build
  preallocate_phase(r_info, arena);
  partition_phase(r_info);
  global_info[tid].r_histogram = r_info.histogram;
  global_info[tid].r_buckets = r_info.buckets;

  preallocate_phase(s_info, arena);
  partition_phase(s_info);
  global_info[tid].s_histogram = s_info.histogram;
  global_info[tid].s_buckets = s_info.buckets;

  if (tid == 0) {
#ifdef WITH_VTUNE_LIB
    __itt_event_end(partition_event);
#endif
    cur_phase = ExecPhase::insertions;
    g_app_record_start = false;
    PLOGI.printf("Partition phase end");
  }
  barrier->arrive_and_wait();
  sh->stats->insertions.duration = g_insert_end - g_insert_start;
  sh->stats->insertions.op_count = partition_sz_r + partition_sz_s;

  if (tid == 0) {
#ifdef WITH_VTUNE_LIB
    __itt_resume();
    __itt_event_start(join_event);
#endif
    cur_phase = ExecPhase::finds;
    g_app_record_start = true;
  }
  barrier->arrive_and_wait();

  uint64_t duration = RDTSC_START();
  uint64_t found = join_phrase(arena, tid, partition_num);

  duration = RDTSCP() - duration;
  PLOGI.printf("tid %lu took %lu cycles", tid, duration);
  if (tid == 0) {
#ifdef WITH_VTUNE_LIB
    __itt_event_end(join_event);
#endif
    cur_phase = ExecPhase::finds;
    g_app_record_start = false;
  }
  barrier->arrive_and_wait();

  sh->stats->finds.duration = g_find_end - g_find_start;
  sh->stats->finds.op_count = partition_sz_s + partition_sz_r;
  sh->stats->found = found;

  if (tid == 0) {
    free(global_info);
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

  Element* build_relation =
      hugepage_alloc_inst_element.allocate(partition_sz_r);
  Element* probe_relation =
      hugepage_alloc_inst_element.allocate(partition_sz_s);
  JoinElement* join_relation =
      hugepage_alloc_inst_join_element.allocate(partition_sz_s);

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
    hashjoin(sh, build_relation, probe_relation, join_relation, barrier,
             partition_sz_r, partition_sz_s);
  } else if (config.mode == PARTITIONJOINV1) {
    radixjoin2016(sh, build_relation, probe_relation, join_relation, barrier,
                  partition_sz_r, partition_sz_s);
  } else if (config.mode == PARTITIONJOINV2) {
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
