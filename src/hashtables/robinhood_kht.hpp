#ifndef _ROBINHOOD_SKHT_H
#define _ROBINHOOD_SKHT_H

#include "base_kht.hpp"
#include "city/city.h"
#include "data_types.h"
// #include "kmer_struct.h"


/*
Kmer cache_record in the hash hashtable
Each cache_record spills over a queue line for now, queue-align later
*/

// 2^21

typedef struct
{
  char kmer_data[KMER_DATA_LENGTH];  // 50 bytes
  uint16_t kmer_count;  // 2 bytes // TODO seems too long, max count is ~14
  bool is_occupied;     // 1 byte
  uint32_t original_bucket_idx;         // 4 bytes
} __attribute__((packed)) __RH_Kmer_r;  // 57 bytes

typedef struct
{
  __RH_Kmer_r kmer;  // 57 bytes
  char padding[7];   // 7 bytes
} __attribute__((packed)) RH_Kmer_r;

typedef struct
{
  __RH_Kmer_r kmer;            // 57 bytes
  uint32_t insert_bucket_idx;  // 4 bytes
  char padding[3];
} __attribute__((packed)) RH_Kmer_queue_r;

std::ostream &operator<<(std::ostream &strm, const __RH_Kmer_r &k)
{
  return strm << std::string(k.kmer_data, KMER_DATA_LENGTH) << " : "
              << k.kmer_count;
}

class RobinhoodKmerHashTable : public KmerHashTable
{
 private:
  uint64_t capacity;
  RH_Kmer_r empty_kmer_r;  /* for comparison for empty slot */
  RH_Kmer_queue_r *queue;  // TODO prefetch this?
  uint32_t queue_idx;      // pointer to head of queue

  uint64_t __hash(const void *k)
  {
#if defined(CITY_HASH)  
    uint64_t cityhash = CityHash64((const char *)k, KMER_DATA_LENGTH);
    /* n % d => n & (d - 1) */
    return cityhash;  // modulo
#endif
    return 0;
  }

  /* Insert items from queue into hash table, interpreting "queue"
  as an array of size queue_sz*/
  void __insert_from_queue(size_t queue_sz)
  {
    this->queue_idx = 0;  // start again
    for (size_t i = 0; i < queue_sz; i++)
    {
      __insert(&queue[i]);
    }
  }

  // TODO inline
  uint32_t __distance_to_bucket(uint32_t original_bucket_idx,
                                uint32_t probe_bucket_idx)
  {
    // modulo
    return (probe_bucket_idx - original_bucket_idx) & (this->capacity - 1);
  }

  /* Insert using prefetch: using a dynamic prefetch queue.
          If bucket is is_occupied, add to queue again to reprobe.
  */
  // TODO inline
  bool __swap(__RH_Kmer_r *table_kmer, __RH_Kmer_r *queue_kmer, uint32_t idx)
  {
    __RH_Kmer_r temp = *table_kmer;
    *table_kmer = *queue_kmer;
    queue[this->queue_idx].kmer = temp;

    uint32_t next_bucket_idx_to_prefetch =
        (idx + 1) & (this->capacity - 1);  // modulo
    queue[this->queue_idx].insert_bucket_idx = next_bucket_idx_to_prefetch;
    __builtin_prefetch(&hashtable[next_bucket_idx_to_prefetch], 1, 3);
    this->queue_idx++;

    return true;
  }

  void __insert(RH_Kmer_queue_r *cache_record)
  {
    uint32_t i = cache_record->insert_bucket_idx;

    // insert in empty bucket
    if (!hashtable[i].kmer.is_occupied)
    {
      hashtable[i].kmer = cache_record->kmer;
      return;
    }

    if (memcmp(&hashtable[i].kmer.kmer_data, cache_record->kmer.kmer_data,
               KMER_DATA_LENGTH) == 0)
    {
      hashtable[i].kmer.kmer_count++;
      return;
    }

    if (__distance_to_bucket(hashtable[i].kmer.original_bucket_idx, i) <
        __distance_to_bucket(cache_record->kmer.original_bucket_idx, i))
    {
      __swap(&hashtable[i].kmer, &cache_record->kmer, i);
#ifdef CALC_STATS
      this->num_swaps++;
#endif
      return;
    }

    {
      cache_record->insert_bucket_idx = (i + 1) & (this->capacity - 1);
      __builtin_prefetch(&hashtable[cache_record->insert_bucket_idx], 1, 3);
      queue[this->queue_idx] = *cache_record;
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

  RH_Kmer_r *hashtable;

  RobinhoodKmerHashTable(uint64_t c)
  {
    // TODO static cast
    // TODO power of 2 hashtable size for ease of mod operations
    this->capacity = this->__upper_power_of_two(c);
    this->hashtable =
        (RH_Kmer_r *)(aligned_alloc(__PAGE_SIZE, capacity * sizeof(RH_Kmer_r)));
    memset(hashtable, 0, capacity * sizeof(RH_Kmer_r));
    memset(&this->empty_kmer_r, 0, sizeof(RH_Kmer_r));

    this->queue = (RH_Kmer_queue_r *)(aligned_alloc(
        __PAGE_SIZE, PREFETCH_QUEUE_SIZE * sizeof(RH_Kmer_queue_r)));
    this->queue_idx = 0;
    __builtin_prefetch(queue, 1, 3);
  }

  ~RobinhoodKmerHashTable()
  {
    free(hashtable);
    free(queue);
  }

  /* insert and increment if exists */
  bool insert(const void *kmer_data)
  {
    uint64_t hash_new =
        __hash((const char *)kmer_data);
    size_t __kmer_idx = hash_new & (this->capacity - 1);  // modulo

    __builtin_prefetch(&hashtable[__kmer_idx], 1, 3);
    // printf("inserting into queue at %u\n", this->queue_idx);
    memcpy(&queue[this->queue_idx].kmer.kmer_data, kmer_data, KMER_DATA_LENGTH);
    queue[this->queue_idx].kmer.kmer_count = 1;
    queue[this->queue_idx].kmer.is_occupied = true;
    queue[this->queue_idx].kmer.original_bucket_idx = __kmer_idx;
    queue[this->queue_idx].insert_bucket_idx = __kmer_idx;
    this->queue_idx++;

    while (this->queue_idx >= PREFETCH_QUEUE_SIZE)
    {
      this->__insert_from_queue(PREFETCH_QUEUE_SIZE);
    }

    return true;
  }

  void flush_queue()
  {
    size_t curr_queue_sz = this->queue_idx;
    while (curr_queue_sz != 0)
    {
      __insert_from_queue(curr_queue_sz);
      curr_queue_sz = this->queue_idx;
    }
  }

  __RH_Kmer_r *find(const void *kmer_data)
  {
#ifdef CALC_STATS
    uint64_t distance_from_bucket = 0;
#endif
    uint64_t cityhash_new =
        CityHash64((const char *)kmer_data, KMER_DATA_LENGTH);

    size_t idx = cityhash_new & (this->capacity - 1);  // modulo

    int memcmp_res =
        memcmp(&hashtable[idx].kmer.kmer_data, kmer_data, KMER_DATA_LENGTH);

    while (memcmp_res != 0)
    {
      idx++;
      idx = idx & (this->capacity - 1);
      memcmp_res =
          memcmp(&hashtable[idx].kmer.kmer_data, kmer_data, KMER_DATA_LENGTH);
#ifdef CALC_STATS
      distance_from_bucket++;
#endif
    }
#ifdef CALC_STATS
    if (distance_from_bucket > this->max_distance_from_bucket)
    {
      this->max_distance_from_bucket = distance_from_bucket;
    }
    this->sum_distance_from_bucket += distance_from_bucket;
#endif
    return &hashtable[idx].kmer;
  }

  void display()
  {
    for (size_t i = 0; i < this->capacity; i++)
    {
      if (hashtable[i].kmer.is_occupied)
      {
        for (size_t k = 0; k < KMER_DATA_LENGTH; k++)
        {
          printf("%c", hashtable[i].kmer.kmer_data[k]);
        }
        printf(": %u\n", hashtable[i].kmer.kmer_count);
      }
    }
  }

  size_t get_fill()
  {
    size_t count = 0;
    for (size_t i = 0; i < this->capacity; i++)
    {
      if (hashtable[i].kmer.is_occupied)
      {
        count++;
      }
    }
    return count;
  }

  size_t get_capacity() { return this->capacity; }

  size_t get_max_count()
  {
    size_t count = 0;
    for (size_t i = 0; i < this->capacity; i++)
    {
      if (hashtable[i].kmer.kmer_count > count)
      {
        count = hashtable[i].kmer.kmer_count;
      }
    }
    return count;
  }

  void print_to_file(std::string outfile)
  {
    std::ofstream f;
    f.open(outfile);
    for (size_t i = 0; i < this->get_capacity(); i++)
    {
      if (this->hashtable[i].kmer.kmer_count > 0)
      {
        f << this->hashtable[i].kmer << std::endl;
      }
    }
  }
};

// TODO bloom filters for high frequency kmers?

#endif /* _ROBINHOOD_SKHT_H */
