#pragma once
//
// Shared sizing + allocation for the k-mer staging buffer.
//
// Both k-mer counting paths pre-stage their input as a flat array of 2-bit
// encoded k-mers before the timed region, so that what gets measured is
// hashtable throughput and not FASTQ parsing or encoding:
//
//   * the global path, src/tests/kmer_tests.cpp (ht-type 3, 8)
//   * the producer/consumer path, src/tests/queue_tests.cpp (ht-type 1, 12)
//
// The staging buffer lives in a HugepageArena, and that is what makes this
// header necessary rather than a plain `new uint64_t[n]`.
//
// HugepageArena keeps the 1GB and the 2MB pool as two SEPARATE mmaps, and
// alloc_internal serves a request out of one pool or the other -- it never
// spans them. The pool sizing (one_gb_pages/two_mb_pages below) is chosen so
// the two pools TOGETHER cover the requirement, which means a caller that asks
// for the whole buffer in a single allocation can fail even though the arena
// holds plenty of room: at 64 threads over an 18GB FASTQ the array is 1.056GiB,
// which fits neither the 1.000GiB pool nor the 0.056GiB remainder pool, and
// every shard throws std::bad_alloc minutes into the run.
//
// StagingBuffer therefore splits the array to match the pool layout: one chunk
// per whole 1GB page reserved, then a remainder chunk out of the 2MB pool. The
// chunks are contiguous in index space even though they are separate
// allocations.
//
#include <plog/Log.h>

#include <cstdint>
#include <vector>

#include "utils/hugepage_arena.hpp"

namespace kmercounter {
namespace staging {

constexpr uint64_t SIZE_1GB = 1ULL << 30;
constexpr uint64_t SIZE_2MB = 2ULL << 20;

/// Bytes to reserve for one shard's kmer array.
///
/// A FASTQ record is `@header\n SEQ\n +\n QUAL\n`, so a record of read length L
/// costs 2L + |header| + 6 bytes and yields L - K + 1 kmers. kmers/bytes is
/// therefore strictly below 1/2 for any well-formed FASTQ, which makes bytes/2
/// a real upper bound and not just an estimate -- the arena cannot grow, so it
/// has to be one.
///
/// `num_shards` is the number of readers the file is split across, which is NOT
/// the same thing on both paths: the global path splits across
/// config.num_threads, but on the producer/consumer path only the producers
/// read, so it is n_prod (config.num_threads there is n_prod + n_cons).
inline uint64_t shard_kmer_bytes(uint64_t in_file_sz, uint32_t num_shards) {
  return (in_file_sz / num_shards / 2 + 1) * sizeof(uint64_t);
}

/// Total bytes one shard asks the arena for: the kmer array, the batch buffer,
/// and one 2MB page of slack so the 64B-aligned bumps always fit.
inline uint64_t shard_arena_bytes(uint64_t kmer_bytes, uint64_t args_bytes) {
  return kmer_bytes + args_bytes + SIZE_2MB;
}

/// Pool sizes for `bytes` -- the two together cover it. Must be paired with
/// StagingBuffer, which splits its allocations to match.
inline uint64_t one_gb_pages(uint64_t bytes) { return bytes / SIZE_1GB; }

inline uint64_t two_mb_pages(uint64_t bytes) {
  return (bytes - one_gb_pages(bytes) * SIZE_1GB) / SIZE_2MB + 1;
}

/// A flat uint64 k-mer array split across arena chunks that mirror the pool
/// layout, so no single allocation has to span the 1GB and 2MB pools.
///
/// Construct this BEFORE any other allocation from the same arena.
/// alloc_internal is greedy on the 1GB pool: a small allocation made first
/// bumps that pool's offset and pushes a later whole-1GiB chunk out of it, at
/// which point the chunk no longer fits anywhere.
class StagingBuffer {
 public:
  /// `batch_len` keeps the hot loop simple: every chunk but the last holds a
  /// whole multiple of batch_len kmers, so a batch never straddles a boundary
  /// and the insert loop needs no per-kmer bounds check.
  StagingBuffer(HugepageArena &arena, uint64_t kmer_bytes, uint32_t batch_len) {
    const uint64_t whole_1gb = one_gb_pages(kmer_bytes);
    // Largest whole-1GiB chunk that is also a whole number of batches.
    const uint64_t kmers_per_1gb =
        (SIZE_1GB / sizeof(uint64_t)) / batch_len * batch_len;

    uint64_t remaining = kmer_bytes / sizeof(uint64_t);
    for (uint64_t i = 0; i < whole_1gb && remaining > kmers_per_1gb; i++) {
      chunks_.push_back(
          {(uint64_t *)arena.aligned_alloc(kmers_per_1gb * sizeof(uint64_t), 64),
           kmers_per_1gb});
      remaining -= kmers_per_1gb;
      capacity_ += kmers_per_1gb;
    }
    if (remaining > 0) {
      chunks_.push_back(
          {(uint64_t *)arena.aligned_alloc(remaining * sizeof(uint64_t), 64),
           remaining});
      capacity_ += remaining;
    }
  }

  /// Total kmers this buffer can hold.
  uint64_t capacity() const { return capacity_; }

  uint64_t num_chunks() const { return chunks_.size(); }

  /// Append; the caller checks `capacity()` first, as the arena cannot grow.
  void push(uint64_t kmer) {
    auto &c = chunks_[fill_chunk_];
    c.data[fill_offset_++] = kmer;
    if (fill_offset_ == c.len) {
      fill_chunk_++;
      fill_offset_ = 0;
    }
  }

  /// Chunks in index order. `len` is in kmers, not bytes.
  struct Chunk {
    uint64_t *data;
    uint64_t len;
  };
  const std::vector<Chunk> &chunks() const { return chunks_; }

  /// How much of each chunk was actually filled, given `num_kmers` pushed.
  /// Chunks past the returned count are untouched and must not be read.
  uint64_t filled_len(uint64_t chunk_idx, uint64_t num_kmers) const {
    uint64_t before = 0;
    for (uint64_t i = 0; i < chunk_idx; i++) before += chunks_[i].len;
    if (num_kmers <= before) return 0;
    const uint64_t left = num_kmers - before;
    return left < chunks_[chunk_idx].len ? left : chunks_[chunk_idx].len;
  }

 private:
  std::vector<Chunk> chunks_;
  uint64_t capacity_ = 0;
  uint64_t fill_chunk_ = 0;
  uint64_t fill_offset_ = 0;
};

}  // namespace staging
}  // namespace kmercounter
