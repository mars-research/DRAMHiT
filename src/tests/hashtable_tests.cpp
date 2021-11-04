#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

#include <atomic>
#include <sstream>

#include "misc_lib.h"
#include "print_stats.h"
#include "sync.h"
#include "tests.hpp"
#include "zipf.h"

#ifdef ENABLE_HIGH_LEVEL_PAPI
#include <papi.h>
#endif

namespace kmercounter {
struct kmer {
  char data[KMER_DATA_LENGTH];
};

extern void get_ht_stats(Shard *, BaseHashTable *);

uint64_t HT_TESTS_HT_SIZE = (1 << 26ULL);  // * 8ull;
uint64_t HT_TESTS_NUM_INSERTS;

#define HT_TESTS_MAX_STRIDE 2

void papi_check(int code) {
#ifdef ENABLE_HIGH_LEVEL_PAPI
  if (code != PAPI_OK) {
    PLOG_ERROR << "PAPI call failed with code " << code;
    std::terminate();
  }
#endif
}

void papi_start_region(const char *name) {
#ifdef ENABLE_HIGH_LEVEL_PAPI
  papi_check(PAPI_hl_region_begin(name));
#endif
}

void papi_end_region(const char *name) {
#ifdef ENABLE_HIGH_LEVEL_PAPI
  papi_check(PAPI_hl_region_end(name));
#endif
}

OpTimings SynthTest::synth_run(BaseHashTable *ktable, uint8_t start) {
  uint64_t count = HT_TESTS_NUM_INSERTS * start;
  auto k = 0;
  uint64_t i = 0;
  struct xorwow_state _xw_state;
  auto inserted = 0lu;
  std::uint64_t duration{};

  xorwow_init(&_xw_state);
  if (start == 0) count = 1;
  __attribute__((aligned(64))) struct kmer kmers[HT_TESTS_BATCH_LENGTH] = {0};
  __attribute__((aligned(64))) struct Item items[HT_TESTS_BATCH_LENGTH] = {0};
  __attribute__((aligned(64))) uint64_t keys[HT_TESTS_BATCH_LENGTH] = {0};
  __attribute__((aligned(64))) Keys _items[HT_TESTS_FIND_BATCH_LENGTH] = {0};
#ifdef WITH_VTUNE_LIB
  static const auto event =
      __itt_event_create("inserting", strlen("inserting"));
  __itt_event_start(event);
#endif

  papi_start_region("synthetic_insertions");
  const auto t_start = RDTSC_START();
  for (i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {
#if defined(SAME_KMER)
    //*((uint64_t *)&kmers[k].data) = count & (32 - 1);
    *((uint64_t *)&kmers[k].data) = 32;
    items[k].kvpair.key = 32;
    items[k].kvpair.value = 32;
    keys[k] = 32;
#elif defined(XORWOW)
#warning "Xorwow rand kmer insert"
    const auto value = xorwow(&_xw_state);
    _items[k].key = value;
    keys[k] = value;
#else
    // *((uint64_t *)&kmers[k].data) = count;
    //*((uint64_t *)items[k].key()) = count;
    //*((uint64_t *)items[k].value()) = count;
    keys[k] = count;
    _items[k].key = count;
#endif

#ifdef NO_PREFETCH
#warning "Compiling no prefetch"
    ktable->insert_noprefetch((void *)&keys[k]);
    k = (k + 1) & (HT_TESTS_BATCH_LENGTH - 1);
    count++;
#else

    // printf("[%s:%d] inserting i= %d, data %lu\n", __func__, start, i, count);
    // printf("%s, inserting i= %d\n", __func__, i);
    // ktable->insert((void *)&kmers[k]);
    // printf("->Inserting %lu\n", count);
    count++;
    // k++;
    // ktable->insert((void *)&items[k]);
    // ktable->insert((void *)&items[k]);
    if (++k == HT_TESTS_BATCH_LENGTH) {
      KeyPairs kp = std::make_pair(HT_TESTS_BATCH_LENGTH, &_items[0]);
      ktable->insert_batch(kp);

      k = 0;
      inserted += kp.first;
    }
#endif  // NO_PREFETCH
        // k = (k + 1) & (HT_TESTS_BATCH_LENGTH - 1);
#if defined(SAME_KMER)
    count++;
#endif
  }
  PLOG_INFO.printf("inserted %lu items", inserted);
  // flush the last batch explicitly
  // printf("%s calling flush queue\n", __func__);
#if !defined(NO_PREFETCH)
  ktable->flush_insert_queue();
#endif

  const auto t_end = RDTSCP();
  papi_end_region("synthetic_insertions");

#ifdef WITH_VTUNE_LIB
  __itt_event_end(event);
#endif

  duration += t_end - t_start;
  // printf("%s: %p\n", __func__, ktable->find(&kmers[k]));

  return {duration, HT_TESTS_NUM_INSERTS};
}

OpTimings SynthTest::synth_run_get(BaseHashTable *ktable, uint8_t start) {
  uint64_t count = HT_TESTS_NUM_INSERTS * start;
  auto k = 0;
  uint64_t found = 0, not_found = 0;
  if (start == 0) count = 1;

  __attribute__((aligned(64))) Keys items[HT_TESTS_FIND_BATCH_LENGTH] = {0};

  Values *values;
  values = new Values[HT_TESTS_FIND_BATCH_LENGTH];
  ValuePairs vp = std::make_pair(0, values);

  std::uint64_t duration{};

  for (auto i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {
    // printf("[%s:%d] inserting i= %d, data %lu\n", __func__, start, i, count);
#if defined(SAME_KMER)
    items[k].key = items[k].id = 32;
    k++;
#else
    items[k].key = count;
    items[k].id = count;
    count++;
#endif

#ifdef NO_PREFETCH
    {
      void *kv = ktable->find_noprefetch(&items[k]);
      if (kv) found += 1;
      k = (k + 1) & (HT_TESTS_BATCH_LENGTH - 1);
    }
#else
    if (++k == HT_TESTS_FIND_BATCH_LENGTH) {
      KeyPairs kp = std::make_pair(HT_TESTS_FIND_BATCH_LENGTH, &items[0]);
      // printf("%s, calling find_batch i = %d\n", __func__, i);

      const auto t_start = RDTSC_START();
      ktable->find_batch(kp, vp);
      const auto t_end = RDTSCP();
      duration += t_end - t_start;

      found += vp.first;
      vp.first = 0;
      k = 0;
      not_found += HT_TESTS_FIND_BATCH_LENGTH - found;
      // printf("\t count %lu | found -> %lu | not_found -> %lu \n", count,
      // found, not_found);
    }
#endif  // NO_PREFETCH
    // printf("\t count %lu | found -> %lu\n", count, found);
  }
#if !defined(NO_PREFETCH)
  if (vp.first > 0) {
    vp.first = 0;
  }

  const auto t_start = RDTSC_START();
  ktable->flush_find_queue(vp);
  const auto t_end = RDTSCP();
  duration += t_end - t_start;

  found += vp.first;
#endif
  return {duration, found};
}

uint64_t seed2 = 123456789;
inline uint64_t PREFETCH_STRIDE = 64;

void SynthTest::synth_run_exec(Shard *sh, BaseHashTable *kmer_ht) {
  OpTimings insert_times{};

  PLOG_INFO.printf("Synth test run: thread %u, ht size: %lu, insertions: %lu",
         sh->shard_idx, HT_TESTS_HT_SIZE, HT_TESTS_NUM_INSERTS);

  for (auto i = 1; i < HT_TESTS_MAX_STRIDE; i++) {
    insert_times = synth_run(kmer_ht, sh->shard_idx);
    PLOG_INFO.printf(
        "Quick stats: thread %u, Batch size: %d, cycles per "
        "insertion:%lu",
        sh->shard_idx, i, insert_times.duration / insert_times.op_count);

#ifdef CALC_STATS
    printf(" Reprobes %lu soft_reprobes %lu\n", kmer_ht->num_reprobes,
           kmer_ht->num_soft_reprobes);
#endif
  }
  sh->stats->insertion_cycles = insert_times.duration;
  sh->stats->num_inserts = insert_times.op_count;

  sleep(1);

  const auto find_times = synth_run_get(kmer_ht, sh->shard_idx);

  sh->stats->find_cycles = find_times.duration;
  sh->stats->num_finds = find_times.op_count;

  if (find_times.op_count > 0)
    PLOG_INFO.printf("thread %u | num_finds %lu | cycles per get: %lu",
           sh->shard_idx, find_times.op_count,
           find_times.duration / find_times.op_count);

#ifndef WITH_PAPI_LIB
  get_ht_stats(sh, kmer_ht);
  // kmer_ht->display();
#endif
}

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

  for (auto i = 1; i < HT_TESTS_MAX_STRIDE; i++) {
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
