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

  inline void set_value(Aggr_KV *from) { this->count = from->count; }

  inline void update_brless(uint8_t cmp) {
    asm volatile(
        "mov %[count], %%rbx\n\t"
        "inc %%rbx\n\t"
        "cmpb $0xff, %[cmp]\n\t"
        "cmove %%rbx, %[count]"
        : [ count ] "+r"(this->count)
        : [ cmp ] "S"(cmp)
        : "rbx");
  }
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

  inline uint64_t find_key_brless(const void *data, uint64_t *retry) {
    Aggr_KV *kvpair =
        const_cast<Aggr_KV *>(reinterpret_cast<const Aggr_KV *>(data));

    uint64_t found = false;
    asm volatile(
        "xor %%r13, %%r13\n\t"
        "mov %[key_in], %%rbx\n\t"
        "mov %%rbx, %%r12\n\t"
        "xor %[key_curr], %%rbx\n\t"
        // if the key is empty, we'll get back the same data
        "cmp %%r12, %%rbx\n\t"
        // set empty = true;
        "mov $0x1, %%r15\n\t"
        "cmove %%r15, %%r13\n\t"
        // set found = false;
        "mov $0x0, %[found]\n\t"
        //"cmove %%r15, %[found]\n\t"
        //"cmovne %%r15, %[found]\n\t"
        // if key == data, we'll get zero. we've found the key!
        "xor %%r15, %%r15\n\t"
        "test %%rbx, %%rbx\n\t"
        "cmove %[val_curr], %%r15\n\t"
        "mov %%r15, %[value_out]\n\t"
        // set found = true;
        "mov $0x1, %%r15\n\t"
        "cmove %%r15, %[found]\n\t"
        // if key != data, we'll get > 0 && !data
        // if !empty && !found, return 0x1, to continue finding the key
        // e | f | retry
        // 0 | 0 | 1
        // 0 | 1 | 0
        // 1 | 0 | 0
        "mov %[found], %%r14\n\t"
        "xor %%r14, %%r13\n\t"
        "not %%r13\n\t"
        "and $0x1, %%r13\n\t"
        "xor %%r14, %%r14\n\t"
        "cmp $0x1, %%r13\n\t"
        "mov $0x1, %%r15\n\t"
        "cmove %%r15, %%r14\n\t"
        "mov %%r14, %[retry]\n\t"
        : [ value_out ] "=m"(kvpair->count), [ retry ] "=m"(*retry),
          [ found ] "=r"(found)
        : [ key_in ] "r"(kvpair->key), [ key_curr ] "m"(this->key),
          [ val_curr ] "rm"(this->count)
        : "rbx", "r12", "r13", "r14", "r15", "cc", "memory");
    return found;
  };

  inline uint16_t insert_or_update(const void *data) {
    uint16_t ret = 0;
    int empty = this->is_empty();
    asm volatile(
        "mov %[count], %%r14\n\t"
        "inc %%r14\n\t"              // inc count to use later
        "cmp $1, %[empty]\n\t"       // cmp is empty
        "cmove %[data], %[key]\n\t"  // conditionally move data to hashtable
        "cmp %[key], %[data]\n\t"
        "mov $0xFF, %%r13w\n\t"
        "cmove %%r14, %[count]\n\t"  //  conditionally increment count
        "cmove %%r13w, %[ret]\n\t"   // return success
        :
        [ ret ] "=r"(ret), [ key ] "+r"(this->key), [ count ] "+r"(this->count)
        : [ empty ] "r"(empty), [ data ] "r"(*(uint64_t *)data)
        : "r13", "r14", "memory");
    return ret;
  };
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

  inline uint16_t insert_or_update(const void *data) {
    std::cout << "Not implemented for Item!" << std::endl;
    assert(false);
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
