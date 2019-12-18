#ifndef _SKHT_H
#define _SKHT_H

#include "data_types.h"
#include "city/city.h"
#include "kmer_struct.h"

// Assumed PAGE SIZE from getconf PAGE_SIZE
#define PAGE_SIZE 4096

#define PREFETCH_CACHE_SIZE 20

/* 
Kmer record in the hash table
Each record spills over a cache line for now, cache-align later
*/

typedef struct {
	char kmer_data[KMER_DATA_LENGTH];
	uint32_t kmer_count; // TODO seems too long
	bool occupied;
} __attribute__((packed)) Kmer_r; 
// TODO use char and bit manipulation instead of bit fields in Kmer_r: 
// https://stackoverflow.com/questions/1283221/algorithm-for-copying-n-bits-at-arbitrary-position-from-one-int-to-another
// TODO how long should be the count variable?
// TODO should we pack the struct?

typedef struct {
	const base_4bit_t* kmer_data_ptr;
	uint64_t kmer_idx;
} Kmer_cache_r; // TODO packed/aligned?

class SimpleKmerHashTable {

private:
	Kmer_r* table;
	uint64_t capacity;
	Kmer_r empty_kmer_r; /* for comparison for empty slot */
	Kmer_cache_r* cache; // TODO prefetch this?
	uint32_t cache_count;
	uint64_t num_reprobes;

	size_t __hash(const base_4bit_t* k)
	{
		uint64_t cityhash =  CityHash64((const char*)k, KMER_DATA_LENGTH);
		return (cityhash % this->capacity);
	}

	bool __insert(const base_4bit_t* kmer_data, size_t kmer_idx)
	{
		size_t probe_idx = kmer_idx;
		int terminate = 0;
		size_t i = 1; /* For counting reprobes in quadratic reprobing */

#ifdef ONLY_MEMCPY
		/* always insert into the same bucket (table[0]), 
			and increment the kmer_count.
		*/
		probe_idx = 0;	// bucket 0
		if (!table[probe_idx].occupied) {;}
		memcpy(&table[probe_idx].kmer_data, kmer_data, KMER_DATA_LENGTH);
		table[probe_idx].kmer_count++;
		terminate = 1;
		return terminate;
	
#endif
		do 
		{
			/* Compare with empty kmer to check if bucket is empty.
			   if yes, insert with a count of 1*/
			// TODO memcmp compare SIMD?
			// TODO have a occupied field instead of memcmp
			if (!table[probe_idx].occupied)
			{
					memcpy(&table[probe_idx].kmer_data, kmer_data, 
						KMER_DATA_LENGTH);
					table[probe_idx].kmer_count++;
					table[probe_idx].occupied = true;
					terminate = 1;
			/* If bucket is occpuied, check if it is occupied by the kmer 
			   we want to insert. If yes, just increment count.*/				
			} else if (memcmp(&table[probe_idx].kmer_data, kmer_data, 
				KMER_DATA_LENGTH) == 0) 
			{	
					table[probe_idx].kmer_count++;
					terminate = 1;
			/* If bucket is occupied, but not by the kmer we want to insert, 
		   		reprobe  */
			} else 
#ifndef QUADRATIC_REPROBING /* Linear reprobe*/
			{
				probe_idx++;
				probe_idx = probe_idx % this->capacity;
#ifdef CALC_AVG_REPROBES
				this->num_reprobes++;
#endif
			}
		} while(!terminate && probe_idx != kmer_idx);
#else /* Quadratic reprobe */
			{
				i += 1;
				probe_idx = (probe_idx + i*i) % this->capacity;
#ifdef CALC_AVG_REPROBES
				this->num_reprobes++;
#endif
			}
		} while(!terminate && i < MAX_REPROBES);
#endif

		return terminate;
} 

public: 

	SimpleKmerHashTable(uint64_t c) 
	{
		// TODO static cast
		// TODO power of 2 table size for ease of mod operations
		this->capacity = c;
		table = (Kmer_r*)(aligned_alloc(PAGE_SIZE, capacity*sizeof(Kmer_r)));
		memset(table, 0, capacity*sizeof(Kmer_r));
		memset(&this->empty_kmer_r, 0, sizeof(Kmer_r));

		cache = (Kmer_cache_r*)(aligned_alloc(PAGE_SIZE, 
				PREFETCH_CACHE_SIZE*sizeof(Kmer_cache_r)));
		cache_count = 0;
		num_reprobes = 0;
	}

	~SimpleKmerHashTable(){
		free(table);
		free(cache);
	}

	/* insert and increment if exists */
	bool insert(const base_4bit_t* kmer_data) 
	{

		uint64_t cityhash_new = CityHash64((const char*)kmer_data, 
			KMER_DATA_LENGTH);
		size_t __kmer_idx = cityhash_new % this->capacity;

#ifdef ONLY_CITYHASH
		return true;
#endif

#ifdef DO_PREFETCH
		/* prefetch buckets and store kmer_data pointers in cache */
		// TODO how much to prefetch?
		// TODO if we do prefetch: what to return? API breaks
		__builtin_prefetch(&table[__kmer_idx], 0, 1);
		cache[cache_count].kmer_data_ptr = kmer_data; 
		cache[cache_count].kmer_idx = __kmer_idx;
		cache_count++;

		/* if cache is full, actually insert */
		if (cache_count == PREFETCH_CACHE_SIZE) 
		{
			for (size_t i =0; i<cache_count; i++)
			{
				__insert(cache[i].kmer_data_ptr, cache[i].kmer_idx);
			}
			cache_count = 0;
		}
		return true;
#else
		return __insert(kmer_data, __kmer_idx); 
#endif
	}

	void print_c(char* s)
	{
		for(int i = 0; i<KMER_DATA_LENGTH; i++)
		{
			printf("%c", s[i]);
		}
	}

	void display(){
		uint32_t max = 0;
		for (size_t i = 0; i<this->capacity; i++)
		{
			for(size_t k = 0; k<KMER_DATA_LENGTH; k++)
			{
				printf("%c", table[i].kmer_data[k]);
			}	
			printf(": %u\n", table[i].kmer_count);
		}
	}

	size_t count() 
	{
		size_t count = 0;
		for (size_t i = 0; i<this->capacity; i++)
		{
			count += table[i].kmer_count;
		}
		return count;
	}

	uint64_t get_num_reprobes()
	{
		return this->num_reprobes;
	}


};


// TODO bloom filters for high frequency kmers?

#endif /* _SKHT_H_ */