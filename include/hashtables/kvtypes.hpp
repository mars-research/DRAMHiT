#ifndef __KV_TYPES_HPP__
#define __KV_TYPES_HPP__

#include "types.hpp"

namespace kmercounter {

struct Kmer_base {
  Kmer_s kmer;
  uint16_t count : 15;
  uint8_t occupied : 1;
} PACKED;

struct Kmer_base_cas {
  Kmer_s kmer;
  uint8_t count;
  bool occupied;
} PACKED;

using Kmer_base_t = struct Kmer_base;
using Kmer_base_cas_t = struct Kmer_base_cas;

struct Kmer_KV_cas {
  Kmer_base_cas_t kb;        // 20 + 2 bytes
  uint64_t kmer_hash;        // 8 bytes
  volatile char padding[2];  // 2 bytes

  friend std::ostream &operator<<(std::ostream &strm, const Kmer_KV_cas &k) {
    return strm << std::string(k.kb.kmer.data, KMER_DATA_LENGTH) << " : "
                << k.kb.count;
  }
} PACKED;

struct Kmer_KV {
  Kmer_base_t kb;            // 20 + 2 bytes
  uint64_t kmer_hash;        // 8 bytes
  volatile char padding[2];  // 2 bytes

  friend std::ostream &operator<<(std::ostream &strm, const Kmer_KV &k) {
    return strm << std::string(k.kb.kmer.data, KMER_DATA_LENGTH) << " : "
                << k.kb.count;
  }

  inline bool is_occupied() const { return kb.occupied; }

  inline uint16_t count() const { return kb.count; }

  inline void set_count(uint16_t count) { kb.count = count; }

  inline void set_occupied() { kb.occupied = true; }

  inline void *data() { return this->kb.kmer.data; }

  inline constexpr size_t data_length() const { return sizeof(this->kb.kmer); }
} PACKED;

static_assert(sizeof(Kmer_KV) % 32 == 0,
              "Sizeof Kmer_KV must be a multiple of 32");

// Kmer q in the hash hashtable
// Each q spills over a queue line for now, queue-align later
struct Kmer_queue {
  const void *kmer_p;
  uint32_t kmer_idx;  // TODO reduce size, TODO decided by hashtable size?
  uint8_t pad[4];
#ifdef COMPARE_HASH
  uint64_t kmer_hash;  // 8 bytes
#endif
} PACKED;

// TODO store org kmer idx, to check if we have wrappd around after reprobe
struct CAS_Kmer_queue_r {
  const void *kmer_data_ptr;
  uint32_t kmer_idx;  // TODO reduce size, TODO decided by hashtable size?
  uint8_t pad[4];
#ifdef COMPARE_HASH
  uint64_t kmer_hash;  // 8 bytes
#endif
} PACKED;

struct KVPair {
  char key[KEY_SIZE];
  char value[VALUE_SIZE];
} PACKED;

struct Item {
  bool occupied;
  KVPair kvpair;

  friend std::ostream &operator<<(std::ostream &strm, const Item &item) {
    return strm << std::string(item.kvpair.key, KEY_SIZE) << " : "
                << std::string(item.kvpair.value, VALUE_SIZE);
  }

  inline bool is_occupied() const { return occupied; }

  inline uint16_t count() const { return 0; }

  inline void set_count(uint16_t count) {}

  inline constexpr size_t data_length() const { return sizeof(KVPair); }

  inline void *data() { return &this->kvpair; }

  inline void set_occupied() { occupied = true; }
} PACKED;

struct ItemQueue {
  void *data_ptr;
  uint32_t idx;
#ifdef COMPARE_HASH
  uint64_t key_hash;  // 8 bytes
#endif
} PACKED;

}  // namespace kmercounter
#endif  // __KV_TYPES_HPP__