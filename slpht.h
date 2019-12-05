#ifndef _SLPHT_H
#define _SLPHT_H

#include "data_types.h"
#include "city/city.h"
#include "kmer_struct.h"

/* 
4 bits per nucleotide, k=100 => 400 bits (~50 bytes)
3 bits per nucleotide, k=100 => 300 bits (~38 bytes) 
*/
#define KMER_DATA_LENGTH 50 
#define KMER_COUNT_LENGTH 4

// Assumed PAGE SIZE from getconf PAGE_SIZE
#define PAGE_SIZE 4096

// typedef __int128 int128_t;
// typedef unsigned __int128 uint128_t;

/* 
Kmer record in the hash table
Each record spills over a cache line for now, cache-align later
*/

typedef struct {
	char kmer_data[KMER_DATA_LENGTH];
	uint32_t kmer_count;
} __attribute__((packed)) Kmer_r; 
// TODO use char and bit manipulation instead of bit fields in Kmer_r: https://stackoverflow.com/questions/1283221/algorithm-for-copying-n-bits-at-arbitrary-position-from-one-int-to-another
// TODO how long should be the count variable?
// TODO should we pack the struct?

class SimpleLinearProbingHashTable {

private:
	Kmer_r* table;
	uint64_t capacity;
	Kmer_r empty_kmer_r; // for comparison for empty slot

	size_t __hash(const base_4bit_t* k){
		uint64_t cityhash =  CityHash64((const char*)k, KMER_DATA_LENGTH);
		return (cityhash % this->capacity);
	}

public: 

	SimpleLinearProbingHashTable(uint64_t c){
		// TODO static cast
		// TODO power of 2 table size for ease of mod operations
		this->capacity = c;
		table = (Kmer_r*)(aligned_alloc(PAGE_SIZE, capacity*sizeof(Kmer_r)));
		memset(table, 0, capacity*sizeof(Kmer_r));
		memset(&this->empty_kmer_r, 0, sizeof(Kmer_r));
	}

	/*
	insert and increment if exists
	*/
	// TODO Linear Probing for now, quadratic later
	bool insert(const base_4bit_t* kmer_data) {

		uint64_t cityhash_new = CityHash64((const char*)kmer_data, KMER_DATA_LENGTH);
		size_t kmer_idx = cityhash_new % this->capacity;
		size_t probe_idx;
		int terminate = 0;

		/* Compare with empty kmer to check if bucket is empty.
		   if yes, insert with a count of 1*/
		// TODO memcmp compare SIMD?
		if(memcmp(&table[kmer_idx], &empty_kmer_r.kmer_data, KMER_DATA_LENGTH) == 0){
			memcpy(&table[kmer_idx], kmer_data, KMER_DATA_LENGTH);
			table[kmer_idx].kmer_count++;
			terminate = 1;
		/* If bucket is occpuied, check if it is occupied by the kmer 
		   we want to insert. If yes, just increment count.*/
		} else if (memcmp(&table[kmer_idx], kmer_data, KMER_DATA_LENGTH) == 0) {
			table[kmer_idx].kmer_count++;
			terminate = 1;
		/* If bucket is occupied, but not by the kmer we want to insert, 
		   reprobe  */
		} else {
			probe_idx = kmer_idx + 1;
			if (probe_idx == this->capacity-1) {
				probe_idx = 0;
			}
		}

		/* reprobe */
		while((!terminate) && (probe_idx != kmer_idx)){
			if(memcmp(&table[probe_idx], &empty_kmer_r.kmer_data, KMER_DATA_LENGTH) == 0){
				memcpy(&table[probe_idx], kmer_data, KMER_DATA_LENGTH);
				table[probe_idx].kmer_count++;
				terminate = 1;
			} else if (memcmp(&table[probe_idx], kmer_data, KMER_DATA_LENGTH) == 0) {
				table[probe_idx].kmer_count++;
				terminate = 1;
			} else {
				probe_idx++;
				if (probe_idx == this->capacity) {
					probe_idx = 0;
				}
			}
		}
		return (terminate == 0);
	}

	void print_c(char* s){
		for(int i = 0; i<LENGTH; i++){
			printf("%c", s[i]);
		}
	}

	void display(){
		for (size_t i = 0; i<this->capacity; i++){
			for(size_t k = 0; k<LENGTH; k++){
				printf("%c", table[i].kmer_data[k]);
			}	
			printf(": %u\n", table[i].kmer_count);
		}
	}

	size_t count() {
		size_t count = 0;
		for (size_t i = 0; i<this->capacity; i++){
			count += table[i].kmer_count;
		}
		return count;
	}


};


// TODO bloom filters for high frequency kmers?

#endif /* _SLPHT_H_ */