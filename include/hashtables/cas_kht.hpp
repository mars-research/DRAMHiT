/// Compare-and-swap(CAS) with linear probing hashtable based off of
/// the folklore HT https://arxiv.org/pdf/1601.04017.pdf
/// Key and values are stored directly in the table.
/// CASHashtable is not parititioned, meaning that there will be
/// at max one instance of it. All threads will share the same 
/// instance.
/// The original one is called the casht and the one we modified with
/// batching + prefetching though is called casht++.
// TODO bloom filters for high frequency kmers?

#ifndef HASHTABLES_CAS_KHT_HPP
#define HASHTABLES_CAS_KHT_HPP

#include <cassert>
#include <fstream>
#include <iostream>
#include <mutex>

#include "constants.hpp"
#include "plog/Log.h"
#include "helper.hpp"
#include "ht_helper.hpp"
#include "sync.h"
#include "hasher.hpp"

namespace kmercounter {
template <typename KV, typename KVQ>
class CASHashTable : public BaseHashTable {
 public:
  /// The global instance is shared by all threads.
  static KV *hashtable;
  /// File descriptor backs the memory
  int fd;
  int id;
  size_t data_length, key_length;

  // static std::vector<std::mutex> hashtable_mutexes;
  // uint32_t thread_id;

  CASHashTable(uint64_t c)
      : fd(-1), id(1), find_head(0), find_tail(0), ins_head(0), ins_tail(0) {
    this->capacity = kmercounter::utils::next_pow2(c);
    // this->ht_init_mutex.lock();
    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);
      if (!this->hashtable) {
        assert(this->ref_cnt == 0);
        this->hashtable = calloc_ht<KV>(this->capacity, this->id, &this->fd, true);
      }
      this->ref_cnt++;
    }
    this->empty_item = this->empty_item.get_empty_key();
    this->key_length = empty_item.key_length();
    this->data_length = empty_item.data_length();

    PLOG_WARNING << "Empty item: " << this->empty_item;
    this->insert_queue =
        (KVQ *)(aligned_alloc(64, PREFETCH_QUEUE_SIZE * sizeof(KVQ)));
    this->find_queue =
        (KVQ *)(aligned_alloc(64, PREFETCH_FIND_QUEUE_SIZE * sizeof(KVQ)));

    printf("[INFO] Hashtable size: %lu\n", this->capacity);
    printf("%s, data_length %lu\n", __func__, this->data_length);

    // this->ht_init_mutex.unlock();
    // this->thread_id = t;
    // std::vector<std::mutex> __ hashtable_mutexes (this->capacity);
    // hashtable_mutexes.swap(__// hashtable_mutexes);
  }

  ~CASHashTable() {
    free(find_queue);
    free(insert_queue);
    // Deallocate the global hashtable if ref_cnt goes down to zero.
    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);
      this->ref_cnt--;
      if (this->ref_cnt == 0) {
        free_mem<KV>(this->hashtable, this->capacity, this->id, this->fd);
        this->hashtable = nullptr;
      }
    }
  }

  void prefetch_queue(QueueType qtype) override {}

  void insert_noprefetch(const void *data) {
    uint64_t hash = this->hash((const char *)data);
    size_t idx = hash & (this->capacity - 1);  // modulo

    KVQ *elem = const_cast<KVQ *>(reinterpret_cast<const KVQ *>(data));

    for (auto i = 0u; i < this->capacity; i++) {
      KV *curr = &this->hashtable[idx];
    retry:
      if (curr->is_empty()) {
        bool cas_res = curr->insert_cas(elem);
        if (cas_res) {
          break;
        } else {
          goto retry;
        }
      } else if (curr->compare_key(data)) {
        curr->update_cas(elem);
        break;
      } else {
        idx++;
        idx = idx & (this->capacity - 1);
      }
    }
  }

  bool insert(const void *data) {
    cout << "Not implemented!" << endl;
    assert(false);
    return false;
  }

  // insert a batch
  void insert_batch(KeyPairs &kp) override {
    this->flush_if_needed();

    Keys *keys;
    uint32_t batch_len;
    std::tie(batch_len, keys) = kp;

    for (auto k = 0u; k < batch_len; k++) {
      void *data = reinterpret_cast<void *>(&keys[k]);
      add_to_insert_queue(data);
    }

    this->flush_if_needed();
  }

  // overridden function for insertion
  void flush_if_needed(void) {
    size_t curr_queue_sz =
        (this->ins_head - this->ins_tail) & (PREFETCH_QUEUE_SIZE - 1);
    while (curr_queue_sz >= INS_FLUSH_THRESHOLD) {
      __insert_one(&this->insert_queue[this->ins_tail]);
      if (++this->ins_tail >= PREFETCH_QUEUE_SIZE) this->ins_tail = 0;
      curr_queue_sz =
          (this->ins_head - this->ins_tail) & (PREFETCH_QUEUE_SIZE - 1);
    }
    return;
  }

  void flush_insert_queue() override {
    size_t curr_queue_sz =
        (this->ins_head - this->ins_tail) & (PREFETCH_QUEUE_SIZE - 1);

    while (curr_queue_sz != 0) {
      __insert_one(&this->insert_queue[this->ins_tail]);
      if (++this->ins_tail >= PREFETCH_QUEUE_SIZE) this->ins_tail = 0;
      curr_queue_sz =
          (this->ins_head - this->ins_tail) & (PREFETCH_QUEUE_SIZE - 1);
    }
  }

  void flush_find_queue(ValuePairs &vp) override {
    size_t curr_queue_sz =
        (this->find_head - this->find_tail) & (PREFETCH_FIND_QUEUE_SIZE - 1);

    while ((curr_queue_sz != 0) && (vp.first < HT_TESTS_BATCH_LENGTH)) {
      __find_one(&this->find_queue[this->find_tail], vp);
      if (++this->find_tail >= PREFETCH_FIND_QUEUE_SIZE) this->find_tail = 0;
      curr_queue_sz =
          (this->find_head - this->find_tail) & (PREFETCH_FIND_QUEUE_SIZE - 1);
    }
  }

  void flush_if_needed(ValuePairs &vp) {
    size_t curr_queue_sz =
        (this->find_head - this->find_tail) & (PREFETCH_FIND_QUEUE_SIZE - 1);
    // make sure you return at most batch_sz (but can possibly return lesser
    // number of elements)
    while ((curr_queue_sz > FLUSH_THRESHOLD) &&
           (vp.first < HT_TESTS_FIND_BATCH_LENGTH)) {
      // cout << "Finding value for key " <<
      // this->find_queue[this->find_tail].key << " at tail : " <<
      // this->find_tail << endl;
      __find_one(&this->find_queue[this->find_tail], vp);
      if (++this->find_tail >= PREFETCH_FIND_QUEUE_SIZE) this->find_tail = 0;
      curr_queue_sz =
          (this->find_head - this->find_tail) & (PREFETCH_FIND_QUEUE_SIZE - 1);
    }
    return;
  }

  void find_batch(KeyPairs &kp, ValuePairs &values) {
    this->flush_if_needed(values);

    Keys *keys;
    uint32_t batch_len;
    std::tie(batch_len, keys) = kp;

    for (auto k = 0u; k < batch_len; k++) {
      void *data = reinterpret_cast<void *>(&keys[k]);
      add_to_find_queue(data);
    }

    this->flush_if_needed(values);
  }

  void *find_noprefetch(const void *data) {
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

      if (curr->is_empty()) {
        found = false;
        goto exit;
      } else if (curr->compare_key(data)) {
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
  exit:
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
      PLOG_ERROR.printf("Could not open outfile %s", outfile.c_str());
      return;
    }

    for (size_t i = 0; i < this->get_capacity(); i++) {
      if (!this->hashtable[i].is_empty()) {
        f << this->hashtable[i] << std::endl;
      }
    }
  }

 private:
  /// Assure thread-safety in constructor and destructor.
  static std::mutex ht_init_mutex;
  /// Reference counter of the global `hashtable`.
  static uint32_t ref_cnt;
  uint64_t capacity;
  KV empty_item;
  KVQ *find_queue;
  KVQ *insert_queue;
  uint32_t find_head;
  uint32_t find_tail;
  uint32_t ins_head;
  uint32_t ins_tail;
  Hasher hasher_;

  uint64_t hash(const void *k) {
    return hasher_(k, this->key_length);
  }

  void prefetch(uint64_t i) {
#if defined(PREFETCH_WITH_PREFETCH_INSTR)
    prefetch_object<true /* write */>(
        &this->hashtable[i & (this->capacity - 1)],
        sizeof(this->hashtable[i & (this->capacity - 1)]));
    // true /*write*/);
#endif

#if defined(PREFETCH_WITH_WRITE)
    prefetch_with_write(&this->hashtable[i & (this->capacity - 1)]);
#endif
  };

  void prefetch_read(uint64_t i) {
    prefetch_object<false /* write */>(
        &this->hashtable[i & (this->capacity - 1)],
        sizeof(this->hashtable[i & (this->capacity - 1)]));
  }

  uint64_t __find_branched(KVQ *q, ValuePairs &vp) {
    // hashtable idx where the data should be found
    size_t idx = q->idx;
    uint64_t found = 0;

  try_find:
    KV *curr = &this->hashtable[idx];
    uint64_t retry;
    found = curr->find(q, &retry, vp);

    // printf("%s, key = %lu | num_values %u, value %lu (id = %lu) | found=%ld, retry %ld\n",
    //          __func__, q->key, vp.first, vp.second[(vp.first - 1) %
    //                  PREFETCH_FIND_QUEUE_SIZE].value, vp.second[(vp.first - 1)
    //                  % PREFETCH_FIND_QUEUE_SIZE].id, found, retry);
    if (retry) {
      // insert back into queue, and prefetch next bucket.
      // next bucket will be probed in the next run
      idx++;
      idx = idx & (this->capacity - 1);  // modulo
      // |    4 elements |
      // | 0 | 1 | 2 | 3 | 4 | 5 ....
      if ((idx & 0x3) != 0) {
        goto try_find;
      }

      this->prefetch_read(idx);

      this->find_queue[this->find_head].key = q->key;
      this->find_queue[this->find_head].key_id = q->key_id;
      this->find_queue[this->find_head].idx = idx;

      this->find_head += 1;
      this->find_head &= (PREFETCH_FIND_QUEUE_SIZE - 1);
    }
    return found;
  }

  auto __find_one(KVQ *q, ValuePairs &vp) { return __find_branched(q, vp); }

  void __insert_branched(KVQ *q) {
    // hashtable idx at which data is to be inserted
    size_t idx = q->idx;
  try_insert:
    KV *curr = &this->hashtable[idx];

    // hashtable_mutexes[pidx].lock();
    // printf("Thread %lu, grabbing lock: %lu\n", this->thread_id, pidx);
    // Compare with empty element
    if (curr->is_empty()) {
      bool cas_res = curr->insert_cas(q);
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
      if (curr->compare_key(q)) {
        curr->update_cas(q);
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
#ifdef CALC_STATS
      ++this->num_soft_reprobes;
#endif
      goto try_insert; // FIXME: @David get rid of the goto for crying out loud
    }

    prefetch(idx);

    this->insert_queue[this->ins_head].key = q->key;
    this->insert_queue[this->ins_head].key_id = q->key_id;
    this->insert_queue[this->ins_head].value = q->value;
    this->insert_queue[this->ins_head].idx = idx;
    ++this->ins_head;
    this->ins_head &= (PREFETCH_QUEUE_SIZE - 1);

#ifdef CALC_STATS
    this->num_reprobes++;
#endif
    return;
  }

  void __insert_one(KVQ *q) { __insert_branched(q); }

  uint64_t read_hashtable_element(const void *data) override {
    PLOG_FATAL << "Not implemented";
    assert(false);
    return -1;
  }

  void add_to_insert_queue(void *data) {
    Keys *key_data = reinterpret_cast<Keys *>(data);
    uint64_t hash = this->hash((const char *)&key_data->key);
    size_t idx = hash & (this->capacity - 1);  // modulo

    // cout << " -- Adding " << key_data->key  << " at " << this->ins_head <<
    // endl;
    this->prefetch(idx);

    this->insert_queue[this->ins_head].idx = idx;
    this->insert_queue[this->ins_head].key = key_data->key;
    this->insert_queue[this->ins_head].value = key_data->value;
    this->insert_queue[this->ins_head].key_id = key_data->id;
    this->insert_queue[this->ins_head].value = key_data->id;

#ifdef COMPARE_HASH
    this->insert_queue[this->ins_head].key_hash = hash;
#endif

    this->ins_head++;
    if (this->ins_head >= PREFETCH_QUEUE_SIZE) this->ins_head = 0;
  }

  void add_to_find_queue(void *data) {
    Keys *key_data = reinterpret_cast<Keys *>(data);
    uint64_t hash = this->hash((const char *)&key_data->key);
    size_t idx = hash & (this->capacity - 1);  // modulo

    this->prefetch_read(idx);

    // cout << " -- Adding " << key_data->key  << " at " << this->find_head <<
    // endl;

    this->find_queue[this->find_head].idx = idx;
    this->find_queue[this->find_head].key = key_data->key;
    this->find_queue[this->find_head].key_id = key_data->id;

#ifdef COMPARE_HASH
    this->queue[this->find_head].key_hash = hash;
#endif

    this->find_head++;
    if (this->find_head >= PREFETCH_FIND_QUEUE_SIZE) this->find_head = 0;
  }
};

/// Static variables
template <class KV, class KVQ>
KV *CASHashTable<KV, KVQ>::hashtable = nullptr;

template <class KV, class KVQ>
std::mutex CASHashTable<KV, KVQ>::ht_init_mutex;

template <class KV, class KVQ>
uint32_t CASHashTable<KV, KVQ>::ref_cnt = 0;
}  // namespace kmercounter
#endif // HASHTABLES_CAS_KHT_HPP
