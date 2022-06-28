#include "tests/SynthTest.hpp"

#include <algorithm>
#include <cstdint>
#include <plog/Log.h>
#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif
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

#ifdef ENABLE_HIGH_LEVEL_PAPI
void papi_check(int code) {
  if (code != PAPI_OK) {
    PLOG_ERROR << "PAPI call failed with code " << code;
    std::terminate();
  }
}
#endif

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

__thread struct xorwow_state _xw_state, init_state;

OpTimings SynthTest::synth_run(BaseHashTable *ktable, uint8_t start) {
  auto k = 0;
  auto inserted = 0lu;
  std::uint64_t duration{};

  xorwow_init(&_xw_state);
  init_state = _xw_state;

  __attribute__((aligned(64))) InsertFindArgument items[HT_TESTS_FIND_BATCH_LENGTH] = {0};
#ifdef WITH_VTUNE_LIB
  std::string evt_name(ht_type_strings[config.ht_type]);
  evt_name += "_insertions";
  static const auto event =
      __itt_event_create(evt_name.c_str(), evt_name.length());
  __itt_event_start(event);
#endif

  papi_start_region("synthetic_insertions");
  const auto t_start = RDTSC_START();
  for (auto j = 0u; j < config.insert_factor; j++) {
    uint64_t count = std::max(static_cast<uint64_t>(1), HT_TESTS_NUM_INSERTS * start);
    _xw_state = init_state;
    for (auto i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {
      std::uint64_t value{};
#if defined(SAME_KMER)
      value = 32;
#elif defined(XORWOW)
#warning "Xorwow rand kmer insert"
      value = xorwow(&_xw_state);
#else
      value = count;
#endif
      items[k].key = items[k].value = value;

      if (config.no_prefetch) {
        ktable->insert_noprefetch((void *)&items[k]);
        k = (k + 1) & (HT_TESTS_BATCH_LENGTH - 1);
        count++;
        inserted++;
      } else {
        count++;
        if (++k == HT_TESTS_BATCH_LENGTH) {
          KeyPairs kp = std::make_pair(HT_TESTS_BATCH_LENGTH, items);
          ktable->insert_batch(kp);

          k = 0;
          inserted += kp.first;
        }
      }
#if defined(SAME_KMER)
      count++;
#endif
    }
    //PLOG_INFO.printf("inserted %" PRIu64 " items", inserted);
    // flush the last batch explicitly
    // printf("%s calling flush queue\n", __func__);
    if (!config.no_prefetch) {
      ktable->flush_insert_queue();
    }
  }

  const auto t_end = RDTSCP();
  papi_end_region("synthetic_insertions");

#ifdef WITH_VTUNE_LIB
  __itt_event_end(event);
#endif

  duration += t_end - t_start;
  // printf("%s: %p\n", __func__, ktable->find(&kmers[k]));

  return {duration, HT_TESTS_NUM_INSERTS * config.insert_factor};
}

OpTimings SynthTest::synth_run_get(BaseHashTable *ktable, uint8_t tid) {
  auto k = 0;
  uint64_t found = 0;

  _xw_state = init_state;

  __attribute__((aligned(64))) InsertFindArgument items[HT_TESTS_FIND_BATCH_LENGTH] = {0};

  FindResult *results = new FindResult[HT_TESTS_FIND_BATCH_LENGTH];
  ValuePairs vp = std::make_pair(0, results);

  std::uint64_t duration{};

#ifdef WITH_VTUNE_LIB
  std::string evt_name(ht_type_strings[config.ht_type]);
  evt_name += "_finds";
  static const auto event =
      __itt_event_create(evt_name.c_str(), evt_name.length());
  __itt_event_start(event);
#endif

  const auto t_start = RDTSC_START();

  for (auto j = 0u; j < config.insert_factor; j++) {
    uint64_t count =
      std::max(HT_TESTS_NUM_INSERTS * tid, static_cast<uint64_t>(1));
    _xw_state = init_state;
    for (auto i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {
      std::uint64_t value{};
#if defined(SAME_KMER)
      value = 32;
#elif defined(XORWOW)
#warning "Xorwow rand kmer insert"
      value = xorwow(&_xw_state);
#else
      value = count;
      count++;
#endif
      items[k].key = value;
      items[k].id = value;
      items[k].part_id = tid;

      if (config.no_prefetch) {
        void *kv = ktable->find_noprefetch(&items[k]);
        if (kv) found += 1;
        k = (k + 1) & (HT_TESTS_BATCH_LENGTH - 1);
      } else {
        if (++k == HT_TESTS_FIND_BATCH_LENGTH) {
          KeyPairs kp = std::make_pair(HT_TESTS_FIND_BATCH_LENGTH, items);

          ktable->find_batch(kp, vp);

          found += vp.first;
          vp.first = 0;
          k = 0;
          //not_found += HT_TESTS_FIND_BATCH_LENGTH - vp.first;
        }
      }
    }
  }

  if (!config.no_prefetch) {
    if (vp.first > 0) {
      vp.first = 0;
    }

    ktable->flush_find_queue(vp);

    found += vp.first;
  }

  const auto t_end = RDTSCP();

#ifdef WITH_VTUNE_LIB
  __itt_event_end(event);
#endif

  duration = t_end - t_start;

  PLOGI.printf("found %" PRIu64 "", found);
  return {duration, found};
}

uint64_t seed2 = 123456789;
inline uint64_t PREFETCH_STRIDE = 64;

static uint64_t insert_done;

void SynthTest::synth_run_exec(Shard *sh, BaseHashTable *kmer_ht) {
  OpTimings insert_times{};

  PLOG_INFO.printf("Synth test run: thread %u, ht size: %" PRIu64 ", insertions: %" PRIu64 "",
                   sh->shard_idx, HT_TESTS_HT_SIZE, HT_TESTS_NUM_INSERTS);

  for (uint32_t i = 1; i < HT_TESTS_MAX_STRIDE; i++) {
    insert_times = synth_run(kmer_ht, sh->shard_idx);
    PLOG_INFO.printf(
        "Quick stats: thread %u, Batch size: %d, cycles per "
        "insertion:%" PRIu64 "",
        sh->shard_idx, i, insert_times.duration / insert_times.op_count);

#ifdef CALC_STATS
    printf(" Reprobes %" PRIu64 " soft_reprobes %" PRIu64 "\n", kmer_ht->num_reprobes,
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

  if (find_times.op_count > 0) {
    PLOG_INFO.printf(
        "thread %u | num_finds %" PRIu64 " | rdtsc_diff %" PRIu64 " | cycles per get: %" PRIu64 "",
        sh->shard_idx, find_times.op_count, find_times.duration,
        find_times.duration / find_times.op_count);
  }

#ifndef WITH_PAPI_LIB
  get_ht_stats(sh, kmer_ht);
  // kmer_ht->display();
#endif
}

}
