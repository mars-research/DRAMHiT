#include <bqueue.h>
#include <misc_lib.h>
#include <plog/Log.h>
#include <sync.h>

#include <RWRatioTest.hpp>
#include <array>
#include <base_kht.hpp>
#include <constants.hpp>
#include <hasher.hpp>
#include <random>
#include <xorwow.hpp>

#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

namespace kmercounter {
struct experiment_results {
  std::uint64_t cycles;
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
  rw_experiment(BaseHashTable& hashtable, unsigned int start_key)
      : hashtable{hashtable},
        timings{},
        prng{},
        sampler{config.pread},
        next_key{start_key},
        write_batch{},
        writes{0, write_batch.data()},
        read_batch{},
        reads{0, read_batch.data()},
        result_batch{},
        results{0, result_batch.data()} {
    PLOG_INFO << "Using P(read) = " << config.pread << "\n";
  }

  auto start_time() { return __rdtsc(); }
  auto stop_time() {
    unsigned int aux;
    return __rdtscp(&aux);
  }

  experiment_results run(unsigned int total_ops) {
    const auto start = start_time();

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

    const auto stop = stop_time();
    timings.cycles = stop - start;

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

    // const auto start = start_time();
    hashtable.insert_batch(writes);
    // timings.insert_cycles += stop_time() - start;

    writes.first = 0;
  }

  void time_find() {
    timings.n_reads += reads.first;

    // const auto start = start_time();
    hashtable.find_batch(reads, results);
    // timings.find_cycles += stop_time() - start;

    timings.n_found += results.first;
    results.first = 0;
    reads.first = 0;
  }

  void time_flush_find() {
    /// const auto start = start_time();
    hashtable.flush_find_queue(results);
    /// timings.find_cycles += stop_time() - start;

    timings.n_found += results.first;
    results.first = 0;
  }

  void time_flush_insert() {
    // const auto start = start_time();
    hashtable.flush_insert_queue();
    // timings.insert_cycles += stop_time() - start;
  }
};

void RWRatioTest::run(Shard& shard, BaseHashTable& hashtable,
                      unsigned int total_ops) {
#ifdef BQ_TESTS_DO_HT_INSERTS
  PLOG_ERROR << "Please disable Bqueues option before running this test";
#else
  PLOG_INFO << "Starting RW thread " << shard.shard_idx;
  rw_experiment experiment{hashtable, shard.shard_idx * total_ops + 1};
#ifdef WITH_VTUNE_LIB
  constexpr auto event_name = "rw_ratio_run";
  static const auto event = __itt_event_create(event_name, strlen(event_name));
  __itt_event_start(event);
#endif
  const auto results = experiment.run(total_ops);

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

  shard.stats->finds.op_count = results.n_reads;
  shard.stats->finds.duration = results.cycles;

  shard.stats->insertions.op_count = results.n_writes;
  shard.stats->insertions.duration = results.cycles;

  shard.stats->any.op_count = results.n_reads + results.n_writes;
  shard.stats->any.duration = results.cycles;

  shard.stats->ht_capacity = hashtable.get_capacity();
  shard.stats->ht_fill = hashtable.get_fill();
#endif
}
}  // namespace kmercounter
