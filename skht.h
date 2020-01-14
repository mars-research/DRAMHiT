#ifndef _SKHT_H
#define _SKHT_H

#include "data_types.h"
#include "city/city.h"
#include "kmer_struct.h"

// Assumed PAGE SIZE from getconf PAGE_SIZE
#define PAGE_SIZE 4096

#define PREFETCH_QUEUE_SIZE 20

/* 
Kmer cache_record in the hash hashtable
Each cache_record spills over a queue line for now, queue-align later
*/

//2^21

typedef struct {
	char kmer_data[KMER_DATA_LENGTH]; // 50 bytes
	uint16_t kmer_count; // 2 bytes // TODO seems too long, max count is ~14
	bool occupied; // 1 bytes
	char padding[11]; // 11 bytes // TODO remove hardcode
} __attribute__((packed)) Kmer_r; 
// TODO use char and bit manipulation instead of bit fields in Kmer_r: 
// https://stackoverflow.com/questions/1283221/algorithm-for-copying-n-bits-at-arbitrary-position-from-one-int-to-another
// TODO how long should be the count variable?
// TODO should we pack the struct?

typedef struct {
	const base_4bit_t* kmer_data_ptr;
	uint32_t kmer_idx; // TODO reduce size, TODO decided by hashtable size?
	char padding[4]; // TODO remove hardcode
} __attribute__((packed)) Kmer_queue_r;


class SimpleKmerHashTable {

private:
	uint64_t capacity;
	Kmer_r empty_kmer_r; /* for comparison for empty slot */
	Kmer_queue_r* queue; // TODO prefetch this?
	uint32_t queue_idx;


	size_t __hash(const base_4bit_t* k)
	{
		uint64_t cityhash =  CityHash64((const char*)k, KMER_DATA_LENGTH);
		/* n % d => n & (d - 1) */
		return (cityhash & (this->capacity -1 )); // modulo
	}

	/* Insert items from queue into hash table, interpreting "queue" 
	as an array of size queue_sz*/
	void __insert_from_queue(size_t queue_sz) {
			this->queue_idx = 0; // start again
			for (size_t i =0; i < queue_sz; i++)
			{
#ifndef DYNAMIC_QUEUE
				__insert(queue[i].kmer_data_ptr, queue[i].kmer_idx);
#else
				__insert(&queue[i]);
#endif
			}
	}

	/* Insert using prefetch: using a dynamic prefetch queue.
		If bucket is occupied, add to queue again to reprobe.
	*/
	bool __insert(Kmer_queue_r* cache_record)
	{
		size_t probe_idx = cache_record->kmer_idx;

		/* Compare with empty kmer to check if bucket is empty.
		   if yes, insert with a count of 1*/
		if (!hashtable[probe_idx].occupied)
		{
			memcpy(&hashtable[probe_idx].kmer_data, cache_record->kmer_data_ptr, 
				KMER_DATA_LENGTH);
				hashtable[probe_idx].kmer_count++;
				hashtable[probe_idx].occupied = true;
#ifdef CALC_STATS
				this->num_memcpys++;
#endif
		// TODO replace memcmp with hash?		
		} else if (memcmp(&hashtable[probe_idx].kmer_data, 
			cache_record->kmer_data_ptr, KMER_DATA_LENGTH) == 0) 
		{	
				hashtable[probe_idx].kmer_count++;
#ifdef CALC_STATS
				this->num_memcmps++;
#endif
		} else 
		{
			// insert back into queue
			// prefetch next bucket
			// next bucket will be probed in the next run
			probe_idx++;
			probe_idx = probe_idx & (this->capacity -1); // modulo 
			__builtin_prefetch(&hashtable[probe_idx], 1, 3);
			cache_record->kmer_idx = probe_idx;
			queue[this->queue_idx].kmer_data_ptr = cache_record->kmer_data_ptr; 	
			queue[this->queue_idx].kmer_idx = cache_record->kmer_idx;
			this->queue_idx++;
#ifdef CALC_STATS
			this->num_reprobes++;
#endif
		}

		return (this->queue_idx == PREFETCH_QUEUE_SIZE);
	} 

	/* Insert using prefetch: using a static prefetch queue.
		If bucket is occupied, reprobe till you find an empty bucket. 
	*/
	bool __insert(const base_4bit_t* kmer_data, size_t kmer_idx)
	{
		size_t probe_idx = kmer_idx;
		int terminate = 0;
		size_t q = 1; /* For counting reprobes in quadratic reprobing */

#ifdef CALC_STATS
		/* to calculate no. of reprobes for this insert */
		uint64_t reprobe_num = 0; 
#endif

#ifdef ONLY_MEMCPY
		/* always insert into the same bucket (hashtable[0]), 
			and increment the kmer_count.
		*/
		probe_idx = 0;	// bucket 0
		if (!hashtable[probe_idx].occupied) {;}
		memcpy(&hashtable[probe_idx].kmer_data, kmer_data, KMER_DATA_LENGTH);
		hashtable[probe_idx].kmer_count++;
		terminate = 1;
		return terminate;
	
#endif
		do 
		{
			/* Compare with empty kmer to check if bucket is empty.
			   if yes, insert with a count of 1*/
			// TODO memcmp compare SIMD?
			// TODO have a occupied field instead of memcmp
			if (!hashtable[probe_idx].occupied)
			{
				memcpy(&hashtable[probe_idx].kmer_data, kmer_data, 
					KMER_DATA_LENGTH);
					hashtable[probe_idx].kmer_count++;
					hashtable[probe_idx].occupied = true;
					terminate = 1;
#ifdef CALC_STATS
				this->num_memcpys++;
#endif

			/* If bucket is occpuied, check if it is occupied by the kmer 
			   we want to insert. If yes, just increment count.*/				
			// TODO replace memcmp with hash?		
			} else if (memcmp(&hashtable[probe_idx].kmer_data, kmer_data, 
				KMER_DATA_LENGTH) == 0) 
			{	
					hashtable[probe_idx].kmer_count++;
					terminate = 1;
#ifdef CALC_STATS
				this->num_memcmps++;
#endif
			/* If bucket is occupied, but not by the kmer we want to insert, 
		   		reprobe  */
			} else 
#ifndef QUADRATIC_REPROBING /* Linear reprobe*/
			{
				probe_idx++;
				probe_idx = probe_idx & (this->capacity-1); //modulo
#ifdef CALC_STATS
				this->num_reprobes++;
				reprobe_num++;
#endif
			}
		} while(!terminate && probe_idx != kmer_idx);
#else /* Quadratic reprobe */
			{
				q += 1;
				probe_idx += q*q;
				probe_idx = probe_idx & (this->capacity -1); //modulo
#ifdef CALC_STATS
				this->num_reprobes++;
#endif
			}
		} while(!terminate && q < MAX_REPROBES);
#endif

#ifdef CALC_STATS
		if (reprobe_num > this->max_distance_from_bucket){
			this->max_distance_from_bucket = reprobe_num;
		} 
#endif
		return terminate;
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
#ifdef CALC_STATS
	uint64_t num_reprobes = 0;
	uint64_t num_memcmps = 0;
	uint64_t num_memcpys = 0;
	uint64_t num_queue_flushes = 0;	
	uint64_t max_distance_from_bucket = 0;
#endif
	Kmer_r* hashtable;

	SimpleKmerHashTable(uint64_t c) 
	{
		// TODO static cast
		// TODO power of 2 hashtable size for ease of mod operations
		this->capacity = this->__upper_power_of_two(c);
		this->hashtable = (Kmer_r*)(aligned_alloc(PAGE_SIZE, capacity*sizeof(Kmer_r)));
		memset(hashtable, 0, capacity*sizeof(Kmer_r));
		memset(&this->empty_kmer_r, 0, sizeof(Kmer_r));

		this->queue = (Kmer_queue_r*)(aligned_alloc(PAGE_SIZE, 
				PREFETCH_QUEUE_SIZE*sizeof(Kmer_queue_r)));
		this->queue_idx = 0;
		__builtin_prefetch(queue, 1, 3);
	}

	~SimpleKmerHashTable(){
		free(hashtable);
		free(queue);
	}

	/* insert and increment if exists */
	bool insert(const base_4bit_t* kmer_data) 
	{

		uint64_t cityhash_new = CityHash64((const char*)kmer_data, 
			KMER_DATA_LENGTH);
		size_t __kmer_idx = cityhash_new & (this->capacity -1 ); // modulo 
		//size_t __kmer_idx = cityhash_new % (this->capacity); 

#ifdef ONLY_CITYHASH
		return true;
#endif

		/* prefetch buckets and store kmer_data pointers in queue */
		// TODO how much to prefetch?
		// TODO if we do prefetch: what to return? API breaks
#ifndef DO_PREFETCH
	//bool __insert(const base_4bit_t* kmer_data, size_t kmer_idx)
	__insert(kmer_data, __kmer_idx);
#else

		__builtin_prefetch(&hashtable[__kmer_idx], 1, 3);
		//printf("inserting into queue at %u\n", this->queue_idx);
		queue[this->queue_idx].kmer_data_ptr = kmer_data; 
		queue[this->queue_idx].kmer_idx = __kmer_idx;
		this->queue_idx++;

		/* if queue is full, actually insert */
		// now queue_idx = 20
		while (this->queue_idx >= PREFETCH_QUEUE_SIZE) 
		{
			this->__insert_from_queue(PREFETCH_QUEUE_SIZE);
		}

		/* if queue is still full, empty it. This is especially needed 
		if queue size is small (< 20?) */
		// if (this->queue_idx == PREFETCH_QUEUE_SIZE) 
		// {
		// 	this->flush_queue();			
		// }
#endif
		return true;
	}

	void flush_queue(){
		size_t curr_queue_sz = this->queue_idx;
		while(curr_queue_sz != 0) 
		{
			__insert_from_queue(curr_queue_sz);			
			curr_queue_sz = this->queue_idx;
		}
#ifdef CALC_STATS
		this->num_queue_flushes++;
#endif
	}

	void display(){
		uint32_t max = 0;
		for (size_t i = 0; i<this->capacity; i++)
		{
			if (hashtable[i].occupied) {
				for(size_t k = 0; k<KMER_DATA_LENGTH; k++)
				{
					printf("%c", hashtable[i].kmer_data[k]);
				}	
				printf(": %u\n", hashtable[i].kmer_count);
			}
		}
	}

	size_t get_fill() 
	{
		size_t count = 0;
		for (size_t i = 0; i<this->capacity; i++)
		{
			if (hashtable[i].occupied)
			{
				count++;
			}
		}
		return count;
	}

	size_t get_capacity(){
		return this->capacity;
	}

	size_t get_max_count()
	{
		size_t count = 0;
		for (size_t i = 0; i<this->capacity; i++)
		{
			if (hashtable[i].kmer_count > count)
			{
				count = hashtable[i].kmer_count;
			}
		}
		return count;
	}		

};


std::ostream& operator<<(std::ostream &strm, const Kmer_r &k) {
    	return strm << std::string(k.kmer_data, KMER_DATA_LENGTH) << " : " << k.kmer_count;
}



// TODO bloom filters for high frequency kmers?

#endif /* _SKHT_H_ */

