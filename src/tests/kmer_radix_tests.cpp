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

#include "Latency.hpp"
#include "constants.hpp"
#include "hashtables/base_kht.hpp"
#include "hashtables/batch_runner/batch_runner.hpp"
#include "hashtables/cas_kht.hpp"
#include "hashtables/kvtypes.hpp"
#include "input_reader/counter.hpp"
#include "input_reader/fastq.hpp"
#include "print_stats.h"
#include "sync.h"
#include "tests/KmerTest.hpp"
#include "types.hpp"
using namespace std;

namespace kmercounter {




uint64_t crc_hash64(const void* buff, uint64_t len) {
  return _mm_crc32_u64(0xffffffff, *static_cast<const std::uint64_t*>(buff));
}
#define HASHER crc_hash64
#define HASH_BIT_MODULO(K, MASK, NBITS) (((K) & MASK) >> NBITS)

#define PBSTR "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
#define PBWIDTH 60

void printProgress(double percentage) {
  int val = (int)(percentage * 100);
  int lpad = (int)(percentage * PBWIDTH);
  int rpad = PBWIDTH - lpad;
  printf("\r%3d%% [%.*s%*s]", val, lpad, PBSTR, rpad, "");
  fflush(stdout);
}

Kmer packkmer(const char* s, int k) {
  uint8_t nt;
  Kmer kmer;
  for (int i = 0; i < k; i++) {
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
    kmer = (kmer | nt) << 2;
  }

  return kmer;
}


uint32_t hash(uint32_t x) {
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = (x >> 16) ^ x;
    return x;
}


uint64_t radix_partition(RadixContext* context,
                                   std::vector<std::vector<Kmer>>& local_partitions,
                                   input_reader::KmerReader& reader, int id) {
  auto R = context->R;
  auto mask = context->mask;
  auto fanOut = context->fanOut;
  uint64_t totol_kmer_part = 0;
  uint32_t partition_idx = 0;


  Kmer kmer;
  while (reader.next(&kmer)) {
    partition_idx = (uint32_t) hash(kmer) % fanOut;
    if (partition_idx < fanOut) {
      local_partitions[partition_idx].push_back(kmer);
      totol_kmer_part++;
    } else {
      PLOG_FATAL << "partition index too big";
    } 
  }

  // flush the cacheline buffer.
  //for (int i = 0; i < fanOut; i++) local_partitions[i]->flush_buffer();

  // pass the partitions into global lookup table, so other threads can gather. 
  // context->partitions[id] = local_partitions;

  return totol_kmer_part;
}

void KmerTest::count_kmer_radix_partition_global(Shard* sh,
                                                 const Configuration& config,
                                                 std::barrier<VoidFn>*
                                                 barrier, RadixContext*
                                                 context, BaseHashTable* ht)
                                                 {
  uint8_t shard_idx = sh->shard_idx;
  uint32_t fanOut = context->fanOut;
  HTBatchRunner batch_runner(ht);
  
  PLOG_INFO.printf("About to initialize Kmer Reader ");

  auto seq_reader = input_reader::KmerReader(config.K, config.in_file, shard_idx,
      config.num_threads);

    PLOG_INFO.printf("Finish initializing Kmer Reader ");


  // size_t array_size = fanOut * sizeof(BufferedPartition*);
  // BufferedPartition** local_partitions =
  //     (BufferedPartition**)malloc(array_size);
  // for (int i = 0; i < fanOut; i++)
  //   local_partitions[i] = new BufferedPartition(context->size_hint);

  std::vector<std::vector<Kmer>> local_partitions(fanOut);

  barrier->arrive_and_wait();


  unsigned long long start_cycle = __rdtsc();
  
  uint64_t total_kmers_part = radix_partition(context, local_partitions,
                                              seq_reader, shard_idx);

  unsigned long long total_cycle = __rdtsc() - start_cycle;
  PLOG_INFO.printf("Radix Partition finished: %d total parititon: %lu cycles: %llu cpo: %lu", 
                   shard_idx, total_kmers_part, total_cycle, total_cycle / total_kmers_part);

  barrier->arrive_and_wait();


  // Partition Again. 

  // Create hashtables here

  

  // auto start_insertion_cycle = _rdtsc();
  // uint64_t total_insertion = 0;

  // uint stride =
  //     fanOut /
  //     context->threads_num;  // number of complete paritions each thread gets.
  // BufferedPartition* workload;
  // for (uint i = 0; i < context->threads_num; i++) {
  //   for (uint j = stride * (shard_idx - 1); j < stride * shard_idx; j++) {
  //     workload = context->partitions[i][j];  // get work load base on shard id.

  //     // we should be able to quickly access the workload partition if the size
  //     // of it is small enough to fit in cache.
  //     uint64_t workload_inserted = 0;
  //     for (uint b = 0; b < workload->blocks_count; b++) {
  //       cacheblock_t* block = workload->get_block(b);
  //       for (uint l = 0; l < block->count; l++) {
  //         for (uint k = 0; k < KMERSPERCACHELINE; k++) {
  //           batch_runner.insert(block->lines[l].kmers[k], 0);
  //           workload_inserted++;
  //           if (workload_inserted >= workload->total_kmer_count) break;
  //         }
  //       }
  //     }
  //     total_insertion += workload_inserted;
  //   }
  // }
  // batch_runner.flush_insert();
  // PLOG_INFO.printf("Insertion finished: %d total insertion: %lu", shard_idx,
  //                  total_insertion);

  // barrier->arrive_and_wait();

  // sh->stats->insertions.duration = _rdtsc() - start_insertion_cycle;
  // sh->stats->insertions.op_count = total_insertion;
  // get_ht_stats(sh, ht);

  // free
  //  PLOG_INFO.printf("freeing memory allocated: %d", shard_idx);
  //for (int i = 0; i < fanOut; i++) delete local_partitions[i];
  //free(local_partitions);
}




#include "time.h"

/*
* Create equal size input and output, move input into output
* 
*/
void KmerTest::count_kmer_baseline(Shard* sh, const Configuration& config,
                                   std::barrier<VoidFn>* barrier,
                                   BaseHashTable* ht) {
  // HTBatchRunner batch_runner(ht);

  uint32_t len = config.data_size; // pow of 2 
  uint32_t inserts = config.workload_size; // 1000000

  srand(time(NULL));

  PLOG_INFO.printf("length: %d, inserts: %d", len, inserts);

  Kmer* output = (Kmer*)aligned_alloc(4096, sizeof(Kmer) * len);

  // populate input array
  Kmer* input = (Kmer*)aligned_alloc(4096, sizeof(Kmer) * len);
  for (uint32_t i = 0; i < len; i++) input[i] = (uint32_t) rand(); 

  auto start = _rdtsc();

  uint32_t e;
  for (uint32_t i = 0; i < inserts; i++) 
  {
    e = input[i & (len-1)];
    output[(hash(e) & (len-1))] = e;
    // ht->insert_noprefetch((void*)(&in));
  }

  // batch_runner.flush_insert();

  auto cycles = _rdtsc() - start;

  uint64_t cpo = (uint64_t)(cycles / inserts);
  PLOG_INFO.printf("cycles: %llu, op: %d cpo: %lu", cycles, inserts, cpo);
  sh->stats->insertions.duration = cycles;
  sh->stats->insertions.op_count = inserts;
  get_ht_stats(sh, ht);

  free(input);
}

}  // namespace kmercounter
