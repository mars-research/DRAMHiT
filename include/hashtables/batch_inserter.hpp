#ifndef HASHTABLES_BATCH_INSERTER_HPP
#define HASHTABLES_BATCH_INSERTER_HPP

#include "base_kht.hpp"
#include "constants.hpp"
#include "types.hpp"

namespace kmercounter {
template <size_t N = HT_TESTS_BATCH_LENGTH>
class HTBatchInserter {
 public:
  HTBatchInserter() : HTBatchInserter(nullptr) {}
  HTBatchInserter(BaseHashTable* ht) : ht_(ht), buffer_(), buffer_size_(0) {}
  ~HTBatchInserter() { flush(); }

  // Insert one kv pair.
  void insert(const uint64_t key, const uint64_t value) {
    // Append kv to `buffer_`
    buffer_[buffer_size_].key = key;
    buffer_[buffer_size_].value = value;
    buffer_size_++;

    // Flush if `buffer_` is full.
    if (buffer_size_ >= N) {
      flush_buffer_();
    }
  }

  // Flush everything to the hashtable and flush the hashtable insert queue.
  void flush() {
    if (buffer_size_ > 0) {
      flush_buffer_();
    }
    flush_ht_();
  }

  // Returns the number of elements flushed.
  size_t num_flushed() { return num_flushed_; }

 private:
  // Flush the insertion buffer without checking `buffer_size_`.
  void flush_buffer_() {
    ht_->insert_batch(InsertFindArguments(buffer_, buffer_size_));
    num_flushed_ += buffer_size_;
    buffer_size_ = 0;
  }

  // Issue a flush to the hashtable.
  void flush_ht_() { ht_->flush_insert_queue(); }

  // Target hashtable.
  BaseHashTable* ht_;
  // Buffer to hold the arguments for batch insertion.
  __attribute__((aligned(64))) InsertFindArgument buffer_[N];
  // Current size of the buffer.
  size_t buffer_size_;
  // Total number of elements flushed.
  size_t num_flushed_;

  // Sanity checks
  static_assert(N > 0);
};
}  // namespace kmercounter
#endif  // HASHTABLES_BATCH_INSERTER_HPP
