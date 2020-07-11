#ifndef _BASE_KHT_H
#define _BASE_KHT_H

#include <stdint.h>
#include <string>

using namespace std;
namespace kmercounter {

const uint32_t PREFETCH_QUEUE_SIZE = 64;

class KmerHashTable {
 public:
  // Upsert (Insert and Update)
  virtual bool insert(const void *kmer_data) = 0;

  virtual void flush_queue() = 0;

  virtual void display() const = 0;

  virtual size_t get_fill() const = 0;

  virtual size_t get_capacity() const = 0;

  virtual size_t get_max_count() const = 0;

  virtual void print_to_file(std::string &outfile) const = 0;

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
