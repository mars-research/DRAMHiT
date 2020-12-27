#ifndef _CAS_KHT_H
#define _CAS_KHT_H

#include <mutex>

#include "dbg.hpp"
#include "helper.hpp"
#include "ht_helper.hpp"
#include "sync.h"

namespace kmercounter {

template <typename T = Kmer_KV_cas>
class CASKmerHashTable : public BaseHashTable {
 public:
  static T *hashtable;
  int fd;
  int id;
  // static std::vector<std::mutex> hashtable_mutexes;
  // uint32_t thread_id;

  CASKmerHashTable(uint64_t c) : fd(-1), id(1), queue_idx(0) {
    this->capacity = kmercounter::next_pow2(c);
    // this->ht_init_mutex.lock();
    if (!this->hashtable) {
      this->hashtable = calloc_ht<T>(this->capacity, this->id, &this->fd);
      memset(&this->empty_kmer_r, 0, sizeof(T));
    }
    this->ht_init_mutex.unlock();

    this->queue = (CAS_Kmer_queue_r *)(aligned_alloc(
        64, PREFETCH_QUEUE_SIZE * sizeof(CAS_Kmer_queue_r)));
    // this->thread_id = t;

    // std::vector<std::mutex> __ hashtable_mutexes (this->capacity);
    // hashtable_mutexes.swap(__// hashtable_mutexes);
  }

  ~CASKmerHashTable() {
    free(queue);
    free_mem<T>(this->hashtable, this->capacity, this->id, this->fd);
  }

  /* insert and increment if exists */
  bool insert(const void *kmer_data) {
    this->__insert_into_queue(kmer_data);

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
  void *find(const void *kmer_data) {
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
        printf("%lu: %u\n", i, hashtable[i].kb.count);
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

  void print_to_file(std::string &outfile) const override {
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

 private:
  uint64_t capacity;
  T empty_kmer_r; /* for comparison for empty slot */
  CAS_Kmer_queue_r *queue;
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
  void __insert_into_queue(const void *data) {
    uint64_t hash = this->hash((const char *)data);
    size_t idx = hash & (this->capacity - 1);  // modulo
    // size_t __kmer_idx = cityhash_new % (this->capacity);

    /* prefetch buckets and store kmer_data pointers in queue */
    // TODO how much to prefetch?
    // TODO if we do prefetch: what to return? API breaks
    this->prefetch(idx);

    // __builtin_prefetch(&hashtable[__kmer_idx], 1, 3);
    // printf("inserting into queue at %u\n", this->queue_idx);
    this->queue[this->queue_idx].data = data;
    this->queue[this->queue_idx].idx = idx;
#ifdef COMPARE_HASH
    this->queue[this->queue_idx].key_hash = hash;
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

  void __insert(CAS_Kmer_queue_r *q) {
    size_t pidx =
        q->idx; /* hashtable location at which data is to be inserted */

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

      memcpy(&hashtable[pidx].kb.kmer.data, q->data, KMER_DATA_LENGTH);
      hashtable[pidx].kb.count++;
#ifdef COMPARE_HASH
      hashtable[pidx].kmer_hash = q->kmer_hash;
#endif
      // hashtable_mutexes[pidx].unlock();
      // printf("Thread %lu, released lock: %lu\n", this->thread_id,
      // pidx);
      // printf("%lu: %d | %d\n", pidx, hashtable[pidx].kb.count, no_ins++);

      return;
    }

#ifdef CALC_STATS
    this->num_hashcmps++;
#endif

#ifdef COMPARE_HASH
    if (this->hashtable[pidx].key_hash == q->key_hash)
#endif
    {
#ifdef CALC_STATS
      this->num_memcmps++;
#endif

      if (memcmp(&hashtable[pidx].kb.kmer.data, q->data, KMER_DATA_LENGTH) ==
          0) {
#ifdef USE_ATOMICS
        fipc_test_FAI(hashtable[pidx].kb.count);
#else
        bool cas_res = false;
        uint32_t ocount;
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
  reprobe : {
    // hashtable_mutexes[pidx].unlock();

    /* insert back into queue, and prefetch next bucket.
    next bucket will be probed in the next run
    */
    pidx++;
    pidx = pidx & (this->capacity - 1);  // modulo

    prefetch(pidx);
    q->idx = pidx;

    // this->queue[this->queue_idx] = *q;
    this->queue[this->queue_idx].data = q->data;
    this->queue[this->queue_idx].idx = q->idx;
    this->queue_idx++;
    // printf("reprobe pidx %d\n", pidx);

#ifdef CALC_STATS
    this->num_reprobes++;
#endif
    return;
  }
  }
};

template <class T>
T *CASKmerHashTable<T>::hashtable;
// std::vector<std::mutex> CASKmerHashTable:: hashtable_mutexes;

// TODO bloom filters for high frequency kmers?

}  // namespace kmercounter
#endif /* _CAS_KHT_H */
