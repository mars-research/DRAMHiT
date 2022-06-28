#ifndef HASHTABLES_BATCH_INSERTER_HPP
#define HASHTABLES_BATCH_INSERTER_HPP

#include "base_kht.hpp"
#include "types.hpp"

namespace kmercounter {
template <size_t N>
class HTBatchInserter {
 public:
  HTBatchInserter(BaseHashtable* ht) : ht_(ht), buffer_(), buffer_size_(0) {}
  ~HTBatchInserter() {
    flush();
  }

  // Insert one kv pair.
  void insert(const uint64_t key, const uint64_t value) {
    // Append kv to `buffer_`
    buffer_[buffer_size_].key = key;
    buffer_[buffer_size_].value = value;
    buffer_size_++;

    // Flush if `buffer_` is full.
    if (buffer_size_ >= N) {
      flush_();
    }
  }

  // Flush if there's anything in the buffer.
  void flush() {
    if (buffer_size_ > 0) {
      flush_();
    }
  }

 private:
  // Flush without checking `buffer_size_`.
  void flush_() {
    KeyPairs kp = std::make_pair(buffer_size_, buffer_);
    ht->insert_batch(kp);
    buffer_size_ = 0;
  }

  // Target hashtable.
  BaseHashTable* ht_;
  // Buffer to hold the arguments for batch insertion.
  __attribute__((aligned(64))) InsertFindArgument buffer_[N];
  // Current size of the buffer.
  size_t buffer_size_;

  // Sanity checks
  static_assert(N > 0);
};
} // namespace kmercounter
#endif  // HASHTABLES_BATCH_INSERTER_HPP
