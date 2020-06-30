#include "misc_lib.h"

#define BQ_MAGIC_64BIT 0xD221A6BE96E04673UL
#define BQ_TESTS_BATCH_LENGTH (1ULL << 5)         // 32
#define BQ_TESTS_DEQUEUE_ARR_LENGTH (1ULL << 10)  // 512
#define BQ_TESTS_NUM_INSERTS (1ULL << 26)
#define BQ_TESTS_HT_SIZE (BQ_TESTS_NUM_INSERTS * 16)

namespace kmercounter {

extern KmerHashTable *init_ht(uint64_t, uint8_t);
extern void get_ht_stats(__shard *, KmerHashTable *);

static int *bqueue_halt;
struct bq_kmer {
  char data[KMER_DATA_LENGTH];
};

struct bq_kmer bq_kmers[BQ_TESTS_DEQUEUE_ARR_LENGTH];
int bq_kmers_idx = 0;

void *producer_thread(void *arg)
{
  __shard *sh = (__shard *)arg;
  sh->stats = (thread_stats *)memalign(CACHE_LINE_SIZE, sizeof(thread_stats));
  uint64_t k = 0;
  uint8_t this_prod_id = sh->shard_idx;
  uint8_t cons_id = 0;
  uint64_t transaction_id;
  queue_t **q = prod_queues[this_prod_id];

#ifdef BQ_TESTS_INSERT_XORWOW
  struct xorwow_state xw_state;
  xorwow_init(&xw_state);
#endif

  fipc_test_FAI(ready_producers);
  while (!test_ready) fipc_test_pause();
  fipc_test_mfence();

  printf("[INFO] Producer %u starting. Total inserts :%llu \n", this_prod_id,
         BQ_TESTS_NUM_INSERTS * consumer_count);

  /* BQ_TESTS_NUM_INSERTS enqueues per consumer */
  cons_id = 0;
  for (transaction_id = 0u; transaction_id < BQ_TESTS_NUM_INSERTS;) {
    /* BQ_TESTS_BATCH_LENGTH enqueues in one batch, then move on to next
     * consumer */
    for (auto i = 0u; i < BQ_TESTS_BATCH_LENGTH; i++) {
#ifdef BQ_TESTS_INSERT_XORWOW
      k = xorwow(&xw_state);
      k = k << 32 | xorwow(&xw_state);
#else
      k = transaction_id;
#endif
      // *((uint64_t *)&kmers[i].data) = k;

      if (enqueue(q[cons_id], (data_t)k) != SUCCESS) {
        /* if enqueue fails, move to next consumer queue */
        // printf("[ERROR] Producer %u -> Consumer %u \n", this_prod_id,
        // cons_id);
        break;
      }
      transaction_id++;
      if (transaction_id % (BQ_TESTS_NUM_INSERTS * consumer_count / 10) == 0) {
        printf("[INFO] Producer %u, transaction_id %lu\n", this_prod_id,
               transaction_id);
      }
    }

    ++cons_id;
    if (cons_id >= consumer_count) cons_id = 0;
  }

  /* enqueue halt messages */
  for (cons_id = 0; cons_id < consumer_count; cons_id++) {
    while (enqueue(q[cons_id], (data_t)BQ_MAGIC_64BIT) != SUCCESS)
      ;
    transaction_id++;
  }

  fipc_test_FAI(completed_producers);
  return NULL;
}

void *consumer_thread(void *arg)
{
  __shard *sh = (__shard *)arg;
  sh->stats = (thread_stats *)memalign(CACHE_LINE_SIZE, sizeof(thread_stats));
  uint64_t t_start, t_end;
  KmerHashTable *kmer_ht = NULL;
  uint8_t finished_producers;
  uint64_t k = 0;
  uint64_t transaction_id = 0;
  uint8_t prod_id = 0;
  uint8_t this_cons_id = sh->shard_idx - producer_count;
  queue_t **q = cons_queues[this_cons_id];
  // bq_kmer[BQ_TESTS_BATCH_LENGTH*consumer_count];

  kmer_ht = init_ht(BQ_TESTS_HT_SIZE, sh->shard_idx);
  fipc_test_FAI(ready_consumers);
  while (!test_ready) fipc_test_pause();
  fipc_test_mfence();

  printf("[INFO] Consumer %u starting\n", this_cons_id);

  t_start = RDTSC_START();

  prod_id = 0;
  while (finished_producers < producer_count) {
    for (auto i = 0u; i < BQ_TESTS_BATCH_LENGTH; i++) {
      /* Receive and unmarshall */
      if (dequeue(q[prod_id], (data_t *)&k) != SUCCESS) {
        /* move on to next producer queue to dequeue */
        // printf("[ERROR] Consumer %u <- Producer %u \n", sh->shard_idx,
        // prod_id);
        break;
      }

      /* Save kmer into array, and insert into HT */
      memcpy(&bq_kmers[bq_kmers_idx].data, &k, sizeof(k));
      kmer_ht->insert((void *)&bq_kmers[bq_kmers_idx]);
      bq_kmers_idx++;
      if (bq_kmers_idx == BQ_TESTS_DEQUEUE_ARR_LENGTH) bq_kmers_idx = 0;

      if ((data_t)k == BQ_MAGIC_64BIT) {
        fipc_test_FAI(finished_producers);
        printf(
            "[INFO] Consumer %u, received HALT from prod_id %u. "
            "finished_producers :%u\n",
            this_cons_id, prod_id, finished_producers);
      }

      transaction_id++;
      if (transaction_id % (BQ_TESTS_NUM_INSERTS * consumer_count / 10) == 0) {
        printf("[INFO] Consumer %u, transaction_id %lu\n", this_cons_id,
               transaction_id);
      }
    }
    ++prod_id;
    if (prod_id >= producer_count) {
      prod_id = 0;
    }
  }

  t_end = RDTSCP();
  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = transaction_id;
  get_ht_stats(sh, kmer_ht);

  printf(
      "[INFO] Quick Stats: Consumer %u finished, receiving %lu messages "
      "(cycles per message %lu)\n",
      this_cons_id, transaction_id, (t_end - t_start) / transaction_id);

  /* Write to file */
  if (!config.ht_file.empty()) {
    std::string outfile = config.ht_file + std::to_string(sh->shard_idx);
    printf("[INFO] Shard %u: Printing to file: %s\n", sh->shard_idx,
           outfile.c_str());
    kmer_ht->print_to_file(outfile);
  }

  // End test
  fipc_test_FAI(completed_consumers);
  return NULL;
}

void no_bqueues(__shard *sh, KmerHashTable *kmer_ht)
{
  uint64_t k = 0;
  // uint64_t num_inserts = 0;
  uint64_t t_start, t_end;
  uint64_t transaction_id;

#ifdef BQ_TESTS_INSERT_XORWOW
  struct xorwow_state xw_state;
  xorwow_init(&xw_state);
#endif

  printf(
      "[INFO] no_bqueues thread %u starting. Total inserts in this "
      "thread:%llu \n",
      sh->shard_idx, BQ_TESTS_NUM_INSERTS);

  t_start = RDTSC_START();

  for (transaction_id = 0u; transaction_id < BQ_TESTS_NUM_INSERTS;
       transaction_id++) {
#ifdef BQ_TESTS_INSERT_XORWOW
    k = xorwow(&xw_state);
    k = k << 32 | xorwow(&xw_state);
#else
    k = transaction_id;
#endif
    // *((uint64_t *)&kmers[i].data) = k;
    memcpy(&bq_kmers[bq_kmers_idx].data, &k, sizeof(k));
    kmer_ht->insert((void *)&bq_kmers[bq_kmers_idx]);
    bq_kmers_idx++;
    if (bq_kmers_idx == BQ_TESTS_DEQUEUE_ARR_LENGTH) bq_kmers_idx = 0;

    if (transaction_id % (BQ_TESTS_NUM_INSERTS) == 0) {
      printf("[INFO] no_bqueues thread %u, transaction_id %lu\n", sh->shard_idx,
             transaction_id);
    }
  }

  t_end = RDTSCP();
  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = transaction_id;
  get_ht_stats(sh, kmer_ht);

  printf(
      "[INFO] Quick Stats: no_bqueues thread %u finished, sending %lu messages "
      "(cycles per message %lu)\n",
      sh->shard_idx, transaction_id, (t_end - t_start) / transaction_id);

  fipc_test_FAI(completed_producers);
}
} // namespace
