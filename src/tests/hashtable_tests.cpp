#include "misc_lib.h"
#include "print_stats.h"
#include "sync.h"
#include "tests.hpp"

namespace kmercounter {
struct kmer {
  char data[KMER_DATA_LENGTH];
};

extern void get_ht_stats(Shard *, BaseHashTable *);

// #define HT_TESTS_BATCH_LENGTH 32
#define HT_TESTS_BATCH_LENGTH 128

uint64_t HT_TESTS_HT_SIZE = (1 << 26);
uint64_t HT_TESTS_NUM_INSERTS;

#define HT_TESTS_MAX_STRIDE 2

uint64_t SynthTest::synth_run(BaseHashTable *ktable) {
  uint64_t count = 1;
  auto k = 0;
  struct xorwow_state _xw_state;

  xorwow_init(&_xw_state);

  __attribute__((aligned(64))) struct kmer kmers[HT_TESTS_BATCH_LENGTH] = {0};
  __attribute__((aligned(64))) struct Item items[HT_TESTS_BATCH_LENGTH] = {0};
  __attribute__((aligned(64))) uint64_t keys[HT_TESTS_BATCH_LENGTH] = {0};

  for (auto i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {
#if defined(SAME_KMER)
    //*((uint64_t *)&kmers[k].data) = count & (32 - 1);
    *((uint64_t *)&kmers[k].data) = 32;
    *((uint64_t *)items[k].key()) = 32;
    *((uint64_t *)items[k].value()) = 32;
#elif defined(XORWOW)
#warning "Xorwow rand kmer insert"
    *((uint64_t *)&kmers[k].data) = xorwow(&_xw_state);
#else
    *((uint64_t *)&kmers[k].data) = count;
    *((uint64_t *)items[k].key()) = count;
    *((uint64_t *)items[k].value()) = count;
    keys[k] = count;
#endif
    // printf("%s, inserting i= %d, data %lu\n", __func__, i, count);
    // printf("%s, inserting i= %d\n", __func__, i);
    // ktable->insert((void *)&kmers[k]);
    // printf("->Inserting %lu\n", count);
    count++;
    // ktable->insert((void *)&items[k]);
    ktable->insert((void *)&keys[k]);
    k = (k + 1) & (HT_TESTS_BATCH_LENGTH - 1);
#if defined(SAME_KMER)
    count++;
#endif
  }
  // flush the last batch explicitly
  printf("%s calling flush queue\n", __func__);
  ktable->flush_queue();
  printf("%s: %p\n", __func__, ktable->find(&kmers[k]));
  return count;
}

uint64_t seed2 = 123456789;
inline uint64_t PREFETCH_STRIDE = 64;

void SynthTest::synth_run_exec(Shard *sh, BaseHashTable *kmer_ht) {
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
        "insertion:%lu \n",
        sh->shard_idx, i, (t_end - t_start) / num_inserts);

#ifdef CALC_STATS
    printf(" Reprobes %lu soft_reprobes %lu\n", kmer_ht->num_reprobes,
           kmer_ht->num_soft_reprobes);
#endif
  }
  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = num_inserts;
#ifndef WITH_PAPI_LIB
  get_ht_stats(sh, kmer_ht);
  // kmer_ht->display();
#endif
}

}  // namespace kmercounter
