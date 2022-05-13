#ifndef _KMER_CLASS_H_
#define _KMER_CLASS_H_

#include <cstring>

#include "city/city.h"
#include "types.hpp"

namespace kmercounter {

constexpr int alignment = 64;

class Kmer {
 public:
  Kmer() {}

  Kmer(const base_4bit_t *data, unsigned len) : kmer_len(len) {
    allocmem(len);
    memcpy(_data, data, kmer_len);
    _hash = CityHash128((const char *)data, len);
  }

  inline const uint64_t hash() const { return _hash.first; }

  Kmer(const Kmer &obj) : _hash(obj._hash), kmer_len(obj.kmer_len) {
    allocmem(kmer_len);
    memcpy(_data, obj._data, kmer_len);
  }

  void allocmem(unsigned len) {
    _data = (base_4bit_t *)std::aligned_malloc(alignment, len);
  }

  void freemem(void) { free(_data); }

  Kmer(Kmer &&obj)
      : _hash(obj._hash), kmer_len(obj.kmer_len), _data(obj._data) {
    obj._data = nullptr;
  }

  ~Kmer() {
    if (_data != nullptr) {
      freemem();
      _data = nullptr;
    }
  }

  inline bool operator==(const Kmer &x) const { return x._hash == _hash; }
  const uint128 full_hash() const { return _hash; }

 private:
  base_4bit_t *_data;
  uint128 _hash;
  uint8_t kmer_len;
};

// hash and compare function - using cityhash
struct Kmer_hash_compare {
  inline size_t hash(const Kmer &k) { return k.hash(); }
  //! True if strings are equal
  inline bool equal(const Kmer &x, const Kmer &y) const {
    return x.hash() == y.hash();
  }
};

struct Kmer_hash {
  //! True if strings are equal
  inline size_t operator()(const Kmer &k) const { return k.hash(); }
  typedef ska::power_of_two_hash_policy hash_policy;
};

struct Kmer_str_hash {
  inline size_t operator()(const std::string &s) const {
    return CityHash128((const char *)s.data(), s.size()).first;
  }
  typedef ska::power_of_two_hash_policy hash_policy;
};

struct Kmer_equal {
  //! True if strings are equal
  inline bool operator()(const Kmer &x, const Kmer &y) const {
    return x.hash() == y.hash();
  }
};

struct Kmer_str_equal {
  //! True if strings are equal
  inline bool operator()(const std::string &s1, const std::string &s2) const {
    return s1 == s2;
  }
};

size_t hash_to_cpu(Kmer &k, uint32_t threadIdx, uint32_t numCons) {
  uint32_t queueNo = ((k.hash() * 11400714819323198485llu) >> 58) % numCons;
  // send_to_queue(queueNo, threadIdx, k);
}

}  // namespace kvstore
#endif /* _KMER_H_ */
