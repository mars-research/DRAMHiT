#include <plog/Log.h>

#include <algorithm>
#include <atomic>
#include <barrier>
#include <cstdint>

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


typedef uint64_t Kmer;

// #define KMERPERPAGE (PAGESIZE - sizeof(uint64_t*))/sizeof(Kmer)

// struct PageLinkedList {
//     Kmer kmers[KMERPERPAGE];
//     PageLinkedList* next;
// };

BaseHashTable* init_ht_radix(const uint64_t sz, uint8_t id) {
  BaseHashTable* kmer_ht = NULL;

  // Create hash table
  switch (config.ht_type) {
    case PARTITIONED_HT:
      kmer_ht = new PartitionedHashStore<KVType, ItemQueue>(sz, id);
      break;
    case CASHTPP:
      /* For the CAS Hash table, size is the same as
          size of one partitioned ht * number of threads */
      kmer_ht =
          new CASHashTable<KVType, ItemQueue>(sz);  // * config.num_threads);
      break;
    case ARRAY_HT:
      kmer_ht = new ArrayHashTable<Value, ItemQueue>(sz);
      break;
    default:
      PLOG_FATAL.printf("HT type not implemented");
      exit(-1);
      break;
  }
  return kmer_ht;
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

struct Task {};
// A queue of tasks, select the thread with most localized memeory to consume it

void KmerTest::count_kmer_radix(Shard* sh, const Configuration& config,
                                std::barrier<VoidFn>* barrier,
                                RadixContext& context) {
  auto D = context.D;
  auto R = context.R;
  auto fanOut = context.fanOut;
  uint32_t** hists = context.hists;
  uint64_t** partitions = context.partitions;

  auto shard_idx = sh->shard_idx;
  // Two ways:
  // 1: rel tmp
  // 2: file cache tmp
  off64_t seg_size = (sh->f_end - sh->f_start) * PAGESIZE;
  uint32_t MASK = context.mask;

  // Assume less than 4G tuples per local partition
  uint32_t* hist = (uint32_t*)calloc(fanOut, sizeof(int32_t));
  hists[shard_idx] = hist;

  // Be care of the `K` here; it's a compile time constant.
  auto reader = input_reader::MakeFastqKMerPreloadReader(
      config.K, config.in_file, sh->shard_idx, config.num_threads);

  // start timers
  std::uint64_t start{};
  std::uint64_t start_cycles{}, end_cycles{};
  std::uint64_t num_kmers{};
  std::chrono::time_point<std::chrono::steady_clock> start_ts, end_ts;
  start = _rdtsc();

  if (sh->shard_idx == 0) {
    start_ts = std::chrono::steady_clock::now();
    start_cycles = _rdtsc();
  }
  
  for (uint64_t kmer; reader->next(&kmer);) {
    auto hash_val = XXH3_64bits((char*)&kmer, sizeof(Kmer));
    uint32_t idx = HASH_BIT_MODULO(hash_val, MASK, R);
    hist[idx]++;
    num_kmers++;
  }
    
  // Need paddding
  for (uint32_t i = 0; i < fanOut; i++) {
    auto hist_i = hist[i];
    auto mod = hist_i % KMERSPERCACHELINE;
    hist[i] = mod == 0 ? hist_i : (hist_i + KMERSPERCACHELINE - mod);
  }

  uint32_t sum = 0;
  /* compute local prefix sum on hist */
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
    auto hash_val = XXH3_64bits(&kmer, sizeof(Kmer));
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

  barrier->arrive_and_wait();
  auto num_threads = config.num_threads;

  if (shard_idx == 0) {
      PLOGI.printf("=== Hists after paddding:");
      for (uint32_t ti = 0; ti < num_threads; ti++) {
          PLOGI.printf("Shard IDX: %u", ti);
          for (uint32_t i = 0; i < fanOut; i++) {
            PLOGI.printf("Partition: %u: %u", i, hists[ti][i]);
          }
      } 
  }

  if (shard_idx >= fanOut) {
    PLOGW.printf("Thread %u goes idle after partitioning.", shard_idx);
    return;
  }

  size_t total = 0;
  for (uint32_t i = 0; i < num_threads; i++) {
    auto start = shard_idx == 0 ? 0 : hists[i][shard_idx - 1];
    auto end = hists[i][shard_idx];
    total += end - start;
  }
  BaseHashTable* ht = init_ht_radix(total, shard_idx);
  HTBatchRunner batch_runner(ht);
  for (uint32_t i = 0; i < num_threads; i++) {
    auto start = shard_idx == 0 ? 0 : hists[i][shard_idx - 1];
    auto end = hists[i][shard_idx];
    for (; start < end; start++) {
      batch_runner.insert(partitions[i][start],
                          0 /* we use the aggr tables so no value */);
    }
  }
  batch_runner.flush_insert();

  barrier->arrive_and_wait();

  sh->stats->insertions.duration = _rdtsc() - start;
  sh->stats->insertions.op_count = num_kmers;
  PLOG_INFO.printf("IDX: %u, num_kmers: %u, fill: %u", shard_idx, num_kmers, ht->get_fill());
  if (sh->shard_idx == 0) {
    end_ts = std::chrono::steady_clock::now();
    end_cycles = _rdtsc();
    PLOG_INFO.printf(
        "Kmer insertion took %llu us (%llu cycles)",
        chrono::duration_cast<chrono::microseconds>(end_ts - start_ts).count(),
        end_cycles - start_cycles);
  }
  PLOGV.printf("[%d] Num kmers %llu", sh->shard_idx, num_kmers);

  get_ht_stats(sh, ht);
}

}  // namespace kmercounter
