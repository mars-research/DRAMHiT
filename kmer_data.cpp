#include <cstring>
#include <algorithm>
#include <random>
#include <malloc.h>
#include <iostream>
#include "kmer_struct.h"
#include <unordered_map>
#include "shard.h"
#include <errno.h>

uint64_t KMER_SMALL_POOL_COUNT = 10* 1000000;
uint64_t KMER_BIG_POOL_COUNT = 20 * 1000000;

#ifdef ALPHANUM_KMERS
/* for hash table debug*/
typedef std::unordered_map<std::string, int> std_umap;
std_umap stdu_kmer_ht;

std::string random_alphanum_string( size_t length )
{
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

std::string convertToString(char* a, int size) 
{ 
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

// generate random data
void generate_random_data_small_pool(Shard* sh)
{
	std::string s(LENGTH, 0);

	std::srand(0);

	std::cout << "Populating small kmer pool ... " << std::endl;

	for (size_t i = 0; i < KMER_SMALL_POOL_COUNT; i++) {
		std::generate_n(s.begin(), LENGTH, std::rand);
#ifdef ALPHANUM_KMERS
		s = random_alphanum_string(LENGTH);
#endif
		memcpy(sh->kmer_small_pool[i].data, s.data(), s.length());
	}
}

void populate_big_kmer_pool(Shard* sh)
{
	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_int_distribution<int> udist(0, KMER_SMALL_POOL_COUNT - 1);

	std::cout << "Populate kmer pool of " << KMER_BIG_POOL_COUNT 
		<< " elements " << std::endl;

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
	Shard* sh)
{
/*	 The small pool and big pool is there to carefully control 
	 the ratio of total k-mers to unique k-mers.*/
	KMER_BIG_POOL_COUNT = base * multiplier;
	KMER_SMALL_POOL_COUNT = uniq_cnt;

	std::cout << "Creating SMALL POOL OF " << KMER_SMALL_POOL_COUNT <<
		 " kmers" << std::endl;
	
	sh->kmer_small_pool = (Kmer_s*) memalign(CACHE_LINE_SIZE, 
		sizeof(Kmer_s) * KMER_SMALL_POOL_COUNT);
	
	if (!sh->kmer_small_pool){
		printf("Cannot allocate memory for Kmer small pool %s\n", 
			strerror(errno));
	}

	std::cout << "Creating BIG POOL OF " << KMER_BIG_POOL_COUNT << 
		" kmers" << std::endl;
	
	sh->kmer_big_pool = (Kmer_s*) memalign(CACHE_LINE_SIZE, 
		sizeof(Kmer_s) * KMER_BIG_POOL_COUNT);
	
	if (!sh->kmer_big_pool)
		std::cout << "Cannot allocate memory for Kmer pool" << std::endl;

#ifdef ALPHANUM_KMERS
	stdu_kmer_ht.reserve(KMER_BIG_POOL_COUNT);
#endif
	// Generates random data in the small pool
	generate_random_data_small_pool(sh);

	// populate k-mer data into the big kmer pool
	populate_big_kmer_pool(sh);

	// we are done with small pool. From now on, only big pool matters
	free(sh->kmer_small_pool);

#ifdef ALPHANUM_KMERS
	//print_pool();
#endif
}


