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
#include "xorwow.hpp"

namespace kmercounter {

#ifdef BUDDY_QUEUE
// typedef struct {
//   uint64_t key;
//   uint64_t val;
// } BuddyItem;

// struct alignas(64) BuddyNode {
//   BuddyItem items[4];  // 56 bytes
//   BuddyNode *next;     // 8 bytes
// };

class BuddyBuffer {
  typedef struct {
    uint64_t key;
    uint64_t val;
  } BuddyItem;

  typedef struct {
    uint8_t flag;
    char padding[64 - sizeof(uint8_t)];
  } flag_cacheline;

 public:
  uint32_t writer_count;
  char pad1[64 - sizeof(uint32_t)];

  uint32_t reader_count;
  char pad2[64 - sizeof(uint32_t)];

  // uint32_t writer_bucket_idx;
  // char pad3[64 - sizeof(uint32_t)];

  // uint32_t reader_bucket_idx;
  // char pad4[64 - sizeof(uint32_t)];

  BuddyItem writer_buffer[4];
  uint8_t writer_buffer_idx;
  flag_cacheline *flags;
  uint32_t bucket_sz;
  uint32_t capacity;
  uint32_t bucket_num;
  uint32_t bucket_msk;
  BuddyItem *arr;

  static void *operator new(std::size_t size, size_t numa_node) {
    size_t page_sz = 4096;
    size_t obj_sz = ((size + page_sz - 1) / page_sz) * page_sz;
    void *mem = aligned_alloc(page_sz, obj_sz);
    assert(mem != nullptr);

    unsigned long nodemask = 1UL << numa_node;
    assert(mbind(mem, obj_sz, MPOL_BIND, &nodemask, sizeof(nodemask) * 8,
                 MPOL_MF_MOVE | MPOL_MF_STRICT) == 0);

    return mem;
  }

  // Matching placement delete (called if constructor throws)
  static void operator delete(void *ptr) noexcept { free(ptr); }

  inline bool is_pow_2(size_t x) { return x != 0 && (x & (x - 1)) == 0; }

  BuddyBuffer(uint32_t capacity, uint32 bucket_sz, size_t numa_node) {
    assert(capacity >= 4);
    assert(capacity % 4 == 0);
    assert(capacity % bucket_sz == 0);

    assert(bucket_sz >= 4);
    assert(bucket_sz % 4 == 0);
    assert(is_pow_2(bucket_sz));

    this->bucket_msk = __builtin_ctz(bucket_sz);

    this->capacity = capacity;
    this->bucket_sz = bucket_sz;
    this->bucket_num = capacity / bucket_sz;
    // assert(is_pow_2(bucket_num));

    this->writer_count = 0;
    this->reader_count = 0;
    // writer_bucket_idx = 0;
    // reader_bucket_idx = 0;
    writer_buffer_idx = 0;

    unsigned long nodemask = 1UL << numa_node;
    uint32_t page_sz = 4096;

    // for flags
    uint64_t mem_sz = this->bucket_num * sizeof(flag_cacheline);
    mem_sz = ((page_sz + mem_sz - 1) / page_sz) * page_sz;
    flags = (flag_cacheline *)aligned_alloc(page_sz, mem_sz);
    assert(flags != nullptr);
    assert(mbind(flags, mem_sz, MPOL_BIND, &nodemask, sizeof(nodemask) * 8,
                 MPOL_MF_MOVE | MPOL_MF_STRICT) == 0);

    // for arr
    mem_sz = this->capacity * sizeof(BuddyItem);
    mem_sz = ((page_sz + mem_sz - 1) / page_sz) * page_sz;
    arr = (BuddyItem *)aligned_alloc(page_sz, mem_sz);
    assert(arr != nullptr);
    assert(mbind(arr, mem_sz, MPOL_BIND, &nodemask, sizeof(nodemask) * 8,
                 MPOL_MF_MOVE | MPOL_MF_STRICT) == 0);

    memset(arr, 0, this->capacity * sizeof(BuddyItem));
    memset(this->flags, 0, bucket_num * sizeof(flag_cacheline));
  }

  bool add(uint64_t a, uint64_t b) {
    writer_buffer[writer_buffer_idx].key = a;
    writer_buffer[writer_buffer_idx].val = b;
    writer_buffer_idx++;

    if (writer_buffer_idx == 4) {
      bool flush_status = this->flush();
      writer_buffer_idx = flush_status ? 0 : 3;
      return flush_status;
    }

    return true;
  }

  bool read(uint64 **addr_ptr) {
    // use 4th slot as flag
    if (arr[(reader_count + 3)].key == 1) {  // read
      *addr_ptr = (uint64_t *)&arr[reader_count];
      reader_count += 4;
      if (reader_count == capacity) {
        reader_count = 0;
      }
      return true;
    }

    // uint32_t bucket_idx = get_flag_idx(reader_count);

    // if (flags[bucket_idx].flag == 1) {
    //   *addr_ptr = (uint64_t *)&arr[reader_count];
    //   reader_count += 4;
    //   if (reader_count == capacity) {
    //     reader_count = 0;
    //   }

    //   if (!(reader_count & (bucket_sz - 1))) {  // we finish a bucket
    //     flags[bucket_idx].flag = 0;
    //   }

    //   return true;
    // }

    // this bucket is not ready, check next
    reader_count += bucket_sz;
    if (reader_count == capacity) {
      reader_count = 0;
    }

    return false;

    // if (flags[reader_bucket_idx].flag == 1) {
    //   *addr_ptr = (uint64_t *)&arr[reader_count];
    //   reader_count += 4;  // increment by cacheline
    //   if (!(reader_count & (bucket_sz - 1))) {
    //     reader_bucket_idx++;
    //   }
    //   return true;
    // }
    // return true;
  }

  void prefetch_arr() {
    uint32_t prefetch_loc = writer_count + 0;
    if (prefetch_loc < capacity) {
      __builtin_prefetch(&(arr[prefetch_loc]), true, 3);
    }
  }

  inline uint32_t get_flag_idx(uint32_t count) { return count >> bucket_msk; }

  bool flush() {
    if (reader_count == writer_count) {
      writer_count += bucket_sz;
      if (writer_count == capacity) writer_count = 0;
    } else {
      if (arr[(writer_count + 3)].key == 0) {
        __m512i data = _mm512_load_si512((void *)writer_buffer);
        _mm512_store_si512((void *)&arr[writer_count], data);
        writer_count += 4;
        if (writer_count == capacity) {
          writer_count = 0;
        }
      }
    }

  retry:
    uint32_t bucket_idx = get_flag_idx(writer_count);
    if (flags[bucket_idx].flag == 0) {
      __m512i data = _mm512_load_si512((void *)writer_buffer);
      _mm512_store_si512((void *)&arr[writer_count], data);
      writer_count += 4;
      if (writer_count == capacity) {
        writer_count = 0;
      }
      if (!(writer_count & (bucket_sz - 1))) {
        flags[bucket_idx].flag = 1;
      }

      return true;
    }

    uint32_t reader_bucket_idx = get_flag_idx(reader_count);
    // bucket is ready, maybe reader is reading it, let us avoid collison
    if (reader_bucket_idx == bucket_idx) {
      writer_count += bucket_sz;
      if (writer_count == capacity) writer_count = 0;

      goto retry;
    }

    return false;
  }
};

#endif

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
  // BuddyNode *buddy_current;  // reader
  // BuddyNode *buddy_tail;     // writer
  // BuddyNode **buddy_nodes;

  static BuddyBuffer **buddy_find_queues;
  static BuddyBuffer **buddy_insert_queues;

  BuddyBuffer *buddy_find_queue;
  BuddyBuffer *buddy_insert_queue;
  BuddyBuffer *own_buddy_insert_queue;
  BuddyBuffer *own_buddy_find_queue;

  uint32_t BuddyBufferLength;
  uint32_t num_threads = 128;

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

#ifdef REMOTE_QUEUE
  uint32_t REMOTE_FIND_QUEUE_SZ_MASK;
  uint32_t remote_find_queue_sz;
#endif

#define KEYMSK ((__mmask8)(0b01010101))
#define PREFETCH_INSERT_NEXT_DISTANCE 8
#define PREFETCH_FIND_NEXT_DISTANCE 8

  CASHashTable(uint64_t c) : CASHashTable(c, 8, 0) {};

  CASHashTable(uint64_t c, uint32_t queue_sz, uint8_t tid)
      : fd(-1), id(1), find_head(0), find_tail(0), ins_head(0), ins_tail(0) {
    this->capacity = kmercounter::utils::next_pow2(c);
    this->find_queue_sz = kmercounter::utils::next_pow2(queue_sz);
    this->insert_queue_sz = find_queue_sz;

    assert(capacity % KV_IN_CACHELINE == 0);

    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);

      if (!this->hashtable) {
        assert(this->ref_cnt == 0);
        this->hashtable = calloc_ht<KV>(this->capacity, this->id, &this->fd);

        PLOGI.printf("Hashtable base: %p Hashtable size: %lu", this->hashtable,
                     this->capacity);
        PLOGI.printf("queue item sz: %d", sizeof(KVQ));
#ifdef BUDDY_QUEUE
        buddy_find_queues =
            (BuddyBuffer **)(aligned_alloc(64, num_threads * sizeof(void *)));

        buddy_insert_queues =
            (BuddyBuffer **)(aligned_alloc(64, num_threads * sizeof(void *)));

        for (int i = 0; i < num_threads; i++) {
          buddy_find_queues[i] = nullptr;
          buddy_insert_queues[i] = nullptr;
        }

        size_t buddy_capacity = 128;  // (this->capacity / config.num_threads);
        size_t bucket_sz = 32;        // buddy_capacity;
        int numa_node;
        int o_numa_node;
        for (int i = 0; i < num_threads; i++) {
          numa_node = i % 2;
          buddy_find_queues[i] =
              new (numa_node) BuddyBuffer(buddy_capacity, bucket_sz, numa_node);
          buddy_insert_queues[i] =
              new (numa_node) BuddyBuffer(buddy_capacity, bucket_sz, numa_node);
        }

#endif
      }
      this->ref_cnt++;
    }

#ifdef BUDDY_QUEUE
    this->tid = sched_getcpu();
    // printf("tid:%d is belongs to node %d\n", tid, numa_node_of_cpu(tid));

    for (int i = 0; i < num_threads; i++) {
      assert(buddy_find_queues[i] != nullptr);
      assert(buddy_insert_queues[i] != nullptr);
    }

    int buddy_cpu = (this->tid % 2 == 0) ? this->tid + 1 : this->tid - 1;
    own_buddy_find_queue = buddy_find_queues[buddy_cpu];
    own_buddy_insert_queue = buddy_insert_queues[buddy_cpu];

    assert(own_buddy_find_queue != nullptr);
    assert(own_buddy_insert_queue != nullptr);
    buddy_find_queue = buddy_find_queues[this->tid];
    buddy_insert_queue = buddy_insert_queues[this->tid];

    // just to be safe
    // buddy_local_writer_buffer_idx = 0;
    // assert(reinterpret_cast<uintptr_t>(&buddy_local_writer_buffer) % 64 ==
    // 0);
#endif
    // this->tid = tid;
    // this->tid = sched_getcpu();
    // printf("Set tid:%d , on cpuid %d\n", this->tid, sched_getcpu());
    this->tid = sched_getcpu();
    this->cpuid = tid >= 28 ? tid - 28 : tid;
    this->empty_item = this->empty_item.get_empty_key();
    this->key_length = empty_item.key_length();
    this->data_length = empty_item.data_length();

    PLOGV << "Empty item: " << this->empty_item;

#ifdef REMOTE_QUEUE
    this->remote_find_queue_sz = find_queue_sz * 2;
    this->remote_find_queue =
        (KVQ *)(aligned_alloc(64, remote_find_queue_sz * sizeof(KVQ)));
    this->REMOTE_FIND_QUEUE_SZ_MASK = this->remote_find_queue_sz - 1;

    this->remote_find_head = 0;
    this->remote_find_tail = 0;
#endif

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
#ifdef BUDDY_QUEUE
    delete buddy_find_queue;
    delete buddy_insert_queue;
#endif
    // Deallocate the global hashtable if ref_cnt goes down to zero.
    {
      const std::lock_guard<std::mutex> lock(ht_init_mutex);
      this->ref_cnt--;
      if (this->ref_cnt == 0) {
        free_mem<KV>(this->hashtable, this->capacity, this->id, this->fd);
        this->hashtable = nullptr;
#ifdef BUDDY_QUEUE
        free(buddy_find_queues);
        free(buddy_insert_queues);
#endif
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
      this->ins_tail++;
      this->ins_tail &= INSERT_QUEUE_SZ_MASK;
      curr_queue_sz = get_insert_queue_sz();
    }
    return;
  }

  inline void pop_insert_queue(collector_type *collector) {
    uint64_t retry = 0;
    uint32_t next_tail;
    const void *next_tail_addr;
    do {
      next_tail = (this->ins_tail + PREFETCH_INSERT_NEXT_DISTANCE) &
                  INSERT_QUEUE_SZ_MASK;
      next_tail_addr = &this->hashtable[this->insert_queue[next_tail].idx];
      __builtin_prefetch(next_tail_addr, false, 3);

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
    // BuddyBuffer *own_buddy_buffer = buddy_insert_queues[this->tid];
    // uint32_t sz = own_buddy_buffer->size();
    // // printf("SIZE OF BUDDY BUFFER = %d\n", sz);
    // // sz[0-64] == 16
    // if (sz == BuddyBufferLength) {
    //   for (int i = 0; i < sz; i++) {
    //     if ((get_insert_queue_sz() >= INSERT_QUEUE_SZ_MASK)) {
    //       pop_insert_queue(collector);
    //     }
    //     add_to_insert_queue(&(own_buddy_buffer->arr[i]), collector);
    //   }
    //   own_buddy_buffer->reset_buffer();
    // }
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
    size_t curr_queue_sz = get_insert_queue_sz();

    while (curr_queue_sz != 0) {
      __insert_one(&this->insert_queue[this->ins_tail], collector);
      this->ins_tail++;
      this->ins_tail &= INSERT_QUEUE_SZ_MASK;
      curr_queue_sz = get_insert_queue_sz();
    }

    // all store must be flushed.
    _mm_sfence();
  }

  void flush_find_queue(ValuePairs &vp, collector_type *collector) override {}

  uint32_t cas_flush_find_queue(ValuePairs &vp, collector_type *collector) {
    size_t curr_queue_sz = get_find_queue_sz();

    while ((curr_queue_sz != 0) && (vp.first < config.batch_len)) {
      __find_one(&this->find_queue[this->find_tail], vp, collector);
      this->find_tail++;
      this->find_tail &= FIND_QUEUE_SZ_MASK;
      curr_queue_sz = get_find_queue_sz();
    }

#ifdef REMOTE_QUEUE
    size_t remote_curr_queue_sz =
        (this->remote_find_head - this->remote_find_tail) &
        REMOTE_FIND_QUEUE_SZ_MASK;

    while ((remote_curr_queue_sz != 0) && (vp.first < config.batch_len)) {
      __remote_find_one(&this->remote_find_queue[this->remote_find_tail], vp,
                        collector);
      this->remote_find_tail++;
      if (this->remote_find_tail == remote_find_queue_sz)
        this->remote_find_tail = 0;
      remote_curr_queue_sz = (this->remote_find_head - this->remote_find_tail) &
                             REMOTE_FIND_QUEUE_SZ_MASK;
    }
    return remote_curr_queue_sz + curr_queue_sz;
#endif

    return curr_queue_sz;
  }

  inline size_t get_find_queue_sz() {
    return (this->find_head - this->find_tail) & FIND_QUEUE_SZ_MASK;
  }
#ifdef REMOTE_QUEUE
  inline size_t get_remote_find_queue_sz() {
    return (this->remote_find_head - this->remote_find_tail) &
           REMOTE_FIND_QUEUE_SZ_MASK;
  }
#endif

  inline void flush_if_needed(ValuePairs &vp, collector_type *collector) {
    size_t curr_queue_sz = get_find_queue_sz();

    while ((curr_queue_sz > FLUSH_THRESHOLD) && (vp.first < config.batch_len)) {
      __find_one(&this->find_queue[this->find_tail], vp, collector);
      this->find_tail++;
      this->find_tail &= FIND_QUEUE_SZ_MASK;
      curr_queue_sz = get_find_queue_sz();
    }
    return;
  }

  inline void pop_find_queue(ValuePairs &vp, collector_type *collector) {
    uint64_t retry = 0;
    uint32_t next_tail;
    const void *next_tail_addr;
    do {
      next_tail =
          (this->find_tail + PREFETCH_FIND_NEXT_DISTANCE) & FIND_QUEUE_SZ_MASK;
      next_tail_addr = &this->hashtable[this->find_queue[next_tail].idx];
      __builtin_prefetch(next_tail_addr, false, 3);
      retry = __find_one(&this->find_queue[this->find_tail], vp, collector);
      this->find_tail++;
      this->find_tail &= FIND_QUEUE_SZ_MASK;

    } while ((retry));
  }

#ifdef REMOTE_QUEUE
  inline void pop_remote_find_queue(ValuePairs &vp, collector_type *collector) {
    uint64_t retry = 0;
    do {
      retry = __remote_find_one(
          &this->remote_find_queue[this->remote_find_tail], vp, collector);
      this->remote_find_tail++;
      this->remote_find_tail &= REMOTE_FIND_QUEUE_SZ_MASK;
      __builtin_prefetch(
          &this->hashtable[this->remote_find_queue[this->remote_find_tail].idx],
          false, 3);
    } while ((retry));
  }
#endif

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

#ifdef CAS_FIND_BANDWIDTH_TEST
    size_t idx;
    uint64_t len = this->capacity >> 2;
    // uint64_t len = this->capacity;
    for (auto &data : kp) {
      idx = _mm_crc32_u64(0xffffffff, data.key) & (len - 1);
      idx = idx << 2;  // idx * 4
      __builtin_prefetch(&this->hashtable[idx], false, 1);
    }
    return;
#endif

#ifdef REMOTE_QUEUE
    for (auto &data : kp) {
      if (is_remote(&data)) {
        if ((get_remote_find_queue_sz() >= REMOTE_FIND_QUEUE_SZ_MASK)) {
          pop_remote_find_queue(values, collector);
        }
        add_to_remote_find_queue(&data, collector);
      } else {
        if ((get_find_queue_sz() >= FIND_QUEUE_SZ_MASK)) {
          pop_find_queue(values, collector);
        }
        add_to_find_queue(&data, collector);
      }
    }
    return;
#endif

#ifdef BUDDY_QUEUE
    uint64_t *addr = nullptr;  // cacheline X
                               // remote read core 0      local write core 1
                               // write [] full,
                               // local write
    if (own_buddy_find_queue->read(
            &addr)) {  // remote read, -> line exclusive in another core
      //__builtin_prefetch(addr, false, 3);  cmake -S . -B build
      //-DOLD_DRAMHiT=ON -DBUCKETIZATION=OFF -DBRANCH=branched
      //-DDRAMHiT_MANUAL_INLINE=OFF -DUNIFORM_PROBING=OFF
      // local write, c
    }
    // __builtin_prefetch(&buddy_current, false, 3);
    // bool flush_remote = own_buddy_find_queue->is_full();
    // if (flush_remote) {
    //   __builtin_prefetch(&(own_buddy_find_queue->arr), false, 3);
    //   __builtin_prefetch(&(own_buddy_find_queue->sz), false, 3);

    // if ((get_find_queue_sz() >= FIND_QUEUE_SZ_MASK)) {
    //       pop_find_queue(values, collector);
    //     }
    //     add_to_find_queue(&data, collector);
    //  }
#endif

    if ((get_find_queue_sz() >= FIND_QUEUE_SZ_MASK)) {
      for (auto &data : kp) {
#ifdef BUDDY_QUEUE
        if (add_to_buddy_find_queue(&data)) {
          continue;
        }
#endif

        pop_find_queue(values, collector);
        add_to_find_queue(&data, collector);
      }
    } else {
      for (auto &data : kp) {
#ifdef BUDDY_QUEUE
        if (add_to_buddy_find_queue(&data)) {
          continue;
        }
#endif
        if ((get_find_queue_sz() >= FIND_QUEUE_SZ_MASK)) {
          pop_find_queue(values, collector);
        }
        add_to_find_queue(&data, collector);
      }
    }

#ifdef BUDDY_QUEUE
    // if (addr != nullptr) {
    //   // __m512i simd512;
    //   // alignas(64) uint64_t local_cacheline[8];
    //   // simd512 = _mm512_load_si512(addr);
    //   // _mm512_store_si512(local_cacheline, simd512);

    //   for (int i = 0; i < 8; i += 2) {
    //     if ((get_find_queue_sz() >= FIND_QUEUE_SZ_MASK)) {
    //       pop_find_queue(values, collector);
    //     }
    //     // buddy_add_to_find_queue(local_cacheline[(i)], local_cacheline[(i +
    //     // 1)]);

    //     buddy_add_to_find_queue(addr[(i)], addr[(i + 1)]);
    //   }
    // }
#endif
  }  // end find_batch()

#else

  uint64_t simple_hash64(uint64_t x) {
    x ^= x >> 33;
    x *= 0xff51afd7ed558ccdULL;
    x ^= x >> 33;
    x *= 0xc4ceb9fe1a85ec53ULL;
    x ^= x >> 33;
    return x;
  }

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

  void flush_ht_from_cache() {
    for (size_t i = 0; i < this->capacity; i += 4) {
      _mm_clflush(&this->hashtable[i]);
    }

    // uint64 count = 0;
    // for (int j = 0; j < 10; j++)
    //   // count += this->get_fill();
    //   for (size_t i = 0; i < this->capacity; i += 4) {
    //     //   // _mm_clflush(&this->hashtable[i]);
    //     __builtin_prefetch(&this->hashtable[i], false, 1);
    //     //   // count += this->hashtable[i].kvpair.key;
    //     count++;
    //   }
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

    // return count;
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

#ifdef REMOTE_QUEUE
  KVQ *remote_find_queue;
  uint32_t remote_find_head;
  uint32_t remote_find_tail;
#endif

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
      this->find_head &= FIND_QUEUE_SZ_MASK;

#ifdef CALC_STATS
      this->num_reprobes++;
#endif
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

  uint64_t __find_one(KVQ *q, ValuePairs &vp, collector_type *collector) {
    // #ifdef BUDDY_QUEUE
    //     if (q->value == 0xdeadbeef) {
    //       buddy_find_queue->add_cl((void*)(buddy_local_writer_buffer.slots));
    //       return 0;
    //     }cmake -S . -B build -DOLD_DRAMHiT=ON -DBUCKETIZATION=OFF
    //     -DBRANCH=branched -DDRAMHiT_MANUAL_INLINE=OFF -DUNIFORM_PROBING=OFF

    // #endif

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

#ifdef REMOTE_QUEUE
  uint64_t __remote_find_one(KVQ *q, ValuePairs &vp,
                             collector_type *collector) {
    if (q->key == this->empty_item.get_key()) {
      return __find_empty(q, vp);
    }

    return __remote_find_simd(q, vp);
  }

  uint64_t __remote_find_simd(KVQ *q, ValuePairs &vp) {
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
      this->remote_find_queue[this->remote_find_head].key_hash = hash;
#else
      idx += CACHELINE_SIZE / sizeof(KV);
      idx = idx & (this->capacity - 1);
#endif

#ifdef DRAMHiT_2023
      __builtin_prefetch(&this->hashtable[idx], false, 3);
#else
      __builtin_prefetch(&this->hashtable[idx], false, 1);
#endif

      this->remote_find_queue[this->remote_find_head].key = q->key;
      this->remote_find_queue[this->remote_find_head].key_id = q->key_id;
      this->remote_find_queue[this->remote_find_head].idx = idx;
      this->remote_find_head += 1;
      this->remote_find_head &= REMOTE_FIND_QUEUE_SZ_MASK;
    }

    return retry;
  }

#endif

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
      idx = idx & (this->capacity - 1);
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

    // we first check if key is 0.if we use cas,
    // it will request for exclusive state unneccesarrily.

#ifdef READ_BEFORE_CAS
    if (curr->kvpair.key == 0)
#endif
      if (__sync_bool_compare_and_swap((__int128 *)curr, 0, *(__int128 *)q)) {
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

#ifdef REMOTE_QUEUE

  inline void add_to_remote_find_queue(void *data, collector_type *collector) {
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
    this->remote_find_queue[this->remote_find_head].idx = idx;
    this->remote_find_queue[this->remote_find_head].key = key_data->key;
    this->remote_find_queue[this->remote_find_head].key_id = key_data->id;

#ifdef UNIFORM_HT_SUPPORT
    this->remote_find_queue[this->remote_find_head].key_hash = hash;
#endif

#ifdef LATENCY_COLLECTION
    this->remote_find_queue[this->remote_find_head].timer_id = timer;
#endif

    this->remote_find_head += 1;
    this->remote_find_head &= REMOTE_FIND_QUEUE_SZ_MASK;
  }

  bool is_remote(void *data) {
    InsertFindArgument *key_data = reinterpret_cast<InsertFindArgument *>(data);

    uint64_t hash = this->hash((const char *)&key_data->key);
    size_t idx = hash & (this->capacity - 1);
#ifdef BUCKETIZATION
    idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);
#endif

    return is_remote_addr(idx);
  }

#endif

#ifdef BUDDY_QUEUE

  bool add_to_buddy_find_queue(void *data) {
    InsertFindArgument *key_data = reinterpret_cast<InsertFindArgument *>(data);

    uint64_t hash = this->hash((const char *)&key_data->key);
    size_t idx = hash & (this->capacity - 1);
#ifdef BUCKETIZATION
    idx = idx - (size_t)(idx & KEYS_IN_CACHELINE_MASK);
#endif

    if (is_remote_addr(idx)) {
      return buddy_find_queue->add(key_data->key,
                                   key_data->id);  // queue 0. writer
    }

    return false;
  }

  inline void buddy_add_to_find_queue(uint64_t key, uint64_t id) {
    uint64_t hash = this->hash((const char *)&key);
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
    this->find_queue[this->find_head].key = key;
    this->find_queue[this->find_head].key_id = id;

#ifdef UNIFORM_HT_SUPPORT
    this->find_queue[this->find_head].key_hash = hash;
#endif

#ifdef LATENCY_COLLECTION
    this->find_queue[this->find_head].timer_id = timer;
#endif

    this->find_head += 1;
    this->find_head &= FIND_QUEUE_SZ_MASK;
  }
#endif

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
    // if (is_remote_addr(idx) && buddy_insert_queue->add(key_data->key,
    // key_data->id)) {
    //   return;
    // }
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

#if defined(BUDDY_QUEUE) || defined(REMOTE_QUEUE)
  bool is_remote_addr(uint64_t idx) {
    // odd tid is node 1, even tid is node 0.
    // lower half is node 0, upper half is node 1
    // xor, value needs to be opposite of each other
    return ((tid & 1) == 0) ^ (idx < (this->capacity >> 1));
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
