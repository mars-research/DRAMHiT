#ifndef _SKHT_H
#define _SKHT_H

#include <fcntl.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#include <array>
#include <cassert>
#include <fstream>
#include <iostream>
#include <tuple>

#include "dbg.hpp"
#include "helper.hpp"
#include "ht_helper.hpp"
#include "sync.h"

#if defined(BRANCHLESS) && defined(BRACNHLESS_NO_SIMD)
#error \
    "BRACHLESS and BRANCHLESS_NO_SIMD options selected in CFLAGS, remove one to fix this error"
#endif

#if defined(BRANCHLESS)
#include <immintrin.h>
#endif

const auto FLUSH_THRESHOLD = 160;

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
                    sizeof(this->hashtable[i & (this->capacity - 1)]),
                    true /* write */);
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

  PartitionedHashStore(uint64_t c, uint8_t id)
      : fd(-1), id(id), queue_idx(0), find_idx(0), find_head(0), find_tail(0) {
    this->capacity = kmercounter::next_pow2(c);
    this->hashtable = calloc_ht<KV>(capacity, this->id, &this->fd);
    this->empty_item = this->empty_item.get_empty_key();
    this->key_length = empty_item.key_length();
    this->data_length = empty_item.data_length();

    cout << "Empty item: " << this->empty_item << endl;
    this->queue = (KVQ *)(aligned_alloc(64, PREFETCH_QUEUE_SIZE * sizeof(KVQ)));
    this->find_queue =
        (KVQ *)(aligned_alloc(64, PREFETCH_FIND_QUEUE_SIZE * sizeof(KVQ)));

    dbg("id: %d this->queue %p | find_queue %p\n", id, this->queue,
        this->find_queue);
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

  void insert_noprefetch(void *data) {
    cout << "Not implemented!" << endl;
    assert(false);
  }

  /* insert and increment if exists */
  bool insert(const void *data) override {
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

  void flush_queue() override {
    size_t curr_queue_sz = this->queue_idx;
    while (curr_queue_sz != 0) {
      __flush_from_queue(curr_queue_sz);
      curr_queue_sz = this->queue_idx;
    }
#ifdef CALC_STATS
    this->num_queue_flushes++;
#endif
  }

  void flush_find_queue_v2(ValuePairs &vp) override {
    size_t curr_queue_sz =
        (this->find_head - this->find_tail) & (PREFETCH_FIND_QUEUE_SIZE - 1);

    while (curr_queue_sz != 0) {
      __find_one_v2(&this->find_queue[this->find_tail], vp);
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
      __find_one_v2(&this->find_queue[this->find_tail], vp);
      if (++this->find_tail >= PREFETCH_FIND_QUEUE_SIZE) this->find_tail = 0;
      curr_queue_sz =
          (this->find_head - this->find_tail) & (PREFETCH_FIND_QUEUE_SIZE - 1);
    }
    return;
  }

  uint8_t flush_find_queue() override {
    size_t curr_queue_sz = this->find_idx;
    uint8_t found = 0;
    while (curr_queue_sz != 0) {
      found += __flush_find_queue(curr_queue_sz);
      curr_queue_sz = this->find_idx;
    }
    return found;
  }

  void find_batch_v2(KeyPairs &kp, ValuePairs &values) {
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
    this->flush_if_needed(values);
    // cout << "== > post flush_before head: " << this->find_head << " tail: "
    // << this->find_tail << endl;

    Keys *keys;
    uint32_t batch_len;
    std::tie(batch_len, keys) = kp;

    for (auto k = 0u; k < batch_len; k++) {
      void *data = reinterpret_cast<void *>(&keys[k]);
      add_to_find_queue_v2(data);
    }

    // cout << "-> flush_after head: " << this->find_head << " tail: " <<
    // this->find_tail << endl;
    this->flush_if_needed(values);
    // cout << "== > post flush_after head: " << this->find_head << " tail: " <<
    // this->find_tail << endl;
  }

  uint8_t find_batch(uint64_t *__keys, uint32_t batch_len) override {
    auto found = 0;
    KV *keys = reinterpret_cast<KV *>(__keys);
    for (auto k = 0u; k < batch_len; k++) {
      void *data = reinterpret_cast<void *>(&keys[k]);
      add_to_find_queue(data);
    }

    found += this->flush_find_queue();

    // printf("%s, found %d keys\n", __func__, found);
    return found;
  }

  void *find(const void *data) override {
#ifdef CALC_STATS
    uint64_t distance_from_bucket = 0;
#endif
    uint64_t hash = this->hash((const char *)data);
    size_t idx = hash;
    KV *curr = NULL;
    bool found = false;

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
    // return empty_element if nothing is found
    if (!found) {
      curr = &this->empty_item;
    }
  exit:
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
  KVQ *find_queue;
  uint32_t queue_idx;
  uint32_t find_idx;
  uint32_t find_head;
  uint32_t find_tail;

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
      curr->update_item(q->data);
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

// TODO: Move this to makefile
#define BRANCHLESS_FIND

  auto __find_one_v2(KVQ *q, ValuePairs &vp) {
    // hashtable idx where the data should be found
    size_t idx = q->idx;
    uint64_t found = 0;

  try_find:

    KV *curr = &this->hashtable[idx];
    uint64_t retry;

    // if (q->key == 45146313) {
    // printf("corrupted! %ld\n", q->key);
    // }
    // found = curr->find_key_brless_v2(q, &retry, vp);
    __builtin_prefetch(q + 6, 1, 3);

    if constexpr (branching == BRANCHKIND::Cmove) {
      found = curr->find_key_brless_v2(q, &retry, vp);
    } else {
      found = curr->find_key_regular_v2(q, &retry, vp);
    }

    /*     printf("%s, key = %lu | num_values %u, value %lu (id = %lu) | found =
       %ld, retry %ld\n", __func__, q->key, vp.first, vp.second[(vp.first - 1) %
       PREFETCH_FIND_QUEUE_SIZE].value, vp.second[(vp.first - 1) %
       PREFETCH_FIND_QUEUE_SIZE].id, found, retry); */

    if constexpr (branching == BRANCHKIND::Yes) {
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
    } else {
      // insert back into queue, and prefetch next bucket.
      // next bucket will be probed in the next run
      idx++;
      idx = idx & (this->capacity - 1);  // modulo
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
    }

    return found;
  }

  auto __find_one(KVQ *q) {
    // hashtable idx where the data should be found
    size_t idx = q->idx;
    uint64_t found = 0;
#ifdef BRANCHLESS_FIND
    KV *curr = &this->hashtable[idx];
    uint64_t retry;

    found = curr->find_key_brless(q->data, &retry);

    // insert back into queue, and prefetch next bucket.
    // next bucket will be probed in the next run
    idx++;
    idx = idx & (this->capacity - 1);  // modulo

    this->prefetch_read(idx);

    this->find_queue[this->find_idx].data = q->data;
    this->find_queue[this->find_idx].idx = idx;

    // this->find_idx should not be incremented if either
    // the desired key is empty or it is found.
    uint64_t inc{1};
    inc = (retry == 0x1) ? inc : 0;
    this->find_idx += inc;

    return found;
#else
  try_find:
    KV *curr = &this->hashtable[idx];

    // Compare with empty element
    if (curr->is_empty()) {
      goto exit;
    } else if (curr->compare_key(q->data)) {
      KV *kv = const_cast<KV *>(reinterpret_cast<const KV *>(q->data));
      kv->set_value(curr);
      found = 1;
      goto exit;
    }

    // insert back into queue, and prefetch next bucket.
    // next bucket will be probed in the next run
    idx++;
    idx = idx & (this->capacity - 1);  // modulo

    // |    4 elements |
    // | 0 | 1 | 2 | 3 | 4 | 5 ....
    if ((idx & 0x3) != 0) {
      goto try_find;
    }

    prefetch(idx);

    this->find_queue[this->find_idx].data = q->data;
    this->find_queue[this->find_idx].idx = idx;
    this->find_idx++;
  exit:
    // printf("%s, key = %lu | found = %lu\n", __func__, *(uint64_t*) q->data,
    // found);
    return found;
#endif
  }

  void __insert(KVQ *q) {
    // hashtable idx at which data is to be inserted
    size_t idx = q->idx;
  try_insert:
    KV *curr = &this->hashtable[idx];

#ifdef BRANCHLESS_NO_SIMD
    // 0xFF: insert or update was successfull
    uint16_t cmp = curr->insert_or_update(q->data);

    /* prepare for (possible) soft reprobe */
    idx++;
    idx = idx & (this->capacity - 1);  // modulo

    prefetch(idx);
    this->queue[this->queue_idx].data = q->data;
    this->queue[this->queue_idx].idx = idx;

    // this->queue_idx should not be incremented if either
    // of the try_inserts succeeded
    int inc{1};
    inc = (cmp == 0xFF) ? 0 : inc;
    this->queue_idx += inc;

    return;

#elif defined(BRANCHLESS)
    static_assert(KMER_DATA_LENGTH == 20, "k-mer key size has changed");
    using Kv_mask = std::array<uint32_t, 8>;
    /* The VMASKMOVPS instruction we use to load the key into a ymmx
     * register loads 4-byte (floating point) numbers based on the
     * MSB of the corresponding 4-byte number in the mask register.
     * The first 8 bytes of an entry in the hastable make up the key.
     * Hence, the first 2 (8/4) entries in the array must have their
     * MSB set.
     */
    __attribute__((aligned(32))) constexpr auto mask_rw =
        Kv_mask{0x80000000, 0x80000000, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0};
    /* When we do not want to read or write, the "mask" must consist
     * of 4-byte numbers with their MSB set to 0.
     */
    __attribute__((aligned(32))) constexpr auto mask_ignore =
        Kv_mask{0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0};
    const uint32_t *const kv_masks[2] = {
        mask_rw.data(),
        mask_ignore.data(),
    };
    auto ymm_load = [](const uint32_t *addr) {
      return _mm256_load_si256(reinterpret_cast<const __m256i *>(addr));
    };
    auto ymm_maskload = [](const auto *addr, auto mask) {
      return _mm256_maskload_epi32(reinterpret_cast<const int *>(addr), mask);
    };
    auto ymm_maskstore = [](auto *addr, auto mask, auto data) {
      return _mm256_maskstore_epi32(reinterpret_cast<int *>(addr), mask, data);
    };
    auto ymm_cmp = [](auto a, auto b) { return _mm256_cmpeq_epi32(a, b); };
    auto ymm_movemask = [](auto a) { return _mm256_movemask_ps(a); };

    /* load key mask and new key */
    const __m256i key_mask = ymm_load(kv_masks[0 /* RW mask */]);
    const __m256i new_key = ymm_maskload(q->data, key_mask);

    /*
     * returns the result of the comparison between the new key
     * and the key at idx */
    auto try_insert = [&](const auto idx) {
      const int mask_idx = !curr->is_empty();
      /* kv_masks[0] returns a mask that reads/writes;
       * kv_masks[1] returns a mask that does nothing */
      const __m256i cond_store_mask = ymm_load(kv_masks[mask_idx]);

      /* conditionally store the new key into hashtable[idx] */
      ymm_maskstore(curr, cond_store_mask, new_key);

      /* at this point the key in the hashtable is either equal to
       * the new key (q->data) or not. compare them
       */
      const __m256i cond_load_mask = ymm_load(kv_masks[0 /*RW mask*/]);
      const __m256i key = ymm_maskload(curr, cond_load_mask);
      const __m256i cmp_raw = ymm_cmp(new_key, key);
      /* ymm_cmp compares the keys as packed 4-byte integers
       * cmp_raw consists of packed 4-byte "result" integers that are
       * 0xFF..FF if the corresponding 4-byte integers in the keys are equal,
       * and 0x00..00 otherwise. testing this is not straight-forward.
       * so, we "compress" the eigth integers into a bit each (MSB).
       */
      return ymm_movemask(_mm256_castsi256_ps(cmp_raw));
    };

    const int cmp = try_insert(idx);

    curr->update_brless(cmp);

    /* prepare for (possible) soft reprobe */
    idx++;
    idx = idx & (this->capacity - 1);  // modulo

    prefetch(idx);
    this->queue[this->queue_idx].data = q->data;
    this->queue[this->queue_idx].idx = idx;

    // this->queue_idx should not be incremented if either
    // of the try_inserts succeeded
    int inc{1};
    inc = (cmp == 0xFF) ? 0 : inc;
    this->queue_idx += inc;

    return;

#else  // !BRANCHLESS
    assert(
        !const_cast<KV *>(reinterpret_cast<const KV *>(q->data))->is_empty());
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

    // |    4 elements |
    // | 0 | 1 | 2 | 3 | 4 | 5 ....
    if ((idx & 0x3) != 0) {
      goto try_insert;
    }

    prefetch(idx);

    this->queue[this->queue_idx].data = q->data;
    this->queue[this->queue_idx].idx = idx;
    this->queue_idx++;

#ifdef CALC_STATS
    this->num_reprobes++;
#endif
    return;
#endif  // BRANCHLESS
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

  void add_to_find_queue(void *data) {
    uint64_t hash = this->hash((const char *)data);
    size_t idx = hash & (this->capacity - 1);  // modulo

    this->prefetch_read(idx);
    this->find_queue[this->find_idx].idx = idx;
    this->find_queue[this->find_idx].data = data;

#ifdef COMPARE_HASH
    this->queue[this->find_idx].key_hash = hash;
#endif
    this->find_idx++;
  }

  void add_to_find_queue_v2(void *data) {
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

  // fetch items from queue and call find
  auto find_prefetched_batch() {
    uint8_t found = 0;
    this->find_idx = 0;  // start again
    for (size_t i = 0; i < PREFETCH_FIND_QUEUE_SIZE; i++) {
      found += __find_one(&this->find_queue[i]);
    }
    return found;
  }

  void __flush_find_queue_v2(size_t qsize, ValuePairs &vp) {
    for (size_t i = 0; i < qsize; i++) {
    }
  }

  uint8_t __flush_find_queue(size_t qsize) {
    uint8_t found = 0;
    this->find_idx = 0;  // start again
    for (size_t i = 0; i < qsize; i++) {
      found += __find_one(&this->find_queue[i]);
    }
    return found;
  }
};

// TODO bloom filters for high frequency kmers?

}  // namespace kmercounter
#endif /* _SKHT_H_ */
