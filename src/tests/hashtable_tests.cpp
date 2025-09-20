#include <cstdint>

#include "hashtables/base_kht.hpp"
#include "types.hpp"
#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

#include <barrier>

#include "./hashtables/cas_kht.hpp"
#include "print_stats.h"
#include "sync.h"
#include "tests/tests.hpp"
#include "utils/hugepage_allocator.hpp"
#include "utils/vtune.hpp"
#include "zipf.h"
#include "zipf_distribution.hpp"

#ifdef ENABLE_HIGH_LEVEL_PAPI
#include <papi.h>
#endif

#ifdef WITH_PERFCPP
#include "PerfMultiCounter.hpp"
#endif

#ifdef WITH_PCM
#include "PCMCounter.hpp"
#endif

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

extern uint64_t HT_TESTS_NUM_INSERTS;
extern ExecPhase cur_phase;
extern uint64_t *g_insert_durations;
extern uint64_t *g_find_durations;
extern bool clear_table;
extern bool stop_sync;
extern uint64_t zipfian_iter;
extern bool zipfian_finds;
extern bool zipfian_inserts;
extern std::vector<key_type> *g_zipf_values;

static inline uint32_t hash_knuth(uint32_t x) { return x * 2654435761u; }

void do_batch_insertion(
    BaseHashTable *ht, uint64_t batch_num, uint32_t batch_len, uint64_t idx,
    std::vector<key_type, huge_page_allocator<key_type>> &zipf_set) {
#if defined(CAS_NO_ABSTRACT)
  CASHashTable<KVType, ItemQueue> *cas_ht =
      static_cast<CASHashTable<KVType, ItemQueue> *>(ht);
#endif
#ifdef LATENCY_COLLECTION
  const auto collector = &collectors.at(id);
  collector->claim();
#else

  collector_type *const collector{};
#endif
  InsertFindArgument *items = (InsertFindArgument *)aligned_alloc(
      64, sizeof(InsertFindArgument) * config.batch_len);
  uint64_t value;
  for (unsigned int n = 0; n < batch_num; ++n) {
    for (int i = 0; i < batch_len; i++) {
      if (!(idx & 7) && idx + 16 < zipf_set.size()) {
        __builtin_prefetch(&zipf_set.at(idx + 16), false, 3);
      }

      value = zipf_set.at(idx);  // len 1024,  zipf[2 * 1024]

      items[i].key = items[i].value = value;
      items[i].id = idx;
      idx++;
    }

    InsertFindArguments keypairs(items, config.batch_len);

#if defined(CAS_NO_ABSTRACT)
    cas_ht->insert_batch_inline(keypairs, collector);
#else
    ht->insert_batch(keypairs, collector);
#endif
  }

  ht->flush_insert_queue(collector);
  free(items);
}

uint64_t do_batch_find(
    BaseHashTable *ht, uint64_t batch_num, uint32_t batch_len, uint32_t idx,
    std::vector<key_type, huge_page_allocator<key_type>> &zipf_set) {
#if defined(CAS_NO_ABSTRACT)
  CASHashTable<KVType, ItemQueue> *cas_ht =
      static_cast<CASHashTable<KVType, ItemQueue> *>(ht);
#endif
  uint64_t found = 0;
#ifdef LATENCY_COLLECTION
  const auto collector = &collectors.at(id);
  collector->claim();
#else
  collector_type *const collector{};
#endif
  InsertFindArgument *items = (InsertFindArgument *)aligned_alloc(
      64, sizeof(InsertFindArgument) * config.batch_len);

#ifdef BUDDY_QUEUE
  FindResult *results = new FindResult[(config.batch_len * 2)];
#else
  FindResult *results = new FindResult[config.batch_len];
#endif

  ValuePairs vp = std::make_pair(0, results);
  uint32_t value;
  for (unsigned int n = 0; n < batch_num; ++n) {
    for (int i = 0; i < batch_len; i++) {
      if (!(idx & 7) && idx + 16 < zipf_set.size()) {
        __builtin_prefetch(&zipf_set.at(idx + 16), false, 3);
      }

      value = zipf_set.at(idx);  // len 1024,  zipf[2 * 1024]

      items[i].key = value;
      items[i].id = idx;
      idx++;
    }

    vp.first = 0;

#if defined(CAS_NO_ABSTRACT)
    cas_ht->find_batch_inline(InsertFindArguments(items, config.batch_len), vp,
                              collector);
#else
    ht->find_batch(InsertFindArguments(items, config.batch_len), vp, collector);
#endif

    found += vp.first;
  }

  vp.first = 0;
  while (ht->flush_find_queue(vp, collector) > 0) {
    found += vp.first;
    vp.first = 0;
  }

  free(items);

  return found;
}

OpTimings do_zipfian_inserts(
    BaseHashTable *hashtable, double skew, int64_t seed, unsigned int count,
    unsigned int id, std::barrier<std::function<void()>> *sync_barrier,
    std::vector<key_type, huge_page_allocator<key_type>> &zipf_set) {
  if (config.insert_factor == 0) return {1, 1};

  const uint64_t ops_per_iter = HT_TESTS_NUM_INSERTS;
  const uint64_t batches = HT_TESTS_NUM_INSERTS / config.batch_len;

  uint64_t start, end;

  for (auto j = 0u; j < config.insert_factor; j++) {
    uint64_t idx = 0;

    if (id == 0) {
      cur_phase = ExecPhase::insertions;
      zipfian_inserts = false;
    }
    sync_barrier->arrive_and_wait();

    do_batch_insertion(hashtable, batches, config.batch_len, idx, zipf_set);

    if (id == 0) {
      zipfian_inserts = true;
      zipfian_iter = j;
    }
    sync_barrier->arrive_and_wait();

    // if (id == 0) {
    //   cur_phase = ExecPhase::none;
    // }
    // sync_barrier->arrive_and_wait();
    // // don't clear last insert iteration, or ht will be empty for finds
    // if (id == 0 && j + 1 < config.insert_factor) {
    //   hashtable->clear();
    // }
    // sync_barrier->arrive_and_wait();
  }

  uint64_t duration = 0;
  uint64_t ops = 0;
  for (int i = 0; i < config.insert_factor; i++)
    duration += g_insert_durations[i];
  ops = ops_per_iter * config.insert_factor;

  // free(durations);
  //  duration = duration / config.num_threads;

  return {duration, ops};
}

OpTimings do_zipfian_gets(
    BaseHashTable *hashtable, unsigned int num_threads, unsigned int id,
    auto sync_barrier,
    std::vector<key_type, huge_page_allocator<key_type>> &zipf_set) {
  if (config.read_factor == 0) {
    return {1, 1};
  }

  std::uint64_t found = 0;
  const uint64_t ops_per_iter = HT_TESTS_NUM_INSERTS;
  const uint64_t batches = ops_per_iter / config.batch_len;

  uint64_t start;
  uint64_t end;

  for (auto j = 0u; j < config.read_factor; j++) {
    uint64_t value, idx;
    idx = 0;

    if (id == 0) {
      cur_phase = ExecPhase::finds;
      zipfian_finds = false;
    }
    sync_barrier->arrive_and_wait();
    found = do_batch_find(hashtable, batches, config.batch_len, idx, zipf_set);
    if (id == 0) {
      zipfian_finds = true;
      zipfian_iter = j;
    }
    sync_barrier->arrive_and_wait();
  }

  uint64_t duration = 0;
  uint64_t ops = 0;

  for (int i = 0; i < config.read_factor; i++) duration += g_find_durations[i];
  ops = ops_per_iter * config.read_factor;

  return {duration, ops};
}

void ZipfianTest::run(Shard *shard, BaseHashTable *hashtable, double skew,
                      int64_t zipf_seed, unsigned int count,
                      std::barrier<std::function<void()>> *sync_barrier) {
  OpTimings insert_timings{};
  OpTimings find_timings{};

  // get zipfian here.
  std::vector<key_type, huge_page_allocator<key_type>> zipf_set_local(
      HT_TESTS_NUM_INSERTS,            // initial size
      huge_page_allocator<key_type>()  // allocator instance
  );

  uint64_t starting_offset = shard->shard_idx * HT_TESTS_NUM_INSERTS;
  for (size_t i = 0; i < HT_TESTS_NUM_INSERTS; i++) {
    zipf_set_local.at(i) = g_zipf_values->at(i + starting_offset);
  }

  if(shard->shard_idx == 0)
  {
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
  insert_timings =
      do_zipfian_inserts(hashtable, skew, zipf_seed, count, shard->shard_idx,
                         sync_barrier, zipf_set_local);
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

  auto rng = std::default_random_engine{};
  std::shuffle(std::begin(zipf_set_local), std::end(zipf_set_local), rng);

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

  find_timings = do_zipfian_gets(hashtable, count, shard->shard_idx,
                                 sync_barrier, zipf_set_local);

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
  shard->stats->ht_fill = config.ht_fill;
  get_ht_stats(shard, hashtable);

  if (shard->shard_idx == 0) {
    cur_phase = ExecPhase::none;
  }
  sync_barrier->arrive_and_wait();

  if (shard->shard_idx == 0) {
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
