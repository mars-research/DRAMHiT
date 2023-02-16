#include <misc_lib.h>
#include <plog/Log.h>
#include <sync.h>
#include <zipf.h>

#include <RWRatioTest.hpp>
#include <array>
#include <constants.hpp>
#include <hasher.hpp>
#include <random>
#include <xorwow.hpp>

#include "hashtables/base_kht.hpp"
#include "hashtables/ht_helper.hpp"
#include "utils/hugepage_allocator.hpp"

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

std::atomic_uint64_t ready{};
extern std::vector<key_type, huge_page_allocator<key_type>>* zipf_values;
void init_zipfian_dist(double skew, int64_t seed);

class rw_experiment {
 public:
  rw_experiment(BaseHashTable& hashtable, unsigned int start_key)
      : hashtable{hashtable},
        timings{},
        prng{},
        sampler{config.pread},
        next_key{start_key},
        write_batch{},
        write_buffer_len{},
        read_batch{},
        read_buffer_len{},
        result_batch{},
        results{0, result_batch.data()} {
    PLOG_INFO << "Using P(read) = " << config.pread << "\n";
  }

  auto start_time() { return __rdtsc(); }
  auto stop_time() {
    unsigned int aux;
    return __rdtscp(&aux);
  }

  experiment_results run(unsigned int total_ops, collector_type* collector) {
    const auto keyrange = config.num_threads * total_ops;
    zipf_distribution distribution{
        config.skew, keyrange,
        next_key};  // next_key is being used purely as a seed here

    std::array<InsertFindArgument, HT_TESTS_BATCH_LENGTH> args{};
    uint64_t k{};
    collector_type dummy{};

    const std::span values{&zipf_values->at(next_key),
                           zipf_values->size() - next_key};
    for (auto i = 0u; i < total_ops; ++i, ++k) {
      if (k == HT_TESTS_BATCH_LENGTH) {
        hashtable.insert_batch(args, &dummy);
        k = 0;
      }

      args[k].key = values[i];
    }

    hashtable.flush_insert_queue();

#ifdef WITH_VTUNE_LIB
    constexpr auto event_name = "rw_ratio_run";
    static const auto event =
        __itt_event_create(event_name, strlen(event_name));
    __itt_event_start(event);
#endif

    std::array<bool, 1024> flips{};
    for (auto& flip : flips) flip = !sampler(prng);

    const auto start = start_time();
    if (!config.no_prefetch) {
      for (auto i = 0u; i < total_ops; ++i) {
        const auto zipf_idx = i;
        if (!(zipf_idx & 7) && zipf_idx + 16 < zipf_values->size()) {
          prefetch_object<false>(&zipf_values->at(zipf_idx + 16), 64);
        }

        if (i % 8 == 0 && i + 16 < keyrange)
          __builtin_prefetch(&values[i + 16]);

        if (write_buffer_len == HT_TESTS_BATCH_LENGTH) time_insert(collector);
        if (read_buffer_len == HT_TESTS_FIND_BATCH_LENGTH) time_find(collector);
        if (flips[i & 1023])
          read_batch[read_buffer_len++].key = values[i];
        else
          write_batch[write_buffer_len++].key = values[i];
      }

      time_insert(collector);
      time_find(collector);
      time_flush_insert(collector);
      time_flush_find(collector);
    } else {
      for (auto i = 0u; i < total_ops; ++i) {
        const auto zipf_idx = i;
        if (!(zipf_idx & 7) && zipf_idx + 16 < zipf_values->size()) {
          prefetch_object<false>(&zipf_values->at(zipf_idx + 16), 64);
        }

        InsertFindArgument kv{values[i], values[i]};
        kv.id = i;
        if (flips[i & 1023]) {
          ++timings.n_writes;
          hashtable.insert_noprefetch(&kv, collector);
        } else {
          ++timings.n_reads;
          if (hashtable.find_noprefetch(&kv, collector)) ++timings.n_found;
        }
      }
    }

    const auto stop = stop_time();
    timings.cycles = stop - start;

#ifdef WITH_VTUNE_LIB
    __itt_event_end(event);
#endif

    return timings;
  }

 private:
  BaseHashTable& hashtable;
  experiment_results timings;
  xorwow_urbg prng;
  std::bernoulli_distribution sampler;
  std::uint64_t next_key;

  std::array<InsertFindArgument, HT_TESTS_BATCH_LENGTH> write_batch;
  size_t write_buffer_len;

  std::array<InsertFindArgument, HT_TESTS_FIND_BATCH_LENGTH> read_batch;
  size_t read_buffer_len;

  std::array<FindResult, HT_TESTS_FIND_BATCH_LENGTH> result_batch;
  ValuePairs results;

  void time_insert(collector_type* collector) {
    timings.n_writes += write_buffer_len;

    // const auto start = start_time();
    hashtable.insert_batch(
        InsertFindArguments(write_batch.data(), write_buffer_len), collector);
    // timings.insert_cycles += stop_time() - start;

    write_buffer_len = 0;
  }

  void time_find(collector_type* collector) {
    timings.n_reads += read_buffer_len;

    // const auto start = start_time();
    hashtable.find_batch(
        InsertFindArguments(read_batch.data(), read_buffer_len), results,
        collector);
    // timings.find_cycles += stop_time() - start;

    timings.n_found += results.first;
    results.first = 0;
    read_buffer_len = 0;
  }

  void time_flush_find(collector_type* collector) {
    /// const auto start = start_time();
    hashtable.flush_find_queue(results, collector);
    /// timings.find_cycles += stop_time() - start;

    timings.n_found += results.first;
    results.first = 0;
  }

  void time_flush_insert(collector_type* collector) {
    // const auto start = start_time();
    hashtable.flush_insert_queue(collector);
    // timings.insert_cycles += stop_time() - start;
  }
};

void RWRatioTest::run(Shard& shard, BaseHashTable& hashtable,
                      unsigned int total_ops) {
  PLOG_INFO << "Starting RW thread " << shard.shard_idx;
  rw_experiment experiment{hashtable, shard.shard_idx * total_ops};

  {
    const std::lock_guard guard{collector_lock};
    if (collectors.empty()) collectors.resize(config.num_threads);
  }

  const auto collector = &collectors.at(shard.shard_idx);
  collector->claim();
  const auto results = experiment.run(total_ops, collector);
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
  shard.stats->insertions = shard.stats->any;

  shard.stats->ht_capacity = hashtable.get_capacity();
  shard.stats->ht_fill = hashtable.get_fill();

  collector->dump("unified", shard.shard_idx);
}
}  // namespace kmercounter
