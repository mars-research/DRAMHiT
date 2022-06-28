#ifndef TYPES_HPP
#define TYPES_HPP

#include <atomic>
#include <cinttypes>
#include <cstdint>
#include <functional>
#include <iostream>
#include <span>
#include <string>
#include <utility>

#define CACHE_LINE_SIZE 64
#define PAGE_SIZE 4096
#define ALPHA 0.15
#define PACKED __attribute__((packed))

#define KMER_DATA_LENGTH 20
#define KEY_SIZE 8
#define VALUE_SIZE 8

// Forward declaration of `eth_hashjoin::tuple_t`.
namespace eth_hashjoin { struct tuple_t; }
namespace kmercounter {

enum class BRANCHKIND { WithBranch, NoBranch_Cmove, NoBranch_Simd };

#if defined(BRANCHLESS_CMOVE)
constexpr BRANCHKIND branching = BRANCHKIND::NoBranch_Cmove;
#elif defined(BRANCHLESS_SIMD)
constexpr BRANCHKIND branching = BRANCHKIND::NoBranch_Simd;
#else
constexpr BRANCHKIND branching = BRANCHKIND::WithBranch;
#endif

enum class BQUEUE_LOAD { None, HtInsert };

#if defined(BQ_TESTS_DO_HT_INSERTS)
constexpr BQUEUE_LOAD bq_load = BQUEUE_LOAD::HtInsert;
#else
constexpr BQUEUE_LOAD bq_load = BQUEUE_LOAD::None;
#endif

#if defined(BRANCHLESS_SIMD) && defined(BRACNHLESS_CMOVE)
#error "BRACHLESS_SIMD and BRANCHLESS_CMOVE options cannot be enabled together"
#endif

// XXX: If you add/modify a mode, update the `run_mode_strings` in
// src/Application.cpp
typedef enum {
  DRY_RUN = 1,
  READ_FROM_DISK = 2,
  WRITE_TO_DISK = 3,
  FASTQ_WITH_INSERT = 4,
  FASTQ_NO_INSERT = 5,
  SYNTH = 6,
  PREFETCH = 7,
  BQ_TESTS_YES_BQ = 8,
  BQ_TESTS_NO_BQ = 9,
  CACHE_MISS = 10,
  ZIPFIAN = 11,
  HASHJOIN = 12,
} run_mode_t;

// XXX: If you add/modify a mode, update the `ht_type_strings` in
// src/Application.cpp
typedef enum {
  PARTITIONED_HT = 1,
  CASHTPP = 3,
} ht_type_t;

extern const char *run_mode_strings[];
extern const char *ht_type_strings[];

// Application configuration
struct Configuration {
  // kmer related stuff
  uint64_t kmer_create_data_base;
  uint32_t kmer_create_data_mult;
  uint64_t kmer_create_data_uniq;
  std::string kmer_files_dir;
  bool alphanum_kmers;
  std::string stats_file;
  std::string ht_file;
  std::string in_file;
  uint64_t in_file_sz;
  uint32_t K;

  // number of threads
  uint32_t num_threads;
  // run mode
  run_mode_t mode;
  // controls distribution of threads across numa nodes
  uint32_t numa_split;

  // hashtable configuration
  // different hashtable types
  uint32_t ht_type;
  // controls load factor on the hashtable
  uint32_t ht_fill;
  // hashtable size
  uint64_t ht_size;
  // insert factor
  uint64_t insert_factor;

  // bqueue configuration
  // prod/cons count
  uint32_t n_prod;
  uint32_t n_cons;
  // number of nops (used once for bqueue debugging)
  uint32_t num_nops;

  // controls zipfian dist
  double skew;
  // used for kmer parsing from disk
  bool drop_caches;
  // enable/disable hw prefetchers (msr 0x1a4)
  bool hwprefetchers;
  // disable prefetching
  bool no_prefetch;

  // Run both casht/cashtpp
  bool run_both;

  // Hashjoin specific configs.
  // Path to relation R.
  std::string relation_r;
  // Path to relation S.
  std::string relation_s;
  // Number of elements in relation R. Only used when the relations are generated.
  uint64_t relation_r_size;
  // Number of elements in relation S. Only used when the relations are generated.
  uint64_t relation_s_size;
  // CSV delimitor for relation files.
  std::string delimitor;

  void dump_configuration() {
    printf("Run configuration{\n");
    printf("  num_threads %u\n", this->num_threads);
    printf("  numa_split %u\n", numa_split);
    printf("  mode %d - %s\n", mode, run_mode_strings[mode]);
    printf("  ht_type %u - %s\n", ht_type, ht_type_strings[ht_type]);
    printf("  ht_size %" PRIu64 " (%" PRIu64 " GiB)\n", ht_size, ht_size/(1ul << 30));
    printf("BQUEUES:\n  n_prod %u | n_cons %u\n", n_prod, n_cons);
    printf("  ht_fill %u\n", ht_fill);
    printf("ZIPFIAN:\n  skew: %f\n", skew);
    printf("  HW prefetchers %s\n", hwprefetchers ? "enabled" : "disabled");
    printf("  SW prefetch engine %s\n", no_prefetch ? "disabled" : "enabled");
    printf("  Run both %s\n", run_both ? "enabled" : "disabled");
    printf("  relation_r %s\n", relation_r.c_str());
    printf("  relation_s %s\n", relation_r.c_str());
    printf("  relation_r_size %" PRIu64 "\n", relation_r_size);
    printf("  relation_s_size %" PRIu64 "\n", relation_s_size);
    printf("  delimitor %s\n", delimitor.c_str());
    printf("}\n");
  }
};

/* Thread stats */
struct thread_stats {
  uint64_t insertion_cycles;  // to be set by create_shards
  uint64_t num_inserts;
  uint64_t num_enqueues;
  uint64_t find_cycles;
  uint64_t num_finds;
  uint64_t ht_fill;
  uint64_t ht_capacity;
  uint32_t max_count;
  uint64_t enqueue_cycles;
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

/// Argument for one hashtable operation(insert/find).
// NEVER NEVER NEVER USE KEY OR ID 0
// Your inserts will be ignored if you do (we use these as empty markers)
struct InsertFindArgument {
  /// The key we try to insert/find.
  uint64_t key;
  /// The value we try to insert.
  uint64_t value;
  /// A user-provided value for the user to keep track of this operation.
  /// This is returned as `FindResult::id`.
  uint64_t id;
  /// The id of the partition that will be handling this operation.
  /// Might not be used depends on the configuration/kind of operation. 
  uint64_t part_id;
};
std::ostream& operator<<(std::ostream& os, const InsertFindArgument& q);

/// A span of `InsertFindArgument`s.
using KeyPairs = std::span<InsertFindArgument>;

/// The result of a find operation on a hashtable.
struct FindResult {
  /// The id of the find operation.
  /// This matches the `InsertFindArgument::id`.
  uint64_t id;
  /// The value of the key of the find operation.
  uint64_t value;

  constexpr FindResult() = default;
  constexpr FindResult(uint64_t id, uint64_t value) : id(id), value(value) {}
  bool operator==(FindResult const&) const = default;
};
std::ostream& operator<<(std::ostream& os, const FindResult& q);

/// A span of `FindResult`s.
using ValuePairs = std::pair<uint32_t, FindResult *>;

struct KeyValuePair {
  uint64_t key;
  uint64_t value;

  KeyValuePair();
  KeyValuePair(const struct eth_hashjoin::tuple_t& tuple);
};

enum class QueueType {
  insert_queue,
  find_queue,
};

struct OpTimings {
  uint64_t duration;
  uint64_t op_count;
};

// Can be use for, let's say, cleanup functions.
using VoidFn = std::function<void()>;

} //namespace kmercounter
#endif // TYPES_HPP

// X mmap, no inserts, 1 thread
// X mmap, no inserts, 10 threads
// X nommap,  no inserts, 1 thread
// X nommap, no inserts, 10 threads

// mmap fasta 1 thread
// mmap fastq 10 threds
// nommap fasta 1 thread
// nommap fastq 10 threds
