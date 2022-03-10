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

struct role_assignments {
  std::vector<bool> is_server;
  std::vector<unsigned int> queue_id;
  std::vector<unsigned int> exclusive_writers;
};

auto get_roles(NumaPolicyQueues& policy) {
  const auto& clients = policy.get_assigned_cpu_list_producers();
  const auto& servers = policy.get_assigned_cpu_list_consumers();
  const auto n_threads = clients.size() + servers.size();
  role_assignments roles{};
  roles.is_server.resize(n_threads);
  roles.queue_id.resize(n_threads);
  roles.exclusive_writers.resize(n_threads);
  auto client_id = 0u;
  for (auto n : clients) roles.queue_id.at(n) = client_id++;

  auto server_id = 0u;
  for (auto n : servers) {
    roles.is_server.at(n) = true;
    roles.queue_id.at(n) = server_id++;
  }

  auto owner_id = 0u;
  for (auto& part : roles.exclusive_writers) {
    part = owner_id++;
    owner_id = owner_id < servers.size() ? owner_id : 0;
  }

  std::stringstream message{};
  message << '[';
  auto first = true;
  for (auto part : roles.exclusive_writers) {
    if (!first) message << ", ";
    message << part;
    first = false;
  }

  message << ']';

  PLOG_WARNING << "Partmap: " << message.str();

  return roles;
}

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

  experiment_results run(unsigned int n_writers, queues& insert_queues,
                         queues& rw_queues) {
    if (n_writers < 0)
      return run_no_bq();
    else
      return run_bq(n_writers, insert_queues, rw_queues);
  }

 private:
  BaseHashTable& hashtable;
  experiment_results timings;  // TODO: I should not be here :(
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

  template <bool no_count>
  void insert() {
    if constexpr (!no_count) timings.n_writes += writes.first;
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

  void insert_all(unsigned int shard) {
    std::uint64_t next_key{base_key};
    for (auto i = 0u; i < per_thread_inserts; ++i) {
      if (writes.first == HT_TESTS_BATCH_LENGTH) insert<true>();
      push_key(writes, next_key++, shard);
    }
  }

  void push_key(KeyPairs& keys, std::uint64_t key,
                unsigned int shard) noexcept {
    Keys key_struct{};
    key_struct.key = key;
    key_struct.id = key;
    key_struct.part_id = shard;
    keys.second[keys.first++] = key_struct;
  }

  experiment_results run_no_bq() {
    insert_all(shard_id);

    const auto start = start_time();
    std::uint64_t next_write_key{base_key};
    std::uint64_t next_read_key{base_key};
    for (auto i = 0u; i < per_thread_inserts; ++i) {
      if (writes.first == HT_TESTS_BATCH_LENGTH) insert<false>();
      if (reads.first == HT_TESTS_FIND_BATCH_LENGTH) find();
      if (sampler(prng))
        push_key(reads, next_read_key++, shard_id);
      else
        push_key(writes, next_write_key++, shard_id);
    }

    insert<false>();
    find();
    flush_insert();
    flush_find();
    const auto stop = stop_time();
    timings.insert_cycles = stop - start;
    timings.find_cycles = stop - start;

    return timings;
  }

  void run_bq_work(const role_assignments& roles, queues& queues,
                   unsigned int n_servers, unsigned int n_clients,
                   unsigned int self_id, bool no_count) {
    const auto queue_id = roles.queue_id.at(self_id);
    if (roles.is_server.at(self_id)) {
      if (no_count)
        run_server<true>(queue_id, n_clients, queues, roles.exclusive_writers);
      else
        run_server<false>(queue_id, n_clients, queues, roles.exclusive_writers);
    } else {
      run_client(queue_id, n_servers, queues, roles.exclusive_writers);
    }
  }

  NumaPolicyQueues make_policy(unsigned int n_clients, unsigned int n_servers) {
    return {static_cast<int>(n_servers), static_cast<int>(n_clients),
            static_cast<numa_policy_queues>(config.numa_split)};
  }

  experiment_results run_bq(unsigned int n_writers, queues& insert_queues,
                            queues& rw_queues) {
    const auto total_threads = static_cast<unsigned int>(config.num_threads);
    const auto half_threads = total_threads / 2;
    const auto n_clients = total_threads - n_writers;
    static auto insert_policy = make_policy(half_threads, half_threads);
    static auto rw_policy = make_policy(n_writers, n_clients);
    const auto self_id = get_cpu();
    run_bq_work(get_roles(insert_policy), insert_queues, half_threads,
                half_threads, self_id, true);

    run_bq_work(get_roles(rw_policy), rw_queues, n_writers, n_clients, self_id,
                false);

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

  template <bool no_count>
  void run_server(unsigned int self_id, unsigned int n_clients, queues& queues,
                  const std::vector<unsigned int>& part_assignments) {
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
      const auto lookahead = iteration + 3;
      const auto lookahead_index =
          lookahead - (lookahead >= n_clients ? n_clients : 0);

      cons_queue_t* next_queue = sources[lookahead_index];
      if ((next_queue->tail + 15) == next_queue->batch_tail) {
        auto tmp_tail = next_queue->tail + BATCH_SIZE - 1;
        if (tmp_tail >= QUEUE_SIZE) tmp_tail = 0;
        __builtin_prefetch(&next_queue->data[tmp_tail], 0, 3);
      }

      const auto block1 = (next_queue->tail + 8) & (QUEUE_SIZE - 1);
      const auto block2 = (next_queue->tail + 16) & (QUEUE_SIZE - 1);
      __builtin_prefetch(&next_queue->data[source->tail], 1, 3);
      __builtin_prefetch(&next_queue->data[block1], 1, 3);
      __builtin_prefetch(&next_queue->data[block2], 1, 3);

      Hasher hash_key{};
      for (auto i = 0u; i < HT_TESTS_BATCH_LENGTH;) {
        data_t data;
        if (dequeue(source, &data) == SUCCESS) {
          if (data == 0xdeadbeef) {
            --live_clients;
          } else {
            const auto part_id = fastrange32(
                _mm_crc32_u32(0xffffffff, hash_key(&data, sizeof(data))),
                config.num_threads);

            if (writes.first == HT_TESTS_BATCH_LENGTH) insert<no_count>();
            push_key(writes, data, part_id);
          }

          ++i;
        } else {
          break;
        }
      }

      ++iteration;
      iteration = iteration < sources.size() ? iteration : 0;
    }

    insert<no_count>();
    flush_insert();
    timings.insert_cycles = stop_time() - start;
  }

  void run_client(unsigned int self_id, unsigned int n_servers, queues& queues,
                  const std::vector<unsigned int>& part_assignments) {
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
      const std::uint64_t part_id{
          fastrange32(_mm_crc32_u32(0xffffffff, hash), config.num_threads)};

      const auto queue_id = part_assignments.at(part_id);
      const auto sink = sinks[queue_id];
      while (enqueue(sink, key) != SUCCESS) _mm_pause();

      if (((sink->head + 4) & 7) == 0) {
        const auto next_sink = queue_id + 1;
        const auto q = sinks[next_sink < n_servers ? next_sink : 0];
        const auto next_1 = (q->head + 8) & (QUEUE_SIZE - 1);
        __builtin_prefetch(&q->data[next_1], 1, 3);
      }
    }

    for (auto i = 0u; i < n_servers; ++i) {
      const auto sink = sinks.at(i);
      source_ends.at(i)->backtrack_flag = 1;
      while (enqueue(sink, 0xdeadbeef) != SUCCESS) _mm_pause();
    }
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
