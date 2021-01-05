#ifndef _CAS_KHT_H
#define _CAS_KHT_H

#include <mutex>

#include "dbg.hpp"
#include "helper.hpp"
#include "ht_helper.hpp"
#include "sync.h"

namespace kmercounter {

template <typename KV, typename KVQ>
class CASHashTable : public BaseHashTable {
 public:
  static KV *hashtable;
  int fd;
  int id;
  size_t data_length, key_length;

  // static std::vector<std::mutex> hashtable_mutexes;
  // uint32_t thread_id;

  CASHashTable(uint64_t c) : fd(-1), id(1), queue_idx(0) {
    this->capacity = kmercounter::next_pow2(c);
    // this->ht_init_mutex.lock();
    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);
      if (!this->hashtable) {
        this->hashtable = calloc_ht<KV>(this->capacity, this->id, &this->fd);
      }
    }
    this->empty_item = this->empty_item.get_empty_key();
    this->key_length = empty_item.key_length();
    this->data_length = empty_item.data_length();

    cout << "Empty item: " << this->empty_item << endl;
    this->queue = (KVQ *)(aligned_alloc(64, PREFETCH_QUEUE_SIZE * sizeof(KVQ)));

    printf("[INFO] Hashtable size: %lu\n", this->capacity);
    printf("%s, data_length %lu\n", __func__, this->data_length);

    // this->ht_init_mutex.unlock();
    // this->thread_id = t;
    // std::vector<std::mutex> __ hashtable_mutexes (this->capacity);
    // hashtable_mutexes.swap(__// hashtable_mutexes);
  }

  ~CASHashTable() {
    free(queue);
    free_mem<KV>(this->hashtable, this->capacity, this->id, this->fd);
  }

  uint8_t flush_find_queue() override { return 0; }

  /* insert and increment if exists */
  bool insert(const void *data) {
    this->__insert_into_queue(data);

    /* if queue is full, actually insert */
    // now queue_idx = 20
    if (this->queue_idx >= PREFETCH_QUEUE_SIZE) {
      this->__insert_from_queue(PREFETCH_QUEUE_SIZE);
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
      __insert_from_queue(curr_queue_sz);
      curr_queue_sz = this->queue_idx;
    }
#ifdef CALC_STATS
    this->num_queue_flushes++;
#endif
  }

  void insert_noprefetch(void *data) {
    uint64_t hash = this->hash((const char *)data);
    size_t idx = hash & (this->capacity - 1);  // modulo

    for (auto i = 0u; i < this->capacity; i++) {
      KV *curr = &this->hashtable[idx];
    retry:
      if (curr->is_empty()) {
        bool cas_res = curr->cas_insert(data, this->empty_item);
        if (cas_res) {
          break;
        } else {
          goto retry;
        }
      } else if (curr->compare_key(data)) {
        curr->cas_update(data);
        break;
      } else {
        idx++;
        idx = idx & (this->capacity - 1);
      }
    }
  }

  uint8_t find_batch(uint64_t *keys, uint32_t batch_len) override {
    assert(false);
    return 0;
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
  static std::mutex ht_init_mutex;
  uint64_t capacity;
  KV empty_item;
  KVQ *queue;
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

  void prefetch(uint64_t i) {
#if defined(PREFETCH_WITH_PREFETCH_INSTR)
    prefetch_object(&this->hashtable[i & (this->capacity - 1)],
                    sizeof(this->hashtable[i & (this->capacity - 1)]),
                    true /*write*/);
#endif

#if defined(PREFETCH_WITH_WRITE)
    prefetch_with_write(&this->hashtable[i & (this->capacity - 1)]);
#endif
  };

  void prefetch_read(uint64_t i) {
    prefetch_object(&this->hashtable[i & (this->capacity - 1)],
                    sizeof(this->hashtable[i & (this->capacity - 1)]),
                    false /* write */);
  }

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

  void __insert(KVQ *q) {
    // hashtable idx at which data is to be inserted
    size_t idx = q->idx;
  try_insert:
    KV *curr = &this->hashtable[idx];

    // hashtable_mutexes[pidx].lock();
    // printf("Thread %lu, grabbing lock: %lu\n", this->thread_id, pidx);
    // Compare with empty element
    if (curr->is_empty()) {
      bool cas_res = curr->cas_insert(q->data, this->empty_item);
      if (cas_res) {
#ifdef CALC_STATS
        this->num_memcpys++;
#endif

#ifdef COMPARE_HASH
        hashtable[pidx].key_hash = q->key_hash;
#endif
        return;
      }
      // hashtable_mutexes[pidx].unlock();
      // printf("Thread %lu, released lock: %lu\n", this->thread_id,
      // pidx);
      // printf("%lu: %d | %d\n", pidx, hashtable[pidx].kb.count, no_ins++);
      // If CAS fails, we need to see if someother thread has updated the same
      // <k,v> onto the position we were trying to insert. If so, we need to
      // update the value instead of inserting new. Just fall-through to check!
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
        curr->cas_update(q->data);
        // hashtable[pidx].kmer_count++;
        // hashtable_mutexes[pidx].unlock();
        return;
      }
    }

    // hashtable_mutexes[pidx].unlock();

    /* insert back into queue, and prefetch next bucket.
    next bucket will be probed in the next run
    */
    idx++;
    idx = idx & (this->capacity - 1);  // modulo

    // |    4 elements |
    // | 0 | 1 | 2 | 3 | 4 | 5 ....
    if ((idx & 0x3) != 0) {
      goto try_insert;
    }

    prefetch(idx);

    this->queue[this->queue_idx].data = q->data;
    this->queue[this->queue_idx].idx = idx;
    this->queue_idx++;
    // printf("reprobe pidx %d\n", pidx);

#ifdef CALC_STATS
    this->num_reprobes++;
#endif
    return;
  }
};

template <class KV, class KVQ>
KV *CASHashTable<KV, KVQ>::hashtable;

template <class KV, class KVQ>
std::mutex CASHashTable<KV, KVQ>::ht_init_mutex;
// std::vector<std::mutex> CASHashTable:: hashtable_mutexes;

// TODO bloom filters for high frequency kmers?

}  // namespace kmercounter
#endif /* _CAS_KHT_H */
