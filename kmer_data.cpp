#include <cstring>
#include <algorithm>
#include <random>
#include <malloc.h>
#include <iostream>
#include "kmer_struct.h"
#include <unordered_map>

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

void insert_kmer_to_small_pool(std::string &s, int i)
{
	memcpy(kmer_small_pool[i].data, s.data(), s.length());
}

// generate random data
void generate_random_data_small_pool(void)
{
	std::string s(LENGTH, 0);

	std::srand(0);

	std::cout << "Populating small kmer pool ... " << std::endl;

	for (size_t i = 0; i < KMER_SMALL_POOL_COUNT; i++) {
		std::generate_n(s.begin(), LENGTH, std::rand);
#ifdef ALPHANUM_KMERS
		s = random_alphanum_string(LENGTH);
#endif
		insert_kmer_to_small_pool(s, i);
	}
}

void populate_big_kmer_pool(void)
{
	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_int_distribution<int> udist(0, KMER_SMALL_POOL_COUNT - 1);

	std::cout << "Populate kmer pool of " << KMER_BIG_POOL_COUNT << " elements " << std::endl;

	for (size_t i = 0; i < KMER_BIG_POOL_COUNT; i++) {
#ifdef ALPHANUM_KMERS
		size_t idx = udist(gen);
		std::string s = convertToString(kmer_small_pool[idx].data, LENGTH);
		++stdu_kmer_ht[s];
		memcpy(kmer_big_pool[i].data, kmer_small_pool[idx].data, LENGTH);		
#else 
		memcpy(kmer_big_pool[i].data, kmer_small_pool[udist(gen)].data, LENGTH);
#endif
	}
}

void create_data(uint64_t base, uint32_t multiplier, uint32_t uniq_cnt)
{
	// The small pool and big pool is there to carefully control the ratio of total k-mers to unique k-mers.
	KMER_BIG_POOL_COUNT = base * multiplier;
	KMER_SMALL_POOL_COUNT = uniq_cnt;

	std::cout << "Creating SMALL POOL OF " << KMER_SMALL_POOL_COUNT << " kmers" << std::endl;
	kmer_small_pool = (Kmer_s*) memalign(CACHE_LINE_SIZE, sizeof(Kmer_s) * KMER_SMALL_POOL_COUNT);
	if (!kmer_small_pool)
		std::cout << "Cannot allocate memory for small pool" << std::endl;

	std::cout << "Creating BIG POOL OF " << KMER_BIG_POOL_COUNT << " kmers" << std::endl;
	kmer_big_pool = (Kmer_s*) memalign(CACHE_LINE_SIZE, sizeof(Kmer_s) * KMER_BIG_POOL_COUNT);
	if (!kmer_big_pool)
		std::cout << "Cannot allocate memory for Kmer pool" << std::endl;

#ifdef ALPHANUM_KMERS
	stdu_kmer_ht.reserve(KMER_BIG_POOL_COUNT);
#endif
	// Generates random data in the small pool
	generate_random_data_small_pool();

	// populate k-mer data into the big kmer pool
	populate_big_kmer_pool();

	// we are done with small pool. From now on, only big pool matters
	free(kmer_small_pool);

#ifdef ALPHANUM_KMERS
	print_pool();
#endif
}


