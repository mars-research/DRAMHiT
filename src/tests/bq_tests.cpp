#include <algorithm>
#include <cassert>
#include <cinttypes>
#include <tuple>

#include "BQueueTest.hpp"
#include "fastrange.h"
#include "hasher.hpp"
#include "hashtables/simple_kht.hpp"
#include "helper.hpp"
#include "misc_lib.h"
#include "print_stats.h"
#include "sync.h"

#if defined(BQ_TESTS_INSERT_ZIPFIAN)
#include "hashtables/ht_helper.hpp"
#include "zipf.h"
#endif

#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

#define BQ_MAGIC_64BIT 0xD221A6BE96E04673UL
#define BQ_TESTS_BATCH_LENGTH_PROD 1
#define BQ_TESTS_BATCH_LENGTH_CONS 32
#define BQ_TESTS_DEQUEUE_ARR_LENGTH 16

namespace kmercounter {
using namespace std;

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

struct bq_kmer {
  char data[KMER_DATA_LENGTH];
} __attribute__((aligned(64)));

struct bq_kmer bq_kmers[BQ_TESTS_DEQUEUE_ARR_LENGTH];

// thread-local since we have multiple consumers
__thread int data_idx = 0;
__thread uint64_t keys[BQ_TESTS_DEQUEUE_ARR_LENGTH];
__attribute__((
    aligned(64))) __thread Keys _items[BQ_TESTS_DEQUEUE_ARR_LENGTH] = {0};

inline std::tuple<double, uint64_t, uint64_t> get_params(uint32_t n_prod,
                                                         uint32_t n_cons,
                                                         uint32_t tid) {
  // In a non-bqueue setting, num-threads = t, then we will have
  // t hashtables of HT_TESTS_HT_SIZE buckets each.
  // However, for bqueue setting where we have different number of
  // producers and consumers, we cannot create hashtable with the same
  // N buckets as it won't be comparable. Why? Because, some of the
  // threads are assigned as producers and they won't have any hash tables.
  // In the end, we want to compare M insertions in total for both bqueue and
  // non-bqueue setting.
  auto ratio = static_cast<double>(n_prod / n_cons) + 1;
  auto num_messages = HT_TESTS_NUM_INSERTS * ratio;
  // our HT has a notion of empty keys which is 0. So, no '0' key for now!
  uint64_t key_start =
      std::max(static_cast<uint64_t>(num_messages) * tid, (uint64_t)1);
  return std::make_tuple(ratio, num_messages, key_start);
}

auto hash_to_cpu(std::uint32_t hash, unsigned int count) {
  return fastrange32(_mm_crc32_u32(0xffffffff, hash), count);
};

void BQueueTest::producer_thread(const uint32_t tid, const uint32_t n_prod,
                                 const uint32_t n_cons, const bool main_thread,
                                 const double skew) {
  // Get shard pointer from the shards array
  Shard *sh = &this->shards[tid];

  // Allocate memory for stats
  sh->stats =
      //(thread_stats *)std::aligned_alloc(CACHE_LINE_SIZE,
      // sizeof(thread_stats));
      (thread_stats *)calloc(1, sizeof(thread_stats));
  alignas(64) uint64_t k = 0;

  uint8_t this_prod_id = sh->shard_idx;
  uint32_t cons_id = 0;
  uint64_t transaction_id;
  queue_t *queues[n_cons];

  // initialize the local queues array from queue_map
  for (int i = 0; i < n_cons; i++) {
    queues[i] = queue_map.at(std::make_tuple(this_prod_id, i));
    PLOG_DEBUG.printf("[prod:%d] q[%d] -> %p", this_prod_id, i, queues[i]);
  }

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

  auto [ratio, num_messages, key_start] = get_params(n_prod, n_cons, tid);
  Hasher hasher;

#ifdef BQ_TESTS_INSERT_ZIPFIAN
  std::vector<uint64_t> values(num_messages);
  for (auto &value : values) value = dist();
#endif

  if (main_thread) {
    // Wait for threads to be ready for test
    while (ready_consumers < n_cons) fipc_test_pause();
    // main thread is a producer, but won't increment!
    while (ready_producers < (n_prod - 1)) fipc_test_pause();

    fipc_test_mfence();

    // Signal begin
    test_ready = 1;
    fipc_test_mfence();
  } else {
    fipc_test_FAI(ready_producers);
    while (!test_ready) fipc_test_pause();
    fipc_test_mfence();
  }

  PLOG_DEBUG.printf(
      "[prod:%u] started! Sending %lu messages to %d consumers | "
      "key_start %lu",
      this_prod_id, num_messages, n_cons, key_start);

  std::vector<unsigned int> hist(n_cons);
  auto get_next_cons = [&](auto inc) {
    auto next_cons_id = cons_id + inc;
    if (next_cons_id >= n_cons) {
      next_cons_id -= n_cons;
    }
    return next_cons_id;
  };
#ifdef WITH_VTUNE_LIB
  static const auto event =
      __itt_event_create("message_enqueue", strlen("message_enqueue"));
  __itt_event_start(event);
#endif

  for (transaction_id = 0u; transaction_id < num_messages;) {
    // The idea is to batch messages upto BQ_TESTS_BATCH_LENGTH
    // for the same queue and then move on to next consumer
#if !defined(BQ_TESTS_DO_HT_INSERTS)
    for (auto i = 0u; i < BQ_TESTS_BATCH_LENGTH_PROD; i++) {
#endif

#ifdef BQ_TESTS_INSERT_XORWOW_NEW
      k = xorwow(&xw_state);
#elif defined(BQ_TESTS_INSERT_ZIPFIAN)  // TODO: this is garbage
    if (i % 8 == 0 && i + 16 < values.size())
      prefetch_object<false>(&values.at(i + 16), 64);
    k = values.at(transaction_id);
#else
    k = key_start++;
#endif
      // XXX: if we are testing without insertions, make sure to pick CRC as
      // the hashing mechanism to have reduced overhead
      uint64_t hash_val = hasher(&k, sizeof(k));
      cons_id = hash_to_cpu(hash_val, n_cons);

      auto *q = queues[cons_id];
      // k has the computed hash in upper 32 bits
      // and the actual key value in lower 32 bits
      k |= (hash_val << 32);
      // *((uint64_t *)&kmers[i].data) = k;
    retry:
      if (enqueue(q, (data_t)k) != SUCCESS) {
        // At some point, we decided to retry immediately.
        // XXX: This could turn into an infinite loop in some corner cases
        q->qstats->num_enq_failures++;
        goto retry;
      }

      if (1) {
        auto q = queues[get_next_cons(1)];
        // 8 data_t elements per cacheline
        if ((Q_HEAD & 7) == 0) {
          auto new_head = (Q_HEAD + 16) & (QUEUE_SIZE - 1);
          __builtin_prefetch(&q->data[new_head], 1, 3);
        }
      }
      transaction_id++;
#ifdef CALC_STATS
      if (transaction_id % (HT_TESTS_NUM_INSERTS * n_cons / 10) == 0) {
        PLOG_INFO.printf(
            "[prod:%u] transaction_id %lu | num_messages %lu (enq failures %u)",
            this_prod_id, transaction_id, num_messages,
            q->qstats->num_enq_failures);
      }
#endif
#if !defined(BQ_TESTS_DO_HT_INSERTS)
    }
#endif

#if !defined(BQ_TESTS_DO_HT_INSERTS)
    /*if (++cons_id >= n_cons) {
      cons_id = 0;
    }*/

    {
      // auto q = queues[get_next_cons(1)];
      //  __builtin_prefetch(&q->data[Q_HEAD], 1, 3);
      //__builtin_prefetch(&q->data[Q_HEAD + 8], 1, 3);
    }
    // prefetch_queue(queues[get_next_cons(2)]);
    // prefetch_queue_data(queues[get_next_cons(1)], true);
#endif
  }

#ifdef WITH_VTUNE_LIB
  __itt_event_end(event);
#endif

  for (auto i = 0u; i < n_cons; ++i) {
    auto *q = queues[i];
    PLOG_INFO.printf("[prod:%u] q[%d] enq_failures %u", this_prod_id, i,
                     q->qstats->num_enq_failures);
  }

  // enqueue halt messages and the consumer automatically knows
  // when to stop
  for (cons_id = 0; cons_id < n_cons; cons_id++) {
    auto *q = queues[cons_id];
    Q_BACKTRACK_FLAG = 1;
    while (enqueue(q, (data_t)BQ_MAGIC_64BIT) != SUCCESS)
      ;
    PLOG_DEBUG.printf(
        "q %p Prod %d Sending END message to cons %d (transaction %u)", q,
        this_prod_id, cons_id, transaction_id);
    transaction_id++;
  }
  PLOG_DEBUG.printf("Producer %d -> Sending end messages to all consumers",
                    this_prod_id);
  // main thread will also increment this
  fipc_test_FAI(completed_producers);

  std::stringstream stream{};
  stream << "[";
  auto first = true;
  for (auto n : hist) {
    if (!first) stream << ", ";

    stream << n;
    first = false;
  }

  stream << "]";
  PLOG_INFO.printf("Producer %d histogram: %s", tid, stream.str().c_str());
}

thread_local std::vector<unsigned int> hash_histogram(histogram_buckets);

void BQueueTest::consumer_thread(const uint32_t tid, const uint32_t n_prod,
                                 const uint32_t n_cons,
                                 const uint32_t num_nops) {
  // Get shard pointer from the shards array
  Shard *sh = &this->shards[tid];

  // Allocate memory for stats
  sh->stats =
      //(thread_stats *)std::aligned_alloc(CACHE_LINE_SIZE,
      // sizeof(thread_stats));
      (thread_stats *)calloc(1, sizeof(thread_stats));

  std::uint64_t count{};
  BaseHashTable *kmer_ht = NULL;
  uint8_t finished_producers = 0;
  alignas(64) uint64_t k = 0;
  uint64_t transaction_id = 0;
  uint32_t prod_id = 0;
  // TODO: Pass producer_count similar to how we pass cons_count in
  // producer thread, instead of referring to global producer_count
  uint8_t this_cons_id = sh->shard_idx - n_prod;
  queue_t *queues[n_prod];
  uint64_t inserted = 0u;

#ifdef WITH_VTUNE_LIB
  std::string thread_name("consumer_thread" + std::to_string(tid));
  PLOG_VERBOSE.printf("thread_name %s", thread_name.c_str());
  __itt_thread_set_name(thread_name.c_str());
#endif

  // initialize the local queues array from queue_map
  for (auto i = 0u; i < n_prod; i++) {
    queues[i] = queue_map.at(std::make_tuple(i, this_cons_id));
    PLOG_DEBUG.printf("[cons:%u] q[%d] -> %p", this_cons_id, i, queues[i]);
  }

  // bq_kmer[BQ_TESTS_BATCH_LENGTH*n_cons];

  PLOG_DEBUG.printf(
      "[cons:%u] init_ht id:%d size:%u", this_cons_id, sh->shard_idx,
      HT_TESTS_HT_SIZE * (cfg->n_prod + cfg->n_cons) / cfg->n_cons);

  [[maybe_unused]] auto [ratio, num_messages, key_start] =
      get_params(n_prod, n_cons, tid);

  kmer_ht = init_ht(HT_TESTS_HT_SIZE * ratio, sh->shard_idx);
  (*this->ht_vec)[tid] = kmer_ht;

  fipc_test_FAI(ready_consumers);
  while (!test_ready) fipc_test_pause();
  fipc_test_mfence();

  PLOG_DEBUG.printf("[cons:%u] starting", this_cons_id);

#ifdef WITH_VTUNE_LIB
  static const auto event =
      __itt_event_create("message_dequeue", strlen("message_dequeue"));
  __itt_event_start(event);
#endif

  auto t_start = RDTSC_START();

  // Round-robin between 0..n_prod
  prod_id = 0;

  while (finished_producers < n_prod) {
    auto *q = queues[prod_id];

    auto get_next_prod = [&](auto inc) {
      auto next_prod_id = prod_id + inc;
      if (next_prod_id >= n_prod) next_prod_id -= n_prod;
      return next_prod_id;
    };

    auto submit_batch = [&](auto num_elements) {
      KeyPairs kp = std::make_pair(num_elements, &_items[0]);

      // TODO: Revisit after enabling HT_INSERTS
      // prefetch_queue(q[get_next_prod(2)]);
      // prefetch_queue_data(q[get_next_prod(1)], false);

      kmer_ht->insert_batch(kp);
      inserted += kp.first;

      data_idx = 0;
    };

    if constexpr (bq_load == BQUEUE_LOAD::HtInsert) {
      kmer_ht->prefetch_queue(QueueType::insert_queue);
    }

    for (auto i = 0u; i < 1 * BQ_TESTS_BATCH_LENGTH_CONS; i++) {
      // dequeue one message
      auto dequeue_status = SUCCESS;
      if ((dequeue_status = dequeue(q, (data_t *)&k)) != SUCCESS) {
        /* move on to next producer queue to dequeue */
        q->qstats->num_deq_failures++;

        if constexpr (bq_load == BQUEUE_LOAD::HtInsert) {
          if (data_idx > 0) {
            submit_batch(data_idx);
          }
        }
        goto pick_next_msg;
      }
      // PLOG_INFO.printf("%s[%d], dequeing from q[%d] = %p\n", __func__,
      // this_cons_id, prod_id, queues[prod_id]);

      //++count;

      // prefetching logic to prefetch the data array elements
      if (dequeue_status == SUCCESS) {
        // auto q = queues[get_next_prod(2)];

        if ((Q_TAIL & 7) == 0) {
          auto new_tail = (Q_TAIL + 16) & (QUEUE_SIZE - 1);
          __builtin_prefetch(&q->data[new_tail], 1, 3);
        }
        //__builtin_prefetch(q->cons_metadata, 1, 3);
      }

      // stop condition. On receiving this magic message, the consumers stop
      // dequeuing from the queues
      if ((data_t)k == BQ_MAGIC_64BIT) {
        fipc_test_FAI(finished_producers);
        PLOG_DEBUG.printf(
            "Consumer %u, received HALT from prod_id %u. "
            "finished_producers :%u",
            this_cons_id, prod_id, finished_producers);

        PLOG_DEBUG.printf("Consumer experienced %" PRIu64 " reprobes, %" PRIu64
                          " soft",
                          kmer_ht->num_reprobes, kmer_ht->num_soft_reprobes);

        PLOG_DEBUG.printf("Consumer received %" PRIu64, count);
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
      if (transaction_id % (HT_TESTS_NUM_INSERTS * n_cons / 10) == 0) {
        PLOG_INFO.printf("[cons:%u] transaction_id %lu", this_cons_id,
                         transaction_id);
      }
#endif
    }
  pick_next_msg:
    // reset the value of k
    // incase if the next dequeue fails, we will have a stale value of k
    k = 0;
    if (++prod_id >= n_prod) {
      prod_id = 0;
    }
  }

  auto t_end = RDTSCP();

  std::stringstream stream{};
  stream << "Hash buckets: [";
  auto first = true;
  for (auto n : hash_histogram) {
    if (!first) stream << ", ";
    stream << n;
    first = false;
  }

  stream << "]\n";
  PLOG_INFO.printf("%s", stream.str().c_str());

#ifdef WITH_VTUNE_LIB
  __itt_event_end(event);
#endif
  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = transaction_id;
  get_ht_stats(sh, kmer_ht);

  for (auto i = 0u; i < n_prod; ++i) {
    auto *q = queues[i];
    PLOG_INFO.printf("[cons:%u] q[%d] deq_failures %u", this_cons_id, i,
                     q->qstats->num_deq_failures);
  }

  PLOG_INFO.printf("cons_id %d | inserted %lu elements", this_cons_id,
                   inserted);
  PLOG_INFO.printf(
      "Quick Stats: Consumer %u finished, receiving %lu messages "
      "(cycles per message %lu) prod_count %u | finished %u",
      this_cons_id, transaction_id, (t_end - t_start) / transaction_id, n_prod,
      finished_producers);

  // Write to file
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
  Shard *sh = &this->shards[tid];
  uint64_t found = 0, not_found = 0;
  uint64_t count = HT_TESTS_NUM_INSERTS * tid;
  BaseHashTable *ktable;
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
    // Both producer and consumer threads participate in find. However, the
    // producer threads do not have any <k,v> pairs to find. So, they queue the
    // find request to the actual partitions which hosts these keys.
    // Nevertheless, they need this ktable object to queue the find requests to
    // other partitions. So, just create a HT with 100 buckets.
    ktable = init_ht(100, sh->shard_idx);
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
  auto ratio = static_cast<double>(n_prod / n_cons) + 1;
  auto num_messages = HT_TESTS_NUM_INSERTS * ratio;
  uint64_t key_start =
      std::max(static_cast<uint64_t>(num_messages) * tid, (uint64_t)1);

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

  int partition;
  int j = 0;

  auto t_start = RDTSC_START();

  for (auto i = 0u; i < HT_TESTS_NUM_INSERTS; i++) {
    k = key_start++;
    uint64_t hash_val = hasher(&k, sizeof(k));

    partition = hash_to_cpu(k, n_cons);
    // k has the computed hash in upper 32 bits
    // and the actual key value in lower 32 bits
    k |= (hash_val << 32);

    items[j].key = k;
    items[j].id = count;
    items[j].part_id = partition + n_prod;
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
    // if (transaction_id % (HT_TESTS_NUM_INSERTS * n_cons / 10) == 0) {
    //   PLOG_INFO.printf("Producer %u, transaction_id %lu\n", this_prod_id,
    //          transaction_id);
    // }
#endif
  }
  auto t_end = RDTSCP();

  sh->stats->find_cycles = (t_end - t_start);
  sh->stats->num_finds = found;

  if (found > 0) {
    PLOG_INFO.printf("thread %u | num_finds %lu | cycles per get: %lu\n",
                     sh->shard_idx, found, (t_end - t_start) / found);
  }

  get_ht_stats(sh, ktable);
}

void BQueueTest::init_queues(uint32_t nprod, uint32_t ncons) {
  // Queue Allocation
  queue_t *queues = (queue_t *)utils::zero_aligned_alloc(
      FIPC_CACHE_LINE_SIZE, nprod * ncons * sizeof(queue_t));

  // allocate queue stats
  queue_stats_t *qstats = (queue_stats_t *)utils::zero_aligned_alloc(
      FIPC_CACHE_LINE_SIZE, nprod * ncons * sizeof(queue_stats_t));

  // map queues and producer_metadata
  for (auto p = 0u; p < nprod; p++) {
#ifdef CONFIG_ALIGN_BQUEUE_METADATA
    prod_metadata_t *pmetadata = (prod_metadata_t *)utils::zero_aligned_alloc(
        FIPC_CACHE_LINE_SIZE, ncons * sizeof(prod_metadata_t));
#endif
    for (auto c = 0u; c < ncons; c++) {
      queue_t *q = &queues[p * ncons + c];
      q->qstats = &qstats[p * ncons + c];
#ifdef CONFIG_ALIGN_BQUEUE_METADATA
      // p0c0 | p0c1 .. p0cn | align | p1c0 .. p1cn | align | pmc0 .. pmcn |
      q->prod_metadata = &pmetadata[c];
#endif
      qstats_map.insert({std::make_tuple(p, c), q->qstats});
      queue_map.insert({std::make_tuple(p, c), q});
    }
  }

#ifdef CONFIG_ALIGN_BQUEUE_METADATA
  // map queues and consumer_metadata
  for (auto c = 0u; c < ncons; c++) {
    cons_metadata_t *cmetadata = (cons_metadata_t *)utils::zero_aligned_alloc(
        FIPC_CACHE_LINE_SIZE, nprod * sizeof(cons_metadata_t));
    // c0p0 | c0p1 .. c0pn | align | c1p0 .. c1pn | align | cmp0 .. cmpn |
    for (auto p = 0u; p < nprod; p++) {
      queue_t *q = &queues[p * ncons + c];
      q->cons_metadata = &cmetadata[p];
    }
  }
#endif

  // initialize all the queues
  for (auto i = 0u; i < nprod * ncons; ++i) {
    queue_t *q = &queues[i];
    PLOG_VERBOSE << "&queues[i] = " << q;
    init_queue(&queues[i]);
  }
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
      PLOG_INFO.printf("no_bqueues thread %u, transaction_id %lu",
                       sh->shard_idx, transaction_id);
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
  // this->run_find_test(cfg, n, npq);
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
    PLOG_VERBOSE.printf("Running master thread with id %d", main_sh->shard_idx);
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

  // Calculate total threads (Prod + cons)
  cfg->num_threads = cfg->n_prod + cfg->n_cons;

  // bail out if n_prod + n_cons > num_cpus
  if (this->cfg->n_prod + this->cfg->n_cons > num_cpus) {
    PLOG_ERROR.printf(
        "producers (%u) + consumers (%u) exceeded number of "
        "available CPUs (%u)",
        this->cfg->n_prod, this->cfg->n_cons, num_cpus);
    exit(-1);
  }

  producer_count = cfg->n_prod;
  consumer_count = cfg->n_cons;

  PLOG_DEBUG.printf("Controller starting ... nprod: %u, ncons: %u", cfg->n_prod,
                    cfg->n_cons);

  // alloc shards array
  this->shards = (Shard *)calloc(sizeof(Shard), cfg->num_threads);

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
    PLOG_DEBUG.printf("Thread producer_thread: %u, affinity: %u", i,
                      assigned_cpu);
    i += 1;
  }

  PLOG_DEBUG.printf("creating cons threads i %d ", i);
  Shard *main_sh = &this->shards[i];
  main_sh->shard_idx = i;
  CPU_ZERO(&cpuset);
  uint32_t last_cpu = 0;
  CPU_SET(last_cpu, &cpuset);
  sched_setaffinity(0, sizeof(cpu_set_t), &cpuset);
  PLOG_DEBUG.printf("Thread 'controller': affinity: %u", last_cpu);

  // Spawn consumer threads
  i = cfg->n_prod;
  for (auto assigned_cpu : this->npq->get_assigned_cpu_list_consumers()) {
    PLOG_DEBUG.printf("i %d assigned cpu %d", i, assigned_cpu);

    Shard *sh = &this->shards[i];
    sh->shard_idx = i;

    auto _thread = std::thread(&BQueueTest::consumer_thread, this, i,
                               cfg->n_prod, cfg->n_cons, cfg->num_nops);

    CPU_ZERO(&cpuset);
    CPU_SET(assigned_cpu, &cpuset);

    pthread_setaffinity_np(_thread.native_handle(), sizeof(cpu_set_t), &cpuset);

    PLOG_DEBUG.printf("Thread consumer_thread: %u, affinity: %u", i,
                      assigned_cpu);

    this->cons_threads.push_back(std::move(_thread));
    i += 1;
    j += 1;
  }

  {
    PLOG_DEBUG.printf("Running master thread with id %d", main_sh->shard_idx);
    this->producer_thread(main_sh->shard_idx, cfg->n_prod, cfg->n_cons, true,
                          cfg->skew);
  }

  // Wait for producers to complete
  while (completed_producers < cfg->n_prod) fipc_test_pause();

  fipc_test_mfence();

  // Wait for consumers to complete
  while (completed_consumers < cfg->n_cons) fipc_test_pause();

  fipc_test_mfence();

  for (auto &th : this->prod_threads) {
    th.join();
  }

  for (auto &th : this->cons_threads) {
    th.join();
  }

  this->prod_threads.clear();
  this->cons_threads.clear();

  // TODO free everything
  // TODO: Move this stats to find after testing find
  print_stats(this->shards, *cfg);
}

}  // namespace kmercounter
