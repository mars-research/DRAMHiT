#include "misc_lib.h"
#include "print_stats.h"
#include "sync.h"
#include "tests.hpp"

//#include "distributions/mica/zipf.h"
//#include "distributions/zipf.h"
#include "distributions/mine/fast_skew.h"

// For extern theta_arg
#include "Application.hpp"

// definitions of Zipf distribuition generators to select from
//#define NONE 0
#define MICA 1
#define STCKOVRFLW 2
#define TOOBIASED 3

// Select one of defines to enable
//#define SAME_KMER
//#define ZIPF
//#define MINE
#define PREGEN
//#define HEADER MICA//STCKOVRFLW//TOOBIASED//

#ifdef PREGEN
#include "pregen/mem.h"
#else
#ifndef HEADER
#include "distributions/zipf.h"
#elif HEADER == MICA
#include "distributions/mica/zipf.h"
#elif HEADER == STCKOVRFLW
#include "distributions/stackoverflow/zipf.h"
#elif HEADER == TOOBIASED
#include "distributions/toobiased/zipf.h"
#endif
#endif

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

extern double theta_arg;
uint64_t *mem;
uint64_t SynthTest::synth_run(KmerHashTable *ktable) {
  auto count = 0;
  auto k = 0;
  struct xorwow_state _xw_state;

  xorwow_init(&_xw_state);

  __attribute__((aligned(64))) struct kmer kmers[HT_TESTS_BATCH_LENGTH] = {0};
  for (auto i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {
    // Depending on selected macro, give different data
#if defined(SAME_KMER)
    //*((uint64_t *)&kmers[k].data) = count & (32 - 1);
    *((uint64_t *)&kmers[k].data) = 32;
#elif defined(XORWOW)
#warning "Xorwow rand kmer insert"
    *((uint64_t *)&kmers[k].data) = xorwow(&_xw_state);
#elif defined(ZIPF)  //
    *((uint64_t *)&kmers[k].data) = zg->next();
    // printf("%ld\n", zg->next());
#elif defined(MINE)
    //*((uint64_t *)&kmers[k].data) = mine::next1(rand_);
    *((uint64_t *)&kmers[k].data) =
        mine::next(0.33, -1.47, -0.272179, HT_TESTS_NUM_INSERTS, rand_);
    // printf("%ld\n", mine::next(0.36, -1.47, -0.296, rand_));
    // printf("%lu\n", mine::next2(rand_));
#elif defined(PREGEN)
    *((uint64_t *)&kmers[k].data) = mem[i];
    // printf("%lu\n", mem[i]);
#elif defined(HEADER)
    *((uint64_t *)&kmers[k].data) =
        next();  // ZipfGen(HT_TESTS_NUM_INSERTS, theta_arg,
                 // HT_TESTS_NUM_INSERTS);//next();//1;//
    // printf("%lu\n", next());
#else
    *((uint64_t *)&kmers[k].data) = count;  //++;
#endif
    ktable->insert((void *)&kmers[k]);
    k = (k + 1) & (HT_TESTS_BATCH_LENGTH - 1);
    //#if defined(SAME_KMER) || defined(ZIPF) || defined(MINE)
    ++count;  // count++;
    //#endif
  }

  // printf("FILE: \"%s\":%d\n",__FILE__, __LINE__);
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
// Depending on selected macro, initialize different datas
#ifdef PREGEN
    // printf("here\n");
    // uint64_t t_start = RDTSC_START();
    mem = generate(HT_TESTS_NUM_INSERTS, HT_TESTS_NUM_INSERTS, theta_arg,
                   HT_TESTS_NUM_INSERTS);
    printf("Data generated.\n");
    // mem = generate(HT_TESTS_NUM_INSERTS, HT_TESTS_NUM_INSERTS, theta_arg,
    // HT_TESTS_NUM_INSERTS); uint64_t t_end = RDTSCP(); printf("Cycles to
    // generate: %lu (%f ms)\t Cycles per gen: %f\n", t_end-t_start,
    // (double)(t_end-t_start)* one_cycle_ns / 1000000.0,
    // (t_end-t_start)/(HT_TESTS_NUM_INSERTS*1.0));
#elif defined(ZIPF)
    printf("theta_arg = %f\n", theta_arg);
    Base_ZipfGen *zg =
        ZipfGen(HT_TESTS_NUM_INSERTS, theta_arg, HT_TESTS_NUM_INSERTS);
#elif defined(MINE)
    Rand *rand_ = new Rand();
#elif defined(HEADER)
    ZipfGen(HT_TESTS_NUM_INSERTS, theta_arg, HT_TESTS_NUM_INSERTS);
#endif
    t_start = RDTSC_START();

    // PREFETCH_QUEUE_SIZE = i;

    // PREFETCH_QUEUE_SIZE = 32;
    num_inserts = synth_run(kmer_ht);

    t_end = RDTSCP();

// Depending on selected macro, free any allocated memory
#ifdef PREGEN
    clear(mem);
#elif defined(ZIPF)
    delete zg;
#elif defined(MINE)
    delete rand_;
#endif

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
#endif
}

}  // namespace kmercounter
