/// Compare-and-swap(CAS) with linear probing hashtable based off of
/// the folklore HT https://arxiv.org/pdf/1601.04017.pdf
/// Key and values are stored directly in the table.
/// FolkloreHashTable is not partitioned, meaning that there will be
/// at max one instance of it. All threads will share the same
/// instance.

#ifndef HASHTABLES_FOLKLORE_KHT_HPP
#define HASHTABLES_FOLKLORE_KHT_HPP

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
class FolkloreHashTable : public BaseHashTable {
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

  FolkloreHashTable(uint64_t c)
      : fd(-1), id(1), find_head(0), find_tail(0), ins_head(0), ins_tail(0) {
    this->capacity = kmercounter::utils::next_pow2(c);
    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);
      if (!this->hashtable) {
        assert(this->ref_cnt == 0);
        this->hashtable = calloc_ht<KV>(this->capacity, this->id, &this->fd);
        PLOGI.printf("Folklore Hashtable base: %p Hashtable size: %lu",
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

  ~FolkloreHashTable() {
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

  uint64_t crc_hash(const char *data) {
    return _mm_crc32_u64(0xffffffff, *reinterpret_cast<const uint64_t *>(data));
  }

  void insert_batch(const InsertFindArguments &kp,
                    collector_type *collector) override {
    for (const auto &data : kp) {
      insert_noprefetch(&data, collector);
    }
  }

  void find_batch(const InsertFindArguments &kp, ValuePairs &vp,
                  collector_type *collector) override {
    size_t found_count = 0;

    for (const auto &data : kp) {
      KV *result = static_cast<KV *>(find_noprefetch(&data, collector));

      if (result != nullptr) {
        vp.second[vp.first + found_count].value = result->get_value();
        vp.second[vp.first + found_count].id = data.id;
        found_count++;
      }
    }

    vp.first += found_count;
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
    uint64_t hash = crc_hash((const char *)data);

    size_t idx = hash & (this->capacity - 1);  // modulo
    // size_t idx = fastrange32(hash, this->capacity);  // modulo

    KVQ *elem = const_cast<KVQ *>(reinterpret_cast<const KVQ *>(data));

    for (auto i = 0u; i < this->capacity; i++) {
      KV *curr = &this->hashtable[idx];
    retry:
      if (curr->is_empty()) {
        bool cas_res = curr->insert_cas(elem);
        if (cas_res) {
          break;
        } else {
          goto retry;
        }
      } else if (curr->compare_key(data)) {
        curr->update_cas(elem);
        break;
      } else {
        idx++;
        idx = idx & (this->capacity - 1);
      }
    }
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

  void *find_noprefetch(const void *data, collector_type *collector) override {
    uint64_t hash = crc_hash((const char *)data);
    size_t idx = hash;
    // size_t idx = fastrange32(hash, this->capacity);  // modulo
    InsertFindArgument *item = const_cast<InsertFindArgument *>(
        reinterpret_cast<const InsertFindArgument *>(data));
    KV *curr;
    bool found = false;

    // printf("Thread %" PRIu64 ": Trying memcmp at: %" PRIu64 "\n",
    // this->thread_id, idx);
    for (auto i = 0u; i < this->capacity; i++) {
      idx = idx & (this->capacity - 1);
      curr = &this->hashtable[idx];

      if (curr->is_empty()) {
        found = false;
        goto exit;
      } else if (curr->compare_key(data)) {
        found = true;
        break;
      }

      idx++;
    }

  exit:

    // return empty_element if nothing is found
    if (!found) {
      printf("key %" PRIu64 " not found at idx %" PRIu64 " | hash %" PRIu64
             "\n",
             item->key, idx, hash);
      curr = nullptr;
    }

    return curr;
  }
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

  void print_to_file(std::string &outfile) const override {}

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

  uint64_t read_hashtable_element(const void *data) override {
    PLOG_FATAL << "Not implemented";
    assert(false);
    return -1;
  }

  void clear() override { memset(this->hashtable, 0, capacity * sizeof(KV)); }
};

/// Static variables
template <class KV, class KVQ>
KV *FolkloreHashTable<KV, KVQ>::hashtable = nullptr;

template <class KV, class KVQ>
uint64_t FolkloreHashTable<KV, KVQ>::empty_slot_ = 0;

template <class KV, class KVQ>
bool FolkloreHashTable<KV, KVQ>::empty_slot_exists_ = false;

template <class KV, class KVQ>
std::mutex FolkloreHashTable<KV, KVQ>::ht_init_mutex;

template <class KV, class KVQ>
uint32_t FolkloreHashTable<KV, KVQ>::ref_cnt = 0;
}  // namespace kmercounter
#endif  // HASHTABLES_FOLKLORE_KHT_HPP