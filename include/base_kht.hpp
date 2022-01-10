#ifndef _BASE_KHT_H
#define _BASE_KHT_H

#include <stdint.h>

#include <string>

#include "Latency.hpp"
#include "types.hpp"

using namespace std;
namespace kvstore {

const uint32_t PREFETCH_QUEUE_SIZE = 64;
const uint32_t PREFETCH_FIND_QUEUE_SIZE = 64;

// #define HT_TESTS_BATCH_LENGTH 32
#define HT_TESTS_BATCH_LENGTH 16
#define HT_TESTS_FIND_BATCH_LENGTH 16

class BaseHashTable {
 public:
  virtual bool insert(const void *data) = 0;

  // NEVER NEVER NEVER USE KEY OR ID 0
  // Your inserts will be ignored if you do (we use these as empty markers)
  virtual void insert_batch(KeyPairs &kp) = 0;

  virtual void insert_noprefetch(const void *data) = 0;

  virtual void flush_insert_queue() = 0;

  // NEVER NEVER NEVER USE KEY OR ID 0
  // Your inserts will be ignored if you do (we use these as empty markers)
  virtual void find_batch(KeyPairs &kp, ValuePairs &vp) = 0;

#ifdef LATENCY_COLLECTION
  virtual void find_batch(KeyPairs &kp, ValuePairs &vp,
                          decltype(collectors)::value_type &collector) {
    PLOG_ERROR
        << "This hashtable did not implement instrumentation for find_batch";

    std::terminate();
  };
#endif

  virtual void *find_noprefetch(const void *data) = 0;

#ifdef LATENCY_COLLECTION
  virtual void *find_noprefetch(const void *data,
                               decltype(collectors)::value_type &collector) {
    PLOG_ERROR << "This hashtable did not implement instrumentation for "
                  "find_noprefetch";

    std::terminate();
  };
#endif

  virtual void flush_find_queue(ValuePairs &vp) = 0;

#ifdef LATENCY_COLLECTION
  virtual void flush_find_queue(ValuePairs &vp,
                                decltype(collectors)::value_type &collector) {
    PLOG_ERROR << "This hashtable did not implement instrumentation for "
                  "flush_find_queue";

    std::terminate();
  };
#endif

  virtual void display() const = 0;

  virtual size_t get_fill() const = 0;

  virtual size_t get_capacity() const = 0;

  virtual size_t get_max_count() const = 0;

  virtual void print_to_file(std::string &outfile) const = 0;

  virtual uint64_t read_hashtable_element(const void *data) = 0;

  virtual void prefetch_queue(QueueType qtype) = 0;

  virtual ~BaseHashTable() {}

  uint64_t num_reprobes = 0;
  uint64_t num_soft_reprobes = 0;
  uint64_t num_memcmps = 0;
  uint64_t num_memcpys = 0;
  uint64_t num_hashcmps = 0;
  uint64_t num_queue_flushes = 0;
  uint64_t sum_distance_from_bucket = 0;
  uint64_t max_distance_from_bucket = 0;
  uint64_t num_swaps = 0;
};

}  // namespace kvstore
#endif  // _BASE_KHT_H
