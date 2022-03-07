#include <bqueue.h>
#include <misc_lib.h>
#include <plog/Log.h>
#include <sync.h>

#include <RWRatioTest.hpp>
#include <algorithm>
#include <array>
#include <base_kht.hpp>
#include <hasher.hpp>
#include <hashtables/kvtypes.hpp>
#include <random>

#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

namespace kmercounter {
class partition {
 public:
  // May just need key/hash, not the entire itemqueue (since the ID is implicit)
  Values& find_one(const ItemQueue& queue_entry);
  void insert_one(const ItemQueue& queue_entry);
  void* address(const ItemQueue& item);  // Needed by prefetching queue
};

class prefetch_queue {
 public:
  prefetch_queue(const std::vector<partition>& tables);
  void dispatch(const ItemQueue& item);
};

class write_queue {
 public:
  void dispatch(const KeyPairs& inserts);
};

class read_queue {
 public:
  ValuePairs dispatch(const KeyPairs& finds);
};

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

  experiment_results run(int n_writers, queues& insert_queues,
                         queues& rw_queues) {
    if (n_writers < 0)
      return run_no_bq();
    else
      return run_bq(n_writers, insert_queues, rw_queues);
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

  experiment_results run_no_bq() {
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

  struct role_assignments {
    std::vector<bool> is_server;
    std::vector<unsigned int> queue_id;
  };

  auto get_roles(NumaPolicyQueues& policy) {
    const auto& clients = policy.get_assigned_cpu_list_producers();
    const auto& servers = policy.get_assigned_cpu_list_consumers();
    const auto n_threads = clients.size() + servers.size();
    role_assignments roles{};
    roles.is_server.resize(n_threads);
    roles.queue_id.resize(n_threads);
    auto client_id = 0u;
    for (auto n : clients) roles.queue_id.at(n) = client_id++;

    auto server_id = 0u;
    for (auto n : servers) {
      roles.is_server.at(n) = true;
      roles.queue_id.at(n) = server_id++;
    }

    return roles;
  }

  experiment_results run_bq(int n_writers, queues& insert_queues,
                            queues& rw_queues) {
    const auto half_threads = static_cast<int>(config.num_threads / 2);
    const auto policy = static_cast<numa_policy_queues>(config.numa_split);
    const auto n_clients = static_cast<int>(config.num_threads) - n_writers;
    static NumaPolicyQueues insert_policy{half_threads, half_threads, policy};
    static NumaPolicyQueues rw_policy{n_writers, n_clients, policy};
    static const auto insert_roles = get_roles(insert_policy);
    static const auto rw_roles = get_roles(rw_policy);
    static_cast<void>(rw_roles);
    const auto self_id = get_cpu();
    const auto insert_queue_id = insert_roles.queue_id.at(self_id);
    if (insert_roles.is_server.at(self_id))
      run_server(insert_queue_id, half_threads, insert_queues);
    else
      run_client(insert_queue_id, half_threads, insert_queues);

    return timings;
  }

  unsigned int get_cpu() {
    cpu_set_t cpuset;
    CPU_ZERO(&cpuset);
    pthread_getaffinity_np(pthread_self(), sizeof(cpuset), &cpuset);
    assert(CPU_COUNT(&cpuset) == 1);
    for (auto i = 0u; i < CPU_SETSIZE; ++i)
      if (CPU_ISSET(i, &cpuset)) return i;

    assert(false);

    return 0;
  }

  void run_server(unsigned int self_id, unsigned int n_clients,
                  queues& queues) {
    std::vector<cons_queue_t*> sources(n_clients);
    for (auto i = 0u; i < n_clients; ++i) {
      auto& source = queues.get_source(i, self_id);
      sources.at(i) = &source;
    }

    std::uint64_t iteration{};
    auto live_clients = sources.size();
    const auto start = start_time();
    while (live_clients) {
      const auto source = sources.at(iteration);
      data_t data;
      if (dequeue(source, &data) == SUCCESS) {
        if (data == 0xdeadbeef) {
          PLOG_WARNING << "Received stop from client " << iteration;
          --live_clients;
        } else {
          if (writes.first == HT_TESTS_BATCH_LENGTH) insert();
          push_key(writes, data);
        }
      } else {
        ++iteration;
        iteration = iteration < sources.size() ? iteration : 0;
      }
    }

    insert();
    flush_insert();
    timings.insert_cycles = stop_time() - start;

    PLOG_WARNING << "Stopped server " << self_id;
  }

  void run_client(unsigned int self_id, unsigned int n_servers,
                  queues& queues) {
    std::vector<prod_queue_t*> sinks(n_servers);
    std::vector<cons_queue_t*> source_ends(n_servers);
    for (auto i = 0u; i < n_servers; ++i) {
      sinks.at(i) = &queues.get_sink(self_id, i);
      source_ends.at(i) = &queues.get_source(self_id, i);
    }

    Hasher hash_key{};
    for (auto i = 0u; i < per_thread_inserts; ++i) {
      const auto key = base_key + i;
      const auto hash = hash_key(&key, sizeof(key));
      const auto queue_id =
          fastrange32(_mm_crc32_u32(0xffffffff, hash), n_servers);

      const auto sink = sinks.at(queue_id);
      while (enqueue(sink, key) != SUCCESS) _mm_pause();
    }

    for (auto i = 0u; i < n_servers; ++i) {
      const auto sink = sinks.at(i);
      source_ends.at(i)->backtrack_flag = 1;
      while (enqueue(sink, 0xdeadbeef) != SUCCESS) _mm_pause();
      PLOG_WARNING << "Sent stop to server " << i;
    }

    PLOG_WARNING << "Client " << self_id << " signalled stop";
  }
};

void init_queues(queues& queues, unsigned int n_clients,
                 unsigned int n_writers) {
  queues.data_arrays.resize(n_clients);
  queues.producer_queues.resize(n_clients);
  queues.consumer_queues.resize(n_writers);
  for (auto i = 0u; i < n_clients; ++i) {
    queues.data_arrays.at(i).resize(n_writers);
    queues.producer_queues.at(i).resize(n_writers);
  }

  for (auto i = 0u; i < n_writers; ++i)
    queues.consumer_queues.at(i).resize(n_clients);

  for (auto i = 0u; i < n_clients; ++i) {
    for (auto j = 0u; j < n_writers; ++j) {
      auto& data = queues.data_arrays[i][j];
      auto& producer = queues.producer_queues[i][j];
      auto& consumer = queues.consumer_queues[j][i];
      init_queue(&consumer);
      consumer.data = data.data;
      producer.data = data.data;
    }
  }
}

void RWRatioTest::init_rw_queues(unsigned int n_clients,
                                 unsigned int n_writers) {
  init_queues(rw_queues, n_clients, n_writers);
}

void RWRatioTest::init_insert_queues(unsigned int n_threads) {
  const auto n_writers = n_threads / 2;
  const auto n_clients = n_writers;
  init_queues(insert_queues, n_clients, n_writers);
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
    if (config.bq_writers >= 0) {
      init_rw_queues(config.num_threads - config.bq_writers, config.bq_writers);
      init_insert_queues(config.num_threads);
    }

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
  const auto results =
      experiment.run(config.bq_writers, insert_queues, rw_queues);

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
