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
#include <array>
#include "base_kht.hpp"
#include "city/city.h"
#include "dbg.hpp"
#include "helper.hpp"
#include "sync.h"
#include "types.hpp"

#if defined(XX_HASH)
#include "xx/xxhash.h"
#endif

#if defined(XX_HASH_3)
#include "xx/xxh3.h"
#endif

#if defined(BRANCHLESS)
#include <immintrin.h>
#endif

namespace kmercounter {

struct Kmer_KV {
  Kmer_base_t kb;            // 20 + 2 bytes
  uint64_t kmer_hash;        // 8 bytes
  volatile char padding[2];  // 2 bytes
} __attribute__((packed));

static_assert(sizeof(Kmer_KV) % 32 == 0,
              "Sizeof Kmer_KV must be a multiple of 32");

// TODO use char and bit manipulation instead of bit fields in Kmer_KV:
// https://stackoverflow.com/questions/1283221/algorithm-for-copying-n-bits-at-arbitrary-position-from-one-int-to-another
// TODO how long should be the count variable?
// TODO should we pack the struct?

// TODO store org kmer idx, to check if we have wrappd around after reprobe

/*
Kmer q in the hash hashtable
Each q spills over a queue line for now, queue-align later
*/

/*
 * 32 bit magic FNV-1a prime
 */
#define FNV_32_PRIME ((uint32_t)0x01000193)
[[maybe_unused]] static uint32_t hval = 0;

/*
 * fnv_32a_buf - perform a 32 bit Fowler/Noll/Vo FNV-1a hash on a buffer
 *
 * input:
 *	buf	- start of buffer to hash
 *	len	- length of buffer in octets
 *	hval	- previous hash value or 0 if first call
 *
 * returns:
 *	32 bit hash as a static hash type
 *
 * NOTE: To use the recommended 32 bit FNV-1a hash, use FNV1_32A_INIT as the
 * 	 hval arg on the first call to either fnv_32a_buf() or fnv_32a_str().
 */
inline uint32_t fnv_32a_buf(const void *buf, size_t len, uint32_t hval) {
  unsigned char *bp = (unsigned char *)buf; /* start of buffer */
  unsigned char *be = bp + len;             /* beyond end of buffer */

  /*
   * FNV-1a hash each octet in the buffer
   */
  while (bp < be) {
    /* xor the bottom with the current octet */
    hval ^= (uint32_t)*bp++;

    /* multiply by the 32 bit FNV magic prime mod 2^32 */
#if defined(NO_FNV_GCC_OPTIMIZATION)
    hval *= FNV_32_PRIME;
#else
    hval +=
        (hval << 1) + (hval << 4) + (hval << 7) + (hval << 8) + (hval << 24);
#endif
  }

  /* return our new hash value */
  return hval;
}

struct Kmer_queue {
  const void *kmer_p;
  uint32_t kmer_idx;  // TODO reduce size, TODO decided by hashtable size?
  uint8_t pad[4];
#ifdef COMPARE_HASH
  uint64_t kmer_hash;  // 8 bytes
#endif
} __attribute__((packed));

inline std::ostream &operator<<(std::ostream &strm, const Kmer_KV &k) {
  return strm << std::string(k.kb.kmer.data, KMER_DATA_LENGTH) << " : "
              << k.kb.count;
}

/* AB: 1GB page table code is from
 * https://github.com/torvalds/linux/blob/master/tools/testing/selftests/vm/hugepage-mmap.c
 */

#define FILE_NAME "/mnt/huge/hugepagefile%d"

#define MAP_HUGE_1GB (30 << MAP_HUGE_SHIFT)

constexpr auto ADDR = static_cast<void *>(0x0ULL);
constexpr auto PROT_RW = PROT_READ | PROT_WRITE;
constexpr auto MAP_FLAGS =
    MAP_HUGETLB | MAP_HUGE_1GB | MAP_PRIVATE | MAP_ANONYMOUS;
constexpr auto LENGTH = 1ULL * 1024 * 1024 * 1024;

constexpr uint64_t CACHE_BLOCK_BITS = 6;
constexpr uint64_t CACHE_BLOCK_MASK = (1ULL << CACHE_BLOCK_BITS) - 1;

// Which byte offset in its cache block does this address reference?
constexpr uint64_t cache_block_offset(uint64_t addr) {
  return addr & CACHE_BLOCK_MASK;
}
// Address of 64 byte block brought into the cache when ADDR accessed
constexpr uint64_t cache_block_aligned_addr(uint64_t addr) {
  return addr & ~CACHE_BLOCK_MASK;
}

inline constexpr void prefetch_object(const void *addr, uint64_t size) {
  uint64_t cache_line1_addr = cache_block_aligned_addr((uint64_t)addr);

#if defined(PREFETCH_TWO_LINE)
  uint64_t cache_line2_addr =
      cache_block_aligned_addr((uint64_t)addr + size - 1);
#endif

  // 1 -- prefetch for write (vs 0 -- read)
  // 0 -- data has no temporal locality (3 -- high temporal locality)
  //__builtin_prefetch((const void*)cache_line1_addr, 1, 1);

  __builtin_prefetch((const void *)cache_line1_addr, 1, 0);

  //__builtin_prefetch(addr, 1, 0);
#if defined(PREFETCH_TWO_LINE)
  if (cache_line1_addr != cache_line2_addr)
    __builtin_prefetch((const void *)cache_line2_addr, 1, 0);
#endif
}

static inline void prefetch_with_write(Kmer_KV *k) {
  /* if I write occupied I get
   * Prefetch stride: 0, cycles per insertion:122
   * Prefetch stride: 1, cycles per insertion:36
   * Prefetch stride: 2, cycles per insertion:46
   * Prefetch stride: 3, cycles per insertion:44
   * Prefetch stride: 4, cycles per insertion:45
   * Prefetch stride: 5, cycles per insertion:46
   * Prefetch stride: 6, cycles per insertion:46
   * Prefetch stride: 7, cycles per insertion:47
   */
  //  k->occupied = 1;
  /* If I write padding I get
   * Prefetch stride: 0, cycles per insertion:123
   * Prefetch stride: 1, cycles per insertion:104
   * Prefetch stride: 2, cycles per insertion:84
   * Prefetch stride: 3, cycles per insertion:73
   * Prefetch stride: 4, cycles per insertion:66
   * Prefetch stride: 5, cycles per insertion:61
   * Prefetch stride: 6, cycles per insertion:57
   * Prefetch stride: 7, cycles per insertion:55
   * Prefetch stride: 8, cycles per insertion:54
   * Prefetch stride: 9, cycles per insertion:53
   * Prefetch stride: 10, cycles per insertion:53
   * Prefetch stride: 11, cycles per insertion:53
   * Prefetch stride: 12, cycles per insertion:52
   */
  k->padding[0] = 1;
}

template <typename T = Kmer_KV>
class alignas(64) SimpleKmerHashTable : public KmerHashTable {
 public:
  T *hashtable;

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
    if (this->hashtable[i & (this->capacity - 1)].kb.occupied == 0) {
      this->hashtable[i & (this->capacity - 1)].kb.occupied = 1;
    } else {
      this->hashtable[i & (this->capacity - 1)].kb.occupied = 1;
    };
#else
    this->hashtable[i & (this->capacity - 1)].kb.occupied = 1;
#endif
    return 0;
  };

  SimpleKmerHashTable(uint64_t c, uint32_t id) {
    // TODO static cast
    // TODO power of 2 hashtable size for ease of mod operations
    this->capacity = kmercounter::next_pow2(c);
    // printf("[INFO] Hashtable size: %lu\n", this->capacity);
#if !defined(HUGE_1GB_PAGES)
    this->hashtable = (T *)aligned_alloc(PAGE_SIZE, capacity * sizeof(T));
#else
    int fd;
    char mmap_path[256] = {0};

    snprintf(mmap_path, sizeof(mmap_path), FILE_NAME, id);

    fd = open(mmap_path, O_CREAT | O_RDWR, 0755);

    if (fd < 0) {
      dbg("Couldn't open file %s:", mmap_path);
      perror("");
      exit(1);
    } else {
      dbg("opened file %s\n", mmap_path);
    }

    this->hashtable = (T *)mmap(ADDR, /* 256*1024*1024*/ capacity * sizeof(T),
                                PROT_RW, MAP_FLAGS, fd, 0);
    if (this->hashtable == MAP_FAILED) {
      perror("mmap");
      unlink(mmap_path);
      exit(1);
    } else {
      dbg("mmap returns %p\n", this->hashtable);
    }

#endif

    if (this->hashtable == NULL) {
      perror("[ERROR]: SimpleKmerHashTable aligned_alloc");
    }

    memset(hashtable, 0, capacity * sizeof(T));
    memset(&this->null_kmer, 0, sizeof(T));

    this->queue = (Kmer_queue *)(aligned_alloc(
        64, PREFETCH_QUEUE_SIZE * sizeof(Kmer_queue)));
    this->queue_idx = 0;
    dbg("id: %d this->queue %p\n", id, this->queue);
    //    __builtin_prefetch(queue, 1, 3);
  }

  ~SimpleKmerHashTable() {
    free(hashtable);
    free(queue);
    printf("hashtable freed\n");
  }

#if INSERT_BATCH

  insert_one() {
    occupied = this->hashtable[pidx].kb.occupied;

    /* Compare with empty kmer to check if bucket is empty, and insert.*/
    if (!occupied) {
#ifdef CALC_STATS
      this->num_memcpys++;
#endif
      memcpy(&this->hashtable[pidx].kb.kmer.data, q->kmer_p, KMER_DATA_LENGTH);
      this->hashtable[pidx].kb.count++;
      this->hashtable[pidx].kb.occupied = true;
      this->hashtable[pidx].kmer_hash = q->kmer_hash;
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
                 KMER_DATA_LENGTH) == 0) {
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
      // this->queue[this->queue_idx].kmer_p = q->kmer_p;
      // this->queue[this->queue_idx].kmer_idx = q->kmer_idx;
      this->queue_idx++;

#ifdef CALC_STATS
      this->num_reprobes++;
#endif
    }

    void insert_batch(kmer_data_t * karray[4]) {
      uint64_t hash_new_0 = this->hash((const char *)karray[0]);
      size_t __kmer_idx_1 = hash_new & (this->capacity - 1);  // modulo

      uint64_t hash_new_0 = this->hash((const char *)karray[0]);
      size_t __kmer_idx_1 = hash_new & (this->capacity - 1);  // modulo

      uint64_t hash_new_0 = this->hash((const char *)karray[0]);
      size_t __kmer_idx_1 = hash_new & (this->capacity - 1);  // modulo

      uint64_t hash_new_0 = this->hash((const char *)karray[0]);
      size_t __kmer_idx_1 = hash_new & (this->capacity - 1);  // modulo

      return;
    }
  };

#endif

  /* Insert using prefetch: using a dynamic prefetch queue.
          If bucket is occupied, add to queue again to reprobe.
  */
  void __insert(Kmer_queue *q) {
    /* hashtable location at which data is to be inserted */
    size_t pidx = q->kmer_idx;

#ifdef BRANCHLESS
    static_assert(KMER_DATA_LENGTH == 20, "k-mer key size has changed");
    using Kv_mask = std::array<uint32_t, 8>;
    /* The VMASKMOVPS instruction we use to load the key into a ymmx
     * register loads 4-byte (floating point) numbers based on the
     * MSB of the corresponding 4-byte number in the mask register.
     * The first 20 bytes of an entry in the hastable make up the key.
     * Hence, the first 5 (20/4) entries in the array must have their
     * MSB set.
     * NOTE: this is selected when Kmer_base::occupied == 0
     */
    constexpr auto mask_rw = Kv_mask {
      0x80000000, 0x80000000, 0x80000000, 0x80000000,
      0x80000000, 0x0,        0x0,        0x0
    };
    /* When we do not want to read or write, the "mask" must consist
     * of 4-byte numbers with their MSB set to 0.
     * NOTE: this is selected when the index, Kmer_base::occupied == 1
     */
    constexpr auto mask_ignore = Kv_mask {
      0x0, 0x0, 0x0, 0x0,
      0x0, 0x0, 0x0, 0x0
    };
    uint32_t const* const kv_masks[2] =
    {
      mask_rw.data(),
      mask_ignore.data(),
    };
    auto ymm_load = [](const uint32_t* addr)
    {
      return _mm256_load_si256(reinterpret_cast<const __m256i*>(addr));
    };
    auto ymm_maskload = [](const auto* addr, auto mask)
    {
      return _mm256_maskload_epi32(reinterpret_cast<const int*>(addr), mask);
    };
    auto ymm_maskstore = [](auto* addr, auto mask, auto data)
    {
      return _mm256_maskstore_epi32(reinterpret_cast<int*>(addr), mask, data);
    };
    auto ymm_cmp = [](auto a, auto b)
    {
      return _mm256_cmpeq_epi32(a, b);
    };
    auto ymm_movemask = [](auto a)
    {
      return _mm256_movemask_ps(a);
    };

    /* load key mask and new key */
    const auto key_mask = ymm_load(kv_masks[0 /* RW mask */]);
    const auto new_key = ymm_maskload(q->kmer_p, key_mask);

    /* define lambda that tries to insert the requested key at idx,
     * if idx is unoccupied.
     *
     * returns the result of the comparison between the new key
     * and the key at idx */
    auto try_insert = [&](const auto idx)
    {
      /* kv_masks[0] returns a mask that reads/writes;
       * kv_masks[1] returns a mask that does nothing */
      const auto occupied = this->hashtable[idx].kb.occupied;
      auto cond_mask = ymm_load(kv_masks[occupied]);

      /* conditionally store the new key into hashtable[idx] */
      const auto kv_dst = &this->hashtable[idx];
      ymm_maskstore(kv_dst, cond_mask, new_key);

      /* at  this point the key in the hashtable is either equal to
       * the new key (q->kmer_p) or not. compare them */
      const auto key = ymm_maskload(kv_dst, key_mask);
      const auto cmp_raw = ymm_cmp(new_key, key);
      /* ymm_cmp compares the keys as packed 4-byte integers
       * cmp_raw consists of packed 4-byte "result" integers that are
       * 0xFF..FF if the corresponding 4-byte integers in the keys are equal,
       * and 0x00..00 otherwise. testing this is not straight-forward.
       * so, we "compress" the eigth integers into a bit each (MSB). */
      return ymm_movemask(_mm256_castsi256_ps(cmp_raw));
    };

    auto cmp = try_insert(pidx);
    /* cmp is 0xff *IFF* new_key == key at pidx*/
    asm volatile (
        "cmpl $0xFF, %[cmp]\n\t"
        "jne  1\n\t" // local label reprobe

        /* keys are equal
         * this->hashtable[pidx].kb.count++; */
        "inc  %[count]\n\t"
        /* this->hashtable[pidx].kb.occupied = 1; */
        "mov  $1, %[occ]\n\t"
        "ret"
        : [occ]"=rm"(this->hashtable[pidx].kb.occupied),
          [count]"=rm"(this->hashtable[pidx].kb.count)
        : [cmp]"rm"(cmp)
    );

// local label reprobe:
    asm volatile (
        "1:\n\t"
    );
    /* hash collision has occurred */
    pidx++;
    pidx = pidx & (this->capacity - 1);  // modulo

    //   | cacheline |
    //   | i | i + 1 |
    //   In the case where two elements fit in a cacheline, a single prefetch
    //   would bring in both the elements. We need not issue a second one.
    //   Check if pidx points to an entry on a new cacheline.
    asm volatile (
        "andq $0x1, %[pidx]\n\t"
        "jz   2\n\t" // local label prefetch
        :
        : [pidx]"r"(pidx)
    );

    // we can perform a soft reprobe
    cmp = try_insert(pidx);

    /* cmp is 0xff *IFF* new_key == key at pidx*/
    asm volatile (
        "cmpl $0xFF, %[cmp]\n\t"
        "jne  2\n\t" // local label prefetch

        /* keys are equal
         * this->hashtable[pidx].kb.count++; */
        "inc  %[count]\n\t"
        "ret"
        : [count]"=rm"(this->hashtable[pidx].kb.count)
        : [cmp]"rm"(cmp)
    );

// local label prefetch:
    asm volatile (
        "2:\n\t"
    );
    //   pidx now points to an entry in a new cacheline, issue a prefetch
    //   and re-insert into the queue
    prefetch(pidx);
    q->kmer_idx = pidx;

    //this->queue[this->queue_idx] = *q;
    this->queue[this->queue_idx].kmer_p = q->kmer_p;
    this->queue[this->queue_idx].kmer_idx = q->kmer_idx;
    this->queue_idx++;

    return;

#else // ! BRANCHLESS
try_insert:
    /* Compare with empty kmer to check if bucket is empty, and insert.*/
    if (!this->hashtable[pidx].kb.occupied) {
#ifdef CALC_STATS
      this->num_memcpys++;
#endif
      memcpy(&this->hashtable[pidx].kb.kmer.data, q->kmer_p, KMER_DATA_LENGTH);
      this->hashtable[pidx].kb.count++;
      this->hashtable[pidx].kb.occupied = true;
#ifdef COMPARE_HASH
      this->hashtable[pidx].kmer_hash = q->kmer_hash;
#endif
      return;
    }

#ifdef CALC_STATS
    this->num_hashcmps++;
#endif

#ifdef COMPARE_HASH
    if (this->hashtable[pidx].kmer_hash == q->kmer_hash)
#endif
    {
#ifdef CALC_STATS
      this->num_memcmps++;
#endif

      if (memcmp(&this->hashtable[pidx].kb.kmer.data, q->kmer_p,
                 KMER_DATA_LENGTH) == 0) {
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

      //   | cacheline |
      //   | i | i + 1 |
      //   In the case where two elements fit in a cacheline, a single prefetch
      //   would bring in both the elements. We need not issue a second
      //   prefetch.
      if (unlikely(pidx & 0x1)) {
#ifdef CALC_STATS
        this->num_soft_reprobes++;
#endif
        goto try_insert;
      }
      prefetch(pidx);
      q->kmer_idx = pidx;

      //this->queue[this->queue_idx] = *q;
      this->queue[this->queue_idx].kmer_p = q->kmer_p;
      this->queue[this->queue_idx].kmer_idx = q->kmer_idx;
      this->queue_idx++;

#ifdef CALC_STATS
      this->num_reprobes++;
#endif
      return;
    }
#endif // BRANCHLESS
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

  void __insert_into_queue(const void *kmer_data) {
    uint64_t hash_new = this->hash((const char *)kmer_data);
    size_t __kmer_idx = hash_new & (this->capacity - 1);  // modulo
    // size_t __kmer_idx2 = (hash_new + 3) & (this->capacity - 1);  // modulo
    // size_t __kmer_idx = cityhash_new % (this->capacity);

    /* prefetch buckets and store kmer_data pointers in queue */
    // TODO how much to prefetch?
    // TODO if we do prefetch: what to return? API breaks
    this->prefetch(__kmer_idx);
    // this->prefetch(__kmer_idx2);

    // printf("inserting into queue at %u\n", this->queue_idx);
    // for (auto i = 0; i < 10; i++)
    //  asm volatile("nop");
    this->queue[this->queue_idx].kmer_p = kmer_data;
    this->queue[this->queue_idx].kmer_idx = __kmer_idx;
#ifdef COMPARE_HASH
    this->queue[this->queue_idx].kmer_hash = hash_new;
#endif
    this->queue_idx++;
  }

  /* insert and increment if exists */
  bool insert(const void *kmer_data) {
    assert(this->queue_idx < PREFETCH_QUEUE_SIZE);
    __insert_into_queue(kmer_data);

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

  T *find(const void *kmer_data) {
#ifdef CALC_STATS
    uint64_t distance_from_bucket = 0;
#endif
    uint64_t hash_new = this->hash((const char *)kmer_data);

    size_t idx = hash_new & (this->capacity - 1);  // modulo

    int memcmp_res =
        memcmp(&this->hashtable[idx].kb.kmer.data, kmer_data, KMER_DATA_LENGTH);

    while (memcmp_res != 0) {
      idx++;
      idx = idx & (this->capacity - 1);
      memcmp_res = memcmp(&this->hashtable[idx].kb.kmer.data, kmer_data,
                          KMER_DATA_LENGTH);
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
      if (this->hashtable[i].kb.occupied) {
        for (size_t k = 0; k < KMER_DATA_LENGTH; k++) {
          printf("%c", this->hashtable[i].kb.kmer.data[k]);
        }
        printf(": %u\n", this->hashtable[i].kb.count);
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
      if (this->hashtable[i].kb.count > count) {
        count = this->hashtable[i].kb.count;
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
  T null_kmer;        /* for comparison for empty slot */
  Kmer_queue *queue;  // TODO prefetch this?
  uint32_t queue_idx;

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
};

// TODO bloom filters for high frequency kmers?

}  // namespace kmercounter
#endif /* _SKHT_H_ */
