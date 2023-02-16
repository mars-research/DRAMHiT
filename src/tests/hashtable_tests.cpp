#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

#include <atomic>
#include <sstream>
#include <barrier>

#include "misc_lib.h"
#include "print_stats.h"
#include "sync.h"
#include "tests/tests.hpp"
#include "utils/hugepage_allocator.hpp"
#include "zipf.h"
#include "zipf_distribution.hpp"

#ifdef ENABLE_HIGH_LEVEL_PAPI
#include <papi.h>
#endif

namespace kmercounter {

extern void get_ht_stats(Shard *, BaseHashTable *);

// default size for hashtable
// when each element is 16 bytes (2 * uint64_t), this amounts to 16 GiB
uint64_t HT_TESTS_HT_SIZE = (1ull << 30);
uint64_t HT_TESTS_NUM_INSERTS;
const uint64_t max_possible_threads = 128;

void sync_complete(void);
bool stop_sync = false;

extern std::vector<key_type, huge_page_allocator<key_type>> *zipf_values;

OpTimings do_zipfian_inserts(BaseHashTable *hashtable, double skew, int64_t seed,
                             unsigned int count, unsigned int id,
                             std::barrier<std::function<void()>> *sync_barrier) {
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
  alignas(64) InsertFindArgument items[HT_TESTS_BATCH_LENGTH]{};

  uint64_t key_start =
      std::max(static_cast<uint64_t>(HT_TESTS_NUM_INSERTS) * id, (uint64_t)1);

  PLOGV.printf("id: %u | key_start %" PRIu64 "", id, key_start);

  const auto start = RDTSC_START();
  key_type key{};

  for (auto j = 0u; j < config.insert_factor; j++) {

    key_start = std::max(static_cast<uint64_t>(HT_TESTS_NUM_INSERTS) * id, (uint64_t)1);
    auto zipf_idx = key_start == 1 ? 0 : key_start;

    for (unsigned int n{}; n < HT_TESTS_NUM_INSERTS; ++n) {
#ifdef XORWOW
      auto value = key_start++;
#else
      // if (!(zipf_idx & 7) && zipf_idx + 16 < zipf_values->size()) {
      //   prefetch_object<false>(&zipf_values->at(zipf_idx + 16), 64);
      // }

      auto value = zipf_values->at(zipf_idx);
#endif
      items[key].key = items[key].value = value;
      items[key].id = n;

      // printf("zipf_values[%d] = %" PRIu64 "\n", zipf_idx, value);
      zipf_idx++;
      if (config.no_prefetch) {
        hashtable->insert_noprefetch(&items[key], collector);
      } else {
        if (++key == HT_TESTS_BATCH_LENGTH) {
          InsertFindArguments keypairs(items);
          hashtable->insert_batch(keypairs, collector);
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
  std::uint64_t duration{};
  std::uint64_t found = 0, not_found = 0;

#ifdef LATENCY_COLLECTION
  const auto collector = &collectors.at(id);
  collector->claim();
#else
  collector_type *const collector{};
#endif

  sync_barrier->arrive_and_wait();
  stop_sync = true;

  alignas(64) InsertFindArgument items[HT_TESTS_BATCH_LENGTH]{};
  FindResult *results = new FindResult[HT_TESTS_FIND_BATCH_LENGTH];
  ValuePairs vp = std::make_pair(0, results);

#ifdef WITH_VTUNE_LIB
  static const auto event =
      __itt_event_create("finds", strlen("finds"));
  __itt_event_start(event);
#endif

  const auto start = RDTSC_START();
  std::uint64_t key{};
  for (auto j = 0u; j < config.insert_factor; j++) {
    uint64_t key_start =
      std::max(static_cast<uint64_t>(HT_TESTS_NUM_INSERTS) * id, (uint64_t)1);
    auto zipf_idx = key_start == 1 ? 0 : key_start;
    for (unsigned int n{}; n < HT_TESTS_NUM_INSERTS; ++n) {
#ifdef XORWOW
      auto value = key_start++;
#else
      if (!(zipf_idx & 7) && zipf_idx + 16 < zipf_values->size()) {
        prefetch_object<false>(&zipf_values->at(zipf_idx + 16), 64);
      }
      auto value = zipf_values->at(zipf_idx);
#endif

      if (config.no_prefetch) {
        auto ret =
            hashtable->find_noprefetch(&value, collector);
        if (ret)
          found++;
        else
          not_found++;
      } else {
        items[key] = {zipf_values->at(zipf_idx), n};

        if (++key == HT_TESTS_FIND_BATCH_LENGTH) {
          hashtable->find_batch(InsertFindArguments(items), vp, collector);
          found += vp.first;
          vp.first = 0;
          key = 0;
        }
      }

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

  sync_barrier->arrive_and_wait();

#ifdef WITH_VTUNE_LIB
  __itt_event_end(event);
#endif
  if (found >= 0) {
    PLOGV.printf(
        "thread %u | num_finds %lu (not_found %lu) | cycles per get: %lu", id,
        found, not_found, found > 0 ? duration / found : 0);
  }

#ifdef LATENCY_COLLECTION
  collector->dump("find", id);
#endif

  return {duration, found};
}

void ZipfianTest::run(Shard *shard, BaseHashTable *hashtable, double skew, int64_t zipf_seed,
                      unsigned int count, std::barrier<std::function<void ()>> *sync_barrier) {
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

  PLOGV.printf(
      "Zipfian test run: thread %u, ht size: %lu, insertions: %lu, skew "
      "%f",
      shard->shard_idx, config.ht_size, HT_TESTS_NUM_INSERTS, skew);

  for (uint32_t i = 1; i < HT_TESTS_MAX_STRIDE; i++) {
    insert_timings =
        do_zipfian_inserts(hashtable, skew, zipf_seed, count, shard->shard_idx, sync_barrier);
    PLOG_INFO.printf(
        "Quick stats: thread %u, Batch size: %d, cycles per "
        "insertion:%" PRIu64 "",
        shard->shard_idx, i, insert_timings.duration / insert_timings.op_count);

#ifdef CALC_STATS
    PLOG_INFO.printf("Reprobes %" PRIu64 " soft_reprobes %" PRIu64 "", hashtable->num_reprobes,
                     hashtable->num_soft_reprobes);
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


  // Do a shuffle to redistribute the keys
  auto rng = std::default_random_engine {};
  std::shuffle(std::begin(*zipf_values), std::end(*zipf_values), rng);

  sleep(1);

  const auto num_finds = do_zipfian_gets(hashtable, count, shard->shard_idx, sync_barrier);

  shard->stats->finds.duration = num_finds.duration;
  shard->stats->finds.op_count = num_finds.op_count;

  if (num_finds.op_count > 0) {
    PLOG_INFO.printf("thread %u | num_finds %" PRIu64 " | cycles per get: %" PRIu64 "",
                     shard->shard_idx, num_finds.op_count,
                     num_finds.duration / num_finds.op_count);
  }

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
