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

//needs to be diff values (27 or 28) for different sizes of generated data and cores
//128GB of data with 32 or 64 cores when this is 26 instead, works but slows down
//due to too many insertions for the hashtable size
uint64_t HT_TESTS_HT_SIZE = 128;//(1 << 26);
//uint64_t HT_TESTS_HT_SIZE = (1 << 26ULL);  // * 8ull;
uint64_t HT_TESTS_NUM_INSERTS;

#define HT_TESTS_MAX_STRIDE 2


extern Configuration config;
//volatile 
extern uint64_t* mem;

volatile uint8_t use_ready = 0;
volatile uint8_t ready = 0;
void until_use_ready(uint8_t tid)
{
    while(tid!=0 && !use_ready){}
}
void until_ready(uint8_t tid)
{
    while(ready!=tid){}
}

//#define HT_SIZE (config.ht_size/config.num_threads)
//#define INS_SIZE ((config.ht_size*config.ht_fill)/(100*config.num_threads))

#define MAX_THREADS 64
uint64_t start[MAX_THREADS];
uint64_t end[MAX_THREADS];

uint64_t SynthTest::synth_run(BaseHashTable *ktable, uint8_t tid) {
  uint64_t count = 0;//HT_TESTS_NUM_INSERTS * tid;
  auto k = 0;
  auto i = 0UL;
  struct xorwow_state _xw_state;
  auto inserted = 0lu;

  xorwow_init(&_xw_state);
  if (tid == 0) count = 1;
  __attribute__((aligned(64))) struct kmer kmers[HT_TESTS_BATCH_LENGTH] = {0};
  __attribute__((aligned(64))) struct Item items[HT_TESTS_BATCH_LENGTH] = {0};
  __attribute__((aligned(64))) uint64_t keys[HT_TESTS_BATCH_LENGTH] = {0};
  __attribute__((aligned(64))) Keys _items[HT_TESTS_FIND_BATCH_LENGTH] = {0};
  uint64_t s = start[tid], e = end[tid];
  for (i = s; i < e; i++) {//(i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {//
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
    _items[k].key = mem[i];//count;//
    //printf("k=%u \t %lu\n", k, _items[k].key);
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
  //printf("%s, inserted %lu items\n", __func__, inserted);

  // flush the last batch explicitly
  // printf("%s calling flush queue\n", __func__);
  // ktable->flush_queue();
  // printf("%s: %p\n", __func__, ktable->find(&kmers[k]));
  return inserted;
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
  //uint64_t s = start[tid], e = end[tid];
  for (auto i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {//for (int i = s; i < e; i++) {//
    // printf("[%s:%d] inserting i= %d, data %lu\n", __func__, start, i, count);
#if defined(SAME_KMER)
    items[k].key = items[k].id = 32;
    k++;
#else
    items[k].key = count;//mem[i];//
    items[k].id = count;//mem[i];//
    k++;
    count++;
#endif
    if (k == HT_TESTS_FIND_BATCH_LENGTH) {
      KeyPairs kp = std::make_pair(HT_TESTS_FIND_BATCH_LENGTH, &items[0]);
      // printf("%s, calling find_batch i = %d\n", __func__, i);
      // ktable->find_batch((Keys *)items, HT_TESTS_FIND_BATCH_LENGTH);
      ktable->find_batch_v2(kp, vp);
      found += vp.first;
      vp.first = 0;
      k = 0;
      not_found += HT_TESTS_FIND_BATCH_LENGTH - found;
      // printf("\t count %lu | found -> %lu | not_found -> %lu \n", count,
      // found, not_found);
    }
    // printf("\t count %lu | found -> %lu\n", count, found);
  }
  // found += ktable->flush_find_queue();
  return found;
}
void SynthTest::synth_run_exec(Shard *sh, BaseHashTable *kmer_ht) {
  uint64_t num_inserts = 0;
  uint64_t t_start, t_end;

  printf("[INFO] Synth test run: thread %u, ht size: %lu, insertions: %lu\n",
         sh->shard_idx, HT_TESTS_HT_SIZE, HT_TESTS_NUM_INSERTS);

  for (auto i = 1; i < HT_TESTS_MAX_STRIDE; i++) {

    //Compute start and end range of data range for each thread
    start[sh->shard_idx] = ((double)sh->shard_idx/config.num_threads)*config.distr_length;
    end[sh->shard_idx] = ((double)(sh->shard_idx+1)/config.num_threads)*config.distr_length;

    printf("Data size: %lu\n", end[sh->shard_idx]-start[sh->shard_idx]);

    t_start = RDTSC_START();
    // PREFETCH_QUEUE_SIZE = i;

    // PREFETCH_QUEUE_SIZE = 32;
    num_inserts = synth_run(kmer_ht, sh->shard_idx);
    t_end = RDTSCP();
    
    printf("[INFO] Inserted %lu elements in %lu cycles (%f ms) at rate of %lu cycles/element\n", num_inserts, t_end-t_start, (double)(t_end-t_start) * one_cycle_ns / 1000000.0, (t_end-t_start)/num_inserts);
    
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

  if (num_finds > 0)
    printf("[INFO] thread %u | num_finds %lu | cycles per get: %lu\n",
           sh->shard_idx, num_finds, (t_end - t_start) / num_finds);

#ifndef WITH_PAPI_LIB
  get_ht_stats(sh, kmer_ht);
  // kmer_ht->display();
#endif
}

void SynthTest::insert_test(Shard *sh, BaseHashTable *kmer_ht) {
  uint64_t num_inserts = 0;
  uint64_t t_start, t_end;


  uint8_t tid = sh->shard_idx;
  uint64_t start = ((double)tid/config.num_threads)*config.distr_length;
  uint64_t end = ((double)(tid+1)/config.num_threads)*config.distr_length;
  printf("[INFO] Insert Test: thread %u, ht size: %lu, insertions: %lu\n",
         tid, HT_TESTS_HT_SIZE, end - start);

  for (auto i = 1; i < HT_TESTS_MAX_STRIDE; i++) {
    t_start = RDTSC_START();
    {
      __attribute__((aligned(64))) Keys _items[HT_TESTS_FIND_BATCH_LENGTH] = {0};

      auto k = 0;
      for ( auto i = start; i < end; i++) 
      {//(i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {//
        _items[k].key = mem[i];
        //printf("k=%u \t %lu\n", k, _items[k].key);
        if (++k == HT_TESTS_BATCH_LENGTH)
        {
          k = 0;
          KeyPairs kp = std::make_pair(HT_TESTS_BATCH_LENGTH, &_items[0]);

          kmer_ht->insert_batch(kp);
          num_inserts += HT_TESTS_BATCH_LENGTH;//kp.first;
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

void SynthTest::find_test(Shard *sh, BaseHashTable *kmer_ht) {
  uint64_t num_inserts = 0;
  uint64_t num_finds = 0, not_found = 0;
  uint64_t t_start, t_end;


  uint8_t tid = sh->shard_idx;
  uint64_t start = ((double)tid/config.num_threads)*config.distr_length;
  uint64_t end = ((double)(tid+1)/config.num_threads)*config.distr_length;
  printf("[INFO] Find Test: thread %u, ht size: %lu, insertions: %lu\n", tid, HT_TESTS_HT_SIZE, end - start);

  for (auto i = 1; i < HT_TESTS_MAX_STRIDE; i++) 
  {

    t_start = RDTSC_START();
    {
      __attribute__((aligned(64))) Keys _items[HT_TESTS_FIND_BATCH_LENGTH] = {0};

      uint64_t count = 0;
      auto k = 0;
      for (auto i = start; i < end; i++)  
      {//(i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {//
        _items[k].key = i;
        //printf("Thread %k=%u \t %lu\n", k, _items[k].key);
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
    printf("[INFO] Quick stats: thread %u, Batch size: %d, cycles per insertion:%lu \n", tid,  i, (t_end - t_start) / num_inserts);


    t_start = RDTSC_START();
    {
        auto k = 0;

        __attribute__((aligned(64))) Keys items[HT_TESTS_FIND_BATCH_LENGTH] = {0};

        Values *values;
        values = new Values[HT_TESTS_FIND_BATCH_LENGTH];
        ValuePairs vp = std::make_pair(0, values);

        for (int i = start; i < end; i++) 
        {//for (auto i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {
          items[k].key = mem[i];
          items[k].id = i;
          if (++k == HT_TESTS_FIND_BATCH_LENGTH) 
          {
            KeyPairs kp = std::make_pair(HT_TESTS_FIND_BATCH_LENGTH, &items[0]);
            kmer_ht->find_batch_v2(kp, vp);
            num_finds += vp.first;
            vp.first = 0;
            k = 0;
            not_found += HT_TESTS_FIND_BATCH_LENGTH - num_finds;
          }
        }
    }
    t_end = RDTSCP();

    until_ready(tid);
    if (num_finds > 0) printf("[INFO] thread %u | num_finds %lu | cycles per get: %lu\n", tid, num_finds, (t_end - t_start) / num_finds);
    else printf("[INFO] Didnt find anything\n");
    ++ready;
    

    
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

}  // namespace kmercounter
