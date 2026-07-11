/// Closed addressing chaining hash table implementation.
/// Follows the inlined implementation of:
/// https://dl.acm.org/doi/10.1145/3625549.3658682
///
/// DLHT organizes the primary table into 64-byte primary buckets, each
/// containing only 3 KV slots. To remain compatible with the benchmark
/// framework, the reported hash table's "capacity" refers to the total number
/// of KV entries (16-byte slots) that would fit in memory, i.e., 4 KV pairs per
/// 64 bytes (8-byte keys and 8-byte values), not the number of primary buckets.
///
/// Since DLHT hashes directly to a primary bucket using a modulo operation,
/// the implementation computes the number of primary buckets as:
///     capacity * sizeof(KV) / sizeof(Primary_bucket)
/// This preserves the requested primary table size while producing the
/// correct bucket count needed for bucket-level indexing.
///
/// In addition to the primary table, DLHT allocates an auxiliary link table
/// equal to 1/8 the size of the primary table. Like the primary table, the
/// link table is organized into 64-byte buckets, but each containing 4 KV slots.
/// Rather than being hash-addressed, link buckets are allocated on demand by
/// atomically incrementing a global link-bucket index, following the design
/// described in the DLHT paper.
///
/// Resizing is not implemented. If an operation would require a resize (e.g.,
/// no free slot can be found), the implementation reports a fatal error and
/// aborts. This matches the benchmark configuration, where the table is sized
/// sufficiently to avoid resizing.
///
/// Final fill percentage is reported using the benchmark's capacity
/// definition (4 KV slots per 64-byte unit), rather than DLHT's usable
/// primary capacity (3 KV slots per primary bucket). Occupied slots in both
/// the primary and link tables contribute to the reported fill percentage.
///
/// DlhtHashTable is not partitioned, meaning there is at most one instance
/// shared by all threads.


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
  static KV* hashtable;
  static KV* links;
  static std::atomic<uint32_t> link_alloc_idx;
  struct Slot {
    uint64_t key = 0;
    uint64_t value = 0;
  };

  struct Bin_hdr {
    // 0-1 bin_state (2 bits)
    // 2-31 slot states (15* 2 bits)
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
  static uint64_t num_buckets;

  static uint64_t link_alloc_size;
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
        link_alloc_size = this->capacity >> 3;
        this->links = calloc_ht<KV>(link_alloc_size, this->id, &this->fd);
        PLOGI.printf("DLHT Hashtable base: %p Hashtable size: %lu",
                     this->hashtable, this->capacity);
        PLOGI.printf("DLHT Links base: %p Links size: %lu", this->links,
                     link_alloc_size);

        uint64_t total_bytes = this->capacity * sizeof(KV);
        if (total_bytes % sizeof(Primary_bucket) != 0) {
          std::cerr
              << "Fatal Error: Hash table capacity (" << total_bytes
              << " bytes) does not divide evenly into 64-byte Primary buckets."
              << std::endl;
          abort();
        }

        num_buckets = total_bytes / sizeof(Primary_bucket);
        PLOGI.printf("capacity: %lu", this->capacity);
        PLOGI.printf("sizeof(KV): %lu", sizeof(KV));
        PLOGI.printf("sizeof(Primary_bucket): %lu", sizeof(Primary_bucket));
        PLOGI.printf("total_bytes: %lu", total_bytes);
        PLOGI.printf("remainder: %lu", total_bytes % sizeof(Primary_bucket));
        PLOGI.printf("num_buckets: %lu", num_buckets);
      }
      this->ref_cnt++;
    }
    this->empty_item = this->empty_item.get_empty_key();
    this->key_length = empty_item.key_length();
    this->data_length = empty_item.data_length();

    PLOGV << "Empty item: " << this->empty_item;
    this->insert_queue =
        (KVQ*)(aligned_alloc(64, PREFETCH_QUEUE_SIZE * sizeof(KVQ)));
    this->find_queue =
        (KVQ*)(aligned_alloc(64, PREFETCH_FIND_QUEUE_SIZE * sizeof(KVQ)));

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
        free_mem<KV>(this->links, link_alloc_size, this->id, this->fd);
        this->hashtable = nullptr;
        this->links = nullptr;
      }
    }
  }

  // Helper to cleanly resolve the slot pointer, returning nullptr if
  // unallocated
  Slot* get_slot(Primary_bucket* pb, int s) {
    if (s == 0) return &pb->slot_1;
    if (s == 1) return &pb->slot_2;
    if (s == 2) return &pb->slot_3;

    // Read the link_meta as a raw 64-bit value
    uint64_t m_val = *(volatile uint64_t*)&pb->link_meta;
    uint32_t idx_1 = m_val & 0xFFFFFFFF;
    uint32_t idx_2_3 = m_val >> 32;

    Link_bucket* l_table = (Link_bucket*)this->links;

    if (s >= 3 && s < 7) {
      if (idx_1 == 0) return nullptr;
      Link_bucket* lb = &l_table[idx_1 - 1];
      if (s == 3) return &lb->slot_1;
      if (s == 4) return &lb->slot_2;
      if (s == 5) return &lb->slot_3;
      if (s == 6) return &lb->slot_4;
    } else if (s >= 7 && s < 11) {
      if (idx_2_3 == 0) return nullptr;
      Link_bucket* lb = &l_table[idx_2_3 - 1];
      if (s == 7) return &lb->slot_1;
      if (s == 8) return &lb->slot_2;
      if (s == 9) return &lb->slot_3;
      if (s == 10) return &lb->slot_4;
    } else if (s >= 11 && s < 15) {
      if (idx_2_3 == 0) return nullptr;
      Link_bucket* lb = &l_table[idx_2_3];  // 2nd consecutive bucket
      if (s == 11) return &lb->slot_1;
      if (s == 12) return &lb->slot_2;
      if (s == 13) return &lb->slot_3;
      if (s == 14) return &lb->slot_4;
    }
    return nullptr;
  }

  // Atomically allocates and chains a link bucket using Fetch-and-Add
  void ensure_link(Primary_bucket* pb, int s) {
    if (s < 3) return;
    uint64_t* meta_ptr = (uint64_t*)&pb->link_meta;
    uint64_t exp_val, des_val;

    if (s >= 3 && s < 7) {
      exp_val = *(volatile uint64_t*)meta_ptr;
      while ((exp_val & 0xFFFFFFFF) == 0) {
        uint32_t new_idx = link_alloc_idx.fetch_add(1) + 1;
        des_val = (exp_val & 0xFFFFFFFF00000000ULL) | new_idx;
        if (__sync_bool_compare_and_swap(meta_ptr, exp_val, des_val)) break;
        exp_val = *(volatile uint64_t*)meta_ptr;
      }
    } else if (s >= 7) {
      exp_val = *(volatile uint64_t*)meta_ptr;
      while ((exp_val >> 32) == 0) {
        uint32_t new_idx = link_alloc_idx.fetch_add(2) + 1;
        des_val = (exp_val & 0xFFFFFFFFULL) | ((uint64_t)new_idx << 32);
        if (__sync_bool_compare_and_swap(meta_ptr, exp_val, des_val)) break;
        exp_val = *(volatile uint64_t*)meta_ptr;
      }
    }
  }

  void find_batch(const InsertFindArguments& kp, ValuePairs& vp,
                  collector_type* collector) override {
    uint64_t mask = (num_buckets)-1;
    Primary_bucket* p_table = (Primary_bucket*)this->hashtable;

    // Pass 1: Prefetch memory locations
    for (uint64_t i = 0; i < kp.size(); i++) {
      uint64_t idx = kp[i].key & mask;
      __builtin_prefetch(&p_table[idx], 0, 1);
    }

    // Pass 2: Execute Gets
    for (uint64_t i = 0; i < kp.size(); i++) {
      uint64_t idx = kp[i].key & mask;
      Primary_bucket* pb = &p_table[idx];
      uint64_t* hdr_ptr = (uint64_t*)&pb->bin_hdr;
      bool retry;

      do {
        retry = false;

        // Extract 32-bit states and version from the 64-bit header
        uint64_t h_val = *(volatile uint64_t*)hdr_ptr;
        uint32_t states = h_val & 0xFFFFFFFF;
        uint32_t version = h_val >> 32;

        bool found = false;
        uint64_t found_val = 0;

        for (int s = 0; s < 15; s++) {
          // States start at bit 2 (0-1 are bin_state)
          uint32_t state = (states >> (2 + s * 2)) & 0x3;
          if (state == 2) {  // 2 == Valid
            Slot* slot = get_slot(pb, s);
            if (slot && slot->key == kp[i].key) {
              found_val = slot->value;
              found = true;
              break;
            }
          }
        }

        uint64_t h_check_val = *(volatile uint64_t*)hdr_ptr;
        uint32_t check_version = h_check_val >> 32;

        if (check_version != version) {
          retry = true;
        } else if (found) {
          vp.second[vp.first].value = found_val;
          vp.second[vp.first].id = kp[i].id;
          vp.first++;
        }
      } while (retry);
    }
  }

  void insert_batch(const InsertFindArguments& kp,
                    collector_type* collector) override {
    uint64_t mask = (num_buckets)-1;
    Primary_bucket* p_table = (Primary_bucket*)this->hashtable;

    // Pass 1: Prefetch memory locations
    for (uint64_t i = 0; i < kp.size(); i++) {
      uint64_t idx = kp[i].key & mask;
      __builtin_prefetch(&p_table[idx], 1, 1);
    }

    // Pass 2: Execute Inserts
    for (uint64_t i = 0; i < kp.size(); i++) {
      uint64_t idx = kp[i].key & mask;
      Primary_bucket* pb = &p_table[idx];
      uint64_t* hdr_ptr = (uint64_t*)&pb->bin_hdr;

      bool inserted = false;
      while (!inserted) {
        uint64_t exp_val = *(volatile uint64_t*)hdr_ptr;
        uint32_t states = exp_val & 0xFFFFFFFF;
        uint32_t version = exp_val >> 32;

        // 1. Find the first Invalid slot (00)
        int target_s = -1;
        for (int s = 0; s < 15; s++) {
          if (((states >> (2 + s * 2)) & 0x3) == 0) {
            target_s = s;
            break;
          }
        }

        if (target_s == -1) {
          std::cerr << "Resize required: capacity exceeded.\n";
          abort();
        }

        // 2. CAS state from Invalid to TryInsert (01)
        uint32_t new_states = states;
        new_states &= ~(3U << (2 + target_s * 2));
        new_states |= (1U << (2 + target_s * 2));

        uint64_t des_val = ((uint64_t)(version + 1) << 32) | new_states;

        if (!__sync_bool_compare_and_swap(hdr_ptr, exp_val, des_val)) {
          continue;  // Retry on failure
        }

        // 3. Ensure chained bucket is allocated if past primary slots
        ensure_link(pb, target_s);

        // 4. Fill slot
        Slot* slot = get_slot(pb, target_s);
        slot->key = kp[i].key;
        slot->value = kp[i].value;

        // 5. CAS state from TryInsert to Valid (10)
        while (true) {
          exp_val = *(volatile uint64_t*)hdr_ptr;
          states = exp_val & 0xFFFFFFFF;
          version = exp_val >> 32;

          new_states = states;
          new_states &= ~(3U << (2 + target_s * 2));
          new_states |= (2U << (2 + target_s * 2));

          des_val = ((uint64_t)(version + 1) << 32) | new_states;

          if (__sync_bool_compare_and_swap(hdr_ptr, exp_val, des_val)) {
            inserted = true;
            break;
          }
        }
      }
    }
  }

  size_t get_fill() const override {
    size_t count = 0;
    Primary_bucket* p_table = (Primary_bucket*)this->hashtable;

    for (size_t i = 0; i < num_buckets; i++) {
      Primary_bucket* pb = &p_table[i];
      uint32_t states = pb->bin_hdr.states;

      for (int s = 0; s < 15; s++) {
        // Shift to the specific slot's 2-bit state and check if it equals 2
        // (Valid)
        if (((states >> (2 + s * 2)) & 0x3) == 2) {
          count++;
        }
      }
    }
    return count;
  }

  void flush_insert_queue(collector_type* collector) override {}
  void prefetch_queue(QueueType qtype) override {}

  void insert_noprefetch(const void* data, collector_type* collector) override {
  }

  bool insert(const void* data) {
    cout << "Not implemented!" << endl;
    assert(false);
    return false;
  }

  // We don't have OOO batches.
  size_t flush_find_queue(ValuePairs& vp, collector_type* collector) override {
    return 0;
  }

  void* find_noprefetch(const void* data, collector_type* collector) override {
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

  void print_to_file(std::string& outfile) const override {
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
  KVQ* find_queue;
  KVQ* insert_queue;
  uint32_t find_head;
  uint32_t find_tail;
  uint32_t ins_head;
  uint32_t ins_tail;
  Hasher hasher_;

  uint64_t read_hashtable_element(const void* data) override {
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
KV* DlhtHashTable<KV, KVQ>::hashtable = nullptr;

template <class KV, class KVQ>
KV* DlhtHashTable<KV, KVQ>::links = nullptr;

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

template <class KV, class KVQ>
uint64_t DlhtHashTable<KV, KVQ>::num_buckets = 0;

template <class KV, class KVQ>
uint64_t DlhtHashTable<KV, KVQ>::link_alloc_size = 0;
}  // namespace kmercounter
#endif  // HASHTABLES_DLHT_KHT_HPP