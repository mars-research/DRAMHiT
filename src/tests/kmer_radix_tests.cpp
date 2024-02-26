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

uint64_t crc_hash64(const void* buff, uint64_t len) {
    return _mm_crc32_u64(0xffffffff, *static_cast<const std::uint64_t*>(buff));
}
#define HASHER crc_hash64
#define HASH_BIT_MODULO(K, MASK, NBITS) (((K) & MASK) >> NBITS)

#define PBSTR "||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||"
#define PBWIDTH 60

void printProgress(double percentage) {
    int val = (int) (percentage * 100);
    int lpad = (int) (percentage * PBWIDTH);
    int rpad = PBWIDTH - lpad;
    printf("\r%3d%% [%.*s%*s]", val, lpad, PBSTR, rpad, "");
    fflush(stdout);
}

Kmer KmerTest::packkmer(const char* s, int k)
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

uint64_t KmerTest::radix_partition( RadixContext* context, 
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

}  // namespace kmercounter
