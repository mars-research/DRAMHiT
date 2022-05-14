#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

#include <atomic>
#include <sstream>

#include "misc_lib.h"
#include "print_stats.h"
#include "sync.h"
#include "tests/tests.hpp"
#include "zipf.h"
#include "zipf_distribution.hpp"
#include "utils/hugepage_allocator.hpp"

#ifdef ENABLE_HIGH_LEVEL_PAPI
#include <papi.h>
#endif

namespace kmercounter {
struct kmer {
  char data[KMER_DATA_LENGTH];
};

extern void get_ht_stats(Shard *, BaseHashTable *);

// default size for hashtable
// when each element is 16 bytes (2 * uint64_t), this amounts to 16 GiB
uint64_t HT_TESTS_HT_SIZE = (1ull << 30);
uint64_t HT_TESTS_NUM_INSERTS;
const uint64_t max_possible_threads = 128;

std::array<uint64_t, max_possible_threads> zipf_gen_timings;

__thread std::vector<std::uint64_t, huge_page_allocator<uint64_t>> *values;

OpTimings do_zipfian_inserts(BaseHashTable *hashtable, double skew,
                             unsigned int count, unsigned int id) {
  auto keyrange_width = (1ull << 63);
#ifdef ZIPF_FAST
  zipf_distribution_apache distribution(keyrange_width, skew);
#else
  zipf_distribution distribution{skew, keyrange_width, id + 1};
#endif
  std::uint64_t duration{};

  const auto _start = RDTSC_START();
  static std::atomic_uint fence{};
  values = new std::vector<uint64_t, huge_page_allocator<uint64_t>>(HT_TESTS_NUM_INSERTS);
  for (auto &value : *values) {
#ifdef ZIPF_FAST
    value = distribution.sample();
#else
    value = distribution();
#endif
  }
  ++fence;
  while (fence < count) _mm_pause();
  const auto _end = RDTSCP();
  PLOGI.printf("generation took %llu cycles (per element %llu cycles)",
        _end-_start, (_end-_start)/HT_TESTS_NUM_INSERTS);

  zipf_gen_timings[id] = _end - _start;

#ifdef WITH_VTUNE_LIB
  static const auto event =
      __itt_event_create("inserting", strlen("inserting"));
  __itt_event_start(event);
#endif

  PLOGI.printf("Starting insertion test");
  alignas(64) Keys items[HT_TESTS_BATCH_LENGTH]{};

  const auto start = RDTSC_START();
  std::uint64_t key{};
  for (auto j = 0u; j < config.insert_factor; j++) {
    for (unsigned int n{}; n < HT_TESTS_NUM_INSERTS; ++n) {
      if (!(n & 7) && n + 16 < values->size()) {
        prefetch_object<false>(&values->at(n + 16), 64);
      }

      items[key].key = items[key].value = values->at(n);
      items[key].id = n;

      if (config.no_prefetch) {
        hashtable->insert_noprefetch(&items[key]);
      } else {
        if (++key == HT_TESTS_BATCH_LENGTH) {
          KeyPairs keypairs{HT_TESTS_BATCH_LENGTH, items};
          hashtable->insert_batch(keypairs);
          key = 0;
        }
      }
    }
  }
  if (!config.no_prefetch) {
    hashtable->flush_insert_queue();
  }

  const auto end = RDTSCP();
  duration += end - start;

  PLOG_DEBUG << "Inserts done; Reprobes: " << hashtable->num_reprobes
             << ", Soft Reprobes: " << hashtable->num_soft_reprobes;

#ifdef WITH_VTUNE_LIB
  __itt_event_end(event);
#endif

  return {duration, HT_TESTS_NUM_INSERTS * config.insert_factor};
}


OpTimings do_zipfian_gets(BaseHashTable *hashtable, unsigned int num_threads, unsigned int id) {
  static std::atomic_uint fence{};
  std::uint64_t duration{};
  std::uint64_t found = 0;

  ++fence;
  while (fence < num_threads) _mm_pause();

  alignas(64) Keys items[HT_TESTS_BATCH_LENGTH]{};
  Values *k_values;
  k_values = new Values[HT_TESTS_FIND_BATCH_LENGTH];
  ValuePairs vp = std::make_pair(0, k_values);

  const auto start = RDTSC_START();
  std::uint64_t key{};
  for (auto j = 0u; j < config.insert_factor; j++) {
    for (unsigned int n{}; n < HT_TESTS_NUM_INSERTS; ++n) {
      if (!(n & 7) && n + 16 < values->size()) {
        prefetch_object<false>(&values->at(n + 16), 64);
      }

      if (config.no_prefetch) {
        auto ret = hashtable->find_noprefetch(&values->at(n));
        if (ret) found += 1;
      } else {
        items[key] = {values->at(n), n};

        if (++key == HT_TESTS_FIND_BATCH_LENGTH) {
          KeyPairs keypairs{HT_TESTS_FIND_BATCH_LENGTH, items};
          hashtable->find_batch(keypairs, vp);
          found += vp.first;
          vp.first = 0;
          key = 0;
        }
      }
    }
  }
  if (!config.no_prefetch) {
    if (vp.first > 0) {
      vp.first = 0;
    }

    hashtable->flush_find_queue(vp);
    found += vp.first;
  }

  const auto end = RDTSCP();
  duration += end - start;

  return {duration, found};
}

void ZipfianTest::run(Shard *shard, BaseHashTable *hashtable, double skew,
                      unsigned int count) {
  OpTimings insert_timings{};
  static_assert(HT_TESTS_MAX_STRIDE - 1 ==
                1);  // Otherwise timing logic is wrong

  PLOG_INFO.printf(
      "Zipfian test run: thread %u, ht size: %lu, insertions: %lu, skew "
      "%f",
      shard->shard_idx, config.ht_size, HT_TESTS_NUM_INSERTS, skew);

  for (uint32_t i = 1; i < HT_TESTS_MAX_STRIDE; i++) {
    insert_timings =
        do_zipfian_inserts(hashtable, skew, count, shard->shard_idx);
    PLOG_INFO.printf(
        "Quick stats: thread %u, Batch size: %d, cycles per "
        "insertion:%lu",
        shard->shard_idx, i, insert_timings.duration / insert_timings.op_count);

#ifdef CALC_STATS
    PLOG_INFO.printf("Reprobes %lu soft_reprobes %lu", hashtable->num_reprobes,
                     hashtable->num_soft_reprobes);
#endif
  }

  shard->stats->insertion_cycles = insert_timings.duration;
  shard->stats->num_inserts = insert_timings.op_count;

  sleep(1);

  const auto num_finds = do_zipfian_gets(hashtable, count, shard->shard_idx);

  shard->stats->find_cycles = num_finds.duration;
  shard->stats->num_finds = num_finds.op_count;

  if (num_finds.op_count > 0) {
    PLOG_INFO.printf("thread %u | num_finds %lu | cycles per get: %lu",
                     shard->shard_idx, num_finds.op_count,
                     num_finds.duration / num_finds.op_count);
  }

#ifndef WITH_PAPI_LIB
  get_ht_stats(shard, hashtable);
#endif
}

}  // namespace kvstore
