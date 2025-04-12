#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

#include <atomic>
#include <barrier>
#include <sstream>

#include "./hashtables/cas_kht.hpp"
#include "misc_lib.h"
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

void sync_complete(void);
bool stop_sync = false;
bool zipfian_finds = false;
bool zipfian_inserts = false;
extern ExecPhase cur_phase;

extern std::vector<key_type, huge_page_allocator<key_type>> *zipf_values;
extern std::vector<cacheline> toxic_waste_dump;

OpTimings do_zipfian_inserts(
    BaseHashTable *hashtable, double skew, int64_t seed, unsigned int count,
    unsigned int id, std::barrier<std::function<void()>> *sync_barrier) {
#ifdef LATENCY_COLLECTION
  const auto collector = &collectors.at(id);
  collector->claim();
#else
  collector_type *const collector{};
#endif

  std::uint64_t duration{};

  sync_barrier->arrive_and_wait();
  stop_sync = true;

#ifdef WITH_VTUNE_LIB
  static const auto event =
      __itt_event_create("inserting", strlen("inserting"));
  __itt_event_start(event);
#endif

  PLOGV.printf("Starting insertion test");
  InsertFindArgument *items = (InsertFindArgument *)aligned_alloc(
      64, sizeof(InsertFindArgument) * config.batch_len);

  uint64_t key_start =
      std::max(static_cast<uint64_t>(HT_TESTS_NUM_INSERTS) * id, (uint64_t)1);

  PLOGV.printf("id: %u | key_start %" PRIu64 "", id, key_start);

  const auto start = RDTSC_START();
  key_type key{};
  std::size_t next_pollution{};

  for (auto j = 0u; j < config.insert_factor; j++) {
    key_start =
        std::max(static_cast<uint64_t>(HT_TESTS_NUM_INSERTS) * id, (uint64_t)1);
    auto zipf_idx = key_start == 1 ? 0 : key_start;

    for (unsigned int n{}; n < HT_TESTS_NUM_INSERTS; ++n) {
#ifdef XORWOW
      auto value = key_start++;
#else
      if (!(zipf_idx & 7) && zipf_idx + 16 < zipf_values->size()) {
        prefetch_object<false>(&zipf_values->at(zipf_idx + 16), 64);
        // __builtin_prefetch(&zipf_values->at(zipf_idx + 16), false, 3);
      }

      auto value = zipf_values->at(zipf_idx);  // len 1024,  zipf[2 * 1024]
#endif
      items[key].key = items[key].value = value;
      items[key].id = n;

      zipf_idx++;
      if (config.no_prefetch) {
        hashtable->insert_noprefetch(&items[key], collector);

        for (auto p = 0u; p < config.pollute_ratio; ++p)
          prefetch_object<true>(
              &toxic_waste_dump[next_pollution++ & (1024 * 1024 - 1)], 64);
      } else {
        if (++key == config.batch_len) {
          InsertFindArguments keypairs(items, config.batch_len);
          hashtable->insert_batch(keypairs, collector);
          for (auto p = 0u; p < config.pollute_ratio * HT_TESTS_BATCH_LENGTH;
               ++p)
            prefetch_object<true>(
                &toxic_waste_dump[next_pollution++ & (1024 * 1024 - 1)], 64);

          key = 0;
        }
      }
    }
  }
  if (!config.no_prefetch) {
    hashtable->flush_insert_queue(collector);
  }

  const auto end = RDTSCP();
  duration += end - start;

  PLOG_DEBUG << "Inserts done; Reprobes: " << hashtable->num_reprobes
             << ", Soft Reprobes: " << hashtable->num_soft_reprobes;

#ifdef WITH_VTUNE_LIB
  __itt_event_end(event);
#endif

  sync_barrier->arrive_and_wait();

#ifdef LATENCY_COLLECTION
  collector->dump("async_insert", id);
#endif

  return {duration, HT_TESTS_NUM_INSERTS * config.insert_factor};
}

OpTimings do_zipfian_gets(BaseHashTable *hashtable, unsigned int num_threads,
                          unsigned int id, auto sync_barrier) {
  auto *cas_ht = static_cast<CASHashTable<KVType, ItemQueue> *>(hashtable);
  std::uint64_t duration{};
  std::uint64_t found = 0, not_found = 0;
#ifdef LATENCY_COLLECTION
  const auto collector = &collectors.at(id);
  collector->claim();
#else
  collector_type *const collector{};
#endif

  InsertFindArgument *items = (InsertFindArgument *)aligned_alloc(
      64, sizeof(InsertFindArgument) * config.batch_len);
  FindResult *results = new FindResult[config.batch_len];
  // alignas(32) ValuePairs vp = std::make_pair(0, results);
  ValuePairs vp = std::make_pair(0, results);
  sync_barrier->arrive_and_wait();
  stop_sync = true;

#ifdef WITH_VTUNE_LIB
  static const auto vtune_event_find =
      __itt_event_create("finding", strlen("finding"));
  __itt_event_start(vtune_event_find);
#endif

  // THis ensures that for a given hashtable size, regardless of
  // the fill factor, number of finds is the same.
  // const uint64_t num_finds = config.ht_size / num_threads;
  const uint64_t num_finds = HT_TESTS_NUM_INSERTS;  // old zipf test

  const auto start = RDTSC_START();
  std::uint64_t key{};
  std::size_t next_pollution{};
  for (auto j = 0u; j < config.insert_factor; j++) {
    uint64_t key_start =
        std::max(static_cast<uint64_t>(num_finds) * id, (uint64_t)1);
    auto zipf_idx = key_start == 1 ? 0 : key_start;
    for (unsigned int n{}; n < num_finds; ++n) {
#ifdef XORWOW
      auto value = key_start++;
#else
      if (!(zipf_idx & 7) && zipf_idx + 16 < zipf_values->size()) {
        // prefetch_object<false>(&zipf_values->at(zipf_idx + 16), 64);
        __builtin_prefetch(&zipf_values->at(zipf_idx + 16), false, 3);
      }

      auto value = zipf_values->at(zipf_idx);
#endif

      // if (config.no_prefetch) {
      //   auto ret = hashtable->find_noprefetch(&value, collector);
      //   for (auto p = 0u; p < config.pollute_ratio; ++p)
      //     prefetch_object<true>(&toxic_waste_dump[next_pollution++ & (1024 *
      //     1024 - 1)], 64);

      //   if (ret)
      //     found++;
      //   else
      //     not_found++;
      // } else {
      items[key] = {value, n};

      if (++key == config.batch_len) {
        cas_ht->find_batch_simple(InsertFindArguments(items, config.batch_len), vp,
                              collector);
        found += vp.first;
        vp.first = 0;
        key = 0;
        // for (auto p = 0u; p < config.pollute_ratio *
        // HT_TESTS_FIND_BATCH_LENGTH; ++p)
        //   prefetch_object<true>(&toxic_waste_dump[next_pollution++ & (1024 *
        //   1024 - 1)], 64);
      }
      // }

      zipf_idx++;
    }
  }
  if (!config.no_prefetch) {
    if (vp.first > 0) {
      vp.first = 0;
    }

    hashtable->flush_find_queue(vp, collector);
    found += vp.first;
  }

  const auto end = RDTSCP();
  duration += end - start;

#ifdef WITH_VTUNE_LIB
  __itt_event_end(vtune_event_find);
#endif

  sync_barrier->arrive_and_wait();

  if (found >= 0) {
    PLOGI.printf("thread %u | num_finds %lu | cycles per get: %lu", id, found,
                 found > 0 ? duration / found : 0);
  }

#ifdef LATENCY_COLLECTION
  collector->dump("find", id);
#endif

  return {duration, found};
}

void ZipfianTest::run(Shard *shard, BaseHashTable *hashtable, double skew,
                      int64_t zipf_seed, unsigned int count,
                      std::barrier<std::function<void()>> *sync_barrier) {
  OpTimings insert_timings{};
  static_assert(HT_TESTS_MAX_STRIDE - 1 ==
                1);  // Otherwise timing logic is wrong

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

  cur_phase = ExecPhase::insertions;

  PLOGV.printf(
      "Zipfian test run: thread %u, ht size: %lu, insertions: %lu, skew "
      "%f",
      shard->shard_idx, config.ht_size, HT_TESTS_NUM_INSERTS, skew);

  for (uint32_t i = 1; i < HT_TESTS_MAX_STRIDE; i++) {
    insert_timings = do_zipfian_inserts(hashtable, skew, zipf_seed, count,
                                        shard->shard_idx, sync_barrier);

#ifdef CALC_STATS
    PLOG_INFO.printf(
        "Quick stats: thread %u, Batch length: %d, cycles per "
        "insertion:%" PRIu64 "",
        shard->shard_idx, config.batch_len,
        insert_timings.duration / insert_timings.op_count);

    PLOG_INFO.printf("Reprobes %" PRIu64 " soft_reprobes %" PRIu64 "",
                     hashtable->num_reprobes, hashtable->num_soft_reprobes);
#endif
  }

  shard->stats->insertions = insert_timings;

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

  if (zipf_values && shard->shard_idx == 0) {
    // Do a shuffle to redistribute the keys
    auto rng = std::default_random_engine{};
    std::shuffle(std::begin(*zipf_values), std::end(*zipf_values), rng);
  }
  //Flush cache after inserts
  // std::size_t next_pollution{};
  //   for (auto p = 0u; p < 900000; ++p)
  //           prefetch_object<false>(
  //               &toxic_waste_dump[next_pollution++ & (1024 * 1024 - 1)], 64);

  cur_phase = ExecPhase::finds;

#ifdef WITH_PERFCPP
  if (shard->shard_idx == 0) EVENTCOUNTERS.start(shard->shard_idx);
#endif

#ifdef WITH_VTUNE_LIB
  __itt_resume();
#endif

  const auto num_finds =
      do_zipfian_gets(hashtable, count, shard->shard_idx, sync_barrier);

#ifdef WITH_VTUNE_LIB
  __itt_pause();
#endif

#ifdef WITH_PERFCPP
  if (shard->shard_idx == 0) {
    EVENTCOUNTERS.stop(shard->shard_idx);
    EVENTCOUNTERS.set_sample_count(shard->shard_idx, num_finds.op_count);
  }
#endif

  shard->stats->finds.duration = num_finds.duration;
  shard->stats->finds.op_count = num_finds.op_count;
  shard->stats->ht_fill = config.ht_fill;
  get_ht_stats(shard, hashtable);

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
