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

#include <xmmintrin.h>

#include <cassert>
#include <cstdint>
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

class BuddyBuffer {
 public:
  uint32_t sz;
  uint32_t capacity;
  InsertFindArgument *arr;
  BuddyBuffer(uint32_t capacity) {
    this->capacity = capacity;
    arr = (InsertFindArgument *)aligned_alloc(64, capacity * sizeof(InsertFindArgument));
  }

  bool add(InsertFindArgument *q) {
    if (sz < capacity) {
      arr[sz] = *q;
      sz++;
      return true;
    }

    return false;
  }

  uint32_t size() { return sz; }
};

template <typename KV, typename KVQ>
class CASHashTable : public BaseHashTable {
 public:
  /// The global instance is shared by all threads.
  static KV *hashtable;
  /// A dedicated slot for the empty value.
  static uint64_t empty_slot_;
  /// True if the empty value is inserted.
  static bool empty_slot_exists_;

#ifdef BUDDY_QUEUE
  static BuddyBuffer **buddy_find_queues;
  static BuddyBuffer **buddy_insert_queues;

  BuddyBuffer *buddy_find_queue;
  BuddyBuffer *buddy_insert_queue;

  uint32_t buddy_find_tail;
  uint32_t buddy_find_head;

#endif

  /// File descriptor backs the memory
  int fd;
  int id;
  size_t data_length, key_length;
  const static uint64_t CACHELINE_SIZE = 64;
  const static uint64_t KV_IN_CACHELINE = CACHELINE_SIZE / sizeof(KV);
  const static uint64_t KEYS_IN_CACHELINE_MASK =
      (CACHELINE_SIZE / sizeof(KV)) - 1;

  uint8_t tid;
  uint8_t cpuid;

  uint32_t find_queue_sz;
  uint32_t insert_queue_sz;
  uint32_t INSERT_QUEUE_SZ_MASK;
  uint32_t FIND_QUEUE_SZ_MASK;
  uint64_t HT_BUCKET_MASK;

#define KEYMSK ((__mmask8)(0b01010101))

  CASHashTable(uint64_t c) : CASHashTable(c, 8, 0) {};

  CASHashTable(uint64_t c, uint32_t queue_sz, uint8_t tid)
      : fd(-1), id(1), find_head(0), find_tail(0), ins_head(0), ins_tail(0) {
    this->capacity = kmercounter::utils::next_pow2(c);
    this->find_queue_sz = kmercounter::utils::next_pow2(queue_sz);
    this->insert_queue_sz = find_queue_sz;

    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);

      if (!this->hashtable) {
        assert(this->ref_cnt == 0);
        this->hashtable = calloc_ht<KV>(this->capacity, this->id, &this->fd);
        PLOGI.printf("Hashtable base: %p Hashtable size: %lu", this->hashtable,
                     this->capacity);
        PLOGI.printf("queue item sz: %d", sizeof(KVQ));
#ifdef BUDDY_QUEUE
        // allocate buddy queues
        buddy_find_queues = (BuddyBuffer **)(aligned_alloc(
            64, config.num_threads * sizeof(void *)));

        buddy_insert_queues = (BuddyBuffer **)(aligned_alloc(
            64, config.num_threads * sizeof(void *)));

        for (int i = 0; i < config.num_threads; i++) {
          buddy_find_queues[i] = new BuddyBuffer(queue_sz);
          buddy_insert_queues[i] = new BuddyBuffer(queue_sz);
        }
#endif
      }
      this->ref_cnt++;
    }

#ifdef BUDDY_QUEUE
    // grab the pointer buddy queues
    int buddy_cpu = (tid % 2 == 0) ? tid + 1 : tid - 1;
    buddy_find_queue = buddy_find_queues[buddy_cpu];
    buddy_insert_queue = buddy_insert_queues[buddy_cpu];

#endif

    this->tid = tid;
    this->cpuid = tid >= 28 ? tid - 28 : tid;
    this->empty_item = this->empty_item.get_empty_key();
    this->key_length = empty_item.key_length();
    this->data_length = empty_item.data_length();

    PLOGV << "Empty item: " << this->empty_item;

    this->insert_queue =
        (KVQ *)(aligned_alloc(64, insert_queue_sz * sizeof(KVQ)));
    this->find_queue = (KVQ *)(aligned_alloc(64, find_queue_sz * sizeof(KVQ)));
    this->FIND_QUEUE_SZ_MASK = this->find_queue_sz - 1;
    this->INSERT_QUEUE_SZ_MASK = this->insert_queue_sz - 1;

    this->HT_BUCKET_MASK =
        (uint32_t)((this->capacity - 1) & ~(KEYS_IN_CACHELINE_MASK));
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

  void clear_table() { memset(this->hashtable, 0, capacity * sizeof(KV)); }

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

  inline uint32_t get_insert_queue_sz() {
    return (ins_head - ins_tail) & INSERT_QUEUE_SZ_MASK;
  }

  // overridden function for insertion
  inline void flush_if_needed(collector_type *collector) {
    size_t curr_queue_sz = get_insert_queue_sz();

    while (curr_queue_sz > INS_FLUSH_THRESHOLD) {
      __insert_one(&this->insert_queue[this->ins_tail], collector);
      if (++this->ins_tail >= insert_queue_sz) this->ins_tail = 0;
      curr_queue_sz = get_insert_queue_sz();
    }
    return;
  }

  inline void pop_insert_queue(collector_type *collector) {
    uint64_t retry = 0;
    do {
      uint32_t next_tail = (this->ins_tail + 8) & INSERT_QUEUE_SZ_MASK;
      const void *next_tail_addr =
          &this->hashtable[this->insert_queue[next_tail].idx];
      __builtin_prefetch(next_tail_addr, true, 3);

      // |N  X  T| -> # 64, 64
      retry = __insert_one(&this->insert_queue[this->ins_tail], collector);
      this->ins_tail++;
      this->ins_tail &= INSERT_QUEUE_SZ_MASK;

    } while ((retry));
  }

#if defined(DRAMHiT_2023)

  // insert a batch
  void insert_batch(const InsertFindArguments &kp, collector_type *collector) {
    this->flush_if_needed(collector);

    for (auto &data : kp) {
      add_to_insert_queue(&data, collector);
    }

    this->flush_if_needed(collector);
  }
#elif defined(DRAMHiT_2025)
  void insert_batch(const InsertFindArguments &kp, collector_type *collector) {

#ifdef BUDDY_QUEUE
    uint32_t sz = buddy_insert_queue->size();
    if (sz == config.batch_len) {
      for (int i = 0; i < sz; i++) {
        if ((get_insert_queue_sz() >= INSERT_QUEUE_SZ_MASK)) {
          pop_insert_queue(collector);
        }
        add_to_insert_queue(&(buddy_insert_queue->arr[i]), collector);
      }
      buddy_insert_queue->sz = 0;
    }
#endif

    if ((get_insert_queue_sz() >= INSERT_QUEUE_SZ_MASK)) {
      for (auto &data : kp) {
        pop_insert_queue(collector);
        add_to_insert_queue(&data, collector);
      }
    } else {
      for (auto &data : kp) {
        if ((get_insert_queue_sz() >= INSERT_QUEUE_SZ_MASK)) {
          pop_insert_queue(collector);
        }
        add_to_insert_queue(&data, collector);
      }
    }
  }
#elif defined(DRAMHiT_REMOTE)
  void insert_batch(const InsertFindArguments &kp, collector_type *collector) {
    for (auto &data : kp) {
      if ((get_insert_queue_sz() >= INSERT_QUEUE_SZ_MASK)) {
        pop_insert_queue(collector);
      }

      if ((get_remote_insert_queue_sz() >= REMOTE_INSERT_QUEUE_SZ_MASK)) {
        pop_remote_insert_queue(collector);
      }
      add_to_insert_queue(&data, collector);
    }
  }
#else
  void insert_batch(const InsertFindArguments &kp, collector_type *collector) {
    bool fast_path = (((ins_head - ins_tail) & INSERT_QUEUE_SZ_MASK) >=
                      (insert_queue_sz - 1));
    if (fast_path) {
      for (auto &data : kp) {
        // pop
        {
          uint64_t retry = 0;
          do {
            uint32_t next_tail = (this->ins_tail + 7) & INSERT_QUEUE_SZ_MASK;
            const void *next_tail_addr =
                &this->hashtable[this->insert_queue[next_tail].idx];
            __builtin_prefetch(next_tail_addr, false, 3);

            // retry =
            //     __insert_one(&this->insert_queue[this->ins_tail], collector);
            {
              KVQ *q = &this->insert_queue[this->ins_tail];
              // hashtable idx at which data is to be inserted

              size_t idx = q->idx;
              idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);
              KV *curr;

              // The intuition is, we load a snapshot of a cacheline of keys and
              // see how far ahead we can skip into. It is okay to be outdated
              // with the world, because, that just means we skip less than we
              // could have. We can do this because keys are never deleted in
              // the hashtable.

              // ex. We load a cacheline like this | - , - , 0, 0 |.
              //  The world can update the keys like this during operation | -,
              //  -, X, 0|
              // but it will never remove any of keys.

              uint64_t *bucket = (uint64_t *)&this->hashtable[idx];
              __m512i cacheline = _mm512_load_si512(bucket);

              // Check of the keys exists,
              __m512i key_vector = _mm512_set1_epi64(q->key);
              __mmask8 key_cmp =
                  _mm512_mask_cmpeq_epu64_mask(KEYMSK, cacheline, key_vector);
              if (key_cmp > 0) {
                __mmask8 offset = _bit_scan_forward(key_cmp);
                bucket[(offset + 1)] = q->value;
                retry = 0;
                this->ins_tail++;
                this->ins_tail &= INSERT_QUEUE_SZ_MASK;
                continue;
              }

              // Check for empty slot
              __m512i zero_vector = _mm512_setzero_si512();
              __mmask8 ept_cmp =
                  _mm512_mask_cmpeq_epu64_mask(KEYMSK, cacheline, zero_vector);
              if (ept_cmp != 0) {
                idx += (_bit_scan_forward(ept_cmp) >> 1);
              } else {
                idx += 4;
                goto add_to_queue;
              }

            try_insert:
              curr = &this->hashtable[idx];

              if (curr->is_empty()) {
                bool cas_res = curr->insert_cas(q);
                if (cas_res) {
#ifdef CALC_STATS
                  this->num_memcpys++;
#endif

#ifdef LATENCY_COLLECTION
                  collector->end(q->timer_id);
#endif

                  retry = 0;
                  this->ins_tail++;
                  this->ins_tail &= INSERT_QUEUE_SZ_MASK;
                  continue;
                }
              }

#ifdef CALC_STATS
              this->num_hashcmps++;
#endif

#ifdef CALC_STATS
              this->num_memcmps++;
#endif
              if (curr->compare_key(q)) {
                curr->update_cas(q);

#ifdef LATENCY_COLLECTION
                collector->end(q->timer_id);
#endif
                retry = 0;
                this->ins_tail++;
                this->ins_tail &= INSERT_QUEUE_SZ_MASK;
                continue;
              }

              /* insert back into queue, and prefetch next bucket.
              next bucket will be probed in the next run
              */
              idx++;
              idx = idx & (this->capacity - 1);  // modulo

              // |  CACHELINE_SIZE   |
              // | 0 | 1 | . | . | n | n+1 ....
              if ((idx & KEYS_IN_CACHELINE_MASK) != 0) {
                goto try_insert;  // FIXME: @David get rid of the goto for
                                  // crying out loud
              }
            add_to_queue:

#ifdef UNIFORM_HT_SUPPORT
              uint64_t old_hash = q->key_hash;
              uint64_t hash = this->hash(&old_hash);
              idx = hash & (this->capacity - 1);
#ifdef BUCKETIZATION
              idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);
#endif
              this->insert_queue[this->ins_head].key_hash = hash;
#endif
              // prefetch(idx);
              __builtin_prefetch(&this->hashtable[idx], false, 1);

              this->insert_queue[this->ins_head].key = q->key;
              this->insert_queue[this->ins_head].key_id = q->key_id;
              this->insert_queue[this->ins_head].value = q->value;
              this->insert_queue[this->ins_head].idx = idx;

#ifdef LATENCY_COLLECTION
              this->insert_queue[this->ins_head].timer_id = q->timer_id;
#endif

              ++this->ins_head;
              this->ins_head &= INSERT_QUEUE_SZ_MASK;

              retry = 1;
              this->ins_tail++;
              this->ins_tail &= INSERT_QUEUE_SZ_MASK;
              continue;
            }

          } while ((retry));
        }
        // push
        {
          InsertFindArgument *key_data =
              reinterpret_cast<InsertFindArgument *>(&data);

#ifdef LATENCY_COLLECTION
          const auto timer = collector->start();
#endif

          uint64_t hash = this->hash((const char *)&key_data->key);
          size_t idx = hash & (this->capacity - 1);
          idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);

          // prefetch(idx);
          __builtin_prefetch(&this->hashtable[idx], false, 1);

          this->insert_queue[this->ins_head].idx = idx;
          this->insert_queue[this->ins_head].key = key_data->key;
          this->insert_queue[this->ins_head].key_id = key_data->id;
          this->insert_queue[this->ins_head].value = key_data->value;

#ifdef UNIFORM_HT_SUPPORT
          this->insert_queue[this->ins_head].key_hash = hash;
#endif

#ifdef LATENCY_COLLECTION
          this->insert_queue[this->ins_head].timer_id = timer;
#endif

          this->ins_head += 1;
          this->ins_head &= INSERT_QUEUE_SZ_MASK;
        }
      }

    } else {
      for (auto &data : kp) {
        if (((ins_head - ins_tail) & INSERT_QUEUE_SZ_MASK) >=
            (insert_queue_sz - 1)) {
          pop_insert_queue(collector);
        }
        add_to_insert_queue(&data, collector);
      }
    }  // end slow path
  }  // end insert unrolled

#endif
  // __attribute__((noinline)) void insert_batch_max_test(
  //     InsertFindArgument *kp, collector_type *collector) {
  //   uint64_t reg;
  //   __m64 kv = _mm_setzero_si64();
  //   uint64_t base_addr = (uint64_t)this->hashtable;
  //   uint64_t lenmsk = this->capacity - 1;
  //   for (int i = 0; i < config.batch_len; i++) {
  //     reg = _mm_crc32_u64(0xffffffff, kp[i].key);
  //     reg = reg & lenmsk;
  //     reg = reg << 4;
  //     reg = base_addr + reg;
  //     _mm_stream_si64((long long int *)(reg), (long long int)kv);
  //     //_mm_sfence();
  //   }
  // }

  void flush_insert_queue(collector_type *collector) override {
    size_t curr_queue_sz =
        (this->ins_head - this->ins_tail) & INSERT_QUEUE_SZ_MASK;

    while (curr_queue_sz != 0) {
      __insert_one(&this->insert_queue[this->ins_tail], collector);
      if (++this->ins_tail >= insert_queue_sz) this->ins_tail = 0;
      curr_queue_sz = (this->ins_head - this->ins_tail) & INSERT_QUEUE_SZ_MASK;
    }

    // all store must be flushed.
    _mm_sfence();
  }

  void flush_find_queue(ValuePairs &vp, collector_type *collector) override {
    size_t curr_queue_sz =
        (this->find_head - this->find_tail) & (find_queue_sz - 1);

    while ((curr_queue_sz != 0) && (vp.first < config.batch_len)) {
      __find_one(&this->find_queue[this->find_tail], vp, collector);
      if (++this->find_tail >= find_queue_sz) this->find_tail = 0;
      curr_queue_sz = (this->find_head - this->find_tail) & (find_queue_sz - 1);
    }
  }

  inline size_t get_find_queue_sz() {
    return (this->find_head - this->find_tail) & FIND_QUEUE_SZ_MASK;
  }

  inline void flush_if_needed(ValuePairs &vp, collector_type *collector) {
    size_t curr_queue_sz =
        (this->find_head - this->find_tail) & FIND_QUEUE_SZ_MASK;

    while ((curr_queue_sz > FLUSH_THRESHOLD) && (vp.first < config.batch_len)) {
      __find_one(&this->find_queue[this->find_tail], vp, collector);
      if (++this->find_tail >= find_queue_sz) {
        this->find_tail = 0;
      }
      curr_queue_sz = get_find_queue_sz();
    }
    return;
  }

  inline void pop_find_queue(ValuePairs &vp, collector_type *collector) {
    uint64_t retry = 0;
    do {
      retry = __find_one(&this->find_queue[this->find_tail], vp, collector);
      this->find_tail++;
      this->find_tail &= FIND_QUEUE_SZ_MASK;
      __builtin_prefetch(
          &this->hashtable[this->find_queue[this->find_tail].idx], false, 3);
    } while ((retry));
  }

#if defined(DRAMHiT_2023)
  void find_batch(const InsertFindArguments &kp, ValuePairs &values,
                  collector_type *collector) {
    this->flush_if_needed(values, collector);

    for (auto &data : kp) {
      add_to_find_queue(&data, collector);
    }

    this->flush_if_needed(values, collector);
  }

#elif defined(DRAMHiT_2025)
  // trickery: we return at most batch sz things due to pop_find_queue.
  void find_batch(const InsertFindArguments &kp, ValuePairs &values,
                  collector_type *collector) {
    // if buddy_find_queue.size() > X { }

    if ((get_find_queue_sz() >= FIND_QUEUE_SZ_MASK)) {
      for (auto &data : kp) {
        pop_find_queue(values, collector);
        add_to_find_queue(&data, collector);
      }
    } else {
      for (auto &data : kp) {
        if ((get_find_queue_sz() >= FIND_QUEUE_SZ_MASK)) {
          pop_find_queue(values, collector);
        }
        add_to_find_queue(&data, collector);
      }
    }
  }
#else
  void find_batch(const InsertFindArguments &kp, ValuePairs &vp,
                  collector_type *collector) {
    bool fast_path = ((this->find_head - this->find_tail) &
                      FIND_QUEUE_SZ_MASK) >= (find_queue_sz - 1);
    // fast path
    if (fast_path) [[likely]] {
      __m512i zero_vector = _mm512_setzero_si512();
      uint32_t tail = this->find_tail;
      uint32_t head = this->find_head;
      uint32_t not_found = 0;
      FindResult *vp_result = vp.second;
      uint64_t key;
      uint64_t *bucket;
      __m512i key_vector;
      __m512i cacheline;
      __mmask8 key_cmp;
      KVQ *q;
      uint64_t hash;
      // c++ iterator is faster than a regular integer loop.
      for (auto &data : kp) {
      retry:

        // Prefetch next tail bucket
        uint32_t next_tail = (tail + 7) & FIND_QUEUE_SZ_MASK;
        const void *next_tail_addr =
            &this->hashtable[this->find_queue[next_tail].idx];
        __builtin_prefetch(next_tail_addr, false, 3);

        q = &this->find_queue[tail];
        uint32_t idx = q->idx;
        key = q->key;

        bucket = (uint64_t *)&this->hashtable[idx];
        key_vector = _mm512_set1_epi64(key);
        // cacheline = _mm512_set1_epi64(key);
        cacheline = _mm512_load_si512(bucket);

        key_cmp = _mm512_mask_cmpeq_epu64_mask(KEYMSK, cacheline, key_vector);
        // update tails before we enter branching.
        tail = (tail + 1) & FIND_QUEUE_SZ_MASK;

        if (key_cmp > 0) {
          __mmask8 offset = _bit_scan_forward(key_cmp);
          vp_result->value = bucket[(offset + 1)];
          vp_result->id = q->key_id;
          vp_result++;
        } else {
          __mmask8 ept_cmp =
              _mm512_mask_cmpeq_epu64_mask(KEYMSK, cacheline, zero_vector);

          // if ept found ept_cmp > 0, then we stop retry
          if (ept_cmp == 0) {  // retry
#ifdef CALC_STATS
            this->num_reprobes++;
#endif

#ifdef UNIFORM_HT_SUPPORT
            hash = _mm_crc32_u64(
                0xffffffff,
                *static_cast<const std::uint64_t *>(&(q->key_hash)));
            idx = hash & HT_BUCKET_MASK;
#else
            idx += CACHELINE_SIZE / sizeof(KV);
            idx = idx & HT_BUCKET_MASK;
#endif
            __builtin_prefetch(&this->hashtable[idx], false, 1);

#ifdef UNIFORM_HT_SUPPORT
            this->find_queue[head].key_hash = hash;
#endif
            this->find_queue[head].key = key;
            this->find_queue[head].key_id = q->key_id;
            this->find_queue[head].idx = idx;
#ifdef LATENCY_COLLECTION
            this->find_queue[head].timer_id = q->timer_id;
#endif
            head += 1;
            head &= FIND_QUEUE_SZ_MASK;
            goto retry;
          } else {
            not_found++;
          }
        }

        // add to find queue
        InsertFindArgument *key_data =
            reinterpret_cast<InsertFindArgument *>(&data);

#ifdef LATENCY_COLLECTION
        const auto timer = collector->start();
#endif
        hash = _mm_crc32_u64(
            0xffffffff, *static_cast<const std::uint64_t *>(&key_data->key));
        uint32_t new_idx = hash & HT_BUCKET_MASK;

        __builtin_prefetch(&this->hashtable[new_idx], false, 1);
        this->find_queue[head].key = key_data->key;
        this->find_queue[head].idx = new_idx;
        this->find_queue[head].key_id = key_data->id;

#ifdef UNIFORM_HT_SUPPORT
        this->find_queue[head].key_hash = hash;
#endif

#ifdef LATENCY_COLLECTION
        this->find_queue[head].timer_id = timer;
#endif
        head += 1;
        head &= FIND_QUEUE_SZ_MASK;
      }  // end for loop

      this->find_tail = tail;
      this->find_head = head;
      vp.first += (kp.size() - not_found);
    }  // end of fast path
    else [[unlikely]] {  // slow paths
      for (auto &data : kp) {
        // pop queue
        if (((find_head - find_tail) & FIND_QUEUE_SZ_MASK) >=
            (find_queue_sz - 1)) {
          pop_find_queue(vp, collector);
        }
        add_to_find_queue(&data, collector);
      }
    }
  }  // end unrolled

#endif

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
      // printf("key %" PRIu64 " not found at idx %" PRIu64 " | hash %" PRIu64
      //        "\n",
      //        item->key, idx, hash);
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

  uint64 flush_ht_from_cache() {
    uint64 count = 0;
    for (int j = 0; j < 10; j++)
      // count += this->get_fill();
      for (size_t i = 0; i < this->capacity; i += 4) {
        //   // _mm_clflush(&this->hashtable[i]);
        __builtin_prefetch(&this->hashtable[i], false, 1);
        //   // count += this->hashtable[i].kvpair.key;
        count++;
      }
    // printf("[JOSH] %d\n", count);
    //   return count;
    // constexpr size_t DUMMY_HT_BYTES = 500 * 1024 * 1024;  // 100MB
    // constexpr size_t DUMMY_HT_CAPACITY = DUMMY_HT_BYTES / sizeof(KV);

    // // Allocate
    // KV *dummy_ht = (KV *)malloc(DUMMY_HT_BYTES);
    // assert(dummy_ht != nullptr);

    // // Optional: zero init so we can test fill
    // memset(dummy_ht, 0, DUMMY_HT_BYTES);

    // // Simple is_empty logic
    // auto is_empty = [](const KV &kv) -> bool {
    //   static const KV zero = {};
    //   return memcmp(&kv, &zero, sizeof(KV)) == 0;
    // };

    // // Count non-empty entries
    // size_t count = 0;
    // for (int j = 0; j < 10; j++)
    //   for (size_t i = 0; i < DUMMY_HT_CAPACITY; i++) {
    //     if (!is_empty(dummy_ht[i])) {
    //       count++;
    //     }
    //   }
    // // printf("Dummy HT fill: %lu entries\n", count);

    // // Free
    // free(dummy_ht);

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

  // const __mmask8 KEYMSK = 0b01010101;

  Hasher hasher_;

  uint64_t hash(const void *k) { return hasher_(k, this->key_length); }

  void prefetch(uint64_t i) {
    prefetch_object<true /* write */>(
        &this->hashtable[i & (this->capacity - 1)],
        sizeof(this->hashtable[i & (this->capacity - 1)]));
  }

  // remove &, as it will generate instructions
  void prefetch_read(uint64_t i) {
    prefetch_object<false /* write */>(&this->hashtable[i], 64);

    // we use pref_obj other places in code, probably good to keep it so we
    // only change pref type once
    //  const void* addr = (const void*) &this->hashtable[i];
    //  __builtin_prefetch((const void *)addr, false, 1);
  }

#if defined(AVX_SUPPORT) && defined(BUCKETIZATION)

  uint64_t __find_simd(KVQ *q, ValuePairs &vp) {
    uint64_t retry;
    size_t idx = q->idx;

    KV *curr_cacheline = &this->hashtable[idx];
    uint64_t found = curr_cacheline->find_simd(q, &retry, vp);

    if (retry) {
#ifdef UNIFORM_HT_SUPPORT
      uint64_t old_hash = q->key_hash;
      uint64_t hash = this->hash(&old_hash);
      idx = hash & (this->capacity - 1);
#ifdef BUCKETIZATION
      idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);
#endif
      this->find_queue[this->find_head].key_hash = hash;
#else
      idx += CACHELINE_SIZE / sizeof(KV);
      idx = idx & (this->capacity - 1);
#endif

#ifdef DRAMHiT_2023
      __builtin_prefetch(&this->hashtable[idx], false, 3);
#else
      __builtin_prefetch(&this->hashtable[idx], false, 1);
#endif

      this->find_queue[this->find_head].key = q->key;
      this->find_queue[this->find_head].key_id = q->key_id;
      this->find_queue[this->find_head].idx = idx;
#ifdef LATENCY_COLLECTION
      this->find_queue[this->find_head].timer_id = q->timer_id;
#endif
      this->find_head += 1;
      this->find_head &= (find_queue_sz - 1);
    }

    return retry;
  }

#endif

  uint64_t __find_branchless_cmov(KVQ *q, ValuePairs &vp) {
    // hashtable idx where the data should be found
    size_t idx = q->idx;
    uint64_t found = 0;

  try_find_brless:
    KV *curr = &this->hashtable[idx];
    uint64_t retry;
    found = curr->find_brless(q, &retry, vp);  // find, not find (curr )

    if (retry) {
      // insert back into queue, and prefetch next bucket.
      // next bucket will be probed in the next run
      idx++;
      idx = idx & (this->capacity - 1);  // make sure idx is in the range

      // If idx still on a cacheline, keep looking until idx spill over
      if ((idx & KEYS_IN_CACHELINE_MASK) != 0) {
        goto try_find_brless;
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
      this->find_head &= (find_queue_sz - 1);
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

  uint64_t __find_branched(KVQ *q, ValuePairs &vp, collector_type *collector) {
    // hashtable idx where the data should be found
    size_t idx = q->idx;
    uint64_t found = 0;

  try_find:
    KV *curr = &this->hashtable[idx];
    uint64_t retry;
    found = curr->find(q, &retry, vp);

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
      this->find_head &= (find_queue_sz - 1);
#ifdef CALC_STATS
      this->num_reprobed++;
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
#if defined(CAS_SIMD)
#ifdef AVX_SUPPORT
    return __find_simd(q, vp);
#else
#error "AVX is not supported, compilation failed."
#endif
#else
    return __find_branched(q, vp, collector);
#endif
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

  uint64_t __insert_branched(KVQ *q, collector_type *collector) {
    // hashtable idx at which data is to be inserted

    size_t idx = q->idx;
    KV *curr;

#ifdef CAS_SIMD
    idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);
    // The intuition is, we load a snapshot of a cacheline of keys and see
    // how far ahead we can skip into. It is okay to be outdated with the world,
    // because, that just means we skip less than we could have. We can do this
    // because keys are never deleted in the hashtable.

    // ex. We load a cacheline like this | - , - , 0, 0 |.
    //  The world can update the keys like this during operation | -, -, X, 0|
    // but it will never remove any of keys.

    uint64_t *bucket = (uint64_t *)&this->hashtable[idx];
    __m512i cacheline = _mm512_load_si512(bucket);

    // Check of the keys exists,
    __m512i key_vector = _mm512_set1_epi64(q->key);
    __mmask8 key_cmp =
        _mm512_mask_cmpeq_epu64_mask(KEYMSK, cacheline, key_vector);
    if (key_cmp > 0) {
      __mmask8 offset = _bit_scan_forward(key_cmp);
      bucket[(offset + 1)] = q->value;
      //_mm_stream_si64((long long int *)&bucket[(offset + 1)], (long long
      // int)q->value);
      return 0;
    }

    // Check for empty slot
    __m512i zero_vector = _mm512_setzero_si512();
    __mmask8 ept_cmp =
        _mm512_mask_cmpeq_epu64_mask(KEYMSK, cacheline, zero_vector);
    if (ept_cmp != 0) {
      idx += (_bit_scan_forward(ept_cmp) >> 1);  // |-, -, 0, 0|
    } else {
#ifdef UNIFORM_HT_SUPPORT
      uint64_t old_hash = q->key_hash;
      uint64_t hash = this->hash(&old_hash);
      idx = hash & (this->capacity - 1);
#ifdef BUCKETIZATION
      idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);
#endif
      this->insert_queue[this->ins_head].key_hash = hash;
#else
      idx += 4;
#endif

#ifdef DRAMHiT_2023
      __builtin_prefetch(&this->hashtable[idx], true, 3);

#else
      __builtin_prefetch(&this->hashtable[idx], false, 1);
#endif
      this->insert_queue[this->ins_head].key = q->key;
      this->insert_queue[this->ins_head].key_id = q->key_id;
      this->insert_queue[this->ins_head].value = q->value;
      this->insert_queue[this->ins_head].idx = idx;

#ifdef LATENCY_COLLECTION
      this->insert_queue[this->ins_head].timer_id = q->timer_id;
#endif

      ++this->ins_head;
      this->ins_head &= INSERT_QUEUE_SZ_MASK;

      return 1;
    }
#endif

  try_insert:
    curr = &this->hashtable[idx];

    // insert key
    if (__sync_bool_compare_and_swap((__int128 *)curr, 0, *(__int128 *)q)) {
      return 0;
    }

    // if(curr->key == q->key) {
    //   curr->value = q->value;
    //   return 0;
    // }

    if (curr->compare_key(q)) {
      curr->update_cas(q);

#ifdef LATENCY_COLLECTION
      collector->end(q->timer_id);
#endif
      return 0;
    }

    idx++;
    idx = idx & (this->capacity - 1);  // modulo

    if ((idx & KEYS_IN_CACHELINE_MASK) != 0) {
      goto try_insert;
    }

#ifdef UNIFORM_HT_SUPPORT
    uint64_t old_hash = q->key_hash;
    uint64_t hash = this->hash(&old_hash);
    idx = hash & (this->capacity - 1);
#ifdef BUCKETIZATION
    idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);
#endif
    this->insert_queue[this->ins_head].key_hash = hash;
#endif

#ifdef DRAMHiT_2023
    __builtin_prefetch(&this->hashtable[idx], true, 3);
#else
    __builtin_prefetch(&this->hashtable[idx], false, 1);
#endif

    this->insert_queue[this->ins_head].key = q->key;
    this->insert_queue[this->ins_head].key_id = q->key_id;
    this->insert_queue[this->ins_head].value = q->value;
    this->insert_queue[this->ins_head].idx = idx;

#ifdef LATENCY_COLLECTION
    this->insert_queue[this->ins_head].timer_id = q->timer_id;
#endif

    ++this->ins_head;
    this->ins_head &= INSERT_QUEUE_SZ_MASK;

    return 1;
  }

  uint64_t __insert_one(KVQ *q, collector_type *collector) {
    if (q->key == this->empty_item.get_key()) {
      __insert_empty(q);
      return 0;
    } else {
      return __insert_branched(q, collector);
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

  inline void add_to_find_queue(void *data, collector_type *collector) {
    InsertFindArgument *key_data = reinterpret_cast<InsertFindArgument *>(data);

#ifdef LATENCY_COLLECTION
    const auto timer = collector->start();
#endif

    uint64_t hash = this->hash((const char *)&key_data->key);
    size_t idx = hash & (this->capacity - 1);

#ifdef BUCKETIZATION
    idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);
#endif

#ifdef DRAMHiT_2023
    __builtin_prefetch(&this->hashtable[idx], false, 3);
#else
    __builtin_prefetch(&this->hashtable[idx], false, 1);
#endif
    this->find_queue[this->find_head].idx = idx;
    this->find_queue[this->find_head].key = key_data->key;
    this->find_queue[this->find_head].key_id = key_data->id;

#ifdef UNIFORM_HT_SUPPORT
    this->find_queue[this->find_head].key_hash = hash;
#endif

#ifdef LATENCY_COLLECTION
    this->find_queue[this->find_head].timer_id = timer;
#endif

    this->find_head += 1;
    this->find_head &= FIND_QUEUE_SZ_MASK;
  }

  inline void add_to_insert_queue(void *data, collector_type *collector) {
    InsertFindArgument *key_data = reinterpret_cast<InsertFindArgument *>(data);

#ifdef LATENCY_COLLECTION
    const auto timer = collector->start();
#endif

    uint64_t hash = this->hash((const char *)&key_data->key);
    size_t idx = hash & (this->capacity - 1);
#ifdef BUCKETIZATION
    idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);
#endif

#ifdef BUDDY_QUEUE
    if (is_remote_addr(idx) &&
        buddy_insert_queue->add(key_data)) {
      return;
    }
#endif

#ifdef DRAMHiT_2023
    __builtin_prefetch(&this->hashtable[idx], false, 3);
#else
    __builtin_prefetch(&this->hashtable[idx], false, 1);
#endif
    this->insert_queue[this->ins_head].idx = idx;
    this->insert_queue[this->ins_head].key = key_data->key;
    this->insert_queue[this->ins_head].key_id = key_data->id;
    this->insert_queue[this->ins_head].value = key_data->value;

#ifdef UNIFORM_HT_SUPPORT
    this->insert_queue[this->ins_head].key_hash = hash;
#endif

#ifdef LATENCY_COLLECTION
    this->insert_queue[this->ins_head].timer_id = timer;
#endif

    this->ins_head += 1;
    this->ins_head &= INSERT_QUEUE_SZ_MASK;
  }

#ifdef BUDDY_QUEUE
  bool is_remote_addr(uint64_t idx) {
    // odd tid is node 1, even tid is node 0.
    // lower half is node 0, upper half is node 1
    // xor, value needs to be opposite of each other
    return (tid % 2 == 0) ^ (idx < (this->capacity / 2));
  }

#endif
};

/// Static variables
template <class KV, class KVQ>
KV *CASHashTable<KV, KVQ>::hashtable = nullptr;

#ifdef BUDDY_QUEUE
template <class KV, class KVQ>
BuddyBuffer **CASHashTable<KV, KVQ>::buddy_find_queues = nullptr;

template <class KV, class KVQ>
BuddyBuffer **CASHashTable<KV, KVQ>::buddy_insert_queues = nullptr;
#endif

template <class KV, class KVQ>
uint64_t CASHashTable<KV, KVQ>::empty_slot_ = 0;

template <class KV, class KVQ>
bool CASHashTable<KV, KVQ>::empty_slot_exists_ = false;

template <class KV, class KVQ>
std::mutex CASHashTable<KV, KVQ>::ht_init_mutex;

template <class KV, class KVQ>
uint32_t CASHashTable<KV, KVQ>::ref_cnt = 0;
}  // namespace kmercounter
#endif  // HASHTABLES_CAS_KHT_HPP
