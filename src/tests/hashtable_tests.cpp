#include "misc_lib.h"
#include "print_stats.h"
#include "sync.h"
#include "tests.hpp"

namespace kmercounter {
struct kmer {
  char data[KMER_DATA_LENGTH];
};

extern void get_ht_stats(Shard *, BaseHashTable *);

uint64_t HT_TESTS_HT_SIZE = (1 << 26ULL);  // * 8ull;
uint64_t HT_TESTS_NUM_INSERTS;

#define HT_TESTS_MAX_STRIDE 2

uint64_t SynthTest::synth_run(BaseHashTable *ktable, uint8_t start) {
  uint64_t count = HT_TESTS_NUM_INSERTS * start;
  auto k = 0;
  auto i = 0;
  struct xorwow_state _xw_state;
  auto inserted = 0lu;

  xorwow_init(&_xw_state);
  if (start == 0) count = 1;
  __attribute__((aligned(64))) struct kmer kmers[HT_TESTS_BATCH_LENGTH] = {0};
  __attribute__((aligned(64))) struct Item items[HT_TESTS_BATCH_LENGTH] = {0};
  __attribute__((aligned(64))) uint64_t keys[HT_TESTS_BATCH_LENGTH] = {0};
  __attribute__((aligned(64))) Keys _items[HT_TESTS_FIND_BATCH_LENGTH] = {0};
  for (i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {
#if defined(SAME_KMER)
    //*((uint64_t *)&kmers[k].data) = count & (32 - 1);
    *((uint64_t *)&kmers[k].data) = 32;
    *((uint64_t *)items[k].key()) = 32;
    *((uint64_t *)items[k].value()) = 32;
    keys[k] = 32;
#elif defined(XORWOW)
#warning "Xorwow rand kmer insert"
    *((uint64_t *)&kmers[k].data) = xorwow(&_xw_state);
#else
    // *((uint64_t *)&kmers[k].data) = count;
    *((uint64_t *)items[k].key()) = count;
    *((uint64_t *)items[k].value()) = count;
    keys[k] = count;
    _items[k].key = count;
#endif
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
      // ktable->insert_noprefetch((void *)&keys[k]);
    }
    // k = (k + 1) & (HT_TESTS_BATCH_LENGTH - 1);
#if defined(SAME_KMER)
    count++;
#endif
  }
  printf("%s, inserted %lu items\n", __func__, inserted);
  // flush the last batch explicitly
  // printf("%s calling flush queue\n", __func__);
  ktable->flush_insert_queue();
  // printf("%s: %p\n", __func__, ktable->find(&kmers[k]));
  return i;
}

uint64_t SynthTest::synth_run_get(BaseHashTable *ktable, uint8_t start) {
  uint64_t count = HT_TESTS_NUM_INSERTS * start;
  auto k = 0;
  uint64_t found = 0, not_found = 0;
  if (start == 0) count = 1;

  __attribute__((aligned(64))) Keys items[HT_TESTS_FIND_BATCH_LENGTH] = {0};

  Values *values;
  values = new Values[HT_TESTS_FIND_BATCH_LENGTH];
  ValuePairs vp = std::make_pair(0, values);

  for (auto i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {
    // printf("[%s:%d] inserting i= %d, data %lu\n", __func__, start, i, count);
#if defined(SAME_KMER)
    items[k].key = items[k].id = 32;
    k++;
#else
    items[k].key = count;
    items[k].id = count;
    k++;
    count++;
#endif
    if (k == HT_TESTS_FIND_BATCH_LENGTH) {
      KeyPairs kp = std::make_pair(HT_TESTS_FIND_BATCH_LENGTH, &items[0]);
      // printf("%s, calling find_batch i = %d\n", __func__, i);
      // ktable->find_batch((Keys *)items, HT_TESTS_FIND_BATCH_LENGTH);
      ktable->find_batch(kp, vp);
      found += vp.first;
      vp.first = 0;
      k = 0;
      not_found += HT_TESTS_FIND_BATCH_LENGTH - found;
      // printf("\t count %lu | found -> %lu | not_found -> %lu \n", count,
      // found, not_found);
    }
    // printf("\t count %lu | found -> %lu\n", count, found);
  }
  if (vp.first > 0) {
    vp.first = 0;
  }
  ktable->flush_find_queue(vp);
  found += vp.first;
  return found;
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
    num_inserts = synth_run(kmer_ht, sh->shard_idx);

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

  sleep(1);

  t_start = RDTSC_START();
  auto num_finds = synth_run_get(kmer_ht, sh->shard_idx);
  t_end = RDTSCP();

  sh->stats->find_cycles = (t_end - t_start);
  sh->stats->num_finds = num_finds;

  if (num_finds > 0)
    printf("[INFO] thread %u | num_finds %lu | cycles per get: %lu\n",
           sh->shard_idx, num_finds, (t_end - t_start) / num_finds);

#ifndef WITH_PAPI_LIB
  get_ht_stats(sh, kmer_ht);
  // kmer_ht->display();
#endif
}

}  // namespace kmercounter
