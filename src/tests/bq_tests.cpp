#include <cinttypes>

#include "BQueueTest.hpp"
#include "misc_lib.h"
#include "print_stats.h"
#include "sync.h"
#include "hasher.hpp"

#if defined(BQ_TESTS_INSERT_ZIPFIAN)
#include "hashtables/ht_helper.hpp"
#include "zipf.h"
#endif

#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

#define BQ_MAGIC_64BIT 0xD221A6BE96E04673UL
#define BQ_TESTS_BATCH_LENGTH 16
#define BQ_TESTS_DEQUEUE_ARR_LENGTH 16

namespace kmercounter {
extern uint64_t HT_TESTS_HT_SIZE;
extern uint64_t HT_TESTS_NUM_INSERTS;

// Test Variables
[[maybe_unused]] static uint64_t transactions = 100000000;

uint32_t producer_count = 1;
uint32_t consumer_count = 1;

uint64_t batch_size = 1;

uint64_t mem_pool_order = 16;
uint64_t mem_pool_size;

// for synchronization of threads
static uint64_t ready = 0;
static uint64_t ready_threads = 0;

extern BaseHashTable *init_ht(uint64_t, uint8_t);
extern void get_ht_stats(Shard *, BaseHashTable *);

#ifdef BQ_TESTS_USE_HALT
int *bqueue_halt;
#endif

struct bq_kmer {
  char data[KMER_DATA_LENGTH];
} __attribute__((aligned(64)));

struct bq_kmer bq_kmers[BQ_TESTS_DEQUEUE_ARR_LENGTH];
// thread-local since we have multiple consumers
__thread int data_idx = 0;
__thread uint64_t keys[BQ_TESTS_DEQUEUE_ARR_LENGTH];
__attribute__((
    aligned(64))) __thread Keys _items[BQ_TESTS_DEQUEUE_ARR_LENGTH] = {0};
alignas(64) uint64_t cons_buffers[64][64][BQ_TESTS_BATCH_LENGTH];
alignas(64) uint64_t buf_idx[64][64];

uint64_t num_enq_failures[64][64] = {0};
uint64_t num_deq_failures[64][64] = {0};

void BQueueTest::producer_thread(int tid, int n_prod, int n_cons,
                                 bool main_thread, double skew) {
  Shard *sh = &this->shards[tid];

  sh->stats =
      //(thread_stats *)std::aligned_alloc(CACHE_LINE_SIZE,
      // sizeof(thread_stats));
      (thread_stats *)calloc(1, sizeof(thread_stats));
  alignas(64) uint64_t k = 0;
  uint8_t this_prod_id = sh->shard_idx;
  uint32_t cons_id = 0;
  uint64_t transaction_id;
  queue_t **q = this->prod_queues[this_prod_id];

#ifdef WITH_VTUNE_LIB
  std::string thread_name("producer_thread" + std::to_string(tid));
  __itt_thread_set_name(thread_name.c_str());
#endif

#ifdef BQ_TESTS_INSERT_XORWOW_NEW
  struct xorwow_state xw_state;
  xorwow_init(&xw_state);
#elif defined(BQ_TESTS_INSERT_ZIPFIAN)
#warning "Zipfian Bqueues"
  zipf_distribution dist{skew, 192ull * (1ull << 20),
                         tid + 1};  // FIXME: magic numbers
#endif

  // HT_TESTS_NUM_INSERTS enqueues per consumer
  cons_id = 0;
  auto mult_factor = static_cast<double>(n_cons) / n_prod;
  auto _num_messages = HT_TESTS_NUM_INSERTS * 2 * mult_factor;
  uint64_t num_messages = static_cast<uint64_t>(_num_messages);
  uint64_t key_start = static_cast<uint64_t>(_num_messages) * tid;
  Hasher hasher;

#ifdef BQ_TESTS_INSERT_ZIPFIAN
  std::vector<uint64_t> values(num_messages);
  for (auto &value : values) value = dist();
#endif

  if (main_thread) {
    // Wait for threads to be ready for test
    while (ready_consumers < consumer_count) fipc_test_pause();
    // main thread is a producer, but won't increment!
    while (ready_producers < (producer_count - 1)) fipc_test_pause();

    fipc_test_mfence();

    // Signal begin
    test_ready = 1;
    fipc_test_mfence();
  } else {
    fipc_test_FAI(ready_producers);
    while (!test_ready) fipc_test_pause();
    fipc_test_mfence();
  }

  // printf("%s, mult_factor %f _num_messages %f | num_messages %lu\n",
  // __func__,
  //        mult_factor, _num_messages, num_messages);
  if (key_start == 0) key_start = 1;
  PLOG_INFO.printf(
      "Producer %u starting. Sending %lu messages to %d consumers | "
      "key_start %lu",
      this_prod_id, num_messages, consumer_count, key_start);

  auto hash_to_cpu = [&](auto hash) {
    // return (hash * 11400714819323198485llu) % n_cons;
    if (!(n_cons & (n_cons - 1))) return hash & (n_cons - 1);
    return hash % n_cons;
  };

  for (transaction_id = 0u; transaction_id < num_messages;) {
    /* BQ_TESTS_BATCH_LENGTH enqueues in one batch, then move on to next
     * consumer */

    for (auto i = 0u; i < BQ_TESTS_BATCH_LENGTH; i++) {
#ifdef BQ_TESTS_INSERT_XORWOW_NEW
      k = xorwow(&xw_state);
#elif defined(BQ_TESTS_INSERT_ZIPFIAN)  // TODO: this is garbage
      if (i % 8 == 0 && i + 16 < values.size())
        prefetch_object<false>(&values.at(i + 16), 64);
      k = values.at(transaction_id);
#else
      k = key_start++;
#endif

      uint64_t hash_val = hasher(&k, sizeof(k));

      cons_id = hash_to_cpu(k);
      // k has the computed hash in upper 32 bits
      // and the actual key value in lower 32 bits
      k |= (hash_val << 32);
      // *((uint64_t *)&kmers[i].data) = k;
    retry:
      if (enqueue(q[cons_id], (data_t)k) != SUCCESS) {
        /* if enqueue fails, move to next consumer queue */
        // PLOG_ERROR.printf("Producer %u -> Consumer %u \n", this_prod_id,
        // cons_id);
        // num_enq_failures[this_prod_id][cons_id]++;
        goto retry;
        // break;
      }
      // printf("%s[%d], enqueuing to q[%d] = %p\n", __func__, this_prod_id,
      // cons_id, q[cons_id]);

      {
        // | 0 | 1 | .... | 7 |
        auto *_q = q[cons_id];
        if ((_q->head & 7) == 0) {
          auto new_head = (_q->head + 8) & (QUEUE_SIZE - 1);
          __builtin_prefetch(&_q->data[new_head], 1, 3);
        }
        auto _cons_id = cons_id + 1;
        if (_cons_id >= consumer_count) _cons_id = 0;
        __builtin_prefetch(q[_cons_id], 1, 3);
      }
      transaction_id++;
#ifdef CALC_STATS
      if (transaction_id % (HT_TESTS_NUM_INSERTS * consumer_count / 10) == 0) {
        PLOG_INFO.printf("Producer %u, transaction_id %lu", this_prod_id,
               transaction_id);
      }
#endif
    }

    /* ++cons_id;
    if (cons_id >= consumer_count) cons_id = 0;

    auto get_next_cons = [&](auto inc) {
      auto next_cons_id = cons_id + inc;
      if (next_cons_id >= consumer_count) next_cons_id -= consumer_count;
      return next_cons_id;
    };

    prefetch_queue(q[get_next_cons(2)], true);
    prefetch_queue_data(q[get_next_cons(1)], true);
    */
  }

#ifdef BQ_TESTS_USE_HALT
  /* Tell consumers to halt */
  for (auto i = 0u; i < consumer_count; ++i) {
    bqueue_halt[i] = 1;
  }
#else
  /* enqueue halt messages */
  for (cons_id = 0; cons_id < consumer_count; cons_id++) {
    q[cons_id]->backtrack_flag = 1;
    while (enqueue(q[cons_id], (data_t)BQ_MAGIC_64BIT) != SUCCESS)
      ;
    transaction_id++;
  }
#endif
  // main thread will also increment this
  fipc_test_FAI(completed_producers);
}

void BQueueTest::consumer_thread(int tid, uint32_t num_nops) {
  Shard *sh = &this->shards[tid];
  sh->stats =
      //(thread_stats *)std::aligned_alloc(CACHE_LINE_SIZE,
      // sizeof(thread_stats));
      (thread_stats *)calloc(1, sizeof(thread_stats));

  std::uint64_t count{};
  uint64_t t_start, t_end;
  BaseHashTable *kmer_ht = NULL;
  uint8_t finished_producers = 0;
  alignas(64) uint64_t k = 0;
  uint64_t transaction_id = 0;
  uint32_t prod_id = 0;
  uint8_t this_cons_id = sh->shard_idx - producer_count;
  queue_t **q = this->cons_queues[this_cons_id];
  uint64_t inserted = 0u;
#ifdef WITH_VTUNE_LIB
  std::string thread_name("consumer_thread" + std::to_string(tid));
  PLOG_VERBOSE.printf("thread_name %s", thread_name.c_str());
  __itt_thread_set_name(thread_name.c_str());
#endif
  // bq_kmer[BQ_TESTS_BATCH_LENGTH*consumer_count];

  PLOG_INFO.printf("init_ht with %d", sh->shard_idx);
  kmer_ht =
      init_ht(HT_TESTS_HT_SIZE * (cfg->n_prod + cfg->n_cons) / cfg->n_cons,
              sh->shard_idx);
  (*this->ht_vec)[tid] = kmer_ht;
  fipc_test_FAI(ready_consumers);
  while (!test_ready) fipc_test_pause();
  fipc_test_mfence();

  PLOG_INFO.printf("Consumer %u starting", this_cons_id);

#ifdef WITH_VTUNE_LIB
  static const auto event =
      __itt_event_create("message_insert", strlen("message_insert"));
  __itt_event_start(event);
#endif
  t_start = RDTSC_START();

  prod_id = 0;
#ifdef BQ_TESTS_USE_HALT
  while (!bqueue_halt[this_cons_id]) {
#else
  while (finished_producers < producer_count) {
#endif

    auto get_next_prod = [&](auto inc) {
      auto next_prod_id = prod_id + inc;
      if (next_prod_id >= producer_count) next_prod_id -= producer_count;
      return next_prod_id;
    };

    auto submit_batch = [&](auto num_elements) {
      KeyPairs kp = std::make_pair(num_elements, &_items[0]);

      prefetch_queue(q[get_next_prod(2)]);
      prefetch_queue_data(q[get_next_prod(1)], false);

      kmer_ht->insert_batch(kp);
      inserted += kp.first;

      data_idx = 0;
    };

    kmer_ht->prefetch_queue(QueueType::insert_queue);
    for (auto i = 0u; i < 1 * BQ_TESTS_BATCH_LENGTH; i++) {
      /* Receive and unmarshall */
      if (dequeue(q[prod_id], (data_t *)&k) != SUCCESS) {
        /* move on to next producer queue to dequeue */
        // PLOG_ERROR.printf("Consumer %u <- Producer %u \n", sh->shard_idx,
        // prod_id);
        // num_deq_failures[tid][prod_id]++;

        if (data_idx > 0) {
          submit_batch(data_idx);
        }

        break;
      }
      // printf("%s[%d], dequeing from q[%d] = %p\n", __func__, this_cons_id,
      // prod_id, q[prod_id]);

      //++count;

      auto *_q = q[prod_id];
      if ((_q->tail & 7) == 0) {
        auto new_tail = (_q->tail + 8) & (QUEUE_SIZE - 1);
        __builtin_prefetch(&_q->data[new_tail], 1, 3);
      }

      if ((data_t)k == BQ_MAGIC_64BIT) {
        fipc_test_FAI(finished_producers);
        PLOG_INFO.printf(
            "Consumer %u, received HALT from prod_id %u. "
            "finished_producers :%u",
            this_cons_id, prod_id, finished_producers);

        PLOG_DEBUG.printf("Consumer experienced %" PRIu64 " reprobes, %" PRIu64
               " soft",
               kmer_ht->num_reprobes, kmer_ht->num_soft_reprobes);

        PLOG_DEBUG.printf("Consumer received %" PRIu64, count);

        continue;
      }

      if constexpr (bq_load == BQUEUE_LOAD::HtInsert) {
        _items[data_idx].key = _items[data_idx].id = k;

        // for (auto i = 0u; i < num_nops; i++) asm volatile("nop");

        if (++data_idx == BQ_TESTS_DEQUEUE_ARR_LENGTH) {
          submit_batch(BQ_TESTS_DEQUEUE_ARR_LENGTH);
        }
      }

      transaction_id++;
#ifdef CALC_STATS
      if (transaction_id % (HT_TESTS_NUM_INSERTS * consumer_count / 10) == 0) {
        PLOG_INFO.printf("Consumer %u, transaction_id %lu", this_cons_id,
               transaction_id);
      }
#endif
    }
    ++prod_id;
    if (prod_id >= producer_count) {
      prod_id = 0;
    }
  }

  t_end = RDTSCP();
#ifdef WITH_VTUNE_LIB
  __itt_event_end(event);
#endif
  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = transaction_id;
  get_ht_stats(sh, kmer_ht);

  PLOG_INFO.printf("cons_id %d | inserted %lu elements", this_cons_id,
         inserted);
  PLOG_INFO.printf(
      "Quick Stats: Consumer %u finished, receiving %lu messages "
      "(cycles per message %lu) prod_count %u | finished %u",
      this_cons_id, transaction_id, (t_end - t_start) / transaction_id,
      producer_count, finished_producers);

  /* Write to file */
  if (!this->cfg->ht_file.empty()) {
    std::string outfile = this->cfg->ht_file + std::to_string(sh->shard_idx);
    PLOG_INFO.printf("Shard %u: Printing to file: %s", sh->shard_idx,
           outfile.c_str());
    kmer_ht->print_to_file(outfile);
  }

  // End test
  fipc_test_FAI(completed_consumers);
}

void BQueueTest::find_thread(int tid, int n_prod, int n_cons,
                             bool main_thread) {
  int part_id;
  Shard *sh = &this->shards[tid];
  int j = 0;
  uint64_t found = 0, not_found = 0;
  uint64_t count = HT_TESTS_NUM_INSERTS * tid;
  BaseHashTable *ktable;
  uint64_t t_start, t_end;
  Hasher hasher;

  if (tid == 0) count = 1;

  alignas(64) uint64_t k = 0;
#ifdef WITH_VTUNE_LIB
  std::string thread_name("find_thread" + std::to_string(tid));
  __itt_thread_set_name(thread_name.c_str());
#endif

  ktable = this->ht_vec->at(tid);

  if (ktable == nullptr) {
    PLOG_INFO.printf("init_ht with %d", sh->shard_idx);
    ktable = init_ht(HT_TESTS_HT_SIZE * 2, sh->shard_idx);
    this->ht_vec->at(tid) = ktable;
  }

  Values *values;
  values = new Values[HT_TESTS_FIND_BATCH_LENGTH];

  if (main_thread) {
    // Wait for threads to be ready for test
    while (ready_threads < (uint64_t)(n_prod + n_cons - 1)) fipc_test_pause();

    // Signal begin
    ready = 1;
    fipc_test_mfence();
  } else {
    fipc_test_FAI(ready_threads);
    while (!ready) fipc_test_pause();
    fipc_test_mfence();
  }

  // HT_TESTS_NUM_INSERTS enqueues per consumer
  auto mult_factor = static_cast<double>(n_cons) / n_prod;
  auto _num_messages = HT_TESTS_NUM_INSERTS * mult_factor;
  uint64_t key_start = static_cast<uint64_t>(_num_messages) * tid;

  __attribute__((aligned(64))) Keys items[HT_TESTS_FIND_BATCH_LENGTH] = {0};

  ValuePairs vp = std::make_pair(0, values);

  if (tid == 1) {
    // return;
  }
  // printf("%s, mult_factor %f _num_messages %f | num_messages %lu\n",
  // __func__,
  //        mult_factor, _num_messages, num_messages);
  if (key_start == 0) key_start = 1;
  PLOG_INFO.printf("Finder %u starting. key_start %lu", tid, key_start);

  auto hash_to_cpu = [&](auto hash) {
    // return (hash * 11400714819323198485llu) % n_cons;
    if (!(n_cons & (n_cons - 1))) return hash & (n_cons - 1);
    return hash % n_cons;
  };

  t_start = RDTSC_START();

  for (auto i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {
    k = key_start++;
    uint64_t hash_val = hasher(&k, sizeof(k));

    part_id = hash_to_cpu(k);
    // k has the computed hash in upper 32 bits
    // and the actual key value in lower 32 bits
    k |= (hash_val << 32);

    items[j].key = k;
    items[j].id = count;
    items[j].part_id = part_id + n_prod;
    count++;

    if (++j == HT_TESTS_FIND_BATCH_LENGTH) {
      KeyPairs kp = std::make_pair(HT_TESTS_FIND_BATCH_LENGTH, &items[0]);
      // printf("%s, calling find_batch i = %d\n", __func__, i);
      // ktable->find_batch((Keys *)items, HT_TESTS_FIND_BATCH_LENGTH);
      ktable->find_batch(kp, vp);
      found += vp.first;
      j = 0;
      not_found += HT_TESTS_FIND_BATCH_LENGTH - vp.first;
      vp.first = 0;
      // printf("\t tid %lu count %lu | found -> %lu | not_found -> %lu \n",
      // tid, count, found, not_found);
    }

#ifdef CALC_STATS
    // if (transaction_id % (HT_TESTS_NUM_INSERTS * consumer_count / 10) == 0) {
    //   PLOG_INFO.printf("Producer %u, transaction_id %lu\n", this_prod_id,
    //          transaction_id);
    // }
#endif
  }
  t_end = RDTSCP();

  sh->stats->find_cycles = (t_end - t_start);
  sh->stats->num_finds = found;

  if (found > 0) {
    PLOG_INFO.printf("thread %u | num_finds %lu | cycles per get: %lu\n",
           sh->shard_idx, found, (t_end - t_start) / found);
  }

  get_ht_stats(sh, ktable);
}

void BQueueTest::init_queues(uint32_t nprod, uint32_t ncons) {
  uint32_t i, j;
  // Queue Allocation
  queue_t *queues = (queue_t *)std::aligned_alloc(
      FIPC_CACHE_LINE_SIZE, nprod * ncons * sizeof(queue_t));

  for (i = 0; i < nprod * ncons; ++i) init_queue(&queues[i]);

  this->prod_queues = (queue_t ***)std::aligned_alloc(
      FIPC_CACHE_LINE_SIZE, nprod * sizeof(queue_t **));
  this->cons_queues = (queue_t ***)std::aligned_alloc(
      FIPC_CACHE_LINE_SIZE, ncons * sizeof(queue_t **));

#ifdef BQ_TESTS_USE_HALT
  bqueue_halt = (int *)calloc(ncons, sizeof(*bqueue_halt));
#endif

  /* For each producer allocate a queue connecting it to <ncons>
   * consumers */
  for (i = 0; i < nprod; ++i)
    this->prod_queues[i] = (queue_t **)std::aligned_alloc(
        FIPC_CACHE_LINE_SIZE, ncons * sizeof(queue_t *));

  for (i = 0; i < ncons; ++i) {
    this->cons_queues[i] = (queue_t **)std::aligned_alloc(
        FIPC_CACHE_LINE_SIZE, nprod * sizeof(queue_t *));
#ifdef BQ_TESTS_USE_HALT
    bqueue_halt[i] = 0;
#endif
  }

  /* Queue Linking */
  for (i = 0; i < nprod; ++i) {
    for (j = 0; j < ncons; ++j) {
      this->prod_queues[i][j] = &queues[i * ncons + j];
      PLOG_INFO.printf("prod_queues[%u][%u] = %p", i, j, &queues[i * ncons + j]);
    }
  }

  for (i = 0; i < ncons; ++i) {
    for (j = 0; j < nprod; ++j) {
      this->cons_queues[i][j] = &queues[i + j * ncons];
      PLOG_INFO.printf("cons_queues[%u][%u] = %p", i, j, &queues[i + j * ncons]);
    }
  }

  // cons_buffers =  (uint64_t *) std::aligned_alloc(FIPC_CACHE_LINE_SIZE, nprod
  // * ncons * BQ_TESTS_BATCH_LENGTH * sizeof(uint64_t)); buf_idx =  (uint64_t
  // *) std::aligned_alloc(FIPC_CACHE_LINE_SIZE, nprod * ncons *
  // sizeof(uint64_t));

  // memset(buf_idx[i], 0x0, nprod * ncons * sizeof(uint64_t));
  memset(cons_buffers, 0x0, sizeof(cons_buffers));
  memset(buf_idx, 0x0, sizeof(buf_idx));
}

void BQueueTest::no_bqueues(Shard *sh, BaseHashTable *kmer_ht) {
  [[maybe_unused]] uint64_t k = 0;
  // uint64_t num_inserts = 0;
  uint64_t t_start, t_end;
  uint64_t transaction_id;

#ifdef BQ_TESTS_INSERT_XORWOW
  struct xorwow_state xw_state;
  xorwow_init(&xw_state);
#endif

  PLOG_INFO.printf(
      "no_bqueues thread %u starting. Total inserts in this "
      "thread:%lu ",
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

#ifdef BQ_TESTS_DO_HT_INSERTS
    /* Save kmer into array*/
    memcpy(&bq_kmers[data_idx].data, &k, sizeof(k));
    /* insert kmer into HT */
    kmer_ht->insert((void *)&bq_kmers[data_idx]);
    data_idx++;
    if (data_idx == BQ_TESTS_DEQUEUE_ARR_LENGTH) data_idx = 0;
#endif

    if (transaction_id % (HT_TESTS_NUM_INSERTS) == 0) {
      PLOG_INFO.printf("no_bqueues thread %u, transaction_id %lu", sh->shard_idx,
             transaction_id);
    }
  }

  t_end = RDTSCP();
  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = transaction_id;
  get_ht_stats(sh, kmer_ht);

  PLOG_INFO.printf(
      "Quick Stats: no_bqueues thread %u finished, sending %lu messages "
      "(cycles per message %lu)",
      sh->shard_idx, transaction_id, (t_end - t_start) / transaction_id);
}

void BQueueTest::run_test(Configuration *cfg, Numa *n, NumaPolicyQueues *npq) {
  this->ht_vec =
      new std::vector<BaseHashTable *>(cfg->n_prod + cfg->n_cons, nullptr);
  // 1) Insert using bqueues
  this->insert_with_bqueues(cfg, n, npq);

  // 2) spawn n_prod + n_cons threads for find
  this->run_find_test(cfg, n, npq);
}

void BQueueTest::run_find_test(Configuration *cfg, Numa *n,
                               NumaPolicyQueues *npq) {
  uint32_t i = 0, j = 0;
  cpu_set_t cpuset;
  // Spawn threads that will perform find operation
  for (uint32_t assigned_cpu : this->npq->get_assigned_cpu_list_producers()) {
    // skip the first CPU, we'll launch it later
    if (assigned_cpu == 0) continue;
    Shard *sh = &this->shards[i];
    sh->shard_idx = i;
    auto _thread = std::thread(&BQueueTest::find_thread, this, i, cfg->n_prod,
                               cfg->n_cons, false);
    CPU_ZERO(&cpuset);
    CPU_SET(assigned_cpu, &cpuset);
    pthread_setaffinity_np(_thread.native_handle(), sizeof(cpu_set_t), &cpuset);
    this->prod_threads.push_back(std::move(_thread));
    PLOG_INFO.printf("Thread find_thread: %u, affinity: %u", i, assigned_cpu);
    i += 1;
  }

  PLOG_INFO.printf("creating cons threads i %d ", i);
  Shard *main_sh = &this->shards[i];
  main_sh->shard_idx = i;
  CPU_ZERO(&cpuset);
  uint32_t last_cpu = 0;
  CPU_SET(last_cpu, &cpuset);
  sched_setaffinity(0, sizeof(cpu_set_t), &cpuset);
  PLOG_INFO.printf("Thread 'controller': affinity: %u", last_cpu);

  // Spawn find threads
  i = cfg->n_prod;
  for (auto assigned_cpu : this->npq->get_assigned_cpu_list_consumers()) {
    PLOG_INFO.printf("i %d assigned cpu %d", i, assigned_cpu);

    Shard *sh = &this->shards[i];
    sh->shard_idx = i;

    auto _thread = std::thread(&BQueueTest::find_thread, this, i, cfg->n_prod,
                               cfg->n_cons, false);

    CPU_ZERO(&cpuset);
    CPU_SET(assigned_cpu, &cpuset);

    pthread_setaffinity_np(_thread.native_handle(), sizeof(cpu_set_t), &cpuset);

    PLOG_INFO.printf("Thread find_thread: %u, affinity: %u", i, assigned_cpu);
    PLOG_INFO.printf("[%d] sh->insertion_cycles %lu", sh->shard_idx,
           sh->stats->insertion_cycles);

    this->cons_threads.push_back(std::move(_thread));
    i += 1;
    j += 1;
  }

  {
    PLOG_INFO.printf("Running master thread with id %d", main_sh->shard_idx);
    this->find_thread(main_sh->shard_idx, cfg->n_prod, cfg->n_cons, true);
  }

  for (auto &th : this->prod_threads) {
    th.join();
  }

  for (auto &th : this->cons_threads) {
    th.join();
  }
  PLOG_INFO.printf("Find done!");
  print_stats(this->shards, *cfg);
}

void BQueueTest::insert_with_bqueues(Configuration *cfg, Numa *n,
                                     NumaPolicyQueues *npq) {
  cpu_set_t cpuset;
  uint32_t i = 0, j = 0;

  this->n = n;
  this->nodes = this->n->get_node_config();
  this->npq = npq;
  this->cfg = cfg;

  uint32_t num_nodes = static_cast<uint32_t>(this->n->get_num_nodes());
  uint32_t num_cpus = static_cast<uint32_t>(this->n->get_num_total_cpus());

  /* num_nodes cpus not available TODO Verify this logic*/
  if (this->cfg->n_prod + this->cfg->n_cons > num_cpus) {
    PLOG_ERROR.printf(
            "producers (%u) + consumers (%u) exceeded number of "
            "available CPUs (%u)",
            this->cfg->n_prod, this->cfg->n_cons, num_cpus);
    PLOG_ERROR.printf(
            "Note: %u core(s) not available, one of which "
            "is assigned completely for synchronization",
            num_nodes);
    exit(-1);
  }

  producer_count = cfg->n_prod;
  consumer_count = cfg->n_cons;
  PLOG_INFO.printf("Controller starting ... nprod: %u, ncons: %u",
         producer_count, consumer_count);

  /* Stats data structures */
  // this->shards = (Shard *)std::aligned_alloc(
  //    FIPC_CACHE_LINE_SIZE, sizeof(Shard) * (producer_count +
  //    consumer_count));

  this->shards =
      (Shard *)calloc(sizeof(Shard), (producer_count + consumer_count));

  // Init queues
  this->init_queues(cfg->n_prod, cfg->n_cons);

  fipc_test_mfence();

  // Spawn producer threads
  for (uint32_t assigned_cpu : this->npq->get_assigned_cpu_list_producers()) {
    // skip the first CPU, we'll launch producer on this
    if (assigned_cpu == 0) continue;
    Shard *sh = &this->shards[i];
    sh->shard_idx = i;
    auto _thread = std::thread(&BQueueTest::producer_thread, this, i,
                               cfg->n_prod, cfg->n_cons, false, cfg->skew);
    CPU_ZERO(&cpuset);
    CPU_SET(assigned_cpu, &cpuset);
    pthread_setaffinity_np(_thread.native_handle(), sizeof(cpu_set_t), &cpuset);
    this->prod_threads.push_back(std::move(_thread));
    PLOG_INFO.printf("Thread producer_thread: %u, affinity: %u", i,
           assigned_cpu);
    i += 1;
  }

  PLOG_INFO.printf("creating cons threads i %d ", i);
  Shard *main_sh = &this->shards[i];
  main_sh->shard_idx = i;
  CPU_ZERO(&cpuset);
  uint32_t last_cpu = 0;
  CPU_SET(last_cpu, &cpuset);
  sched_setaffinity(0, sizeof(cpu_set_t), &cpuset);
  PLOG_INFO.printf("Thread 'controller': affinity: %u", last_cpu);

  // Spawn consumer threads
  i = producer_count;
  for (auto assigned_cpu : this->npq->get_assigned_cpu_list_consumers()) {
    PLOG_INFO.printf("i %d assigned cpu %d", i, assigned_cpu);

    Shard *sh = &this->shards[i];
    sh->shard_idx = i;

    auto _thread =
        std::thread(&BQueueTest::consumer_thread, this, i, cfg->num_nops);

    CPU_ZERO(&cpuset);
    CPU_SET(assigned_cpu, &cpuset);

    pthread_setaffinity_np(_thread.native_handle(), sizeof(cpu_set_t), &cpuset);

    PLOG_INFO.printf("Thread consumer_thread: %u, affinity: %u", i,
           assigned_cpu);

    this->cons_threads.push_back(std::move(_thread));
    i += 1;
    j += 1;
  }

  {
    PLOG_INFO.printf("Running master thread with id %d", main_sh->shard_idx);
    this->producer_thread(main_sh->shard_idx, cfg->n_prod, cfg->n_cons, true,
                          cfg->skew);
  }

  // Wait for producers to complete
  while (completed_producers < producer_count) fipc_test_pause();

  fipc_test_mfence();

  // Wait for consumers to complete
  while (completed_consumers < consumer_count) fipc_test_pause();

  fipc_test_mfence();

  cfg->num_threads = producer_count + consumer_count;
  // print_stats(this->shards, *cfg);

  for (auto &th : this->prod_threads) {
    th.join();
  }

  for (auto &th : this->cons_threads) {
    th.join();
  }
  this->prod_threads.clear();
  this->cons_threads.clear();
  /* TODO free everything */
}

}  // namespace kmercounter
