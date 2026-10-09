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

#include <atomic>
#include <cassert>
#include <cstdint>
#include <cstring>
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
#include "xorwow.hpp"

// The find queue uses 16 B entries {key, 32-bit hash, key_id} (CAS_FIND_QUEUE16)
// wherever that is exact: 8 B keys; with uniform probing the probe chain is seeded
// by crc32, whose values are 32 bits. Otherwise (other key sizes or hashers, the
// non-SIMD find, latency collection) the find queue keeps the 32 B ItemQueue.
#if (KEY_LEN == 8) && defined(CAS_SIMD) && !defined(LATENCY_COLLECTION) && \
    (defined(CRC_HASH) || !defined(UNIFORM_HT_SUPPORT))
#define CAS_FIND_QUEUE16
#endif

namespace kmercounter {


template <typename KV, typename KVQ>
class CASHashTable : public BaseHashTable {
 public:
  /// The global instance is shared by all threads.
  static KV *hashtable;
  /// A dedicated slot for the empty value.
  static uint64_t empty_slot_;
  /// True if the empty value is inserted.
  static bool empty_slot_exists_;

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

#ifdef CAS_FIND_QUEUE16
  // 16 B find-queue entry: {key, hash, key_id}. With uniform probing `hash` is the
  // full 32-bit crc32 value (crc32 results are 32 bits, so the 8 B key_hash held
  // nothing more); the bucket index is hash & HT_BUCKET_MASK, and the unmasked
  // value seeds the next probe on a reprobe. With linear probing it holds the
  // bucket index itself. Four entries fill one cache line.
  struct FindQ16 {
    key_type key;
    uint32_t hash;
    uint32_t key_id;
  };
  static_assert(sizeof(FindQ16) == 16 && offsetof(FindQ16, key_id) == 12,
                "16 B find-queue entry");
  using FQE = FindQ16;
#else
  using FQE = KVQ;
#endif

  const static __mmask8 KEYMSK = 0b01010101;
// #define KEYMSK ((__mmask8)(0b01010101))
#define PREFETCH_INSERT_NEXT_DISTANCE 8
// find: how many queue slots ahead the next bucket is prefetched into L1
// (cmake -DFIND_PF_DIST=N; must stay below the find-queue length)
#ifdef FIND_PF_DIST
#define PREFETCH_FIND_NEXT_DISTANCE FIND_PF_DIST
#else
#define PREFETCH_FIND_NEXT_DISTANCE 8
#endif

  CASHashTable(uint64_t c) : CASHashTable(c, 8, 0) {};

  CASHashTable(uint64_t c, uint32_t queue_sz, uint8_t tid)
      : fd(-1), id(1), find_head(0), find_tail(0), ins_head(0), ins_tail(0) {
    this->capacity = kmercounter::utils::next_pow2(c);
    if (capacity % KV_IN_CACHELINE != 0) {
      PLOGE.printf("Capacity %lu is not a multiple of KV_IN_CACHELINE %d\n",
                   capacity, KV_IN_CACHELINE);
      abort();
    }

    this->insert_queue_sz = this->find_queue_sz = queue_sz;

    if (find_queue_sz > 0 && find_queue_sz % 2 != 0) {
      PLOGE.printf("Queue size %lu is not a power of 2\n", find_queue_sz);
      abort();
    }

    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);

      if (!this->hashtable) {
        assert(this->ref_cnt == 0);
        this->hashtable = calloc_ht<KV>(this->capacity, this->id, &this->fd);

        PLOGI.printf(
            "Hashtable base: %p Hashtable size: %lu, %lu GB", this->hashtable,
            this->capacity,
            (this->capacity * sizeof(KV)) / (1024ULL * 1024ULL * 1024ULL));
        PLOGI.printf("queue sz: %lu, queue item sz: %d, find queue item sz: %d",
                     find_queue_sz, sizeof(KVQ), sizeof(FQE));
      }
      this->ref_cnt++;
    }

    this->tid = sched_getcpu();
    this->cpuid = tid >= 28 ? tid - 28 : tid;
    this->empty_item = this->empty_item.get_empty_key();
    this->key_length = empty_item.key_length();
    this->data_length = empty_item.data_length();

    PLOGV << "Empty item: " << this->empty_item;
    this->insert_queue =
        (KVQ *)(aligned_alloc(64, insert_queue_sz * sizeof(KVQ)));
    this->find_queue = (FQE *)(aligned_alloc(64, find_queue_sz * sizeof(FQE)));
    this->FIND_QUEUE_SZ_MASK = this->find_queue_sz - 1;
    this->INSERT_QUEUE_SZ_MASK = this->insert_queue_sz - 1;

    this->HT_BUCKET_MASK =
        (uint32_t)((this->capacity - 1) & ~(KEYS_IN_CACHELINE_MASK));
#ifdef DEEP_VECTORIZATION
    // the deep find path works in steps of 4 arguments
    if (config.batch_len % 4 != 0) {
      PLOGE.printf("DEEP_VECTORIZATION needs a batch length that is a multiple of 4 (got %u)",
                   (unsigned)config.batch_len);
      abort();
    }
#endif
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

  void clear() override { memset(this->hashtable, 0, capacity * sizeof(KV)); }

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
#ifdef CAS_INSERT_PREFETCH_DOUBLE
    uint32_t next_tail;
    const void *next_tail_addr;
#endif
    while (curr_queue_sz > INS_FLUSH_THRESHOLD) {
#ifdef CAS_INSERT_PREFETCH_DOUBLE
      next_tail = (this->ins_tail + PREFETCH_INSERT_NEXT_DISTANCE) &
                  INSERT_QUEUE_SZ_MASK;
      next_tail_addr = &this->hashtable[this->insert_queue[next_tail].idx];
      __builtin_prefetch(next_tail_addr, true, 3);
#endif
      __insert_one(&this->insert_queue[this->ins_tail], collector);
      this->ins_tail++;
      this->ins_tail &= INSERT_QUEUE_SZ_MASK;
      curr_queue_sz = get_insert_queue_sz();
    }
    return;
  }

  inline void pop_insert_queue(collector_type *collector) {
    uint64_t retry = 0;
#ifdef CAS_INSERT_PREFETCH_DOUBLE
    uint32_t next_tail;
    const void *next_tail_addr;
#endif
    do {
#ifdef CAS_INSERT_PREFETCH_DOUBLE
      next_tail = (this->ins_tail + PREFETCH_INSERT_NEXT_DISTANCE) &
                  INSERT_QUEUE_SZ_MASK;
      next_tail_addr = &this->hashtable[this->insert_queue[next_tail].idx];
      __builtin_prefetch(next_tail_addr, true, 3);
#endif
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
#if defined(CAS_NO_ABSTRACT)
  void insert_batch(const InsertFindArguments &kp,
                    collector_type *collector) override {}
  void insert_batch_inline(const InsertFindArguments &kp,
                           collector_type *collector) {
#else
  void insert_batch(const InsertFindArguments &kp, collector_type *collector) {
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

#elif defined(DRAMHiT_2025_INLINED)

#if defined(CAS_NO_ABSTRACT)
  void insert_batch(const InsertFindArguments &kp,
                    collector_type *collector) override {}
  void insert_batch_inline(const InsertFindArguments &kp,
                           collector_type *collector) {
    insert_batch_impl(kp, collector);
  }
#else
  void insert_batch(const InsertFindArguments &kp, collector_type *collector) {
    insert_batch_impl(kp, collector);
  }
#endif
  // 16 B insert arguments {key, value} (not part of the BaseHashTable interface)
  void insert_batch(const InsertArguments &kp, collector_type *collector) {
    insert_batch_impl(kp, collector);
  }

  // The insert fast/slow paths, for either argument type (InsertFindArgument, 24 B, or
  // InsertArgument, 16 B). Inserts return nothing, so the insert queue does not carry
  // an id (ItemQueue::key_id is left unwritten on the insert side).
  template <typename Arg>
  inline __attribute__((always_inline)) void insert_batch_impl(std::span<Arg> kp,
                                                               collector_type *collector) {
    bool fast_path = (((ins_head - ins_tail) & INSERT_QUEUE_SZ_MASK) >=
                      (insert_queue_sz - 1));
    if (fast_path) {
      // TODo lift head and tail out to local var

      uint32_t head = this->ins_head;
      uint32_t tail = this->ins_tail;
      for (auto &data : kp) {
        // pop
        {
          uint64_t retry = 0;
          do {
#ifdef CAS_INSERT_PREFETCH_DOUBLE
            uint32_t next_tail =
                (tail + PREFETCH_INSERT_NEXT_DISTANCE) & INSERT_QUEUE_SZ_MASK;
            const void *next_tail_addr =
                &this->hashtable[this->insert_queue[next_tail].idx];

            __builtin_prefetch(next_tail_addr, true, 3);
#endif
            KVQ *q = &this->insert_queue[tail];

            tail++;
            tail &= INSERT_QUEUE_SZ_MASK;

            {
              // hashtable idx at which data is to be inserted

              size_t idx = q->idx;
              KV *curr;

              uint64_t *bucket = (uint64_t *)&this->hashtable[idx];
              __m512i cacheline = _mm512_load_si512(bucket);

              // Check of the keys exists,
              __m512i key_vector = _mm512_set1_epi64(q->key);
              __mmask8 key_cmp =
                  _mm512_mask_cmpeq_epu64_mask(KEYMSK, cacheline, key_vector);
              if (key_cmp > 0) {
                __mmask8 offset = _bit_scan_forward(key_cmp);
                if constexpr (std::is_same_v<KV, Aggr_KV>) {
                  // This table is shared by every thread, so the count bump
                  // has to be atomic; a plain read-modify-write here loses
                  // updates whenever two threads hit the same key at once.
                  __sync_fetch_and_add(&bucket[(offset + 1)], 1);
                } else {
                  bucket[(offset + 1)] = q->value;
                }
                break;
              }

              // Check for empty slot
              __m512i zero_vector = _mm512_setzero_si512();
              __mmask8 ept_cmp =
                  _mm512_mask_cmpeq_epu64_mask(KEYMSK, cacheline, zero_vector);
              if (ept_cmp != 0) {
                idx += (_bit_scan_forward(ept_cmp) >> 1);
              } else {
                // No empty slot here. Step to the next bucket ourselves, so
                // that every path reaches retry_add_to_queue with idx already
                // pointing at the bucket to probe next.
                idx += KV_IN_CACHELINE;
                idx = idx & (this->capacity - 1);
                goto retry_add_to_queue;
              }

            try_insert:
              curr = &this->hashtable[idx];
#ifdef READ_BEFORE_CAS
              if (curr->is_empty())
#endif
                if (__sync_bool_compare_and_swap((__int128 *)curr, 0,
                                                 empty_slot_payload(q))) {
                  break;
                }

              if (curr->compare_key(q)) {
                curr->update_cas(q);
                break;
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
              // Walked off the end of the bucket: idx is already the next
              // bucket's base, so it must NOT be advanced again below. It used
              // to be, which sent this path to bucket N+2 while the
              // bucket-full path above went to N+1 -- two threads inserting
              // the same key could then probe disjoint buckets, never see each
              // other, and each insert it, leaving one key in two slots.
            retry_add_to_queue:

#ifdef UNIFORM_HT_SUPPORT
              uint64_t old_hash = q->key_hash;
              uint64_t hash = this->hash(&old_hash);
              idx = hash & (this->capacity - 1);
              idx = idx & ~(size_t)KEYS_IN_CACHELINE_MASK;
              this->insert_queue[head].key_hash = hash;
#endif

              prefetch_insert(idx);
              this->insert_queue[head].key = q->key;
              this->insert_queue[head].value = q->value;
              this->insert_queue[head].idx = idx;

#ifdef LATENCY_COLLECTION
              this->insert_queue[head].timer_id = q->timer_id;
#endif

              head++;
              head &= INSERT_QUEUE_SZ_MASK;

              retry = 1;
            }

          } while ((retry));
        }
        // add to insert queue
        {
          Arg *key_data = &data;

#ifdef LATENCY_COLLECTION
          const auto timer = collector->start();
#endif

          uint64_t hash = this->hash((const char *)&key_data->key);
          size_t idx = hash & (this->capacity - 1);

#if defined(BUCKETIZATION)
          idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);
#endif
          prefetch_insert(idx);

          this->insert_queue[head].idx = idx;
          this->insert_queue[head].key = key_data->key;
          this->insert_queue[head].value = key_data->value;

#ifdef UNIFORM_HT_SUPPORT
          this->insert_queue[head].key_hash = hash;
#endif

#ifdef LATENCY_COLLECTION
          this->insert_queue[head].timer_id = timer;
#endif

          head++;
          head &= INSERT_QUEUE_SZ_MASK;
        }
      }

      this->ins_head = head;
      this->ins_tail = tail;

    } else {
      for (auto &data : kp) {
        if (((ins_head - ins_tail) & INSERT_QUEUE_SZ_MASK) >=
            (insert_queue_sz - 1)) {
          pop_insert_queue(collector);
        }
        add_to_insert_queue_t(&data, collector);
      }
    }  // end slow path
  }  // end insert unrolled
#endif

  void flush_insert_queue(collector_type *collector) override {
    size_t curr_queue_sz = get_insert_queue_sz();
    while (curr_queue_sz > 0) {
      pop_insert_queue(collector);
      curr_queue_sz--;
    }

    // all store must be flushed.
    _mm_sfence();
  }

  size_t flush_find_queue(ValuePairs &vp, collector_type *collector) override {
    size_t curr_queue_sz = get_find_queue_sz();
    while ((curr_queue_sz > 0) && (vp.first < config.batch_len)) {
      pop_find_queue(vp, collector);  // gurantee to reduce curr_queue_sz
      curr_queue_sz--;
    }

    return curr_queue_sz;  // how many has been flushed
  }

  inline size_t get_find_queue_sz() {
    return (this->find_head - this->find_tail) & FIND_QUEUE_SZ_MASK;
  }

  void flush_if_needed(ValuePairs &vp, collector_type *collector) {
#ifdef DOUBLE_PREFETCH
    uint32_t next_tail;
    const void *next_tail_addr;
#endif
    size_t curr_queue_sz = get_find_queue_sz();
    while ((curr_queue_sz > FLUSH_THRESHOLD) &&
           (vp.first < config.batch_len)) {  // 32 64 16
#ifdef DOUBLE_PREFETCH
      next_tail =
          (this->find_tail + PREFETCH_FIND_NEXT_DISTANCE) & FIND_QUEUE_SZ_MASK;
      next_tail_addr = &this->hashtable[fq_idx(&this->find_queue[next_tail])];
      __builtin_prefetch(next_tail_addr, false, 3);
#endif

      __find_one(&this->find_queue[this->find_tail], vp, collector);
      this->find_tail++;
      this->find_tail &= FIND_QUEUE_SZ_MASK;
      curr_queue_sz = get_find_queue_sz();
    }
    return;
  }

#ifdef DEEP_VECTORIZATION
  // Deep pop: complete 4 finds -- pop_find_queue x 4, each retrying through reprobes
  // -- and write their results with one 64 B store. The 4 completed entries can be
  // anywhere in the queue (reprobes are pushed back in between), so each hit's value
  // and key_id are loaded on their own and placed in lane k of one register.
  // A not-found completion leaves its lane out (compress store). This is the reference
  // form of the deep pop; find_batch's fast path inlines the same logic with tail and
  // head kept in registers, followed by a 4-argument deep push. Needs >= 4 queued
  // entries and room for 4 results at vp.second + vp.first.
  inline void deep_pop_find_queue(ValuePairs &vp, collector_type *collector) {
    (void)collector;
    const uint32_t bmask = (uint32_t)HT_BUCKET_MASK;
    __m512i res = _mm512_setzero_si512();
    uint32_t found = 0;  // bit k: completion k was a hit (has a result in lane k)
    for (uint32_t k = 0; k < 4; k++) {
      for (;;) {  // until this entry completes (hit or not found)
#ifdef DOUBLE_PREFETCH
        __builtin_prefetch(&this->hashtable[fq_idx(&this->find_queue[(this->find_tail + PREFETCH_FIND_NEXT_DISTANCE) &
                                                                     FIND_QUEUE_SZ_MASK])],
                           false, 3);
#endif
        FQE *const e = &this->find_queue[this->find_tail];
        this->find_tail = (this->find_tail + 1) & FIND_QUEUE_SZ_MASK;
        const __m512i line = _mm512_load_si512(&this->hashtable[fq_idx(e)]);
        const __mmask8 hit = _mm512_mask_cmpeq_epu64_mask(KEYMSK, line, _mm512_set1_epi64(e->key));
        if (hit) {  // {key_id, value} -> lane k: the value is the lane after the key
          const __m128i r = _mm_unpacklo_epi64(
              _mm_cvtsi32_si128((int)e->key_id),
              _mm512_castsi512_si128(_mm512_maskz_compress_epi64(_kshiftli_mask8(hit, 1), line)));
          res = _mm512_mask_broadcast_i32x4(res, (__mmask16)(0xFu << (4 * k)), r);
          found |= 1u << k;
          break;
        }
        if (_mm512_mask_cmpeq_epu64_mask(KEYMSK, line, _mm512_setzero_si512()))  // not found
          break;
        // reprobe: push back with the next hash
#ifdef UNIFORM_HT_SUPPORT
        const uint32_t nh = (uint32_t)_mm_crc32_u64(0xffffffff, (uint64_t)e->hash);
#else
        const uint32_t nh = ((e->hash & bmask) + CACHELINE_SIZE / sizeof(KV)) & bmask;
#endif
        prefetch_read(nh & bmask);
        fq_put(&this->find_queue[this->find_head], e->key, nh, e->key_id);
        this->find_head = (this->find_head + 1) & FIND_QUEUE_SZ_MASK;
#ifdef CALC_STATS
        this->num_reprobes++;
#endif
      }
    }
    FindResult *const out = vp.second + vp.first;
    if (found == 0xF)
      _mm512_storeu_si512(out, res);
    else
      _mm512_mask_compressstoreu_epi64(out, (__mmask8)(_pdep_u32(found, 0x55) * 3), res);
    vp.first += _mm_popcnt_u32(found);
  }
#endif

  inline void pop_find_queue(ValuePairs &vp, collector_type *collector) {
    uint64_t retry = 0;
#ifdef DOUBLE_PREFETCH
    uint32_t next_tail;
    const void *next_tail_addr;
#endif
    do {
#ifdef DOUBLE_PREFETCH
      next_tail =
          (this->find_tail + PREFETCH_FIND_NEXT_DISTANCE) & FIND_QUEUE_SZ_MASK;
      next_tail_addr = &this->hashtable[fq_idx(&this->find_queue[next_tail])];
      __builtin_prefetch(next_tail_addr, false, 3);
#endif
      retry = __find_one(&this->find_queue[this->find_tail], vp, collector);
      this->find_tail++;
      this->find_tail &= FIND_QUEUE_SZ_MASK;

    } while ((retry));
  }

#if defined(DRAMHiT_2023)
  void find_batch(const InsertFindArguments &kp, ValuePairs &values,
                  collector_type *collector) override {
    this->flush_if_needed(values, collector);

    //
    // 1. (curr_queue_sz <= FLUSH_THRESHOLD) and vp.first < FLUSH_THRESHOLD/2
    // 2. (curr_queue_sz > FLUSH_THRESHOLD) and vp.first == FLUSH_THRESHOLD/2,
    // => queue sz < 48.
    //
    for (auto &data : kp) {
      add_to_find_queue(&data, collector);
    }

    this->flush_if_needed(values, collector);
  }

#elif defined(DRAMHiT_2025)

#if defined(CAS_NO_ABSTRACT)
  void find_batch(const InsertFindArguments &kp, ValuePairs &values,
                  collector_type *collector) override {}

  // trickery: we return at most batch sz things due to pop_find_queue.
  void find_batch_inline(const InsertFindArguments &kp, ValuePairs &values,
                         collector_type *collector) {

#else
  void find_batch(const InsertFindArguments &kp, ValuePairs &values,
                  collector_type *collector) {
#endif

#if defined(FAST_PATH)
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
#else
    for (auto &data : kp) {
      if ((get_find_queue_sz() >= FIND_QUEUE_SZ_MASK)) {
        pop_find_queue(values, collector);
      }
      add_to_find_queue(&data, collector);
    }
#endif
  }

#elif defined(DRAMHiT_2025_INLINED)

#if defined(CAS_NO_ABSTRACT)
  void find_batch(const InsertFindArguments &kp, ValuePairs &values,
                  collector_type *collector) override {}

  // trickery: we return at most batch sz things due to pop_find_queue.
  void find_batch_inline(const InsertFindArguments &kp, ValuePairs &vp,
                         collector_type *collector) {
    find_batch_impl(kp, vp, collector);
  }
#else
  void find_batch(const InsertFindArguments &kp, ValuePairs &vp,
                  collector_type *collector) {
    find_batch_impl(kp, vp, collector);
  }
#endif
  // 16 B find arguments {key, -, id} (not part of the BaseHashTable interface)
  void find_batch(const FindArguments &kp, ValuePairs &vp, collector_type *collector) {
    find_batch_impl(kp, vp, collector);
  }

  // The find fast/slow paths, for either argument type (InsertFindArgument, 24 B, or
  // FindArgument, 16 B); both have .key and .id.
  template <typename Arg>
  inline __attribute__((always_inline)) void find_batch_impl(std::span<Arg> kp, ValuePairs &vp,
                                                             collector_type *collector) {
#if defined(DEEP_VECTORIZATION) && \
    !(defined(CAS_FIND_QUEUE16) && defined(CAS_FIND_RING_OFFSETS) && defined(CAS_FIND_COMPRESS_VALUE) && \
      defined(CAS_FIND_KSHIFT) && defined(DOUBLE_PREFETCH))
#error "DEEP_VECTORIZATION needs the 16 B find queue, CAS_FIND_RING_OFFSETS, CAS_FIND_COMPRESS_VALUE, CAS_FIND_KSHIFT and PREFETCH=DOUBLE"
#endif
    bool fast_path = ((this->find_head - this->find_tail) &
                      FIND_QUEUE_SZ_MASK) >= (find_queue_sz - 1);
    // fast path
    if (fast_path) [[likely]] {
#ifdef DEEP_VECTORIZATION
    {
      // ===== deep vectorization: the batch in steps of 4 =====
      __m512i zero_vector = _mm512_setzero_si512();
      // tail/head are byte offsets into find_queue (a slot is base + offset)
      char *const fq_base = reinterpret_cast<char *>(this->find_queue);
      const uint64_t fq_mask = (uint64_t)this->find_queue_sz * sizeof(FQE) - 1;
      uint64_t tail = (uint64_t)this->find_tail * sizeof(FQE);
      uint64_t head = (uint64_t)this->find_head * sizeof(FQE);
#define FQ(off) (*reinterpret_cast<FQE *>(fq_base + (off)))
      uint32_t not_found = 0;
      FindResult *vp_result = vp.second;
      const uint32_t bmask = (uint32_t)HT_BUCKET_MASK;  // kept in a register
      // bucket index = hash & bmask, written as andn(~bmask, hash): BMI1 andn has 3
      // operands, so the mask register is not copied before every AND
      const uint32_t nbmask = ~bmask;
      const auto bidx = [nbmask](const FQE *x) -> uint32_t {
        uint32_t r;  // asm: gcc folds __andn_u32(~bmask, h) back into a 2-operand AND
        __asm__("andnl %2, %1, %0" : "=r"(r) : "r"(nbmask), "rm"(x->hash));
        return r;
      };
      // the key broadcast straight from memory (vpbroadcastq m64, one load uop): through
      // _mm512_set1_epi64 gcc loads the key into a GPR first, as the reprobe path reuses it
      const auto bcast_key = [](const FQE *x) -> __m512i {
        __m512i v;
        __asm__("vpbroadcastq %1, %0" : "=v"(v) : "m"(x->key));
        return v;
      };
      // Each step completes 4 finds (deep pop) and pushes the next 4 arguments (deep push).
      //  - deep pop: 4 completions with pop_find_queue's semantics: a reprobe pushes the
      //    entry back with its next hash and pops the next entry. So the 4 completed
      //    entries can come from any queue slots; each hit's {key_id, value} is loaded
      //    on its own and placed in lane k of one register, and the 4 results go out
      //    with one 64 B store (a compress store if some lane was not found).
      //  - deep push: the next 4 arguments as one 64 B block of 16 B entries (4 entry
      //    stores instead if the block would wrap the ring).
      // 4 completions free 4 slots and 4 pushes refill them: the queue stays full.
      static_assert(sizeof(FQE) == 16 && offsetof(FQE, key_id) == 12, "16 B find-queue entry");
      static_assert(sizeof(FindResult) == 16 && offsetof(FindResult, value) == 8,
                    "4 results are written as 64 B");
      static_assert(sizeof(Arg) == 24 || (sizeof(Arg) == 16 && offsetof(FindArgument, id) == 12),
                    "push block: 24 B InsertFindArgument (permuted) or 16 B FindArgument (as is)");
      constexpr uint64_t E = sizeof(FQE);
      // the table base is a static member: keep it in a register
      KV *const ht = this->hashtable;
      // 24 B arguments: 4 InsertFindArguments (key = dwords 6j,6j+1, id = dword 6j+4),
      // loaded as dwords 0..15 (a) and 8..23 (b) -> block {key lo, key hi, -, id} per entry.
      // 16 B FindArguments already have the block layout.
      const __m512i push_perm =
          _mm512_set_epi32(30, 0, 27, 26, 24, 0, 13, 12, 10, 0, 7, 6, 4, 0, 1, 0);
      constexpr __mmask16 HASH_LANES = 0x4444;  // dword 4j+2 = hash of entry j
      Arg *dp = kp.data();
      // batch_len is a multiple of 4 (checked in the constructor); only a caller's short
      // final batch can leave 1-3 arguments, handled after the loop
      Arg *const in_end = dp + (kp.size() & ~(size_t)3);
      for (; dp != in_end; dp += 4) {
        // ---- deep pop: 4 completed finds ----
        __m512i res = _mm512_setzero_si512();
        uint32_t found = 0;  // bit k: completion k was a hit (has a result in lane k)
#pragma GCC unroll 4
        for (uint32_t k = 0; k < 4; k++) {
          for (;;) {  // until this entry completes (hit or not found)
            __builtin_prefetch(&ht[bidx(&FQ((tail + PREFETCH_FIND_NEXT_DISTANCE * E) & fq_mask))], false, 3);
            FQE *const e = &FQ(tail);
            tail = (tail + E) & fq_mask;
            const __m512i line = _mm512_load_si512(&ht[bidx(e)]);
            const __mmask8 hit = _mm512_mask_cmpeq_epu64_mask(KEYMSK, line, bcast_key(e));
            if (hit) [[likely]] {
              // {key_id, value} -> lane k: the value is the lane after the key
              const __m128i r = _mm_unpacklo_epi64(
                  _mm_cvtsi32_si128((int)e->key_id),
                  _mm512_castsi512_si128(_mm512_maskz_compress_epi64(_kshiftli_mask8(hit, 1), line)));
              res = _mm512_mask_broadcast_i32x4(res, (__mmask16)(0xFu << (4 * k)), r);
              found |= 1u << k;
              break;
            }
            if (_mm512_mask_cmpeq_epu64_mask(KEYMSK, line, zero_vector)) {  // empty slot: not found
              not_found++;
              break;
            }
            // reprobe (bucket full, key elsewhere): push back with the next hash
#ifdef UNIFORM_HT_SUPPORT
            const uint32_t nh = (uint32_t)_mm_crc32_u64(0xffffffff, (uint64_t)e->hash);
#else
            const uint32_t nh = ((e->hash & bmask) + CACHELINE_SIZE / sizeof(KV)) & bmask;
#endif
            __builtin_prefetch(&ht[nh & bmask], false, 1);  // = prefetch_read, local base
            fq_put(&FQ(head), e->key, nh, e->key_id);
            head = (head + E) & fq_mask;
#ifdef CALC_STATS
            this->num_reprobes++;
#endif
          }
        }
        if (found == 0xF) [[likely]] {
          _mm512_storeu_si512(vp_result, res);  // one 64 B store of 4 results
          vp_result += 4;
        } else {  // write only the lanes that have a result (2 qwords each)
          _mm512_mask_compressstoreu_epi64(vp_result, (__mmask8)(_pdep_u32(found, 0x55) * 3), res);
          vp_result += _mm_popcnt_u32(found);
        }

        // ---- deep push: the next 4 arguments ----
        uint32_t hh[4];
#pragma GCC unroll 4
        for (int j = 0; j < 4; j++) {
          hh[j] = (uint32_t)_mm_crc32_u64(0xffffffff, dp[j].key);
          __builtin_prefetch(&ht[hh[j] & bmask], false, 1);  // = prefetch_read, local base
#ifndef UNIFORM_HT_SUPPORT
          hh[j] &= bmask;  // linear probing keeps the bucket index itself
#endif
        }
        if (head + 4 * E <= fq_mask + 1) [[likely]] {
          __m512i blk;
          if constexpr (sizeof(Arg) == 16)  // 4 x {key, -, id}: already the block layout
            blk = _mm512_loadu_si512(dp);
          else
            blk = _mm512_permutex2var_epi32(
                _mm512_loadu_si512(dp), push_perm,
                _mm512_loadu_si512(reinterpret_cast<const char *>(dp) + 32));
          blk = _mm512_mask_expand_epi32(
              blk, HASH_LANES, _mm512_castsi128_si512(_mm_set_epi32(hh[3], hh[2], hh[1], hh[0])));
          _mm512_storeu_si512(&FQ(head), blk);
        } else {  // the block would wrap the ring
#pragma GCC unroll 4
          for (int j = 0; j < 4; j++) fq_put(&FQ((head + j * E) & fq_mask), dp[j].key, hh[j], dp[j].id);
        }
        head = (head + 4 * E) & fq_mask;
      }
      this->find_tail = tail / sizeof(FQE);
      this->find_head = head / sizeof(FQE);
#undef FQ
      vp.first += (in_end - kp.data()) - not_found;
      // 1-3 leftover arguments (a short final batch): the generic per-item path
      for (Arg *const end = kp.data() + kp.size(); dp != end; ++dp) {
        pop_find_queue(vp, collector);
        add_to_find_queue_t(dp, collector);
      }
    }
#else
    {
      // ===== scalar: one find at a time =====
      __m512i zero_vector = _mm512_setzero_si512();
#ifdef CAS_FIND_RING_OFFSETS
      // Inside this loop tail/head are byte offsets into find_queue, so a slot
      // is base + offset with no index scaling; converted back on exit.
      static_assert((sizeof(FQE) & (sizeof(FQE) - 1)) == 0,
                    "find queue entry size must be a power of two");
      char *const fq_base = reinterpret_cast<char *>(this->find_queue);
      // 64-bit so an offset can be used directly as an addressing-mode index.
      const uint64_t fq_mask = (uint64_t)this->find_queue_sz * sizeof(FQE) - 1;
      uint64_t tail = (uint64_t)this->find_tail * sizeof(FQE);
      uint64_t head = (uint64_t)this->find_head * sizeof(FQE);
#define FQ(off) (*reinterpret_cast<FQE *>(fq_base + (off)))
#else
      uint32_t tail = this->find_tail;
      uint32_t head = this->find_head;
#define FQ(i) (this->find_queue[i])
#endif
      uint32_t not_found = 0;
      FindResult *vp_result = vp.second;
      uint64_t key;
      uint64_t *bucket;
      __m512i key_vector;
      __m512i cacheline;
      __mmask8 key_cmp;
      FQE *q;
      uint64_t hash;
      const uint32_t bmask = (uint32_t)HT_BUCKET_MASK;  // kept in a register
      // pointer loop (same code as the span iterator)
      Arg *const in_end = kp.data() + kp.size();
      for (Arg *dp = kp.data(); dp != in_end; ++dp) {
        auto &data = *dp;
      retry:

#ifdef DOUBLE_PREFETCH
        // Prefetch next tail bucket
#ifdef CAS_FIND_RING_OFFSETS
        uint64_t next_tail =
            (tail + PREFETCH_FIND_NEXT_DISTANCE * sizeof(FQE)) & fq_mask;
#else
        uint32_t next_tail = (tail + PREFETCH_FIND_NEXT_DISTANCE) & FIND_QUEUE_SZ_MASK;
#endif
        const void *next_tail_addr =
            &this->hashtable[fq_idx(&FQ(next_tail), bmask)];
        __builtin_prefetch(next_tail_addr, false, 3);
#endif
        q = &FQ(tail);
        uint32_t idx = fq_idx(q, bmask);
        bucket = (uint64_t *)&this->hashtable[idx];
        cacheline = _mm512_load_si512(bucket);
#ifdef CAS_FIND_EMBCAST
        // compare straight against the entry ({1to8} memory broadcast); the
        // key is reloaded from q only on the retry path
        key_cmp = cmp_key_bcast(cacheline, &q->key);
#else
        key = q->key;
        key_vector = _mm512_set1_epi64(key);
        key_cmp = _mm512_mask_cmpeq_epu64_mask(KEYMSK, cacheline, key_vector);
#endif
        // update tails before we enter branching.
#ifdef CAS_FIND_RING_OFFSETS
        tail = (tail + sizeof(FQE)) & fq_mask;
#else
        tail = (tail + 1) & FIND_QUEUE_SZ_MASK;
#endif

        if (key_cmp > 0) {
#ifdef CAS_FIND_COMPRESS_VALUE
          // The value sits in the lane after its key; take it from the line
          // already in cacheline rather than locating and reloading it.
#ifdef CAS_FIND_KSHIFT
          // One mask-register shift. Written as integer arithmetic (key_cmp << 1)
          // gcc moves the mask to a GPR, shifts, and moves it back: 3 instructions.
          const __mmask8 value_lanes = _kshiftli_mask8(key_cmp, 1);
#else
          const __mmask8 value_lanes = (__mmask8)(key_cmp << 1);
#endif
          vp_result->value = _mm_cvtsi128_si64(_mm512_castsi512_si128(
              _mm512_maskz_compress_epi64(value_lanes, cacheline)));
#else
          __mmask8 offset = _bit_scan_forward(key_cmp);
          vp_result->value = bucket[(offset + 1)];
#endif
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

#ifdef CAS_FIND_QUEUE16
#ifdef UNIFORM_HT_SUPPORT
            hash = _mm_crc32_u64(0xffffffff, (uint64_t)q->hash);
            idx = hash & bmask;
#else
            idx += CACHELINE_SIZE / sizeof(KV);
            idx = idx & HT_BUCKET_MASK;
            hash = idx;
#endif
            prefetch_read(idx);
            fq_put(&FQ(head), q->key, (uint32_t)hash, q->key_id);
#else
#ifdef UNIFORM_HT_SUPPORT
            hash = _mm_crc32_u64(
                0xffffffff,
                *static_cast<const std::uint64_t *>(&(q->key_hash)));
            idx = hash & HT_BUCKET_MASK;
#else
            idx += CACHELINE_SIZE / sizeof(KV);
            idx = idx & HT_BUCKET_MASK;
#endif
            prefetch_read(idx);

#ifdef UNIFORM_HT_SUPPORT
            FQ(head).key_hash = hash;
#endif
#ifdef CAS_FIND_EMBCAST
            FQ(head).key = q->key;
#else
            FQ(head).key = key;
#endif
            FQ(head).key_id = q->key_id;
            FQ(head).idx = idx;
#ifdef LATENCY_COLLECTION
            FQ(head).timer_id = q->timer_id;
#endif
#endif
#ifdef CAS_FIND_RING_OFFSETS
            head = (head + sizeof(FQE)) & fq_mask;
#else
            head += 1;
            head &= FIND_QUEUE_SZ_MASK;
#endif
            goto retry;
          } else {
            not_found++;
          }
        }

        // add to find queue
        Arg *key_data = &data;

#ifdef LATENCY_COLLECTION
        const auto timer = collector->start();
#endif

        hash = _mm_crc32_u64(
            0xffffffff, *static_cast<const std::uint64_t *>(&key_data->key));

        uint32_t new_idx = hash & HT_BUCKET_MASK;

        prefetch_read(new_idx);
#ifdef CAS_FIND_QUEUE16
#ifdef UNIFORM_HT_SUPPORT
        fq_put(&FQ(head), key_data->key, (uint32_t)hash, key_data->id);
#else
        fq_put(&FQ(head), key_data->key, new_idx, key_data->id);
#endif
#else
        FQ(head).key = key_data->key;
#ifdef CAS_FIND_SCALAR_PACK
        {
          // idx and key_id are adjacent 32-bit fields. Left alone, gcc packs them
          // through an xmm register (vmovd + vpinsrd + vmovq, all port 5). Passing
          // both through an empty asm leaves two scalar stores.
          uint32_t pack_idx = new_idx, pack_id = key_data->id;
          __asm__("" : "+r"(pack_idx), "+r"(pack_id));
          FQ(head).idx = pack_idx;
          FQ(head).key_id = pack_id;
        }
#else
        FQ(head).idx = new_idx;
        FQ(head).key_id = key_data->id;
#endif

#ifdef UNIFORM_HT_SUPPORT
        FQ(head).key_hash = hash;
#endif

#ifdef LATENCY_COLLECTION
        FQ(head).timer_id = timer;
#endif
#endif  // CAS_FIND_QUEUE16
#ifdef CAS_FIND_RING_OFFSETS
        head = (head + sizeof(FQE)) & fq_mask;
#else
        head += 1;
        head &= FIND_QUEUE_SZ_MASK;
#endif
      }  // end for loop

#ifdef CAS_FIND_RING_OFFSETS
      this->find_tail = tail / sizeof(FQE);
      this->find_head = head / sizeof(FQE);
#else
      this->find_tail = tail;
      this->find_head = head;
#endif
#undef FQ
      vp.first += (kp.size() - not_found);
    }
#endif
    }  // end of fast path
    else [[unlikely]] {  // slow paths
      for (auto &data : kp) {
        if ((get_find_queue_sz() >= FIND_QUEUE_SZ_MASK)) {
          pop_find_queue(vp, collector);
        }
        add_to_find_queue_t(&data, collector);
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

  void flush_ht_from_cache() {
    for (size_t i = 0; i < this->capacity; i += 4) {
      _mm_clflush(&this->hashtable[i]);
    }
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
  FQE *find_queue;
  KVQ *insert_queue;

  // bucket index of a find-queue entry
  inline uint32_t fq_idx(const FQE *e) const { return fq_idx(e, (uint32_t)HT_BUCKET_MASK); }
  // same with the mask passed in: the find fast path keeps it in a register (the
  // entry stores could otherwise alias HT_BUCKET_MASK and force a reload each find)
  static inline uint32_t fq_idx(const FQE *e, uint32_t bmask) {
#ifdef CAS_FIND_QUEUE16
    return e->hash & bmask;
#else
    (void)bmask;
    return e->idx;
#endif
  }

#ifdef CAS_FIND_QUEUE16
  // Write a 16 B entry. h = the crc hash (uniform probing) or the bucket index
  // (linear probing).
  static inline void fq_put(FQE *e, uint64_t key, uint32_t h, uint32_t id) {
    e->key = key;
    e->hash = h;
    e->key_id = id;
  }
#endif
  uint32_t find_head;
  uint32_t find_tail;
  uint32_t ins_head;
  uint32_t ins_tail;

  // const __mmask8 KEYMSK = 0b01010101;

  Hasher hasher_;

  uint64_t hash(const void *k) { return hasher_(k, this->key_length); }


  // void prefetch(uint64_t i) {
  //   prefetch_object<true /* write */>(
  //       &this->hashtable[i & (this->capacity - 1)],
  //       sizeof(this->hashtable[i & (this->capacity - 1)]));
  // }

  // // remove &, as it will generate instructions
  // void prefetch_read(uint64_t i) {
  //   prefetch_object<false /* write */>(&this->hashtable[i], 64);

  //   // we use pref_obj other places in code, probably good to keep it so we
  //   // only change pref type once
  //   //  const void* addr = (const void*) &this->hashtable[i];
  //   //  __builtin_prefetch((const void *)addr, false, 1);
  // }

#if defined(AVX_SUPPORT) && defined(BUCKETIZATION)

  uint64_t __find_simd(FQE *q, ValuePairs &vp) {
    uint64_t retry;
#ifdef CAS_FIND_QUEUE16
    // Item::find_simd reads an ItemQueue; the 16 B entry is compared here instead.
    size_t idx = fq_idx(q);
    {
      uint64_t *bucket = (uint64_t *)&this->hashtable[idx];
      const __m512i line = _mm512_load_si512(bucket);
      const __mmask8 key_cmp =
          _mm512_mask_cmpeq_epu64_mask(KEYMSK, line, _mm512_set1_epi64(q->key));
      if (key_cmp) {
        vp.second[vp.first].id = q->key_id;
        vp.second[vp.first].value = bucket[_bit_scan_forward(key_cmp) + 1];
        vp.first++;
        return 0;
      }
      retry = _mm512_mask_cmpeq_epu64_mask(KEYMSK, line, _mm512_setzero_si512()) == 0;
    }
    if (retry) {
#ifdef UNIFORM_HT_SUPPORT
      uint64_t old_hash = q->hash;
      uint64_t hash = this->hash(&old_hash);
      idx = hash & HT_BUCKET_MASK;
#else
      idx = (idx + CACHELINE_SIZE / sizeof(KV)) & HT_BUCKET_MASK;
      uint64_t hash = idx;
#endif
      prefetch_read(idx);
      fq_put(&this->find_queue[this->find_head], q->key, (uint32_t)hash, q->key_id);
      this->find_head++;
      this->find_head &= FIND_QUEUE_SZ_MASK;
#ifdef CALC_STATS
      this->num_reprobes++;
#endif
    }
    return retry;
#else
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

      prefetch_read(idx);

      this->find_queue[this->find_head].key = q->key;
      this->find_queue[this->find_head].key_id = q->key_id;
      this->find_queue[this->find_head].idx = idx;
#ifdef LATENCY_COLLECTION
      this->find_queue[this->find_head].timer_id = q->timer_id;
#endif
      this->find_head++;
      this->find_head &= FIND_QUEUE_SZ_MASK;

#ifdef CALC_STATS
      this->num_reprobes++;
#endif
    }

    return retry;
#endif  // CAS_FIND_QUEUE16
  }

#endif

#ifndef CAS_FIND_QUEUE16
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

#ifdef UNIFORM_HT_SUPPORT
      uint64_t old_hash = q->key_hash;
      uint64_t hash = this->hash(&old_hash);
      idx = hash & (this->capacity - 1);
#ifdef BUCKETIZATION
      idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);
#endif
      this->find_queue[this->find_head].key_hash = hash;
#else
      // we don't need this part of code, because branched idx already at start of next cacheline
      // idx += CACHELINE_SIZE / sizeof(KV);
      // idx = idx & (this->capacity - 1);
#endif

      // key is at a different cacheline, prefetch and delay the find

      prefetch_read(idx);

      this->find_queue[this->find_head].key = q->key;
      this->find_queue[this->find_head].key_id = q->key_id;
      this->find_queue[this->find_head].idx = idx;
#ifdef LATENCY_COLLECTION
      this->find_queue[this->find_head].timer_id = q->timer_id;
#endif

      this->find_head++;
      this->find_head &= FIND_QUEUE_SZ_MASK;
#ifdef CALC_STATS
      this->num_reprobes++;
#endif
    } else {
#ifdef LATENCY_COLLECTION
      collector->end(q->timer_id);
#endif
    }

    return retry;
  }
#endif

  uint64_t __find_one(FQE *q, ValuePairs &vp, collector_type *collector) {
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
  }  // end __find_one()

  /// Update or increment the empty key.
  uint64_t __find_empty(FQE *q, ValuePairs &vp) {
    if (empty_slot_exists_) {
      vp.second[vp.first].id = q->key_id;
      vp.second[vp.first].value = empty_slot_;
      vp.first++;
    }
    return empty_slot_;
  }


  // Insert-path prefetch, selected by -DCAS_PREFETCH_INSERTION (see
  // CMakeLists.txt). DOUBLE pairs this queue-time prefetch with a second,
  // dequeue-time prefetchw in flush_if_needed/pop_insert_queue/insert_batch;
  // PREFETCHT1_ONLY is the same queue-time prefetch without that second one.
  // (locality 2 is prefetcht1.)
  inline void prefetch_insert(uint64_t idx) {
#if defined(CAS_INSERT_PREFETCH_DOUBLE) || defined(CAS_INSERT_PREFETCHT1_ONLY)
    __builtin_prefetch(&this->hashtable[idx], false, 2); // L2 prefetch first
#elif defined(CAS_INSERT_PREFETCH_PREFETCHW)
    __builtin_prefetch(&this->hashtable[idx], true, 3);
#elif defined(CAS_INSERT_PREFETCH_NONE)
    (void)idx;
#else
#error "no CAS_PREFETCH_INSERTION choice defined; configure with cmake"
#endif
  }

#ifdef CAS_FIND_EMBCAST
  // vpcmpequq against the key as a {1to8} memory-broadcast operand. gcc does not
  // fold _mm512_set1_epi64(*key) into the compare by itself: it keeps the key in
  // a GPR + vpbroadcastq, or emits a separate broadcast load.
  static inline __mmask8 cmp_key_bcast(__m512i line, const uint64_t *key) {
    __mmask8 k;
    const __mmask8 km = KEYMSK;
    __asm__("vpcmpequq %2%{1to8%}, %1, %0%{%3%}"
            : "=k"(k)
            : "v"(line), "m"(*key), "Yk"(km));
    return k;
  }
#endif

  inline void prefetch_read(uint64_t idx) {
#ifdef DOUBLE_PREFETCH
    __builtin_prefetch(&this->hashtable[idx], false, 1);
#elif L1_PREFETCH
    __builtin_prefetch(&this->hashtable[idx], false, 3);
#elif L2_PREFETCH
    __builtin_prefetch(&this->hashtable[idx], false, 2);
#elif L3_PREFETCH
    __builtin_prefetch(&this->hashtable[idx], false, 1);
#elif NTA_PREFETCH
    __builtin_prefetch(&this->hashtable[idx], false, 0);
#elif NONE_PREFETCH
    // do nothing...
#endif
  }

  // The 128-bit CAS below claims an empty slot by writing the queue entry's
  // first 16 bytes ({key, value}) straight into the bucket. For the
  // aggregating table that is wrong: an insert means "one more occurrence of
  // this key", so the slot must be seeded with a count of 1, not with the
  // caller-supplied value (kmer counting inserts carry no meaningful value).
  // Every other Aggr_KV update path -- update_cas, insert_cas, insert, and the
  // SIMD key-match branch -- already increments by 1 and ignores q->value, so
  // this was the one place that leaked the caller's value into the count,
  // costing exactly one observation per distinct key. The Item path is
  // unchanged: for Item the helper is the same reinterpret it always was.
  static inline __int128 empty_slot_payload(KVQ *q) {
    if constexpr (std::is_same_v<KV, Aggr_KV>) {
      static_assert(sizeof(Aggr_KV) == sizeof(__int128),
                    "128-bit slot claim assumes a 16-byte Aggr_KV");
      Aggr_KV kv;
      kv.key = q->key;
      kv.count = 1;
      __int128 payload;
      memcpy(&payload, &kv, sizeof(payload));
      return payload;
    } else {
      return *(__int128 *)q;
    }
  }

  uint64_t __insert_branched(KVQ *q, collector_type *collector) {
    // hashtable idx at which data is to be inserted

    size_t idx = q->idx;
    KV *curr;

#if defined(CAS_SIMD) && defined(BUCKETIZATION)
    //  The intuition is, we load a snapshot of a cacheline of keys and see
    //  how far ahead we can skip into. It is okay to be outdated with the
    //  world, because, that just means we skip less than we could have. We can
    //  do this because keys are never deleted in the hashtable.

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
      if constexpr (std::is_same_v<KV, Aggr_KV>) {
        // Shared table: the count bump has to be atomic (see above).
        __sync_fetch_and_add(&bucket[(offset + 1)], 1);
      } else {
        bucket[(offset + 1)] = q->value;
        //_mm_stream_si64((long long int *)&bucket[(offset + 1)], (long long
        // int)q->value);
      }
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
      idx = idx & (this->capacity - 1);
#endif

      prefetch_insert(idx);

      this->insert_queue[this->ins_head].key = q->key;
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

    // cpu 1 -> | - -  - - |
    // cpu 2
  try_insert:
    curr = &this->hashtable[idx];

    // we first check if key is 0.if we use cas,
    // it will request for exclusive state unneccesarrily.

#ifdef READ_BEFORE_CAS
    if (curr->is_empty())
#endif
      if (__sync_bool_compare_and_swap((__int128 *)curr, 0,
                                       empty_slot_payload(q))) {
        return 0;
      }

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

    prefetch_insert(idx);

    this->insert_queue[this->ins_head].key = q->key;
    this->insert_queue[this->ins_head].value = q->value;
    this->insert_queue[this->ins_head].idx = idx;

#ifdef LATENCY_COLLECTION
    this->insert_queue[this->ins_head].timer_id = q->timer_id;
#endif

    this->ins_head++;
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

  void add_to_find_queue(void *data, collector_type *collector) {
    add_to_find_queue_t(reinterpret_cast<InsertFindArgument *>(data), collector);
  }

  template <typename Arg>
  void add_to_find_queue_t(const Arg *key_data, collector_type *collector) {

#ifdef LATENCY_COLLECTION
    const auto timer = collector->start();
#endif

    uint64_t hash = this->hash((const char *)&key_data->key);
    size_t idx = hash & (this->capacity - 1);

#ifdef BUCKETIZATION
    idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);
#endif

    prefetch_read(idx);

#ifdef CAS_FIND_QUEUE16
#ifdef UNIFORM_HT_SUPPORT
    fq_put(&this->find_queue[this->find_head], key_data->key, (uint32_t)hash, key_data->id);
#else
    fq_put(&this->find_queue[this->find_head], key_data->key, (uint32_t)idx, key_data->id);
#endif
#else
    this->find_queue[this->find_head].idx = idx;
    this->find_queue[this->find_head].key = key_data->key;
    this->find_queue[this->find_head].key_id = key_data->id;

#ifdef UNIFORM_HT_SUPPORT
    this->find_queue[this->find_head].key_hash = hash;
#endif

#ifdef LATENCY_COLLECTION
    this->find_queue[this->find_head].timer_id = timer;
#endif
#endif

    this->find_head++;
    this->find_head &= FIND_QUEUE_SZ_MASK;
  }

  inline void add_to_insert_queue(void *data, collector_type *collector) {
    add_to_insert_queue_t(reinterpret_cast<InsertFindArgument *>(data), collector);
  }

  template <typename Arg>
  inline void add_to_insert_queue_t(const Arg *key_data, collector_type *collector) {

#ifdef LATENCY_COLLECTION
    const auto timer = collector->start();
#endif

    uint64_t hash = this->hash((const char *)&key_data->key);
    size_t idx = hash & (this->capacity - 1);
#ifdef BUCKETIZATION
    idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);
#endif

    prefetch_insert(idx);

    this->insert_queue[this->ins_head].idx = idx;
    this->insert_queue[this->ins_head].key = key_data->key;
    this->insert_queue[this->ins_head].value = key_data->value;

#ifdef UNIFORM_HT_SUPPORT
    this->insert_queue[this->ins_head].key_hash = hash;
#endif

#ifdef LATENCY_COLLECTION
    this->insert_queue[this->ins_head].timer_id = timer;
#endif

    this->ins_head++;
    this->ins_head &= INSERT_QUEUE_SZ_MASK;
  }
};

/// Static variables
template <class KV, class KVQ>
KV *CASHashTable<KV, KVQ>::hashtable = nullptr;

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
