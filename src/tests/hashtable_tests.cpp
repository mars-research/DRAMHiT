#include "misc_lib.h"
#include "print_stats.h"
#include "sync.h"
#include "tests.hpp"
#include "zipf.h"

namespace kmercounter {
struct kmer {
  char data[KMER_DATA_LENGTH];
};

extern void get_ht_stats(Shard *, BaseHashTable *);

uint64_t HT_TESTS_HT_SIZE = (1 << 26ULL);  // * 8ull;
uint64_t HT_TESTS_NUM_INSERTS;

#define HT_TESTS_MAX_STRIDE 2

OpTimings SynthTest::synth_run(BaseHashTable *ktable, uint8_t start) {
  uint64_t count = HT_TESTS_NUM_INSERTS * start;
  auto k = 0;
  auto i = 0;
  struct xorwow_state _xw_state;
  auto inserted = 0lu;
  std::uint64_t duration{};

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
    //*((uint64_t *)items[k].key()) = count;
    //*((uint64_t *)items[k].value()) = count;
    keys[k] = count;
    _items[k].key = count;
#endif

#ifdef NO_PREFETCH
#warning "Compiling no prefetch"
    const auto t_start = RDTSC_START();
    ktable->insert_noprefetch((void *)&keys[k]);
    const auto t_end = RDTSCP();
    duration += t_end - t_start;
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

      const auto t_start = RDTSC_START();
      ktable->insert_batch(kp);
      const auto t_end = RDTSCP();
      duration += t_end - t_start;

      k = 0;
      inserted += kp.first;
      // ktable->insert_noprefetch((void *)&keys[k]);
    }
#endif  // NO_PREFETCH
        // k = (k + 1) & (HT_TESTS_BATCH_LENGTH - 1);
#if defined(SAME_KMER)
    count++;
#endif
  }
  printf("%s, inserted %lu items\n", __func__, inserted);
  // flush the last batch explicitly
  // printf("%s calling flush queue\n", __func__);
#if !defined(NO_PREFETCH)
  const auto t_start = RDTSC_START();
  ktable->flush_insert_queue();
  const auto t_end = RDTSCP();
  duration += t_end - t_start;
#endif
  // printf("%s: %p\n", __func__, ktable->find(&kmers[k]));
  return {duration, HT_TESTS_NUM_INSERTS};
}

OpTimings SynthTest::synth_run_get(BaseHashTable *ktable, uint8_t start) {
  uint64_t count = HT_TESTS_NUM_INSERTS * start;
  auto k = 0;
  uint64_t found = 0, not_found = 0;
  if (start == 0) count = 1;

  __attribute__((aligned(64))) uint64_t keys[HT_TESTS_FIND_BATCH_LENGTH] = {0};
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
    keys[k] = count;
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
      // ktable->find_batch((Keys *)items, HT_TESTS_FIND_BATCH_LENGTH);

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

  printf("[INFO] Synth test run: thread %u, ht size: %lu, insertions: %lu\n",
         sh->shard_idx, HT_TESTS_HT_SIZE, HT_TESTS_NUM_INSERTS);

  for (auto i = 1; i < HT_TESTS_MAX_STRIDE; i++) {
    insert_times = synth_run(kmer_ht, sh->shard_idx);
    printf(
        "[INFO] Quick stats: thread %u, Batch size: %d, cycles per "
        "insertion:%lu \n",
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
    printf("[INFO] thread %u | num_finds %lu | cycles per get: %lu\n",
           sh->shard_idx, find_times.op_count,
           find_times.duration / find_times.op_count);

#ifndef WITH_PAPI_LIB
  get_ht_stats(sh, kmer_ht);
  // kmer_ht->display();
#endif
}

OpTimings do_zipfian_inserts(BaseHashTable *hashtable, double skew) {
  constexpr auto keyrange_width = 100'000'000;
  zipf_distribution distribution {skew, keyrange_width};
  std::uint64_t duration{};

#ifdef NO_PREFETCH
#warning "Zipfian no-prefetch"
  for (unsigned int n{}; n < HT_TESTS_NUM_INSERTS; ++n) {
    alignas(64) std::uint64_t zipf_value {distribution()};
    const auto start = RDTSC_START();
    hashtable->insert_noprefetch(&zipf_value);
    const auto end = RDTSCP();
    duration += end - start;
  }
#else
  unsigned int key{};
  alignas(64) Keys items[HT_TESTS_BATCH_LENGTH]{};
  for (unsigned int n{}; n < HT_TESTS_NUM_INSERTS; ++n) {
    const auto zipf_value = distribution();
    items[key] = {zipf_value, n};

    ++key;
    key = (key == HT_TESTS_BATCH_LENGTH) ? 0 : key;

    if (!key) {
      KeyPairs keypairs{HT_TESTS_BATCH_LENGTH, items};
      const auto start = RDTSC_START();
      hashtable->insert_batch(keypairs);
      const auto end = RDTSCP();
      duration += end - start;
    }
  }

  const auto start = RDTSC_START();
  hashtable->flush_insert_queue();
  const auto end = RDTSCP();
  duration += end - start;
#endif

  return {duration, HT_TESTS_NUM_INSERTS};
}

OpTimings do_zipfian_gets(BaseHashTable *kmer_ht, unsigned int id) {
  printf("[WARNING] Zipfian gets not implemented yet\n");
  return {0, 1};
}

void ZipfianTest::run(Shard *shard, BaseHashTable *hashtable, double skew) {
  OpTimings insert_timings{};

  printf("[INFO] Zipfian test run: thread %u, ht size: %lu, insertions: %lu, skew %f\n",
         shard->shard_idx, HT_TESTS_HT_SIZE, HT_TESTS_NUM_INSERTS, skew);

  for (auto i = 1; i < HT_TESTS_MAX_STRIDE; i++) {
    insert_timings = do_zipfian_inserts(hashtable, skew);
    printf(
        "[INFO] Quick stats: thread %u, Batch size: %d, cycles per "
        "insertion:%lu \n",
        shard->shard_idx, i, insert_timings.duration / insert_timings.op_count);

#ifdef CALC_STATS
    printf(" Reprobes %lu soft_reprobes %lu\n", kmer_ht->num_reprobes,
           kmer_ht->num_soft_reprobes);
#endif
  }

  shard->stats->insertion_cycles = insert_timings.duration;
  shard->stats->num_inserts = insert_timings.op_count;

  sleep(1);

  const auto num_finds = do_zipfian_gets(hashtable, shard->shard_idx);

  shard->stats->find_cycles = num_finds.duration;
  shard->stats->num_finds = num_finds.op_count;

  if (num_finds.op_count > 0)
    printf("[INFO] thread %u | num_finds %lu | cycles per get: %lu\n",
           shard->shard_idx, num_finds.op_count,
           num_finds.duration / num_finds.op_count);

#ifndef WITH_PAPI_LIB
  get_ht_stats(shard, hashtable);
#endif
}

}  // namespace kmercounter
