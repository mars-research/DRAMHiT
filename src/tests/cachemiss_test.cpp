#include "tests.hpp"

#define HT_TESTS_BATCH_LENGTH 128

namespace kmercounter {

extern uint64_t HT_TESTS_HT_SIZE;
extern uint64_t HT_TESTS_NUM_INSERTS;

void CacheMissTest::cache_miss_run(Shard *sh, BaseHashTable *k_ht) {
  uint64_t t_start, t_end;
  uint64_t val = 0;
  int k = 0;
  uint64_t count = HT_TESTS_NUM_INSERTS * sh->shard_idx;
  printf(
      "[INFO] Cache Miss test run: thread %u, ht size: %lu, insertions: %lu\n",
      sh->shard_idx, HT_TESTS_HT_SIZE, HT_TESTS_NUM_INSERTS);

  if (t_start == 0) count = 1;
  __attribute__((aligned(64))) uint64_t keys[HT_TESTS_BATCH_LENGTH] = {0};

  t_start = RDTSC_START();
  for (auto i = 0; i < HT_TESTS_NUM_INSERTS; i++) {
#if defined(SAME_KMER)
    keys[k] = 32;
#else
    keys[k] = count;
#endif
    count++;
    val += k_ht->read_hashtable_element((void *)&keys[k]);
    k = (k + 1) & (HT_TESTS_BATCH_LENGTH - 1);
  }
  t_end = RDTSCP();

  printf(
      "[INFO] CacheMissTest: Quick stats: thread %u, Batch size: %d, cycles "
      "per "
      "insertion:%lu \n",
      sh->shard_idx, (count - 1), ((t_end - t_start) / (count - 1)));
}
}  // namespace kmercounter