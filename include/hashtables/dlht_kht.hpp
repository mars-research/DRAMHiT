/// Compare-and-swap(CAS) with linear probing hashtable based off of
/// the folklore HT https://arxiv.org/pdf/1601.04017.pdf
/// Key and values are stored directly in the table.
/// DlhtHashTable is not parititioned, meaning that there will be
/// at max one instance of it. All threads will share the same
/// instance.

#ifndef HASHTABLES_DLHT_KHT_HPP
#define HASHTABLES_DLHT_KHT_HPP

#include <cassert>
#include <fstream>
#include <iostream>
#include <mutex>
#include <type_traits>

#include "constants.hpp"
#include "hasher.hpp"
#include "helper.hpp"
#include "ht_helper.hpp"
#include "plog/Log.h"
#include "sync.h"

namespace kmercounter {
template <typename KV, typename KVQ>
class DlhtHashTable : public BaseHashTable {
 public:
  /// The global instance is shared by all threads.
  static KV *hashtable;
  /// A dedicated slot for the empty value.
  static uint64_t empty_slot_;
  /// True if the empty value is inserted.
  static bool empty_slot_exists_;
  /// File descriptor backs the memory
  int fd;
  int id;
  size_t data_length, key_length;
  const static uint64_t CACHELINE_SIZE = 64;
  const static uint64_t KEYS_IN_CACHELINE_MASK =
      (CACHELINE_SIZE / sizeof(KV)) - 1;

  DlhtHashTable(uint64_t c)
      : fd(-1), id(1), find_head(0), find_tail(0), ins_head(0), ins_tail(0) {
    this->capacity = kmercounter::utils::next_pow2(c);
    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);
      if (!this->hashtable) {
        assert(this->ref_cnt == 0);
        this->hashtable = calloc_ht<KV>(this->capacity, this->id, &this->fd);
        PLOGI.printf("DLHT Hashtable base: %p Hashtable size: %lu",
                     this->hashtable, this->capacity);
      }
      this->ref_cnt++;
    }
    this->empty_item = this->empty_item.get_empty_key();
    this->key_length = empty_item.key_length();
    this->data_length = empty_item.data_length();

    PLOGV << "Empty item: " << this->empty_item;
    this->insert_queue =
        (KVQ *)(aligned_alloc(64, PREFETCH_QUEUE_SIZE * sizeof(KVQ)));
    this->find_queue =
        (KVQ *)(aligned_alloc(64, PREFETCH_FIND_QUEUE_SIZE * sizeof(KVQ)));

    PLOGV.printf("%s, data_length %lu\n", __func__, this->data_length);
  }

  ~DlhtHashTable() {
    free(find_queue);
    free(insert_queue);
    // Deallocate the global hashtable if ref_cnt goes down to zero.
    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);
      this->ref_cnt--;
      if (this->ref_cnt == 0) {
        free_mem<KV>(this->hashtable, this->capacity, this->id, this->fd);
        this->hashtable = nullptr;
      }
    }
  }

  void insert_batch(const InsertFindArguments &kp,
                    collector_type *collector) override {

                      //TODO
                    }

  void find_batch(const InsertFindArguments &kp, ValuePairs &values,
                  collector_type *collector) override {
                    //TODO
                  }

  size_t get_fill() const override {
    size_t count = 0;
    for (size_t i = 0; i < this->capacity; i++) {
      if (!this->hashtable[i].is_empty()) {
        count++;
      }
    }
    return count;
  }

  void flush_insert_queue(collector_type *collector) override {}
  void prefetch_queue(QueueType qtype) override {}

  void insert_noprefetch(const void *data, collector_type *collector) override {
  }

  bool insert(const void *data) {
    cout << "Not implemented!" << endl;
    assert(false);
    return false;
  }
  size_t flush_find_queue(ValuePairs &vp, collector_type *collector) override {
    size_t curr_queue_sz = 0;
    return curr_queue_sz;
  }

  void *find_noprefetch(const void *data, collector_type *collector) override {}

  void display() const override {
    for (size_t i = 0; i < this->capacity; i++) {
      if (!this->hashtable[i].is_empty()) {
        cout << this->hashtable[i] << endl;
      }
    }
  }

  size_t get_capacity() const override { return this->capacity; }

  size_t get_max_count() const override {
    size_t count = 0;
    for (size_t i = 0; i < this->capacity; i++) {
      if (this->hashtable[i].get_value() > count) {
        count = this->hashtable[i].get_value();
      }
    }
    return count;
  }

  void print_to_file(std::string &outfile) const override {
    std::ofstream f(outfile);
    if (!f) {
      PLOG_ERROR.printf("Could not open outfile %s", outfile.c_str());
      return;
    }

    for (size_t i = 0; i < this->get_capacity(); i++) {
      if (!this->hashtable[i].is_empty()) {
        f << this->hashtable[i] << std::endl;
      }
    }
  }

 private:
  /// Assure thread-safety in constructor and destructor.
  static std::mutex ht_init_mutex;
  /// Reference counter of the global `hashtable`.
  static uint32_t ref_cnt;
  uint64_t capacity;
  KV empty_item;
  KVQ *find_queue;
  KVQ *insert_queue;
  uint32_t find_head;
  uint32_t find_tail;
  uint32_t ins_head;
  uint32_t ins_tail;
  Hasher hasher_;

  uint64_t hash(const void *k) { return hasher_(k, this->key_length); }

  void prefetch(uint64_t i) {
#if defined(PREFETCH_WITH_PREFETCH_INSTR)
    prefetch_object<true /* write */>(
        &this->hashtable[i & (this->capacity - 1)],
        sizeof(this->hashtable[i & (this->capacity - 1)]));
    // true /*write*/);
#endif

#if defined(PREFETCH_WITH_WRITE)
    prefetch_with_write(&this->hashtable[i & (this->capacity - 1)]);
#endif
  };

  void prefetch_read(uint64_t i) {
    prefetch_object<false /* write */>(
        &this->hashtable[i & (this->capacity - 1)],
        sizeof(this->hashtable[i & (this->capacity - 1)]));
  }

  uint64_t read_hashtable_element(const void *data) override {
    PLOG_FATAL << "Not implemented";
    assert(false);
    return -1;
  }

  void clear() override { memset(this->hashtable, 0, capacity * sizeof(KV)); }
};

/// Static variables
template <class KV, class KVQ>
KV *DlhtHashTable<KV, KVQ>::hashtable = nullptr;

template <class KV, class KVQ>
uint64_t DlhtHashTable<KV, KVQ>::empty_slot_ = 0;

template <class KV, class KVQ>
bool DlhtHashTable<KV, KVQ>::empty_slot_exists_ = false;

template <class KV, class KVQ>
std::mutex DlhtHashTable<KV, KVQ>::ht_init_mutex;

template <class KV, class KVQ>
uint32_t DlhtHashTable<KV, KVQ>::ref_cnt = 0;
}  // namespace kmercounter
#endif  // HASHTABLES_DLHT_KHT_HPP