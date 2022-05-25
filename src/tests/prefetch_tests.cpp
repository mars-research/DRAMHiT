#include <sched.h>

#include "tests/PrefetchTest.hpp"
#include "misc_lib.h"
#include "print_stats.h"
#include "types.hpp"
#include "xorwow.hpp"

namespace kmercounter {

extern void get_ht_stats(Shard *, BaseHashTable *);
extern uint64_t HT_TESTS_HT_SIZE;
extern uint64_t HT_TESTS_NUM_INSERTS;

inline uint64_t seed = 123456789;
inline uint64_t PREFETCH_STRIDE = 64;

__thread struct xorwow_state xw_state;
__thread struct xorwow_state xw_state2;

inline int myrand(uint64_t *seed) {
  uint64_t m = 1 << 31;
  *seed = (1103515245 * (*seed) + 12345) % m;
  return *seed;
}

uint64_t PrefetchTest::prefetch_test_run(
    PartitionedHashStore<Prefetch_KV, PrefetchKV_Queue> *ktable) {
  auto count = 0;
  auto sum = 0;
  [[maybe_unused]] auto k = 0;

  printf("NUM inserts %lu\n", HT_TESTS_NUM_INSERTS);

  // seed2 = seed;

#ifdef XORWOW_SCAN
#warning "XORWOW_SCAN"
  memcpy(&xw_state2, &xw_state, sizeof(xw_state));

  for (auto i = 0u; i < PREFETCH_STRIDE; i++) {
    // k = rand(&seed2);
    k = xorwow(&xw_state2);

    // printf("p: %lu\n", k);
    ktable->prefetch(k);
  }
#endif  // XORWOW_SCAN

  for (auto i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {
    // k = myrand(&seed);
    // k = rand();

#ifdef XORWOW_SCAN
    /*
     * With if-then dependency it's 99 cycles, without 30 (no prefetch)
     *
     * Prefetch itself doesn't help, 100 cycles with normal prefetch (with
     * dependency).
     *
     * However, if I prefetch with the "write" it seems to help
     *
     * Prefetch test run: ht size:1073741824, insertions:67108864
     * Prefetch stride: 0, cycles per insertion:121
     * Prefetch stride: 1, cycles per insertion:36
     * Prefetch stride: 2, cycles per insertion:46
     * Prefetch stride: 3, cycles per insertion:44
     * Prefetch stride: 4, cycles per insertion:45
     * Prefetch stride: 5, cycles per insertion:46
     * Prefetch stride: 6, cycles per insertion:47
     */

    k = xorwow(&xw_state);

    // printf("t: %lu\n", k);
    ktable->touch(k);
#endif

#ifdef SERIAL_SCAN
    /* Fully prefethed serial scan is 14 cycles */
    sum += ktable->touch(i);
    // ktable->prefetch(i + 32);
#endif

#ifdef XORWOW_SCAN
    // k = rand(&seed2);
    k = xorwow(&xw_state2);
    // printf("p: %lu\n", k);
    ktable->prefetch(k);
#endif
    count++;
  }
  return count;
}

void PrefetchTest::prefetch_test_run_exec(Shard *sh, Configuration &cfg,
                                          BaseHashTable *kmer_ht) {
  uint64_t num_inserts = 0;
  uint64_t t_start, t_end;

  printf("[INFO] Prefetch test run: thread %u, ht size:%lu, insertions:%lu\n",
         sh->shard_idx, HT_TESTS_HT_SIZE, HT_TESTS_NUM_INSERTS);

#ifdef XORWOW_SCAN
  xorwow_init(&xw_state);
#endif

  // for (auto i = 0; i < HT_TESTS_MAX_STRIDE; i++) {
  t_start = RDTSC_START();
  // PREFETCH_STRIDE = i;
  num_inserts = prefetch_test_run(
      (PartitionedHashStore<Prefetch_KV, PrefetchKV_Queue> *)kmer_ht);
  t_end = RDTSCP();
  printf(
      "[INFO] Quick stats: thread %u, Prefetch stride: %lu, cycles per "
      "insertion:%lu\n",
      sh->shard_idx, PREFETCH_STRIDE, (t_end - t_start) / num_inserts);
  //}

  sh->stats->insertions.duration = (t_end - t_start);
  sh->stats->insertions.op_count = num_inserts;
#ifndef WITH_PAPI_LIB
  get_ht_stats(sh, kmer_ht);
#endif
}

}  // namespace kmercounter
