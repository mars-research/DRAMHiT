#include <absl/container/flat_hash_map.h>
#include <plog/Log.h>

#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

#include <sys/syscall.h>
#include <unistd.h>

#include <algorithm>
#include <atomic>
#include <barrier>
#include <cstdint>
#include <queue>

#include "constants.hpp"
#include "hashtables/base_kht.hpp"
#include "hashtables/batch_runner/batch_runner.hpp"
// #include "hashtables/cas_kht_single.hpp"
#include "hashtables/kvtypes.hpp"
#include "input_reader/counter.hpp"
#include "input_reader/fastq.hpp"
#include "print_stats.h"
#include "sync.h"
#include "tests/KmerTest.hpp"
#include "types.hpp"
using namespace std;



namespace kmercounter {

// CRC3


// #define HASHER CityHash64

// absl::flat_hash_map<Kmer, long> check_count(
//     const absl::flat_hash_map<Kmer, uint64_t>& reference,
//     const absl::flat_hash_map<Kmer, uint64_t>& aggregation) {
//   absl::flat_hash_map<Kmer, long> diff;
//   for (const auto& entry : reference) {
//     auto key = entry.first;
//     auto val = entry.second;
//     if (aggregation.contains(key)) {
//       auto agg_val = aggregation.at(key);
//       if (val != agg_val) {
//         diff[key] = (long)agg_val - (long)val;
//       }
//     } else {
//       diff[key] = val;
//     }
//   }
//   return diff;
// }

// absl::flat_hash_map<Kmer, uint64_t> build_ref(const Configuration& config) {
//   PLOGI.printf("Building reference HT reader");
//   // Be care of the `K` here; it's a compile time constant.
//   auto reader =
//       input_reader::MakeFastqKMerPreloadReader(config.K, config.in_file, 0,
//       1);

//   PLOGI.printf("Alloc reference HT");
//   absl::flat_hash_map<Kmer, uint64_t> counter(1 << 20);
//   PLOGI.printf("Count reference HT");
//   counter.reserve(1 << 20);
//   for (uint64_t kmer; reader->next(&kmer);) {
//     counter[kmer]++;
//   }
//   return counter;
// }

// void check_functionality(const Configuration& config,
//                          const RadixContext& context) {
//   auto reference = build_ref(config);
//   auto aggregation = context.aggregate();
//   auto diff = check_count(reference, aggregation);
//   auto rev_diff = check_count(aggregation, reference);
//   for (auto& entry : rev_diff) {
//     assert(entry.second < 0);
//   }
//   uint64_t max_diff = 0;
//   Kmer max_diff_kmer = 0;
//   for (auto& entry : diff) {
//     auto abs_diff = std::abs(entry.second);

//     assert(entry.second > 0);
//     if (abs_diff > max_diff) {
//       max_diff = abs_diff;
//       max_diff_kmer = entry.first;
//     }
//   }
//   PLOGI.printf(
//       "Diff kmer: %llu(rev: %llu); total distinct kmer: (ref: %llu, aggr: "
//       "%llu); max diff: %llu(ref: %llu);",
//       diff.size(), rev_diff.size(), reference.size(), aggregation.size(),
//       max_diff, reference[max_diff_kmer]);
// }
/* #define RADIX_HASH(V)  ((V>>7)^(V>>13)^(V>>21)^V) */

// uint64_t partitioning(Shard* sh, const Configuration& config,
//                       RadixContext& context,
//                       std::unique_ptr<input_reader::InputReaderU64> reader,
//                       PartitionChunks* local_chunks) {
//   auto shard_idx = sh->shard_idx;
//   auto R = context.R;
//   auto fanOut = context.fanOut;
//   auto sz = sh->f_end - sh->f_start;

//   // Two ways:
//   // 1: rel tmp
//   // 2: file cache tmp
//   uint32_t MASK = context.mask;

//   // uint64_t* hist = (uint64_t*)calloc(fanOut, sizeof(int64_t));
//   // hists[shard_idx] = hist;
//   // for (uint64_t kmer; reader->next(&kmer);) {
//   //   auto hash_val = HASHER((char*)&kmer, sizeof(Kmer));
//   //   uint32_t idx = HASH_BIT_MODULO(hash_val, MASK, R);
//   //   hist[idx]++;
//   //   num_kmers++;
//   // }
//   //
//   // // Need paddding so that the size of each partition is an integer
//   multiple
//   // of the cache line size for (uint32_t i = 0; i < fanOut; i++) {
//   //   auto hist_i = hist[i];
//   //   auto mod = hist_i % KMERSPERCACHELINE;
//   //   hist[i] = mod == 0 ? hist_i : (hist_i + KMERSPERCACHELINE - mod);
//   // }
//   //
//   // uint32_t sum = 0;
//   // /* compute local prefix sum on hist so that we can get the start and end
//   // position of each partition */ for (uint32_t i = 0; i < fanOut; i++) {
//   //   sum += hist[i];
//   //   hist[i] = sum;
//   // }

//   PLOGI.printf("IDX: %u, sz: %llu", shard_idx, sz / fanOut);
//   auto start_alloc = _rdtsc();
//   // uint6Please provide a short explanation (a few sentences) of why you
//   need
//   // more time. 4_t* locals =
//   //     (uint64_t*)std::aligned_alloc(PAGESIZE, hist[fanOut - 1] *
//   //     sizeof(Kmer));
//   // cacheline_t* buffers = (cacheline_t*)std::aligned_alloc(
//   // CACHELINE_SIZE, sizeof(cacheline_t) * fanOut);

//   cacheline_t* buffers = (cacheline_t*)mmap(
//       nullptr, /* 256*1024*1024*/ sizeof(cacheline_t) * fanOut,
//       PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
//   // PLOGI.printf("end mmap");
//   if (buffers == MAP_FAILED) {
//     perror("mmap");
//     exit(1);
//   }
//   // cacheline_t buffers[fanOut];
//   auto end_alloc = _rdtsc() - start_alloc;
//   // PLOGI.printf("IDX: %u, Partition alloc: %llu cycles", shard_idx,
//   // end_alloc); partitions[shard_idx] = locals;

//   for (uint32_t i = 0; i < fanOut; i++) {
//     buffers[i].data.slot = 0;
//   }
//   uint64_t total_num_part = 0;
//   auto start_swb = _rdtsc();
//   uint64_t sum = 0;
//   uint64_t xo = 0;
//   for (uint64_t kmer; reader->next(&kmer);) {
//     xo += kmer;
//     // sum += kmer;
//     total_num_part += 1;
//     // auto hash_val = (kmer * 3) >> (64 - context.D);
//     auto hash_val = HASHER((const char*)&kmer, sizeof(Kmer));
//     uint32_t idx = HASH_BIT_MODULO(hash_val, MASK, R);
//     uint32_t slot = buffers[idx].data.slot;
//     Kmer* part = (Kmer*)(buffers + idx);
//     // Only works if KMERSPERCACHELINE is a power of 2
//     uint32_t slotMod = (slot) & (KMERSPERCACHELINE - 1);
//     part[slotMod] = kmer;

//     if (slotMod == (KMERSPERCACHELINE - 1)) {
//       PartitionChunks& partitionChunk = (local_chunks[idx]);
//       // PLOGI.printf("partitions size: %llu, partition array: %llu, IDX: %u,
//       // idx: %u", context.partitions.size(),
//       // context.partitions[shard_idx].size(), shard_idx, idx);
//       auto next_loc = partitionChunk.get_next();
//       // xo += (uint64_t) next_loc;
//       partitionChunk.advance();
//       // partitionChunk.chunk_size++;
//       /* write out 64-Bytes with non-temporal store */
//       store_nontemp_64B(next_loc, (buffers + idx));
//       /* writes += TUPLESPERCACHELINE; */
//     }
//     buffers[idx].data.slot = slot + 1;
//   }
//   context.partitions[shard_idx] = local_chunks;
//   //
//   context.partitions[shard_idx].insert(context.partitions[shard_idx].end(),
//   // local_chunks.begin(), local_chunks.end());
//   // context.partition_ready[shard_idx] = true;
//   auto swb_end = _rdtsc();
//   auto swb_diff = swb_end - start_swb;
//   PLOGI.printf(
//       "IDX: %u;SWB: %llu cycles; Timestamp: %llu; Partition_alloc: %llu; "
//       "SWB_per_kmer: %llu, sum: %llu",
//       shard_idx, swb_diff, swb_end - context.global_time, end_alloc,
//       swb_diff / total_num_part, xo);
//   return total_num_part;
// }

// void KmerTest::count_kmer_radix_partition(Shard* sh, const Configuration&
// config,
//                             std::barrier<VoidFn>* barrier,
//                             RadixContext& context, BaseHashTable* ht) {
//   auto nthreads_d = context.nthreads_d;
//   auto gathering_threads = 1 << nthreads_d;
//   auto shard_idx = sh->shard_idx;
//   auto fanOut = context.fanOut;

//   HTBatchRunner batch_runner(ht);

//   // PartitionChunks local_chunks[fanOut];
//   PartitionChunks* local_chunks = (PartitionChunks*)mmap(
//       nullptr, /* 256*1024*1024*/ sizeof(PartitionChunks) * fanOut,
//       PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);

//   for (int i = 0; i < fanOut; i++) {
//     local_chunks[i] = PartitionChunks((sh->f_end - sh->f_start) / fanOut);
//   }

//   auto reader = input_reader::MakeFastqKMerPreloadReader(
//       config.K, config.in_file, shard_idx, config.num_threads);

//   // wait for read initialization
//   barrier->arrive_and_wait();

//   auto start_partition_cycle = _rdtsc();

//   uint64_t total_kmers_partition =
//       partitioning(sh, config, context, move(reader), local_chunks);

//   // wait for partitions
//   barrier->arrive_and_wait();

//   // Redistribution ?

//   auto start_insertion_cycle = _rdtsc();
//   uint64_t total_kmers_insertion = 0;

//   for (int i = 0; i < fanOut; i++) {
//     PartitionChunks pc = local_chunks[i];
//     for (int j = 0; j < pc.chunks_len; j++) {
//       KmerChunk kc = pc.chunks[j];
//       for (int k = 0; k < kc.count; k++) {
//         batch_runner.insert(kc.kmers[k], 0);
//         total_kmers_insertion++;
//       }
//     }
//   }
//   batch_runner.flush_insert();
//   // wait for insertion
//   barrier->arrive_and_wait();

//   // stats printing
//   sh->stats->insertions.duration = _rdtsc() - start_insertion_cycle;
//   sh->stats->insertions.op_count = total_kmers_insertion;

//   get_ht_stats(sh, ht);
// }

// void KmerTest::count_kmer_radix_partition_global(Shard* sh,
//                                                  const Configuration& config,
//                                                  std::barrier<VoidFn>* barrier,
//                                                  RadixContext& context,
//                                                  BaseHashTable* ht) {
//   auto nthreads_d = context.nthreads_d;
//   auto gathering_threads = 1 << nthreads_d;
//   auto shard_idx = sh->shard_idx;
//   auto fanOut = context.fanOut;

//   HTBatchRunner batch_runner(ht);

//   auto reader = input_reader::MakeFastqKMerPreloadReader(
//       config.K, config.in_file, shard_idx, config.num_threads);

//   // wait for read initialization
//   barrier->arrive_and_wait();

//   uint64_t total_kmers_read = radix_partition(context, move(reader));
//   PLOG_INFO.printf("Total kmer read %d\n", total_kmers_read);
//   // wait for partitions
//   barrier->arrive_and_wait();

//   auto start_insertion_cycle = _rdtsc();

//   uint32_t part_count = config.num_threads / fanOut;
//   uint64_t total_insertion = 0;

//   for (int i = 0; i < part_count; i++) {
//     BufferedPartition& partition = context.buffer_partitions[sh->shard_idx + i];

//     uint64_t total_kmers_insertion = 0;
//     uint64_t total_kmer_partition = partition.total_kmer_count;
//     uint64_t num_insert = 0;
//     for (cacheblock_t& b : partition.blocks) {
//       for (int j = 0; j < b.count; j++) {
//         num_insert = total_kmer_partition > KMERSPERCACHELINE
//                          ? KMERSPERCACHELINE
//                          : total_kmer_partition;
//         for (int k = 0; k < num_insert; k++) {
//           batch_runner.insert(b.lines[j].kmers[k], 0);
//           total_kmers_insertion++;
//         }
//         total_kmer_partition -= num_insert;
//       }
//     }

//     total_insertion += total_kmers_insertion;

//     if (total_kmers_insertion != partition.total_kmer_count) {
//       PLOG_FATAL
//           << "insertion amount is not equal to partition amount insertion: "
//           << total_kmers_insertion
//           << " vs partition: " << partition.total_kmer_count;
//     }
//   }

//   batch_runner.flush_insert();
//   // wait for insertion
//   barrier->arrive_and_wait();

//   // stats printing
//   sh->stats->insertions.duration = _rdtsc() - start_insertion_cycle;
//   sh->stats->insertions.op_count = total_insertion;
//   get_ht_stats(sh, ht);
// }

uint64_t crc_hash64(const void* buff, uint64_t len) {
    return _mm_crc32_u64(0xffffffff, *static_cast<const std::uint64_t*>(buff));
}
#define HASHER crc_hash64
#define HASH_BIT_MODULO(K, MASK, NBITS) (((K) & MASK) >> NBITS)


Kmer packkmer(const char* s, int k)
{
  uint8_t nt;
  Kmer kmer;
  for(int i=0; i<k;i++)
  {
    switch (s[i]) {
            case 'a':
            case 'A':
                nt = 0;
                break;
            case 'c':
            case 'C':
                nt = 1;
                break;
            case 'g':
            case 'G':
                nt = 2;
                break;
            case 't':
            case 'T':
                nt = 3;
                break;
            default:
                nt = 0;
                break;
    }
    kmer = (kmer & nt) << 2;
  }

  return kmer;
}


#define PBSTR "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
#define PBWIDTH 60

void printProgress(double percentage) {
    int val = (int) (percentage * 100);
    int lpad = (int) (percentage * PBWIDTH);
    int rpad = PBWIDTH - lpad;
    printf("\r%3d%% [%.*s%*s]", val, lpad, PBSTR, rpad, "");
    fflush(stdout);
}

uint64_t radix_partition( RadixContext* context, 
                          BufferedPartition** local_partitions,
                          input_reader::FastqReader& reader,
                           int id, int k) {
    auto R = context->R;
    auto mask = context->mask;
    auto fanOut = context->fanOut;
    uint64_t totol_kmer_part = 0;

    string_view sv; 
    const char* data;
    uint64_t hash_val = 0; 
    uint32_t partition_idx = 0; 

    while(reader.next(&sv))
    {
      size_t len = sv.size();

      for(int i=0; i<(len-k+1); i++) {
        data = sv.substr(i, k).data();
        hash_val = crc_hash64(data, k);
        partition_idx = (uint32_t)HASH_BIT_MODULO(hash_val, mask, R);
        if (partition_idx < fanOut)
        {
          local_partitions[partition_idx]->write_kmer(packkmer(data, k));
          totol_kmer_part++;
        }
        else
        {
          PLOG_FATAL << "partition index too big";
        }
      }
    }

    // flush the cacheline buffer.
    for(int i=0; i<fanOut; i++)
      local_partitions[i]->flush_buffer();

    // pass the partitions into global lookup table, so other threads can gather.
    context->partitions[id] = local_partitions;

    uint64_t tt_count = 0; 
    uint64_t count = 0;
    for(int i=0; i<fanOut; i++)
    {
      count = local_partitions[i]->total_kmer_count;
      tt_count += count;
      printf("Thread id: %d partition [%d], kmer count [%lu] \n", id, i, count);
    }

    if(tt_count != totol_kmer_part) 
      printf("total count %lu doesn match total partition count %lu \n", tt_count, totol_kmer_part); 
    return totol_kmer_part;
  }

void KmerTest::count_kmer_radix_partition_global(Shard* sh,
                                                 const Configuration& config,
                                                 std::barrier<VoidFn>* barrier,
                                                 RadixContext* context,
                                                 BaseHashTable* ht) {

  uint8_t shard_idx = sh->shard_idx;
  PLOG_INFO.printf("Radix FASTQ INSERT Initialization started %d", shard_idx);

  uint32_t fanOut = context->fanOut;
  HTBatchRunner batch_runner(ht);
  auto seq_reader = input_reader::FastqReader(config.in_file, shard_idx, config.num_threads);
  size_t array_size = fanOut * sizeof(BufferedPartition*);
  BufferedPartition** local_partitions = (BufferedPartition**)malloc(array_size);
  for (int i = 0; i < fanOut; i++)
      local_partitions[i] = new BufferedPartition(context->size_hint);
  PLOG_INFO.printf("Radix FASTQ INSERT Initialization finished %d", shard_idx);
  
  barrier->arrive_and_wait();
  
  PLOG_INFO.printf("Radix Partition started %d", shard_idx);
  uint64_t total_kmers_part = radix_partition(context, local_partitions, seq_reader, shard_idx, config.K);
  PLOG_INFO.printf("Radix Partition finished: %d total parititon: %lu", shard_idx, total_kmers_part);

  barrier->arrive_and_wait();

  auto start_insertion_cycle = _rdtsc();
  uint64_t total_insertion = 0;
  uint stride = fanOut / context->threads_num;
  BufferedPartition* workload;

  PLOG_INFO.printf("Insertion started %d", shard_idx);
  for (uint i = 0; i < context->threads_num; i++) {
    for (uint j = stride * i; j < stride * (i + 1); j++) {
      workload = context->partitions[i][j];

      // Insert into a block
      uint64_t workload_inserted = 0;
      for (uint b = 0; b < workload->blocks_count; b++) {
        cacheblock_t* block = workload->get_block(b);
        for (uint l = 0; l < block->count; l++) {
          for (uint k = 0; k < KMERSPERCACHELINE; k++) {
            batch_runner.insert(block->lines[l].kmers[k], 0);
            workload_inserted++;
            if(workload_inserted >= workload->total_kmer_count)
              break;
          }
        }
      }

      total_insertion += workload_inserted;
    }
  }
  batch_runner.flush_insert();

  PLOG_INFO.printf("Insertion finished: %d total insertion: %lu", shard_idx , total_insertion);
  
  barrier->arrive_and_wait();

  sh->stats->insertions.duration = _rdtsc() - start_insertion_cycle;
  sh->stats->insertions.op_count = total_insertion;
  get_ht_stats(sh, ht);

  //free 
  // PLOG_INFO.printf("freeing memory allocated: %d", shard_idx); 
  for(int i=0; i < fanOut; i++)
    delete local_partitions[i]; 
  free(local_partitions);
}

// void KmerTest::count_kmer_radix_custom(Shard* sh, const Configuration&
// config,
//                                        std::barrier<VoidFn>* barrier,
//                                        RadixContext& context) {
//   auto hashmaps_per_thread = context.hashmaps_per_thread;
//   auto nthreads_d = context.nthreads_d;
//   auto gathering_threads = 1 << nthreads_d;

//   auto shard_idx = sh->shard_idx;
//   auto fanOut = context.fanOut;

//   // PartitionChunks local_chunks[fanOut];
//   PartitionChunks* local_chunks = (PartitionChunks*)mmap(
//       nullptr, /* 256*1024*1024*/ sizeof(PartitionChunks) * fanOut,
//       PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);

//   for (int i = 0; i < fanOut; i++) {
//     local_chunks[i] = PartitionChunks((sh->f_end - sh->f_start) / fanOut);
//   }

// #ifdef WITH_VTUNE_LIB
//   static const auto file_event =
//       __itt_event_create("file_loading", strlen("file_loading"));
//   __itt_event_start(file_event);
// #endif
//   auto first_reader_start = _rdtsc();
//   // Be care of the `K` here; it's a compile time constant.
//   auto reader = input_reader::MakeFastqKMerPreloadReader(
//       config.K, config.in_file, shard_idx, config.num_threads);
//   auto first_reader_diff = _rdtsc() - first_reader_start;
// #ifdef WITH_VTUNE_LIB
//   __itt_event_end(file_event);
// #endif
//   PLOGI.printf(
//       "IDX: %u, First reader cycles: %llu, First start: %llu, current: %llu",
//       shard_idx, first_reader_diff, first_reader_start - context.global_time,
//       _rdtsc() - context.global_time);

//   auto ht_alloc_start = _rdtsc();
//   std::vector<CASHashTableSingle<KVType, ItemQueue>*> prealloc_maps;
//   prealloc_maps.reserve(hashmaps_per_thread);
//   // if (shard_idx == 0) {

//   for (int i = 0; i < hashmaps_per_thread; i++) {
//     auto ht = new CASHashTableSingle<KVType, ItemQueue>(
//         (1 << 26) / (hashmaps_per_thread == 1 ? 1 : hashmaps_per_thread +
//         0));
//     prealloc_maps.push_back(ht);
//   }

//   // }
//   InsertFindArgument arg;
//   arg.value = 0;
//   auto ht_alloc_time = _rdtsc() - ht_alloc_start;
//   PLOGI.printf("IDX: %u, HT alloc cycle per Kmer: %llu, total cycles: %llu",
//                shard_idx, ht_alloc_time / (1 << 26), ht_alloc_time);

//   // start timers
//   std::uint64_t start_cycles{}, end_cycles{}, start_partition_cycle,
//       end_partition_cycle, start_insertions_cycle, end_insertions_cycle;
//   std::chrono::time_point<std::chrono::steady_clock> start_ts, end_ts,
//       start_partition_ts, end_partition_ts, start_insertions_ts,
//       end_insertions_ts;

//   // barrier->arrive_and_wait();

//   if (sh->shard_idx == 0) {
//     start_ts = std::chrono::steady_clock::now();
//     start_cycles = _rdtsc();
//   }
//   // Wait for all readers finish initializing.
//   barrier->arrive_and_wait();

//   std::uint64_t start_shard = _rdtsc();
//   start_partition_cycle = _rdtsc();
//   auto total_kmers_part = 0;

// #ifdef WITH_VTUNE_LIB
//   static const auto event =
//       __itt_event_create("partitioning", strlen("partitioning"));
//   __itt_event_start(event);
// #endif
//   total_kmers_part =
//       partitioning(sh, config, context, move(reader), local_chunks);
// #ifdef WITH_VTUNE_LIB
//   __itt_event_end(event);
// #endif
//   auto time = _rdtsc() - start_partition_cycle;
//   PLOGI.printf("IDX: %d, total_num: %llu, per_kmer: %llu, p_cycles: %llu",
//                shard_idx, total_kmers_part, time / total_kmers_part, time);

//   end_partition_cycle = _rdtsc();

// #ifdef WITH_VTUNE_LIB
//   static const auto event_b =
//       __itt_event_create("hit first barrier", strlen("hit first barrier"));
//   __itt_event_start(event_b);
// #endif
//   barrier->arrive_and_wait();
// #ifdef WITH_VTUNE_LIB
//   __itt_event_end(event_b);
// #endif
//   auto after_first_barrier = _rdtsc() - end_partition_cycle;
//   // return;

//   PLOGI.printf("IDX: %u Start partitioning at: %llu, gap: %llu", shard_idx,
//                start_partition_cycle - context.global_time,
//                end_partition_cycle - total_kmers_part);
//   PLOGI.printf(
//       "IDX: %u, time spent at the first_barrier: %llu, reaching barrier "
//       "at: %llu",
//       shard_idx, after_first_barrier,
//       end_partition_cycle - context.global_time);
//   auto num_threads = config.num_threads;

//   if (shard_idx >= gathering_threads) {
//     PLOGW.printf("Thread %u goes idle after partitioning.", shard_idx);
//     return;
//   }

//   std::vector<BaseHashTable*> maps;
//   maps.reserve(hashmaps_per_thread);

//   uint64_t total_insertions = 0;

// #ifdef WITH_VTUNE_LIB
//   static const auto insert_event = __itt_event_create(
//       "Gathering and inserting", strlen("Gathering and inserting"));
//   __itt_event_start(insert_event);
// #endif

//   // start_insertions_ts = std::chrono::steady_clock::now();
//   start_insertions_cycle = _rdtsc();

//   for (uint32_t k = 0; k < hashmaps_per_thread; k++) {
//     uint32_t partition_idx = hashmaps_per_thread * shard_idx + k;
//     uint64_t total_num_kmers = 0;
//     for (uint32_t i = 0; i < num_threads; i++) {
//       for (auto& chunk : context.partitions[i][partition_idx].chunks) {
//         total_num_kmers += chunk.count;
//       }
//     }

//     total_insertions += total_num_kmers;
//     auto ht = prealloc_maps[k];

//     auto count_inner = 0;

//     auto start_insertions_cycle_inner = _rdtsc();
//     for (uint32_t i = 0; i < num_threads; i++) {
//       size_t next_t = (shard_idx + i) % num_threads;
//       auto& chunks = context.partitions[next_t][partition_idx];

//       auto start_insertions_cycle_innest = _rdtsc();
//       for (auto chunk : chunks.chunks) {
//         count_inner += chunk.count;
//         for (int j = 0; j < chunk.count; j++) {
//           arg.key = chunk.kmers[j];
//           ht->insert_one(&arg, nullptr);
//         }
//       }
//     }

//     auto diff = _rdtsc() - start_insertions_cycle_inner;
//     maps.push_back(ht);
//   }

//   // end_insertions_ts = std::chrono::steady_clock::now();
//   end_insertions_cycle = _rdtsc();

//   barrier->arrive_and_wait();

// #ifdef WITH_VTUNE_LIB
//   __itt_event_end(insert_event);
// #endif
//   auto second_barrier = _rdtsc() - end_insertions_cycle;
//   // PLOGI.printf("IDX: %u, time spent at the second barrier: %llu cycles",
//   //              shard_idx, second_barrier);

//   sh->stats->insertions.duration = _rdtsc() - start_shard;
//   sh->stats->insertions.op_count = total_insertions;
//   // PLOG_INFO.printf("IDX: %u, num_kmers: %u, fill: %u", shard_idx,
//   num_kmers,
//   // ht->get_fill());
//   for (uint32_t i = 0; i < hashmaps_per_thread; i++) {
//     PLOG_INFO.printf("IDX: %u, cap: %u, fill: %u", shard_idx,
//                      maps[i]->get_capacity(), maps[i]->get_fill());
//   }
//   if (sh->shard_idx == 0) {
//     end_ts = std::chrono::steady_clock::now();
//     end_cycles = _rdtsc();
//     PLOG_INFO.printf(
//         "Kmer insertion took %llu us (%llu cycles)",
//         chrono::duration_cast<chrono::microseconds>(end_ts -
//         start_ts).count(), end_cycles - start_cycles);
//     // check_functionality(config, context);
//   }
//   auto partition_time = chrono::duration_cast<chrono::microseconds>(
//                             end_partition_ts - start_partition_ts)
//                             .count();
//   auto partition_cycles = end_partition_cycle - start_partition_cycle;
//   auto insertion_time = chrono::duration_cast<chrono::microseconds>(
//                             end_insertions_ts - start_insertions_ts)
//                             .count();
//   auto insertion_cycles = end_insertions_cycle - start_insertions_cycle;
//   auto total_time = partition_time + insertion_time;
//   auto time_per_insertion = (double)insertion_time /
//   (double)total_insertions; auto cycles_per_insertion = insertion_cycles /
//   total_insertions; auto cycles_per_partition = partition_cycles /
//   total_kmers_part; PLOG_INFO.printf(
//       "IDX: %u, radix: %u partition_time: %llu us(%llu %%), partition_cycles:
//       "
//       "%llu, total_kmer_partition: %llu, cycles_per_partition: %llu, "
//       "first_barrier: %llu, insertion "
//       "time: %llu us(%llu %%), insertion_cycles: %llu, time_per_insertion: "
//       "%.4f us"
//       ", cycles_per_insertion: %llu, total_kmer_insertion: %llu, "
//       "second_barrier: %llu",
//       shard_idx, context.D, partition_time, partition_time * 100 /
//       total_time, partition_cycles, total_kmers_part, cycles_per_partition,
//       after_first_barrier, insertion_time, insertion_time * 100 / total_time,
//       insertion_cycles, time_per_insertion, cycles_per_insertion,
//       total_insertions, second_barrier);
//   // PLOGV.printf("[%d] Num kmers %llu", sh->shard_idx, total_insertions);
//   // get_ht_stats(sh, ht);
// }

}  // namespace kmercounter
