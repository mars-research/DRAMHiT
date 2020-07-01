#include "BQueueTest.hpp"
#include "misc_lib.h"
#include "print_stats.h"
#include "sync.h"

#define BQ_MAGIC_64BIT 0xD221A6BE96E04673UL
#define BQ_TESTS_BATCH_LENGTH (1ULL << 5)         // 32
#define BQ_TESTS_DEQUEUE_ARR_LENGTH (1ULL << 10)  // 512

namespace kmercounter {

extern uint64_t HT_TESTS_HT_SIZE;
extern uint64_t HT_TESTS_NUM_INSERTS;

// Test Variables
[[maybe_unused]] static uint64_t transactions = 100000000;
// static uint64_t transactions = 200000000;

uint8_t producer_count = 1;
uint8_t consumer_count = 1;

uint64_t batch_size = 1;

uint64_t mem_pool_order = 16;
uint64_t mem_pool_size;

extern KmerHashTable *init_ht(uint64_t, uint8_t);
extern void get_ht_stats(Shard *, KmerHashTable *);

int *bqueue_halt;

struct bq_kmer {
  char data[KMER_DATA_LENGTH];
};

struct bq_kmer bq_kmers[BQ_TESTS_DEQUEUE_ARR_LENGTH];
int bq_kmers_idx = 0;

void BQueueTest::producer_thread(int tid) {
  Shard *sh = &this->shards[tid];

  sh->stats =
      (thread_stats *)std::aligned_alloc(CACHE_LINE_SIZE, sizeof(thread_stats));
  uint64_t k = 0;
  uint8_t this_prod_id = sh->shard_idx;
  uint8_t cons_id = 0;
  uint64_t transaction_id;
  queue_t **q = this->prod_queues[this_prod_id];

#ifdef BQ_TESTS_INSERT_XORWOW
  struct xorwow_state xw_state;
  xorwow_init(&xw_state);
#endif

  fipc_test_FAI(ready_producers);
  while (!test_ready) fipc_test_pause();
  fipc_test_mfence();

  printf("[INFO] Producer %u starting. Total inserts :%llu \n", this_prod_id,
         HT_TESTS_NUM_INSERTS * consumer_count);

  /* HT_TESTS_NUM_INSERTS enqueues per consumer */
  cons_id = 0;
  for (transaction_id = 0u; transaction_id < HT_TESTS_NUM_INSERTS;) {
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
      if (transaction_id % (HT_TESTS_NUM_INSERTS * consumer_count / 10) == 0) {
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
}

void BQueueTest::consumer_thread(int tid) {
  Shard *sh = &this->shards[tid];
  sh->stats =
      (thread_stats *)std::aligned_alloc(CACHE_LINE_SIZE, sizeof(thread_stats));
  uint64_t t_start, t_end;
  KmerHashTable *kmer_ht = NULL;
  uint8_t finished_producers;
  uint64_t k = 0;
  uint64_t transaction_id = 0;
  uint8_t prod_id = 0;
  uint8_t this_cons_id = sh->shard_idx - producer_count;
  queue_t **q = this->cons_queues[this_cons_id];
  // bq_kmer[BQ_TESTS_BATCH_LENGTH*consumer_count];

  kmer_ht = init_ht(HT_TESTS_HT_SIZE, sh->shard_idx);
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
      if (transaction_id % (HT_TESTS_NUM_INSERTS * consumer_count / 10) == 0) {
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
  if (!this->cfg->ht_file.empty()) {
    std::string outfile = this->cfg->ht_file + std::to_string(sh->shard_idx);
    printf("[INFO] Shard %u: Printing to file: %s\n", sh->shard_idx,
           outfile.c_str());
    kmer_ht->print_to_file(outfile);
  }

  // End test
  fipc_test_FAI(completed_consumers);
}

void BQueueTest::init_queues(int nprod, int ncons) {
  uint64_t e, i, j;
  // Queue Allocation
  queue_t *queues = (queue_t *)std::aligned_alloc(
      FIPC_CACHE_LINE_SIZE, nprod * ncons * sizeof(queue_t));

  for (i = 0; i < nprod * ncons; ++i) init_queue(&queues[i]);

  this->prod_queues = (queue_t ***)std::aligned_alloc(
      FIPC_CACHE_LINE_SIZE, nprod * sizeof(queue_t **));
  this->cons_queues = (queue_t ***)std::aligned_alloc(
      FIPC_CACHE_LINE_SIZE, ncons * sizeof(queue_t **));

  bqueue_halt = (int *)calloc(ncons, sizeof(*bqueue_halt));

  /* For each producer allocate a queue connecting it to <ncons>
   * consumers */
  for (i = 0; i < nprod; ++i)
    this->prod_queues[i] = (queue_t **)std::aligned_alloc(
        FIPC_CACHE_LINE_SIZE, ncons * sizeof(queue_t *));

  for (i = 0; i < ncons; ++i) {
    this->cons_queues[i] = (queue_t **)std::aligned_alloc(
        FIPC_CACHE_LINE_SIZE, nprod * sizeof(queue_t *));
    bqueue_halt[i] = 0;
  }

  /* Queue Linking */
  for (i = 0; i < nprod; ++i) {
    for (j = 0; j < ncons; ++j) {
      this->prod_queues[i][j] = &queues[i * ncons + j];
      printf("[INFO] prod_queues[%lu][%lu] = %p\n", i, j,
             &queues[i * ncons + j]);
    }
  }

  for (i = 0; i < ncons; ++i) {
    for (j = 0; j < nprod; ++j) {
      this->cons_queues[i][j] = &queues[i + j * ncons];
      printf("[INFO] cons_queues[%lu][%lu] = %p\n", i, j,
             &queues[i + j * ncons]);
    }
  }
}

void BQueueTest::no_bqueues(Shard *sh, KmerHashTable *kmer_ht) {
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
      sh->shard_idx, HT_TESTS_NUM_INSERTS);

  t_start = RDTSC_START();

  for (transaction_id = 0u; transaction_id < HT_TESTS_NUM_INSERTS;
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

    if (transaction_id % (HT_TESTS_NUM_INSERTS) == 0) {
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

void BQueueTest::run_test(Configuration *cfg, Numa *n) {
  cpu_set_t cpuset;
  uint64_t e, i, j;

  // TODO numa split
  if (cfg->n_prod + cfg->n_cons > nodes[0].cpu_list.size()) {
    printf(
        "[ERROR] producers [%u] + consumers [%u] exceeded number of available "
        "CPUs on node 0 [%lu]\n",
        cfg->n_prod, cfg->n_cons, nodes[0].cpu_list.size());
    exit(-1);
  }

  this->n = n;
  this->nodes = this->n->get_node_config();
  this->cfg = cfg;
  this->prod_threads = new std::thread[cfg->n_prod];
  this->cons_threads = new std::thread[cfg->n_cons];

  // pthread_self()
  producer_count = cfg->n_prod;
  consumer_count = cfg->n_cons;
  printf("[INFO]: Controller starting ... nprod: %u, ncons: %u\n",
         producer_count, consumer_count);

  /* Stats data structures */
  this->shards = (Shard *)std::aligned_alloc(
      FIPC_CACHE_LINE_SIZE,
      sizeof(Shard) * (producer_count + consumer_count));

  memset(this->shards, 0, sizeof(Shard) * (producer_count + consumer_count));

  // Init queues
  this->init_queues(cfg->n_prod, cfg->n_cons);

  fipc_test_mfence();

  // Thread Allocation
  this->prod_threads = new std::thread[producer_count];

  this->cons_threads = new std::thread[consumer_count];

  // Spawn producer threads
  for (size_t i = 0; i < producer_count; i++) {
    Shard *sh = &this->shards[i];
    sh->shard_idx = i;

    this->prod_threads[i] = std::thread(&BQueueTest::producer_thread, this, i);

    CPU_ZERO(&cpuset);
    size_t cpu_idx = (i % nodes[0].cpu_list.size()) * 2;  // {0,2,4,6,8}
    CPU_SET(nodes[0].cpu_list[cpu_idx], &cpuset);
    pthread_setaffinity_np(prod_threads[i].native_handle(), sizeof(cpu_set_t),
                           &cpuset);
    printf("[INFO]: Spawn producer_thread %lu, affinity: %u\n", i,
           nodes[0].cpu_list[cpu_idx]);
  }

  // Spawn consumer threads
  for (size_t i = producer_count, j = 0; i < producer_count + consumer_count;
       i++, j++) {
    Shard *sh = &this->shards[i];
    sh->shard_idx = i;

    this->cons_threads[i] = std::thread(&BQueueTest::consumer_thread, this, i);

    CPU_ZERO(&cpuset);
    size_t cpu_idx = (j % nodes[0].cpu_list.size()) * 2 + 1;  //{1,3,5,7,9}
    CPU_SET(nodes[0].cpu_list[cpu_idx], &cpuset);
    pthread_setaffinity_np(this->cons_threads[j].native_handle(),
                           sizeof(cpu_set_t), &cpuset);
    printf("[INFO]: Spawn consumer_thread %lu, affinity: %u\n", j,
           nodes[0].cpu_list[cpu_idx]);
  }

  CPU_ZERO(&cpuset);
  /* last cpu of last node  */
  auto last_numa_node = nodes[n->get_num_nodes() - 1];
  CPU_SET(last_numa_node.cpu_list[last_numa_node.num_cpus - 1], &cpuset);
  sched_setaffinity(0, sizeof(cpu_set_t), &cpuset);

  /* Wait for threads to be ready for test */
  while (ready_consumers < consumer_count) fipc_test_pause();
  while (ready_producers < producer_count) fipc_test_pause();

  fipc_test_mfence();

  /* Begin Test */
  test_ready = 1;
  fipc_test_mfence();

  /* Wait for producers to complete */
  while (completed_producers < producer_count) fipc_test_pause();

  fipc_test_mfence();

  /* Tell consumers to halt */
  for (i = 0; i < consumer_count; ++i) {
    bqueue_halt[i] = 1;
  }

  /* Wait for consumers to complete */
  while (completed_consumers < consumer_count) fipc_test_pause();

  fipc_test_mfence();

  cfg->num_threads = producer_count + consumer_count;
  print_stats(this->shards, *cfg);

  /* Tell consumers to halt once producers are done */
  // return 0;

  /* TODO free everything */
}

}  // namespace kmercounter
