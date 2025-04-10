/// Partitioned hashtable.
/// Each partition is a linear probing with SIMD lookup.
/// Key and values are stored directly in the table.

#ifndef _SKHT_H
#define _SKHT_H

#include <fcntl.h>
#include <immintrin.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <x86intrin.h>  // _bit_scan_forward

//#include <linux/getcpu.h>
#include <array>
#include <cassert>
#include <fstream>
#include <iostream>
#include <mutex>
#include <tuple>
#include <type_traits>

#include "constants.hpp"
#include "experiments.hpp"
#include "fastrange.h"
#include "hasher.hpp"
#include "helper.hpp"
#include "ht_helper.hpp"
#include "misc_lib.h"
#include "plog/Log.h"
#include "sync.h"

namespace kmercounter {


namespace { // This prevents definition collision

// utility constants and lambdas for SIMD operations
constexpr size_t KV_PER_CACHE_LINE = CACHE_LINE_SIZE / KV_SIZE;

const size_t MAX_PARTITIONS = 64;

#ifdef AVX_SUPPORT

// cacheline
//       <------------------------ cacheline ------------------------->
//       || val3 | key3 || val2 | key2 || val1 | key1 || val0 | key0 ||
// bits: ||  7      6       5      4       3      2       1      0   ||
// masks for AVX512 instructions
constexpr __mmask8 KEY0 = 0b00000001;
constexpr __mmask8 KEY1 = 0b00000100;
constexpr __mmask8 KEY2 = 0b00010000;
constexpr __mmask8 KEY3 = 0b01000000;
constexpr __mmask8 VAL0 = 0b00000010;
constexpr __mmask8 VAL1 = 0b00001000;
constexpr __mmask8 VAL2 = 0b00100000;
constexpr __mmask8 VAL3 = 0b10000000;
constexpr __mmask8 KVP0 = KEY0 | VAL0;
constexpr __mmask8 KVP1 = KEY1 | VAL1;
constexpr __mmask8 KVP2 = KEY2 | VAL2;
constexpr __mmask8 KVP3 = KEY3 | VAL3;

// key_cmp_masks are indexed by cidx, the index of an entry in a cacheline
// the masks are used to mask irrelevant bits of the result of 4-way SIMD
// key comparisons
constexpr std::array<__mmask8, KV_PER_CACHE_LINE> key_cmp_masks = {
    KEY3 | KEY2 | KEY1 | KEY0,  // cidx: 0; all key comparisons valid
    KEY3 | KEY2 | KEY1,         // cidx: 1; only last three comparisons valid
    KEY3 | KEY2,                // cidx: 2; only last two comparisons valid
    KEY3,                       // cidx: 3; only last comparison valid
};

auto load_cacheline = [](void const *cptr) { return _mm512_load_epi64(cptr); };

auto store_cacheline = [](void *cptr, __mmask8 kv_mask, __m512i cacheline) {
  _mm512_mask_store_epi64(cptr, kv_mask, cacheline);
};

auto key_cmp = [](__m512i cacheline, __m512i key_vector, size_t cidx) {
  __mmask8 cmp = _mm512_cmpeq_epu64_mask(cacheline, key_vector);
  // zmm registers are compared as 8 uint64_t
  // mask irrelevant results before returning
  return cmp & key_cmp_masks[cidx];
};

const __m512i empty_key_vector = _mm512_setzero_si512();

auto empty_key_cmp = [](__m512i cacheline, size_t cidx) {
  return key_cmp(cacheline, empty_key_vector, cidx);
};

#endif

} 

// TODO use char and bit manipulation instead of bit fields in Kmer_KV:
// https://stackoverflow.com/questions/1283221/algorithm-for-copying-n-bits-at-arbitrary-position-from-one-int-to-another
// TODO how long should be the count variable?
// TODO should we pack the struct?

constexpr auto histogram_bits = 6;
constexpr std::uint32_t histogram_buckets{1 << histogram_bits};
constexpr std::uint32_t histogram_mask{histogram_buckets - 1};
extern thread_local std::vector<unsigned int> hash_histogram;

template <typename KV, typename KVQ>
class alignas(64) PartitionedHashStore : public BaseHashTable {
 public:
  static KV **hashtable;
  static int *fds;
  int id;
  size_t data_length, key_length;
  /// A dedicated slot for the empty value.
  uint64_t empty_slot_;
  /// True if the empty value is inserted.
  bool empty_slot_exists_;

  // https://www.bfilipek.com/2019/08/newnew-align.html
  void *operator new(std::size_t size, std::align_val_t align) {
    auto ptr = aligned_alloc(static_cast<std::size_t>(align), size);

    if (!ptr) throw std::bad_alloc{};

    PLOGV << "Allocating " << size
          << ", align: " << static_cast<std::size_t>(align) << ", ptr: " << ptr;

    return ptr;
  }

  void operator delete(void *ptr, std::size_t size,
                       std::align_val_t align) noexcept {
    PLOGV << "deleting " << size
          << ", align: " << static_cast<std::size_t>(align)
          << ", ptr : " << ptr;
    free(ptr);
  }

  void prefetch(uint64_t i) {
    if (i > this->capacity) [[unlikely]] {
      PLOG_ERROR.printf("%u > %" PRIu64 "\n", i, this->capacity);
      std::terminate();
    }
#if defined(PREFETCH_WITH_PREFETCH_INSTR)
    prefetch_object<true /* write */>(&this->hashtable[this->id][i],
                                      sizeof(this->hashtable[this->id][i]));
    // true /* write */);
#endif

#if defined(PREFETCH_WITH_WRITE)
    prefetch_with_write(&this->hashtable[i]);
#endif
  };

  void prefetch_partition(uint64_t idx, int _part_id, bool write) {
    if (idx > this->capacity) [[unlikely]] {
      std::terminate();
    }

    auto p = _part_id;
    if (write) {
      prefetch_object<true>((void *)&this->hashtable[p][idx],
                            sizeof(this->hashtable[p][idx]));
    } else {
      prefetch_object<false>((void *)&this->hashtable[p][idx],
                             sizeof(this->hashtable[p][idx]));
    }
  };

  void prefetch_read(uint64_t i) {
    if (i > this->capacity) [[unlikely]] {
      PLOG_ERROR.printf("%u > %" PRIu64 "\n", i, this->capacity);
      std::terminate();
    }

    prefetch_object<false /* write */>(&this->hashtable[i],
                                       sizeof(this->hashtable[i]));
  }

  inline uint8_t touch(uint64_t i) {
    if (i > this->capacity) std::terminate();
#if defined(TOUCH_DEPENDENCY)
    if (this->hashtable[this->id][i].kb.count == 0) {
      this->hashtable[this->id][i].kb.count = 1;
    } else {
      this->hashtable[this->id][i].kb.count = 1;
    };
#else
    this->hashtable[this->id][i].kb.count = 1;
#endif
    return 0;
  };

  PartitionedHashStore(uint64_t c, uint8_t id)
      : id(id), find_head(0), find_tail(0), ins_head(0), ins_tail(0) {
    this->capacity = c;

    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);

      if (!this->fds) {
        this->fds = new int[MAX_PARTITIONS]();
      }

      if (!this->hashtable) {
        // Allocate placeholder for hashtable pointers
        const auto hashtable_size = MAX_PARTITIONS * sizeof(KV *);
        this->hashtable =
            (KV **)(aligned_alloc(64, hashtable_size));
        // Zero the hashtable pointers
        memset(this->hashtable, 0, hashtable_size);
      }
    }

    assert(this->id < (int)MAX_PARTITIONS);

    // paranoid check. id should be unique
    assert(this->hashtable[this->id] == nullptr);

    this->ht_sz = this->capacity * sizeof(KV);

    // Allocate for this id
    this->hashtable[this->id] =
        (KV *)calloc_ht<KV>(this->capacity, this->id, &this->fds[this->id]);
    this->empty_item = this->empty_item.get_empty_key();
    this->key_length = empty_item.key_length();
    this->data_length = empty_item.data_length();

    PLOGV << "Empty item: " << this->empty_item;
    this->insert_queue =
        (KVQ *)(aligned_alloc(64, PREFETCH_QUEUE_SIZE * sizeof(KVQ)));
    this->find_queue =
        (KVQ *)(aligned_alloc(64, PREFETCH_FIND_QUEUE_SIZE * sizeof(KVQ)));

    memset(this->insert_queue, 0x0, PREFETCH_QUEUE_SIZE * sizeof(KVQ));

    memset(this->find_queue, 0x0, PREFETCH_FIND_QUEUE_SIZE * sizeof(KVQ));

    PLOG_DEBUG.printf("id: %d insert_queue %p | find_queue %p", id,
                      this->insert_queue, this->find_queue);
    PLOGV.printf("Hashtable base %p | Hashtable size: %lu | data_length %lu",
                      this->hashtable[this->id], this->capacity,
                     this->data_length);
  }

  ~PartitionedHashStore() {
    free(find_queue);
    free(insert_queue);
    free_mem<KV>(this->hashtable[this->id], this->capacity, this->id,
                 this->fds[this->id]);
    this->hashtable[this->id] = nullptr;
  }

#ifdef AVX_SUPPORT
  // FIXME: shares a lot of code with __insert_branchless_simd
  void __insert_noprefetch_simd(const void *data) {
    KVQ *q = const_cast<KVQ *>(reinterpret_cast<const KVQ *>(data));
    uint64_t hash = 0;
    uint64_t key = 0;

    hash = this->hash((const char *)&q->key);
    key = q->key;

    size_t idx = fastrange32(hash, this->capacity);

    KV *cur_ht = this->hashtable[this->id];

    for (auto i = 0u; i < this->capacity;) {
      static_assert(CACHE_LINE_SIZE == 64);
      static_assert(sizeof(KV) == 16);
      constexpr size_t KV_PER_CACHE_LINE = CACHE_LINE_SIZE / sizeof(KV);

      // masks for AVX512 instructions
      constexpr __mmask8 KEY0 = 0b00000001;
      constexpr __mmask8 KEY1 = 0b00000100;
      constexpr __mmask8 KEY2 = 0b00010000;
      constexpr __mmask8 KEY3 = 0b01000000;
      constexpr __mmask8 VAL0 = 0b00000010;
      constexpr __mmask8 VAL1 = 0b00001000;
      constexpr __mmask8 VAL2 = 0b00100000;
      constexpr __mmask8 VAL3 = 0b10000000;
      constexpr __mmask8 KVP0 = KEY0 | VAL0;
      constexpr __mmask8 KVP1 = KEY1 | VAL1;
      constexpr __mmask8 KVP2 = KEY2 | VAL2;
      constexpr __mmask8 KVP3 = KEY3 | VAL3;

      // a vector of 1s that is used for incrementing a value
      constexpr __m512i INCREMENT_VECTOR = {
          0ULL, 1ULL,  // KVP0
          0ULL, 1ULL,  // KVP1
          0ULL, 1ULL,  // KVP2
          0ULL, 1ULL,  // KVP3
      };

      // cacheline_masks is indexed by q->idx % KV_PER_CACHE_LINE
      constexpr std::array<__mmask8, KV_PER_CACHE_LINE> cacheline_masks = {
          KVP3 | KVP2 | KVP1 | KVP0,  // load all KV pairs in the cacheline
          KVP3 | KVP2 | KVP1,         // skip the first KV pair
          KVP3 | KVP2,                // skip the first two KV pairs
          KVP3,                       // load only the last KV pair
      };
      // key_cmp_masks are indexed by cidx, the index of an entry in a cacheline
      // the masks are used to mask irrelevant bits of the result of 4-way SIMD
      // key comparisons
      constexpr std::array<__mmask8, KV_PER_CACHE_LINE> key_cmp_masks = {
          KEY3 | KEY2 | KEY1 | KEY0,  // cidx: 0; all key comparisons valid
          KEY3 | KEY2 | KEY1,  // cidx: 1; only last three comparisons valid
          KEY3 | KEY2,         // cidx: 2; only last two comparisons valid
          KEY3,                // cidx: 3; only last comparison valid
      };
      // key_copy_masks are indexed by the return value of the BSF instruction,
      // executed on the mask returned by a search for empty keys in a
      // cacheline
      //       <-------------------- cacheline --------------------->
      //       || key | val || key | val || key | val || key | val ||
      // bits: ||  0     1      2     3      4     5      6     7  ||
      // the only possible indices are: 0, 2, 4, 6
      constexpr std::array<__mmask8, 8> key_copy_masks = {
          KEY0,  // bit 0 set; choose first key
          0,
          KEY1,  // bit 2 set; choose second
          0,
          KEY2,  // bit 4 set; choose third
          0,
          KEY3,  // bit 6 set; choose last
          0,
      };

      auto load_key_vector = [q]() {
        // we want to load only the keys into a ZMM register, as two 32-bit
        // integers. 0b0011 matches the first 64 bits of a KV pair -- the key
        __mmask16 mask{0b0011001100110011};
        __m128i kv =
            _mm_loadl_epi64(reinterpret_cast<const __m128i *>(&q->key));
        return _mm512_maskz_broadcast_i32x2(mask, kv);
      };

      auto load_kv_vector = [q]() {
        // we want to load only the key value pair into a ZMM register, as four
        // 4-byte integers. 0b1111 matches the entire KV pair
        __mmask16 mask{0b1111111111111111};
        __m128i kv =
            _mm_loadl_epi64(reinterpret_cast<const __m128i *>(&q->key));
        return _mm512_maskz_broadcast_i32x2(mask, kv);
      };

      auto load_cacheline = [this, cur_ht, idx, &cacheline_masks](size_t cidx) {
        const KV *cptr = &cur_ht[idx & ~(KV_PER_CACHE_LINE - 1)];
        return _mm512_maskz_load_epi64(cacheline_masks[cidx], cptr);
      };

      auto store_cacheline = [this, cur_ht, idx](__m512i cacheline,
                                                 __mmask8 kv_mask) {
        KV *cptr = &cur_ht[idx & ~(KV_PER_CACHE_LINE - 1)];
        _mm512_mask_store_epi64(cptr, kv_mask, cacheline);
      };

      auto key_cmp = [&key_cmp_masks](__m512i cacheline, __m512i key_vector,
                                      size_t cidx) {
        __mmask8 cmp = _mm512_cmpeq_epu64_mask(cacheline, key_vector);
        // zmm registers are compared as 8 uint64_t
        // mask irrelevant results before returning
        return cmp & key_cmp_masks[cidx];
      };

      auto empty_cmp = [&key_cmp_masks](__m512i cacheline, size_t cidx) {
        const __m512i empty_key_vector = _mm512_setzero_si512();
        __mmask8 cmp = _mm512_cmpeq_epu64_mask(cacheline, empty_key_vector);
        // zmm registers are compared as 8 uint64_t
        // mask irrelevant results before returning
        return cmp & key_cmp_masks[cidx];
      };

      auto key_copy_mask = [&empty_cmp, &key_copy_masks](__m512i cacheline,
                                                         uint32_t eq_cmp,
                                                         size_t cidx) {
        uint32_t locations = empty_cmp(cacheline, cidx);
        __mmask16 copy_mask = 1 << _bit_scan_forward(locations);
        // if locations == 0, _bit_scan_forward(locations) is undefined
        // if eq_cmp != 0, key is already present
        //
        // if ((locations && !eq_cmp) == 0) copy_mask = 0;
        asm("andnl %[locations], %[eq_cmp], %%ecx\n\t"
            "cmovzw %%cx, %[copy_mask]\n\t"
            : [copy_mask] "+r"(copy_mask)
            : [locations] "r"(locations), [eq_cmp] "r"(eq_cmp)
            : "rcx");
        return static_cast<__mmask8>(copy_mask);
      };

      auto blend = [](__m512i &cacheline, __m512i kv_vector, __mmask8 mask) {
        cacheline = _mm512_mask_blend_epi64(mask, cacheline, kv_vector);
      };

      auto increment_count = [INCREMENT_VECTOR](__m512i &cacheline,
                                                __mmask8 val_mask) {
        cacheline = _mm512_mask_add_epi64(cacheline, val_mask, cacheline,
                                          INCREMENT_VECTOR);
      };

      // compute index within the cacheline
      const size_t cidx = idx & (KV_PER_CACHE_LINE - 1);

      // depending on the value of idx, between 1 and 4 KV pairs in a cacheline
      // can be probed for an insert operation. load the cacheline.
      __m512i cacheline = load_cacheline(cidx);
      // load a vector of the key-value in all 4 positions
      __m512i kv_vector;
      if constexpr (std::is_same_v<KV, Aggr_KV>) {
        kv_vector = load_key_vector();
      } else {
        kv_vector = load_kv_vector();
      }

      __mmask8 eq_cmp = key_cmp(cacheline, kv_vector, cidx);

      // compute a mask for copying the key into an empty slot
      // will be 0 if eq_cmp != 0 (key already exists in the cacheline)
      __mmask8 copy_mask = key_copy_mask(cacheline, eq_cmp, cidx);

      // between eq_cmp and copy_mask, at most one bit will be set
      // if we shift-left eq_cmp|copy_mask by 1 bit, the bit will correspond
      // to the value of the KV-pair we are interested in
      __mmask8 key_mask = eq_cmp | copy_mask;
      __mmask8 val_mask = key_mask << 1;
      __mmask8 kv_mask = key_mask | val_mask;

      if (!kv_mask) {
        auto inc_idx = KV_PER_CACHE_LINE - cidx;
        auto nidx = idx + inc_idx;
        nidx =
            nidx >= this->capacity ? (nidx - this->capacity) : nidx;  // modulo
        idx = nidx;
        i += inc_idx;
#ifdef CALC_STATS
        this->num_reprobes++;
#endif
      } else {
        if constexpr (std::is_same_v<KV, Aggr_KV>) {
          blend(cacheline, kv_vector, copy_mask);
          increment_count(cacheline, val_mask);
          // write the cacheline back; just the KV pair that was modified
          store_cacheline(cacheline, kv_mask);
        } else {
          store_cacheline(kv_vector, kv_mask);
        }
        break;
      }
    }
    return;
  }
#endif 

  void __insert_noprefetch_branched(const void *data, collector_type* collector) {
    KVQ *key_data = const_cast<KVQ *>(reinterpret_cast<const KVQ *>(data));
    uint64_t hash = 0;

#ifdef LATENCY_COLLECTION
    const auto start_time = collector->sync_start();
#endif
    size_t idx;
#if defined(BQ_KEY_UPPER_BITS_HAS_HASH)
    hash = key_data->key >> 32;
    key_data->key &= 0xffffffff;
    idx = fastrange32(_mm_crc32_u32(0xffffffff, hash), this->capacity);
#else
    hash = this->hash((const char *)&key_data->key);
    idx = fastrange32(hash, this->capacity);
#endif

    KV *cur_ht = this->hashtable[this->id];

    //PLOGV.printf("hash %lu | key %lu | idx %lu", hash, key_data->key, idx);
    for (auto i = 0u; i < this->capacity; i++) {
      KV *curr = &cur_ht[idx];
      auto retry = false;

      retry = curr->insert(key_data);

      if (retry) {
        idx++;
        idx = idx == this->capacity ? 0 : idx;  // modulo
#ifdef CALC_STATS
        this->num_reprobes++;
#endif
      } else {
#ifdef LATENCY_COLLECTION
        collector->sync_end(start_time);
#endif

        if (0) {
          printf("inserted key %" PRIu64 " at idx %zu | hash %" PRIu64 "\n", key_data->key,
                 idx, hash);
        }
        break;
      }
    }
  }

  void insert_noprefetch(const void *data, collector_type* collector) override {
#ifdef LATENCY_COLLECTION
    static_assert(branching == BRANCHKIND::WithBranch, "Latency collection only supported with branched insertion");
#endif

    if constexpr (branching == BRANCHKIND::WithBranch) {
      __insert_noprefetch_branched(data, collector);
    } else if constexpr (branching == BRANCHKIND::NoBranch_Simd) {
      #ifdef AVX_SUPPORT
        __insert_noprefetch_simd(data);
      #else
        __insert_noprefetch_branched(data, collector);
      #endif 
    }
  }

  // insert a batch
  void insert_batch(const InsertFindArguments &kp, collector_type* collector) override {
    this->flush_if_needed(collector);

    for (auto &data : kp) {
      add_to_insert_queue(&data, collector);
    }

    this->flush_if_needed(collector);
  }

  bool insert(const void *data) { return false; }

  // TODO: static_assert for queue pow2

  // overridden function for insertion
  void flush_if_needed(collector_type* collector) {
    size_t curr_queue_sz =
        (this->ins_head - this->ins_tail) & (PREFETCH_QUEUE_SIZE - 1);
    while (curr_queue_sz >= INS_FLUSH_THRESHOLD) {
      __insert_one(&this->insert_queue[this->ins_tail], collector);
      this->ins_tail = (this->ins_tail + 1) & (PREFETCH_QUEUE_SIZE - 1);
      curr_queue_sz =
          (this->ins_head - this->ins_tail) & (PREFETCH_QUEUE_SIZE - 1);
    }
    return;
  }

  void flush_insert_queue(collector_type* collector) override {
    size_t curr_queue_sz =
        (this->ins_head - this->ins_tail) & (PREFETCH_QUEUE_SIZE - 1);

    while (curr_queue_sz != 0) {
      __insert_one(&this->insert_queue[this->ins_tail], collector);
      this->ins_tail = (this->ins_tail + 1) & (PREFETCH_QUEUE_SIZE - 1);
      curr_queue_sz =
          (this->ins_head - this->ins_tail) & (PREFETCH_QUEUE_SIZE - 1);
    }
  }

  void flush_find_queue(ValuePairs &vp, collector_type* collector) override {
    size_t curr_queue_sz =
        (this->find_head - this->find_tail) & (PREFETCH_FIND_QUEUE_SIZE - 1);

    while ((curr_queue_sz != 0) && (vp.first < config.batch_len)) {
      __find_one(&this->find_queue[this->find_tail], vp, collector);
      if (++this->find_tail >= PREFETCH_FIND_QUEUE_SIZE) this->find_tail = 0;
      curr_queue_sz =
          (this->find_head - this->find_tail) & (PREFETCH_FIND_QUEUE_SIZE - 1);
    }
  }

  void flush_if_needed(ValuePairs &vp, collector_type* collector) {
    size_t curr_queue_sz =
        (this->find_head - this->find_tail) & (PREFETCH_FIND_QUEUE_SIZE - 1);
    // make sure you return at most batch_sz (but can possibly return lesser
    // number of elements)
    while ((curr_queue_sz > FLUSH_THRESHOLD) &&
           (vp.first < config.batch_len)) {
      // cout << "Finding value for key " <<
      // this->find_queue[this->find_tail].key << " at tail : " <<
      // this->find_tail << endl;
      __find_one(&this->find_queue[this->find_tail], vp, collector);
      if (++this->find_tail >= PREFETCH_FIND_QUEUE_SIZE) this->find_tail = 0;
      curr_queue_sz =
          (this->find_head - this->find_tail) & (PREFETCH_FIND_QUEUE_SIZE - 1);
    }
    return;
  }

  void find_batch(const InsertFindArguments &kp, ValuePairs &values, collector_type* collector) override {
    // What's the size of the prefetch queue size?
    // pfq_sz = 4 * 64;
    // flush_threshold = 128;
    // batch_sz = 64;
    // On arrival, there are three possibilities
    // 1) The prefetch queue is empty -> we can happily submit the batch and
    // return 2) The prefetch queue is full -> we need to go thro to see if some
    // of them can be reaped 3) The prefetch queue is half-full -> we can
    // enqueue half the batch, process the queue and enqueue the leftover items

    // cout << "-> flush_before head: " << this->find_head << " tail: " <<
    // this->find_tail << endl;
    this->flush_if_needed(values, collector);
    // cout << "== > post flush_before head: " << this->find_head << " tail: "
    // << this->find_tail << endl;

    for (auto &data : kp) {
      add_to_find_queue(&data, collector);
    }

    // cout << "-> flush_after head: " << this->find_head << " tail: " <<
    // this->find_tail << endl;
    this->flush_if_needed(values, collector);
    // cout << "== > post flush_after head: " << this->find_head << " tail: " <<
    // this->find_tail << endl;
  }

  void *find_noprefetch(const void *data, collector_type* collector) override {
#ifdef CALC_STATS
    uint64_t distance_from_bucket = 0;
#endif
    InsertFindArgument *item = const_cast<InsertFindArgument *>(reinterpret_cast<const InsertFindArgument *>(data));

#ifdef LATENCY_COLLECTION
    const auto start_time = collector->sync_start();
#endif
    uint64_t hash;//, key;
    size_t idx;
#if defined(BQ_KEY_UPPER_BITS_HAS_HASH)
    hash = item->key >> 32;
    item->key &= 0xffffffff;
    idx = fastrange32(_mm_crc32_u32(0xffffffff, hash), this->capacity);
#else
    hash = this->hash((const char *)&item->key);
    idx = fastrange32(hash, this->capacity);
#endif

    KV *cur_ht = this->hashtable[item->part_id];
    KV *curr;

    bool found = false;

    for (auto i = 0u; i < this->capacity; i++) {
      curr = &cur_ht[idx];

      if (curr->compare_key(item)) {
        found = true;
        break;
      } else if (curr->is_empty()) {
        goto exit;
      }

#ifdef CALC_STATS
      distance_from_bucket++;
#endif
      idx++;
      idx = idx == this->capacity ? 0 : idx;
    }
#ifdef CALC_STATS
    if (distance_from_bucket > this->max_distance_from_bucket) {
      this->max_distance_from_bucket = distance_from_bucket;
    }
    this->sum_distance_from_bucket += distance_from_bucket;
#endif

#ifdef LATENCY_COLLECTION
    collector->sync_end(start_time);
#endif

  exit:
    // return empty_element if nothing is found
    if (!found) {
      printf("key %" PRIu64 " not found at idx %" PRIu32 " | hash %" PRIu64 "\n", item->key, idx,
             hash);
      curr = nullptr;
    }
    return curr;
  }

  void display() const override {
    KV *ht = this->hashtable[this->id];
    for (size_t i = 0; i < this->capacity; i++) {
      if (!ht[i].is_empty()) {
        cout << ht[i] << endl;
      }
    }
  }

  size_t get_fill() const override {
    size_t count = 0;
    KV *ht = this->hashtable[this->id];
    for (size_t i = 0; i < this->capacity; i++) {
      if (!ht[i].is_empty()) {
        count++;
      }
    }
    return count;
  }

  size_t get_capacity() const override { return this->capacity; }

  size_t get_max_count() const override {
    size_t count = 0;
    KV *ht = this->hashtable[this->id];
    for (size_t i = 0; i < this->capacity; i++) {
      if (ht[i].get_value() > count) {
        count = ht[i].get_value();
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
    KV *ht = this->hashtable[this->id];
    for (size_t i = 0; i < this->get_capacity(); i++) {
      if (!ht[i].is_empty()) {
        f << ht[i] << std::endl;
      }
    }
  }

  size_t get_ht_size() const { return this->ht_sz; }

 private:
  static std::mutex ht_init_mutex;
  uint64_t capacity;
  size_t ht_sz;
  KV empty_item; /* for comparison for empty slot */
  KVQ *queue;    // TODO prefetch this?
  KVQ *find_queue;
  KVQ *insert_queue;
  uint32_t find_head;
  uint32_t find_tail;
  uint32_t ins_head;
  uint32_t ins_tail;
  Hasher hasher_;

  uint64_t hash(const void *k) { return hasher_(k, this->key_length); }

  uint64_t __find_branched(KVQ *q, ValuePairs &vp, collector_type* collector) {
    // hashtable idx where the data should be found
    size_t idx = q->idx;
    uint64_t found = 0;
    // unsigned int cpu, node;

    // getcpu(&cpu, &node);
  try_find:
    // printf("%s, cpu: %d part_id %d idx %d\n", __func__, cpu, q->part_id,
    // idx);
    KV *curr = &this->hashtable[q->part_id][idx];
    uint64_t retry;
    found = curr->find(q, &retry, vp);

    // printf("%s, key = %" PRIu64 " | found = %d\n", __func__, q->key, found);
    //  printf("%s, key = %" PRIu64 " | num_values %u, value %" PRIu64 " (id = %" PRIu64 ") | found
    //  =%ld, retry %ld\n",
    //         __func__, q->key, vp.first, vp.second[(vp.first - 1) %
    //                 PREFETCH_FIND_QUEUE_SIZE].value, vp.second[(vp.first - 1)
    //                 % PREFETCH_FIND_QUEUE_SIZE].id, found, retry);
    if (retry) {
      // insert back into queue, and prefetch next bucket.
      // next bucket will be probed in the next run
      idx++;
      idx = idx == this->capacity ? 0 : idx;  // modulo
      // |    4 elements |
      // | 0 | 1 | 2 | 3 | 4 | 5 ....
      if ((idx & 0x3) != 0) {
        goto try_find;
      }

      this->prefetch_partition(idx, q->part_id, false);

      this->find_queue[this->find_head].key = q->key;
      this->find_queue[this->find_head].key_id = q->key_id;
      this->find_queue[this->find_head].idx = idx;
      this->find_queue[this->find_head].part_id = q->part_id;
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

  uint64_t __find_branchless_cmov(KVQ *q, ValuePairs &vp) {
    // hashtable idx where the data should be found
    size_t idx = q->idx;
    uint64_t found = 0;

    KV *curr = &this->hashtable[q->part_id][idx];
    uint64_t retry = 1;

    found = curr->find_brless(q, &retry, vp);

    // insert back into queue, and prefetch next bucket.
    // next bucket will be probed in the next run
    idx++;
    idx = idx == this->capacity ? 0 : idx;  // modulo
    this->find_queue[this->find_head].key = q->key;
    this->find_queue[this->find_head].key_id = q->key_id;
    this->find_queue[this->find_head].idx = idx;
    this->prefetch_read(idx);

    // this->find_head should not be incremented if either
    // the desired key is empty or it is found.
    uint64_t inc{1};
    inc = (retry == 0x1) ? inc : 0;

    this->find_head += inc;
    this->find_head &= (PREFETCH_FIND_QUEUE_SIZE - 1);

    return found;
  }
#ifdef AVX_SUPPORT
  uint64_t __find_branchless_simd(KVQ *q, ValuePairs &vp) {
    static_assert(sizeof(KV) == KV_SIZE);

    // hashtable idx at which data is to be found
    size_t idx = q->idx;
    // index within the cacheline
    const size_t cidx = idx & (KV_PER_CACHE_LINE - 1);
    // index at which current cacheline starts
    const size_t ccidx = idx - cidx;
    // pointer to current cacheline
    KV *cptr = &this->hashtable[q->part_id][idx & ~(KV_PER_CACHE_LINE - 1)];

    auto load_key_vector = [q]() {
      // we want to load only the keys into a ZMM register, as two 32-bit
      // integers. 0b0011 matches the first 64 bits of a KV pair -- the key
      __mmask16 mask{0b0011001100110011};
      __m128i kv = _mm_loadl_epi64(reinterpret_cast<const __m128i *>(&q->key));
      return _mm512_maskz_broadcast_i32x2(mask, kv);
    };

    // load the cacheline.
    __m512i cacheline = load_cacheline(cptr);
    // load a vector of the key in all 4 positions
    __m512i key_vector = load_key_vector();

    // depending on the value of idx, between 1 and 4 KV pairs in a cacheline
    // can be probed for a find operation. compare key at relevant positions
    __mmask8 eq_cmp = key_cmp(cacheline, key_vector, cidx);
    // look for empty keys in the same (relevant) positions
    __mmask8 empty_cmp = empty_key_cmp(cacheline, cidx);

    // compute index at which there is a key match
    //size_t midx = _bit_scan_forward(eq_cmp) >> 1;
    const KV *match = &this->hashtable[q->part_id][idx];

    //PLOGV.printf("match found? key %lu | key_id %lu | value %lu", q->key, q->key_id, match->get_value());

    // if eq_cmp == 0, match is invalid as there is no match
    __mmask8 found = 0;
    asm(
        // if (!eq_cmp) found = 1;
        "test %[eq_cmp], %[eq_cmp]\n\t"
        "setnz %[found]\n\t"
        : [found] "=r"(found)
        : [eq_cmp] "r"(eq_cmp));

    if (found) {

      // copy the value out
      vp.second[vp.first].value = match->get_value();
      vp.second[vp.first].id = q->key_id;
      vp.first += found;
    }
    // if key is not found, and we have not encountered any empty "slots"
    // reprobe is necessary
    __mmask8 reprobe = 0;
    asm(
        // if (!found && !empty_cmp) reprobe = 1;
        "orb %[found], %[empty_cmp]\n\t"
        "setz %[reprobe]\n\t"
        : [reprobe] "=r"(reprobe)
        : [found] "r"(found), [empty_cmp] "r"(empty_cmp));

    if (reprobe) {
#ifdef CALC_STATS
      this->max_distance_from_bucket++;
#endif
      // index at which reprobe must begin
      size_t ridx = ccidx + reprobe * KV_PER_CACHE_LINE;
      ridx = (ridx >= this->capacity) ? (ridx - this->capacity) : ridx;  // modulo

      this->prefetch_partition(ridx, q->part_id, false);

      this->find_queue[this->find_head].key = q->key;
      this->find_queue[this->find_head].key_id = q->key_id;
      this->find_queue[this->find_head].idx = ridx;
      this->find_queue[this->find_head].part_id = q->part_id;

      this->find_head += reprobe;
      this->find_head &= (PREFETCH_FIND_QUEUE_SIZE - 1);
    }
    return found;
  }
#endif


  auto __find_one(KVQ *q, ValuePairs &vp, collector_type* collector) {
    if (q->key == this->empty_item.get_key()) {
      return __find_empty(q, vp);
    }

    if constexpr (branching == BRANCHKIND::WithBranch) {
      return __find_branched(q, vp, collector);
    } else if constexpr (branching == BRANCHKIND::NoBranch_Cmove) {
      return __find_branchless_cmov(q, vp);
    } else if constexpr (branching == BRANCHKIND::NoBranch_Simd) {

      #ifdef AVX_SUPPORT
        return __find_branchless_simd(q, vp);
      #else
        return __find_branchless_cmov(q, vp);
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

  void __insert_branched(KVQ *q, collector_type* collector) {
    // hashtable idx at which data is to be inserted
    size_t idx = q->idx;
    KV *cur_ht = this->hashtable[this->id];
  try_insert:
    KV *curr = &cur_ht[idx];
    auto retry = false;
    // if constexpr (experiment_inactive(experiment_type::insert_dry_run,
    //                                   experiment_type::aggr_kv_write_key_only))
    //PLOGV.printf("Inserting key %lu", q->key);
    retry = curr->insert(q);

    // if constexpr (experiment_active(experiment_type::aggr_kv_write_key_only))
    // {
    //  curr->key = q->key;
    // }

    if (retry) {
      // FIXME: we *really* need an insert_to_queue() subroutine, this is too
      // brittle insert back into queue, and prefetch next bucket. next bucket
      // will be probed in the next run
      idx++;
      idx = idx == this->capacity ? 0 : idx;  // modulo

      // |    4 elements |
      // | 0 | 1 | 2 | 3 | 4 | 5 ....
      if ((idx & 0x3) != 0) {
#ifdef CALC_STATS
        ++this->num_soft_reprobes;
#endif

        goto try_insert;
      }

      prefetch(idx);

      this->insert_queue[this->ins_head].key = q->key;
      this->insert_queue[this->ins_head].key_id = q->key_id;
      this->insert_queue[this->ins_head].value = q->value;
      this->insert_queue[this->ins_head].idx = idx;

#ifdef LATENCY_COLLECTION
      this->insert_queue[this->ins_head].timer_id = q->timer_id;
#endif

      ++this->ins_head;
      this->ins_head &= (PREFETCH_QUEUE_SIZE - 1);

#ifdef CALC_STATS
      this->num_reprobes++;
#endif
    }
  }

  void __insert_branchless_cmov(KVQ *q) {
    // hashtable idx at which data is to be inserted
    size_t idx = q->idx;
    KV *curr = &this->hashtable[this->id][idx];
    // returns 1 succeeded
    uint8_t cmp = curr->insert_or_update_v2(q);

    /* prepare for (possible) soft reprobe */
    idx++;
    idx = idx == this->capacity ? 0 : idx;  // modulo

    prefetch(idx);
    this->insert_queue[this->ins_head].key = q->key;
    this->insert_queue[this->ins_head].key_id = q->key_id;
    this->insert_queue[this->ins_head].idx = idx;

    // this->queue_idx should not be incremented if either
    // of the try_inserts succeeded
    int inc{1};
    inc = (cmp == 0xff) ? 0 : inc;
    this->ins_head += inc;
    this->ins_head &= (PREFETCH_QUEUE_SIZE - 1);
  }

#ifdef AVX_SUPPORT
  void __insert_branchless_simd(KVQ *q) {
    // hashtable idx at which data is to be inserted
    size_t idx = q->idx;
    KV *cur_ht = this->hashtable[this->id];

    static_assert(CACHE_LINE_SIZE == 64);
    static_assert(sizeof(KV) == 16);
    constexpr size_t KV_PER_CACHE_LINE = CACHE_LINE_SIZE / sizeof(KV);

    // masks for AVX512 instructions
    constexpr __mmask8 KEY0 = 0b00000001;
    constexpr __mmask8 KEY1 = 0b00000100;
    constexpr __mmask8 KEY2 = 0b00010000;
    constexpr __mmask8 KEY3 = 0b01000000;
    constexpr __mmask8 VAL0 = 0b00000010;
    constexpr __mmask8 VAL1 = 0b00001000;
    constexpr __mmask8 VAL2 = 0b00100000;
    constexpr __mmask8 VAL3 = 0b10000000;
    constexpr __mmask8 KVP0 = KEY0 | VAL0;
    constexpr __mmask8 KVP1 = KEY1 | VAL1;
    constexpr __mmask8 KVP2 = KEY2 | VAL2;
    constexpr __mmask8 KVP3 = KEY3 | VAL3;

    // a vector of 1s that is used for incrementing a value
    constexpr __m512i INCREMENT_VECTOR = {
        0ULL, 1ULL,  // KVP0
        0ULL, 1ULL,  // KVP1
        0ULL, 1ULL,  // KVP2
        0ULL, 1ULL,  // KVP3
    };

    // cacheline_masks is indexed by q->idx % KV_PER_CACHE_LINE
    constexpr std::array<__mmask8, KV_PER_CACHE_LINE> cacheline_masks = {
        KVP3 | KVP2 | KVP1 | KVP0,  // load all KV pairs in the cacheline
        KVP3 | KVP2 | KVP1,         // skip the first KV pair
        KVP3 | KVP2,                // skip the first two KV pairs
        KVP3,                       // load only the last KV pair
    };
    // key_cmp_masks are indexed by cidx, the index of an entry in a cacheline
    // the masks are used to mask irrelevant bits of the result of 4-way SIMD
    // key comparisons
    constexpr std::array<__mmask8, KV_PER_CACHE_LINE> key_cmp_masks = {
        KEY3 | KEY2 | KEY1 | KEY0,  // cidx: 0; all key comparisons valid
        KEY3 | KEY2 | KEY1,  // cidx: 1; only last three comparisons valid
        KEY3 | KEY2,         // cidx: 2; only last two comparisons valid
        KEY3,                // cidx: 3; only last comparison valid
    };
    // key_copy_masks are indexed by the return value of the BSF instruction,
    // executed on the mask returned by a search for empty keys in a
    // cacheline
    //       <-------------------- cacheline --------------------->
    //       || key | val || key | val || key | val || key | val ||
    // bits: ||  0     1      2     3      4     5      6     7  ||
    // the only possible indices are: 0, 2, 4, 6
    constexpr std::array<__mmask8, 8> key_copy_masks = {
        KEY0,  // bit 0 set; choose first key
        0,
        KEY1,  // bit 2 set; choose second
        0,
        KEY2,  // bit 4 set; choose third
        0,
        KEY3,  // bit 6 set; choose last
        0,
    };

    auto load_key_vector = [q]() {
      // we want to load only the keys into a ZMM register, as two 32-bit
      // integers. 0b0011 matches the first 64 bits of a KV pair -- the key
      __mmask16 mask{0b0011001100110011};
      __m128i kv = _mm_loadl_epi64(reinterpret_cast<const __m128i *>(&q->key));
      return _mm512_maskz_broadcast_i32x2(mask, kv);
    };

    auto load_kv_vector = [q]() {
      // we want to load only the key value pair into a ZMM register, as four
      // 4-byte integers. 0b1111 matches the entire KV pair
      __mmask16 mask{0b1111111111111111};
      __m128i kv = _mm_loadl_epi64(reinterpret_cast<const __m128i *>(&q->key));
      return _mm512_maskz_broadcast_i32x2(mask, kv);
    };

    auto load_cacheline = [this, cur_ht, idx, &cacheline_masks](size_t cidx) {
      const KV *cptr = &cur_ht[idx & ~(KV_PER_CACHE_LINE - 1)];
      return _mm512_maskz_load_epi64(cacheline_masks[cidx], cptr);
    };

    auto store_cacheline = [this, cur_ht, idx](__m512i cacheline,
                                               __mmask8 kv_mask) {
      KV *cptr = &cur_ht[idx & ~(KV_PER_CACHE_LINE - 1)];
      _mm512_mask_store_epi64(cptr, kv_mask, cacheline);
    };

    auto key_cmp = [&key_cmp_masks](__m512i cacheline, __m512i key_vector,
                                    size_t cidx) {
      __mmask8 cmp = _mm512_cmpeq_epu64_mask(cacheline, key_vector);
      // zmm registers are compared as 8 uint64_t
      // mask irrelevant results before returning
      return cmp & key_cmp_masks[cidx];
    };

    auto empty_cmp = [&key_cmp_masks](__m512i cacheline, size_t cidx) {
      const __m512i empty_key_vector = _mm512_setzero_si512();
      __mmask8 cmp = _mm512_cmpeq_epu64_mask(cacheline, empty_key_vector);
      // zmm registers are compared as 8 uint64_t
      // mask irrelevant results before returning
      return cmp & key_cmp_masks[cidx];
    };

    auto key_copy_mask = [&empty_cmp, &key_copy_masks](
                             __m512i cacheline, uint32_t eq_cmp, size_t cidx) {
      uint32_t locations = empty_cmp(cacheline, cidx);
      __mmask16 copy_mask = 1 << _bit_scan_forward(locations);
      // if locations == 0, _bit_scan_forward(locations) is undefined
      // if eq_cmp != 0, key is already present
      //
      // if ((locations && !eq_cmp) == 0) copy_mask = 0;
      asm("andnl %[locations], %[eq_cmp], %%ecx\n\t"
          "cmovzw %%cx, %[copy_mask]\n\t"
          : [copy_mask] "+r"(copy_mask)
          : [locations] "r"(locations), [eq_cmp] "r"(eq_cmp)
          : "rcx");
      return static_cast<__mmask8>(copy_mask);
    };

    auto blend = [](__m512i &cacheline, __m512i kv_vector, __mmask8 mask) {
      cacheline = _mm512_mask_blend_epi64(mask, cacheline, kv_vector);
    };

    auto increment_count = [INCREMENT_VECTOR](__m512i &cacheline,
                                              __mmask8 val_mask) {
      cacheline = _mm512_mask_add_epi64(cacheline, val_mask, cacheline,
                                        INCREMENT_VECTOR);
    };

    // compute index within the cacheline
    const size_t cidx = idx & (KV_PER_CACHE_LINE - 1);

    // depending on the value of idx, between 1 and 4 KV pairs in a cacheline
    // can be probed for an insert operation. load the cacheline.
    __m512i cacheline = load_cacheline(cidx);
    // load a vector of the key-value in all 4 positions
    __m512i kv_vector;
    if constexpr (std::is_same_v<KV, Aggr_KV>) {
      kv_vector = load_key_vector();
    } else {
      kv_vector = load_kv_vector();
    }

    __mmask8 eq_cmp = key_cmp(cacheline, kv_vector, cidx);

    // compute a mask for copying the key into an empty slot
    // will be 0 if eq_cmp != 0 (key already exists in the cacheline)
    __mmask8 copy_mask = key_copy_mask(cacheline, eq_cmp, cidx);

    // between eq_cmp and copy_mask, at most one bit will be set
    // if we shift-left eq_cmp|copy_mask by 1 bit, the bit will correspond
    // to the value of the KV-pair we are interested in
    __mmask8 key_mask = eq_cmp | copy_mask;
    __mmask8 val_mask = key_mask << 1;
    __mmask8 kv_mask = key_mask | val_mask;

#ifdef PURE_BRANCHLESS
    if constexpr (std::is_same_v<KV, Aggr_KV>) {
      blend(cacheline, kv_vector, copy_mask);
      increment_count(cacheline, val_mask);
      // write the cacheline back; just the KV pair that was modified
      store_cacheline(cacheline, kv_mask);
    } else {
      store_cacheline(kv_vector, kv_mask);
    }

    // prepare for possible reprobe
    // point next idx (nidx) to the start of the next cacheline
    auto nidx = idx + KV_PER_CACHE_LINE - cidx;
    nidx = nidx >= this->capacity ? (nidx - this->capacity) : nidx;  // modulo
    this->insert_queue[this->ins_head].key = q->key;
    this->insert_queue[this->ins_head].key_id = q->key_id;
    this->insert_queue[this->ins_head].idx = nidx;
    auto queue_idx_inc = 1;
    // if kv_mask != 0, insert succeeded; reprobe unnecessary
    asm volatile(
        "xorq %%rcx, %%rcx\n\t"
        "test %[kv_mask], %[kv_mask]\n\t"
        // if (kv_mask) queue_idx_inc = 0;
        "cmovnzl %%ecx, %[inc]\n\t"
        // if (kv_mask) nidx = idx;
        "cmovnzq %[idx], %[nidx]\n\t"
        : [nidx] "+r"(nidx), [inc] "+r"(queue_idx_inc)
        : [kv_mask] "r"(kv_mask), [idx] "r"(idx)
        : "rcx");

    // issue prefetch
    prefetch(nidx);
    this->ins_head += queue_idx_inc;
    this->ins_head &= (PREFETCH_QUEUE_SIZE - 1);
#else
    if (!kv_mask) {
      auto nidx = idx + KV_PER_CACHE_LINE - cidx;
      nidx = nidx >= this->capacity ? (nidx - this->capacity) : nidx;  // modulo
      prefetch(nidx);
      this->insert_queue[this->ins_head].key = q->key;
      this->insert_queue[this->ins_head].key_id = q->key_id;
      this->insert_queue[this->ins_head].value = q->value;
      this->insert_queue[this->ins_head].idx = nidx;
      this->ins_head++;  // += queue_idx_inc;
      this->ins_head &= (PREFETCH_QUEUE_SIZE - 1);
    } else {
      if constexpr (std::is_same_v<KV, Aggr_KV>) {
        blend(cacheline, kv_vector, copy_mask);
        increment_count(cacheline, val_mask);
        // write the cacheline back; just the KV pair that was modified
        store_cacheline(cacheline, kv_mask);
      } else {
        store_cacheline(kv_vector, kv_mask);
      }
    }
#endif
    return;
  }
#endif

  void __insert_one(KVQ *q, collector_type* collector) {
    if (q->key == this->empty_item.get_key()) {
      return __insert_empty(q);
    }

#ifdef LATENCY_COLLECTION
    static_assert(branching == BRANCHKIND::WithBranch, "Latency collection only supported with branched insertion");
#endif

    if constexpr (experiment_inactive(experiment_type::nop_insert)) {
      if constexpr (branching == BRANCHKIND::WithBranch) {
        __insert_branched(q, collector);
      } else if constexpr (branching == BRANCHKIND::NoBranch_Cmove) {
        __insert_branchless_cmov(q);
      } else if constexpr (branching == BRANCHKIND::NoBranch_Simd) {
        #ifdef AVX_SUPPORT
          __insert_branchless_simd(q); 
        #else 
          __insert_branchless_cmov(q);
        #endif
      }
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

  uint64_t read_hashtable_element(const void *data) {
    std::terminate();  // TODO: if you want to use this, we don't use pow2
                       // capacities anymore
    uint64_t hash = this->hash((const char *)data);
    size_t idx = hash & (this->capacity - 1);
    KV *curr = &this->hashtable[this->id][idx];
    return curr->get_value();
  }

  void prefetch_queue(QueueType qtype) override {
    if (qtype == QueueType::insert_queue) {
      auto _ins_head = this->ins_head;
      __builtin_prefetch(&this->insert_queue[_ins_head], 1, 3);
      _ins_head = this->ins_head + (64 / sizeof(KVQ));
      __builtin_prefetch(&this->insert_queue[_ins_head], 1, 3);
    } else if (qtype == QueueType::find_queue) {
      auto _find_head = this->find_head;
      __builtin_prefetch(&this->find_queue[_find_head], 1, 3);
      _find_head = this->find_head + (64 / sizeof(KVQ));
      __builtin_prefetch(&this->find_queue[_find_head], 1, 3);
    }
  }

  void add_to_insert_queue(void *data, collector_type* collector) {
    InsertFindArgument *key_data = reinterpret_cast<InsertFindArgument *>(data);
    uint64_t hash = 0;
    uint64_t key = 0;

    if (bq_load == BQUEUE_LOAD::HtInsert) [[likely]] {
#if defined(BQ_KEY_UPPER_BITS_HAS_HASH)
      hash = key_data->key >> 32;
      key = key_data->key & 0xFFFFFFFF;
#else
      hash = this->hash((const char *)&key_data->key);
      key = key_data->key;
#endif
    } else {
      hash = this->hash((const char *)&key_data->key);
      key = key_data->key;
    }

    // The hashes have little to no upper-bit entropy _because of how they are
    // assigned to the queues_
    size_t idx;
    idx = fastrange32(hash, this->capacity);  // modulo

    //PLOGD.printf("Getting idx %zu", idx);
    if (idx > this->capacity) [[unlikely]] {
      PLOG_ERROR.printf("%u > %" PRIu64 "\n", idx, this->capacity);
      std::terminate();
    }

#if defined(HASH_HISTOGRAM)
    ++hash_histogram.at(idx & histogram_mask);
#endif
    this->prefetch(idx);

    // if constexpr (experiment_inactive(experiment_type::prefetch_only)) {
    this->insert_queue[this->ins_head].idx = idx;
    this->insert_queue[this->ins_head].key = key;
    this->insert_queue[this->ins_head].value = key_data->value;
    this->insert_queue[this->ins_head].key_id = key_data->id;

#ifdef COMPARE_HASH
    this->insert_queue[this->ins_head].key_hash = hash;
#endif

    this->ins_head = (this->ins_head + 1) & (PREFETCH_QUEUE_SIZE - 1);
    //}
  }

  void add_to_find_queue(void *data, collector_type* collector) {
    InsertFindArgument *key_data = reinterpret_cast<InsertFindArgument *>(data);
    uint64_t hash = 0;
    uint64_t key = 0;

#ifdef LATENCY_COLLECTION
    const auto time = collector->start();
#endif

    if (bq_load == BQUEUE_LOAD::HtInsert) {
#if defined(BQ_KEY_UPPER_BITS_HAS_HASH)
      hash = key_data->key >> 32;
      key = key_data->key & 0xFFFFFFFF;
#else
      hash = this->hash((const char *)&key_data->key);
      key = key_data->key;
#endif
    } else {
      hash = this->hash((const char *)&key_data->key);
      key = key_data->key;
    }

    size_t idx;
    idx = fastrange32(hash, this->capacity);  // modulo

    this->prefetch_partition(idx, key_data->part_id, false);

    this->find_queue[this->find_head].idx = idx;
    this->find_queue[this->find_head].key = key;
    this->find_queue[this->find_head].key_id = key_data->id;
    this->find_queue[this->find_head].part_id = key_data->part_id;
#ifdef LATENCY_COLLECTION
    this->find_queue[this->find_head].timer_id = time;
#endif

#ifdef COMPARE_HASH
    this->queue[this->find_head].key_hash = hash;
#endif

    this->find_head++;
    if (this->find_head >= PREFETCH_FIND_QUEUE_SIZE) this->find_head = 0;
  }
};

template <class KV, class KVQ>
KV **PartitionedHashStore<KV, KVQ>::hashtable;

template <class KV, class KVQ>
std::mutex PartitionedHashStore<KV, KVQ>::ht_init_mutex;

template <class KV, class KVQ>
int *PartitionedHashStore<KV, KVQ>::fds;

// std::vector<std::mutex> PartitionedArrayHashTable:: hashtable_mutexes;

// TODO bloom filters for high frequency kmers?

}  // namespace kmercounter
#endif /* _SKHT_H_ */
