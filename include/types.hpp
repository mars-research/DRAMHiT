#ifndef TYPES_HPP
#define TYPES_HPP

#include <absl/hash/hash.h>

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
namespace eth_hashjoin {
struct tuple_t;
}
namespace kmercounter {

#if (KEY_LEN == 4)
using key_type = std::uint32_t;
#elif (KEY_LEN == 8)
using key_type = std::uint64_t;
#endif

using value_type = key_type;

enum class BRANCHKIND { WithBranch, NoBranch_Cmove, NoBranch_Simd };

#if defined(BRANCHLESS_CMOVE)
constexpr BRANCHKIND branching = BRANCHKIND::NoBranch_Cmove;
#elif defined(BRANCHLESS_SIMD)
constexpr BRANCHKIND branching = BRANCHKIND::NoBranch_Simd;
#else
constexpr BRANCHKIND branching = BRANCHKIND::WithBranch;
#endif

enum class BQUEUE_LOAD { None, HtInsert };

// Yes, yes, I know, global; it's midnight, ok?
extern BQUEUE_LOAD bq_load;

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
  RW_RATIO = 12,
  HASHJOIN = 13,
  FASTQ_WITH_INSERT_RADIX = 14,
} run_mode_t;

// XXX: If you add/modify a mode, update the `ht_type_strings` in
// src/Application.cpp
typedef enum {
  PARTITIONED_HT = 1,
  CASHTPP = 3,
  ARRAY_HT = 4,
} ht_type_t;

extern const char* run_mode_strings[];
extern const char* ht_type_strings[];

struct alignas(64) cacheline {
  char dummy;
};

class RadixContext {
 public:
  uint64_t** hists;
  uint64_t** partitions;
  // Radix shift
  uint8_t R;
  // Radix bits
  uint8_t D;
  uint32_t fanOut;
  uint64_t mask;
  // How many hash map does a thread have
  uint32_t multiplier;
  uint32_t nthreads_d;

  RadixContext(uint8_t d, uint8_t r, uint32_t num_threads)
      : R(r), D(d), fanOut(1 << d), mask(((1 << d) - 1) << r) {
    hists = (uint64_t**)std::aligned_alloc(CACHE_LINE_SIZE,
                                           fanOut * sizeof(uint64_t*));
    partitions = (uint64_t**)std::aligned_alloc(
        CACHE_LINE_SIZE, fanOut * sizeof(uint64_t*));

    nthreads_d = 0;
    while ((1 << (1 + nthreads_d)) <= num_threads) {
      nthreads_d++;
    }
    if (fanOut <= num_threads) {
        multiplier = 1;
    } else {
        multiplier = 1 << (d - nthreads_d);
    }
    // for (uint32_t i = 0; i < num_threads; i++) {
    //     hists[i] = (uint32_t*) std::aligned_alloc(CACHE_LINE_SIZE, fanOut *
    //     sizeof(uint32_t)); partitions[i] =
    //     (uint64_t*)std::aligned_alloc(CACHE_LINE_SIZE, fanOut *
    //     sizeof(uint64_t*));
    // }
  }

  RadixContext() = default;
};

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
  // seed for zipf dist generation
  int64_t seed;
  // R/W ratio for associated tests (modes 12 and 8)
  double pread;
  // used for kmer parsing from disk
  bool drop_caches;
  // enable/disable hw prefetchers (msr 0x1a4)
  bool hwprefetchers;
  // disable prefetching
  bool no_prefetch;

  // Run both casht/cashtpp
  bool run_both;

  // queue length for batching requests
  uint32_t batch_len;

  // Hashjoin specific configs.
  // Whether to materialize the join output
  bool materialize;
  // Path to relation R.
  std::string relation_r;
  // Path to relation S.
  std::string relation_s;
  // Number of elements in relation R. Only used when the relations are
  // generated.
  uint64_t relation_r_size;
  // Number of elements in relation S. Only used when the relations are
  // generated.
  uint64_t relation_s_size;
  // CSV delimitor for relation files.
  std::string delimitor;

  bool rw_queues;
  unsigned pollute_ratio;

  void dump_configuration() {
    printf("Run configuration {\n");
    printf("  num_threads %u\n", this->num_threads);
    printf("  numa_split %u\n", numa_split);
    printf("  mode %d - %s\n", mode, run_mode_strings[mode]);
    printf("  ht_type %u - %s\n", ht_type, ht_type_strings[ht_type]);
    printf("  ht_size %" PRIu64 " (%" PRIu64 " GiB)\n", ht_size,
           ht_size / (1ul << 30));
    printf("  K %" PRIu64 "\n", K);
    printf("  P(read) %f\n", pread);
    printf("  Pollution Ratio %u\n", pollute_ratio);
    printf("BQUEUES:\n  n_prod %u | n_cons %u\n", n_prod, n_cons);
    printf("  ht_fill %u\n", ht_fill);
    printf("ZIPFIAN:\n  skew: %f\n  seed: %ld\n", skew, seed);
    printf("  HW prefetchers %s\n", hwprefetchers ? "enabled" : "disabled");
    printf("  SW prefetch engine %s\n", no_prefetch ? "disabled" : "enabled");
    printf("  Run both %s\n", run_both ? "enabled" : "disabled");
    printf("  batch length %u\n", batch_len);
    printf("  relation_r %s\n", relation_r.c_str());
    printf("  relation_s %s\n", relation_r.c_str());
    printf("  relation_r_size %" PRIu64 "\n", relation_r_size);
    printf("  relation_s_size %" PRIu64 "\n", relation_s_size);
    printf("  delimitor %s\n", delimitor.c_str());
    printf("}\n");
  }
};

struct OpTimings {
  uint64_t duration;
  uint64_t op_count;
};

inline OpTimings& operator+=(OpTimings& a, const OpTimings& b) {
  a.duration += b.duration;
  a.op_count += b.op_count;
  return a;
}

inline auto cycles_per_op(const OpTimings& ops) {
  return ops.duration / ops.op_count;
}

/* Thread stats */
struct thread_stats {
  OpTimings insertions;
  OpTimings finds;
  OpTimings enqueues;
  OpTimings any;
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
  thread_stats* stats;
  Kmer_s* kmer_big_pool;
  Kmer_s* kmer_small_pool;
  Kmer_s* pool;
};

/// Argument for one hashtable operation(insert/find).
// NEVER NEVER NEVER USE KEY OR ID 0
// Your inserts will be ignored if you do (we use these as empty markers)
struct InsertFindArgument {
  /// The key we try to insert/find.
  kmercounter::key_type key;
  /// The value we try to insert.
  kmercounter::value_type value;
  /// A user-provided value for the user to keep track of this operation.
  /// This is returned as `FindResult::id`.
  /// In aggregation mode, this is the "key". Don't ask why.
  uint32_t id;
  /// The id of the partition that will be handling this operation.
  /// Might not be used depends on the configuration/kind of operation.
  uint32_t part_id;
};
std::ostream& operator<<(std::ostream& os, const InsertFindArgument& q);

/// A span of `InsertFindArgument`s.
using InsertFindArguments = std::span<InsertFindArgument>;

/// The result of a find operation on a hashtable.
struct FindResult {
  /// The id of the find operation.
  /// This matches the `InsertFindArgument::id`.
  uint32_t id;
  /// The value of the key of the find operation.
  /// This is the number of occurrences in aggregation mode.
  value_type value;

  constexpr FindResult() = default;
  constexpr FindResult(uint32_t id, uint32_t value) : id(id), value(value) {}
  bool operator==(FindResult const&) const = default;

  template <typename H>
  friend H AbslHashValue(H h, const FindResult& x) {
    return H::combine(std::move(h), x.id, x.value);
  }
};
std::ostream& operator<<(std::ostream& os, const FindResult& q);

/// A span of `FindResult`s.
using ValuePairs = std::pair<uint32_t, FindResult*>;

struct Key {
  key_type key;

  Key();
  Key(const uint64_t&, const uint64_t&);
  Key(const struct eth_hashjoin::tuple_t& tuple);

  bool operator==(const Key& b) const { return (this->key == b.key); }

  operator bool() const { return *this == decltype(*this){}; }
};

struct KeyValuePair {
  key_type key;
  value_type value;

  KeyValuePair();
  KeyValuePair(uint64_t, uint64_t);
  KeyValuePair(const struct eth_hashjoin::tuple_t& tuple);

  bool operator==(const KeyValuePair& b) const {
    return (this->key == b.key) && (this->value == b.value);
  }

  operator bool() const { return *this == decltype(*this){}; }
};

enum class QueueType {
  insert_queue,
  find_queue,
};

enum class ExecPhase {
  insertions,
  finds,
  none,
};
// Can be use for, let's say, cleanup functions.
using VoidFn = std::function<void()>;

}  // namespace kmercounter
#endif  // TYPES_HPP

// X mmap, no inserts, 1 thread
// X mmap, no inserts, 10 threads
// X nommap,  no inserts, 1 thread
// X nommap, no inserts, 10 threads

// mmap fasta 1 thread
// mmap fastq 10 threds
// nommap fasta 1 thread
// nommap fastq 10 threds
