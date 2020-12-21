#ifndef _CAS_KHT_H
#define _CAS_KHT_H

#include <mutex>
#include "base_kht.hpp"
#include "city/city.h"
#include "helper.hpp"
#include "sync.h"
#include "types.hpp"
#include "dbg.hpp"
#include "ht_helper.hpp"

#if defined(XX_HASH)
#include "xx/xxhash.h"
#endif

#if defined(XX_HASH_3)
#include "xx/xxh3.h"
#endif

namespace kmercounter {

struct Kmer_KV_cas {
  Kmer_base_cas_t kb;            // 20 + 2 bytes
  uint64_t kmer_hash;        // 8 bytes
  volatile char padding[2];  // 2 bytes
} __attribute__((packed));

static uint64_t working_threads = 0;

typedef struct {
  char kmer_data[KMER_DATA_LENGTH];  // 50 bytes
  uint16_t kmer_count;     // 2 bytes // TODO seems too long, max count is ~14
  bool occupied;           // 1 bytes
  uint64_t kmer_hash;  // 8 bytes
  char padding[3];         // 3 bytes // TODO remove hardcode
} __attribute__((packed)) CAS_Kmer_r;

// TODO store org kmer idx, to check if we have wrappd around after reprobe
typedef struct {
  const void* kmer_data_ptr;
  uint32_t kmer_idx;       // TODO reduce size, TODO decided by hashtable size?
  uint64_t kmer_hash;  // 8 bytes
} __attribute__((packed)) CAS_Kmer_queue_r;

std::ostream& operator<<(std::ostream& strm, const Kmer_KV_cas& k) {
  return strm << std::string(k.kb.kmer.data, KMER_DATA_LENGTH) << " : "
              << k.kb.count;
}

template <typename T = Kmer_KV_cas>
class CASKmerHashTable : public KmerHashTable {
 private:
  uint64_t capacity;
  T empty_kmer_r;  /* for comparison for empty slot */
  CAS_Kmer_queue_r* queue;  // TODO prefetch this?
  uint32_t queue_idx;
  std::mutex ht_init_mutex;

  uint64_t hash(const void *k) {
    uint64_t hash_val;
#if defined(CITY_HASH)
    hash_val = CityHash64((const char *)k, KMER_DATA_LENGTH);
#elif defined(FNV_HASH)
    hash_val = hval = fnv_32a_buf(k, KMER_DATA_LENGTH, hval);
#elif defined(XX_HASH)
    hash_val = XXH64(k, KMER_DATA_LENGTH, 0);
#elif defined(XX_HASH_3)
    hash_val = XXH3_64bits(k, KMER_DATA_LENGTH);
#endif
    return hash_val;
  }

  void prefetch(uint64_t i) {
#if defined(PREFETCH_WITH_PREFETCH_INSTR)
    prefetch_object(&this->hashtable[i & (this->capacity - 1)],
                    sizeof(this->hashtable[i & (this->capacity - 1)]));
#endif

#if defined(PREFETCH_WITH_WRITE)
    prefetch_with_write(&this->hashtable[i & (this->capacity - 1)]);
#endif
  };
  void __insert_into_queue(const void* kmer_data) {
    uint64_t hash_new = this->hash((const char*)kmer_data);
    size_t __kmer_idx = hash_new & (this->capacity - 1);  // modulo
    // size_t __kmer_idx = cityhash_new % (this->capacity);

    /* prefetch buckets and store kmer_data pointers in queue */
    // TODO how much to prefetch?
    // TODO if we do prefetch: what to return? API breaks
    this->prefetch(__kmer_idx);

    // __builtin_prefetch(&hashtable[__kmer_idx], 1, 3);
    // printf("inserting into queue at %u\n", this->queue_idx);
    this->queue[this->queue_idx].kmer_data_ptr = kmer_data;
    this->queue[this->queue_idx].kmer_idx = __kmer_idx;
#ifdef COMPARE_HASH
    this->queue[this->queue_idx].kmer_cityhash = hash_new;
#endif
    this->queue_idx++;
  }

  /* Insert items from queue into hash table, interpreting "queue"
  as an array of size queue_sz*/
  void __insert_from_queue(size_t queue_sz) {
    this->queue_idx = 0;  // start again
    for (size_t i = 0; i < queue_sz; i++) {
      __insert(&this->queue[i]);
    }
  }

  void __insert(CAS_Kmer_queue_r* q) {
    static int no_ins = 0;
    size_t pidx = q->kmer_idx; /* hashtable location at which data is to be inserted */

    /* Compare with empty kmer to check if bucket is empty, and insert. */
    // hashtable_mutexes[pidx].lock();
    // printf("Thread %lu, grabbing lock: %lu\n", this->thread_id, pidx);

    if (!hashtable[pidx].kb.occupied) {
      bool cas_res = fipc_test_CAS(&hashtable[pidx].kb.occupied, false, true);
      if (!cas_res) {
        goto reprobe;
      }
#ifdef CALC_STATS
      this->num_memcpys++;
#endif

      memcpy(&hashtable[pidx].kb.kmer.data, q->kmer_data_ptr, KMER_DATA_LENGTH);
      hashtable[pidx].kb.count++;
      // hashtable[pidx].occupied = true;
#ifdef COMPARE_HASH
      hashtable[pidx].kmer_hash = q->kmer_hash;
#endif
      // hashtable_mutexes[pidx].unlock();
      // printf("Thread %lu, released lock: %lu\n", this->thread_id,
      // pidx);
      return;
    }

#ifdef CALC_STATS
    this->num_hashcmps++;
#endif

    if (hashtable[pidx].kmer_hash == q->kmer_hash) {
#ifdef CALC_STATS
      this->num_memcmps++;
#endif

      if (memcmp(&hashtable[pidx].kb.kmer.data, q->kmer_data_ptr,
                 KMER_DATA_LENGTH) == 0) {
        bool cas_res = false;
        uint32_t ocount;
        // TODO: atomic_inc
#ifdef USE_ATOMICS
        fipc_test_FAI(hashtable[pidx].kb.count);
#else
        while (cas_res == false) {
          ocount = hashtable[pidx].kb.count;
          cas_res =
              fipc_test_CAS(&hashtable[pidx].kb.count, ocount, ocount + 1);
        }
#endif
        // hashtable[pidx].kmer_count++;
        // hashtable_mutexes[pidx].unlock();
        return;
      }
    }
reprobe:
    {
      // hashtable_mutexes[pidx].unlock();

      /* insert back into queue, and prefetch next bucket.
      next bucket will be probed in the next run
      */
      pidx++;
      pidx = pidx & (this->capacity - 1);  // modulo

      prefetch(pidx);
      q->kmer_idx = pidx;

      //this->queue[this->queue_idx] = *q;
      this->queue[this->queue_idx].kmer_data_ptr = q->kmer_data_ptr;
      this->queue[this->queue_idx].kmer_idx = q->kmer_idx;
      this->queue_idx++;
      // printf("reprobe pidx %d\n", pidx);

#ifdef CALC_STATS
      this->num_reprobes++;
#endif
      return;
    }
  }

 public:
  static T* hashtable;
  // static std::vector<std::mutex> hashtable_mutexes;
  // uint32_t thread_id;

  CASKmerHashTable(uint64_t c) {
    // TODO static cast
    // TODO power of 2 hashtable size for ease of mod operations
    this->capacity = kmercounter::next_pow2(c);
    this->ht_init_mutex.lock();
    if (!hashtable) {
      this->hashtable = (T*)(aligned_alloc(
          PAGE_SIZE, capacity * sizeof(T)));
      memset(hashtable, 0, capacity * sizeof(T));
      memset(&this->empty_kmer_r, 0, sizeof(T));
    }
    this->ht_init_mutex.unlock();

    this->queue = (CAS_Kmer_queue_r*)(aligned_alloc(
        PAGE_SIZE,
        kmercounter::PREFETCH_QUEUE_SIZE * sizeof(CAS_Kmer_queue_r)));
    this->queue_idx = 0;
    // __builtin_prefetch(queue, 1, 3);
    fipc_test_FAI(working_threads);

    // this->thread_id = t;

    // std::vector<std::mutex> __ hashtable_mutexes (this->capacity);
    // hashtable_mutexes.swap(__// hashtable_mutexes);
  }

  ~CASKmerHashTable() {
    free(queue);
    fipc_test_FAD(working_threads);
    if (!working_threads) {
      printf("DESTROYED\n");
      free(hashtable);
    }
  }

  /* insert and increment if exists */
  bool insert(const void* kmer_data) {
    __insert_into_queue(kmer_data);

    /* if queue is full, actually insert */
    // now queue_idx = 20
    if (this->queue_idx >= PREFETCH_QUEUE_SIZE) {
      this->__insert_from_queue(PREFETCH_QUEUE_SIZE);
    }

    /* if queue is still full, empty it. This is especially needed
    if queue size is small (< 20?) */
    if (this->queue_idx == PREFETCH_QUEUE_SIZE) {
    	this->flush_queue();
    }
    return true;
  }

  void flush_queue() {
    size_t curr_queue_sz = this->queue_idx;
    while (curr_queue_sz != 0) {
      __insert_from_queue(curr_queue_sz);
      curr_queue_sz = this->queue_idx;
    }
#ifdef CALC_STATS
    this->num_queue_flushes++;
#endif
  }

  // T* find(const void * kmer_data)
  T *find(const void* kmer_data) {
#ifdef CALC_STATS
    uint64_t distance_from_bucket = 0;
#endif
    uint64_t hash_new = this->hash((const char *)kmer_data);

    size_t idx = hash_new & (this->capacity - 1);  // modulo

    // printf("Thread %lu: Trying memcmp at: %lu\n", this->thread_id, idx);
    int memcmp_res =
        memcmp(&hashtable[idx].kb.kmer.data, kmer_data, KMER_DATA_LENGTH);

    while (memcmp_res != 0) {
      idx++;
      idx = idx & (this->capacity - 1);
      // printf("%d\n", idx);
      memcmp_res =
          memcmp(&hashtable[idx].kb.kmer.data, kmer_data, KMER_DATA_LENGTH);
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
    return &this->hashtable[idx];
  }

  void display() const override {
    for (size_t i = 0; i < this->capacity; i++) {
      if (hashtable[i].kb.occupied) {
        /*for (size_t k = 0; k < KMER_DATA_LENGTH; k++) {
          printf("%c", hashtable[i].kb.kmer.data[k]);
        }*/
        printf("%u: %u\n", i, hashtable[i].kb.count);
      }
    }
  }

  size_t get_fill() const override {
    size_t count = 0;
    for (size_t i = 0; i < this->capacity; i++) {
      if (this->hashtable[i].kb.occupied) {
        count++;
      }
    }
    return count;
  }

  size_t get_capacity() const override { return this->capacity; }

  size_t get_max_count() const override {
    size_t count = 0;
    for (size_t i = 0; i < this->capacity; i++) {
      if (hashtable[i].kb.count > count) {
        count = hashtable[i].kb.count;
      }
    }
    return count;
  }

  void print_to_file(std::string& outfile) const override {
    std::ofstream f(outfile);
    if (!f) {
      dbg("Could not open outfile %s\n", outfile.c_str());
      return;
    }

    for (size_t i = 0; i < this->get_capacity(); i++) {
      if (this->hashtable[i].kb.count > 0) {
        f << this->hashtable[i] << std::endl;
      }
    }
  }
};

template<class T>
T* CASKmerHashTable<T>::hashtable;
// std::vector<std::mutex> CASKmerHashTable:: hashtable_mutexes;

// TODO bloom filters for high frequency kmers?

}  // namespace kmercounter
#endif /* _CAS_KHT_H */
