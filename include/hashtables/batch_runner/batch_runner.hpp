#ifndef BATCH_RUNNER_BATCH_RUNNER_HPP
#define BATCH_RUNNER_BATCH_RUNNER_HPP

#include "batch_finder.hpp"
#include "batch_inserter.hpp"
#include "hashtables/base_kht.hpp"

namespace kmercounter {
/// A wrapper around `HTBatchInserter` and `HTBatchFinder`.
template <size_t N = HT_TESTS_BATCH_LENGTH>
class HTBatchRunner : public HTBatchInserter<N>, public HTBatchFinder<N> {
 public:
  using FindCallback = HTBatchFinder<N>::FindCallback;

  HTBatchRunner() = default;
  HTBatchRunner(BaseHashTable* ht) : HTBatchRunner(ht, nullptr) {}
  HTBatchRunner(BaseHashTable* ht, FindCallback find_callback)
      : HTBatchInserter<N>(ht), HTBatchFinder<N>(ht, find_callback) {}
  ~HTBatchRunner() { flush(); }

  /// Insert one kv pair.
  void insert(const uint64_t key, const uint64_t value) {
    HTBatchInserter<N>::insert(key, value);
  }

  /// Flush both insert and find queue.
  void flush() {
    flush_insert();
    flush_find();
  }

  /// Flush insert queue.
  void flush_insert() { HTBatchInserter<N>::flush(); }

  /// Flush find queue.
  void flush_find() { HTBatchFinder<N>::flush(); }

  /// Returns the number of inserts flushed.
  size_t num_insert_flushed() { return HTBatchInserter<N>::num_flushed(); }

  /// Returns the number of inserts flushed.
  size_t num_find_flushed() { return HTBatchFinder<N>::num_flushed(); }

  // Sanity checks
  static_assert(N > 0);
};
}  // namespace kmercounter

#endif  // BATCH_RUNNER_BATCH_RUNNER_HPP
