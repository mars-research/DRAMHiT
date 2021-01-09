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

// #define HT_TESTS_BATCH_LENGTH 32
#define HT_TESTS_BATCH_LENGTH 128
#define HT_TESTS_FIND_BATCH_LENGTH PREFETCH_FIND_QUEUE_SIZE

//needs to be diff values (27 or 28) for different sizes of generated data and cores
//128GB of data with 32 or 64 cores when this is 26 instead, works but slows down
//due to too many insertions for the hashtable size
uint64_t HT_TESTS_HT_SIZE = (1 << 28);
//uint64_t HT_TESTS_HT_SIZE = (1 << 26ULL);  // * 8ull;
uint64_t HT_TESTS_NUM_INSERTS;

#define HT_TESTS_MAX_STRIDE 2


extern Configuration config;
//volatile 
extern uint64_t* mem;

volatile uint8_t use_ready = 0;
volatile uint8_t clr_ready = 0;
void until_use_ready(uint8_t tid)
{
    while(tid!=0 && !use_ready){}
}
void until_ready(uint8_t tid)
{
    while(clr_ready!=tid){}
}

//#define HT_SIZE (config.ht_size/config.num_threads)
//#define INS_SIZE ((config.ht_size*config.ht_fill)/(100*config.num_threads))

#define MAX_THREADS 64
uint64_t start[MAX_THREADS];
uint64_t end[MAX_THREADS];
uint64_t data_size[MAX_THREADS];

uint64_t SynthTest::synth_run(BaseHashTable *ktable, uint8_t tid) {
  uint64_t count = 0;//HT_TESTS_NUM_INSERTS * tid;
  auto k = 0;
  auto i = 0UL;
  struct xorwow_state _xw_state;

  xorwow_init(&_xw_state);
  if (start == 0) count = 1;
  __attribute__((aligned(64))) struct kmer kmers[HT_TESTS_BATCH_LENGTH] = {0};
  __attribute__((aligned(64))) struct Item items[HT_TESTS_BATCH_LENGTH] = {0};
  __attribute__((aligned(64))) uint64_t keys[HT_TESTS_BATCH_LENGTH] = {0};

    uint64_t s = start[tid], e = end[tid];
    for (i = s; i < e; i++) {
        *((uint64_t *)&kmers[k].data) = count;//mem[i];
        *((uint64_t *)items[k].key()) = count;
        *((uint64_t *)items[k].value()) = count;
        keys[k] = mem[i];//1;//count;//
        //printf("%lu\n", mem[i]);
        
        ktable->insert((void *)&keys[k]);

        // ktable->insert_noprefetch((void *)&keys[k]);
        k = (k + 1) & (HT_TESTS_BATCH_LENGTH - 1);
        ++count;

        /*
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
            *((uint64_t *)&kmers[k].data) = count;
            *((uint64_t *)items[k].key()) = count;
            *((uint64_t *)items[k].value()) = count;
            keys[k] = count;
        #endif
            // printf("[%s:%d] inserting i= %d, data %lu\n", __func__, start, i, count);
            // printf("%s, inserting i= %d\n", __func__, i);
            // ktable->insert((void *)&kmers[k]);
            // printf("->Inserting %lu\n", count);
            count++;
            // ktable->insert((void *)&items[k]);
            ktable->insert((void *)&items[k]);

            // ktable->insert_noprefetch((void *)&keys[k]);
            k = (k + 1) & (HT_TESTS_BATCH_LENGTH - 1);
        #if defined(SAME_KMER)
            count++;
        #endif
        */
    }
  // flush the last batch explicitly
  //printf("%s calling flush queue\n", __func__);
  ktable->flush_queue();
  //printf("%s: %p\n", __func__, ktable->find(&kmers[k]));
  return count;//i;
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
      ktable->find_batch_v2(kp, vp);
      found += vp.first;
      vp.first = 0;
      k = 0;
      not_found += HT_TESTS_FIND_BATCH_LENGTH - found;
      // printf("\t count %lu | found -> %lu | not_found -> %lu \n", count,
      // found, not_found);
    }
  }
  // found += ktable->flush_find_queue();
  return found;
}

uint64_t seed2 = 123456789;
inline uint64_t PREFETCH_STRIDE = 64;
void SynthTest::synth_run_exec(Shard *sh, BaseHashTable *kmer_ht) {
  uint64_t num_inserts = 0;
  uint64_t t_start, t_end;
  int fd;

  printf("[INFO] Synth test run: thread %u, ht size: %lu, insertions: %lu\n",
         sh->shard_idx, HT_TESTS_HT_SIZE, HT_TESTS_NUM_INSERTS);

  for (auto i = 1; i < HT_TESTS_MAX_STRIDE; i++) {
    size_t distr_length = config.distr_length;
    /*
    //freeze threads that arent thread 0 until use_ready is incremented
    if(sh->shard_idx == 0)
    {
        mem = calloc_ht<uint64_t>(distr_length, -1, &fd);
    }

    //Syncronize threads to make sure to use mem after it is allocated
    until_ready(sh->shard_idx);
    ++clr_ready;
    until_ready(config.num_threads);
    */

    //Compute start and end range of data range for each thread
    start[sh->shard_idx] = ((double)sh->shard_idx/config.num_threads)*distr_length;
    end[sh->shard_idx] = ((double)(sh->shard_idx+1)/config.num_threads)*distr_length;
    data_size[sh->shard_idx] = end[sh->shard_idx] - start[sh->shard_idx];

    /*
    //Precompute sum and data for pregeneration
    t_start = RDTSC_START();
    ZipfGen(config.distr_range, config.zipf_theta, 12451, sh->shard_idx, config.num_threads);
    t_end = RDTSCP();
    printf("[INFO] Sum %lu range in %lu cycles (%f ms) at rate of %lu cycles/element\n", config.distr_range, t_end-t_start, (double)(t_end-t_start) * one_cycle_ns / 1000000.0, (t_end-t_start)/data_size[sh->shard_idx]);
    
    //pregenerate the indices/keys
    t_start = RDTSC_START();
    for (uint64_t j = start[sh->shard_idx]; j < end[sh->shard_idx]; ++j) 
    {
        //next returns a number from [0 - config.range]
        //insert has issues if key inserted is 0 so add 1
        mem[j] = next()+1; //TODO: modify to return key instead i.e. "keys[next()]"
    }
    t_end = RDTSCP();
    printf("[INFO] Generate %lu elements in %lu cycles (%f ms) at rate of %lu cycles/element\n", data_size[sh->shard_idx], t_end-t_start, (double)(t_end-t_start) * one_cycle_ns / 1000000.0, (t_end-t_start)/data_size[sh->shard_idx]);
    */

    t_start = RDTSC_START();
    // PREFETCH_QUEUE_SIZE = i;

    // PREFETCH_QUEUE_SIZE = 32;
    num_inserts = synth_run(kmer_ht, sh->shard_idx);
    t_end = RDTSCP();
    printf("[INFO] Inserted %lu elements in %lu cycles (%f ms) at rate of %lu cycles/element\n", num_inserts, t_end-t_start, (double)(t_end-t_start) * one_cycle_ns / 1000000.0, (t_end-t_start)/num_inserts);
    
    /*
    if(sh->shard_idx == 0)
    {
      clr_ready = 0;
    }

    //Syncronize threads to make sure to free mem after it is used
    until_ready(sh->shard_idx);
    ++clr_ready;
    until_ready(config.num_threads);
    
    //free memory allocated by thread 0
    if(sh->shard_idx == 0)
    {
      free_mem((void*) mem, distr_length, -1, fd);
    }
    */

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

  /*t_start = RDTSC_START();
  auto num_finds = synth_run_get(kmer_ht, sh->shard_idx);
  t_end = RDTSCP();*

  if (num_finds > 0)
  printf("[INFO] thread %u | num_finds %lu | cycles per get: %lu\n",
         sh->shard_idx, num_finds, (t_end - t_start) / num_finds);*/

#ifndef WITH_PAPI_LIB
  get_ht_stats(sh, kmer_ht);
  // kmer_ht->display();
#endif
}

}  // namespace kmercounter
