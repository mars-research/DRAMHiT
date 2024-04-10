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

// uint64_t KmerTest::radix_partition(RadixContext* context,
//                                    BufferedPartition** local_partitions,
//                                    input_reader::FastqReader& reader, int id,
//                                    int k) {
//   auto R = context->R;
//   auto mask = context->mask;
//   auto fanOut = context->fanOut;
//   uint64_t totol_kmer_part = 0;

//   string_view sv;
//   const char* data;
//   uint64_t hash_val = 0;
//   uint32_t partition_idx = 0;

//   while (reader.next(&sv)) {
//     size_t len = sv.size();

//     for (int i = 0; i < (len - k + 1); i++) {
//       data = sv.substr(i, k).data();
//       hash_val = crc_hash64(data, k);
//       partition_idx = (uint32_t)HASH_BIT_MODULO(hash_val, mask, R);
//       if (partition_idx < fanOut) {
//         local_partitions[partition_idx]->write_kmer(packkmer(data, k));
//         totol_kmer_part++;
//       } else {
//         PLOG_FATAL << "partition index too big";
//       }
//     }
//   }

//   // flush the cacheline buffer.
//   for (int i = 0; i < fanOut; i++) local_partitions[i]->flush_buffer();

//   // pass the partitions into global lookup table, so other threads can
//   gather. context->partitions[id] = local_partitions;

//   uint64_t tt_count = 0;
//   uint64_t count = 0;
//   uint64_t avg = 0;

//   for (int i = 0; i < fanOut; i++) {
//     count = local_partitions[i]->total_kmer_count;
//     tt_count += count;
//   }

//   if (tt_count != totol_kmer_part)
//     printf("total count %lu doesn match total partition count %lu \n",
//     tt_count,
//            totol_kmer_part);

//   avg = (uint64_t)(tt_count / fanOut);
//   printf("Thread id: %d average partition count [%lu] \n", id, avg);
//   return totol_kmer_part;
// }
void KmerTest::count_kmer_radix_partition_global(Shard* sh,
                                                 const Configuration& config,
                                                 std::barrier<VoidFn>* barrier,
                                                 RadixContext* context,
                                                 BaseHashTable* ht) {}
// void KmerTest::count_kmer_radix_partition_global(Shard* sh,
//                                                  const Configuration& config,
//                                                  std::barrier<VoidFn>*
//                                                  barrier, RadixContext*
//                                                  context, BaseHashTable* ht)
//                                                  {
//   uint8_t shard_idx = sh->shard_idx;
//   uint32_t fanOut = context->fanOut;
//   HTBatchRunner batch_runner(ht);
//   auto seq_reader =
//       input_reader::FastqReader(config.in_file, shard_idx,
//       config.num_threads);
//   size_t array_size = fanOut * sizeof(BufferedPartition*);
//   BufferedPartition** local_partitions =
//       (BufferedPartition**)malloc(array_size);
//   for (int i = 0; i < fanOut; i++)
//     local_partitions[i] = new BufferedPartition(context->size_hint);
//   PLOG_INFO.printf("Radix FASTQ INSERT Initialization finished %d",
//   shard_idx);

//   barrier->arrive_and_wait();

//   uint64_t total_kmers_part = radix_partition(context, local_partitions,
//                                               seq_reader, shard_idx,
//                                               config.K);
//   PLOG_INFO.printf("Radix Partition finished: %d total parititon: %lu",
//                    shard_idx, total_kmers_part);

//   barrier->arrive_and_wait();

//   auto start_insertion_cycle = _rdtsc();
//   uint64_t total_insertion = 0;

//   uint stride =
//       fanOut /
//       context->threads_num;  // number of complete paritions each thread
//       gets.
//   BufferedPartition* workload;
//   for (uint i = 0; i < context->threads_num; i++) {
//     for (uint j = stride * (shard_idx - 1); j < stride * shard_idx; j++) {
//       workload = context->partitions[i][j];  // get work load base on shard
//       id.

//       // we should be able to quickly access the workload partition if the
//       size
//       // of it is small enough to fit in cache.
//       uint64_t workload_inserted = 0;
//       for (uint b = 0; b < workload->blocks_count; b++) {
//         cacheblock_t* block = workload->get_block(b);
//         for (uint l = 0; l < block->count; l++) {
//           for (uint k = 0; k < KMERSPERCACHELINE; k++) {
//             batch_runner.insert(block->lines[l].kmers[k], 0);
//             workload_inserted++;
//             if (workload_inserted >= workload->total_kmer_count) break;
//           }
//         }
//       }
//       total_insertion += workload_inserted;
//     }
//   }
//   batch_runner.flush_insert();
//   PLOG_INFO.printf("Insertion finished: %d total insertion: %lu", shard_idx,
//                    total_insertion);

//   barrier->arrive_and_wait();

//   sh->stats->insertions.duration = _rdtsc() - start_insertion_cycle;
//   sh->stats->insertions.op_count = total_insertion;
//   get_ht_stats(sh, ht);

//   // free
//   //  PLOG_INFO.printf("freeing memory allocated: %d", shard_idx);
//   for (int i = 0; i < fanOut; i++) delete local_partitions[i];
//   free(local_partitions);
// }



typedef struct KmerSeq {
  Kmer* kmers;
  uint64_t len;
  KmerSeq* next;
} KmerSeq;

uint64_t getKmerFromSeqencer(input_reader::FastqReader* reader, int k,
                             Kmer* kmers) {
  string_view sv;
  const char* data;
  uint64_t num_kmers = 0;
  if (reader->next(&sv)) {
    size_t len = sv.size();
    num_kmers = len - k + 1;
    if (num_kmers < 1) return 0;
    kmers = (Kmer*)malloc(sizeof(uint64_t) * num_kmers);

    for (int i = 0; i < num_kmers; i++) {
      data = sv.substr(i, k).data();
      kmers[i] = packkmer(data, k);
    }
  }

  return num_kmers;
}

void KmerTest::count_kmer_partition(Shard* sh, const Configuration& config,
                                    std::barrier<VoidFn>* barrier) {

  auto seq_reader = input_reader::FastqReader(config.in_file, sh->shard_idx,
                                              config.num_threads);

  KmerSeq* kmer_seq = (KmerSeq*)malloc(sizeof(KmerSeq));
  KmerSeq* head = kmer_seq;

  kmer_seq->len = 100;
  for(int i=0; i<100; i++)
    kmer_seq->kmers[i] = i;
  
  // uint64_t num_seq = 0;
  // while ((kmer_seq->len = getKmerFromSeqencer(&seq_reader, config.K,
  //                                             kmer_seq->kmers)) > 0) {
  //   kmer_seq->next = (KmerSeq*)malloc(sizeof(KmerSeq));
  //   kmer_seq = kmer_seq->next;
  //   num_seq++;
  // }
  kmer_seq->next = nullptr;

  //PLOG_INFO.printf("num seq %d", num_seq);

  // TODO: User control param
  double max_fill_factor = config.max_fill_factor;
  uint64_t sz = config.ht_size;
  uint32_t num_ht = config.num_ht;

  BaseHashTable* ht = new CASHashTable<KVType, ItemQueue>(sz);
  HTBatchRunner batch_runner(ht);

  // barrier->arrive_and_wait();

  auto start = _rdtsc();

  uint64_t inserts = 0;
  uint64_t ht_inserted = 0;

  kmer_seq = head;
  uint64_t kmer;
  uint64_t seq_num = 0;

  while (1) {
    for (int j = 0; j < kmer_seq->len; j++) {
      kmer = kmer_seq->kmers[j];
      if (ht_inserted >= sz) {
        ht_inserted = 0;
        // flush the old ht.
        batch_runner.flush_insert();
        // TODO save ht to disk`
        break;
      }
      batch_runner.insert(kmer, 0);
      inserts++;
      ht_inserted++;
      PLOG_INFO.printf("Inserted: %lu", ht_inserted);
    }

    if(kmer_seq->next == nullptr)
      break;
    else
      kmer_seq = kmer_seq->next;
  }

  batch_runner.flush_insert();
  auto cycles = _rdtsc() - start;
  uint64_t cpo = (uint64_t)(cycles / inserts);
  PLOG_INFO.printf("cycles: %llu, op: %d cpo: %lu", cycles, inserts, cpo);

  // free
  KmerSeq* tmp;
  kmer_seq = head;
  while (kmer_seq != NULL) {
    tmp = kmer_seq;
    kmer_seq = kmer_seq->next;
    free(tmp);
  }
}

#include "time.h"


uint32_t hash(uint32_t x) {
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = ((x >> 16) ^ x) * 0x45d9f3b;
    x = (x >> 16) ^ x;
    return x;
}

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
