#ifndef __TYPES_HPP__
#define __TYPES_HPP__

#include <atomic>
#include <cstdint>
#include <string>

#define CACHE_LINE_SIZE 64
#define PAGE_SIZE 4096
#define ALPHA 0.15
#define PACKED __attribute__((packed))

#define KMER_DATA_LENGTH 20
#define KEY_SIZE 8
#define VALUE_SIZE 8

extern const uint32_t PREFETCH_QUEUE_SIZE;

typedef enum {
  DRY_RUN = 1,
  READ_FROM_DISK = 2,
  WRITE_TO_DISK = 3,
  FASTQ_WITH_INSERT = 4,
  FASTQ_NO_INSERT = 5,
  SYNTH = 6,
  PREFETCH = 7,
  BQ_TESTS_YES_BQ = 8,
  BQ_TESTS_NO_BQ = 9
} run_mode_t;

typedef enum {
  SIMPLE_KHT = 1,
  ROBINHOOD_KHT = 2,
  CAS_KHT = 3,
  CAS_NOPREFETCH = 4,
  STDMAP_KHT = 5,
} ht_type_t;

/* Test config */
struct Configuration {
  uint64_t kmer_create_data_base;
  uint32_t kmer_create_data_mult;
  uint64_t kmer_create_data_uniq;
  uint32_t num_threads;
  run_mode_t mode;
  std::string kmer_files_dir;
  bool alphanum_kmers;
  bool numa_split;
  std::string stats_file;
  std::string ht_file;
  std::string in_file;
  uint32_t ht_type;
  uint64_t in_file_sz;
  bool drop_caches;
  uint32_t n_prod;
  uint32_t n_cons;
  uint32_t num_nops;
  uint32_t K;
  uint32_t ht_fill;
};

/* Thread stats */
struct thread_stats {
  uint64_t insertion_cycles;  // to be set by create_shards
  uint64_t num_inserts;
  uint64_t find_cycles;
  uint64_t num_finds;
  uint64_t ht_fill;
  uint64_t ht_capacity;
  uint32_t max_count;
  // uint64_t total_threads; // TODO add this back
#ifdef CALC_STATS
  uint64_t num_reprobes;
  uint64_t num_memcpys;
  uint64_t num_memcmps;
  uint64_t num_hashcmps;
  uint64_t num_queue_flushes;
  double avg_distance_from_bucket;
  uint64_t max_distance_from_bucket;
  uint64_t avg_read_length;
  uint64_t num_sequences;
#endif /*CALC_STATS*/
};

struct Kmer_s {
  char data[KMER_DATA_LENGTH];
};

struct Shard {
  uint8_t shard_idx;  // equivalent to a thread_id
  off64_t f_start;    // start byte into file
  off64_t f_end;      // end byte into file
  thread_stats *stats;
  Kmer_s *kmer_big_pool;
  Kmer_s *kmer_small_pool;
  Kmer_s *pool;
};

#endif  // __TYPES_HPP__

// X mmap, no inserts, 1 thread
// X mmap, no inserts, 10 threads
// X nommap,  no inserts, 1 thread
// X nommap, no inserts, 10 threads

// mmap fasta 1 thread
// mmap fastq 10 threds
// nommap fasta 1 thread
// nommap fastq 10 threds
