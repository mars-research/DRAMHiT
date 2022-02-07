#include "tests/SynthTest.hpp"

#include <algorithm>
#include <cstdint>
#include <plog/Log.h>

#include "constants.hpp"
#include "hashtables/base_kht.hpp"
#include "hashtables/kvtypes.hpp"
#include "print_stats.h"
#include "sync.h"
#include "xorwow.hpp"
#ifdef ENABLE_HIGH_LEVEL_PAPI
#include <papi.h>
#endif

#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

namespace kmercounter {
namespace {
struct kmer {
  char data[KMER_DATA_LENGTH];
};

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
} // namespace

extern Configuration config;
extern uint64_t HT_TESTS_HT_SIZE;
extern uint64_t HT_TESTS_NUM_INSERTS;

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
  std::string evt_name(ht_type_strings[config.ht_type]);
  evt_name += "_insertions";
  static const auto event =
      __itt_event_create(evt_name.c_str(), evt_name.length());
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
#ifdef NO_PREFETCH
    keys[k] = count;
#endif
    _items[k].key = count;
    _items[k].value = count;
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

OpTimings SynthTest::synth_run_get(BaseHashTable *ktable, uint8_t tid) {
  uint64_t count =
      std::max(HT_TESTS_NUM_INSERTS * tid, static_cast<uint64_t>(1));
  auto k = 0;
  uint64_t found = 0, not_found = 0;

  __attribute__((aligned(64))) Keys items[HT_TESTS_FIND_BATCH_LENGTH] = {0};

  Values *values;
  values = new Values[HT_TESTS_FIND_BATCH_LENGTH];
  ValuePairs vp = std::make_pair(0, values);

  std::uint64_t duration{};

#ifdef WITH_VTUNE_LIB
  std::string evt_name(ht_type_strings[config.ht_type]);
  evt_name += "_finds";
  static const auto event =
      __itt_event_create(evt_name.c_str(), evt_name.length());
  __itt_event_start(event);
#endif

  const auto t_start = RDTSC_START();

  for (auto i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {
#if defined(SAME_KMER)
    items[k].key = items[k].id = 32;
    k++;
#else
    items[k].key = count;
    items[k].id = count;
    // part_id is relevant only for partitioned ht
    items[k].part_id = tid;
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

      ktable->find_batch(kp, vp);

      found += vp.first;
      vp.first = 0;
      k = 0;
      not_found += HT_TESTS_FIND_BATCH_LENGTH - found;
    }
#endif  // NO_PREFETCH
  }

#if !defined(NO_PREFETCH)
  if (vp.first > 0) {
    vp.first = 0;
  }

  ktable->flush_find_queue(vp);

  found += vp.first;
#endif

  const auto t_end = RDTSCP();

#ifdef WITH_VTUNE_LIB
  __itt_event_end(event);
#endif

  duration = t_end - t_start;

  return {duration, found};
}

uint64_t seed2 = 123456789;
inline uint64_t PREFETCH_STRIDE = 64;

static uint64_t insert_done;

void SynthTest::synth_run_exec(Shard *sh, BaseHashTable *kmer_ht) {
  OpTimings insert_times{};

  PLOG_INFO.printf("Synth test run: thread %u, ht size: %lu, insertions: %lu",
                   sh->shard_idx, HT_TESTS_HT_SIZE, HT_TESTS_NUM_INSERTS);

  for (uint32_t i = 1; i < HT_TESTS_MAX_STRIDE; i++) {
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

  fipc_test_FAI(insert_done);

  while (insert_done < config.num_threads) {
    fipc_test_pause();
  }

  const auto find_times = synth_run_get(kmer_ht, sh->shard_idx);

  sh->stats->find_cycles = find_times.duration;
  sh->stats->num_finds = find_times.op_count;

  if (find_times.op_count > 0)
    PLOG_INFO.printf(
        "thread %u | num_finds %lu | rdtsc_diff %lu | cycles per get: %lu",
        sh->shard_idx, find_times.op_count, find_times.duration,
        find_times.duration / find_times.op_count);

#ifndef WITH_PAPI_LIB
  get_ht_stats(sh, kmer_ht);
  // kmer_ht->display();
#endif
}

}