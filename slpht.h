#include "data_types.h"

#define KMER_DATA_LENGTH 50 /* 50 bytes from kmer_struct */
#define KMER_COUNT_LENGTH (CACHE_LINE_SIZE - KMER_DATA_LENGTH) /*14 bytes */

// Assumed PAGE SIZE from getconf PAGE_SIZE
#define PAGE_SIZE 4096

typedef __int128 int128_t;
typedef unsigned __int128 uint128_t;


/* 
Kmer record in the hash table
*/
struct Kmer_r {
	char kmer_data[KMER_DATA_LENGTH];
	uint128_t kmer_count : KMER_COUNT_LENGTH * 8;
}; 
// TODO cache_align
// TODO use char and bit manipulation instead of bit fields in Kmer_r: https://stackoverflow.com/questions/1283221/algorithm-for-copying-n-bits-at-arbitrary-position-from-one-int-to-another

typedef struct Kmer_r Kmer_r; 

class SimpleLinearProbingHashTable {

private:
	Kmer_r* table;
	uint64_t capacity;

	size_t __hash(const base_4bit_t* k){
		// TODO cityhash128?
		uint64_t cityhash =  CityHash64((const char*)k, KMER_DATA_LENGTH);
		return (cityhash % this->capacity);
	}

public: 

	SimpleLinearProbingHashTable(uint64_t c){
		// TODO static cast
		// TODO remove /1000
		// TODO power of 2 table size for ease of mod operations
		this->capacity = c / 1000;
		table = (Kmer_r*)(aligned_alloc(PAGE_SIZE, capacity*sizeof(Kmer_r)));
		memset(table, 0, capacity);
	}

	// TODO Linear Probing for now, quadratic later
	/*
	insert and increment if exists
	*/
	bool insert(const base_4bit_t* kmer_data) {

		uint64_t cityhash_new = CityHash64((const char*)kmer_data, KMER_DATA_LENGTH);
		uint64_t cityhash_ex;
		size_t kmer_idx = cityhash_new % this->capacity;
		size_t probe_idx;
		int terminate = 0;

		// TODO do strcmp? strlen is incorrect
		if(!strlen(table[kmer_idx].kmer_data)){
			memcpy(&table[kmer_idx], kmer_data, KMER_DATA_LENGTH);
			table[kmer_idx].kmer_count++;
			terminate = 1;
		} else {
			cityhash_ex = CityHash64((const char*)&table[kmer_idx], KMER_DATA_LENGTH);
			if (cityhash_ex == cityhash_new){
				table[kmer_idx].kmer_count++;
				terminate = 1;
			} else {
				probe_idx = kmer_idx + 1;
				if (probe_idx == this->capacity-1) {probe_idx = 0;}
			}
		}

		// TODO while compare to what?
		while((!terminate) && (probe_idx != kmer_idx)){
			// TODO do strcmp? strlen is incorrect
			if(!strlen(table[probe_idx].kmer_data)){
				memcpy(&table[probe_idx], kmer_data, KMER_DATA_LENGTH);
				table[probe_idx].kmer_count++;
				terminate = 1;
			} else {
				cityhash_ex = CityHash64((const char*)&table[probe_idx], KMER_DATA_LENGTH);
				if (cityhash_ex == cityhash_new){
					table[probe_idx].kmer_count++;
					terminate = 1;
				} else {
					probe_idx++;
					if (probe_idx == this->capacity) {probe_idx = 0;}
				}
			}
		}
		return (terminate == 0);
	}

};