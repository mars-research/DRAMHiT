#ifndef _SKHT_H
#define _SKHT_H

#include <fcntl.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include <cassert>
#include <fstream>
#include <iostream>

#include "dbg.hpp"
#include "helper.hpp"
#include "ht_helper.hpp"
#include "sync.h"

namespace kmercounter {

// TODO use char and bit manipulation instead of bit fields in Kmer_KV:
// https://stackoverflow.com/questions/1283221/algorithm-for-copying-n-bits-at-arbitrary-position-from-one-int-to-another
// TODO how long should be the count variable?
// TODO should we pack the struct?

template <typename KV, typename KVQ>
class alignas(64) PartitionedHashStore : public BaseHashTable {
 public:
  KV *hashtable;
  int fd;
  int id;
  size_t data_length, key_length;

  // https://www.bfilipek.com/2019/08/newnew-align.html
  void *operator new(std::size_t size, std::align_val_t align) {
    auto ptr = aligned_alloc(static_cast<std::size_t>(align), size);

    if (!ptr) throw std::bad_alloc{};

    std::cout << "[INFO] "
              << "new: " << size
              << ", align: " << static_cast<std::size_t>(align)
              << ", ptr: " << ptr << '\n';

    return ptr;
  }

  void operator delete(void *ptr, std::size_t size,
                       std::align_val_t align) noexcept {
    std::cout << "delete: " << size
              << ", align: " << static_cast<std::size_t>(align)
              << ", ptr : " << ptr << '\n';
    free(ptr);
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

  inline uint8_t touch(uint64_t i) {
#if defined(TOUCH_DEPENDENCY)
    if (this->hashtable[i & (this->capacity - 1)].kb.count == 0) {
      this->hashtable[i & (this->capacity - 1)].kb.count = 1;
    } else {
      this->hashtable[i & (this->capacity - 1)].kb.count = 1;
    };
#else
    this->hashtable[i & (this->capacity - 1)].kb.count = 1;
#endif
    return 0;
  };

  PartitionedHashStore(uint64_t c, uint8_t id) : fd(-1), id(id), queue_idx(0) {
    this->capacity = kmercounter::next_pow2(c);
    this->hashtable = calloc_ht<KV>(capacity, this->id, &this->fd);
    this->empty_item = this->empty_item.get_empty_key();
    this->key_length = empty_item.key_length();
    this->data_length = empty_item.data_length();

    cout << "Empty item: " << this->empty_item << endl;
    this->queue = (KVQ *)(aligned_alloc(64, PREFETCH_QUEUE_SIZE * sizeof(KVQ)));
    dbg("id: %d this->queue %p\n", id, this->queue);
    printf("[INFO] Hashtable size: %lu\n", this->capacity);
    printf("%s, data_length %lu\n", __func__, this->data_length);
  }

  ~PartitionedHashStore() {
    free(queue);
    free_mem<KV>(this->hashtable, this->capacity, this->id, this->fd);
  }

#if INSERT_BATCH

  insert_one() {
    occupied = this->hashtable[pidx].kb.occupied;

    /* Compare with empty kmer to check if bucket is empty, and insert.*/
    if (!occupied) {
#ifdef CALC_STATS
      this->num_memcpys++;
#endif
      memcpy(&this->hashtable[pidx].kb.kmer.data, q->kmer_p, this->data_length);
      this->hashtable[pidx].kb.count++;
      this->hashtable[pidx].kb.occupied = true;
      this->hashtable[pidx].key_hash = q->key_hash;
      return;
    }

#ifdef CALC_STATS
    this->num_hashcmps++;
#endif

    if (this->hashtable[pidx].kmer_hash == q->kmer_hash) {
#ifdef CALC_STATS
      this->num_memcmps++;
#endif

      if (memcmp(&this->hashtable[pidx].kb.kmer.data, q->kmer_p,
                 this->data_length) == 0) {
        this->hashtable[pidx].kb.count++;
        return;
      }
    }

    {
      /* insert back into queue, and prefetch next bucket.
      next bucket will be probed in the next run
      */
      pidx++;
      pidx = pidx & (this->capacity - 1);  // modulo
      prefetch(pidx);
      q->kmer_idx = pidx;

      this->queue[this->queue_idx] = *q;
      // this->queue[this->queue_idx].data = q->data;
      // this->queue[this->queue_idx].idx = q->idx;
      this->queue_idx++;

#ifdef CALC_STATS
      this->num_reprobes++;
#endif
    }

    void insert_batch(kmer_data_t * karray[4]) {
      uint64_t hash_new_0 = this->hash((const char *)karray[0]);
      size_t __kmer_idx_1 = hash & (this->capacity - 1);  // modulo

      uint64_t hash_new_0 = this->hash((const char *)karray[0]);
      size_t __kmer_idx_1 = hash & (this->capacity - 1);  // modulo

      uint64_t hash_new_0 = this->hash((const char *)karray[0]);
      size_t __kmer_idx_1 = hash & (this->capacity - 1);  // modulo

      uint64_t hash_new_0 = this->hash((const char *)karray[0]);
      size_t __kmer_idx_1 = hash & (this->capacity - 1);  // modulo

      return;
    }
  };

#endif

  /* insert and increment if exists */
  bool insert(const void *data) {
    assert(this->queue_idx < PREFETCH_QUEUE_SIZE);
    __insert_into_queue(data);

    /* if queue is full, actually insert */
    // now queue_idx = 20
    if (this->queue_idx >= PREFETCH_QUEUE_SIZE) {
      this->__insert_from_queue();

#if 0
      for (auto i = 0u; i < PREFETCH_QUEUE_SIZE / 2; i += 4)
        __builtin_prefetch(&this->queue[this->queue_idx + i], 1, 3);
#endif
    }

    // XXX: This is to ensure correctness of the hashtable. No matter what the
    // queue size is, this has to be enabled!
    if (this->queue_idx == PREFETCH_QUEUE_SIZE) {
      this->flush_queue();
    }

    // XXX: Most likely the HT is full here. We should panic here!
    assert(this->queue_idx < PREFETCH_QUEUE_SIZE);

    return true;
  }

  void flush_queue() {
    size_t curr_queue_sz = this->queue_idx;
    while (curr_queue_sz != 0) {
      __flush_from_queue(curr_queue_sz);
      curr_queue_sz = this->queue_idx;
    }
#ifdef CALC_STATS
    this->num_queue_flushes++;
#endif
  }

  void *find(const void *data) {
#ifdef CALC_STATS
    uint64_t distance_from_bucket = 0;
#endif
    uint64_t hash = this->hash((const char *)data);
    size_t idx = hash;
    KV *curr;
    bool found = false;

    // printf("Thread %lu: Trying memcmp at: %lu\n", this->thread_id, idx);
    for (auto i = 0u; i < this->capacity; i++) {
      idx = idx & (this->capacity - 1);
      curr = &this->hashtable[idx];
      if (curr->compare_key(data)) {
        found = true;
        break;
      }
#ifdef CALC_STATS
      distance_from_bucket++;
#endif
      idx++;
    }
#ifdef CALC_STATS
    if (distance_from_bucket > this->max_distance_from_bucket) {
      this->max_distance_from_bucket = distance_from_bucket;
    }
    this->sum_distance_from_bucket += distance_from_bucket;
#endif
    // return empty_element if nothing is found
    if (!found) {
      curr = &this->empty_item;
    }
    return curr;
  }

  void display() const override {
    for (size_t i = 0; i < this->capacity; i++) {
      if (!this->hashtable[i].is_empty()) {
        cout << this->hashtable[i] << endl;
      }
    }
  }

  size_t get_fill() const override {
    size_t count = 0;
    for (size_t i = 0; i < this->capacity; i++) {
      if (!this->hashtable[i].is_empty()) {
        count++;
      }
    }
    return count;
  }

  size_t get_capacity() const override { return this->capacity; }

  size_t get_max_count() const override {
    size_t count = 0;
    for (size_t i = 0; i < this->capacity; i++) {
      if (this->hashtable[i].get_value() > count) {
        count = this->hashtable[i].get_value();
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
      if (!this->hashtable[i].is_empty()) {
        f << this->hashtable[i] << std::endl;
      }
    }
  }

 private:
  uint64_t capacity;
  KV empty_item; /* for comparison for empty slot */
  KVQ *queue;    // TODO prefetch this?
  uint32_t queue_idx;

  uint64_t hash(const void *k) {
    uint64_t hash_val;
#if defined(CITY_HASH)
    hash_val = CityHash64((const char *)k, this->key_length);
#elif defined(FNV_HASH)
    hash_val = hval = fnv_32a_buf(k, this->key_length, hval);
#elif defined(XX_HASH)
    hash_val = XXH64(k, this->key_length, 0);
#elif defined(XX_HASH_3)
    hash_val = XXH3_64bits(k, this->key_length);
#endif
    return hash_val;
  }

  /* Insert using prefetch: using a dynamic prefetch queue.
          If bucket is occupied, add to queue again to reprobe.
  */
  void __insert_with_soft_reprobe(KVQ *q) {
    /* hashtable location at which data is to be inserted */
    size_t pidx = q->idx;
    KV *curr = &this->hashtable[pidx];
    // printf("%s trying to insert %d\n", __func__, *(uint64_t*)q->data);
    // cout << "element at pidx: " << pidx << " => " << this->hashtable[pidx] <<
    // " occupied: " << occupied << endl;
  try_insert:
    // Compare with empty element
    if (curr->is_empty()) {
#ifdef CALC_STATS
      this->num_memcpys++;
#endif
      curr.update_item(q->data);
      // this->hashtable[pidx].kb.count++;
      // this->hashtable[pidx].set_count(this->hashtable[pidx].count() + 1);
      // printf("inserting %d | ",
      // *(uint64_t*)&this->hashtable[pidx].kb.kmer.data printf("%lu: %d |
      // %d\n", pidx, hashtable[pidx].kb.count, no_ins++);
      // cout << "Inserting " << this->hashtable[pidx] << endl;
#ifdef COMPARE_HASH
      this->hashtable[pidx].key_hash = q->key_hash;
#endif
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

      if (curr->compare_key(q->data)) {
        // update value
        curr->update_value(q->data, 0);
        return;
      }
    }

    {
      /* insert back into queue, and prefetch next bucket.
      next bucket will be probed in the next run
      */
      pidx++;
      pidx = pidx & (this->capacity - 1);  // modulo

      //   | cacheline |
      //   | i | i + 1 |
      //   In the case where two elements fit in a cacheline, a single prefetch
      //   would bring in both the elements. We need not issue a second
      //   prefetch.
      if ((pidx & 0x1) || (pidx & 0x2)) {
        // if (unlikely(pidx & 0x1)) {
#ifdef CALC_STATS
        this->num_soft_reprobes++;
#endif
        goto try_insert;
      }
      prefetch(pidx);
      // q->idx = pidx;

      // this->queue[this->queue_idx] = *q;
      this->queue[this->queue_idx].data = q->data;
      this->queue[this->queue_idx].idx = pidx;
      this->queue_idx++;
      // printf("reprobe pidx %d\n", pidx);

#ifdef CALC_STATS
      this->num_reprobes++;
#endif
      return;
    }
  }

  void __insert(KVQ *q) {
    // hashtable idx at which data is to be inserted
    size_t idx = q->idx;
    KV *curr = &this->hashtable[idx];

    // Compare with empty element
    if (curr->is_empty()) {
#ifdef CALC_STATS
      this->num_memcpys++;
#endif
      curr->insert_item(q->data, 0);
#ifdef COMPARE_HASH
      this->hashtable[pidx].key_hash = q->key_hash;
#endif
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

      if (curr->compare_key(q->data)) {
        curr->update_value(q->data, 0);
        return;
      }
    }

    // insert back into queue, and prefetch next bucket.
    // next bucket will be probed in the next run
    idx++;
    idx = idx & (this->capacity - 1);  // modulo
    prefetch(idx);

    this->queue[this->queue_idx].data = q->data;
    this->queue[this->queue_idx].idx = idx;
    this->queue_idx++;

#ifdef CALC_STATS
    this->num_reprobes++;
#endif
    return;
  }

  /* Insert items from queue into hash table, interpreting "queue"
  as an array of size queue_sz*/
  void __insert_from_queue() {
    this->queue_idx = 0;  // start again
    for (size_t i = 0; i < PREFETCH_QUEUE_SIZE; i++) {
      __insert(&this->queue[i]);
    }
  }

  void __flush_from_queue(size_t qsize) {
    this->queue_idx = 0;  // start again
    for (size_t i = 0; i < qsize; i++) {
      __insert(&this->queue[i]);
    }
  }

  void __insert_into_queue(const void *data) {
    uint64_t hash = this->hash((const char *)data);
    size_t idx = hash & (this->capacity - 1);  // modulo
    // size_t __kmer_idx2 = (hash + 3) & (this->capacity - 1);  // modulo
    // size_t __kmer_idx = cityhash_new % (this->capacity);

    /* prefetch buckets and store data pointers in queue */
    // TODO how much to prefetch?
    // TODO if we do prefetch: what to return? API breaks
    this->prefetch(idx);
    // this->prefetch(__kmer_idx2);

    // printf("inserting into queue at %u\n", this->queue_idx);
    // for (auto i = 0; i < 10; i++)
    //  asm volatile("nop");
    this->queue[this->queue_idx].data = data;
    this->queue[this->queue_idx].idx = idx;
#ifdef COMPARE_HASH
    this->queue[this->queue_idx].key_hash = hash;
#endif
    this->queue_idx++;
  }
};

// TODO bloom filters for high frequency kmers?

}  // namespace kmercounter
#endif /* _SKHT_H_ */
