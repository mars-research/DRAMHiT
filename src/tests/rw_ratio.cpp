#include <bqueue.h>
#include <misc_lib.h>
#include <plog/Log.h>
#include <sync.h>

#include <RWRatioTest.hpp>
#include <array>
#include <base_kht.hpp>
#include <hasher.hpp>
#include <random>

#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

namespace kmercounter {
struct experiment_results {
  std::uint64_t insert_cycles;
  std::uint64_t find_cycles;
  std::uint64_t n_reads;
  std::uint64_t n_writes;
  std::uint64_t n_found;
};

extern Configuration config;

class rw_experiment {
 public:
  rw_experiment(BaseHashTable& hashtable, double p_read, unsigned int shard_id,
                unsigned int per_thread_ops)
      : hashtable{hashtable},
        timings{},
        prng{},
        sampler{p_read},
        base_key{1 + shard_id * per_thread_ops},
        shard_id{shard_id},
        per_thread_inserts{per_thread_ops},
        write_batch{},
        writes{0, write_batch.data()},
        read_batch{},
        reads{0, read_batch.data()},
        result_batch{},
        results{0, result_batch.data()} {}

  experiment_results run() {
    insert_all();

    const auto start = start_time();
    std::uint64_t next_write_key{base_key};
    std::uint64_t next_read_key{base_key};
    for (auto i = 0u; i < per_thread_inserts; ++i) {
      if (writes.first == HT_TESTS_BATCH_LENGTH) insert();
      if (reads.first == HT_TESTS_FIND_BATCH_LENGTH) find();
      if (sampler(prng))
        push_key(reads, next_read_key++);
      else
        push_key(writes, next_write_key++);
    }

    insert();
    find();
    flush_insert();
    flush_find();
    const auto stop = stop_time();
    timings.insert_cycles = stop - start;
    timings.find_cycles = stop - start;

    return timings;
  }

 private:
  BaseHashTable& hashtable;
  experiment_results timings;
  xorwow_urbg prng;
  std::bernoulli_distribution sampler;
  const std::uint64_t base_key;
  const std::uint64_t shard_id;
  const unsigned int per_thread_inserts;

  std::array<Keys, HT_TESTS_BATCH_LENGTH> write_batch;
  KeyPairs writes;

  std::array<Keys, HT_TESTS_FIND_BATCH_LENGTH> read_batch;
  KeyPairs reads;

  std::array<Values, HT_TESTS_FIND_BATCH_LENGTH> result_batch;
  ValuePairs results;

  std::uint64_t start_time() { return __rdtsc(); }
  std::uint64_t stop_time() {
    unsigned int aux;
    return __rdtscp(&aux);
  }

  void insert(bool no_count = false) {
    if (!no_count) timings.n_writes += writes.first;
    hashtable.insert_batch(writes);
    writes.first = 0;
  }

  void find() {
    timings.n_reads += reads.first;
    hashtable.find_batch(reads, results);
    timings.n_found += results.first;
    results.first = 0;
    reads.first = 0;
  }

  void flush_find() {
    hashtable.flush_find_queue(results);
    timings.n_found += results.first;
    results.first = 0;
  }

  void flush_insert() { hashtable.flush_insert_queue(); }

  void insert_all() {
    std::uint64_t next_key{base_key};
    for (auto i = 0u; i < per_thread_inserts; ++i) {
      if (writes.first == HT_TESTS_BATCH_LENGTH) insert(true);
      push_key(writes, next_key++);
    }
  }

  void push_key(KeyPairs& keys, std::uint64_t key) noexcept {
    Keys key_struct{};
    key_struct.key = key;
    key_struct.id = key;
    key_struct.part_id = shard_id;
    keys.second[keys.first++] = key_struct;
  }
};

void RWRatioTest::init_queues(unsigned int n_clients, unsigned int n_writers) {
  data_arrays.resize(n_clients);
  producer_queues.resize(n_clients);
  consumer_queues.resize(n_writers);
  for (auto i = 0u; i < n_clients; ++i) {
    data_arrays.at(i).resize(n_writers);
    producer_queues.at(i).resize(n_writers);
  }

  for (auto i = 0u; i < n_writers; ++i) consumer_queues.at(i).resize(n_clients);

  for (auto i = 0u; i < n_clients; ++i) {
    for (auto j = 0u; j < n_writers; ++j) {
      auto& data = data_arrays[i][j];
      auto& producer = producer_queues[i][j];
      auto& consumer = consumer_queues[j][i];
      init_queue(&consumer);
      consumer.data = data.data;
      producer.data = data.data;
    }
  }
}

bool is_consumer_thread(NumaPolicyQueues& policy, std::uint8_t core_id) {
  const auto& consumers = policy.get_assigned_cpu_list_consumers();
  return std::find(consumers.begin(), consumers.end(), core_id) !=
         consumers.end();
}

void RWRatioTest::run(Shard& shard, BaseHashTable& hashtable,
                      unsigned int per_thread_inserts) {
#ifdef BQ_TESTS_DO_HT_INSERTS
  PLOG_ERROR << "Please disable Bqueues option before running this test";
#else
  /*
      - Generate random bools in-place to avoid prefetching problems (but also
     benchmark dry run i.e. max throughput with just bools)
      - Submit batches of reads/writes only when full (bqueue consumers already
     do this)
      - Remove dependence on build flag for the stash-hash-in-upper-bits trick
     (don't want to force a rebuild every test)
  */

  if (shard.shard_idx == 0) {
    while (ready < config.num_threads - 1) _mm_pause();
    start = true;
  } else {
    ++ready;
    while (!start) _mm_pause();
  }

  PLOG_INFO << "Starting RW thread "
            << static_cast<unsigned int>(shard.shard_idx);

  rw_experiment experiment{hashtable, config.p_read, shard.shard_idx,
                           per_thread_inserts};
#ifdef WITH_VTUNE_LIB
  constexpr auto event_name = "rw_ratio_run";
  static const auto event = __itt_event_create(event_name, strlen(event_name));
  __itt_event_start(event);
#endif
  const auto results = experiment.run();

#ifdef WITH_VTUNE_LIB
  __itt_event_end(event);
#endif

  PLOG_INFO << "Executed " << results.n_reads << " reads / " << results.n_writes
            << " writes ("
            << static_cast<double>(results.n_reads) / results.n_writes
            << " R/W)";

  if (results.n_reads != results.n_found) {
    PLOG_WARNING << "Not all read attempts succeeded (" << results.n_reads
                 << " / " << results.n_found << ")";
  }

  shard.stats->num_finds = results.n_reads;
  shard.stats->num_inserts = results.n_writes;
  shard.stats->find_cycles = results.find_cycles;
  shard.stats->insertion_cycles = results.insert_cycles;
  shard.stats->ht_capacity = hashtable.get_capacity();
  shard.stats->ht_fill = hashtable.get_fill();
#endif
}
}  // namespace kmercounter
