#ifndef _BASE_KHT_H
#define _BASE_KHT_H

#include <stdint.h>

#include <string>

#include "types.hpp"

using namespace std;
namespace kmercounter {

const uint32_t PREFETCH_QUEUE_SIZE = 64 * 4;
const uint32_t PREFETCH_FIND_QUEUE_SIZE = 64 * 4;

// #define HT_TESTS_BATCH_LENGTH 32
#define HT_TESTS_BATCH_LENGTH 128
#define HT_TESTS_FIND_BATCH_LENGTH 64

class BaseHashTable {
 public:
  // Upsert (Insert and Update)
  virtual bool insert(const void *data) = 0;

  virtual void insert_noprefetch(void *data) = 0;

  virtual void insert_batch(KeyPairs &kp) = 0;

  virtual void *find(const void *data) = 0;

  virtual uint8_t find_batch(uint64_t *keys, uint32_t batch_len) = 0;

  virtual void find_batch_v2(KeyPairs &kp, ValuePairs &vp) = 0;

  virtual void flush_queue() = 0;

  virtual uint8_t flush_find_queue() = 0;

  virtual void flush_find_queue_v2(ValuePairs &vp) = 0;

  virtual void display() const = 0;

  virtual size_t get_fill() const = 0;

  virtual size_t get_capacity() const = 0;

  virtual size_t get_max_count() const = 0;

  virtual void print_to_file(std::string &outfile) const = 0;

  virtual uint64_t read_hashtable_element(const void *data) = 0;

  virtual ~BaseHashTable() {}
#ifdef CALC_STATS
  uint64_t num_reprobes = 0;
  uint64_t num_soft_reprobes = 0;
  uint64_t num_memcmps = 0;
  uint64_t num_memcpys = 0;
  uint64_t num_hashcmps = 0;
  uint64_t num_queue_flushes = 0;
  uint64_t sum_distance_from_bucket = 0;
  uint64_t max_distance_from_bucket = 0;
  uint64_t num_swaps = 0;
#endif
};

}  // namespace kmercounter
#endif  // _BASE_KHT_H
