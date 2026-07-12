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
  /// Constants and State Enums
  static constexpr int MAX_SLOTS = 15;
  static constexpr uint32_t STATE_MASK = 0x3;
  
  // Structural boundaries for the bucket chain
  static constexpr int PRIMARY_SLOTS = 3;
  static constexpr int SLOTS_PER_LINK_BUCKET = 4;
  static constexpr int FIRST_LINK_START = PRIMARY_SLOTS;                                      // 3
  static constexpr int SECOND_LINK_START = FIRST_LINK_START + SLOTS_PER_LINK_BUCKET;          // 7
  static constexpr int THIRD_LINK_START = SECOND_LINK_START + SLOTS_PER_LINK_BUCKET;          // 11

  enum SlotState : uint32_t {
    INVALID = 0,
    TRY_INSERT = 1,
    VALID = 2
  };

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
  static uint64_t max_link_buckets;
  
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
        
        uint64_t total_link_bytes = link_alloc_size * sizeof(KV);
        max_link_buckets = total_link_bytes / sizeof(Link_bucket);

        PLOGI.printf("capacity: %lu", this->capacity);
        PLOGI.printf("sizeof(KV): %lu", sizeof(KV));
        PLOGI.printf("sizeof(Primary_bucket): %lu", sizeof(Primary_bucket));
        PLOGI.printf("total_bytes: %lu", total_bytes);
        PLOGI.printf("remainder: %lu", total_bytes % sizeof(Primary_bucket));
        PLOGI.printf("num_buckets: %lu", num_buckets);
        PLOGI.printf("max_link_buckets: %lu", max_link_buckets);
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

  // Inline helpers to abstract bitwise state manipulation
  inline SlotState extract_state(uint32_t states, int slot_index) const {
    return static_cast<SlotState>((states >> (2 + slot_index * 2)) & STATE_MASK);
  }

  inline uint32_t update_state(uint32_t states, int slot_index, SlotState new_state) const {
    states &= ~(STATE_MASK << (2 + slot_index * 2));
    states |= (static_cast<uint32_t>(new_state) << (2 + slot_index * 2));
    return states;
  }

  // Helper to cleanly resolve the slot pointer, returning nullptr if unallocated
  Slot* get_slot(Primary_bucket* primary_bucket, int slot_index) {
    if (slot_index == 0) return &primary_bucket->slot_1;
    if (slot_index == 1) return &primary_bucket->slot_2;
    if (slot_index == 2) return &primary_bucket->slot_3;

    // Read the link_meta as a raw 64-bit value
    uint64_t raw_link_meta = *(volatile uint64_t*)&primary_bucket->link_meta;
    uint32_t first_link_bucket_index = raw_link_meta & 0xFFFFFFFF;
    uint32_t second_and_third_link_bucket_index = raw_link_meta >> 32;

    Link_bucket* link_table = (Link_bucket*)this->links;

    if (slot_index >= FIRST_LINK_START && slot_index < SECOND_LINK_START) {
      if (first_link_bucket_index == 0) return nullptr;
      
      Link_bucket* link_bucket = &link_table[first_link_bucket_index - 1];
      if (slot_index == 3) return &link_bucket->slot_1;
      if (slot_index == 4) return &link_bucket->slot_2;
      if (slot_index == 5) return &link_bucket->slot_3;
      if (slot_index == 6) return &link_bucket->slot_4;
      
    } else if (slot_index >= SECOND_LINK_START && slot_index < THIRD_LINK_START) {
      if (second_and_third_link_bucket_index == 0) return nullptr;
      
      Link_bucket* link_bucket = &link_table[second_and_third_link_bucket_index - 1];
      if (slot_index == 7) return &link_bucket->slot_1;
      if (slot_index == 8) return &link_bucket->slot_2;
      if (slot_index == 9) return &link_bucket->slot_3;
      if (slot_index == 10) return &link_bucket->slot_4;
      
    } else if (slot_index >= THIRD_LINK_START && slot_index < MAX_SLOTS) {
      if (second_and_third_link_bucket_index == 0) return nullptr;
      
      Link_bucket* link_bucket = &link_table[second_and_third_link_bucket_index];  // 2nd consecutive bucket
      if (slot_index == 11) return &link_bucket->slot_1;
      if (slot_index == 12) return &link_bucket->slot_2;
      if (slot_index == 13) return &link_bucket->slot_3;
      if (slot_index == 14) return &link_bucket->slot_4;
    }
    return nullptr;
  }

  // Atomically allocates and chains a link bucket using Fetch-and-Add
  void allocate_link_bucket(Primary_bucket* primary_bucket, int slot_index) {
    if (slot_index < PRIMARY_SLOTS) return;
    
    uint64_t* link_meta_ptr = (uint64_t*)&primary_bucket->link_meta;
    uint64_t expected_value, desired_value;

    if (slot_index >= FIRST_LINK_START && slot_index < SECOND_LINK_START) {
      expected_value = *(volatile uint64_t*)link_meta_ptr;
      while ((expected_value & 0xFFFFFFFF) == 0) {
        uint32_t new_link_index = link_alloc_idx.fetch_add(1) + 1;
        
        if (new_link_index > max_link_buckets) {
          std::cerr << "Resize required: Global link bucket pool exhausted :3\n";
          abort();
        }

        desired_value = (expected_value & 0xFFFFFFFF00000000ULL) | new_link_index;
        if (__sync_bool_compare_and_swap(link_meta_ptr, expected_value, desired_value)) break;
        expected_value = *(volatile uint64_t*)link_meta_ptr;
      }
    } else if (slot_index >= SECOND_LINK_START) {
      expected_value = *(volatile uint64_t*)link_meta_ptr;
      while ((expected_value >> 32) == 0) {
        uint32_t new_link_index = link_alloc_idx.fetch_add(2) + 1;
        
        if (new_link_index + 1 > max_link_buckets) {
          std::cerr << "Resize required: Global link bucket pool exhausted :3\n";
          abort();
        }

        desired_value = (expected_value & 0xFFFFFFFFULL) | ((uint64_t)new_link_index << 32);
        if (__sync_bool_compare_and_swap(link_meta_ptr, expected_value, desired_value)) break;
        expected_value = *(volatile uint64_t*)link_meta_ptr;
      }
    }
  }

  void find_batch(const InsertFindArguments& kp, ValuePairs& vp,
                  collector_type* collector) override {
    uint64_t mask = num_buckets - 1;
    Primary_bucket* primary_table = (Primary_bucket*)this->hashtable;

    // Pass 1: Prefetch memory locations
    for (uint64_t i = 0; i < kp.size(); i++) {
      uint64_t idx = kp[i].key & mask;
      __builtin_prefetch(&primary_table[idx], 0, 1);
    }

    // Pass 2: Execute Gets
    for (uint64_t i = 0; i < kp.size(); i++) {
      uint64_t idx = kp[i].key & mask;
      Primary_bucket* primary_bucket = &primary_table[idx];
      uint64_t* header_ptr = (uint64_t*)&primary_bucket->bin_hdr;
      bool retry;

      do {
        retry = false;

        // Extract 32-bit states and version from the 64-bit header
        uint64_t header_value = *(volatile uint64_t*)header_ptr;
        uint32_t states = header_value & 0xFFFFFFFF;
        uint32_t version = header_value >> 32;

        bool found = false;
        uint64_t found_val = 0;

        for (int slot_index = 0; slot_index < MAX_SLOTS; slot_index++) {
          if (extract_state(states, slot_index) == VALID) {
            Slot* slot = get_slot(primary_bucket, slot_index);
            if (slot && slot->key == kp[i].key) {
              found_val = slot->value;
              found = true;
              break;
            }
          }
        }

        uint64_t check_header_value = *(volatile uint64_t*)header_ptr;
        uint32_t check_version = check_header_value >> 32;

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
    uint64_t mask = num_buckets - 1;
    Primary_bucket* primary_table = (Primary_bucket*)this->hashtable;

    // Pass 1: Prefetch memory locations
    for (uint64_t i = 0; i < kp.size(); i++) {
      uint64_t idx = kp[i].key & mask;
      __builtin_prefetch(&primary_table[idx], 1, 1);
    }

    // Pass 2: Execute Inserts
    for (uint64_t i = 0; i < kp.size(); i++) {
      uint64_t idx = kp[i].key & mask;
      Primary_bucket* primary_bucket = &primary_table[idx];
      uint64_t* header_ptr = (uint64_t*)&primary_bucket->bin_hdr;

      bool inserted = false;
      while (!inserted) {
        uint64_t expected_value = *(volatile uint64_t*)header_ptr;
        uint32_t states = expected_value & 0xFFFFFFFF;
        uint32_t version = expected_value >> 32;

        // 1. Find the first Invalid slot
        int target_slot_index = -1;
        for (int slot_index = 0; slot_index < MAX_SLOTS; slot_index++) {
          if (extract_state(states, slot_index) == INVALID) {
            target_slot_index = slot_index;
            break;
          }
        }

        if (target_slot_index == -1) {
          std::cerr << "Resize required: capacity exceeded :3\n";
          abort();
        }

        // 2. CAS state from Invalid to TryInsert
        uint32_t new_states = update_state(states, target_slot_index, TRY_INSERT);
        uint64_t desired_value = ((uint64_t)(version + 1) << 32) | new_states;

        if (!__sync_bool_compare_and_swap(header_ptr, expected_value, desired_value)) {
          continue;  // Retry on failure
        }

        // 3. Ensure chained bucket is allocated if past primary slots
        allocate_link_bucket(primary_bucket, target_slot_index);

        // 4. Fill slot
        Slot* slot = get_slot(primary_bucket, target_slot_index);
        slot->key = kp[i].key;
        slot->value = kp[i].value;

        // 5. CAS state from TryInsert to Valid
        while (true) {
          expected_value = *(volatile uint64_t*)header_ptr;
          states = expected_value & 0xFFFFFFFF;
          version = expected_value >> 32;

          new_states = update_state(states, target_slot_index, VALID);
          desired_value = ((uint64_t)(version + 1) << 32) | new_states;

          if (__sync_bool_compare_and_swap(header_ptr, expected_value, desired_value)) {
            inserted = true;
            break;
          }
        }
      }
    }
  }

  size_t get_fill() const override {
    size_t count = 0;
    Primary_bucket* primary_table = (Primary_bucket*)this->hashtable;

    for (size_t i = 0; i < num_buckets; i++) {
      Primary_bucket* primary_bucket = &primary_table[i];
      uint32_t states = primary_bucket->bin_hdr.states;

      for (int slot_index = 0; slot_index < MAX_SLOTS; slot_index++) {
        if (extract_state(states, slot_index) == VALID) {
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

template <class KV, class KVQ>
uint64_t DlhtHashTable<KV, KVQ>::max_link_buckets = 0;

}  // namespace kmercounter
#endif  // HASHTABLES_DLHT_KHT_HPP