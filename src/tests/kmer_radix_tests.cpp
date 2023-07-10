#include <plog/Log.h>

#include <algorithm>
#include <atomic>
#include <barrier>
#include <cstdint>

#include <absl/container/flat_hash_map.h>
#include "constants.hpp"
#include "hashtables/array_kht.hpp"
#include "hashtables/base_kht.hpp"
#include "hashtables/batch_runner/batch_runner.hpp"
#include "hashtables/cas_kht.hpp"
#include "hashtables/kvtypes.hpp"
#include "hashtables/simple_kht.hpp"
#include "input_reader/counter.hpp"
#include "input_reader/fastq.hpp"
#include "print_stats.h"
#include "sync.h"
#include "tests/KmerTest.hpp"
#include "types.hpp"

namespace kmercounter {

#define HASHER XXH3_64bits

absl::flat_hash_map<Kmer, long> check_count(const absl::flat_hash_map<Kmer, uint64_t>& reference, const absl::flat_hash_map<Kmer, uint64_t>& aggregation) {
    absl::flat_hash_map<Kmer, long> diff;
    for (const auto& entry: reference) {
        auto key = entry.first;
        auto val = entry.second;
        if (aggregation.contains(key)) {
            auto agg_val = aggregation.at(key);
            if (val != agg_val) {
                diff[key] = (long)agg_val - (long)val;
            }
        }
        else {
            diff[key] = val;
        }
    }
    return diff;
  }

absl::flat_hash_map<Kmer, uint64_t> build_ref(const Configuration& config) {

  // Be care of the `K` here; it's a compile time constant.
  auto reader = input_reader::MakeFastqKMerPreloadReader(
      config.K, config.in_file, 0, 1);

  absl::flat_hash_map<Kmer, uint64_t> counter;  
  for (uint64_t kmer; reader->next(&kmer);) {
    counter[kmer]++;   
  }
  return counter;
}


void check_functionality(const Configuration& config, const RadixContext& context) {
      auto reference = build_ref(config);
      auto aggregation = context.aggregate();
      auto diff = check_count(reference, aggregation);
      auto rev_diff = check_count(aggregation, reference);
      for (auto& entry: rev_diff) {
          assert(entry.second < 0);
      }
      uint64_t max_diff = 0;
      Kmer max_diff_kmer = 0;
      for (auto& entry: diff) {
        auto abs_diff = std::abs(entry.second);

        assert(entry.second > 0);
        if (abs_diff > max_diff) {
            max_diff = abs_diff;
            max_diff_kmer = entry.first;
        }
      }
      PLOGI.printf("Diff kmer: %llu(rev: %llu); total distinct kmer: (ref: %llu, aggr: %llu); max diff: %llu(ref: %llu);", diff.size(), rev_diff.size(), reference.size(), aggregation.size(), max_diff, reference[max_diff_kmer]);
}
/**
 * Makes a non-temporal write of 64 bytes from src to dst.
 * Uses vectorized non-temporal stores if available, falls
 * back to assignment copy.
 *
 * @param dst
 * @param src
 *
 * @return
 */
static inline void store_nontemp_64B(void* dst, void* src) {
#ifdef __AVX__
  register __m256i* d1 = (__m256i*)dst;
  register __m256i s1 = *((__m256i*)src);
  register __m256i* d2 = d1 + 1;
  register __m256i s2 = *(((__m256i*)src) + 1);

  _mm256_stream_si256(d1, s1);
  _mm256_stream_si256(d2, s2);

#elif defined(__SSE2__)

  register __m128i* d1 = (__m128i*)dst;
  register __m128i* d2 = d1 + 1;
  register __m128i* d3 = d1 + 2;
  register __m128i* d4 = d1 + 3;
  register __m128i s1 = *(__m128i*)src;
  register __m128i s2 = *((__m128i*)src + 1);
  register __m128i s3 = *((__m128i*)src + 2);
  register __m128i s4 = *((__m128i*)src + 3);

  _mm_stream_si128(d1, s1);
  _mm_stream_si128(d2, s2);
  _mm_stream_si128(d3, s3);
  _mm_stream_si128(d4, s4);

#else
  /* just copy with assignment */
  *(cacheline_t*)dst = *(cacheline_t*)src;

#endif
}
/* #define RADIX_HASH(V)  ((V>>7)^(V>>13)^(V>>21)^V) */
#define HASH_BIT_MODULO(K, MASK, NBITS) (((K)&MASK) >> NBITS)

/** L1 cache parameters. \note Change as needed for different machines */
#ifndef CACHE_LINE_SIZE
#define CACHE_LINE_SIZE 64
#endif

// Should be power of 2?
#define KMERSPERCACHELINE (CACHE_LINE_SIZE / sizeof(Kmer))


typedef union {
  struct {
    Kmer kmers[KMERSPERCACHELINE];
  } kmers;
  struct {
    Kmer kmers[KMERSPERCACHELINE - 1];
    uint32_t slot;
  } data;
} cacheline_t;

void partitioning(Shard* sh, const Configuration& config, const RadixContext& context, 
        std::unique_ptr<input_reader::InputReaderU64> reader) {
  auto shard_idx = sh->shard_idx;
  auto R = context.R;
  auto fanOut = context.fanOut;
  uint64_t** hists = context.hists;
  uint64_t** partitions = context.partitions;
  std::uint64_t num_kmers{};
  
  // Two ways:
  // 1: rel tmp
  // 2: file cache tmp
  uint32_t MASK = context.mask;

  // Assume less than 4G tuples per local partition
  uint64_t* hist = (uint64_t*)calloc(fanOut, sizeof(int64_t));
  hists[shard_idx] = hist;
  for (uint64_t kmer; reader->next(&kmer);) {
    auto hash_val = HASHER((char*)&kmer, sizeof(Kmer));
    uint32_t idx = HASH_BIT_MODULO(hash_val, MASK, R);
    hist[idx]++;
    num_kmers++;
  }
    
  // Need paddding so that the size of each partition is an integer multiple of the cache line size
  for (uint32_t i = 0; i < fanOut; i++) {
    auto hist_i = hist[i];
    auto mod = hist_i % KMERSPERCACHELINE;
    hist[i] = mod == 0 ? hist_i : (hist_i + KMERSPERCACHELINE - mod);
  }

  uint32_t sum = 0;
  /* compute local prefix sum on hist so that we can get the start and end position of each partition */
  for (uint32_t i = 0; i < fanOut; i++) {
    sum += hist[i];
    hist[i] = sum;
  }

  uint64_t* locals =
      (uint64_t*)std::aligned_alloc(PAGESIZE, hist[fanOut - 1] * sizeof(Kmer));
  partitions[shard_idx] = locals;

  cacheline_t* buffer = (cacheline_t*)std::aligned_alloc(
      CACHE_LINE_SIZE, sizeof(cacheline_t) * fanOut);

  for (uint32_t i = 0; i < fanOut; i++) {
    buffer[i].data.slot = i == 0 ? 0 : hist[i - 1];
  }

  auto new_reader = input_reader::MakeFastqKMerPreloadReader(
      config.K, config.in_file, sh->shard_idx, config.num_threads);
  for (uint64_t kmer; new_reader->next(&kmer);) {
    auto hash_val = HASHER(&kmer, sizeof(Kmer));
    uint32_t idx = HASH_BIT_MODULO(hash_val, MASK, R);
    uint32_t slot = buffer[idx].data.slot;
    Kmer* part = (Kmer*)(buffer + idx);
    // Only works if KMERSPERCACHELINE is a power of 2
    uint32_t slotMod = (slot) & (KMERSPERCACHELINE - 1);
    part[slotMod] = kmer;

    if (slotMod == (KMERSPERCACHELINE - 1)) {
      /* write out 64-Bytes with non-temporal store */
      store_nontemp_64B((locals + slot - (KMERSPERCACHELINE - 1)),
                        (buffer + idx));
      /* writes += TUPLESPERCACHELINE; */
    }

    buffer[idx].data.slot = slot + 1;
  }
}

void KmerTest::count_kmer_radix(Shard* sh, const Configuration& config,
                                std::barrier<VoidFn>* barrier,
                                RadixContext& context) {
  auto hashmaps_per_thread = context.hashmaps_per_thread; 
  auto nthreads_d = context.nthreads_d;
  auto gathering_threads = 1 << nthreads_d;
  uint64_t** hists = context.hists;
  uint64_t** partitions = context.partitions;

  auto shard_idx = sh->shard_idx;

  // Be care of the `K` here; it's a compile time constant.
  auto reader = input_reader::MakeFastqKMerPreloadReader(
      config.K, config.in_file, sh->shard_idx, config.num_threads);

  std::uint64_t start = _rdtsc();
  // start timers
  std::uint64_t
      start_cycles{}, 
      end_cycles{},
      start_partition_cycle, 
      end_partition_cycle,
      start_insertions_cycle,
      end_insertions_cycle
  ;
  std::chrono::time_point<std::chrono::steady_clock> 
      start_ts, 
      end_ts, 
      start_partition_ts, 
      end_partition_ts,
      start_insertions_ts,
      end_insertions_ts
      ;

  if (sh->shard_idx == 0) {
    start_ts = std::chrono::steady_clock::now();
    start_cycles = _rdtsc();
  }

  start_partition_ts = std::chrono::steady_clock::now();
  start_partition_cycle = _rdtsc();

  partitioning(sh, config, context, 
          std::move(reader));

  end_partition_ts = std::chrono::steady_clock::now();
  end_partition_cycle = _rdtsc();

  barrier->arrive_and_wait();

  auto num_threads = config.num_threads;

  // if (shard_idx == 0) {
  //     PLOGI.printf("=== Hists after paddding:");
  //     PLOGI.printf("Partition time: %u", _rdtsc() - start);
  //     uint64_t total_mem = 0;
  //     for (uint32_t ti = 0; ti < num_threads; ti++) {
  //         auto count = hists[ti][fanOut - 1];
  //         total_mem += count;
  //         PLOGI.printf("IDX: %u, Count: %u, size: %u M", ti, count, count * sizeof(Kmer) / (1024 * 1024));
  //     } 
  //     PLOGI.printf("Total mem: %u M", total_mem * sizeof(Kmer) / (1024 * 1024));
  //     for (uint32_t ti = 0; ti < num_threads; ti++) {
  //         PLOGI.printf("Shard IDX: %u", ti);
  //         for (uint32_t i = 0; i < fanOut; i++) {
  //           auto count = hists[ti][i];
  //           PLOGI.printf("Partition: %u: %u, size: %u M", i, count, count * sizeof(Kmer) / (1024 * 1024));
  //         }
  //     } 
  // }

  if (shard_idx >= gathering_threads) {
    PLOGW.printf("Thread %u goes idle after partitioning.", shard_idx);
    return;
  }


  start_insertions_ts = std::chrono::steady_clock::now();
  start_insertions_cycle = _rdtsc();
  std::vector<absl::flat_hash_map<Kmer, uint64_t>> maps;
  maps.reserve(hashmaps_per_thread);

  uint64_t total_insertions = 0; 
  for (uint32_t k = 0; k < hashmaps_per_thread; k++) {
    
    uint32_t partition_idx = hashmaps_per_thread * shard_idx + k;
  uint64_t total_num_kmers = 0;
  for (uint32_t i = 0; i < num_threads; i++) {
    uint64_t start = partition_idx == 0u ? 0u : hists[i][partition_idx - 1];
    uint64_t end = hists[i][partition_idx];
    total_num_kmers += end - start;
  }
  // PLOGI.printf("Shard IDX: %u, total: %u", shard_idx, total);
  // BaseHashTable* ht = init_ht_radix(total, shard_idx);
  // HTBatchRunner batch_runner(ht);
  absl::flat_hash_map<Kmer, uint64_t> counter(
        total_num_kmers);  // 1GB initial size.
  // counter.reserve(total >> 6);
  for (uint32_t i = 0; i < num_threads; i++) {
    uint64_t start = partition_idx == 0u ? 0u : hists[i][partition_idx - 1];
    uint64_t end = hists[i][partition_idx];
    if (i == 1) {
        PLOGI.printf("IDX: %u, remote: %u, start: %u end: %u", shard_idx, i, start, end);
    }
    total_insertions += end - start;
    for (; start < end; start++) {
          counter[partitions[i][start]]++;  
      // batch_runner.insert(partitions[i][start],
      //                     0 /* we use the aggr tables so no value */);
        }
    }
    context.hashmaps[shard_idx].push_back(std::move(counter));
  }
  // batch_runner.flush_insert();

  PLOGI.printf("Shard IDX: %u, Finish insertions, hit barrier", shard_idx);

  end_insertions_ts = std::chrono::steady_clock::now();
  end_insertions_cycle = _rdtsc();

  barrier->arrive_and_wait();

  sh->stats->insertions.duration = _rdtsc() - start;
  sh->stats->insertions.op_count = total_insertions;
  // PLOG_INFO.printf("IDX: %u, num_kmers: %u, fill: %u", shard_idx, num_kmers, ht->get_fill());
  for (uint32_t i = 0; i < hashmaps_per_thread; i++) {
    PLOG_INFO.printf("IDX: %u, cap: %u, fill: %u", shard_idx, maps[i].capacity(), maps[i].size());
  }
  if (sh->shard_idx == 0) {
    end_ts = std::chrono::steady_clock::now();
    end_cycles = _rdtsc();
    PLOG_INFO.printf(
        "Kmer insertion took %llu us (%llu cycles)",
        chrono::duration_cast<chrono::microseconds>(end_ts - start_ts).count(),
        end_cycles - start_cycles);
    
    check_functionality(config, context);
  }
  auto partition_time = chrono::duration_cast<chrono::microseconds>(end_partition_ts - start_partition_ts).count(); 
  auto partition_cycles = end_partition_cycle - start_partition_cycle;
  auto insertion_time = chrono::duration_cast<chrono::microseconds>(end_insertions_ts - start_insertions_ts).count();
  auto insertion_cycles = end_insertions_cycle - start_insertions_cycle;
  auto total_time = partition_time + insertion_time;
  auto time_per_insertion = (double) insertion_time / (double) total_insertions;
  auto cycles_per_insertion = insertion_cycles / total_insertions;
  PLOG_INFO.printf("IDX: %u, partition time: %llu us (%llu cycles)(%llu %%), insertion time: %llu us (%llu cycles)(%llu %%), time_per_insertion: %.4f us(%llu cycles)", 
        shard_idx,
        partition_time,
        partition_cycles,
        partition_time * 100 / total_time,
        insertion_time,
        insertion_cycles,
        insertion_time * 100 / total_time,
        time_per_insertion,
        cycles_per_insertion
          );
  PLOGV.printf("[%d] Num kmers %llu", sh->shard_idx, total_insertions);
  // get_ht_stats(sh, ht);
}

}  // namespace kmercounter
