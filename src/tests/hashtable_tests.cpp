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
uint64_t HT_TESTS_HT_SIZE = (1ull << 30);
uint64_t HT_TESTS_NUM_INSERTS;
const uint64_t max_possible_threads = 128;

#ifdef WITH_PERFCPP
extern MultithreadCounter EVENTCOUNTERS;
#endif

#if defined(WITH_PCM)
extern pcm::PCMCounters pcm_cnt;
#endif

void sync_complete(void);

bool clear_table = false;
extern ExecPhase cur_phase;

extern uint64_t *g_insert_durations;
extern uint64_t *g_find_durations;
uint64_t zipfian_iter;
bool stop_sync = false;
bool zipfian_finds = false;
bool zipfian_inserts = false;

extern std::vector<key_type, huge_page_allocator<key_type>> *zipf_values;
static inline uint32_t hash_knuth(uint32_t x) { return x * 2654435761u; }

void do_batch_insertion(BaseHashTable *ht, uint64_t batch_num,
                        uint32_t batch_len, uint64_t idx) {

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
#if defined(INFLIGHT)
      value = hash_knuth(idx);
#elif defined(ZIPFIAN)
      if (!(idx & 7) && idx + 16 < zipf_set->size()) {
        __builtin_prefetch(&zipf_set->at(idx + 16), false, 3);
      }

      value = zipf_set->at(idx);  // len 1024,  zipf[2 * 1024]
#else
      value = idx;
#endif
      items[i].key = items[i].value = value;
      items[i].id = idx;
      idx++;
    }

    InsertFindArguments keypairs(items, config.batch_len);
    ht->insert_batch(keypairs, collector);
  }

  ht->flush_insert_queue(collector);
  free(items);
}

uint64_t do_batch_find(BaseHashTable *ht, uint64_t batch_num,
                       uint32_t batch_len, uint32_t idx) {
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
#if defined(INFLIGHT)
      value = hash_knuth(idx);
#elif defined(ZIPFIAN)
      if (!(idx & 7) && idx + 16 < zipf_set->size()) {
        __builtin_prefetch(&zipf_set->at(idx + 16), false, 3);
      }

      value = zipf_set->at(idx);  // len 1024,  zipf[2 * 1024]
#else
      value = idx;
#endif
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
  while (ht->flush_find_queue(vp, collector) > 0)
  {
    found += vp.first;
    vp.first = 0;
  }

  free(items);

  return found;
}

OpTimings do_zipfian_inserts(
    BaseHashTable *hashtable, double skew, int64_t seed, unsigned int count,
    unsigned int id, std::barrier<std::function<void()>> *sync_barrier,
    std::vector<key_type, huge_page_allocator<key_type>> *zipf_set) {

  if (config.insert_factor == 0) return {1, 1};

  if (id == 0) {
    cur_phase = ExecPhase::insertions;
    zipfian_inserts = false;
  }

  const uint64_t ops_per_iter = HT_TESTS_NUM_INSERTS;
  const uint64_t batches = HT_TESTS_NUM_INSERTS / config.batch_len;

  uint64_t start, end;

  for (auto j = 0u; j < config.insert_factor; j++) {


    uint64_t idx;
#if defined(ZIPFIAN)
    idx = 0;
#else
    idx = ops_per_iter * id;
#endif

    if (id == 0) {
      cur_phase = ExecPhase::insertions;
      zipfian_inserts = false;
    }
    sync_barrier->arrive_and_wait();

    do_batch_insertion(hashtable, batches, config.batch_len, idx);

    if (id == 0) {
      zipfian_inserts = true;
      zipfian_iter = j;
    }
    sync_barrier->arrive_and_wait();

    if (id == 0) {
      cur_phase = ExecPhase::none;
    }
    sync_barrier->arrive_and_wait();
    if (id == 0) {
      hashtable->clear();
    }
    sync_barrier->arrive_and_wait();
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
    std::vector<key_type, huge_page_allocator<key_type>> *zipf_set) {


  if (config.read_factor == 0) {
    return {1, 1};
  }

  if (id == 0) {
    cur_phase = ExecPhase::finds;
    zipfian_finds = false;
  }

  std::uint64_t found = 0;
  const uint64_t ops_per_iter = HT_TESTS_NUM_INSERTS;
  const uint64_t batches = ops_per_iter / config.batch_len;

  uint64_t start;
  uint64_t end;

  for (auto j = 0u; j < config.read_factor; j++) {
    uint64_t value, idx;

#if defined(ZIPFIAN)
    idx = 0;
#else
    idx = id * ops_per_iter;
#endif

    // All thread wait here, and record start

    if (id == 0) {
      zipfian_finds = false;
    }
    sync_barrier->arrive_and_wait();
    found = do_batch_find(hashtable, batches, config.batch_len, idx);
    if (id == 0) {
      zipfian_finds = true;
      zipfian_iter = j;
    }
    sync_barrier->arrive_and_wait();

    // if (found > 0) {
    //   double per_found = (double)found / ops_per_iter;
    //     PLOGI.printf("op issued %lu, actual found %lu, perc
    //     %.3f",ops_per_iter, found, per_found);
    // }
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
  OpTimings upsertion_timings{1, 1};

  // generate zipfian here.
  std::vector<key_type, huge_page_allocator<key_type>> *zipf_set_local;
#if defined(ZIPFIAN)
  zipf_set_local = new std::vector<key_type, huge_page_allocator<key_type>>(
      HT_TESTS_NUM_INSERTS);
  // int cpu = sched_getcpu();
  // sleep(cpu);
  //   uint64_t* zipf_set_local =
  //   static_cast<uint64_t*>(aligned_alloc(CACHE_LINE_SIZE,
  //   HT_TESTS_NUM_INSERTS * sizeof(uint64_t)));
  // assert(zipf_set_local != nullptr && "aligned_alloc failed");

  uint64_t starting_offset = shard->shard_idx * HT_TESTS_NUM_INSERTS;
  for (int i = 0; i < HT_TESTS_NUM_INSERTS; i++) {
    zipf_set_local->at(i) = zipf_values->at(i + starting_offset);
    // zipf_set_local->at(i) = hash_knuth(i + starting_offset);
  }

  // PLOGI.printf("generated %d zipf on thread %d", HT_TESTS_NUM_INSERTS,
  //              shard->shard_idx);
#else
  std::vector<key_type, huge_page_allocator<key_type>> *zipf_set;
#endif

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

  PLOGV.printf(
      "Zipfian test run: thread %u, ht size: %lu, insertions: %lu, skew "
      "%f",
      shard->shard_idx, config.ht_size, HT_TESTS_NUM_INSERTS, skew);

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

#if defined(ZIPFIAN)
  if (zipf_set_local) {
    auto rng = std::default_random_engine{};
    std::shuffle(std::begin(*zipf_set_local), std::end(*zipf_set_local), rng);
  }
#endif

  // if (shard->shard_idx == 0) cas_ht->flush_ht_from_cache();

#ifdef WITH_VTUNE_LIB
  // static const auto upsert_event =
  //     __itt_event_create("upsert_test", strlen("upsert_test"));
  // __itt_event_start(upsert_event);
#endif

  // upsertion_timings =
  //     do_zipfian_upserts(hashtable, skew, zipf_seed, count, shard->shard_idx,
  //                        sync_barrier, zipf_set_local);

#ifdef WITH_VTUNE_LIB
  // __itt_event_end(upsert_event);
#endif

  shard->stats->upsertions = upsertion_timings;
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

#if defined(ZIPFIAN)
  if (zipf_set_local) {
    auto rng = std::default_random_engine{};
    std::shuffle(std::begin(*zipf_set_local), std::end(*zipf_set_local), rng);
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
