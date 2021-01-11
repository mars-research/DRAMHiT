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

struct ItemQueue {
  uint64_t key;
  uint64_t value;
  uint32_t key_id;
  uint32_t idx;
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

  inline bool insert_regular_v2(const void *data) {
    ItemQueue *elem =
        const_cast<ItemQueue *>(reinterpret_cast<const ItemQueue *>(data));

    if (this->is_empty()) {
      this->key = elem->key;
      this->count += 1;
      return false;
    } else if (this->key == elem->key) {
      this->count += 1;
      return false;
    }
    return true;
  }

  inline bool cas_insert(const void *data) {
    ItemQueue *elem =
        const_cast<ItemQueue *>(reinterpret_cast<const ItemQueue *>(data));

    const Aggr_KV empty = this->get_empty_key();
    auto success =
        __sync_bool_compare_and_swap(&this->key, empty.key, elem->key);

    if (success) {
      this->cas_update(data);
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
    ItemQueue *elem =
        const_cast<ItemQueue *>(reinterpret_cast<const ItemQueue *>(from));
    return this->key == elem->key;
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

  inline uint64_t find_key_regular_v2(const void *data, uint64_t *retry,
                                      ValuePairs &vp) {
    ItemQueue *elem =
        const_cast<ItemQueue *>(reinterpret_cast<const ItemQueue *>(data));
    auto found = false;
    *retry = 0;
    if (this->is_empty()) {
      goto exit;
    } else if (this->key == elem->key) {
      found = true;
      vp.second[vp.first].value = this->count;
      vp.second[vp.first].id = elem->key_id;
      vp.first++;
      goto exit;
    } else {
      *retry = 1;
    }
  exit:
    return found;
  }

#define EMPTY_CHECK_C

  inline uint64_t find_key_brless_v2(const void *data, uint64_t *retry,
                                     ValuePairs &vp) {
    ItemQueue *elem =
        const_cast<ItemQueue *>(reinterpret_cast<const ItemQueue *>(data));

    uint8_t found = false;
    uint32_t cur_val_idx = vp.first;

#ifdef EMPTY_CHECK_C
    // *retry = 1;
    asm volatile(
        // prep registers
        "xor %%r15, %%r15\n\t"
        "xor %%r14, %%r14\n\t"
        // move incoming key to rbx
        "mov %[key_in], %%rbx\n\t"
        // if ((cur->key ^ key) == 0), we've found the key!
        "xor %[key_curr], %%rbx\n\t"
        "cmp %[key_in], %%rbx\n\t"
        // set empty = true
        "sete %%r13b\n\t"
        // temporarily increment the cur_val_idx (local var)
        "inc %[cur_val_idx]\n\t"
        // check if the key is equal to curr->key
        "test %%rbx, %%rbx\n\t"
        "cmove %[val_curr], %%r15\n\t"
        "mov %%r15, %[value_out]\n\t"
        // copy key_id if found = true
        "cmove %[key_id], %%r14d\n\t"
        "mov %%r14, %[value_id]\n\t"
        // set found = true;
        "sete %[found]\n\t"
        "mov %[values_idx], %%r14\n\t"
        "cmove %[cur_val_idx], %%r14d\n\t"
        "mov %%r14, %[values_idx]\n\t"

        // if key != data, we'll get > 0 && !data
        // if !empty && !found, return 0x1, to continue finding the key
        // e | f | retry
        // 0 | 0 | 1
        // 0 | 1 | 0
        // 1 | 0 | 0
        "xor %[found], %%r13b\n\t"
        "cmp $0x1, %%r13b\n\t"
        // "mov %[retry], %%r14\n\t"
        "setne %%r15b\n\t"
        "mov %%r15, %[retry]\n\t"
        : [ value_out ] "=m"(vp.second[cur_val_idx]),
          [ value_id ] "=m"(vp.second[cur_val_idx].id), [ retry ] "=m"(*retry),
          [ found ] "+r"(found), [ values_idx ] "+m"(vp.first),
          [ cur_val_idx ] "+r"(cur_val_idx)
        : [ key_in ] "r"(elem->key), [ key_id ] "r"(elem->key_id),
          [ key_curr ] "m"(this->key), [ val_curr ] "rm"(this->count)
        : "rax", "rbx", "r12", "r13", "r14", "r15", "cc", "memory");
#else
    bool empty = this->is_empty();

    asm volatile(
        "xor %%r13, %%r13\n\t"
        "mov %[key_in], %%rbx\n\t"
        "xor %[key_curr], %%rbx\n\t"
        "mov $0x0, %[found]\n\t"

        // 2) if key == data, we'll get zero. we've found the key!
        "xor %%r15, %%r15\n\t"
        "xor %%r14, %%r14\n\t"
        // increment the cur_val_idx
        "inc %[cur_val_idx]\n\t"
        "test %%rbx, %%rbx\n\t"
        "cmove %[val_curr], %%r15\n\t"
        "mov %%r15, %[value_out]\n\t"
        // copy key_id if found = true
        "cmove %[key_id], %%r14d\n\t"
        "mov %%r14, %[value_id]\n\t"

        // set found = true;
        "mov $0x1, %%r15\n\t"
        "cmove %%r15, %[found]\n\t"
        "mov %[values_idx], %%r14\n\t"
        "cmove %[cur_val_idx], %%r14d\n\t"
        "mov %%r14, %[values_idx]\n\t"
        // if key != data, we'll get > 0 && !data
        // if !empty && !found, return 0x1, to continue finding the key
        // e | f | retry
        // 0 | 0 | 1
        // 0 | 1 | 0
        // 1 | 0 | 0
        "mov %[empty], %%r13b\n\t"
        "mov %[found], %%r14\n\t"
        "or %%r14, %%r13\n\t"
        "cmp $0x1, %%r13\n\t"
        "mov %[retry], %%r14\n\t"
        "mov $0x0, %%r15\n\t"
        "cmove %%r15, %%r14\n\t"
        "mov %%r14, %[retry]\n\t"

        // "not %%r13\n\t"
        // "and $0x1, %%r13\n\t"
        // "xor %%r14, %%r14\n\t"
        // "cmp $0x1, %%r13\n\t"
        // "mov $0x1, %%r15\n\t"
        // "cmove %%r15, %%r14\n\t"
        // "mov %%r14, %[retry]\n\t"
        : [ value_out ] "=m"(vp.second[cur_val_idx]),
          [ value_id ] "=m"(vp.second[cur_val_idx].id), [ retry ] "=m"(*retry),
          [ found ] "+r"(found), [ values_idx ] "+m"(vp.first),
          [ cur_val_idx ] "+r"(cur_val_idx)
        : [ key_in ] "r"(elem->key), [ key_id ] "r"(elem->key_id),
          [ key_curr ] "m"(this->key), [ val_curr ] "rm"(this->count),
          [ empty ] "r"(empty)
        : "rax", "rbx", "r12", "r13", "r14", "r15", "cc", "memory");
#endif  // EMPTY_CHECK_C
    return found;
  };

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

#if 0
  inline uint16_t insert_or_update_v2(const void *data) {
    ItemQueue *elem =
        const_cast<ItemQueue *>(reinterpret_cast<const ItemQueue *>(data));

    uint16_t ret = 0;
    int empty = this->is_empty();
    asm volatile(
        "mov %[count], %%r14\n\t"
        "inc %%r14\n\t"              // inc count to use later
        "cmp $1, %[empty]\n\t"       // cmp is empty
        "cmove %[key_in], %[key]\n\t"  // conditionally move data to hashtable
        "cmp %[key], %[key_in]\n\t"
        "mov $0xFF, %%r13w\n\t"
        "cmove %%r14, %[count]\n\t"  //  conditionally increment count
        //"sete %[ret]\n\t"
        "cmove %%r13w, %[ret]\n\t"   // return success
        :
        [ ret ] "=r"(ret), [ key ] "+r"(this->key), [ count ] "+r"(this->count)
        : [ empty ] "r"(empty), [ key_in ] "r"(elem->key)
        : "r13", "r14", "cc", "memory");
    return ret;
  };
#else

  inline uint16_t insert_or_update_v2(const void *data) {
    ItemQueue *elem =
        const_cast<ItemQueue *>(reinterpret_cast<const ItemQueue *>(data));
    Aggr_KV empty = this->get_empty_key();

#if 0
    //uint8_t ret = 0;
    // __m64 empty_mask = _mm_set1_pi8((this->is_empty() << 7));
    auto inc_count = reinterpret_cast<__m64>(this->count + 1);
    auto this_key = reinterpret_cast<__m64>(this->key);
    auto key_in = reinterpret_cast<__m64>(elem->key);
    auto empty_key = reinterpret_cast<__m64>(empty.key);
    
    auto equal_mask = _mm_cmpeq_pi32(key_in, this_key);
    auto empty_mask = _mm_cmpeq_pi32(empty_key, this_key);

    _m_maskmovq(key_in, empty_mask, reinterpret_cast<char*>(&this->key));
    _m_maskmovq(inc_count, equal_mask, reinterpret_cast<char*>(&this->count));

    return _m_pmovmskb(_mm_or_si64(equal_mask, empty_mask));
#else
    int ret = 0;
    asm volatile(
        "movq %[count], %%r13\n\t"
        "inc %%r13\n\t"  // inc count to use later
        "movq %%r13, %%mm0\n\t"
        "movq %[key_in], %%mm1\n\t"
        "movq %[key], %%mm2\n\t"
        "movq %[empty_key], %%mm3\n\t"
        // empty_mask mm3
        "pcmpeqd %%mm2, %%mm3\n\t"
        // equal_mask mm2
        "pcmpeqd %%mm1, %%mm2\n\t"
        "mov %[_this], %%rdi\n\t"
        "maskmovq %%mm3, %%mm1\n\t"
        "add $0x8, %%rdi\n\t"
        "maskmovq %%mm2, %%mm0\n\t"
        "por %%mm2, %%mm3\n\t"
        "pmovmskb %%mm3, %[ret]\n\t"
        : [ ret ] "=r"(ret)
        : [ key ] "r"(this->key), [ count ] "r"(this->count),
          [ empty_key ] "r"(empty.key), [ key_in ] "r"(elem->key),
          [ _this ] "r"(this)
        : "mm0", "mm1", "mm2", "mm3", "rdi", "r13", "cc", "memory");
    return ret;
#endif
  };
#endif
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

  inline bool cas_insert(const void *from) {
    const ItemQueue *elem = reinterpret_cast<const ItemQueue *>(from);
    const Item empty = this->get_empty_key();

    auto success = __sync_bool_compare_and_swap(&this->kvpair.key,
                                                empty.kvpair.key, elem->key);

    if (success) {
      this->update_value(from);
    }
    return success;
  }

  inline uint16_t insert_or_update(const void *data) {
    std::cout << "Not implemented for Item!" << std::endl;
    assert(false);
  }

  inline bool insert_regular_v2(const void *data) {
    cout << "Not implemented!" << endl;
    assert(false);
  }

  inline bool compare_key(const void *from) {
    const KVPair *kvpair = reinterpret_cast<const KVPair *>(from);
    return this->kvpair.key == kvpair->key;
  }

  inline void update_value(const void *from) {
    const KVPair *kvpair = reinterpret_cast<const KVPair *>(from);
    this->kvpair.value = kvpair->value;
  }

  inline bool cas_update(const void *from) {
    const ItemQueue *elem = reinterpret_cast<const ItemQueue *>(from);
    auto ret = false;
    uint64_t old_val;
    while (!ret) {
      old_val = this->kvpair.value;
      ret = __sync_bool_compare_and_swap(&this->kvpair.value, old_val,
                                         elem->value);
    }
    return ret;
  }

  inline void *data() { return &this->kvpair; }

  inline void *key() { return &this->kvpair.key; }

  inline void *value() { return &this->kvpair.value; }

  inline uint64_t get_value() const { return this->kvpair.value; }

  inline Item get_empty_key() {
    Item empty;
    empty.kvpair.key = empty.kvpair.value = 0;
    return empty;
  }

  inline bool is_empty() {
    Item empty = this->get_empty_key();
    return this->kvpair.key == empty.kvpair.key;
  }

  inline uint64_t find_key_brless_v2(const void *data, uint64_t *retry,
                                     ValuePairs &vp) {
    ItemQueue *item =
        const_cast<ItemQueue *>(reinterpret_cast<const ItemQueue *>(data));

    uint64_t found = false;
    uint32_t cur_val_idx = vp.first;

    asm volatile(
        "xor %%r13, %%r13\n\t"
        "mov %[key_in], %%rbx\n\t"
        "mov %%rbx, %%r12\n\t"
        "xor %[key_curr], %%rbx\n\t"
        // 1) if the key is empty, we'll get back the same data
        "cmp %%r12, %%rbx\n\t"
        // set empty = true;
        "mov $0x1, %%r15\n\t"
        "cmove %%r15, %%r13\n\t"
        // set found = false;
        // "cmove $0x0, %[found]\n\t"

        // 2) if key == data, we'll get zero. we've found the key!
        "xor %%r15, %%r15\n\t"
        "xor %%r14, %%r14\n\t"
        // increment the cur_val_idx
        "inc %[cur_val_idx]\n\t"
        "test %%rbx, %%rbx\n\t"
        "cmove %[val_curr], %%r15\n\t"
        "mov %%r15, %[value_out]\n\t"
        // copy key_id if found = true
        "cmove %[key_id], %%r14d\n\t"
        "mov %%r14, %[value_id]\n\t"

        // set found = true;
        "mov $0x1, %%r15\n\t"
        "cmove %%r15, %[found]\n\t"
        "mov %[values_idx], %%r14\n\t"
        "cmove %[cur_val_idx], %%r14d\n\t"
        "mov %%r14, %[values_idx]\n\t"

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
        : [ value_out ] "=m"(vp.second[cur_val_idx]),
          [ value_id ] "=m"(vp.second[cur_val_idx].id), [ retry ] "=m"(*retry),
          [ found ] "+r"(found), [ values_idx ] "+m"(vp.first),
          [ cur_val_idx ] "+r"(cur_val_idx)
        : [ key_in ] "r"(item->key), [ key_id ] "r"(item->key_id),
          [ key_curr ] "m"(this->kvpair.key),
          [ val_curr ] "rm"(this->kvpair.value)
        : "rbx", "r12", "r13", "r14", "r15", "cc", "memory");
    return found;
  };

  inline uint64_t find_key_brless(const void *data, uint64_t *retry) {
    Item *item = const_cast<Item *>(reinterpret_cast<const Item *>(data));

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
        : [ value_out ] "=m"(item->kvpair.value), [ retry ] "=m"(*retry),
          [ found ] "=r"(found)
        : [ key_in ] "r"(item->kvpair.key), [ key_curr ] "m"(this->kvpair.key),
          [ val_curr ] "rm"(this->kvpair.value)
        : "rbx", "r12", "r13", "r14", "r15", "cc", "memory");
    return found;
  };
} PACKED;

}  // namespace kmercounter

#endif  // __KV_TYPES_HPP__
