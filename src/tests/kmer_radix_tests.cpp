#include <absl/container/flat_hash_map.h>
#include <plog/Log.h>

#include <algorithm>
#include <atomic>
#include <barrier>
#include <cstdint>

#include "constants.hpp"
#include "hashtables/base_kht.hpp"
#include "hashtables/batch_runner/batch_runner.hpp"
#include "hashtables/cas_kht_single.hpp"
#include "hashtables/kvtypes.hpp"
#include "input_reader/counter.hpp"
#include "input_reader/fastq.hpp"
#include "print_stats.h"
#include "sync.h"
#include "tests/KmerTest.hpp"
#include "types.hpp"

namespace kmercounter {

#define HASHER XXH3_64bits

absl::flat_hash_map<Kmer, long> check_count(
    const absl::flat_hash_map<Kmer, uint64_t>& reference,
    const absl::flat_hash_map<Kmer, uint64_t>& aggregation) {
  absl::flat_hash_map<Kmer, long> diff;
  for (const auto& entry : reference) {
    auto key = entry.first;
    auto val = entry.second;
    if (aggregation.contains(key)) {
      auto agg_val = aggregation.at(key);
      if (val != agg_val) {
        diff[key] = (long)agg_val - (long)val;
      }
    } else {
      diff[key] = val;
    }
  }
  return diff;
}

absl::flat_hash_map<Kmer, uint64_t> build_ref(const Configuration& config) {
  PLOGI.printf("Building reference HT reader");
  // Be care of the `K` here; it's a compile time constant.
  auto reader =
      input_reader::MakeFastqKMerPreloadReader(config.K, config.in_file, 0, 1);

  PLOGI.printf("Alloc reference HT");
  absl::flat_hash_map<Kmer, uint64_t> counter(1 << 20);
  PLOGI.printf("Count reference HT");
  counter.reserve(1 << 20);
  for (uint64_t kmer; reader->next(&kmer);) {
    counter[kmer]++;
  }
  return counter;
}

void check_functionality(const Configuration& config,
                         const RadixContext& context) {
  auto reference = build_ref(config);
  auto aggregation = context.aggregate();
  auto diff = check_count(reference, aggregation);
  auto rev_diff = check_count(aggregation, reference);
  for (auto& entry : rev_diff) {
    assert(entry.second < 0);
  }
  uint64_t max_diff = 0;
  Kmer max_diff_kmer = 0;
  for (auto& entry : diff) {
    auto abs_diff = std::abs(entry.second);

    assert(entry.second > 0);
    if (abs_diff > max_diff) {
      max_diff = abs_diff;
      max_diff_kmer = entry.first;
    }
  }
  PLOGI.printf(
      "Diff kmer: %llu(rev: %llu); total distinct kmer: (ref: %llu, aggr: "
      "%llu); max diff: %llu(ref: %llu);",
      diff.size(), rev_diff.size(), reference.size(), aggregation.size(),
      max_diff, reference[max_diff_kmer]);
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

uint64_t partitioning(Shard* sh, const Configuration& config,
                      RadixContext& context,
                      std::unique_ptr<input_reader::InputReaderU64> reader) {
  auto shard_idx = sh->shard_idx;
  auto R = context.R;
  auto fanOut = context.fanOut;
  auto sz = sh->f_end - sh->f_start;

  // Two ways:
  // 1: rel tmp
  // 2: file cache tmp
  uint32_t MASK = context.mask;

  // uint64_t* hist = (uint64_t*)calloc(fanOut, sizeof(int64_t));
  // hists[shard_idx] = hist;
  // for (uint64_t kmer; reader->next(&kmer);) {
  //   auto hash_val = HASHER((char*)&kmer, sizeof(Kmer));
  //   uint32_t idx = HASH_BIT_MODULO(hash_val, MASK, R);
  //   hist[idx]++;
  //   num_kmers++;
  // }
  //
  // // Need paddding so that the size of each partition is an integer multiple
  // of the cache line size for (uint32_t i = 0; i < fanOut; i++) {
  //   auto hist_i = hist[i];
  //   auto mod = hist_i % KMERSPERCACHELINE;
  //   hist[i] = mod == 0 ? hist_i : (hist_i + KMERSPERCACHELINE - mod);
  // }
  //
  // uint32_t sum = 0;
  // /* compute local prefix sum on hist so that we can get the start and end
  // position of each partition */ for (uint32_t i = 0; i < fanOut; i++) {
  //   sum += hist[i];
  //   hist[i] = sum;
  // }

  PLOGI.printf("IDX: %u, sz: %llu", shard_idx, sz / fanOut);
  auto start_alloc = _rdtsc();
  // uint64_t* locals =
  //     (uint64_t*)std::aligned_alloc(PAGESIZE, hist[fanOut - 1] *
  //     sizeof(Kmer));
  for (int i = 0; i < fanOut; i++) {
    context.partitions[shard_idx].push_back(PartitionChunks(sz / fanOut));
  }
  cacheline_t* buffers = (cacheline_t*)std::aligned_alloc(
      CACHELINE_SIZE, sizeof(cacheline_t) * fanOut);
  auto end_alloc = _rdtsc() - start_alloc;
  // PLOGI.printf("IDX: %u, Partition alloc: %llu cycles", shard_idx,
  // end_alloc); partitions[shard_idx] = locals;

  for (uint32_t i = 0; i < fanOut; i++) {
    buffers[i].data.slot = 0;
  }

  auto start_swb = _rdtsc();
  for (uint64_t kmer; reader->next(&kmer);) {
    auto hash_val = HASHER(&kmer, sizeof(Kmer));
    uint32_t idx = HASH_BIT_MODULO(hash_val, MASK, R);
    uint32_t slot = buffers[idx].data.slot;
    Kmer* part = (Kmer*)(buffers + idx);
    // Only works if KMERSPERCACHELINE is a power of 2
    uint32_t slotMod = (slot) & (KMERSPERCACHELINE - 1);
    part[slotMod] = kmer;

    if (slotMod == (KMERSPERCACHELINE - 1)) {
      PartitionChunks* partitionChunk = &(context.partitions[shard_idx][idx]);
      // PLOGI.printf("partitions size: %llu, partition array: %llu, IDX: %u,
      // idx: %u", context.partitions.size(),
      // context.partitions[shard_idx].size(), shard_idx, idx);
      auto next_loc = partitionChunk->get_next();
      partitionChunk->advance();
      /* write out 64-Bytes with non-temporal store */
      store_nontemp_64B(next_loc, (buffers + idx));
      /* writes += TUPLESPERCACHELINE; */
    }
    buffers[idx].data.slot = slot + 1;
  }
  auto swb_end = _rdtsc();
  PLOGI.printf(
      "IDX: %u;SWB: %llu cycles; Timestamp: %llu; Partition_alloc: %llu",
      shard_idx, swb_end - start_swb, swb_end - context.global_time, end_alloc);
  return (uint64_t)swb_end;
}

void KmerTest::count_kmer_radix(Shard* sh, const Configuration& config,
                                std::barrier<VoidFn>* barrier,
                                RadixContext& context) {
  auto hashmaps_per_thread = context.hashmaps_per_thread;
  auto nthreads_d = context.nthreads_d;
  auto gathering_threads = 1 << nthreads_d;
  uint64_t** hists = context.hists;
  uint64_t** partitions = context.parts;

  auto shard_idx = sh->shard_idx;

  // Be care of the `K` here; it's a compile time constant.
  auto first_reader_start = _rdtsc();
  auto reader = input_reader::MakeFastqKMerPreloadReader(
      config.K, config.in_file, sh->shard_idx, config.num_threads);
  auto first_reader_diff = _rdtsc() - first_reader_start;
  PLOGI.printf("First reader cycles: %llu, First start: %llu, current: %llu",
               first_reader_diff, first_reader_start - context.global_time,
               _rdtsc() - context.global_time);
  std::uint64_t start = _rdtsc();
  // start timers
  std::uint64_t start_cycles{}, end_cycles{}, start_partition_cycle,
      end_partition_cycle, start_insertions_cycle, end_insertions_cycle;
  std::chrono::time_point<std::chrono::steady_clock> start_ts, end_ts,
      start_partition_ts, end_partition_ts, start_insertions_ts,
      end_insertions_ts;

  if (sh->shard_idx == 0) {
    start_ts = std::chrono::steady_clock::now();
    start_cycles = _rdtsc();
  }

  start_partition_ts = std::chrono::steady_clock::now();
  start_partition_cycle = _rdtsc();

  partitioning(sh, config, context, std::move(reader));
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
  //         PLOGI.printf("IDX: %u, Count: %u, size: %u M", ti, count, count *
  //         sizeof(Kmer) / (1024 * 1024));
  //     }
  //     PLOGI.printf("Total mem: %u M", total_mem * sizeof(Kmer) / (1024 *
  //     1024)); for (uint32_t ti = 0; ti < num_threads; ti++) {
  //         PLOGI.printf("Shard IDX: %u", ti);
  //         for (uint32_t i = 0; i < fanOut; i++) {
  //           auto count = hists[ti][i];
  //           PLOGI.printf("Partition: %u: %u, size: %u M", i, count, count *
  //           sizeof(Kmer) / (1024 * 1024));
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
        PLOGI.printf("IDX: %u, remote: %u, start: %u end: %u", shard_idx, i,
                     start, end);
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
  // PLOG_INFO.printf("IDX: %u, num_kmers: %u, fill: %u", shard_idx, num_kmers,
  // ht->get_fill());
  for (uint32_t i = 0; i < hashmaps_per_thread; i++) {
    PLOG_INFO.printf("IDX: %u, cap: %zu, fill: %u", shard_idx,
                     context.hashmaps[shard_idx][i].capacity(),
                     context.hashmaps[shard_idx][i].size());
  }
  if (sh->shard_idx == 0) {
    end_ts = std::chrono::steady_clock::now();
    end_cycles = _rdtsc();
    PLOG_INFO.printf(
        "Kmer insertion took %llu us (%llu cycles)",
        chrono::duration_cast<chrono::microseconds>(end_ts - start_ts).count(),
        end_cycles - start_cycles);
    // check_functionality(config, context);
  }

  auto partition_time = chrono::duration_cast<chrono::microseconds>(
                            end_partition_ts - start_partition_ts)
                            .count();
  auto partition_cycles = end_partition_cycle - start_partition_cycle;
  auto insertion_time = chrono::duration_cast<chrono::microseconds>(
                            end_insertions_ts - start_insertions_ts)
                            .count();
  auto insertion_cycles = end_insertions_cycle - start_insertions_cycle;
  auto total_time = partition_time + insertion_time;
  auto time_per_insertion = (double)insertion_time / (double)total_insertions;
  auto cycles_per_insertion = insertion_cycles / total_insertions;
  PLOG_INFO.printf(
      "IDX: %u, partition time: %llu us (%llu cycles)(%llu %%), insertion "
      "time: %llu us (%llu cycles)(%llu %%), time_per_insertion: %.4f us(%llu "
      "cycles)",
      shard_idx, partition_time, partition_cycles,
      partition_time * 100 / total_time, insertion_time, insertion_cycles,
      insertion_time * 100 / total_time, time_per_insertion,
      cycles_per_insertion);
  PLOGV.printf("[%d] Num kmers %llu", sh->shard_idx, total_insertions);
  // get_ht_stats(sh, ht);
}

void KmerTest::count_kmer_radix_custom(Shard* sh, const Configuration& config,
                                       std::barrier<VoidFn>* barrier,
                                       RadixContext& context) {
  auto hashmaps_per_thread = context.hashmaps_per_thread;
  auto nthreads_d = context.nthreads_d;
  auto gathering_threads = 1 << nthreads_d;

  auto shard_idx = sh->shard_idx;

  auto first_reader_start = _rdtsc();
  // Be care of the `K` here; it's a compile time constant.
  auto reader = input_reader::MakeFastqKMerPreloadReader(
      config.K, config.in_file, sh->shard_idx, config.num_threads);
  auto first_reader_diff = _rdtsc() - first_reader_start;
  PLOGI.printf("First reader cycles: %llu, First start: %llu, current: %llu",
               first_reader_diff, first_reader_start - context.global_time,
               _rdtsc() - context.global_time);

  auto ht_alloc_start = _rdtsc();
  std::vector<CASHashTableSingle<KVType, ItemQueue>*> prealloc_maps;
  prealloc_maps.reserve(hashmaps_per_thread);
  for (int i = 0; i < hashmaps_per_thread; i++) {
    auto ht = new CASHashTableSingle<KVType, ItemQueue>((1 << 26) /
                                                        hashmaps_per_thread);
    prealloc_maps.push_back(ht);
  }
  InsertFindArgument arg;
  arg.value = 0;
  auto ht_alloc_time = _rdtsc() - ht_alloc_start;
  PLOGI.printf("IDX: %u, HT alloc cycle per Kmer: %llu, total cycles: %llu",
               shard_idx, ht_alloc_time / (1 << 26), ht_alloc_time);

  // start timers
  std::uint64_t start_cycles{}, end_cycles{}, start_partition_cycle,
      end_partition_cycle, start_insertions_cycle, end_insertions_cycle;
  std::chrono::time_point<std::chrono::steady_clock> start_ts, end_ts,
      start_partition_ts, end_partition_ts, start_insertions_ts,
      end_insertions_ts;

  // barrier->arrive_and_wait();

  if (sh->shard_idx == 0) {
    start_ts = std::chrono::steady_clock::now();
    start_cycles = _rdtsc();
  }

  // Wait for all readers finish initializing.
  barrier->arrive_and_wait();

  std::uint64_t start_shard = _rdtsc();
  start_partition_ts = std::chrono::steady_clock::now();
  start_partition_cycle = _rdtsc();
  auto part_alloc = partitioning(sh, config, context, std::move(reader));
  // start_shard = part_alloc;
  // start_partition_cycle += part_alloc;
  end_partition_ts = std::chrono::steady_clock::now();
  end_partition_cycle = _rdtsc();

  barrier->arrive_and_wait();
  auto after_first_barrier = _rdtsc() - end_partition_cycle;

  PLOGI.printf("IDX: %u Start partitioning at: %llu, gap: %llu", shard_idx,
               start_partition_cycle - context.global_time,
               end_partition_cycle - part_alloc);
  PLOGI.printf(
      "IDX: %u, time spent at the first barrier: %llu cycles, reaching barrier "
      "at: %llu",
      shard_idx, after_first_barrier,
      end_partition_cycle - context.global_time);
  // start_shard += after_first_barrier;
  auto num_threads = config.num_threads;

  // if (shard_idx == 0) {
  //     PLOGI.printf("=== Hists after paddding:");
  //     PLOGI.printf("Partition time: %u", _rdtsc() - start);
  //     uint64_t total_mem = 0;
  //     for (uint32_t ti = 0; ti < num_threads; ti++) {
  //         auto count = hists[ti][fanOut - 1];
  //         total_mem += count;
  //         PLOGI.printf("IDX: %u, Count: %u, size: %u M", ti, count, count *
  //         sizeof(Kmer) / (1024 * 1024));
  //     }
  //     PLOGI.printf("Total mem: %u M", total_mem * sizeof(Kmer) / (1024 *
  //     1024)); for (uint32_t ti = 0; ti < num_threads; ti++) {
  //         PLOGI.printf("Shard IDX: %u", ti);
  //         for (uint32_t i = 0; i < fanOut; i++) {
  //           auto count = hists[ti][i];
  //           PLOGI.printf("Partition: %u: %u, size: %u M", i, count, count *
  //           sizeof(Kmer) / (1024 * 1024));
  //         }
  //     }
  // }

  if (shard_idx >= gathering_threads) {
    PLOGW.printf("Thread %u goes idle after partitioning.", shard_idx);
    return;
  }

  std::vector<BaseHashTable*> maps;

  // maps.reserve(32);
  // if (shard_idx == 0) {
  //     size_t num = (1llu << 26) * 32;
  //     for (int i = 0; i < 1; i++) {
  //        auto start_ht = _rdtsc();
  //        auto ht = aligned_alloc(PAGE_SIZE, num * 16);
  //        memset(ht, 0, num * 16);
  //        // auto ht = new CASHashTableSingle<KVType, ItemQueue>( - 100);
  //        auto end_ht = _rdtsc() - start_ht;
  //        PLOGI.printf("Iter: %u, alloc cycles: %llu, cycles per elem: %llu",
  //        i, end_ht, end_ht / num);
  //        maps.push_back(std::move((BaseHashTable*)ht));
  //     }
  // }
  // return;
  maps.reserve(hashmaps_per_thread);

  uint64_t total_insertions = 0;

  start_insertions_ts = std::chrono::steady_clock::now();
  start_insertions_cycle = _rdtsc();
  // std::vector<size_t> gather_hist(hashmaps_per_thread);
  // for (uint32_t k = 0; k < hashmaps_per_thread; k++) {
  //     uint32_t partition_idx = hashmaps_per_thread * shard_idx + k;
  //     uint64_t total_num_kmers = 0;
  //     for (uint32_t i = 0; i < num_threads; i++) {
  //       uint64_t start = partition_idx == 0u ? 0u : hists[i][partition_idx -
  //       1]; uint64_t end = hists[i][partition_idx]; total_num_kmers += end -
  //       start;
  //     }
  //     gather_hist.push_back(total_num_kmers);
  // }
  // for (uint32_t k = 1; k < hashmaps_per_thread; k++) {
  //     gather_hist[k] += gather_hist[k - 1];
  // }

  // auto total_capacity = gather_hist[hashmaps_per_thread - 1] *
  // sizeof(KVType); auto shared_hash_array = (KVType*)
  // std::aligned_alloc(PAGESIZE, total_capacity); auto shared_insert_queue =
  // (ItemQueue *)(aligned_alloc(CACHELINE_SIZE, PREFETCH_QUEUE_SIZE *
  // sizeof(ItemQueue))); memset(shared_hash_array, 0, total_capacity);

  for (uint32_t k = 0; k < hashmaps_per_thread; k++) {
    uint32_t partition_idx = hashmaps_per_thread * shard_idx + k;
    // uint64_t total_num_kmers = gather_hist[k] - (k == 0? 0: gather_hist[k -
    // 1]);
    uint64_t total_num_kmers = 0;
    for (uint32_t i = 0; i < num_threads; i++) {
      // uint64_t start = partition_idx == 0u ? 0u : hists[i][partition_idx -
      // 1]; uint64_t end = hists[i][partition_idx];
      for (auto& chunk : context.partitions[i][partition_idx].chunks) {
        total_num_kmers += chunk.count;
      }
    }

    total_insertions += total_num_kmers;
    //
    //     gather_hist.push_back(total_num_kmers);
    // auto slice = shared_hash_array + (k == 0? 0: gather_hist[k - 1]);

    // PLOGI.printf("Shard IDX: %u, total: %u", shard_idx, total);
    // auto ht_alloc_start = _rdtsc();
    // auto ht = new CASHashTableSingle<KVType, ItemQueue>(total_num_kmers);
    // auto ht_alloc_time = _rdtsc() - ht_alloc_start;
    // start_shard += ht_alloc_time;
    // start_insertions_cycle += ht_alloc_time;
    auto ht = prealloc_maps[k];
    // PLOGI.printf("IDX: %u, HT alloc cycle per Kmer: %llu, total cycles:
    // %llu", shard_idx, ht_alloc_time / total_num_kmers, ht_alloc_time);
    // counter.reserve(total >> 6);

    // uint64_t xori = 0;
    auto count_inner = 0;

    auto start_insertions_cycle_inner = _rdtsc();
    for (uint32_t i = 0; i < num_threads; i++) {
      // uint64_t start = partition_idx == 0u ? 0u : hists[i][partition_idx -
      // 1]; uint64_t end = hists[i][partition_idx];
      auto& chunks = context.partitions[i][partition_idx];

      // if (i == 1) {
      //     PLOGI.printf("IDX: %u, remote: %u, start: %u end: %u", shard_idx,
      //     i, start, end);
      // }
      // auto count_innest = chunks.total_count;
      // count_inner += count_innest;

      auto start_insertions_cycle_innest = _rdtsc();
      for (auto chunk : chunks.chunks) {
        count_inner += chunk.count;
        for (int j = 0; j < chunk.count; j++) {
          arg.key = chunk.kmers[j];
          ht->insert_one(&arg, nullptr);
        }
      }

      // for (size_t k = start; k < end; k++) {
      //     // xori = xori + 1;
      //     // __asm("");
      //      // xori ^= partitions[i][k];
      //      // batch_runner.insert(partitions[i][k], 0 /* we use the aggr
      //      tables so no value */); arg.key = partitions[i][k];
      //      ht->insert_one(&arg, nullptr);
      //     }
      //     auto diff = _rdtsc() - start_insertions_cycle_innest;
      //     PLOGI.printf("IDX:%u; remote: %u; Innest: cycles: %llu,
      //     cycles_per_in: %llu , start: %llu; end: %llu; total: %llu.",
      //             shard_idx, i, diff, diff / count_innest, start, end,
      //             count_innest);
    }

    auto diff = _rdtsc() - start_insertions_cycle_inner;
    PLOGI.printf("Inner: cycles: %llu, cycles_per_in: %llu", diff,
                 diff / count_inner);
    // batch_runner.insert(xori, 0 /* we use the aggr tables so no value */);
    // batch_runner.flush_insert();

    // absl::flat_hash_map<Kmer, uint64_t> counter(
    // total_num_kmers);  // 1GB initial size.
    // ht->aggregate(counter);
    // context.hashmaps[shard_idx].push_back(std::move(counter));

    maps.push_back(ht);
  }

  // PLOGI.printf("Shard IDX: %u, Finish insertions, hit barrier", shard_idx);
  PLOGI.printf("Shard IDX: %u, Finish insertions, hit barrier", shard_idx);
  end_insertions_ts = std::chrono::steady_clock::now();
  end_insertions_cycle = _rdtsc();

  barrier->arrive_and_wait();

  PLOGI.printf("IDX: %u, time spent at the second barrier: %llu cycles",
               shard_idx, _rdtsc() - end_insertions_cycle);

  sh->stats->insertions.duration = _rdtsc() - start_shard;
  sh->stats->insertions.op_count = total_insertions;
  // PLOG_INFO.printf("IDX: %u, num_kmers: %u, fill: %u", shard_idx, num_kmers,
  // ht->get_fill());
  for (uint32_t i = 0; i < hashmaps_per_thread; i++) {
    PLOG_INFO.printf("IDX: %u, cap: %u, fill: %u", shard_idx,
                     maps[i]->get_capacity(), maps[i]->get_fill());
  }
  if (sh->shard_idx == 0) {
    end_ts = std::chrono::steady_clock::now();
    end_cycles = _rdtsc();
    PLOG_INFO.printf(
        "Kmer insertion took %llu us (%llu cycles)",
        chrono::duration_cast<chrono::microseconds>(end_ts - start_ts).count(),
        end_cycles - start_cycles);
    // check_functionality(config, context);
  }
  auto partition_time = chrono::duration_cast<chrono::microseconds>(
                            end_partition_ts - start_partition_ts)
                            .count();
  auto partition_cycles = end_partition_cycle - start_partition_cycle;
  auto insertion_time = chrono::duration_cast<chrono::microseconds>(
                            end_insertions_ts - start_insertions_ts)
                            .count();
  auto insertion_cycles = end_insertions_cycle - start_insertions_cycle;
  auto total_time = partition_time + insertion_time;
  auto time_per_insertion = (double)insertion_time / (double)total_insertions;
  auto cycles_per_insertion = insertion_cycles / total_insertions;
  PLOG_INFO.printf(
      "IDX: %u, partition time: %llu us (%llu cycles)(%llu %%), insertion "
      "time: %llu us (%llu cycles)(%llu %%), time_per_insertion: %.4f us(%llu "
      "cycles)",
      shard_idx, partition_time, partition_cycles,
      partition_time * 100 / total_time, insertion_time, insertion_cycles,
      insertion_time * 100 / total_time, time_per_insertion,
      cycles_per_insertion);
  PLOGV.printf("[%d] Num kmers %llu", sh->shard_idx, total_insertions);
  // get_ht_stats(sh, ht);
}

}  // namespace kmercounter
