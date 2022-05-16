#ifndef __PREFETCH_TEST_HPP__
#define __PREFETCH_TEST_HPP__

#include <plog/Log.h>

#include "hashtables/simple_kht.hpp"
#include "types.hpp"

namespace kmercounter {

struct Prefetch_KV {
  Kmer_base kb;        // 20 + 2 bytes
  uint32_t kmer_hash;  // 4 bytes (4B enties is enough)
  volatile char padding[6];
  uint8_t _pad[32];

  inline void *data() { return this->kb.kmer.data; }

  inline void *key() { return this->kb.kmer.data; }

  inline void *value() { return NULL; }

  inline constexpr size_t data_length() const { return sizeof(this->kb.kmer); }

  inline constexpr size_t key_length() const { return sizeof(this->kb.kmer); }

  inline constexpr size_t value_length() const { return sizeof(this->kb); }

  inline void insert_item(const void *from, size_t len) {
    const char *kmer_data = reinterpret_cast<const char *>(from);
    memcpy(this->kb.kmer.data, kmer_data, this->key_length());
    this->kb.count += 1;
  }

  inline bool insert_regular_v2(const void *data) {
    PLOG_FATAL << "Not implemented";
    assert(false);
    return false;
  }

  inline uint16_t insert_or_update_v2(const void *data) {
    PLOG_FATAL << "Not implemented";
    assert(false);
    return -1;
  }

  inline bool compare_key(const void *from) {
    const char *kmer_data = reinterpret_cast<const char *>(from);
    return !memcmp(this->kb.kmer.data, kmer_data, this->key_length());
  }

  inline void update_value(const void *from, size_t len) {
    this->kb.count += 1;
  }

  inline void set_value(Prefetch_KV *from) { this->kb.count = from->kb.count; }

  inline void update_brless(uint8_t cmp) {}

  inline uint64_t find_key_brless(const void *data, uint64_t *ret) {
    PLOG_FATAL << "Not implemented";
    assert(false);
    return -1;
  }

  inline uint64_t find_key_brless_v2(const void *data, uint64_t *retry,
                                     ValuePairs &vp) {
    PLOG_FATAL << "Not implemented";
    assert(false);
    return -1;
  }

  inline uint64_t find_key_regular_v2(const void *data, uint64_t *retry,
                                      ValuePairs &vp) {
    PLOG_FATAL << "Not implemented";
    assert(false);
    return -1;
  }

  inline Prefetch_KV get_empty_key() {
    Prefetch_KV empty;
    memset(empty.kb.kmer.data, 0, sizeof(empty.kb.kmer.data));
    return empty;
  }

  inline bool is_empty() {
    Prefetch_KV empty = this->get_empty_key();
    return !memcmp(this->key(), empty.key(), this->key_length());
  }

  inline uint16_t get_value() const { return this->kb.count; }

  inline uint16_t insert_or_update(const void *data) { return 0xFF; }
} PACKED;

struct PrefetchKV_Queue {
  const void *data;
  uint32_t idx;
  uint64_t key;
  uint64_t key_id;
  uint8_t pad[4];
#ifdef COMPARE_HASH
  uint64_t key_hash;  // 8 bytes
#endif
};

static_assert(sizeof(Prefetch_KV) == CACHE_LINE_SIZE,
              "Sizeof Prefetch_KV should be equal to CACHE_LINE_SIZE(64)");

inline std::ostream &operator<<(std::ostream &strm, const Prefetch_KV &k) {
  return strm << std::string(k.kb.kmer.data, KMER_DATA_LENGTH) << " : "
              << k.kb.count;
}

class PrefetchTest {
 public:
  void prefetch_test_run_exec(Shard *sh, Configuration &cfg, BaseHashTable *);
  uint64_t prefetch_test_run(
      PartitionedHashStore<Prefetch_KV, PrefetchKV_Queue> *ktable);
};

}  // namespace kmercounter

#endif  // __PREFETCH_TEST_HPP__
