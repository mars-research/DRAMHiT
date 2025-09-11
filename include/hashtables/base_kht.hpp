#ifndef HASHTABLES_BASE_KHT_HPP
#define HASHTABLES_BASE_KHT_HPP

#include <stdint.h>

#include <string>

#include "Latency.hpp"
#include "types.hpp"

using namespace std;
namespace kmercounter {
class BaseHashTable {
 public:
  virtual bool insert(const void *data) = 0;

  // NEVER NEVER NEVER USE KEY OR ID 0
  // Your inserts will be ignored if you do (we use these as empty markers)
  virtual void insert_batch(const InsertFindArguments &kp, collector_type* collector = nullptr) = 0;

  virtual void insert_noprefetch(const void *data, collector_type* collector = nullptr) = 0;

  virtual void flush_insert_queue(collector_type* collector = nullptr) = 0;

  // NEVER NEVER NEVER USE KEY OR ID 0
  // Your inserts will be ignored if you do (we use these as empty markers)
  virtual void find_batch(const InsertFindArguments &kp, ValuePairs &vp, collector_type* collector = nullptr) = 0;

  virtual void *find_noprefetch(const void *data, collector_type* collector = nullptr) = 0;

  virtual size_t flush_find_queue(ValuePairs &vp, collector_type* collector = nullptr) = 0;

  virtual void display() const = 0;

  virtual size_t get_fill() const = 0;

  virtual size_t get_capacity() const = 0;

  virtual size_t get_max_count() const = 0;

  virtual void print_to_file(std::string &outfile) const = 0;

  virtual uint64_t read_hashtable_element(const void *data) = 0;

  virtual void prefetch_queue(QueueType qtype) = 0;

  virtual void clear()  
  {
    
  }

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

}  // namespace kmercounter
#endif  // HASHTABLES_BASE_KHT_HPP
