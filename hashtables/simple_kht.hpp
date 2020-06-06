#ifndef _SKHT_H
#define _SKHT_H

#include "../include/base_kht.hpp"
#include "../city/city.h"
#include "../include/data_types.h"
// #include "kmer_struct.h"

// 2^21
typedef struct {
  char kmer_data[KMER_DATA_LENGTH];  // 50 bytes
  uint16_t kmer_count;     // 2 bytes // TODO seems too long, max count is ~14
  bool occupied;           // 1 bytes
  uint64_t kmer_cityhash;  // 8 bytes
  char padding[3];         // 3 bytes // TODO remove hardcode
} __attribute__((packed)) Kmer_r;
// TODO use char and bit manipulation instead of bit fields in Kmer_r:
// https://stackoverflow.com/questions/1283221/algorithm-for-copying-n-bits-at-arbitrary-position-from-one-int-to-another
// TODO how long should be the count variable?
// TODO should we pack the struct?

// TODO store org kmer idx, to check if we have wrappd around after reprobe

/*
Kmer q in the hash hashtable
Each q spills over a queue line for now, queue-align later
*/

typedef struct {
  const void *kmer_data_ptr;
  uint32_t kmer_idx;       // TODO reduce size, TODO decided by hashtable size?
  uint64_t kmer_cityhash;  // 8 bytes
} __attribute__((packed)) Kmer_queue_r;

std::ostream &operator<<(std::ostream &strm, const Kmer_r &k)
{
  return strm << std::string(k.kmer_data, KMER_DATA_LENGTH) << " : "
              << k.kmer_count;
}

#define CACHE_BLOCK_BITS 6
#define CACHE_BLOCK_SIZE (1U << CACHE_BLOCK_BITS)  /* 64 */
#define CACHE_BLOCK_MASK (CACHE_BLOCK_SIZE - 1)    /* 63, 0x3F */

/* Which byte offset in its cache block does this address reference? */
#define CACHE_BLOCK_OFFSET(ADDR) ((ADDR) & CACHE_BLOCK_MASK)

/* Address of 64 byte block brought into the cache when ADDR accessed */
#define CACHE_BLOCK_ALIGNED_ADDR(ADDR) ((ADDR) & ~CACHE_BLOCK_MASK)

static inline void prefetch_object(const void *addr, uint64_t size) {
  uint64_t cache_line1_addr = CACHE_BLOCK_ALIGNED_ADDR((uint64_t)addr);
  uint64_t cache_line2_addr = CACHE_BLOCK_ALIGNED_ADDR((uint64_t)addr + size - 1);

  // 1 -- prefetch for write (vs 0 -- read)
  // 0 -- data has no temporal locality (3 -- high temporal locality)
  //__builtin_prefetch((const void*)cache_line1_addr, 1, 1);

 // __builtin_prefetch((const void*)cache_line1_addr, 1, 0);
 // if (cache_line1_addr != cache_line2_addr)
 //   __builtin_prefetch((const void*)cache_line2_addr, 1, 0);
}

class SimpleKmerHashTable : public KmerHashTable
{
 
  public:
  void touch(uint64_t i) {
    hashtable[i & (this->capacity - 1)].occupied = 1;
  };

 private:
  uint64_t capacity;
  Kmer_r empty_kmer_r;  /* for comparison for empty slot */
  Kmer_queue_r *queue;  // TODO prefetch this?
  uint32_t queue_idx;

  size_t __hash(const void *k)
  {
    uint64_t cityhash = CityHash64((const char *)k, KMER_DATA_LENGTH);
    /* n % d => n & (d - 1) */
    return (cityhash & (this->capacity - 1));  // modulo
  }

  void __insert_into_queue(const void *kmer_data)
  {
    uint64_t cityhash_new =
        CityHash64((const char *)kmer_data, KMER_DATA_LENGTH);
    size_t __kmer_idx = cityhash_new & (this->capacity - 1);  // modulo
    // size_t __kmer_idx = cityhash_new % (this->capacity);

    /* prefetch buckets and store kmer_data pointers in queue */
    // TODO how much to prefetch?
    // TODO if we do prefetch: what to return? API breaks

    prefetch_object(&hashtable[__kmer_idx], sizeof(hashtable[__kmer_idx]));

    // printf("inserting into queue at %u\n", this->queue_idx);
    queue[this->queue_idx].kmer_data_ptr = kmer_data;
    queue[this->queue_idx].kmer_idx = __kmer_idx;
    queue[this->queue_idx].kmer_cityhash = cityhash_new;
    this->queue_idx++;
  }

  /* Insert items from queue into hash table, interpreting "queue"
  as an array of size queue_sz*/
  void __insert_from_queue(size_t queue_sz)
  {
    this->queue_idx = 0;  // start again
    for (size_t i = 0; i < queue_sz; i++) {
      __insert(&queue[i]);
    }
  }

    /* Insert using prefetch: using a dynamic prefetch queue.
          If bucket is occupied, add to queue again to reprobe.
  */
  void __insert(Kmer_queue_r *q)
  {
    /* hashtable location at which data is to be inserted */
    size_t pidx = q->kmer_idx;

    /* Compare with empty kmer to check if bucket is empty, and insert.*/
    if (!hashtable[pidx].occupied) {
#ifdef CALC_STATS
      this->num_memcpys++;
#endif
      memcpy(&hashtable[pidx].kmer_data, q->kmer_data_ptr, KMER_DATA_LENGTH);
      hashtable[pidx].kmer_count++;
      hashtable[pidx].occupied = true;
      hashtable[pidx].kmer_cityhash = q->kmer_cityhash;
      return;
    }

#ifdef CALC_STATS
    this->num_hashcmps++;
#endif

    if (hashtable[pidx].kmer_cityhash == q->kmer_cityhash) {
#ifdef CALC_STATS
      this->num_memcmps++;
#endif

      if (memcmp(&hashtable[pidx].kmer_data, q->kmer_data_ptr,
                 KMER_DATA_LENGTH) == 0) {
        hashtable[pidx].kmer_count++;
        return;
      }
    }

    {
      /* insert back into queue, and prefetch next bucket.
      next bucket will be probed in the next run
      */
      pidx++;
      pidx = pidx & (this->capacity - 1);  // modulo
      //__builtin_prefetch(&hashtable[pidx], 1, 3);
      prefetch_object(&hashtable[pidx], sizeof(hashtable[pidx]));
      q->kmer_idx = pidx;

      queue[this->queue_idx] = *q;
      // queue[this->queue_idx].kmer_data_ptr = q->kmer_data_ptr;
      // queue[this->queue_idx].kmer_idx = q->kmer_idx;
      this->queue_idx++;

#ifdef CALC_STATS
      this->num_reprobes++;
#endif
      return;
    }
  }

  uint64_t __upper_power_of_two(uint64_t v)
  {
    v--;
    v |= v >> 1;
    v |= v >> 2;
    v |= v >> 4;
    v |= v >> 8;
    v |= v >> 16;
    v |= v >> 32;
    v++;
    return v;
  }

 public:

  Kmer_r *hashtable;

  SimpleKmerHashTable(uint64_t c)
  {
    // TODO static cast
    // TODO power of 2 hashtable size for ease of mod operations
    this->capacity = this->__upper_power_of_two(c);
    // printf("[INFO] Hashtable size: %lu\n", this->capacity);
    this->hashtable =
        (Kmer_r *)aligned_alloc(__PAGE_SIZE, capacity * sizeof(Kmer_r));
    if (this->hashtable == NULL) {
      perror("[ERROR]: SimpleKmerHashTable aligned_alloc");
    }
    if (memset(hashtable, 0, capacity * sizeof(Kmer_r)) < 0){
      perror("[ERROR]: SimpleKmerHashTable memset");
    }
    if (memset(&this->empty_kmer_r, 0, sizeof(Kmer_r)) < 0){
      perror("[ERROR]: SimpleKmerHashTable");
    }

    this->queue = (Kmer_queue_r *)(aligned_alloc(
        __PAGE_SIZE, PREFETCH_QUEUE_SIZE * sizeof(Kmer_queue_r)));
    this->queue_idx = 0;
    __builtin_prefetch(queue, 1, 3);
  }

  ~SimpleKmerHashTable()
  {
    free(hashtable);
    free(queue);
  }

  /* insert and increment if exists */
  bool insert(const void *kmer_data)
  {
    __insert_into_queue(kmer_data);

    /* if queue is full, actually insert */
    // now queue_idx = 20
    while (this->queue_idx >= PREFETCH_QUEUE_SIZE) {
      this->__insert_from_queue(PREFETCH_QUEUE_SIZE);
    }

    /* if queue is still full, empty it. This is especially needed
    if queue size is small (< 20?) */
    // if (this->queue_idx == PREFETCH_QUEUE_SIZE)
    // {
    // 	this->flush_queue();
    // }
    return true;
  }

  void flush_queue()
  {
    size_t curr_queue_sz = this->queue_idx;
    while (curr_queue_sz != 0) {
      __insert_from_queue(curr_queue_sz);
      curr_queue_sz = this->queue_idx;
    }
#ifdef CALC_STATS
    this->num_queue_flushes++;
#endif
  }

  Kmer_r *find(const void *kmer_data)
  {
#ifdef CALC_STATS
    uint64_t distance_from_bucket = 0;
#endif
    uint64_t cityhash_new =
        CityHash64((const char *)kmer_data, KMER_DATA_LENGTH);

    size_t idx = cityhash_new & (this->capacity - 1);  // modulo

    int memcmp_res =
        memcmp(&hashtable[idx].kmer_data, kmer_data, KMER_DATA_LENGTH);

    while (memcmp_res != 0) {
      idx++;
      idx = idx & (this->capacity - 1);
      memcmp_res =
          memcmp(&hashtable[idx].kmer_data, kmer_data, KMER_DATA_LENGTH);
#ifdef CALC_STATS
      distance_from_bucket++;
#endif
    }

#ifdef CALC_STATS
    if (distance_from_bucket > this->max_distance_from_bucket) {
      this->max_distance_from_bucket = distance_from_bucket;
    }
    this->sum_distance_from_bucket += distance_from_bucket;
#endif
    return &hashtable[idx];
  }

  void display()
  {
    for (size_t i = 0; i < this->capacity; i++) {
      if (hashtable[i].occupied) {
        for (size_t k = 0; k < KMER_DATA_LENGTH; k++) {
          printf("%c", hashtable[i].kmer_data[k]);
        }
        printf(": %u\n", hashtable[i].kmer_count);
      }
    }
  }

  size_t get_fill()
  {
    size_t count = 0;
    for (size_t i = 0; i < this->capacity; i++) {
      if (hashtable[i].occupied) {
        count++;
      }
    }
    return count;
  }

  size_t get_capacity() { return this->capacity; }

  size_t get_max_count()
  {
    size_t count = 0;
    for (size_t i = 0; i < this->capacity; i++) {
      if (hashtable[i].kmer_count > count) {
        count = hashtable[i].kmer_count;
      }
    }
    return count;
  }

  void print_to_file(std::string outfile)
  {
    std::ofstream f;
    f.open(outfile);
    for (size_t i = 0; i < this->get_capacity(); i++) {
      if (this->hashtable[i].kmer_count > 0) {
        f << this->hashtable[i] << std::endl;
      }
    }
  }
};

// TODO bloom filters for high frequency kmers?

#endif /* _SKHT_H_ */
