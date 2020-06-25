#ifndef HT_TESTS
#define HT_TESTS

#include "misc_lib.h"

struct kmer {
  char data[KMER_DATA_LENGTH];
};

const uint32_t PREFETCH_QUEUE_SIZE = 64;

extern KmerHashTable *init_ht(uint64_t, uint8_t);
extern void get_ht_stats(__shard *, KmerHashTable *);

// #define HT_TESTS_BATCH_LENGTH 32
#define HT_TESTS_BATCH_LENGTH 128

const uint64_t HT_TESTS_HT_SIZE = (1 << 26);
uint64_t HT_TESTS_NUM_INSERTS;

#define HT_TESTS_MAX_STRIDE 2

__thread struct xorwow_state xw_state;
__thread struct xorwow_state xw_state2;

uint64_t synth_run(KmerHashTable *ktable)
{
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

uint64_t seed = 123456789;
uint64_t seed2 = 123456789;
uint64_t PREFETCH_STRIDE = 64;

int myrand(uint64_t *seed)
{
  uint64_t m = 1 << 31;
  *seed = (1103515245 * (*seed) + 12345) % m;
  return *seed;
}

uint64_t prefetch_test_run(SimpleKmerHashTable *ktable)
{
  auto count = 0;
  [[maybe_unused]] auto k = 0;

  // seed2 = seed;

#ifdef XORWOW_SCAN
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
    ktable->touch(i);
    //ktable->prefetch(i+(1 << 20) & (HT_TESTS_NUM_INSERTS - 1));
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

void synth_run_exec(__shard *sh, KmerHashTable *kmer_ht)
{
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

void prefetch_test_run_exec(__shard *sh, KmerHashTable *kmer_ht)
{
  uint64_t num_inserts = 0;
  uint64_t t_start, t_end;

  printf("[INFO] Prefetch test run: thread %u, ht size:%lu, insertions:%lu\n",
         sh->shard_idx, HT_TESTS_HT_SIZE, HT_TESTS_NUM_INSERTS);

  xorwow_init(&xw_state);

  for (auto i = 0; i < HT_TESTS_MAX_STRIDE; i++) {
    t_start = RDTSC_START();
    //PREFETCH_STRIDE = i;
    num_inserts = prefetch_test_run((SimpleKmerHashTable *)kmer_ht);
    t_end = RDTSCP();
    printf(
        "[INFO] Quick stats: thread %u, Prefetch stride: %lu, cycles per "
        "insertion:%lu\n",
        sh->shard_idx, PREFETCH_STRIDE, (t_end - t_start) / num_inserts);
  }

  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = num_inserts;
  get_ht_stats(sh, kmer_ht);
}

#endif /* HASHTABLE_TESTS */
