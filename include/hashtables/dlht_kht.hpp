/// Closed addressing chaining hash table implementation
/// follows the inlined implementation of:
/// https://dl.acm.org/doi/10.1145/3625549.3658682 Resizing is not implemented
/// as it isn't included in main throughput benchmarks DlhtHashTable is not
/// parititioned, meaning that there will be at max one instance of it. All
/// threads will share the same instance.

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
  static KV *links;
  static std::atomic<uint32_t> link_alloc_idx;
  struct Slot {
    uint64_t key = 0;
    uint64_t value = 0;
  };

  struct Bin_hdr {
    //0-1 bin_state (2 bits)
    //2-31 slot states (15* 2 bits)
    uint32_t states = 0;
    uint32_t version = 0;
  };

  struct Link_meta {
    uint32_t link_bucket_idx_1 = 0;
    uint32_t link_bucket_idx_2_3 = 0;
  };

  struct alignas(64) Primary_bucket {
    Bin_hdr bin_hdr;
    Link_meta link_meta;
    Slot slot_1;
    Slot slot_2;
    Slot slot_3;
  };

  struct alignas(64) Link_bucket {
    Slot slot_1;
    Slot slot_2;
    Slot slot_3;
    Slot slot_4;
  };

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
        uint64_t link_alloc_size = this->capacity >> 3;
        this->links = calloc_ht<KV>(link_alloc_size, this->id, &this->fd);
        PLOGI.printf("DLHT Hashtable base: %p Hashtable size: %lu",
                     this->hashtable, this->capacity);

        PLOGI.printf("DLHT Links base: %p Links size: %lu",
                     this->links, link_alloc_size);
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
        uint64_t link_alloc_size = this->capacity >> 3;
        free_mem<KV>(this->links, link_alloc_size, this->id, this->fd);
        this->hashtable = nullptr;
        this->links = nullptr;
      }
    }
  }

  void insert_batch(const InsertFindArguments &kp,
                    collector_type *collector) override {
    // TODO
  }

  void find_batch(const InsertFindArguments &kp, ValuePairs &values,
                  collector_type *collector) override {
    // TODO
  }

  size_t get_fill() const override {
    size_t count = 0;
    // for (size_t i = 0; i < this->capacity; i++) {
    //   if (!this->hashtable[i].is_empty()) {
    //     count++;
    //   }
    // }
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

  // We don't have OOO batches.
  size_t flush_find_queue(ValuePairs &vp, collector_type *collector) override {
    return 0;
  }

  void *find_noprefetch(const void *data, collector_type *collector) override {
    cout << "Not implemented!!!" << endl;
    assert(false);
  }

  void display() const override {
    cout << "Not implemented!!!!" << endl;
    assert(false);
  }

  size_t get_capacity() const override { return this->capacity; }

  size_t get_max_count() const override {
    size_t count = 0;
    cout << "Not implemented!!!!!!" << endl;
    assert(false);
    return count;
  }

  void print_to_file(std::string &outfile) const override {
    cout << "Not implemented!!!!!!!" << endl;
    assert(false);
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
    cout << "Not implemented!!!!!!!!!!" << endl;
    assert(false);
  };

  uint64_t read_hashtable_element(const void *data) override {
    cout << "Not implemented!!!!!!!!!!" << endl;
    assert(false);
    return -1;
  }

  void clear() override {
    cout << "Not implemented!!!!!!!!!!!" << endl;
    assert(false);
    memset(this->hashtable, 0, capacity * sizeof(KV));
  }
};

/// Static variables
template <class KV, class KVQ>
KV *DlhtHashTable<KV, KVQ>::hashtable = nullptr;

template <class KV, class KVQ>
KV *DlhtHashTable<KV, KVQ>::links = nullptr;

template <class KV, class KVQ>
std::atomic<uint32_t> DlhtHashTable<KV, KVQ>::link_alloc_idx{0};

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