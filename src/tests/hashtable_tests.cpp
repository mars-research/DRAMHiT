#include "misc_lib.h"
#include "print_stats.h"
#include "sync.h"
#include "tests.hpp"

#include "hashtables/kvtypes.hpp"

#include "distribution/mica/zipf.h"

namespace kmercounter {
struct kmer {
  char data[KMER_DATA_LENGTH];
};

extern void get_ht_stats(Shard *, BaseHashTable *);


extern Configuration config;
uint64_t HT_TESTS_HT_SIZE = config.ht_size;
uint64_t HT_TESTS_NUM_INSERTS = config.distr_length;

#define HT_TESTS_MAX_STRIDE 2


extern uint64_t* key_distr;

void SynthTest::insert_test(Shard *sh, BaseHashTable *kmer_ht) {
  uint64_t num_inserts = 0;
  uint64_t t_start, t_end;


  uint8_t tid = sh->shard_idx;
  uint64_t start = ((double)tid/config.num_threads)*config.distr_length;
  uint64_t end = ((double)(tid+1)/config.num_threads)*config.distr_length;
  printf("[INFO] Insert Test: thread %u, ht size: %lu, insertions: %lu\n", tid, config.ht_size, end - start);

  for (auto i = 1; i < HT_TESTS_MAX_STRIDE; i++) 
  {
    //Insert a key into the hashtable, with keys following a zipfian distribution
    t_start = RDTSC_START();
    {
      __attribute__((aligned(64))) Keys _items[HT_TESTS_FIND_BATCH_LENGTH] = {0};

      auto k = 0;
      for (uint64_t i = start; i < end; i++) 
      {
        _items[k].key = key_distr[i];
        if (++k == HT_TESTS_BATCH_LENGTH)
        {
          k = 0;
          KeyPairs kp = std::make_pair(HT_TESTS_BATCH_LENGTH, &_items[0]);

          kmer_ht->insert_batch(kp);
          num_inserts += HT_TESTS_BATCH_LENGTH;
        }
      }
    }
    t_end = RDTSCP();
    printf("[INFO] Inserted %lu elements in %lu cycles (%f ms) at rate of %lu cycles/element\n", num_inserts, t_end-t_start, (double)(t_end-t_start) * one_cycle_ns / 1000000.0, (t_end-t_start)/num_inserts);
    printf("[INFO] Quick stats: thread %u, Batch size: %d, cycles per insertion:%lu \n", sh->shard_idx, i, (t_end - t_start) / num_inserts);

#ifdef CALC_STATS
    printf(" Reprobes %lu soft_reprobes %lu\n", kmer_ht->num_reprobes,
           kmer_ht->num_soft_reprobes);
#endif
  }
  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = num_inserts;

  sleep(1);

#ifndef WITH_PAPI_LIB
  get_ht_stats(sh, kmer_ht);
  // kmer_ht->display();
#endif
}

uint8_t ready = 0;
inline void until_ready(uint8_t tid)
{
  while(ready!=tid) fipc_test_pause();
}

void SynthTest::find_test(Shard *sh, BaseHashTable *kmer_ht) {
  //uint64_t num_inserts = 0;
  uint64_t num_finds = 0, not_found = 0;
  uint64_t t_start, t_end;


  uint8_t tid = sh->shard_idx;
  uint64_t start = ((double)tid/config.num_threads)*config.distr_length;
  uint64_t end = ((double)(tid+1)/config.num_threads)*config.distr_length;
  printf("[INFO] Find Test: thread %u, ht size: %lu, insertions: %lu\n", tid, config.ht_size, end - start);

  for (auto i = 1; i < HT_TESTS_MAX_STRIDE; i++) 
  {
    //Inserting a uniform distribution into the hashtable
    {
      __attribute__((aligned(64))) Keys _items[HT_TESTS_FIND_BATCH_LENGTH] = {0};

      auto k = 0;
      for (uint64_t i = start; i < end; i++)  
      {
        _items[k].key = i;
        if (++k == HT_TESTS_BATCH_LENGTH) 
        {
          k = 0;
          KeyPairs kp = std::make_pair(HT_TESTS_BATCH_LENGTH, &_items[0]);
          kmer_ht->insert_batch(kp);
          //num_inserts += HT_TESTS_BATCH_LENGTH;
        }
      }
    }

    //Find/Get a key from the hashtable, with keys following a zipfian distribution
    t_start = RDTSC_START();
    {
        auto k = 0;

        __attribute__((aligned(64))) Keys items[HT_TESTS_FIND_BATCH_LENGTH] = {0};

        Values *values;
        values = new Values[HT_TESTS_FIND_BATCH_LENGTH];
        ValuePairs vp = std::make_pair(0, values);

        for (uint64_t i = start; i < end; i++) 
        {
          items[k].key = key_distr[i];
          items[k].id = i;
          if (++k == HT_TESTS_FIND_BATCH_LENGTH) 
          {
            KeyPairs kp = std::make_pair(HT_TESTS_FIND_BATCH_LENGTH, &items[0]);
            kmer_ht->find_batch(kp, vp);
            num_finds += vp.first;
            vp.first = 0;
            k = 0;
            not_found += HT_TESTS_FIND_BATCH_LENGTH - num_finds;
          }
        }
    }
    t_end = RDTSCP();

    if (num_finds > 0) printf("[INFO] thread %u | num_finds %lu | cycles per get: %lu\n", tid, num_finds, (t_end - t_start) / num_finds);
    else printf("[INFO] Didnt find anything\n");    

    
#ifdef CALC_STATS
    printf(" Reprobes %lu soft_reprobes %lu\n", kmer_ht->num_reprobes,
           kmer_ht->num_soft_reprobes);
#endif
  }

  sh->stats->find_cycles = (t_end - t_start);
  sh->stats->num_finds = num_finds;

  sleep(1);

#ifndef WITH_PAPI_LIB
  get_ht_stats(sh, kmer_ht);
  // kmer_ht->display();
#endif
}

}  // namespace kmercounter
