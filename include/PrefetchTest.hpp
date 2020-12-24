#ifndef __PREFETCH_TEST_HPP__
#define __PREFETCH_TEST_HPP__

#include "hashtables/simple_kht.hpp"
#include "types.hpp"

namespace kmercounter {

struct Prefetch_KV {
  Kmer_base_t kb;      // 20 + 2 bytes
  uint32_t kmer_hash;  // 4 bytes (4B enties is enough)
  volatile char padding[6];
  uint8_t _pad[32];

  inline bool is_occupied() const { return kb.occupied; }

  inline uint16_t count() const { return kb.count; }

  inline void set_count(uint16_t count) { kb.count = count; }

  inline void set_occupied() { kb.occupied = true; }

  inline void *data() { return this->kb.kmer.data; }

  inline constexpr size_t data_length() const { return sizeof(this->kb.kmer); }
} PACKED;

struct PrefetchKV_Queue {};

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
