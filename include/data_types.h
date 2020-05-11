#ifndef _DATA_TYPES_H
#define _DATA_TYPES_H

#define __CACHE_LINE_SIZE 64
#define __PAGE_SIZE 4096
// #define KMER_DATA_LENGTH 100 * 2 / 8  // 20 mer for now
#define KMER_DATA_LENGTH 50
#define ALPHA 0.15

// kmer (key)
struct Kmer_s {
  char data[KMER_DATA_LENGTH];
};

/* Test config */
struct Configuration {
  uint64_t kmer_create_data_base;
  uint32_t kmer_create_data_mult;
  uint64_t kmer_create_data_uniq;
  uint32_t num_threads;
  uint32_t read_write_kmers;
  std::string kmer_files_dir;
  bool alphanum_kmers;
  bool numa_split;
  std::string stats_file;
  std::string ht_file;
  std::string in_file;
  uint32_t ht_type;
  uint64_t in_file_sz;
  bool drop_caches;
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
#endif /*CALC_STATS*/
};

struct __shard {
  uint32_t shard_idx;
  off64_t f_start;  // start byte into file
  off64_t f_end;    // end byte into file
  thread_stats* stats;
  Kmer_s* kmer_big_pool;
  Kmer_s* kmer_small_pool;
  Kmer_s* pool;
};

#endif /* _DATA_TYPES_H */
