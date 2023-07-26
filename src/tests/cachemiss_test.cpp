#include "tests/tests.hpp"

namespace kmercounter {

extern uint64_t HT_TESTS_HT_SIZE;
extern uint64_t HT_TESTS_NUM_INSERTS;

void CacheMissTest::cache_miss_run(Shard *sh, BaseHashTable *k_ht) {
  uint64_t val = 0;
  int k = 0;
  uint64_t i = 0u;
  uint64_t count = HT_TESTS_NUM_INSERTS * sh->shard_idx;
  printf("[INFO] Cache Miss test run: thread %u, ht size: %" PRIu64
         ", insertions: %" PRIu64 "\n",
         sh->shard_idx, HT_TESTS_HT_SIZE, HT_TESTS_NUM_INSERTS);

  if (sh->shard_idx == 0) count = 1;
  __attribute__((aligned(64))) uint64_t keys[HT_TESTS_BATCH_LENGTH] = {0};

  auto t_start = RDTSC_START();
  for (i = 0; i < HT_TESTS_NUM_INSERTS; i++) {
#if defined(SAME_KMER)
    keys[k] = 32;
#else
    keys[k] = count;
#endif
    count++;
    val += k_ht->read_hashtable_element((void *)&keys[k]);
    k = (k + 1) & (HT_TESTS_BATCH_LENGTH - 1);
  }
  auto t_end = RDTSCP();

  printf("[INFO] CacheMissTest: Quick stats: thread %u, Batch size: %" PRIu64
         ", cycles "
         "per insertion: %" PRIu64 "\n",
         sh->shard_idx, i, ((t_end - t_start) / i));
}
}  // namespace kmercounter
