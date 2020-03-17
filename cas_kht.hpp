#ifndef _CAS_KHT_H
#define _CAS_KHT_H

#include <mutex>
#include "base_kht.hpp"
#include "city/city.h"
#include "data_types.h"
#include "kmer_struct.h"
#include "libfipc.h"

#define PREFETCH_QUEUE_SIZE 20

static uint64_t working_threads = 0;

typedef struct
{
  char kmer_data[KMER_DATA_LENGTH];  // 50 bytes
  uint16_t kmer_count;     // 2 bytes // TODO seems too long, max count is ~14
  bool occupied;           // 1 bytes
  uint64_t kmer_cityhash;  // 8 bytes
  char padding[3];         // 3 bytes // TODO remove hardcode
} __attribute__((packed)) CAS_Kmer_r;

// TODO store org kmer idx, to check if we have wrappd around after reprobe
typedef struct
{
  const void* kmer_data_ptr;
  uint32_t kmer_idx;       // TODO reduce size, TODO decided by hashtable size?
  uint64_t kmer_cityhash;  // 8 bytes
} __attribute__((packed)) CAS_Kmer_queue_r;

std::ostream& operator<<(std::ostream& strm, const CAS_Kmer_r& k)
{
  return strm << std::string(k.kmer_data, KMER_DATA_LENGTH) << " : "
              << k.kmer_count;
}

class CASKmerHashTable : public KmerHashTable
{
 private:
  uint64_t capacity;
  CAS_Kmer_r empty_kmer_r;  /* for comparison for empty slot */
  CAS_Kmer_queue_r* queue;  // TODO prefetch this?
  uint32_t queue_idx;
  std::mutex ht_init_mutex;

  size_t __hash(const void* k)
  {
    uint64_t cityhash = CityHash64((const char*)k, KMER_DATA_LENGTH);
    /* n % d => n & (d - 1) */
    return (cityhash & (this->capacity - 1));  // modulo
  }

  void __insert_into_queue(const void* kmer_data)
  {
    uint64_t cityhash_new =
        CityHash64((const char*)kmer_data, KMER_DATA_LENGTH);
    size_t __kmer_idx = cityhash_new & (this->capacity - 1);  // modulo
    // size_t __kmer_idx = cityhash_new % (this->capacity);

    /* prefetch buckets and store kmer_data pointers in queue */
    // TODO how much to prefetch?
    // TODO if we do prefetch: what to return? API breaks

    // __builtin_prefetch(&hashtable[__kmer_idx], 1, 3);
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
    for (size_t i = 0; i < queue_sz; i++)
    {
      __insert(&queue[i]);
    }
  }

  /* Insert using prefetch: using a dynamic prefetch queue.
          If bucket is occupied, add to queue again to reprobe.
  */
  void __reprobe(CAS_Kmer_queue_r* q, size_t curr_idx)
  {
    curr_idx++;
    curr_idx = curr_idx & (this->capacity - 1);  // modulo
    // __builtin_prefetch(&hashtable[curr_idx], 1, 3);
    q->kmer_idx = curr_idx;

    queue[this->queue_idx] = *q;
    // queue[this->queue_idx].kmer_data_ptr = q->kmer_data_ptr;
    // queue[this->queue_idx].kmer_idx = q->kmer_idx;
    this->queue_idx++;
#ifdef CALC_STATS
    this->num_reprobes++;
#endif
  }

  void __insert(CAS_Kmer_queue_r* q)
  {
    size_t pidx = q->kmer_idx; /* hashtable location at which data is to be
                                  inserted */

    /* Compare with empty kmer to check if bucket is empty, and insert. */
    // hashtable_mutexes[pidx].lock();
    // printf("Thread %lu, grabbing lock: %lu\n", this->thread_id, pidx);

    if (!hashtable[pidx].occupied)
    {
      bool cas_res = fipc_test_CAS(&hashtable[pidx].occupied, false, true);
      if (!cas_res)
      {
        __reprobe(q, pidx);
        return;
      }
#ifdef CALC_STATS
      this->num_memcpys++;
#endif

      memcpy(&hashtable[pidx].kmer_data, q->kmer_data_ptr, KMER_DATA_LENGTH);
      hashtable[pidx].kmer_count++;
      // hashtable[pidx].occupied = true;
      hashtable[pidx].kmer_cityhash = q->kmer_cityhash;
      // hashtable_mutexes[pidx].unlock();
      // printf("Thread %lu, released lock: %lu\n", this->thread_id,
      // pidx);
      return;
    }

#ifdef CALC_STATS
    this->num_hashcmps++;
#endif

    if (hashtable[pidx].kmer_cityhash == q->kmer_cityhash)
    {
#ifdef CALC_STATS
      this->num_memcmps++;
#endif

      if (memcmp(&hashtable[pidx].kmer_data, q->kmer_data_ptr,
                 KMER_DATA_LENGTH) == 0)
      {
        bool cas_res = false;
        uint32_t ocount;
        while (cas_res == false)
        {
          ocount = hashtable[pidx].kmer_count;
          cas_res =
              fipc_test_CAS(&hashtable[pidx].kmer_count, ocount, ocount + 1);
        }

        // hashtable[pidx].kmer_count++;
        // hashtable_mutexes[pidx].unlock();
        return;
      }
    }

    {
      /* insert back into queue, and prefetch next bucket.
      next bucket will be probed in the next run
      */
      // hashtable_mutexes[pidx].unlock();
      __reprobe(q, pidx);

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
#ifdef CALC_STATS
  uint64_t num_reprobes = 0;
  uint64_t num_memcmps = 0;
  uint64_t num_memcpys = 0;
  uint64_t num_hashcmps = 0;
  uint64_t num_queue_flushes = 0;
  uint64_t sum_distance_from_bucket = 0;
  uint64_t max_distance_from_bucket = 0;
#endif
  static CAS_Kmer_r* hashtable;
  // static std::vector<std::mutex> hashtable_mutexes;
  // uint32_t thread_id;

  CASKmerHashTable(uint64_t c)
  {
    // TODO static cast
    // TODO power of 2 hashtable size for ease of mod operations
    this->capacity = this->__upper_power_of_two(c);
    this->ht_init_mutex.lock();
    if (!hashtable)
    {
      this->hashtable = (CAS_Kmer_r*)(aligned_alloc(
          __PAGE_SIZE, capacity * sizeof(CAS_Kmer_r)));
      memset(hashtable, 0, capacity * sizeof(CAS_Kmer_r));
      memset(&this->empty_kmer_r, 0, sizeof(CAS_Kmer_r));
    }
    this->ht_init_mutex.unlock();

    this->queue = (CAS_Kmer_queue_r*)(aligned_alloc(
        __PAGE_SIZE, PREFETCH_QUEUE_SIZE * sizeof(CAS_Kmer_queue_r)));
    this->queue_idx = 0;
    // __builtin_prefetch(queue, 1, 3);
    fipc_test_FAI(working_threads);

    // this->thread_id = t;

    // std::vector<std::mutex> __ hashtable_mutexes (this->capacity);
    // hashtable_mutexes.swap(__// hashtable_mutexes);
  }

  ~CASKmerHashTable()
  {
    free(queue);
    fipc_test_FAD(working_threads);
    if (!working_threads)
    {
      printf("DESTROYED\n");
      free(hashtable);
    }
  }

  /* insert and increment if exists */
  bool insert(const void* kmer_data)
  {
    __insert_into_queue(kmer_data);

    /* if queue is full, actually insert */
    // now queue_idx = 20
    while (this->queue_idx >= PREFETCH_QUEUE_SIZE)
    {
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
    while (curr_queue_sz != 0)
    {
      __insert_from_queue(curr_queue_sz);
      curr_queue_sz = this->queue_idx;
    }
#ifdef CALC_STATS
    this->num_queue_flushes++;
#endif
  }

  // CAS_Kmer_r* find(const void * kmer_data)
  size_t find(const void* kmer_data)
  {
#ifdef CALC_STATS
    uint64_t distance_from_bucket = 0;
#endif
    uint64_t cityhash_new =
        CityHash64((const char*)kmer_data, KMER_DATA_LENGTH);

    size_t idx = cityhash_new & (this->capacity - 1);  // modulo

    // printf("Thread %lu: Trying memcmp at: %lu\n", this->thread_id, idx);
    int memcmp_res =
        memcmp(&hashtable[idx].kmer_data, kmer_data, KMER_DATA_LENGTH);

    while (memcmp_res != 0)
    {
      idx++;
      idx = idx & (this->capacity - 1);
      // printf("%d\n", idx);
      memcmp_res =
          memcmp(&hashtable[idx].kmer_data, kmer_data, KMER_DATA_LENGTH);
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
    return idx;
  }

  void display()
  {
    uint32_t max = 0;
    for (size_t i = 0; i < this->capacity; i++)
    {
      if (hashtable[i].occupied)
      {
        for (size_t k = 0; k < KMER_DATA_LENGTH; k++)
        {
          printf("%c", hashtable[i].kmer_data[k]);
        }
        printf(": %u\n", hashtable[i].kmer_count);
      }
    }
  }

  size_t get_fill()
  {
    size_t count = 0;
    for (size_t i = 0; i < this->capacity; i++)
    {
      if (hashtable[i].occupied)
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
      if (hashtable[i].kmer_count > count)
      {
        count = hashtable[i].kmer_count;
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
      if (this->hashtable[i].kmer_count > 0)
      {
        f << this->hashtable[i] << std::endl;
      }
    }
  }
};

CAS_Kmer_r* CASKmerHashTable::hashtable;
// std::vector<std::mutex> CASKmerHashTable:: hashtable_mutexes;

// TODO bloom filters for high frequency kmers?

#endif /* _CAS_KHT_H */
