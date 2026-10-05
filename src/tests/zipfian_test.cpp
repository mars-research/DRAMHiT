#include <cstdint>

#include "tests/ZipfianTest.hpp"
#include "hashtables/base_kht.hpp"
#include "types.hpp"
#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

#include <barrier>

#include "./hashtables/cas_kht.hpp"
#include "./hashtables/dlht_kht.hpp"
#include "./hashtables/folklore_kht.hpp"


#include "print_stats.h"
#include "sync.h"
#include "utils/hugepage_allocator.hpp"
#include "numa.hpp"
#include <numaif.h>
#include "utils/vtune.hpp"

#ifdef ENABLE_HIGH_LEVEL_PAPI
#include <papi.h>
#endif

#ifdef WITH_PERFCPP
#include "PerfMultiCounter.hpp"
#endif

#ifdef WITH_PCM
#include "PCMCounter.hpp"
#endif
#include <random>
namespace kmercounter {

extern void get_ht_stats(Shard *, BaseHashTable *);

// default size for hashtable
// when each element is 16 bytes (2 * uint64_t), this amounts to 16 GiB
#ifdef WITH_PERFCPP
extern MultithreadCounter EVENTCOUNTERS;
#endif

#if defined(WITH_PCM)
extern pcm::PCMCounters pcm_cnt;
#endif

void sync_complete(void);

extern ExecPhase cur_phase;
extern uint64_t *g_insert_durations;
extern uint64_t *g_find_durations;
extern bool clear_table;
extern bool stop_sync;
extern uint64_t zipfian_iter;
extern bool zipfian_finds;
extern bool zipfian_inserts;

extern std::vector<key_type> *g_zipf_values;
using HashTableTestHugepageAlloc = huge_page_allocator<key_type>;
using HashTableTestVec = std::vector<key_type, HashTableTestHugepageAlloc>;

uint64_t do_batch_insertion(BaseHashTable *ht, HashTableTestVec &workload) {
#if defined(CAS_NO_ABSTRACT)
  CASHashTable<KVType, ItemQueue> *cas_ht =
      static_cast<CASHashTable<KVType, ItemQueue> *>(ht);
#endif
#ifdef LATENCY_COLLECTION
  const auto collector = &collectors.at(id);
  collector->claim();
#else

  uint64_t request_num = workload.size();
  uint32_t batch_len = config.batch_len;
  uint64_t batch_num = request_num / batch_len;
  collector_type *const collector{};
#endif
  InsertFindArgument *items = (InsertFindArgument *)aligned_alloc(
      64, sizeof(InsertFindArgument) * config.batch_len);
  key_type value;
  uint64_t idx = 0;
  for (uint64_t n = 0; n < batch_num; ++n) {
    for (uint32_t i = 0; i < batch_len; i++) {
      if (!(idx & 7) && idx + 16 < request_num) {
        __builtin_prefetch(&workload[idx + 16], false, 3);
      }

      value = workload[idx];

      items[i].key = items[i].value = value;
      items[i].id = idx;
      idx++;
    }

    InsertFindArguments keypairs(items, batch_len);

#if defined(CAS_NO_ABSTRACT)
    cas_ht->insert_batch_inline(keypairs, collector);
#else
    ht->insert_batch(keypairs, collector);
#endif
  }

  uint64_t residue_num = request_num - batch_len * batch_num;
  if (residue_num > 0) {
    for (uint64_t i = 0; i < residue_num; i++) {
      if (!(idx & 7) && (idx + 16 < request_num)) {
        __builtin_prefetch(&workload[idx + 16], false, 3);
      }
      value = workload[idx];
      items[i].key = items[i].value = value;
      items[i].id = idx;
      idx++;
    }
    InsertFindArguments keypairs(items, residue_num);
#if defined(CAS_NO_ABSTRACT)
    cas_ht->insert_batch_inline(keypairs, collector);
#else
    ht->insert_batch(keypairs, collector);
#endif
  }
  ht->flush_insert_queue(collector);
  free(items);

  return idx;
}

struct ht_do_batch_find_ret {
  uint32_t idx;
  uint32_t found;
};

uint64_t do_batch_find(BaseHashTable *ht, HashTableTestVec &workload,
                       uint64_t *found_res) {
#if defined(CAS_NO_ABSTRACT)
  CASHashTable<KVType, ItemQueue> *cas_ht =
      static_cast<CASHashTable<KVType, ItemQueue> *>(ht);
#endif
  uint64_t request_num = workload.size();
  uint32_t batch_len = config.batch_len;
  uint64_t batch_num = request_num / batch_len;
  uint64_t found = 0;
  uint64_t idx = 0;
#ifdef LATENCY_COLLECTION
  const auto collector = &collectors.at(id);
  collector->claim();
#else
  collector_type *const collector{};
#endif
  InsertFindArgument *items = (InsertFindArgument *)aligned_alloc(
      64, sizeof(InsertFindArgument) * batch_len);

#ifdef BUDDY_QUEUE
  FindResult *results = new FindResult[(batch_len * 2)];
#else
  FindResult *results = new FindResult[batch_len];
#endif

  ValuePairs vp = std::make_pair(0, results);
  key_type value;
  for (uint64_t n = 0; n < batch_num; ++n) {
    for (uint32_t i = 0; i < batch_len; i++) {
      if (!(idx & 7) && idx + 16 < request_num) {
        __builtin_prefetch(&workload[idx + 16], false, 3);
      }

      value = workload[idx];

      items[i].key = items[i].value = value;
      items[i].id = idx;
      idx++;
    }

    vp.first = 0;

#if defined(CAS_NO_ABSTRACT)
    cas_ht->find_batch_inline(InsertFindArguments(items, batch_len), vp,
                              collector);
#else
    ht->find_batch(InsertFindArguments(items, batch_len), vp, collector);
#endif

    found += vp.first;
  }

  uint64_t residue_num = request_num - batch_len * batch_num;
  if (residue_num > 0) {
    for (uint64_t i = 0; i < residue_num; i++) {
      if (!(idx & 7) && (idx + 16 < request_num)) {
        __builtin_prefetch(&workload[idx + 16], false, 3);
      }
      value = workload[idx];
      items[i].key = items[i].value = value;
      items[i].id = idx;
      idx++;
    }

    vp.first = 0;
#if defined(CAS_NO_ABSTRACT)
    cas_ht->find_batch_inline(InsertFindArguments(items, residue_num), vp,
                              collector);
#else
    ht->find_batch(InsertFindArguments(items, residue_num), vp, collector);
#endif

    found += vp.first;
  }

  while (true) {
    vp.first = 0;
    size_t cur_queue_sz = ht->flush_find_queue(vp, collector);
    if (vp.first == 0 && cur_queue_sz == 0) {
      break;
    }
    found += vp.first;
  }

  free(items);

  *found_res = found;
  return idx;
}

OpTimings do_zipfian_inserts(
    BaseHashTable *hashtable,
    unsigned int id, std::barrier<std::function<void()>> *sync_barrier,
    std::vector<key_type, huge_page_allocator<key_type>> &zipf_set) {
  if (config.insert_factor == 0) return {1, 1};

  uint64_t ops = 0;
  if (id == 0) {
    cur_phase = ExecPhase::insertions;
    zipfian_inserts = false;
  }
  sync_barrier->arrive_and_wait();

  for (auto j = 0u; j < config.insert_factor; j++) {
    ops += do_batch_insertion(hashtable, zipf_set);
  }

  if (id == 0) {
    zipfian_inserts = true;
    zipfian_iter = 0;
  }
  sync_barrier->arrive_and_wait();

  uint64_t duration = 0;
  // for (int i = 0; i < config.insert_factor; i++)  duration +=
  // g_insert_durations[i];
  duration += g_insert_durations[0];

  return {duration, ops};
}

OpTimings do_zipfian_gets(BaseHashTable *hashtable,
                          unsigned int id, auto sync_barrier,
                          HashTableTestVec &zipf_set, uint64_t *found) {
  if (config.read_factor == 0) {
    return {1, 1};
  }

  uint64_t ops = 0;
  uint64_t found_per_turn = 0;
  *found = 0;
  if (id == 0) {
    cur_phase = ExecPhase::finds;
    zipfian_finds = false;
  }
  sync_barrier->arrive_and_wait();

  for (auto j = 0u; j < config.read_factor; j++) {
    ops += do_batch_find(hashtable, zipf_set, &found_per_turn);
    *found = *found + found_per_turn;
  }

  if (id == 0) {
    zipfian_finds = true;
    zipfian_iter = 0;
  }
  sync_barrier->arrive_and_wait();

  uint64_t duration = 0;
  // for (int i = 0; i < config.read_factor; i++) duration +=
  // g_find_durations[i];
  duration += g_find_durations[0];

  return {duration, ops};
}

void ZipfianTest::run(Shard *shard, BaseHashTable *hashtable,
                      std::barrier<std::function<void()>> *sync_barrier) {
  OpTimings insert_timings{};
  OpTimings find_timings{};

  // split global data into chunks. bring into local hugepages memory
  uint64_t data_sz = g_zipf_values->size();
  uint64_t starting_offset = shard->shard_idx * (data_sz / config.num_threads);
  uint64_t partition_size = data_sz / config.num_threads;

  HashTableTestHugepageAlloc hugepage_alloc_inst_ht_test;
  // if it is last threads, it can take over the left over.
  if (shard->shard_idx == config.num_threads - 1)
    partition_size += data_sz % config.num_threads;

  // Allocate the hugepage-backed local key partition without touching it, so
  // that under the custom numa policy (numa_split 10) it can be bound to the
  // memory node(s) the hashtable uses (HBM) before its pages are faulted in:
  // the keys the find loop streams then come from HBM, not from the DDR of
  // the cpu's own node. resize() below value-initialises and thus places them.
  HashTableTestVec zipf_set_local(hugepage_alloc_inst_ht_test);
  zipf_set_local.reserve(partition_size);

  if (config.numa_split == 10 && !getenv("NO_KEY_BIND")) {
    uint32_t mem_node_msk = config.np_mem_node_msk;
    if (config.np_mem_local) {
      // same rule as the hashtable arena: each thread uses the HBM node
      // closest to its own cpu node
      int local_node = nearest_memory_only_node(shard->numa_node);
      if (local_node >= 0) mem_node_msk = 1u << local_node;
    }
    if (mem_node_msk != 0) {
      unsigned long nodemask = mem_node_msk;
      uint64_t bind_sz =
          hugepage_alloc_inst_ht_test
              .get_rounded_alloc_size(partition_size * sizeof(key_type))
              .second;
      int policy = (__builtin_popcount(mem_node_msk) > 1) ? MPOL_INTERLEAVE
                                                           : MPOL_BIND;
      if (mbind(zipf_set_local.data(), bind_sz, policy, &nodemask,
                sizeof(nodemask) * 8, MPOL_MF_STRICT | MPOL_MF_MOVE) != 0) {
        PLOGE.printf("shard %u: mbind of local key partition to node msk 0x%x failed",
                     (unsigned)shard->shard_idx, mem_node_msk);
      } else {
        PLOGI.printf("shard %u: local key partition (%lu B) bound to node msk 0x%x",
                     (unsigned)shard->shard_idx, bind_sz, mem_node_msk);
      }
    }
  }
  zipf_set_local.resize(partition_size);

  for (uint64_t i = 0; i < partition_size; i++) {
      zipf_set_local.at(i) = g_zipf_values->at(i + starting_offset);
  }

  if (shard->shard_idx == 0) {
    cur_phase = ExecPhase::free_global_zipfian_values;
  }
  sync_barrier->arrive_and_wait();
#ifdef LATENCY_COLLECTION
  static auto step = 0;
  {
    std::lock_guard lock{collector_lock};
    if (step == 0) {
      collectors.resize(config.num_threads);
      step = 1;
    }
  }
#endif

#ifdef WITH_PERFCPP
  if (shard->shard_idx != 0) EVENTCOUNTERS.start(shard->shard_idx);
#endif

#ifdef WITH_VTUNE_LIB
  // static const auto insert_event =
  //     __itt_event_create("insert_test", strlen("insert_test"));
  // __itt_event_start(insert_event);
#endif
  if (shard->shard_idx == 0) {
    PLOGI.printf("zipfian test insert start");
  }
  insert_timings =
      do_zipfian_inserts(hashtable, shard->shard_idx,
                         sync_barrier, zipf_set_local);
  if (shard->shard_idx == 0) {
    PLOGI.printf("zipfian test insert end");
  }
#ifdef WITH_VTUNE_LIB
  //__itt_event_end(insert_event);
#endif

#ifdef WITH_PERFCPP
  if (shard->shard_idx != 0) {
    EVENTCOUNTERS.stop(shard->shard_idx);
    EVENTCOUNTERS.set_sample_count(shard->shard_idx, insert_timings.op_count);
    // EVENTCOUNTERS.save("Insertion_perfcpp_counter.csv");
    // EVENTCOUNTERS.clear(shard->shard_idx);
  }
#endif

  shard->stats->insertions = insert_timings;

  //auto rng = std::default_random_engine{};
  //std::shuffle(std::begin(zipf_set_local), std::end(zipf_set_local), rng);

#ifdef WITH_VTUNE_LIB
  // __itt_event_end(upsert_event);
#endif

#ifdef LATENCY_COLLECTION
  {
    std::lock_guard lock{collector_lock};
    if (step == 1) {
      collectors.clear();
      collectors.resize(config.num_threads);
      step = 2;
    }
  }
#endif

#ifdef WITH_PERFCPP
  // if (shard->shard_idx == 0)
  EVENTCOUNTERS.start(shard->shard_idx);
#endif

#ifdef WITH_VTUNE_LIB
  // static const auto vtune_event_find =
  //     __itt_event_create("find_test", strlen("find_test"));
  // __itt_event_start(vtune_event_find);
  __itt_resume();
#endif

  if (shard->shard_idx == 0) {
    PLOGI.printf("zipfian test find start");
  }

  uint64_t found = 0;
  find_timings = do_zipfian_gets(hashtable, shard->shard_idx,
                                 sync_barrier, zipf_set_local, &found);

  if (shard->shard_idx == 0) {
    PLOGI.printf("zipfian test find end");
  }
#if defined(WITH_PCM)
  // if (shard->shard_idx == 0) {
  //   pcm_cnt.stop_bw();
  //   pcm_cnt.read_out_bw();
  // }
#elif defined(WITH_VTUNE_LIB)
  __itt_pause();
#elif defined(WITH_PERFCPP)
  EVENTCOUNTERS.stop(shard->shard_idx);
#endif

  shard->stats->finds = find_timings;
  shard->stats->found = found;
  get_ht_stats(shard, hashtable);

  if (shard->shard_idx == 0) {
    cur_phase = ExecPhase::none;
  }
  sync_barrier->arrive_and_wait();

  if (shard->shard_idx == 0) {
      shard->stats->ht_fill = hashtable->get_fill();
      shard->stats->ht_capacity = hashtable->get_capacity();
    PLOGI.printf("get fill %.3f",
                 (double)hashtable->get_fill() / hashtable->get_capacity());
  }

#ifdef LATENCY_COLLECTION
  {
    std::lock_guard lock{collector_lock};
    if (step == 2) {
      collectors.clear();
      step = 3;
    }
  }
#endif
}

}  // namespace kmercounter
