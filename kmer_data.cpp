#include <cstring>
#include <algorithm>
#include <random>
#include <malloc.h>
#include <iostream>
#include "kmer_struct.h"
#include <unordered_map>
#include "shard.h"

uint64_t KMER_SMALL_POOL_COUNT = 10* 1000000;
uint64_t KMER_BIG_POOL_COUNT = 20 * 1000000;

#ifdef ALPHANUM_KMERS
/* for hash table debug*/
typedef std::unordered_map<std::string, int> std_umap;
std_umap stdu_kmer_ht;

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

void print_pool() {
	for(auto k : stdu_kmer_ht){
		std::cout << k.first << ":" << k.second << std::endl;
	}
}

#endif

void generate_random_data_small_pool(Shard* sh) {
	std::string s(LENGTH, 0);

	std::srand(0);

	printf("[INFO] Shard %u, Populating SMALL POOL\n", sh->shard_idx);

	for (size_t i = 0; i < KMER_SMALL_POOL_COUNT; i++) {
		std::generate_n(s.begin(), LENGTH, std::rand);
#ifdef ALPHANUM_KMERS
		s = random_alphanum_string(LENGTH);
#endif
		memcpy(sh->kmer_small_pool[i].data, s.data(), s.length());
	}
}

void populate_big_kmer_pool(Shard* sh) {
	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_int_distribution<int> udist(0, KMER_SMALL_POOL_COUNT - 1);

	printf("[INFO] Shard %u, Populating kmer BIG POOL of %lu elements\n", 
		sh->shard_idx, KMER_BIG_POOL_COUNT);

	for (size_t i = 0; i < KMER_BIG_POOL_COUNT; i++) {
#ifdef ALPHANUM_KMERS
		size_t idx = udist(gen);
		std::string s = convertToString(sh->kmer_small_pool[idx].data, 
			LENGTH);
		++stdu_kmer_ht[s];
		memcpy(sh->kmer_big_pool[i].data, sh->kmer_small_pool[idx].data, 
			LENGTH);		
#else 
		memcpy(sh->kmer_big_pool[i].data, sh->kmer_small_pool[udist(gen)].data, 
			LENGTH);
#endif
	}
}

void create_data(uint64_t base, uint32_t multiplier, uint32_t uniq_cnt, 
	Shard* sh) {

	/*
	The small pool and big pool is there to carefully control the ratio of 
	total k-mers to unique k-mers.
 	*/

	KMER_BIG_POOL_COUNT = base * multiplier;
	KMER_SMALL_POOL_COUNT = uniq_cnt;

	printf("[INFO] Shard %u, Creating kmer SMALL POOL of %lu elements\n", 
		sh->shard_idx, KMER_SMALL_POOL_COUNT);

	sh->kmer_small_pool = (Kmer_s*) memalign(CACHE_LINE_SIZE, 
		sizeof(Kmer_s) * KMER_SMALL_POOL_COUNT);
	
	if (!sh->kmer_small_pool){
		printf("[ERROR] Shard %u, Cannot allocate memory for SMALL POOL\n", 
			sh->shard_idx);
	}

	printf("[INFO] Shard %u Creating kmer BIG POOL of %lu elements\n", 
		sh->shard_idx, KMER_BIG_POOL_COUNT);
	
	sh->kmer_big_pool = (Kmer_s*) memalign(CACHE_LINE_SIZE, 
		sizeof(Kmer_s) * KMER_BIG_POOL_COUNT);
	
	if (!sh->kmer_big_pool){
		printf("[ERROR] Shard %u, Cannot allocate memory for BIG POOL\n",
			sh->shard_idx);
	}

#ifdef ALPHANUM_KMERS
	stdu_kmer_ht.reserve(KMER_BIG_POOL_COUNT);
#endif
	
	generate_random_data_small_pool(sh);

	populate_big_kmer_pool(sh);

	/* We are done with small pool. From now on, only big pool matters */
	free(sh->kmer_small_pool);

#ifdef ALPHANUM_KMERS
	//	print_pool();
#endif
}


