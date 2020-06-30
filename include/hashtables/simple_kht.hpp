#ifndef _SKHT_H
#define _SKHT_H

#include "dbg.hpp"
#include <sys/mman.h>
#include "base_kht.hpp"
#include "city/city.h"
#include "types.hpp"

#if defined(XX_HASH)
#include "xx/xxhash.h"
#endif

#if defined(XX_HASH_3)
#include "xx/xxh3.h"
#endif
// #include "kmer_struct.h"

namespace kmercounter {
// 2^21
typedef struct {
  char kmer_data[KMER_DATA_LENGTH];   // 20 bytes
  uint32_t kmer_count;                // 4 bytes // TODO seems too long, max count is ~14
  volatile bool occupied;             // 1 bytes
  uint32_t kmer_cityhash;             // 4 bytes (4B enties is enough)
  volatile char padding[3];           // 3 bytes // TODO remove hardcode
  //uint8_t _pad[32];
} __attribute__((packed)) Kmer_r;

// TODO use char and bit manipulation instead of bit fields in Kmer_r:
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
uint32_t hval = 0; 

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
uint32_t fnv_32a_buf(const void *buf, size_t len, uint32_t hval)
{
  unsigned char *bp = (unsigned char *)buf;	/* start of buffer */
  unsigned char *be = bp + len;		/* beyond end of buffer */

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
    hval += (hval<<1) + (hval<<4) + (hval<<7) + (hval<<8) + (hval<<24);
#endif
  }

  /* return our new hash value */
  return hval;
}


typedef struct {
  const void *kmer_data_ptr;
  uint32_t kmer_idx;       // TODO reduce size, TODO decided by hashtable size?
  uint8_t pad[4];
#ifdef COMPARE_HASH
  uint64_t kmer_cityhash;  // 8 bytes
#endif
} __attribute__((packed)) Kmer_queue_r;

std::ostream &operator<<(std::ostream &strm, const Kmer_r &k)
{
  return strm << std::string(k.kmer_data, KMER_DATA_LENGTH) << " : "
              << k.kmer_count;
}

/* AB: 1GB page table code is from https://github.com/torvalds/linux/blob/master/tools/testing/selftests/vm/hugepage-mmap.c */

#define FILE_NAME "/mnt/huge/hugepagefile%d"
#define LENGTH (1*1024UL*1024*1024)
#define PROTECTION (PROT_READ | PROT_WRITE)

#define MAP_HUGE_1GB    (30 << MAP_HUGE_SHIFT)

/* Only ia64 requires this */
#ifdef __ia64__
#define ADDR (void *)(0x8000000000000000UL)
#define FLAGS (MAP_SHARED | MAP_FIXED)
#else
#define ADDR (void *)(0x0UL)
#define FLAGS (MAP_HUGETLB | MAP_HUGE_1GB | MAP_PRIVATE | MAP_ANONYMOUS )
#endif

#define CACHE_BLOCK_BITS 6
#define CACHE_BLOCK_SIZE (1ULL << CACHE_BLOCK_BITS)  /* 64 */
#define CACHE_BLOCK_MASK (CACHE_BLOCK_SIZE - 1)    /* 63, 0x3F */

/* Which byte offset in its cache block does this address reference? */
#define CACHE_BLOCK_OFFSET(ADDR) ((ADDR) & CACHE_BLOCK_MASK)

/* Address of 64 byte block brought into the cache when ADDR accessed */
#define CACHE_BLOCK_ALIGNED_ADDR(ADDR) ((ADDR) & ~CACHE_BLOCK_MASK)

static inline void prefetch_object(const void *addr, uint64_t size) {
  uint64_t cache_line1_addr = CACHE_BLOCK_ALIGNED_ADDR((uint64_t)addr);

#if defined(PREFETCH_TWO_LINE)
  uint64_t cache_line2_addr = CACHE_BLOCK_ALIGNED_ADDR((uint64_t)addr + size - 1);
#endif

  // 1 -- prefetch for write (vs 0 -- read)
  // 0 -- data has no temporal locality (3 -- high temporal locality)
  //__builtin_prefetch((const void*)cache_line1_addr, 1, 1);

  __builtin_prefetch((const void*)cache_line1_addr, 1, 0);

  //__builtin_prefetch(addr, 1, 0);
#if defined(PREFETCH_TWO_LINE)
  if (cache_line1_addr != cache_line2_addr)
    __builtin_prefetch((const void*)cache_line2_addr, 1, 0);
#endif	

}

static inline void prefetch_with_write(Kmer_r *k) {
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

class alignas(64) SimpleKmerHashTable : public KmerHashTable
{
 
  public:
  void prefetch(uint64_t i) {
#if defined(PREFETCH_WITH_PREFETCH_INSTR)
    prefetch_object(&this->hashtable[i & (this->capacity - 1)], 
                    sizeof(this->hashtable[i & (this->capacity - 1)]));
#endif

#if defined(PREFETCH_WITH_WRITE)
		prefetch_with_write(&this->hashtable[i & (this->capacity - 1)]);
#endif
  };

  void touch(uint64_t i) {
#if defined(TOUCH_DEPENDENCY)
		if (this->hashtable[i & (this->capacity - 1)].occupied == 0) {
	    this->hashtable[i & (this->capacity - 1)].occupied = 27;
		} else {
			this->hashtable[i & (this->capacity - 1)].occupied = 78;
		};
#else
	  this->hashtable[i & (this->capacity - 1)].occupied = 78;
#endif
  };

 private:
  uint64_t capacity;
  Kmer_r empty_kmer_r;  /* for comparison for empty slot */
  Kmer_queue_r *queue;  // TODO prefetch this?
  uint32_t queue_idx;

  uint64_t __hash(const void *k)
  {
#if defined(CITY_HASH)
    uint64_t cityhash = CityHash64((const char *)k, KMER_DATA_LENGTH);
    return cityhash;
#endif

#if defined(FNV_HASH)
    hval = fnv_32a_buf(k, KMER_DATA_LENGTH, hval);
    return hval;
#endif

#if defined(XX_HASH)
    XXH64_hash_t xxhash = XXH64(k, KMER_DATA_LENGTH, 0);
    return xxhash;
#endif

#if defined(XX_HASH_3)
    XXH64_hash_t xxhash = XXH3_64bits(k, KMER_DATA_LENGTH);
    return xxhash;
#endif

  }


  uint64_t __upper_power_of_two(uint64_t v)
  {
    v--;
    v |= v >> 1;
    v |= v >> 2;
    v |= v >> 4;
    v |= v >> 8;
    v |= v >> 16;
    v |= v >> 32;
    v++;
    return v;
  }

 public:

  Kmer_r *hashtable;

  // https://www.bfilipek.com/2019/08/newnew-align.html
  void* operator new(std::size_t size, std::align_val_t align) {
    auto ptr = aligned_alloc(static_cast<std::size_t>(align), size);

    if (!ptr)
      throw std::bad_alloc{};

    std::cout << "new: " << size << ", align: "
      << static_cast<std::size_t>(align)
      << ", ptr: " << ptr << '\n';

    return ptr;
  }

  SimpleKmerHashTable(uint64_t c, uint32_t id)
  {
    // TODO static cast
    // TODO power of 2 hashtable size for ease of mod operations
    this->capacity = this->__upper_power_of_two(c);
    // printf("[INFO] Hashtable size: %lu\n", this->capacity);
#if !defined(HUGE_1GB_PAGES)
    this->hashtable =
        (Kmer_r *)aligned_alloc(PAGE_SIZE, capacity * sizeof(Kmer_r));
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

		this->hashtable = (Kmer_r *)mmap(ADDR, /* 256*1024*1024*/ capacity * sizeof(Kmer_r), 
																			PROTECTION, FLAGS, fd, 0);
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

    memset(hashtable, 0, capacity * sizeof(Kmer_r));
    memset(&this->empty_kmer_r, 0, sizeof(Kmer_r));

    this->queue = (Kmer_queue_r *)(aligned_alloc(
        64, PREFETCH_QUEUE_SIZE * sizeof(Kmer_queue_r)));
    this->queue_idx = 0;
    dbg("id: %d this->queue %p\n", id, this->queue);
//    __builtin_prefetch(queue, 1, 3);
  }

  ~SimpleKmerHashTable()
  {
    free(hashtable);
    free(queue);
    printf("hashtable freed\n");
  }

#if INSERT_BATCH

  insert_one () {
    
    occupied = this->hashtable[pidx].occupied; 

    /* Compare with empty kmer to check if bucket is empty, and insert.*/
    if (!occupied) {
#ifdef CALC_STATS
      this->num_memcpys++;
#endif
      memcpy(&this->hashtable[pidx].kmer_data, q->kmer_data_ptr, KMER_DATA_LENGTH);
      this->hashtable[pidx].kmer_count++;
      this->hashtable[pidx].occupied = true;
      this->hashtable[pidx].kmer_cityhash = q->kmer_cityhash;
      return;
    }

#ifdef CALC_STATS
    this->num_hashcmps++;
#endif

    if (this->hashtable[pidx].kmer_cityhash == q->kmer_cityhash) {
#ifdef CALC_STATS
      this->num_memcmps++;
#endif

      if (memcmp(&this->hashtable[pidx].kmer_data, q->kmer_data_ptr,
                 KMER_DATA_LENGTH) == 0) {
        this->hashtable[pidx].kmer_count++;
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
      // this->queue[this->queue_idx].kmer_data_ptr = q->kmer_data_ptr;
      // this->queue[this->queue_idx].kmer_idx = q->kmer_idx;
      this->queue_idx++;

#ifdef CALC_STATS
      this->num_reprobes++;
#endif


  }


  void insert_batch(kmer_data_t *karray[4]) {

    uint64_t hash_new_0 = __hash((const char *)karray[0]);
    size_t __kmer_idx_1 = hash_new & (this->capacity - 1);  // modulo
 
    uint64_t hash_new_0 = __hash((const char *)karray[0]);
    size_t __kmer_idx_1 = hash_new & (this->capacity - 1);  // modulo
 
    uint64_t hash_new_0 = __hash((const char *)karray[0]);
    size_t __kmer_idx_1 = hash_new & (this->capacity - 1);  // modulo
 
    uint64_t hash_new_0 = __hash((const char *)karray[0]);
    size_t __kmer_idx_1 = hash_new & (this->capacity - 1);  // modulo
 
      return;
    }

  };
 
#endif

  /* Insert using prefetch: using a dynamic prefetch queue.
          If bucket is occupied, add to queue again to reprobe.
  */
  void __insert(Kmer_queue_r *q)
  {
    /* hashtable location at which data is to be inserted */
    size_t pidx = q->kmer_idx;

  try_insert:
    /* Compare with empty kmer to check if bucket is empty, and insert.*/
    if (!this->hashtable[pidx].occupied) {
#ifdef CALC_STATS
      this->num_memcpys++;
#endif
      memcpy(&this->hashtable[pidx].kmer_data, q->kmer_data_ptr, KMER_DATA_LENGTH);
      this->hashtable[pidx].kmer_count++;
      this->hashtable[pidx].occupied = true;
#ifdef COMPARE_HASH    
      this->hashtable[pidx].kmer_cityhash = q->kmer_cityhash;
#endif
      return;
    }

#ifdef CALC_STATS
    this->num_hashcmps++;
#endif

#ifdef COMPARE_HASH    
    if (this->hashtable[pidx].kmer_cityhash == q->kmer_cityhash)
#endif    
    {
#ifdef CALC_STATS
      this->num_memcmps++;
#endif

      if (memcmp(&this->hashtable[pidx].kmer_data, q->kmer_data_ptr,
                 KMER_DATA_LENGTH) == 0) {
        this->hashtable[pidx].kmer_count++;
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
        this->num_reprobes++;
#endif
        goto try_insert;
      } 
      prefetch(pidx);
      q->kmer_idx = pidx;

      this->queue[this->queue_idx] = *q;
      // this->queue[this->queue_idx].kmer_data_ptr = q->kmer_data_ptr;
      // this->queue[this->queue_idx].kmer_idx = q->kmer_idx;
      this->queue_idx++;

#ifdef CALC_STATS
      this->num_reprobes++;
#endif
      return;
    }
  }



  /* Insert items from queue into hash table, interpreting "queue"
  as an array of size queue_sz*/
  void __insert_from_queue()
  {
    this->queue_idx = 0;  // start again
    for (size_t i = 0; i < PREFETCH_QUEUE_SIZE; i++) {
      __insert(&this->queue[i]);
    }
  }

  void __flush_from_queue(size_t qsize)
  {
    this->queue_idx = 0;  // start again
    for (size_t i = 0; i < qsize; i++) {
      __insert(&this->queue[i]);
    }
  }


  void __insert_into_queue(const void *kmer_data)
  {
    uint64_t hash_new = __hash((const char *)kmer_data);
    size_t __kmer_idx = hash_new & (this->capacity - 1);  // modulo
    //size_t __kmer_idx2 = (hash_new + 3) & (this->capacity - 1);  // modulo
    // size_t __kmer_idx = cityhash_new % (this->capacity);

    /* prefetch buckets and store kmer_data pointers in queue */
    // TODO how much to prefetch?
    // TODO if we do prefetch: what to return? API breaks
    this->prefetch(__kmer_idx);
    //this->prefetch(__kmer_idx2);

    // printf("inserting into queue at %u\n", this->queue_idx);
    //for (auto i = 0; i < 10; i++)
    //  asm volatile("nop");
    this->queue[this->queue_idx].kmer_data_ptr = kmer_data;
    this->queue[this->queue_idx].kmer_idx = __kmer_idx;
#ifdef COMPARE_HASH
    this->queue[this->queue_idx].kmer_cityhash = hash_new;
#endif
    this->queue_idx++;
  }


  /* insert and increment if exists */
  bool insert(const void *kmer_data)
  {
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

    /* if queue is still full, empty it. This is especially needed
    if queue size is small (< 20?) */
    // if (this->queue_idx == PREFETCH_QUEUE_SIZE)
    // {
    // 	this->flush_queue();
    // }
    return true;
  }

  void flush_queue()
  {
    size_t curr_queue_sz = this->queue_idx;
    while (curr_queue_sz != 0) {
      __flush_from_queue(curr_queue_sz);
      curr_queue_sz = this->queue_idx;
    }
#ifdef CALC_STATS
    this->num_queue_flushes++;
#endif
  }

  Kmer_r *find(const void *kmer_data)
  {
#ifdef CALC_STATS
    uint64_t distance_from_bucket = 0;
#endif
    uint64_t hash_new = __hash((const char *)kmer_data);

    size_t idx = hash_new & (this->capacity - 1);  // modulo

    int memcmp_res =
        memcmp(&this->hashtable[idx].kmer_data, kmer_data, KMER_DATA_LENGTH);

    while (memcmp_res != 0) {
      idx++;
      idx = idx & (this->capacity - 1);
      memcmp_res =
          memcmp(&this->hashtable[idx].kmer_data, kmer_data, KMER_DATA_LENGTH);
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

  void display()
  {
    for (size_t i = 0; i < this->capacity; i++) {
      if (this->hashtable[i].occupied) {
        for (size_t k = 0; k < KMER_DATA_LENGTH; k++) {
          printf("%c", this->hashtable[i].kmer_data[k]);
        }
        printf(": %u\n", this->hashtable[i].kmer_count);
      }
    }
  }

  size_t get_fill()
  {
    size_t count = 0;
    for (size_t i = 0; i < this->capacity; i++) {
      if (this->hashtable[i].occupied) {
        count++;
      }
    }
    return count;
  }

  size_t get_capacity() { return this->capacity; }

  size_t get_max_count()
  {
    size_t count = 0;
    for (size_t i = 0; i < this->capacity; i++) {
      if (this->hashtable[i].kmer_count > count) {
        count = this->hashtable[i].kmer_count;
      }
    }
    return count;
  }

  void print_to_file(std::string outfile)
  {
    std::ofstream f;
    f.open(outfile);
    for (size_t i = 0; i < this->get_capacity(); i++) {
      if (this->hashtable[i].kmer_count > 0) {
        f << this->hashtable[i] << std::endl;
      }
    }
  }
};

// TODO bloom filters for high frequency kmers?

} // namespace kmercounter
#endif /* _SKHT_H_ */
