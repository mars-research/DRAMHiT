#include <cstring>
#include <algorithm>
#include <random>
#include <malloc.h>
#include <iostream>
#include "kmer_struct.h"
#include <unordered_map>
#include "shard.h"
#include "test_config.h"


/* for hash table debug*/
#ifdef ALPHANUM_KMERS

/* TODO: map to hold all generated alphanum kmers and their count*/
/* map should thread-local */

std::string random_alphanum_string( size_t length ) {
    auto randchar = []() -> char
    {
        const char charset[] =
        "0123456789"
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        "abcdefghijklmnopqrstuvwxyz";
        const size_t max_index = (sizeof(charset) - 1);
        return charset[ rand() % max_index ];
    };
    std::string str(length,0);
    std::generate_n( str.begin(), length, randchar );
    return str;
}

std::string convertToString(char* a, int size) { 
    int i; 
    std::string s = ""; 
    for (i = 0; i < size; i++) { 
        s = s + a[i]; 
    } 
    return s;
}

#endif

void generate_random_data_small_pool(Shard* sh, uint64_t* small_pool_count) {
	
	std::string s(LENGTH, 0);
	std::srand(0);

#ifndef NDEBUG
	printf("[INFO] Shard %u, Populating SMALL POOL\n", sh->shard_idx);
#endif 
	for (size_t i = 0; i < *small_pool_count; i++) {
		std::generate_n(s.begin(), LENGTH, std::rand);
#ifdef ALPHANUM_KMERS
		s = random_alphanum_string(LENGTH);
#endif
		memcpy(sh->kmer_small_pool[i].data, s.data(), s.length());
	}
}

void populate_big_kmer_pool(Shard* sh, const uint64_t* small_pool_count, 
	const uint64_t* big_pool_count) 
{
	
	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_int_distribution<int> udist(0, *small_pool_count - 1);

#ifndef NDEBUG
	printf("[INFO] Shard %u, Populating kmer BIG POOL of %lu elements\n", 
		sh->shard_idx, *big_pool_count);
#endif 

	for (size_t i = 0; i < *big_pool_count; i++) {
#ifdef ALPHANUM_KMERS
		size_t idx = udist(gen);
		std::string s = convertToString(sh->kmer_small_pool[idx].data, 
			LENGTH);
		memcpy(sh->kmer_big_pool[i].data, sh->kmer_small_pool[idx].data, 
			LENGTH);		
#else 
		memcpy(sh->kmer_big_pool[i].data, sh->kmer_small_pool[udist(gen)].data, 
			LENGTH);
#endif
	}
}

void create_data(Shard* sh) 
{

	/*
	The small pool and big pool is there to carefully control the ratio of 
	total k-mers to unique k-mers.
 	*/

	uint64_t KMER_BIG_POOL_COUNT = KMER_CREATE_DATA_BASE * KMER_CREATE_DATA_MULT;
	uint64_t KMER_SMALL_POOL_COUNT = KMER_CREATE_DATA_UNIQ;

#ifndef NDEBUG
	printf("[INFO] Shard %u, Creating kmer SMALL POOL of %lu elements\n", 
		sh->shard_idx, KMER_SMALL_POOL_COUNT);
#endif
	sh->kmer_small_pool = (Kmer_s*) memalign(CACHE_LINE_SIZE, 
		sizeof(Kmer_s) * KMER_SMALL_POOL_COUNT);
	
	if (!sh->kmer_small_pool){
		printf("[ERROR] Shard %u, Cannot allocate memory for SMALL POOL\n", 
			sh->shard_idx);
	}
#ifndef NDEBUG
	printf("[INFO] Shard %u Creating kmer BIG POOL of %lu elements\n", 
		sh->shard_idx, KMER_BIG_POOL_COUNT);
#endif
	sh->kmer_big_pool = (Kmer_s*) memalign(CACHE_LINE_SIZE, 
		sizeof(Kmer_s) * KMER_BIG_POOL_COUNT);
	
	if (!sh->kmer_big_pool){
		printf("[ERROR] Shard %u, Cannot allocate memory for BIG POOL\n",
			sh->shard_idx);
	}

	generate_random_data_small_pool(sh, &KMER_SMALL_POOL_COUNT);

	populate_big_kmer_pool(sh, &KMER_SMALL_POOL_COUNT, &KMER_BIG_POOL_COUNT);

	/* We are done with small pool. From now on, only big pool matters */
	free(sh->kmer_small_pool);

}


