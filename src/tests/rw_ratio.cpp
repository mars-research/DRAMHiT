#include <misc_lib.h>
#include <plog/Log.h>
#include <sync.h>

#include <RWRatioTest.hpp>
#include <array>
#include <base_kht.hpp>
#include <random>

namespace kmercounter {
void RWRatioTest::run(Shard& shard, BaseHashTable& hashtable,
                      double reads_per_write, unsigned int total_ops,
                      unsigned int bq_writer_count) {
  /*
      - Generate random bools in-place to avoid prefetching problems (but also
     benchmark dry run i.e. max throughput with just bools)
      - Submit batches of reads/writes only when full (bqueue consumers already
     do this)
      - Remove dependence on build flag for the stash-hash-in-upper-bits trick
     (don't want to force a rebuild every test)
  */

  PLOG_INFO << "Starting RW thread " << shard.shard_idx;

  xorwow_urbg prng{};
  std::bernoulli_distribution sampler{reads_per_write / (1 + reads_per_write)};
  std::array<Keys, HT_TESTS_BATCH_LENGTH> write_batch{};
  std::array<Keys, HT_TESTS_FIND_BATCH_LENGTH> read_batch{};
  std::array<Values, HT_TESTS_FIND_BATCH_LENGTH> result_batch{};
  KeyPairs writes{0, write_batch.data()};
  KeyPairs reads{0, read_batch.data()};
  ValuePairs results{0, result_batch.data()};
  const auto push_key = [](KeyPairs& keys, std::uint64_t key) noexcept {
    Keys key_struct{};
    key_struct.key = key;
    keys.second[keys.first++] = key_struct;
  };

  unsigned int n_found{};
  unsigned int n_written{};
  unsigned int n_read{};
  uint64_t find_cycles{};
  uint64_t insert_cycles{};
  std::uint64_t next_key{1};
  for (auto i = 0u; i < total_ops; ++i) {
    if (writes.first == HT_TESTS_BATCH_LENGTH) {
      n_written += writes.first;
      const auto t_start = RDTSC_START();
      hashtable.insert_batch(writes);
      insert_cycles += RDTSCP() - t_start;
      writes.first = 0;
    }

    if (reads.first == HT_TESTS_FIND_BATCH_LENGTH) {
      n_read += reads.first;
      const auto t_start = RDTSC_START();
      hashtable.find_batch(reads, results);
      find_cycles += RDTSCP() - t_start;
      n_found += results.first;
      results.first = 0;
      reads.first = 0;
    }

    if (sampler(prng))
      push_key(reads, std::uniform_int_distribution<std::uint64_t>{
                          1, next_key - 1}(prng));
    else
      push_key(writes, next_key++);
  }

  n_read += reads.first;
  n_written += writes.first;

  auto t_start = RDTSC_START();
  hashtable.insert_batch(writes);
  insert_cycles += RDTSCP() - t_start;

  t_start = RDTSC_START();
  hashtable.find_batch(reads, results);
  find_cycles += RDTSCP() - t_start;

  n_found += results.first;

  t_start = RDTSC_START();
  hashtable.flush_insert_queue();
  insert_cycles += RDTSCP() - t_start;

  t_start = RDTSC_START();
  hashtable.flush_find_queue(results);
  find_cycles += RDTSCP() - t_start;

  n_found += results.first;

  PLOG_INFO << "Executed " << n_read << " reads / " << n_written << " writes ("
            << static_cast<double>(n_read) / n_written << " R/W)";

  if (n_read != n_found) {
    PLOG_ERROR << "Not all read attempts succeeded (" << n_read << " / "
               << n_found << ")";
  }

  shard.stats->num_finds = n_read;
  shard.stats->num_inserts = n_written;
  shard.stats->find_cycles = find_cycles;
  shard.stats->insertion_cycles = insert_cycles;
}
}  // namespace kmercounter
