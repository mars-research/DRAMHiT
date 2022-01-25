#include <misc_lib.h>
#include <plog/Log.h>
#include <sync.h>

#include <RWRatioTest.hpp>
#include <array>
#include <base_kht.hpp>
#include <random>

namespace kmercounter {
struct experiment_results {
  std::uint64_t insert_cycles;
  std::uint64_t find_cycles;
  std::uint64_t n_reads;
  std::uint64_t n_writes;
  std::uint64_t n_found;
};

class rw_experiment {
 public:
  rw_experiment(BaseHashTable& hashtable, double rw_ratio)
      : hashtable{hashtable},
        timings{},
        prng{},
        sampler{rw_ratio / (1.0 + rw_ratio)},
        write_batch{},
        writes{0, write_batch.data()},
        read_batch{},
        reads{0, read_batch.data()},
        result_batch{},
        results{0, result_batch.data()} {}

  experiment_results run(unsigned int total_ops) {
    const auto push_key = [](KeyPairs& keys, std::uint64_t key) noexcept {
      Keys key_struct{};
      key_struct.key = key;
      keys.second[keys.first++] = key_struct;
    };

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

void RWRatioTest::run(Shard& shard, BaseHashTable& hashtable,
                      double reads_per_write, unsigned int total_ops,
                      unsigned int bq_writer_count) {
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

  PLOG_INFO << "Starting RW thread " << shard.shard_idx;
  rw_experiment experiment{hashtable, reads_per_write};
  const auto results = experiment.run(total_ops);
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
