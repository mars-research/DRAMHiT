#ifndef HT_TESTS
#define HT_TESTS

#include "misc_lib.h"
#include "print_stats.h"
#include "sync.h"
#include "tests.hpp"

namespace kmercounter {
struct kmer {
  char data[KMER_DATA_LENGTH];
};

extern void get_ht_stats(Shard *, KmerHashTable *);

// #define HT_TESTS_BATCH_LENGTH 32
#define HT_TESTS_BATCH_LENGTH 128

uint64_t HT_TESTS_HT_SIZE = (1 << 26);
uint64_t HT_TESTS_NUM_INSERTS;

#define HT_TESTS_MAX_STRIDE 2

__thread struct xorwow_state xw_state;
__thread struct xorwow_state xw_state2;

uint64_t SynthTest::synth_run(KmerHashTable *ktable) {
  auto count = 0;
  auto k = 0;
  struct xorwow_state _xw_state;

  xorwow_init(&_xw_state);

  __attribute__((aligned(64))) struct kmer kmers[HT_TESTS_BATCH_LENGTH];

  for (auto i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {
#if defined(SAME_KMER)
    *((uint64_t *)&kmers[k].data) = count & (32 - 1);
#elif defined(XORWOW)
#warning "Xorwow rand kmer insert"
    *((uint64_t *)&kmers[k].data) = xorwow(&_xw_state);
#else
    *((uint64_t *)&kmers[k].data) = count;
#endif
    ktable->insert((void *)&kmers[k]);
    k = (k + 1) & (HT_TESTS_BATCH_LENGTH - 1);
    count++;
  }

  return count;
}

uint64_t seed2 = 123456789;
inline uint64_t PREFETCH_STRIDE = 64;

void SynthTest::synth_run_exec(Shard *sh, KmerHashTable *kmer_ht) {
  uint64_t num_inserts = 0;
  uint64_t t_start, t_end;

  printf("[INFO] Synth test run: thread %u, ht size: %lu, insertions: %lu\n",
         sh->shard_idx, HT_TESTS_HT_SIZE, HT_TESTS_NUM_INSERTS);

  for (auto i = 1; i < HT_TESTS_MAX_STRIDE; i++) {
    t_start = RDTSC_START();

    // PREFETCH_QUEUE_SIZE = i;

    // PREFETCH_QUEUE_SIZE = 32;
    num_inserts = synth_run(kmer_ht);

    t_end = RDTSCP();
    printf(
        "[INFO] Quick stats: thread %u, Batch size: %d, cycles per "
        "insertion:%lu\n",
        sh->shard_idx, i, (t_end - t_start) / num_inserts);
  }
  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = num_inserts;
  get_ht_stats(sh, kmer_ht);
}

}  // namespace kmercounter
#endif /* HASHTABLE_TESTS */
