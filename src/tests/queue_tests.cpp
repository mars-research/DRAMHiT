#include <algorithm>
#include <cassert>
#include <cinttypes>
#include <tuple>

#include "fastrange.h"
#include "hasher.hpp"
#include "hashtables/ht_helper.hpp"
#include "hashtables/simple_kht.hpp"
#include "helper.hpp"
#include "input_reader/csv.hpp"
#include "input_reader/eth_rel_gen.hpp"
#include "input_reader/fastq.hpp"
#include "misc_lib.h"
#include "print_stats.h"
#include "queues/bqueue_aligned.hpp"
#include "queues/lynxq.hpp"
#include "queues/section_queues.hpp"
#include "sync.h"
#include "tests/QueueTest.hpp"
#include "utils/hugepage_allocator.hpp"
#include "utils/vtune.hpp"
#include "xorwow.hpp"
#include "zipf.h"
#include "zipf_distribution.hpp"

#define PGROUNDDOWN(x) (x & ~(PAGESIZE - 1))

namespace kmercounter {

using namespace std;

const uint64_t CACHELINE_SIZE = sysconf(_SC_LEVEL1_DCACHE_LINESIZE);
const uint64_t CACHELINE_MASK = CACHELINE_SIZE - 1;
const uint64_t PAGESIZE = sysconf(_SC_PAGESIZE);

void setup_signal_handler(void);

extern uint64_t HT_TESTS_HT_SIZE;
extern uint64_t HT_TESTS_NUM_INSERTS;

// Test Variables
[[maybe_unused]] static uint64_t transactions = 100000000;

// for synchronization of threads
static uint64_t ready = 0;
static uint64_t ready_threads = 0;

extern BaseHashTable *init_ht(uint64_t, uint8_t);
extern void get_ht_stats(Shard *, BaseHashTable *);

struct bq_kmer {
  char data[KMER_DATA_LENGTH];
} __attribute__((aligned(64)));

// thread-local since we have multiple consumers
static __thread int data_idx = 0;
auto get_ht_size = [](int ncons) {
  uint64_t ht_size = config.ht_size / ncons;
  if (ht_size & 0x3) {
    ht_size = ht_size + 4 - (ht_size % 4);
  }
  return ht_size;
};

std::vector<key_type, huge_page_allocator<key_type>> *zipf_values;

void init_zipfian_dist(double skew, int64_t seed) {
  std::uint64_t keyrange_width = (1ull << 63);
  if constexpr (std::is_same_v<key_type, std::uint32_t>) {
    keyrange_width = (1ull << 31);
  }

  //zipf_values = new std::vector<key_type, huge_page_allocator<key_type>>(config.ht_size);
  zipf_values = new std::vector<key_type, huge_page_allocator<key_type>>(HT_TESTS_NUM_INSERTS); //old zipf test

  std::stringstream cache_name{};
  cache_name << "/opt/dramhit/cache" << config.skew << "_" << config.ht_size << "_" << config.ht_fill << ".bin";
  std::ifstream cache{cache_name.str().c_str()};

  PLOG_INFO << cache_name.str() << " " << cache.is_open();
  if (cache.is_open()) {
    cache.read(reinterpret_cast<char *>(zipf_values->data()),
               zipf_values->size() * sizeof(key_type));
    cache.close();
  } else {
    zipf_distribution_apache distribution(keyrange_width, skew, seed);
    PLOGI.printf("Initializing global zipf with skew %f, seed %ld", skew, seed);

    for (auto &value : *zipf_values) {
      value = distribution.sample();
    }
    PLOGI.printf("Zipfian dist generated. size %zu", zipf_values->size());
    std::ofstream cache_out{cache_name.str().c_str()};
    cache_out.write(reinterpret_cast<char *>(zipf_values->data()),
                    zipf_values->size() * sizeof(key_type));
    cache_out.close();
  }
}

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
  auto ratio = static_cast<double>(n_prod) / n_cons + 1;

  auto num_messages = HT_TESTS_NUM_INSERTS / n_prod;
  // our HT has a notion of empty keys which is 0. So, no '0' key for now!
  uint64_t key_start =
      std::max(static_cast<uint64_t>(num_messages) * tid, (uint64_t)1);

  if (tid == (n_prod - 1)) {
    num_messages += HT_TESTS_NUM_INSERTS % n_prod;
  }
  return std::make_tuple(ratio, num_messages, key_start);
}

static auto hash_to_cpu(std::uint32_t hash, unsigned int count) {
  return fastrange32(_mm_crc32_u32(0xffffffff, hash), count);
};

static auto get_current_node() { return numa_node_of_cpu(sched_getcpu()); };

static auto mbind_buffer_local(void *buf, ssize_t sz) {
  unsigned long nodemask[4096] = {0};
  ssize_t page_size = sysconf(_SC_PAGESIZE);
  nodemask[0] = 1 << get_current_node();
  PLOGV.printf("nodemask %x", nodemask[0]);
  long ret = mbind(buf, std::max(sz, page_size), MPOL_BIND, nodemask, 4096,
                   MPOL_MF_MOVE | MPOL_MF_STRICT);
  if (ret < 0) {
    PLOGE.printf("mbind failed! ret %d (errno %d)", ret, errno);
  }
  return ret;
}


std::barrier<std::function<void()>> *prod_barrier;
uint64_t g_rw_start, g_rw_end;
std::vector<cacheline> toxic_waste_dump(1024 * 1024 * 1024 / sizeof(cacheline));

template <typename T>
void QueueTest<T>::producer_thread(
    const uint32_t tid, const uint32_t n_prod, const uint32_t n_cons,
    const bool main_thread, const double skew, bool is_join,
    std::barrier<std::function<void()>> *barrier) {
  // Get shard pointer from the shards array
  Shard *sh = &this->shards[tid];

  // Allocate memory for stats
  sh->stats = (thread_stats *)calloc(1, sizeof(thread_stats));
  alignas(64) uint64_t k = 0;

  uint8_t this_prod_id = sh->shard_idx;
  uint32_t cons_id = 0;
  uint64_t transaction_id{};
  typename T::prod_queue_t *pqueues[n_cons];
  typename T::cons_queue_t *cqueues[n_cons];

  vtune::set_threadname("producer_thread" + std::to_string(tid));

  auto [ratio, num_messages, key_start] = get_params(n_prod, n_cons, tid);
  Hasher hasher;
#define CONFIG_NUMA_AFFINITY

  for (auto i = 0u; i < n_cons; i++) {
    pqueues[i] = &this->queues->all_pqueues[this_prod_id][i];
#ifdef CONFIG_NUMA_AFFINITY
    mbind_buffer_local((void *)PGROUNDDOWN((uint64_t)pqueues[i]),
                       sizeof(typename T::prod_queue_t));
    // mbind_buffer_local(pqueues[i]->data, this->queues->queue_size);
#endif
  }

  struct xorwow_state _xw_state, init_state;
  auto key_start_orig = key_start;

#if defined(BQ_TESTS_INSERT_ZIPFIAN_LOCAL)
#warning LOCAL ZIPFIAN
  constexpr auto keyrange_width = (1ull << 63);  // 192 * (1 << 20);
  zipf_distribution_apache distribution(keyrange_width, skew);

  std::vector<std::uint64_t> values(num_messages);
  for (auto &value : values) {
    value = distribution.sample();
  }
#endif

#if defined(XORWOW)
  xorwow_init(&_xw_state);
  init_state = _xw_state;
#endif
  static auto event = -1;
  static bool test_started = false;

  if (main_thread) {
    event = vtune::event_start("message_enq");
  }

#if 0
  input_reader::PartitionedEthRelationGenerator t1(
      "r.tbl", DEFAULT_R_SEED, config.relation_r_size, sh->shard_idx,
      n_prod, config.relation_r_size);
  input_reader::SizedInputReader<KeyValuePair>* r_table = &t1;
#endif

#if defined(BQUEUE_KMER_TEST)
#warning "BQ KMER TEST"
  auto reader = input_reader::MakeFastqKMerPreloadReader(
      config.K, config.in_file, sh->shard_idx, n_prod);
#endif

  // PLOGD.printf("sh->shard_idx %d, n_prod %d config.relation_r_size %llu
  // r_table size %d",
  //     sh->shard_idx, n_prod, config.relation_r_size, r_table->size());

  std::function<void()> on_completion = []() noexcept {
    if (!test_started) {
      g_rw_start = RDTSC_START();
      test_started = true;
      PLOG_INFO << "Producers synchronized after pre-inserts";
    } else {
      g_rw_end = RDTSCP();
      PLOGI.printf("producers took %llu cycles", g_rw_end - g_rw_start);
    }
  };

  if (tid == 0) {
    prod_barrier = new std::barrier(config.n_prod, on_completion);
  }
  std::size_t next_pollution{};

  barrier->arrive_and_wait();

  PLOGV.printf(
      "[prod:%u] started! Sending %lu messages to %d consumers | "
      "key_start %lu key_end %lu",
      this_prod_id, num_messages, n_cons, key_start, key_start + num_messages);

  auto get_next_cons = [&](auto inc) {
    auto next_cons_id = cons_id + inc;
    if (next_cons_id >= n_cons) next_cons_id = 0;
    return next_cons_id;
  };

  key_start = key_start_orig;
  auto zipf_idx = key_start == 1 ? 0 : key_start;
  for (transaction_id = 0u; transaction_id < num_messages * cfg->rw_queues;) {
    k = zipf_values->at(zipf_idx);
    ++zipf_idx;
    uint64_t hash_val = hasher(&k, sizeof(k));
    cons_id = hash_to_cpu(hash_val, n_cons);
    auto pq = pqueues[cons_id];
    this->queues->enqueue(pq, this_prod_id, cons_id, {k, k});
    transaction_id++;
  }

  auto ht_size = config.ht_size / n_cons;
  const auto ktable = init_ht(ht_size, sh->shard_idx);
  this->ht_vec->at(tid) = ktable;

  std::bernoulli_distribution coin{config.pread};
  xorwow_urbg urbg{};
  std::array<bool, 1024> flips;
  for (auto &flip : flips) flip = !coin(urbg);  // do a write if true

  prod_barrier->arrive_and_wait();

#if defined(BQUEUE_KMER_TEST)
  Key kv{};
#else
  KeyValuePair kv{};
#endif
  auto t_start = RDTSC_START();
  // std::uint64_t num_kmers{};

#ifdef LATENCY_COLLECTION
  auto &collector = collectors.at(tid);
#endif

  for (auto j = 0u; j < config.insert_factor; j++) {
    key_start = key_start_orig;
    auto zipf_idx = key_start == 1 ? 0 : key_start;
    std::uint64_t kmer{};
#if defined(XORWOW)
    _xw_state = init_state;
#endif

    auto next_item = 0u;
    auto item_id = 0u;
    std::array<InsertFindArgument, HT_TESTS_FIND_BATCH_LENGTH> items{};

#if defined(BQUEUE_KMER_TEST)
    for (; reader->next(&kmer);) {
#else
    for (transaction_id = 0u; transaction_id < num_messages;) {
#endif
      if (is_join) {
        // num_kmers++;
        kv.key = k = kmer;
        #if !defined(BQUEUE_KMER_TEST)
            kv.value = 0;
        #endif
      } else {
#if defined(XORWOW)
#warning "Xorwow rand kmer insert"
      const auto value = xorwow(&_xw_state);
      k = value;
      kv = data_t(value, value);

#elif defined(BQ_TESTS_INSERT_ZIPFIAN)
#warning "Zipfian insertion"
        if (!(zipf_idx & 7) && zipf_idx + 16 < zipf_values->size())
          prefetch_object<false>(&zipf_values->at(zipf_idx + 16), 64);

      k = zipf_values->at(zipf_idx);
      kv = data_t(k, k);
      //PLOGV.printf("zipf_values[%" PRIu64 "] = %" PRIu64, zipf_idx, k);
      zipf_idx++;
#elif defined(BQ_TESTS_INSERT_ZIPFIAN_LOCAL)
      k = values.at(transaction_id);
#else
      k = key_start++;
      kv = data_t(k, k);
#endif
      }
      // XXX: if we are testing without insertions, make sure to pick CRC as
      // the hashing mechanism to have reduced overhead
      uint64_t hash_val = hasher(&k, sizeof(k));
      cons_id = hash_to_cpu(hash_val, n_cons);

      if (!cfg->rw_queues || flips[transaction_id & 1023]) {  // TODO
#if defined(BQ_KEY_UPPER_BITS_HAS_HASH)
        // k has the computed hash in upper 32 bits
        // and the actual key value in lower 32 bits
        kv.key |= (hash_val << 32);
#endif
        // if (++cons_id >= n_cons) cons_id = 0;

        auto pq = pqueues[cons_id];
        // PLOGV.printf("Queuing key = %" PRIu64 ", value = %" PRIu64, kv.key,
        // kv.value);
#ifdef LATENCY_COLLECTION
        const auto timer = collector.sync_start();
#endif
        this->queues->enqueue(pq, this_prod_id, cons_id, (data_t)kv);
#ifdef LATENCY_COLLECTION
        collector.sync_end(timer);
#endif
        auto npq = pqueues[get_next_cons(1)];

        this->queues->prefetch(this_prod_id, get_next_cons(1), true);
      } else {
        auto &item = items[next_item];
        items[next_item].key = k;
        items[next_item].id = item_id++;
        items[next_item].part_id = cons_id + n_prod;
        if (next_item == 0) ktable->prefetch_queue(QueueType::find_queue);

        ++next_item;
        if (next_item == HT_TESTS_FIND_BATCH_LENGTH) {
          next_item = 0;
          InsertFindArguments kp{items};
          std::array<FindResult, HT_TESTS_FIND_BATCH_LENGTH> results{};
          ValuePairs vp{0, results.data()};
          ktable->find_batch(kp, vp, nullptr);
        }
      }

      for (auto p = 0u; p < config.pollute_ratio; ++p)
        prefetch_object<true>(
            &toxic_waste_dump[next_pollution++ & (1024 * 1024 - 1)], 64);

      transaction_id++;
    }
  }

  // enqueue halt messages and the consumer automatically knows
  // when to stop
  for (cons_id = 0; cons_id < n_cons; cons_id++) {
    this->queues->push_done(this_prod_id, cons_id);

    PLOG_DEBUG.printf("Prod %d Sending END message to cons %d (transaction %u)",
                      this_prod_id, cons_id, transaction_id);
    transaction_id++;
  }

  auto t_end = RDTSCP();

  prod_barrier->arrive_and_wait();

  if (main_thread) {
    vtune::event_end(event);
  }

  if (cfg->rw_queues) {
    sh->stats->finds.duration = (t_end - t_start);
    sh->stats->finds.op_count = transaction_id * config.insert_factor;
  } else {
    sh->stats->enqueues.duration = (t_end - t_start);
    sh->stats->enqueues.op_count = transaction_id * config.insert_factor;
  }

#ifdef LATENCY_COLLECTION
  collector.dump("sync_insert", tid);
#endif

  PLOG_DEBUG.printf("Producer %d -> Sending end messages to all consumers",
                    this_prod_id);
}

template <typename T>
void QueueTest<T>::consumer_thread(
    const uint32_t tid, const uint32_t n_prod, const uint32_t n_cons,
    const uint32_t num_nops, std::barrier<std::function<void()>> *barrier) {
  // Get shard pointer from the shards array
  Shard *sh = &this->shards[tid];

#ifdef LATENCY_COLLECTION
  const auto collector = &collectors.at(tid);
  collector->claim();
#else
  collector_type *const collector{};
#endif

  // Allocate memory for stats
  sh->stats =
      //(thread_stats *)std::aligned_alloc(CACHE_LINE_SIZE,
      // sizeof(thread_stats));
      (thread_stats *)calloc(1, sizeof(thread_stats));

  InsertFindArgument *items =
      (InsertFindArgument *) aligned_alloc(64, sizeof(InsertFindArgument) * config.batch_len);

  std::uint64_t count{};
  BaseHashTable *kmer_ht = NULL;
  uint8_t finished_producers = 0;
  // alignas(64)
  uint64_t k = 0;
#if defined(BQUEUE_KMER_TEST)
  Key kv{};
#else
  KeyValuePair kv{};
#endif
  uint64_t transaction_id = 0;
  uint32_t prod_id = 0;

  uint8_t this_cons_id = sh->shard_idx - n_prod;
  uint64_t inserted = 0u;
  typename T::cons_queue_t *cqueues[n_prod];

  // initialize the local queues array from queue_map
  for (auto i = 0u; i < n_prod; i++) {
    cqueues[i] = &this->queues->all_cqueues[this_cons_id][i];
#ifdef CONFIG_NUMA_AFFINITY
    mbind_buffer_local((void *)PGROUNDDOWN((uint64_t)cqueues[i]),
                       sizeof(typename T::cons_queue_t));
    // mbind_buffer_local(cqueues[i]->data, this->queues->queue_size);
#endif
  }
  vtune::set_threadname("consumer_thread" + std::to_string(tid));

  auto ht_size = get_ht_size(n_cons);

  if (bq_load == BQUEUE_LOAD::HtInsert) {
    PLOGV.printf("[cons:%u] init_ht id:%d size:%u", this_cons_id, sh->shard_idx,
                 ht_size);
    kmer_ht = init_ht(ht_size, sh->shard_idx);
    (*this->ht_vec)[tid] = kmer_ht;
  }

  barrier->arrive_and_wait();

  PLOG_DEBUG.printf("[cons:%u] starting", this_cons_id);

  unsigned int cpu, node;
  getcpu(&cpu, &node);

  PLOGV.printf("[cons:%u] starting tid %u | cpu %u", this_cons_id, gettid(),
               cpu);

  static auto event = -1;
  if (tid == n_prod) event = vtune::event_start("message_deq");

  auto t_start = RDTSC_START();

  // Round-robin between 0..n_prod
  prod_id = 0;

  uint64_t active_qmask = 0ull;

  for (auto i = 0u; i < n_prod; i++) {
    active_qmask |= (1ull << i);
  }

  while (finished_producers < n_prod) {
    auto submit_batch = [&](auto num_elements) {
      InsertFindArguments kp(items, num_elements);

      kmer_ht->insert_batch(kp, collector);
      inserted += kp.size();

      data_idx = 0;
    };

    auto get_next_prod = [&](auto inc) {
      auto next_prod_id = prod_id + inc;
      if (next_prod_id >= n_prod) next_prod_id = 0;
      return next_prod_id;
    };

    if (bq_load == BQUEUE_LOAD::HtInsert) {
      if (!config.no_prefetch) {
        kmer_ht->prefetch_queue(QueueType::insert_queue);
      }
    }
    auto cq = cqueues[prod_id];

    auto np1 = get_next_prod(1);
    this->queues->prefetch(np1, this_cons_id, false);

    if (!(active_qmask & (1ull << prod_id))) {
      goto pick_next_msg;
    }

    for (auto i = 0u; i < 1 * config.batch_len; i++) {
      // dequeue one message
      auto ret =
          this->queues->dequeue(cq, prod_id, this_cons_id, (data_t *)&kv);
      if (ret == RETRY) {
        if (bq_load == BQUEUE_LOAD::HtInsert) {
          if (!config.no_prefetch) {
            if (data_idx > 0) {
              submit_batch(data_idx);
            }
          }
        }
        goto pick_next_msg;
      }
      // PLOGV.printf("Dequeuing key = %" PRIu64 ", value = %" PRIu64, kv.key,
      // kv.value);
      /*
      IF_PLOG(plog::verbose) {
        PLOG_VERBOSE.printf("dequeing from q[%d][%d] value %" PRIu64 "",
                    prod_id, this_cons_id, k & ((1 << 31) - 1));
      }*/
      ++count;

      // STOP condition. On receiving this magic message, the consumers stop
      // dequeuing from the queues
      if ((data_t)kv == T::BQ_MAGIC_KV) [[unlikely]] {
        fipc_test_FAI(finished_producers);
        // printf("Got MAGIC bit. stopping consumer\n");
        this->queues->pop_done(prod_id, this_cons_id);
        active_qmask &= ~(1ull << prod_id);
        /* PLOGV.printf(
            "Consumer %u, received HALT from prod_id %u. "
            "finished_producers :%u",
            this_cons_id, prod_id, finished_producers);
            */
#ifdef CALC_STATS
        PLOG_DEBUG.printf("Consumer experienced %" PRIu64 " reprobes, %" PRIu64
                          " soft",
                          kmer_ht->num_reprobes, kmer_ht->num_soft_reprobes);
#endif

        PLOG_DEBUG.printf("Consumer received %" PRIu64, count);
        if (!config.no_prefetch) {
          if (data_idx > 0) {
            submit_batch(data_idx);
          }
        }
        goto pick_next_msg;
      }

      if (bq_load == BQUEUE_LOAD::HtInsert) {
        items[data_idx].key = kv.key;
        items[data_idx].id = kv.key;
        //PLOGV.printf("sizeof items %zu | size of kv.key %zu",
        //          sizeof(_items[data_idx].key), sizeof(kv.key));
        //_items[data_idx].value = k & 0xffffffff;
#if !defined(BQUEUE_KMER_TEST)
        items[data_idx].value = kv.value;
#endif

        // for (auto i = 0u; i < num_nops; i++) asm volatile("nop");

        if (config.no_prefetch) {
          //PLOGV.printf("Inserting key %" PRIu64, _items[data_idx].key);
          kmer_ht->insert_noprefetch(&items[data_idx], collector);
          inserted++;
        } else {
          if (++data_idx == config.batch_len) {
            submit_batch(config.batch_len);
          }
        }
      }

      transaction_id++;
#ifdef CALC_STATS
      /*if (transaction_id % (HT_TESTS_NUM_INSERTS * n_cons / 10) == 0) {
        PLOG_INFO.printf("[cons:%u] transaction_id %" PRIu64 " deq_failures %"
      PRIu64 "", this_cons_id, transaction_id, q->num_deq_failures);
      }*/
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

  if (tid == n_prod) vtune::event_end(event);

  sh->stats->insertions.duration = (t_end - t_start);
  sh->stats->insertions.op_count = transaction_id;

  if (bq_load == BQUEUE_LOAD::HtInsert) {
    get_ht_stats(sh, kmer_ht);
  }

  for (auto i = 0u; i < n_prod; ++i) {
    this->queues->dump_stats(i, this_cons_id);
  }
#ifdef CONFIG_ALIGN_BQUEUE_METADATA
  for (auto i = 0u; i < n_prod; ++i) {
    auto *q = cqueues[i];
    PLOG_INFO.printf("[cons:%u] q[%d] deq_failures %u", this_cons_id, i,
                     q->num_deq_failures);
  }
#endif

  PLOGV.printf("cons_id %d | inserted %lu elements", this_cons_id, inserted);
  PLOGV.printf(
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

#ifdef LATENCY_COLLECTION
  collector->dump("insert", tid);
#endif
}

template <typename T>
void QueueTest<T>::find_thread(int tid, int n_prod, int n_cons, bool is_join,
                               std::barrier<std::function<void()>> *barrier) {
  Shard *sh = &this->shards[tid];
  uint64_t found = 0, not_found = 0;
  uint64_t count = std::max(HT_TESTS_NUM_INSERTS * tid, (uint64_t)1);
  BaseHashTable *ktable;
  Hasher hasher;

#ifdef LATENCY_COLLECTION
  const auto collector = &collectors.at(tid);
  collector->claim();
#else
  collector_type *const collector{};
#endif

  struct xorwow_state _xw_state, init_state;

  xorwow_init(&_xw_state);
  init_state = _xw_state;

  alignas(64) uint64_t k = 0;

  vtune::set_threadname("find_thread" + std::to_string(tid));

  ktable = this->ht_vec->at(tid);

  if (ktable == nullptr) {
    // Both producer and consumer threads participate in find. However, the
    // producer threads do not have any <k,v> pairs to find. So, they queue the
    // find request to the actual partitions which hosts these keys.
    // Nevertheless, they need this ktable object to queue the find requests to
    // other partitions. So, just create a HT with 100 buckets.

    auto ht_size = get_ht_size(n_cons);
    PLOGV.printf("[find%u] init_ht ht_size: %u | id: %d", tid, ht_size,
                 sh->shard_idx);
    ktable = init_ht(ht_size, sh->shard_idx);
    this->ht_vec->at(tid) = ktable;
  } else {
    PLOGD.printf("Dist to nodes tid %u", tid);
    auto *part_ht = reinterpret_cast<PartitionedHashStore<KVType, ItemQueue>*>(ktable);
    void *ht_mem = part_ht->hashtable[part_ht->id];
    distribute_mem_to_nodes(ht_mem, part_ht->get_ht_size());
  }

  FindResult *results = new FindResult[config.batch_len];
#if 0
  input_reader::PartitionedEthRelationGenerator t2(
      "s.tbl", DEFAULT_S_SEED, config.relation_s_size, sh->shard_idx,
      n_prod + n_cons, config.relation_r_size);

  input_reader::SizedInputReader<KeyValuePair>* s_table = &t2;
#endif
  // barrier->arrive_and_wait();

  auto num_messages = HT_TESTS_NUM_INSERTS / (n_prod + n_cons);

  // our HT has a notion of empty keys which is 0. So, no '0' key for now!
  uint64_t key_start =
      std::max(static_cast<uint64_t>(num_messages) * tid, (uint64_t)1);

  InsertFindArgument *items =
      (InsertFindArgument *) aligned_alloc(64, sizeof(InsertFindArgument) * config.batch_len);

  ValuePairs vp = std::make_pair(0, results);

  PLOGV.printf("Finder %u starting. key_start %lu | num_messages %lu", tid,
               key_start, num_messages);

  int partition;
  int j = 0;

  barrier->arrive_and_wait();

  static const auto event = vtune::event_start("find_batch");

  std::size_t next_pollution{};
  auto t_start = RDTSC_START();

  for (auto m = 0u; m < config.insert_factor; m++) {
    key_start =
        std::max(static_cast<uint64_t>(num_messages) * tid, (uint64_t)1);
    auto zipf_idx = key_start == 1 ? 0 : key_start;
#if defined(XORWOW)
    _xw_state = init_state;
#endif
    for (auto i = 0u; i < num_messages; i++) {
      if (is_join) {
#if 0
        KeyValuePair kv;
        s_table->next(&kv);
        k = kv.key;
#endif
      } else {
#if defined(XORWOW)
        k = xorwow(&_xw_state);
#elif defined(BQ_TESTS_INSERT_ZIPFIAN)
#warning "Zipfian finds"
        if (!(zipf_idx & 7) && zipf_idx + 16 < zipf_values->size())
          prefetch_object<false>(&zipf_values->at(zipf_idx + 16), 64);

        k = zipf_values->at(zipf_idx);
        // PLOGV.printf("zipf_values[%" PRIu64 "] = %" PRIu64, zipf_idx, k);
        zipf_idx++;
#else
#warning "Monotonic counters"
        k = key_start++;
#endif
      }
      uint64_t hash_val = hasher(&k, sizeof(k));

      partition = hash_to_cpu(hash_val, n_cons);
      // PLOGI.printf("partition %d", partition);

#if defined(BQ_KEY_UPPER_BITS_HAS_HASH)
      // k has the computed hash in upper 32 bits
      // and the actual key value in lower 32 bits
      k |= (hash_val << 32);
#endif

      items[j].key = k;
      items[j].id = count;
      items[j].part_id = partition + n_prod;
      count++;

      if (!config.no_prefetch) {
        if (j == 0) {
          ktable->prefetch_queue(QueueType::find_queue);
        }
      }

      if (config.no_prefetch) {
        // PLOGV.printf("Finding key %llu", items[0].key);
        auto ret = ktable->find_noprefetch(&items[0], collector);
        // PLOGV.printf("Got key %lu, value %lu", item->kvpair.key,
        // item->kvpair.value);
        if (ret)
          found++;
        else {
          not_found++;
          // printf("key %" PRIu64 " not found | zipf_idx %" PRIu64 "\n", k,
          // zipf_idx - 1);
        }
      } else {
        if (++j == config.batch_len) {
          // PLOGI.printf("calling find_batch i = %d", i);
          // ktable->find_batch((InsertFindArgument *)items, HT_TESTS_FIND_BATCH_LENGTH);
          ktable->find_batch(InsertFindArguments(items, config.batch_len), vp, collector);
          found += vp.first;
          j = 0;
          not_found += config.batch_len - vp.first;
          vp.first = 0;
          // PLOGD.printf("tid %" PRIu64 " count %" PRIu64 " | found -> %"
          // PRIu64 " | not_found -> %" PRIu64 "", tid,
          //     count, found, not_found);

          for (auto p = 0u;
               p < config.pollute_ratio * HT_TESTS_FIND_BATCH_LENGTH; ++p)
            prefetch_object<true>(
                &toxic_waste_dump[next_pollution++ & (1024 * 1024 - 1)], 64);
        }
      }

    }
    if (!config.no_prefetch) {
      if (vp.first > 0) {
        vp.first = 0;
      }

      ktable->flush_find_queue(vp, collector);
      found += vp.first;
    }
  }
  auto t_end = RDTSCP();

  barrier->arrive_and_wait();

#ifdef CALC_STATS
  PLOG_INFO.printf(
      "Finder %u (found %" PRIu64 ", not_found %" PRIu64 ")", tid,
      found, not_found);
#endif

  vtune::event_end(event);

  sh->stats->finds.duration = (t_end - t_start);
  sh->stats->finds.op_count = found;

  if (found >= 0) {
    PLOGV.printf(
        "thread %u | num_finds %lu (not_found %lu) | cycles per get: %lu",
        sh->shard_idx, found, not_found,
        found > 0 ? (t_end - t_start) / found : 0);
  }

  get_ht_stats(sh, ktable);

#ifdef LATENCY_COLLECTION
  collector->dump("find", tid);
  PLOG_INFO << "Dumping find";
#endif
}

template <typename T>
void QueueTest<T>::init_queues(uint32_t nprod, uint32_t ncons) {
  PLOG_DEBUG.printf("Initializing queues");
  if (std::is_same<T, kmercounter::LynxQueue>::value) {
    this->QUEUE_SIZE = QueueTest::LYNX_QUEUE_SIZE;
  } else if (std::is_same<T, kmercounter::BQueueAligned>::value) {
    this->QUEUE_SIZE = QueueTest::BQ_QUEUE_SIZE;
  } else if (std::is_same<T, kmercounter::SectionQueue>::value) {
    this->QUEUE_SIZE = 4;
  }
  this->queues = new T(nprod, ncons, this->QUEUE_SIZE, this->npq);
}

template <typename T>
void QueueTest<T>::run_test(Configuration *cfg, Numa *n, bool is_join,
                            NumaPolicyQueues *npq) {
  const auto thread_count = cfg->n_prod + cfg->n_cons;
  this->ht_vec = new std::vector<BaseHashTable *>(thread_count, nullptr);

  std::chrono::time_point<std::chrono::steady_clock> start_ts, end_ts;

  start_ts = std::chrono::steady_clock::now();

#ifdef LATENCY_COLLECTION
  collectors.resize(thread_count);
#endif

  // 1) Insert using bqueues
  this->insert_with_queues(cfg, n, is_join, npq);

#ifdef LATENCY_COLLECTION
  collectors.clear();
  collectors.resize(thread_count);
#endif

  // HACK: Usually, we disable prefetching for smaller sized HTs. For some
  // unknown reason, we observed that inserts on casht++ with smaller
  // hashtables performed better when prefetching was turned on, but finds were
  // OK with the original config (prefetch = off). The weird hack was to enable
  // prefetching for insertions and turn it off for finds. Revisit this - vn
  // cfg->no_prefetch = 0;

  // Do a shuffle to redistribute the keys
  if (zipf_values) {
    auto rng = std::default_random_engine{};
    std::shuffle(std::begin(*zipf_values), std::end(*zipf_values), rng);
  }

  // 2) spawn n_prod + n_cons threads for find
  if (!is_join || cfg->rw_queues) this->run_find_test(cfg, n, is_join, npq);

  end_ts = std::chrono::steady_clock::now();

  PLOG_INFO.printf(
      "Kmer insertion took %llu us",
      chrono::duration_cast<chrono::microseconds>(end_ts - start_ts).count());
  print_stats(this->shards, *cfg);
}

template <typename T>
void QueueTest<T>::run_find_test(Configuration *cfg, Numa *n, bool is_join,
                                 NumaPolicyQueues *npq) {
  uint32_t i = 0, j = 0;
  cpu_set_t cpuset;
  bool started = false;
  uint64_t g_find_start = 0, g_find_end = 0;

  std::function<void()> on_completion = [&]() noexcept {
    if (!started) {
      PLOG_INFO << "Sync completed. Starting Find threads!";
      started = true;
      g_find_start = RDTSC_START();
    } else {
      g_find_end = RDTSCP();
      PLOGI.printf("Finds took %lu cycles", g_find_end - g_find_start);
    }
    // For debugging
  };

  std::barrier barrier(cfg->n_prod + cfg->n_cons, on_completion);

  // Spawn threads that will perform find operation
  for (uint32_t assigned_cpu : this->npq->get_assigned_cpu_list_producers()) {
    // skip the first CPU, we'll launch it later
    if (assigned_cpu == 0) continue;
    Shard *sh = &this->shards[i];
    sh->shard_idx = i;
    auto _thread = std::thread(&QueueTest::find_thread, this, i, cfg->n_prod,
                               cfg->n_cons, is_join, &barrier);
    CPU_ZERO(&cpuset);
    CPU_SET(assigned_cpu, &cpuset);
    pthread_setaffinity_np(_thread.native_handle(), sizeof(cpu_set_t), &cpuset);
    this->prod_threads.push_back(std::move(_thread));
    PLOGV.printf("Thread find_thread: %u, affinity: %u", i, assigned_cpu);
    i += 1;
  }

  PLOGV.printf("creating cons threads i %d ", i);
  Shard *main_sh = &this->shards[i];
  main_sh->shard_idx = i;
  CPU_ZERO(&cpuset);
  uint32_t last_cpu = 0;
  CPU_SET(last_cpu, &cpuset);
  sched_setaffinity(0, sizeof(cpu_set_t), &cpuset);
  PLOGV.printf("Thread 'controller': affinity: %u", last_cpu);

  // Spawn find threads
  i = cfg->n_prod;
  for (auto assigned_cpu : this->npq->get_assigned_cpu_list_consumers()) {
    PLOGV.printf("i %d assigned cpu %d", i, assigned_cpu);

    Shard *sh = &this->shards[i];
    sh->shard_idx = i;

    auto _thread = std::thread(&QueueTest::find_thread, this, i, cfg->n_prod,
                               cfg->n_cons, is_join, &barrier);

    CPU_ZERO(&cpuset);
    CPU_SET(assigned_cpu, &cpuset);

    pthread_setaffinity_np(_thread.native_handle(), sizeof(cpu_set_t), &cpuset);

    PLOGV.printf("Thread find_thread: %u, affinity: %u", i, assigned_cpu);
    PLOGV.printf("[%d] sh->insertion_cycles %lu", sh->shard_idx,
                 cycles_per_op(sh->stats->insertions));

    this->cons_threads.push_back(std::move(_thread));
    i += 1;
    j += 1;
  }

  {
    PLOG_VERBOSE.printf("Running master thread with id %d", main_sh->shard_idx);
    this->find_thread(main_sh->shard_idx, cfg->n_prod, cfg->n_cons, is_join,
                      &barrier);
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

template <class T>
void QueueTest<T>::insert_with_queues(Configuration *cfg, Numa *n, bool is_join,
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

  PLOG_DEBUG.printf(
      "Controller starting ... nprod: %u, ncons: %u (num_threads %u)",
      cfg->n_prod, cfg->n_cons, cfg->num_threads);

  // alloc shards array
  this->shards = (Shard *)calloc(sizeof(Shard), cfg->num_threads);

  // Init queues
  this->init_queues(cfg->n_prod, cfg->n_cons);

  std::function<void()> on_completion = []() noexcept {
    // For debugging
    PLOG_INFO << "Sync completed. Starting prod/cons threads!";
  };

  std::barrier barrier(cfg->n_prod + cfg->n_cons, on_completion);

  // Spawn producer threads
  for (uint32_t assigned_cpu : this->npq->get_assigned_cpu_list_producers()) {
    // skip the first CPU, we'll launch producer on this
    if (assigned_cpu == 0) continue;
    Shard *sh = &this->shards[i];
    sh->shard_idx = i;
    auto _thread =
        std::thread(&QueueTest<T>::producer_thread, this, i, cfg->n_prod,
                    cfg->n_cons, false, cfg->skew, is_join, &barrier);
    CPU_ZERO(&cpuset);
    CPU_SET(assigned_cpu, &cpuset);
    pthread_setaffinity_np(_thread.native_handle(), sizeof(cpu_set_t), &cpuset);
    this->prod_threads.push_back(std::move(_thread));
    PLOGV.printf("Thread producer_thread: %u, affinity: %u", i, assigned_cpu);
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
    Shard *sh = &this->shards[i];
    sh->shard_idx = i;

    PLOG_DEBUG.printf("tid %d assigned cpu %d", i, assigned_cpu);

    auto _thread =
        std::thread(&QueueTest<T>::consumer_thread, this, i, cfg->n_prod,
                    cfg->n_cons, cfg->num_nops, &barrier);

    CPU_ZERO(&cpuset);
    CPU_SET(assigned_cpu, &cpuset);

    pthread_setaffinity_np(_thread.native_handle(), sizeof(cpu_set_t), &cpuset);

    PLOGV.printf("Thread consumer_thread: %u, affinity: %u", i, assigned_cpu);

    this->cons_threads.push_back(std::move(_thread));
    i += 1;
    j += 1;
  }

  {
    PLOGV.printf("Running master thread with id %d", main_sh->shard_idx);
    this->producer_thread(main_sh->shard_idx, cfg->n_prod, cfg->n_cons, true,
                          cfg->skew, is_join, &barrier);
  }

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
  // print_stats(this->shards, *cfg);
}

template class QueueTest<SectionQueue>;

const data_t SectionQueue::BQ_MAGIC_KV = data_t(
      SectionQueue::BQ_MAGIC_64BIT, SectionQueue::BQ_MAGIC_64BIT);
//template class QueueTest<LynxQueue>;
//template class QueueTest<BQueueAligned>;
}  // namespace kmercounter
