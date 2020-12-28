#ifndef __KV_TYPES_HPP__
#define __KV_TYPES_HPP__

#include "types.hpp"

namespace kmercounter {

struct Kmer_base {
  Kmer_s kmer;
  uint16_t count;
} PACKED;

struct Kmer_KV {
  Kmer_base kb;              // 20 + 2 bytes
  uint64_t kmer_hash;        // 8 bytes
  volatile char padding[2];  // 2 bytes

  friend std::ostream &operator<<(std::ostream &strm, const Kmer_KV &k) {
    // return strm << std::string(k.kb.kmer.data, KMER_DATA_LENGTH) << " : "
    return strm << *((uint64_t *)k.kb.kmer.data) << " : " << k.kb.count;
  }

  inline void *data() { return this->kb.kmer.data; }

  inline void *key() { return this->kb.kmer.data; }

  inline void *value() { return NULL; }

  inline void insert_item(const void *from, size_t len) {
    const char *kmer_data = reinterpret_cast<const char *>(from);
    memcpy(this->kb.kmer.data, kmer_data, this->key_length());
    this->kb.count += 1;
  }

  inline bool compare_key(const void *from) {
    const char *kmer_data = reinterpret_cast<const char *>(from);
    return !memcmp(this->kb.kmer.data, kmer_data, this->key_length());
  }

  inline void update_value(const void *from, size_t len) {
    this->kb.count += 1;
  }

  inline uint16_t get_value() const { return this->kb.count; }

  inline constexpr size_t data_length() const { return sizeof(this->kb.kmer); }

  inline constexpr size_t key_length() const { return sizeof(this->kb.kmer); }

  inline constexpr size_t value_length() const { return sizeof(this->kb); }

  inline Kmer_KV get_empty_key() {
    Kmer_KV empty;
    memset(empty.kb.kmer.data, 0, sizeof(empty.kb.kmer.data));
    return empty;
  }

  inline bool is_empty() {
    Kmer_KV empty = this->get_empty_key();
    return !memcmp(this->key(), empty.key(), this->key_length());
  }

} PACKED;

static_assert(sizeof(Kmer_KV) % 32 == 0,
              "Sizeof Kmer_KV must be a multiple of 32");

// Kmer q in the hash hashtable
// Each q spills over a queue line for now, queue-align later
struct Kmer_queue {
  const void *data;
  uint32_t idx;  // TODO reduce size, TODO decided by hashtable size?
  uint8_t pad[4];
#ifdef COMPARE_HASH
  uint64_t key_hash;  // 8 bytes
#endif
} PACKED;

struct Aggr_KV {
  using key_type = uint64_t;
  using value_type = uint64_t;

  key_type key;
  value_type count;

  friend std::ostream &operator<<(std::ostream &strm, const Aggr_KV &k) {
    return strm << k.key << " : " << k.count;
  }

  // inline void *data() { return this; }

  // inline void *key() { return &this->key; }

  // inline void *value() { return NULL; }

  inline void insert_item(const void *from, size_t len) {
    const key_type *key = reinterpret_cast<const key_type *>(from);
    this->key = *key;
    this->count += 1;
  }

  inline bool cas_insert(const void *from, Aggr_KV &empty) {
    const key_type *key = reinterpret_cast<const key_type *>(from);
    auto success = __sync_bool_compare_and_swap(&this->key, empty.key, *key);

    if (success) {
      this->cas_update(from);
    }
    return success;
  }

  inline bool cas_update(const void *from) {
    auto ret = false;
    uint64_t old_val;
    while (!ret) {
      old_val = this->count;
      ret = __sync_bool_compare_and_swap(&this->count, old_val, old_val + 1);
    }
    return ret;
  }

  inline bool compare_key(const void *from) {
    const key_type *key = reinterpret_cast<const key_type *>(from);
    return this->key == *key;
  }

  inline void update_value(const void *from, size_t len) { this->count += 1; }

  inline uint16_t get_value() const { return this->count; }

  inline constexpr size_t data_length() const { return sizeof(Aggr_KV); }

  inline constexpr size_t key_length() const { return sizeof(key_type); }

  inline constexpr size_t value_length() const { return sizeof(value_type); }

  inline Aggr_KV get_empty_key() {
    Aggr_KV empty;
    empty.key = empty.count = 0;
    return empty;
  }

  inline bool is_empty() {
    Aggr_KV empty = this->get_empty_key();
    return this->key == empty.key;
  }
} PACKED;

struct KVPair {
  uint64_t key;
  uint64_t value;
} PACKED;

struct Item {
  KVPair kvpair;

  friend std::ostream &operator<<(std::ostream &strm, const Item &item) {
    return strm << item.kvpair.key << " : " << item.kvpair.value;
  }

  inline constexpr size_t data_length() const { return sizeof(KVPair); }

  inline constexpr size_t key_length() const { return sizeof(kvpair.key); }

  inline constexpr size_t value_length() const { return sizeof(kvpair.value); }

  inline void insert_item(const void *from, size_t len) {
    const KVPair *kvpair = reinterpret_cast<const KVPair *>(from);
    this->kvpair = *kvpair;
  }

  inline bool cas_insert(const void *from, Item &empty) {
    const KVPair *kvpair = reinterpret_cast<const KVPair *>(from);
    auto success = __sync_bool_compare_and_swap(&this->kvpair.key,
                                                empty.kvpair.key, kvpair->key);

    if (success) {
      this->kvpair.value = kvpair->value;
    }
    return success;
  }

  inline bool compare_key(const void *from) {
    const KVPair *kvpair = reinterpret_cast<const KVPair *>(from);
    return this->kvpair.key == kvpair->key;
  }

  inline void update_value(const void *from, size_t len) {
    const KVPair *kvpair = reinterpret_cast<const KVPair *>(from);
    this->kvpair.value = kvpair->value;
  }

  inline bool cas_update(const void *from) {
    const KVPair *kvpair = reinterpret_cast<const KVPair *>(from);
    auto ret = false;
    uint64_t old_val;
    while (!ret) {
      old_val = this->kvpair.value;
      ret = __sync_bool_compare_and_swap(&this->kvpair.value, old_val,
                                         kvpair->value);
    }
    return ret;
  }

  inline void *data() { return &this->kvpair; }

  inline void *key() { return &this->kvpair.key; }

  inline void *value() { return &this->kvpair.value; }

  inline uint16_t get_value() const { return this->kvpair.value; }

  inline Item get_empty_key() {
    Item empty;
    empty.kvpair.key = empty.kvpair.value = 0;
    return empty;
  }

  inline bool is_empty() {
    Item empty = this->get_empty_key();
    return this->kvpair.key == empty.kvpair.key;
  }

} PACKED;

struct ItemQueue {
  const void *data;
  uint32_t idx;
#ifdef COMPARE_HASH
  uint64_t key_hash;  // 8 bytes
#endif
} PACKED;

}  // namespace kmercounter
#endif  // __KV_TYPES_HPP__