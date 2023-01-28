#ifndef BATCH_RUNNER_BATCH_FINDER_HPP
#define BATCH_RUNNER_BATCH_FINDER_HPP

#include <plog/Log.h>

#include <functional>
#include <span>

#include "constants.hpp"
#include "hashtables/base_kht.hpp"
#include "types.hpp"

namespace kmercounter {
template <size_t N = HT_TESTS_BATCH_LENGTH>
class HTBatchFinder {
 public:
  using FindCallback = std::function<void(const FindResult&)>;

  HTBatchFinder() : HTBatchFinder(nullptr) {}
  HTBatchFinder(BaseHashTable* ht) : HTBatchFinder(ht, nullptr) {}
  HTBatchFinder(BaseHashTable* ht, FindCallback callback_fn)
      : ht_(ht),
        buffer_size_(0),
        results_(0, result_buffer_),
        callback_fn_(callback_fn) {}
  ~HTBatchFinder() {
    if (ht_ != nullptr) {
      flush();
    }
  }

  /// Find a key. `id` is used to track the find operation.
  /// Set `parition_id` to the actual partition if you have more than one
  /// partition when using PartitionedHT.
  void find(const uint64_t key, const uint64_t id,
            const uint64_t partition_id = 0) {
    // Append kv to `buffer_`
    buffer_[buffer_size_].key = key;
    buffer_[buffer_size_].id = id;
    buffer_[buffer_size_].part_id = partition_id;
    buffer_size_++;

    // Flush if `buffer_` is full.
    if (buffer_size_ >= N) {
      flush_buffer();
    }
  }

  void *find_noprefetch(const KeyValuePair &kv) {
    return ht_->find_noprefetch((void*) &kv);
  }

  /// Flush everything to the hashtable and flush the hashtable find queue.
  void flush() {
    if (buffer_size_ > 0) {
      flush_buffer();
    }
    flush_ht();
  }

  // Returns the number of elements flushed.
  size_t num_flushed() { return num_flushed_; }

  // Set the callback function.
  void set_callback(FindCallback callback_fn) { callback_fn_ = callback_fn; }

 private:
  // Flush the insertion buffer without checking `buffer_size_`.
  void flush_buffer() {
    ht_->find_batch(InsertFindArguments(buffer_, buffer_size_), results_);
    num_flushed_ += buffer_size_;
    buffer_size_ = 0;
    process_results();
  }

  // Issue a flush to the hashtable.
  void flush_ht() {
    ht_->flush_find_queue(results_);
    process_results();
  }

  /// Process each result, if there's any.
  void process_results() {
    for (const auto& result : std::span(results_.second, results_.first)) {
      callback_fn_(result);
    }
    // The hashtable might pollute the `results_` with buffers from other
    // finders.
    results_ = {0, result_buffer_};
  }

  // Target hashtable.
  BaseHashTable* ht_ = nullptr;
  // Buffer to hold the arguments for batch insertion.
  __attribute__((aligned(64))) InsertFindArgument buffer_[N] = {};
  // Current size of the buffer.
  size_t buffer_size_ = 0;
  // Total number of elements flushed.
  size_t num_flushed_ = 0;
  // The buffer for storing the results.
  __attribute__((aligned(64))) FindResult result_buffer_[N] = {};
  // The results of finds.
  ValuePairs results_ = {0, nullptr};
  // A user provided function for processing a result
  FindCallback callback_fn_ = nullptr;

  // Sanity checks
  static_assert(N > 0);
};
}  // namespace kmercounter
#endif  // BATCH_RUNNER_BATCH_FINDER_HPP
