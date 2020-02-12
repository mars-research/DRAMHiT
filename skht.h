#ifndef _SKHT_H
#define _SKHT_H

#include "data_types.h"
#include "city/city.h"
#include "kmer_struct.h"

// Assumed PAGE SIZE from getconf PAGE_SIZE
#define PAGE_SIZE 4096

#define PREFETCH_QUEUE_SIZE 20
#define PREFETCH_HT_SIZE 20
/* 
Kmer q in the hash hashtable
Each q spills over a queue line for now, queue-align later
*/
typedef struct {
	char kmer_data[KMER_DATA_LENGTH];	// 50
	uint16_t kmer_count;				// 2 
	char padding[12];					// 12 
} __attribute__((packed)) Kmer_ht_r; 

typedef struct {
	bool occupied;			// 1
	Kmer_ht_r* ptr_to_ht;	// 8
	uint64_t cityhash;		// 8
	uint32_t org_idx;		// 4
	char padding[11];		// 11
} __attribute__((packed)) Kmer_ptr_r;


typedef struct {
	union {
		base_4bit_t* ptr_to_pool;
		Kmer_ht_r* ptr_to_ht;	
	};								// 8
	uint32_t insert_idx;			// 4
	uint32_t org_idx;				// 4
	bool swap;						// 1
	uint64_t cityhash;				// 8
	char padding[7];				// 7
} __attribute__((packed)) Kmer_queue_r;

class SimpleKmerHashTable {

private:
	uint64_t capacity;
	Kmer_queue_r* queue; // TODO prefetch this?
	uint32_t queue_idx;
	uint32_t ht_idx;


	size_t __hash(const base_4bit_t* k)
	{
		uint64_t cityhash =  CityHash64((const char*)k, KMER_DATA_LENGTH);
		/* n % d => n & (d - 1) */
		return (cityhash & (this->capacity -1 )); // modulo
	}

	void __insert_into_queue(const base_4bit_t* kmer_data)
	{
		uint64_t cityhash_new = CityHash64((const char*)kmer_data,
			KMER_DATA_LENGTH);

		/* prefetch buckets and store kmer_data pointers in queue */
		// TODO how much to prefetch?
		// TODO if we do prefetch: what to return? API breaks


		//printf("inserting into queue at %u\n", this->queue_idx);
		queue[this->queue_idx].ptr_to_pool = (base_4bit_t*) kmer_data; 
		queue[this->queue_idx].insert_idx = cityhash_new & (this->capacity -1 ); // modulo
		queue[this->queue_idx].org_idx = queue[this->queue_idx].insert_idx;
		queue[this->queue_idx].swap = false;
		queue[this->queue_idx].cityhash = cityhash_new;
		__builtin_prefetch(&pointertable[queue[this->queue_idx].insert_idx], 1, 3);

		this->queue_idx++;
	}

	/* Insert items from queue into hash table, interpreting "queue" 
	as an array of size queue_sz*/
	void __insert_from_queue(size_t queue_sz) {
			this->queue_idx = 0; // start again
			// for (size_t i =0; i < queue_sz; i++)
			// {
			// 	std::cout << queue[i].insert_idx << "|" ;
			// }
			// std::cout << std::endl;
			for (size_t i =0; i < queue_sz; i++)
			{
				__insert(&queue[i]);
			}
			// std::cout << "----------------------" << std:: endl;
	}

	/* Insert using prefetch: using a dynamic prefetch queue.
		If bucket is occupied, add to queue again to reprobe.
	*/
	void __insert(Kmer_queue_r* q)
	{

		uint32_t pidx = q->insert_idx;		// pointertable location at which pointer is to be inserted.
		uint32_t hidx = this->ht_idx;		// hashtable location at which data is to be copied (if needed)

		// std::cout << "[" << pidx << "]\t-> ";

		if (!pointertable[pidx].occupied)
		{

			if (q->swap)
			{
				pointertable[pidx].ptr_to_ht = q->ptr_to_ht;
				// hashtable[hidx].kmer_count = q->ptr_to_ht->kmer_count;
				// std::cout << "INS points to prev ht locn"<< std::endl;
			}	
			else
			{
				memcpy(&hashtable[hidx].kmer_data, q->ptr_to_pool, 
					KMER_DATA_LENGTH);
				hashtable[hidx].kmer_count = 1;
				pointertable[pidx].ptr_to_ht = &hashtable[hidx];
				this->ht_idx++;
				// std::cout << "INS at ht[" <<hidx << "]"<< std::endl;
			}

			pointertable[pidx].occupied = true;
			pointertable[pidx].org_idx = q->org_idx;
			pointertable[pidx].cityhash = q->cityhash;

			return;		
		} 

#ifdef CALC_STATS
		this->num_hashcmps++;
#endif

		if (pointertable[pidx].cityhash == q->cityhash)
		{
			if (memcmp(pointertable[pidx].ptr_to_ht->kmer_data, q->ptr_to_pool, 
						KMER_DATA_LENGTH) == 0) 
			{

#ifdef CALC_STATS
		this->num_memcmps++;
#endif
				//__TODO__ prefetch, how?
				pointertable[pidx].ptr_to_ht->kmer_count++;
				// std::cout << "INC to " << pointertable[pidx].ptr_to_ht->kmer_count << std::endl;
				return;
			}	
		}

		if (__distance_to_bucket(pointertable[pidx].org_idx, pidx) < 
			__distance_to_bucket(q->org_idx, pidx))
		{
			// std::cout << "SWP ptr of pt["<< pidx << "] to ht[" << hidx << "]" << std::endl;
			__insert_and_swap(q);
			return;
		}

		{

			q->insert_idx = (pidx + 1) & (this->capacity - 1); // modulo
			__builtin_prefetch(&pointertable[q->insert_idx], 1, 3);

			// std::cout << "REP at pt[" << pidx + 1 << "]" <<std::endl;

			queue[this->queue_idx] = *q;		// insert back into queue to be reprobed
			this->queue_idx++;

#ifdef CALC_STATS
			this->num_reprobes++;
#endif
			return;
		}
	}

	uint32_t __distance_to_bucket(uint32_t original_bucket_idx, 
		uint32_t probe_bucket_idx)
	{
		return (probe_bucket_idx - original_bucket_idx) & (this->capacity -1); 	// modulo
	}

	void __insert_and_swap( Kmer_queue_r* q){

		uint32_t pidx = q->insert_idx;		// pointertable location at which pointer is to be inserted.
		uint32_t hidx = this->ht_idx;		// hashtable location at which data is to be copied (if needed)

		Kmer_ht_r* temp_h = pointertable[pidx].ptr_to_ht;
		uint32_t temp_o = pointertable[pidx].org_idx;
		uint64_t temp_c = pointertable[pidx].cityhash;

		// if this queue element is already a swap victim
		// it is now being swapped in
		if (q->swap)
		{
			pointertable[pidx].ptr_to_ht = q->ptr_to_ht;
			pointertable[pidx].org_idx = q->org_idx;
			pointertable[pidx].cityhash = q->cityhash;
		} else 
		{
			memcpy(&hashtable[hidx].kmer_data, q->ptr_to_pool, KMER_DATA_LENGTH);
			hashtable[hidx].kmer_count = 1;
			this->ht_idx++;
			pointertable[pidx].ptr_to_ht = &hashtable[hidx];
			pointertable[pidx].org_idx = q->org_idx;
			pointertable[pidx].cityhash = q->cityhash;
		}

		// pointertable[q->insert_idx].occupied = true; // not needed

		q->ptr_to_ht = temp_h;
		q->org_idx = temp_o;
		q->cityhash - temp_c;
		q->insert_idx = (pidx + 1) & (this->capacity -1);
		q->swap = true;
		queue[this->queue_idx] = *q;

		// queue[this->queue_idx].ptr_to_ht = temp_h;		// pointer in queue points to an element in ht which was swapped
		// queue[this->queue_idx].org_idx = temp_o;				
		// queue[this->queue_idx].insert_idx = pidx + 1; 	// after swapping, try inserting at next bucket
		// queue[this->queue_idx].swap = true;

		this->queue_idx++;

		__builtin_prefetch(&pointertable[queue[this->queue_idx].insert_idx], 1, 3);

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
	uint64_t num_hashcmps = 0;
	uint64_t num_queue_flushes = 0;	
	uint64_t max_distance_from_bucket = 0;
#endif
	Kmer_ht_r* hashtable;
	Kmer_ptr_r* pointertable;

	SimpleKmerHashTable(uint64_t c) 
	{
		// TODO static cast
		this->capacity = this->__upper_power_of_two(c);

		this->hashtable = (Kmer_ht_r*)(aligned_alloc(PAGE_SIZE, capacity*sizeof(Kmer_ht_r)));
		memset(hashtable, 0, capacity*sizeof(Kmer_ht_r));
		this->ht_idx = 0;
		// __TODO__
		__builtin_prefetch(hashtable, 1, 3);

		this->pointertable = (Kmer_ptr_r*)(aligned_alloc(PAGE_SIZE, capacity*sizeof(Kmer_ptr_r)));
		memset(pointertable, 0, capacity*sizeof(Kmer_ptr_r));

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
		__insert_into_queue(kmer_data);

		/* if queue is full, actually insert */
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

	Kmer_ht_r* find(const base_4bit_t * kmer_data)
	{
#ifdef CALC_STATS
		uint64_t distance_from_bucket = 0;
#endif
		uint64_t cityhash_new = CityHash64((const char*)kmer_data, 
			KMER_DATA_LENGTH);
		size_t idx = cityhash_new & (this->capacity -1 ); // modulo

		// // std::cout << "pt[" << idx << "]" ;

		int memcmp_res = memcmp(pointertable[idx].ptr_to_ht->kmer_data, 
			kmer_data, KMER_DATA_LENGTH);

		while(memcmp_res != 0)
		{
			idx++;
			idx = idx & (this->capacity -1);
			// // std::cout << ", pt[" << idx << "]" ;
			memcmp_res = memcmp(pointertable[idx].ptr_to_ht->kmer_data, 
				kmer_data, KMER_DATA_LENGTH);
#ifdef CALC_STATS
			distance_from_bucket++;
#endif
		}

		// // std::cout << "\t !! " << std::endl;

#ifdef CALC_STATS
		if (distance_from_bucket > this->max_distance_from_bucket)
			this->max_distance_from_bucket = distance_from_bucket;
#endif

		return pointertable[idx].ptr_to_ht;
	}

	void display()
	{
		// uint32_t max = 0;
		for (size_t i = 0; i<this->capacity; i++)
		{
			if (pointertable[i].occupied) {
				char* pt = pointertable[i].ptr_to_ht->kmer_data;
/*				// std::cout << std::string(pt , KMER_DATA_LENGTH) << " : " \
					<<  pointertable[i].ptr_to_ht->kmer_count << std::endl;*/
			}
		}
	}

	size_t get_fill() 
	{
		size_t count = 0;
		for (size_t i = 0; i<this->capacity; i++)
		{
			if (pointertable[i].occupied)
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


std::ostream& operator<<(std::ostream &strm, const Kmer_ht_r &k) {
    	return strm << std::string(k.kmer_data, KMER_DATA_LENGTH) << " : " << k.kmer_count;
}



// TODO bloom filters for high frequency kmers?

#endif /* _SKHT_H_ */

