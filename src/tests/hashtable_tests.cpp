#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

#include <atomic>
#include <sstream>

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

#ifdef WITH_PAPI_LIB
#include "mem_bw_papi.hpp"
#endif

namespace kmercounter {

extern void get_ht_stats(Shard *, BaseHashTable *);

// default size for hashtable
// when each element is 16 bytes (2 * uint64_t), this amounts to 16 GiB
uint64_t HT_TESTS_HT_SIZE = (1ull << 30);
uint64_t HT_TESTS_NUM_INSERTS;
const uint64_t max_possible_threads = 128;

extern std::vector<std::uint64_t, huge_page_allocator<uint64_t>> *zipf_values;

OpTimings do_zipfian_inserts(BaseHashTable *hashtable, double skew,
                             unsigned int count, unsigned int id) {
  auto keyrange_width = (1ull << 63);
#ifdef ZIPF_FAST
  zipf_distribution_apache distribution(keyrange_width, skew);
#else
  zipf_distribution distribution{skew, keyrange_width, id + 1};
#endif
  std::uint64_t duration{};
  static std::atomic_uint num_entered{};

#ifdef LATENCY_COLLECTION
  const auto collector = &collectors.at(id);
  collector->claim();
#else
  collector_type *const collector{};
#endif

#if defined(WITH_PAPI_LIB)
  static MemoryBwCounters bw_counters{2};
  if (++num_entered == config.num_threads) {
    PLOGI.printf("Starting counters %u", num_entered.load());
    bw_counters.start();
  }
#else
  ++num_entered;
#endif
  while (num_entered < count) _mm_pause();

#ifdef WITH_VTUNE_LIB
  static const auto event =
      __itt_event_create("inserting", strlen("inserting"));
  __itt_event_start(event);
#endif

  PLOGI.printf("Starting insertion test");
  alignas(64) InsertFindArgument items[HT_TESTS_BATCH_LENGTH]{};

  const auto start = RDTSC_START();
  std::uint64_t key{};

  uint64_t key_start =
      std::max(static_cast<uint64_t>(HT_TESTS_NUM_INSERTS) * id, (uint64_t)1);

  PLOGV.printf("id: %u | key_start %" PRIu64 "", id, key_start);

  for (auto j = 0u; j < config.insert_factor; j++) {
    auto zipf_idx = key_start == 1 ? 0 : key_start;
    for (unsigned int n{}; n < HT_TESTS_NUM_INSERTS; ++n) {
      if (!(zipf_idx & 7) && zipf_idx + 16 < zipf_values->size()) {
        prefetch_object<false>(&zipf_values->at(zipf_idx + 16), 64);
      }

      auto value = zipf_values->at(zipf_idx);
      items[key].key = items[key].value = value;
      items[key].id = n;

      // printf("zipf_values[%d] = %" PRIu64 "\n", zipf_idx, value);
      zipf_idx++;
      if (config.no_prefetch) {
        hashtable->insert_noprefetch(&items[key], collector);
      } else {
        if (++key == HT_TESTS_BATCH_LENGTH) {
          KeyPairs keypairs(items);
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

#if defined(WITH_PAPI_LIB)
  if (--num_entered == 0) {
    PLOGI.printf("Stopping counters %u", num_entered.load());
    bw_counters.stop();
    bw_counters.compute_mem_bw();
  }
#endif

#ifdef LATENCY_COLLECTION
  collector->dump("insert", id);
#endif

  return {duration, HT_TESTS_NUM_INSERTS * config.insert_factor};
}

OpTimings do_zipfian_gets(BaseHashTable *hashtable, unsigned int num_threads,
                          unsigned int id) {
  std::uint64_t duration{};
  std::uint64_t found = 0, not_found = 0;

#ifdef LATENCY_COLLECTION
  const auto collector = &collectors.at(id);
  collector->claim();
#else
  collector_type *const collector{};
#endif

  static std::atomic_uint num_entered{};
  num_entered++;
#if defined(WITH_PAPI_LIB)
  static MemoryBwCounters bw_counters{2};
  if (num_entered == config.num_threads) {
    bw_counters.start();
  }
#endif
  while (num_entered < num_threads) _mm_pause();

  alignas(64) InsertFindArgument items[HT_TESTS_BATCH_LENGTH]{};
  FindResult *results = new FindResult[HT_TESTS_FIND_BATCH_LENGTH];
  ValuePairs vp = std::make_pair(0, results);

  uint64_t key_start =
      std::max(static_cast<uint64_t>(HT_TESTS_NUM_INSERTS) * id, (uint64_t)1);
  const auto start = RDTSC_START();
  std::uint64_t key{};
  for (auto j = 0u; j < config.insert_factor; j++) {
    auto zipf_idx = key_start == 1 ? 0 : key_start;
    for (unsigned int n{}; n < HT_TESTS_NUM_INSERTS; ++n) {
      if (!(zipf_idx & 7) && zipf_idx + 16 < zipf_values->size()) {
        prefetch_object<false>(&zipf_values->at(zipf_idx + 16), 64);
      }

      if (config.no_prefetch) {
        auto ret = hashtable->find_noprefetch(&zipf_values->at(zipf_idx), collector);
        if (ret)
          found++;
        else
          not_found++;
      } else {
        items[key] = {zipf_values->at(zipf_idx), n};

        if (++key == HT_TESTS_FIND_BATCH_LENGTH) {
          hashtable->find_batch(KeyPairs(items), vp, collector);
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

#if defined(WITH_PAPI_LIB)
  if (--num_entered == 0) {
    bw_counters.stop();
    bw_counters.compute_mem_bw();
  }
#endif

  if (found >= 0) {
    PLOG_INFO.printf(
        "thread %u | num_finds %" PRIu64 " (not_found %" PRIu64 ") | cycles per get: %" PRIu64 "", id,
        found, not_found, found > 0 ? duration / found : 0);
  }

#ifdef LATENCY_COLLECTION
  collector->dump("find", id);
#endif

  return {duration, found};
}

void ZipfianTest::run(Shard *shard, BaseHashTable *hashtable, double skew,
                      unsigned int count) {
  OpTimings insert_timings{};
  static_assert(HT_TESTS_MAX_STRIDE - 1 ==
                1);  // Otherwise timing logic is wrong

#ifdef LATENCY_COLLECTION
  static auto step = 0;
  {
    std::lock_guard lock {collector_lock};
    if (step == 0) {
      collectors.resize(config.num_threads);
      step = 1;
    }
  }
#endif

  PLOG_INFO.printf(
      "Zipfian test run: thread %u, ht size: %" PRIu64 ", insertions: %" PRIu64 ", skew "
      "%f",
      shard->shard_idx, config.ht_size, HT_TESTS_NUM_INSERTS, skew);

  for (uint32_t i = 1; i < HT_TESTS_MAX_STRIDE; i++) {
    insert_timings =
        do_zipfian_inserts(hashtable, skew, count, shard->shard_idx);
    PLOG_INFO.printf(
        "Quick stats: thread %u, Batch size: %d, cycles per "
        "insertion:%" PRIu64 "",
        shard->shard_idx, i, insert_timings.duration / insert_timings.op_count);

#ifdef CALC_STATS
    PLOG_INFO.printf("Reprobes %" PRIu64 " soft_reprobes %" PRIu64 "", hashtable->num_reprobes,
                     hashtable->num_soft_reprobes);
#endif
  }

  shard->stats->insertion_cycles = insert_timings.duration;
  shard->stats->num_inserts = insert_timings.op_count;

#ifdef LATENCY_COLLECTION
  {
    std::lock_guard lock {collector_lock};
    if (step == 1) {
      collectors.clear();
      collectors.resize(config.num_threads);
      step = 2;
    }
  }
#endif

  sleep(1);

  const auto num_finds = do_zipfian_gets(hashtable, count, shard->shard_idx);

  shard->stats->find_cycles = num_finds.duration;
  shard->stats->num_finds = num_finds.op_count;

  if (num_finds.op_count > 0) {
    PLOG_INFO.printf("thread %u | num_finds %" PRIu64 " | cycles per get: %" PRIu64 "",
                     shard->shard_idx, num_finds.op_count,
                     num_finds.duration / num_finds.op_count);
  }

  get_ht_stats(shard, hashtable);

#ifdef LATENCY_COLLECTION
  {
    std::lock_guard lock {collector_lock};
    if (step == 2) {
      collectors.clear();
      step = 3;
    }
  }
#endif
}

}  // namespace kmercounter
