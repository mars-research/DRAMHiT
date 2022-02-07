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

#ifdef ENABLE_HIGH_LEVEL_PAPI
#include <papi.h>
#endif

namespace kmercounter {

extern void get_ht_stats(Shard *, BaseHashTable *);

// default size for hashtable
// when each element is 16 bytes (2 * uint64_t), this amounts to 64 GiB
uint64_t HT_TESTS_HT_SIZE = (1ull << 26) * 64;
uint64_t HT_TESTS_NUM_INSERTS;

OpTimings do_zipfian_inserts(BaseHashTable *hashtable, double skew,
                             unsigned int count, unsigned int id) {
  constexpr auto keyrange_width = 64ull * (1ull << 26);  // 192 * (1 << 20);
  zipf_distribution distribution{skew, keyrange_width, id + 1};
  std::uint64_t duration{};

  static std::atomic_uint fence{};
  std::vector<std::uint64_t> values(HT_TESTS_NUM_INSERTS);
  for (auto &value : values) value = distribution();
  ++fence;
  while (fence < count) _mm_pause();

#ifdef WITH_VTUNE_LIB
  static const auto event =
      __itt_event_create("inserting", strlen("inserting"));
  __itt_event_start(event);
#endif

#ifdef NO_PREFETCH
#warning "Zipfian no-prefetch"
  const auto start = RDTSC_START();
  for (unsigned int n{}; n < HT_TESTS_NUM_INSERTS; ++n) {
    if (n % 8 == 0 && n + 16 < values.size())
      prefetch_object<false>(&values.at(n + 16), 64);

    hashtable->insert_noprefetch(&values.at(n));
  }

  const auto end = RDTSCP();
  duration += end - start;
#else
  unsigned int key{};
  alignas(64) Keys items[HT_TESTS_BATCH_LENGTH]{};
  const auto start = RDTSC_START();
  for (unsigned int n{}; n < HT_TESTS_NUM_INSERTS; ++n) {
    if (n % 8 == 0 && n + 16 < values.size())
      prefetch_object<false>(&values.at(n + 16), 64);

    items[key] = {values.at(n), n};

    if (++key == HT_TESTS_BATCH_LENGTH) {
      KeyPairs keypairs{HT_TESTS_BATCH_LENGTH, items};
      hashtable->insert_batch(keypairs);
      key = 0;
    }
  }

  hashtable->flush_insert_queue();
  const auto end = RDTSCP();
  duration += end - start;
#endif

  PLOG_DEBUG << "Inserts done; Reprobes: " << hashtable->num_reprobes
             << ", Soft Reprobes: " << hashtable->num_soft_reprobes;

#ifdef WITH_VTUNE_LIB
  __itt_event_end(event);
#endif

  return {duration, HT_TESTS_NUM_INSERTS};
}

OpTimings do_zipfian_gets(BaseHashTable *kmer_ht, unsigned int id) {
  PLOG_WARNING.printf("Zipfian gets not implemented yet");
  return {0, 1};
}

void ZipfianTest::run(Shard *shard, BaseHashTable *hashtable, double skew,
                      unsigned int count) {
  OpTimings insert_timings{};
  static_assert(HT_TESTS_MAX_STRIDE - 1 ==
                1);  // Otherwise timing logic is wrong

  PLOG_INFO.printf(
      "Zipfian test run: thread %u, ht size: %lu, insertions: %lu, skew "
      "%f",
      shard->shard_idx, HT_TESTS_HT_SIZE, HT_TESTS_NUM_INSERTS, skew);

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

  const auto num_finds = do_zipfian_gets(hashtable, shard->shard_idx);

  shard->stats->find_cycles = num_finds.duration;
  shard->stats->num_finds = num_finds.op_count;

  if (num_finds.op_count > 0)
    PLOG_INFO.printf("thread %u | num_finds %lu | cycles per get: %lu",
                     shard->shard_idx, num_finds.op_count,
                     num_finds.duration / num_finds.op_count);

#ifndef WITH_PAPI_LIB
  get_ht_stats(shard, hashtable);
#endif
}

}  // namespace kmercounter
