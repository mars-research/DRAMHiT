#include <bqueue.h>
#include <misc_lib.h>
#include <plog/Log.h>
#include <sync.h>

#include <RWRatioTest.hpp>
#include <array>
#include <base_kht.hpp>
#include <hasher.hpp>
#include <random>

namespace kmercounter {
struct experiment_results {
  std::uint64_t insert_cycles;
  std::uint64_t find_cycles;
  std::uint64_t n_reads;
  std::uint64_t n_writes;
  std::uint64_t n_found;
};

void push_key(KeyPairs& keys, std::uint64_t key) noexcept {
  Keys key_struct{};
  key_struct.key = key;
  keys.second[keys.first++] = key_struct;
}

extern Configuration config;

class rw_experiment {
 public:
  rw_experiment(BaseHashTable& hashtable, double rw_ratio)
      : hashtable{hashtable},
        timings{},
        prng{},
        sampler{rw_ratio / (1.0 + rw_ratio)},
        next_key{1},
        write_batch{},
        writes{0, write_batch.data()},
        read_batch{},
        reads{0, read_batch.data()},
        result_batch{},
        results{0, result_batch.data()} {}

  experiment_results run(unsigned int total_ops) {
    for (auto i = 0u; i < total_ops; ++i) {
      if (writes.first == HT_TESTS_BATCH_LENGTH) time_insert();
      if (reads.first == HT_TESTS_FIND_BATCH_LENGTH) time_find();
      if (sampler(prng))
        push_key(reads, std::uniform_int_distribution<std::uint64_t>{
                            1, next_key - 1}(prng));
      else
        push_key(writes, next_key++);
    }

    time_insert();
    time_find();
    time_flush_insert();
    time_flush_find();

    return timings;
  }

  experiment_results run_bq_client(unsigned int total_ops,
                                   std::vector<prod_queue_t>& queues,
                                   unsigned int producer_id,
                                   std::uint64_t n_producers,
                                   std::uint64_t n_consumers) {
    for (auto i = 0u; i < total_ops; ++i) {
      if (reads.first == HT_TESTS_FIND_BATCH_LENGTH) time_find();
      if (sampler(prng)) {
        push_key(reads, std::uniform_int_distribution<std::uint64_t>{
                            1, next_key - 1}(prng));
      } else {
        const auto key = next_key++;
        const auto hash = Hasher{}(&key, sizeof(key));
        auto& queue = queues.at(hash_to_cpu(hash, n_consumers));
        while (enqueue(&queue, key)) _mm_pause();
      }
    }

    time_find();
    time_flush_find();

    for (auto& queue : queues)
      while (enqueue(&queue, 0xdeadbeefdeadbeef)) _mm_pause();

    return timings;
  }

  experiment_results run_bq_server(unsigned int total_ops,
                                   std::vector<cons_queue_t>& queues,
                                   unsigned int consumer_id,
                                   std::uint64_t n_producers,
                                   std::uint64_t n_consumers) {
    unsigned int producer_id{};
    while (true) {
      if (writes.first == HT_TESTS_BATCH_LENGTH) time_insert();
      auto& queue = queues.at(producer_id);
      data_t data;
      if (!dequeue(&queue, &data)) {
        if (data == 0xdeadbeefdeadbeef) break;
        push_key(writes, data);
      }

      ++producer_id;
      producer_id %= n_producers;
    }

    time_insert();
    time_flush_insert();

    return timings;
  }

 private:
  BaseHashTable& hashtable;
  experiment_results timings;
  xorwow_urbg prng;
  std::bernoulli_distribution sampler;
  std::uint64_t next_key;

  std::array<Keys, HT_TESTS_BATCH_LENGTH> write_batch;
  KeyPairs writes;

  std::array<Keys, HT_TESTS_FIND_BATCH_LENGTH> read_batch;
  KeyPairs reads;

  std::array<Values, HT_TESTS_FIND_BATCH_LENGTH> result_batch;
  ValuePairs results;

  void time_insert() {
    timings.n_writes += writes.first;

    const auto start = RDTSC_START();
    hashtable.insert_batch(writes);
    timings.insert_cycles += RDTSCP() - start;

    writes.first = 0;
  }

  void time_find() {
    timings.n_reads += reads.first;

    const auto start = RDTSC_START();
    hashtable.find_batch(reads, results);
    timings.find_cycles += RDTSCP() - start;

    timings.n_found += results.first;
    results.first = 0;
    reads.first = 0;
  }

  void time_flush_find() {
    const auto start = RDTSC_START();
    hashtable.flush_find_queue(results);
    timings.find_cycles += RDTSCP() - start;

    timings.n_found += results.first;
    results.first = 0;
  }

  void time_flush_insert() {
    const auto start = RDTSC_START();
    hashtable.flush_insert_queue();
    timings.insert_cycles += RDTSCP() - start;
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

bool is_consumer_thread(NumaPolicyQueues& policy) {
  const auto& consumers = policy.get_assigned_cpu_list_consumers();
  cpu_set_t cpu_set;
  assert(!pthread_getaffinity_np(pthread_self(), sizeof(cpu_set), &cpu_set));
  for (const auto consumer : consumers) {
    if (CPU_ISSET(consumer, &cpu_set)) return true;
  }

  return false;
}

void RWRatioTest::run(Shard& shard, BaseHashTable& hashtable,
                      double reads_per_write, unsigned int total_ops,
                      const unsigned int n_writers) {
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

  const auto n_readers = config.num_threads - n_writers;
  static NumaPolicyQueues policy{
      n_readers, n_writers, static_cast<numa_policy_queues>(config.numa_split)};

  const auto is_consumer = is_consumer_thread(policy);
  const auto bq_id = is_consumer ? next_consumer++ : next_producer++;
  if (shard.shard_idx == 0) {
    if (n_writers) init_queues(n_readers, n_writers);
    while (ready < config.num_threads - 1) _mm_pause();
    start = true;
  } else {
    ++ready;
    while (!start) _mm_pause();
  }

  PLOG_INFO << "Starting RW thread " << shard.shard_idx;
  rw_experiment experiment{hashtable, reads_per_write};
  experiment_results results{};
  if (!n_writers) {
    assert(config.ht_type != SIMPLE_KHT);
    results = experiment.run(total_ops / config.num_threads);
  } else {
    if (is_consumer)
      results = experiment.run_bq_server(total_ops / config.num_threads,
                                         consumer_queues.at(bq_id), bq_id,
                                         n_readers, n_writers);
    else
      results = experiment.run_bq_client(total_ops / config.num_threads,
                                         producer_queues.at(bq_id), bq_id,
                                         n_readers, n_writers);
  }

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
#endif
}
}  // namespace kmercounter
