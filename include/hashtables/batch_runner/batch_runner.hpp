#ifndef BATCH_RUNNER_BATCH_RUNNER_HPP
#define BATCH_RUNNER_BATCH_RUNNER_HPP

#include "batch_finder.hpp"
#include "batch_inserter.hpp"
#include "hashtables/base_kht.hpp"

namespace kmercounter {
extern Configuration config;
/// A wrapper around `HTBatchInserter` and `HTBatchFinder`.
template <size_t N = HT_TESTS_BATCH_LENGTH>
class HTBatchRunner : public HTBatchInserter<N>, public HTBatchFinder<N> {
 public:
  using FindCallback = HTBatchFinder<N>::FindCallback;

  HTBatchRunner() : HTBatchRunner(nullptr) {}
  HTBatchRunner(BaseHashTable* ht) : HTBatchRunner(ht, nullptr) {}
  HTBatchRunner(BaseHashTable* ht, FindCallback find_callback)
      : HTBatchInserter<N>(ht), HTBatchFinder<N>(ht, find_callback) {}
  ~HTBatchRunner() { flush(); }

  /// Insert one kv pair.
  void insert(const uint64_t key, const uint64_t value) {
    if (config.no_prefetch) {
      KeyValuePair kv;
      kv.key = key;
      kv.value = value;
      HTBatchInserter<N>::insert_noprefetch(kv);
    } else {
      HTBatchInserter<N>::insert(key, value);
    }
  }

  /// Insert one kv pair.
  inline void insert(const KeyValuePair& kv) {
    if (config.no_prefetch) {
      HTBatchInserter<N>::insert_noprefetch(kv);
    } else {
      // this->insert(kv.key, kv.value);
      HTBatchInserter<N>::insert(kv.key, kv.value);
    }
  }

  void* find(const KeyValuePair& kv) {
    if (config.no_prefetch) {
      return HTBatchFinder<N>::find_noprefetch(kv);
    } else {
      HTBatchFinder<N>::find(kv.key, kv.value);
      return nullptr;
    }
  }

  /// Flush both insert and find queue.
  void flush() {
    flush_insert();
    flush_find();
  }

  /// Flush insert queue.
  void flush_insert() {
    if (!config.no_prefetch) HTBatchInserter<N>::flush();
  }

  /// Flush find queue.
  void flush_find() {
    if (!config.no_prefetch) HTBatchFinder<N>::flush();
  }

  /// Returns the number of inserts flushed.
  size_t num_insert_flushed() { return HTBatchInserter<N>::num_flushed(); }

  /// Returns the number of inserts flushed.
  size_t num_find_flushed() { return HTBatchFinder<N>::num_flushed(); }

  // Sanity checks
  static_assert(N > 0);
};
}  // namespace kmercounter

#endif  // BATCH_RUNNER_BATCH_RUNNER_HPP
