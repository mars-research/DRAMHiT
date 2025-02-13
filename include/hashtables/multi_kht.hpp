/// Compare-and-swap(CAS) with linear probing hashtable based off of
/// the folklore HT https://arxiv.org/pdf/1601.04017.pdf
/// Key and values are stored directly in the table.
/// CASHashtable is not parititioned, meaning that there will be
/// at max one instance of it. All threads will share the same
/// instance.
/// The original one is called the casht and the one we modified with
/// batching + prefetching though is called casht++.
// TODO bloom filters for high frequency kmers?

#ifndef HASHTABLES_MULTI_KHT_HPP
#define HASHTABLES_MULTI_KHT_HPP

#include <cassert>
#include <fstream>
#include <iostream>
#include <mutex>
#include <type_traits>

#include "constants.hpp"
#include "hasher.hpp"
#include "helper.hpp"
#include "ht_helper.hpp"
#include "plog/Log.h"
#include "sync.h"

namespace kmercounter {
template <typename KV, typename KVQ>
class MultiHashTable : public BaseHashTable {
 public:
  /// The global instance is shared by all threads.
  static KV *hashtable;  // 1024 * 4 <- 0, 4, 8,
  /// A dedicated slot for the empty value.
  static uint64_t empty_slot_;
  /// True if the empty value is inserted.
  static bool empty_slot_exists_;
  /// File descriptor backs the memory
  static KV *backup_hashtable;
  int fd;
  int id;



  const static __mmask8 KEYMSK = 0b01010101;
  size_t data_length, key_length;
  const static uint64_t CACHELINE_SIZE = 64;
  const static uint64_t KEYS_IN_CACHELINE_MASK =
      (CACHELINE_SIZE / sizeof(KV)) - 1;

  MultiHashTable(uint64_t c)
      : fd(-1),
        id(1),
        find_head(0),
        find_tail(0),
        ins_head(0),
        ins_tail(0) {
    this->capacity = kmercounter::utils::next_pow2(c);

    //capacity = capacity*2;
    lvl0_capacity = capacity >> 1; 
    lvl1_capacity = capacity - lvl0_capacity; 
    // lvl1_capacity = capacity >> 2; 
    // lvl0_capacity = capacity - lvl1_capacity; 
    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);
      if (!this->hashtable) {
        assert(this->ref_cnt == 0);
        this->hashtable = calloc_ht<KV>(this->capacity, this->id, &this->fd);
        this->backup_hashtable = &hashtable[lvl0_capacity]; // |0 | 1 |2 | 3| 

        PLOGI.printf("L0 Hashtable base: %p L0 Hashtable size: %lu\n"
                     "L1 Hashtable base: %p L1 Hashtable size: %lu",
                     hashtable, lvl0_capacity, backup_hashtable, lvl1_capacity);

        // this->backup_hashtable =
        //     calloc_ht<KV>(this->capacity, this->id1, &this->fd1);
        // PLOGI.printf("Backup Hashtable base: %p Hashtable size: %lu\n",
        //              this->backup_hashtable, this->capacity);
      }
      this->ref_cnt++;
    }


    this->empty_item = this->empty_item.get_empty_key();
    this->key_length = empty_item.key_length();
    this->data_length = empty_item.data_length();

    PLOGV << "Empty item: " << this->empty_item;
    this->insert_queue =
        (KVQ *)(aligned_alloc(64, PREFETCH_QUEUE_SIZE * sizeof(KVQ)));
    for (int i = 0; i < PREFETCH_QUEUE_SIZE; i++) {
      this->insert_queue[i].part_id = 0;
    }

    this->find_queue =
        (KVQ *)(aligned_alloc(64, PREFETCH_FIND_QUEUE_SIZE * sizeof(KVQ)));
    for (int i = 0; i < PREFETCH_FIND_QUEUE_SIZE; i++) {
      this->find_queue[i].part_id = 0;
    }

    PLOGV.printf("%s, data_length %lu\n", __func__, this->data_length);
  }

  ~MultiHashTable() {
    free(find_queue);
    free(insert_queue);
    // Deallocate the global hashtable if ref_cnt goes down to zero.
    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);
      this->ref_cnt--;
      if (this->ref_cnt == 0) {
        free_mem<KV>(this->hashtable, this->capacity, this->id, this->fd);
        this->hashtable = nullptr;
        // free_mem<KV>(this->backup_hashtable, this->capacity, this->id1,
        //              this->fd1);
        // this->backup_hashtable = nullptr;
      }
    }
  }

  void prefetch_queue(QueueType qtype) override {}

  void insert_noprefetch(const void *data, collector_type *collector) override {
#ifdef LATENCY_COLLECTION
    const auto timer_start = collector->sync_start();
#endif

    uint64_t hash = this->hash((const char *)data);
    size_t idx = hash & (this->capacity - 1);  // modulo
    // size_t idx = fastrange32(hash, this->capacity);  // modulo

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

#ifdef LATENCY_COLLECTION
    collector->sync_end(timer_start);
#endif
  }

  bool insert(const void *data) {
    cout << "Not implemented!" << endl;
    assert(false);
    return false;
  }

  // insert a batch
  void insert_batch(const InsertFindArguments &kp,
                    collector_type *collector) override {
    this->flush_if_needed(collector);

    for (auto &data : kp) {
      add_to_insert_queue(&data, collector);
    }

    this->flush_if_needed(collector);
  }

  // overridden function for insertion
  void flush_if_needed(collector_type *collector) {
    size_t curr_queue_sz =
        (this->ins_head - this->ins_tail) & (PREFETCH_QUEUE_SIZE - 1);

    while (curr_queue_sz >= INS_FLUSH_THRESHOLD) {
      __insert_one(&this->insert_queue[this->ins_tail], collector);

      if (++this->ins_tail >= PREFETCH_QUEUE_SIZE) this->ins_tail = 0;
      curr_queue_sz =
          (this->ins_head - this->ins_tail) & (PREFETCH_QUEUE_SIZE - 1);
    }
    return;
  }

  void flush_insert_queue(collector_type *collector) override {
    size_t curr_queue_sz =
        (this->ins_head - this->ins_tail) & (PREFETCH_QUEUE_SIZE - 1);

    while (curr_queue_sz != 0) {
      __insert_one(&this->insert_queue[this->ins_tail], collector);
      if (++this->ins_tail >= PREFETCH_QUEUE_SIZE) this->ins_tail = 0;
      curr_queue_sz =
          (this->ins_head - this->ins_tail) & (PREFETCH_QUEUE_SIZE - 1);
    }
  }

  void flush_find_queue(ValuePairs &vp, collector_type *collector) override {
    size_t curr_queue_sz =
        (this->find_head - this->find_tail) & (PREFETCH_FIND_QUEUE_SIZE - 1);

    while ((curr_queue_sz != 0) && (vp.first < config.batch_len)) {
      __find_one(&this->find_queue[this->find_tail], vp, collector);
      if (++this->find_tail >= PREFETCH_FIND_QUEUE_SIZE) this->find_tail = 0;
      curr_queue_sz =
          (this->find_head - this->find_tail) & (PREFETCH_FIND_QUEUE_SIZE - 1);
    }
  }

  void flush_if_needed(ValuePairs &vp, collector_type *collector) {
    size_t curr_queue_sz =
        (this->find_head - this->find_tail) & (PREFETCH_FIND_QUEUE_SIZE - 1);
    // make sure you return at most batch_sz (but can possibly return lesser
    // number of elements)

    if((curr_queue_sz >= FLUSH_THRESHOLD) && (vp.first < config.batch_len))
    {
      __builtin_prefetch(&curr_queue_sz, true, 3);
      __builtin_prefetch(&this->find_tail, true, 3);
    }

    while ((curr_queue_sz >= FLUSH_THRESHOLD) && (vp.first < config.batch_len)) {
      __find_one(&this->find_queue[this->find_tail], vp, collector);
      if (++this->find_tail >= PREFETCH_FIND_QUEUE_SIZE) {
        this->find_tail = 0;
      }
      curr_queue_sz =
          (this->find_head - this->find_tail) & (PREFETCH_FIND_QUEUE_SIZE - 1);
    }
    return;
  }

  void find_batch(const InsertFindArguments &kp, ValuePairs &values,
                  collector_type *collector) override {
    this->flush_if_needed(values, collector);

    for (auto &data : kp) {
      add_to_find_queue(&data, collector);
      // prefetch next line, 
      // do find here
    }

    this->flush_if_needed(values, collector);
  }

  void *find_noprefetch(const void *data, collector_type *collector) override {
#ifdef CALC_STATS
    uint64_t distance_from_bucket = 0;
#endif
#ifdef LATENCY_COLLECTION
    const auto timer_start = collector->sync_start();
#endif

    uint64_t hash = this->hash((const char *)data);
    size_t idx = hash;
    // size_t idx = fastrange32(hash, this->capacity);  // modulo
    InsertFindArgument *item = const_cast<InsertFindArgument *>(
        reinterpret_cast<const InsertFindArgument *>(data));
    KV *curr;
    bool found = false;

    // printf("Thread %" PRIu64 ": Trying memcmp at: %" PRIu64 "\n",
    // this->thread_id, idx);
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
#ifdef LATENCY_COLLECTION
    collector->sync_end(timer_start);
#endif

    // return empty_element if nothing is found
    if (!found) {
      printf("key %" PRIu64 " not found at idx %" PRIu64 " | hash %" PRIu64
             "\n",
             item->key, idx, hash);
      curr = nullptr;
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

  size_t get_lvl1_fill() {
    size_t count = 0;
    for (size_t i = 0; i < lvl1_capacity; i++) {
      if (!backup_hashtable[i].is_empty()) {
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
  uint64_t lvl0_capacity;
  uint64_t lvl1_capacity;
  KV empty_item;
  KVQ *find_queue;
  KVQ *insert_queue;
  uint32_t find_head;
  uint32_t find_tail;
  uint32_t ins_head;
  uint32_t ins_tail;
  Hasher hasher_;

  uint64_t hash(const void *k) { return hasher_(k, this->key_length); }

  void prefetch(uint64_t i) {
#if defined(PREFETCH_WITH_PREFETCH_INSTR)
    prefetch_object<true /* write */>(
        &this->hashtable[i & (lvl0_capacity - 1)],
        sizeof(this->hashtable[i & (lvl0_capacity - 1)]));
    // true /*write*/);
#endif

#if defined(PREFETCH_WITH_WRITE)
    prefetch_with_write(&this->hashtable[i & (this->capacity - 1)]);
#endif
  };

  inline void prefetch_backup(uint64_t i) {
    prefetch_object<true>(
        &this->backup_hashtable[i & (lvl1_capacity - 1)],
        sizeof(this->backup_hashtable[i & (lvl1_capacity - 1)]));
  }

  inline void prefetch_read_backup(uint64_t i) {
    prefetch_object<false>(
        &this->backup_hashtable[i & (lvl1_capacity - 1)],
        sizeof(this->backup_hashtable[i & (lvl1_capacity - 1)]));
  }

  void ht_prefetch_write(uint64_t i, size_t ht_level) {
    if (ht_level == 0) {
      prefetch_object<true /* write */>(
          &this->hashtable[i & (lvl0_capacity - 1)],
          sizeof(this->hashtable[i & (lvl0_capacity - 1)]));
      // true /*write*/);
    } else {
      prefetch_object<true /* write */>(
          &this->backup_hashtable[i & (lvl1_capacity - 1)],
          sizeof(this->backup_hashtable[i & (lvl1_capacity - 1)]));
      // true /*write*/);
    }
  };

  void ht_prefetch_read(uint64_t i, size_t ht_level) {
    if (ht_level == 0) {
      prefetch_object<false /* write */>(
          &this->hashtable[i & (lvl0_capacity - 1)],
          sizeof(this->hashtable[i & (lvl0_capacity - 1)]));
      // true /*write*/);
    } else {
      prefetch_object<false /* write */>(
          &this->backup_hashtable[i & (lvl1_capacity - 1)],
          sizeof(this->backup_hashtable[i & (lvl1_capacity - 1)]));
      // true /*write*/);
    }
  };

  void prefetch_read(uint64_t i) {
    prefetch_object<false /* write */>(
        &this->hashtable[i & (lvl0_capacity - 1)],
        sizeof(this->hashtable[i & (lvl0_capacity - 1)]));
  }


  inline void __add_to_findqueue(KVQ *q, size_t idx) 
  {
    this->prefetch_read_backup(idx);
    this->find_queue[this->find_head].idx = idx;
    this->find_queue[this->find_head].key = q->key;
    this->find_queue[this->find_head].key_id = q->key_id;
    this->find_queue[this->find_head].part_id = 1;
    this->find_head += 1;
    this->find_head &= (PREFETCH_FIND_QUEUE_SIZE - 1);
  }

#ifdef AVX_SUPPORT 
  uint64_t __find_simd_level1(KVQ *q, ValuePairs &vp) {

    uint64_t retry;
    size_t idx = q->idx;
    idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);
    size_t offset = q->idx - idx;

    KV *curr_cacheline = &this->backup_hashtable[idx];
    uint64_t found = curr_cacheline->find_simd(q, &retry, vp, offset);

    if (retry) {
      idx += CACHELINE_SIZE / sizeof(KV);
      idx = idx & (lvl1_capacity - 1);
      this->prefetch_read_backup(idx);
      this->find_queue[this->find_head].key = q->key;
      this->find_queue[this->find_head].key_id = q->key_id;
      this->find_queue[this->find_head].idx = idx;
      this->find_queue[this->find_head].part_id = 1;

#ifdef LATENCY_COLLECTION
      this->find_queue[this->find_head].timer_id = q->timer_id;
#endif
      this->find_head += 1;
      this->find_head &= (PREFETCH_FIND_QUEUE_SIZE - 1);
    }
    return found;

    // size_t idx = q->idx;
    // KV *entry = &this->backup_hashtable[idx];

    // while (1) {
      
    //   if (entry->is_empty()) {
    //     return 0;
    //   }

    //   if (entry->compare_key(q)) {
    //     vp.second[vp.first].id = q->key_id;
    //     vp.second[vp.first].value = entry->kvpair.value;
    //     vp.first++;
    //     return 1;
    //   }

    //   idx++;
    //   idx = idx & (lvl1_capacity - 1);
      
    //   if ((idx & KEYS_IN_CACHELINE_MASK) == 0) break;

    //   entry = &this->backup_hashtable[idx];
    // }

    // __add_to_findqueue(q, idx);
    // return 0;


  }// end findsimdlvl1

  inline uint64_t __find_simd_level0(KVQ *q, ValuePairs &vp) {
    size_t idx = q->idx;
    idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);
    size_t offset = idx - q->idx;

    KV *entry = &this->hashtable[idx];
    uint64_t retry;
    uint64_t found = entry->find_simd(q, &retry, vp, offset);
    
    if(retry) {
      __add_to_findqueue(q, q->idx);
    }

    return found; 
  }

  uint64_t __find_simd(KVQ *q, ValuePairs &vp) {
    if(q->part_id == 0) 
      return __find_simd_level0(q, vp);
    return __find_simd_level1(q,vp);
  }
#endif

  // TODO.
  uint64_t __find_branched(KVQ *q, ValuePairs &vp, collector_type *collector) {
    // hashtable idx where the data should be found
    size_t idx = q->idx;
    uint64_t found = 0;

  try_find:
    KV *curr = &this->hashtable[idx];
    uint64_t retry;
    found = curr->find(q, &retry, vp);

    // printf("%s, key = %" PRIu64 " | num_values %u, value %" PRIu64 " (id = %"
    // PRIu64 ") | found=%ld, retry %ld\n",
    //          __func__, q->key, vp.first, vp.second[(vp.first - 1) %
    //                  PREFETCH_FIND_QUEUE_SIZE].value, vp.second[(vp.first -
    //                  1) % PREFETCH_FIND_QUEUE_SIZE].id, found, retry);
    if (retry) {
      // insert back into queue, and prefetch next bucket.
      // next bucket will be probed in the next run
      idx++;
      idx = idx & (this->capacity - 1);  // modulo

      // If idx still on a cacheline, keep looking until idx spill over
      if ((idx & KEYS_IN_CACHELINE_MASK) != 0) {
        goto try_find;
      }

      // key is at a different cacheline, prefetch and delay the find
      this->prefetch_read(idx);

      this->find_queue[this->find_head].key = q->key;
      this->find_queue[this->find_head].key_id = q->key_id;
      this->find_queue[this->find_head].idx = idx;
#ifdef LATENCY_COLLECTION
      this->find_queue[this->find_head].timer_id = q->timer_id;
#endif

      this->find_head += 1;
      this->find_head &= (PREFETCH_FIND_QUEUE_SIZE - 1);
#ifdef CALC_STATS
      this->sum_distance_from_bucket++;
#endif
    } else {
#ifdef LATENCY_COLLECTION
      collector->end(q->timer_id);
#endif
    }

    return found;
  }

  auto __find_one(KVQ *q, ValuePairs &vp, collector_type *collector) {
    if (q->key == this->empty_item.get_key()) {
      return __find_empty(q, vp);
    }

    if constexpr (branching == BRANCHKIND::WithBranch) {
      return __find_branched(q, vp, collector);
    } else if constexpr (branching == BRANCHKIND::NoBranch_Simd) {
#ifdef AVX_SUPPORT
      return __find_simd(q, vp);
#endif
    }
  }

  /// Update or increment the empty key.
  uint64_t __find_empty(KVQ *q, ValuePairs &vp) {
    if (empty_slot_exists_) {
      vp.second[vp.first].id = q->key_id;
      vp.second[vp.first].value = empty_slot_;
      vp.first++;
    }
    return empty_slot_;
  }


  inline void __insert_branched_l0(KVQ *q, collector_type *collector)
  {
    // hashtable idx at which data is to be inserted

    size_t idx = q->idx;
    idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);  
  try_insert:
    KV *curr = &this->hashtable[idx];

    // hashtable_mutexes[pidx].lock();
    // printf("Thread %" PRIu64 ", grabbing lock: %" PRIu64 "\n",
    // this->thread_id, pidx); Compare with empty element
    if (curr->is_empty()) {
      // std::cout << "insert_cas k " << q->key << " : " << q->value << "\n";
      bool cas_res = curr->insert_cas(q);
      if (cas_res) {
        return;
      }
      // hashtable_mutexes[pidx].unlock();
      // printf("Thread %" PRIu64 ", released lock: %" PRIu64 "\n",
      // this->thread_id, pidx); printf("%" PRIu64 ": %d | %d\n", pidx,
      // hashtable[pidx].kb.count, no_ins++); If CAS fails, we need to see if
      // someother thread has updated the same <k,v> onto the position we were
      // trying to insert. If so, we need to update the value instead of
      // inserting new. Just fall-through to check!
    }

    {
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
    idx = idx & (lvl0_capacity - 1);  // modulo

    // |  CACHELINE_SIZE   |
    // | 0 | 1 | . | . | n | n+1 ....
    if ((idx & KEYS_IN_CACHELINE_MASK) != 0) {
      goto try_insert;  // FIXME: @David get rid of the goto for crying out loud
    }


    size_t queue_idx = q->idx  & (lvl1_capacity - 1);
    //prefetch write
    prefetch_object<true>(
      &this->backup_hashtable[queue_idx],
      sizeof(this->backup_hashtable[queue_idx]));

    this->insert_queue[this->ins_head].key = q->key;
    this->insert_queue[this->ins_head].key_id = q->key_id;
    this->insert_queue[this->ins_head].value = q->value;
    this->insert_queue[this->ins_head].idx = queue_idx;
    this->insert_queue[this->ins_head].part_id = 1;

    ++this->ins_head;
    this->ins_head &= (PREFETCH_QUEUE_SIZE - 1);

    return;

    // size_t idx = q->idx;
    // KV *curr = &this->hashtable[idx];
    // idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);    

    // // Try find in the cachline
    // while (1) {
    //   if (curr->is_empty() && curr->insert_cas(q)) {
    //     return;
    //   }

    //   if (curr->compare_key(q) && curr->update_cas(q)) {
    //     return;
    //   }

    //   idx++;
    //   idx = idx & (lvl0_capacity - 1);

    //   if ((idx & KEYS_IN_CACHELINE_MASK) == 0) {
    //     break;
    //   }
    // }

    // // Not found,
    // // determine idx to fetch, if level 0, use original hash idx, if level 1,
    // // use accumulated idx
    // size_t queue_idx = q->idx;
    // prefetch_read_backup(queue_idx);
    // this->insert_queue[this->ins_head].idx = queue_idx;
    // this->insert_queue[this->ins_head].key = q->key;
    // this->insert_queue[this->ins_head].key_id = q->key_id;
    // this->insert_queue[this->ins_head].value = q->value;
    // this->insert_queue[this->ins_head].part_id = 1;
    // ++this->ins_head;
    // this->ins_head &= (PREFETCH_QUEUE_SIZE - 1);

  }// end l0 find

  void __insert_branched_l1(KVQ *q, collector_type *collector) {
    // hashtable idx at which data is to be inserted

    size_t idx = q->idx;
  try_insert_lvl1:
    KV *curr = &this->backup_hashtable[idx];

    // hashtable_mutexes[pidx].lock();
    // printf("Thread %" PRIu64 ", grabbing lock: %" PRIu64 "\n",
    // this->thread_id, pidx); Compare with empty element
    if (curr->is_empty()) {
      // std::cout << "insert_cas k " << q->key << " : " << q->value << "\n";
      bool cas_res = curr->insert_cas(q);
      if (cas_res) {
        return;
      }
      // hashtable_mutexes[pidx].unlock();
      // printf("Thread %" PRIu64 ", released lock: %" PRIu64 "\n",
      // this->thread_id, pidx); printf("%" PRIu64 ": %d | %d\n", pidx,
      // hashtable[pidx].kb.count, no_ins++); If CAS fails, we need to see if
      // someother thread has updated the same <k,v> onto the position we were
      // trying to insert. If so, we need to update the value instead of
      // inserting new. Just fall-through to check!
    }

    {
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
    idx = idx & (lvl1_capacity - 1);  // modulo

    // |  CACHELINE_SIZE   |
    // | 0 | 1 | . | . | n | n+1 ....
    if ((idx & KEYS_IN_CACHELINE_MASK) != 0) {
      goto try_insert_lvl1;  // FIXME: @David get rid of the goto for crying out loud
    }

    //prefetch write
    prefetch_object<true>(
      &this->backup_hashtable[idx & (lvl1_capacity - 1)],
      sizeof(this->backup_hashtable[idx & (lvl1_capacity - 1)]));

    this->insert_queue[this->ins_head].key = q->key;
    this->insert_queue[this->ins_head].key_id = q->key_id;
    this->insert_queue[this->ins_head].value = q->value;
    this->insert_queue[this->ins_head].idx = idx;
    this->insert_queue[this->ins_head].part_id = 1;
    ++this->ins_head;
    this->ins_head &= (PREFETCH_QUEUE_SIZE - 1);
    // printf("Current fill: %d Max fill: %d\n",get_lvl1_fill(), lvl1_capacity);

    return;
/////////////////////////////////////////////////////////////////////
    // if(get_lvl1_fill() >= lvl1_capacity-1) 
    // {
    //   printf("Current fill: %d Max fill: %d\n",get_lvl1_fill(), lvl1_capacity);
    //  exit(-1);
    // }
    // size_t idx = q->idx;
    // KV *curr = &this->backup_hashtable[idx];


    // printf("Key %lu ID %lu\n", q->key, q->key_id);

    // // Try find in the cachline
    // while (1) {
    //   if (curr->is_empty() && curr->insert_cas(q)) {
    //     return;
    //   }

    //   if (curr->compare_key(q) && curr->update_cas(q)) {
    //     return;
    //   }

    //   idx++;
    //   idx = idx & (lvl1_capacity - 1);


    //   if ((idx & KEYS_IN_CACHELINE_MASK) == 0) {
    //     break;
    //   }
    // }

    // // Not found,
    // // determine idx to fetch, if level 0, use original hash idx, if level 1,
    // // use accumulated idx
    // size_t queue_idx = idx;

    // prefetch_read_backup(queue_idx);
    // this->insert_queue[this->ins_head].idx = queue_idx;
    // this->insert_queue[this->ins_head].key = q->key;
    // this->insert_queue[this->ins_head].key_id = q->key_id;
    // this->insert_queue[this->ins_head].value = q->value;
    // this->insert_queue[this->ins_head].part_id = 1;
    // ++this->ins_head;
    // this->ins_head &= (PREFETCH_QUEUE_SIZE - 1);
  }

  /*
   The primary hashtable needs to be cache line aligned.
   The backup hashtable doesn't need to be cahceline aligned.
  */
  void __insert_branched(KVQ *q, collector_type *collector) {
    if(q->part_id == 0)
      __insert_branched_l0(q, collector);
    else
      __insert_branched_l1(q, collector);
  }

  void __insert_one(KVQ *q, collector_type *collector) {
    if (q->key == this->empty_item.get_key()) {
      __insert_empty(q);
    } else {
      __insert_branched(q, collector);
    }
  }

  /// Update or increment the empty key.
  void __insert_empty(KVQ *q) {
    if constexpr (std::is_same_v<KV, Item>) {
      empty_slot_ = q->value;
    } else if constexpr (std::is_same_v<KV, Aggr_KV>) {
      empty_slot_ += q->value;
    } else {
      assert(false && "Invalid template type");
    }
    empty_slot_exists_ = true;
  }

  uint64_t read_hashtable_element(const void *data) override {
    PLOG_FATAL << "Not implemented";
    assert(false);
    return -1;
  }

  void add_to_insert_queue(void *data, collector_type *collector) {
    InsertFindArgument *key_data = reinterpret_cast<InsertFindArgument *>(data);

#ifdef LATENCY_COLLECTION
    const auto timer = collector->start();
#endif

    uint64_t hash = this->hash((const char *)&key_data->key);
    size_t idx = hash & (lvl0_capacity - 1);
    prefetch(idx);

    this->insert_queue[this->ins_head].idx = idx;
    this->insert_queue[this->ins_head].key = key_data->key;
    this->insert_queue[this->ins_head].value = key_data->value;
    this->insert_queue[this->ins_head].key_id = key_data->id;
    this->insert_queue[this->ins_head].part_id = 0;

#ifdef LATENCY_COLLECTION
    this->insert_queue[this->ins_head].timer_id = timer;
#endif

#ifdef COMPARE_HASH
    this->insert_queue[this->ins_head].key_hash = hash;
#endif

    this->ins_head++;
    if (this->ins_head >= PREFETCH_QUEUE_SIZE) this->ins_head = 0;
  }

  void add_to_find_queue(void *data, collector_type *collector) {
    InsertFindArgument *key_data = reinterpret_cast<InsertFindArgument *>(data);

#ifdef LATENCY_COLLECTION
    const auto timer = collector->start();
#endif

    uint64_t hash = this->hash((const char *)&key_data->key);
    size_t idx = hash & (lvl0_capacity - 1);
    prefetch_read(idx);

    this->find_queue[this->find_head].idx = idx;
    this->find_queue[this->find_head].key = key_data->key;
    this->find_queue[this->find_head].key_id = key_data->id;
    this->find_queue[this->find_head].part_id = 0;

#ifdef LATENCY_COLLECTION
    this->find_queue[this->find_head].timer_id = timer;
#endif

#ifdef COMPARE_HASH
    this->queue[this->find_head].key_hash = hash;
#endif

    this->find_head++;
    if (this->find_head >= PREFETCH_FIND_QUEUE_SIZE) this->find_head = 0;
  }
};

/// Static variables
template <class KV, class KVQ>
KV *MultiHashTable<KV, KVQ>::hashtable = nullptr;

template <class KV, class KVQ>
KV *MultiHashTable<KV, KVQ>::backup_hashtable = nullptr;

template <class KV, class KVQ>
uint64_t MultiHashTable<KV, KVQ>::empty_slot_ = 0;

template <class KV, class KVQ>
bool MultiHashTable<KV, KVQ>::empty_slot_exists_ = false;

template <class KV, class KVQ>
std::mutex MultiHashTable<KV, KVQ>::ht_init_mutex;

template <class KV, class KVQ>
uint32_t MultiHashTable<KV, KVQ>::ref_cnt = 0;
}  // namespace kmercounter

#endif
