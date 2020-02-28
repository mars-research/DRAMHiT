#include <cstring>
#include <algorithm>
#include <random>
#include <malloc.h>
#include <iostream>
#include "kmer_struct.h"
#include <unordered_map>
#include "shard.h"
#include "test_config.h"
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>

const char* POOL_FILE_FORMAT = "/local/devel/pools/million/39/%02u.bin";

/* TODO: map to hold all generated alphanum kmers and their count*/
/* map should thread-local */

/* Generating alphanum kmers for easier debug */
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

void generate_random_data_small_pool(Shard* sh, uint64_t small_pool_count) 
{
	
	std::string s(KMER_DATA_LENGTH, 0);
	std::srand(0);

#ifndef NDEBUG
	printf("[INFO] Shard %u, Populating SMALL POOL\n", sh->shard_idx);
#endif 
	for (size_t i = 0; i < small_pool_count; i++) 
	{
		std::generate_n(s.begin(), KMER_DATA_LENGTH, std::rand);
#ifdef ALPHANUM_KMERS
		s = random_alphanum_string(KMER_DATA_LENGTH);
#endif
		memcpy(sh->kmer_small_pool[i].data, s.data(), s.length());
	}
}

void populate_big_kmer_pool(Shard* sh, const uint64_t small_pool_count, 
	const uint64_t big_pool_count) 
{
	
	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_int_distribution<int> udist(0, small_pool_count - 1);

#ifndef NDEBUG
	printf("[INFO] Shard %u, Populating kmer BIG POOL of %lu elements\n", 
		sh->shard_idx, big_pool_count);
#endif 

	for (size_t i = 0; i < big_pool_count; i++) 
	{
#ifdef ALPHANUM_KMERS
		size_t idx = udist(gen);
		std::string s = std::string(sh->kmer_small_pool[idx].data, 
			KMER_DATA_LENGTH);
		memcpy(sh->kmer_big_pool[i].data, sh->kmer_small_pool[idx].data, 
			KMER_DATA_LENGTH);		
#else 
		memcpy(sh->kmer_big_pool[i].data, sh->kmer_small_pool[udist(gen)].data, 
			KMER_DATA_LENGTH);
#endif
	}
}

void write_data(Shard* sh, const char* filename, const char* data, 
	uint64_t big_pool_count)
{
	FILE* fp;
	fp = fopen(filename, "wb");
	int res = fwrite(data, KMER_DATA_LENGTH, big_pool_count, fp);
	if (res)
	{
		printf("[INFO] Shard %u, Wrote %d items to file: %s\n", 
			sh->shard_idx, res, filename);
	} else
	{
		printf("[ERROR] Shard %u, cannot read data into big pool\n",
			sh->shard_idx);
	}
	fclose(fp);
}


/*	Touching pages bring mmaped pages into memory. Possibly because we have lot 
of memory, pages are never swapped out. mlock itself doesn't seem to bring pages 
into memory as the interface promises. TODO look into this.	*/

void __attribute__((optimize("O0"))) __touch(char* fmap, size_t sz)
{
	for (int i = 0; i< sz; i+= PAGE_SIZE)
		char temp = fmap[i];
}

char* read_data(Shard* sh, const char* filename,
	uint64_t big_pool_count)
{

	int fd = open(filename, O_RDONLY);
	size_t SIZE = big_pool_count* KMER_DATA_LENGTH;

	printf("[INFO] Shard %u, file %s: size %lu, big_pool_count : %lu \n", 
		sh->shard_idx, filename, SIZE, big_pool_count);
	char* fmap =  (char*) mmap(NULL, SIZE, PROT_READ, MAP_PRIVATE, fd, 0);

	__touch(fmap, SIZE); 

	mlock(fmap, big_pool_count * KMER_DATA_LENGTH);

	printf("[INFO] Shard %u, mlock done\n", sh->shard_idx);

	return fmap;

}

/* 	The small pool and big pool is there to carefully control the ratio of 
total k-mers to unique k-mers.	*/

void create_data(Shard* sh) 
{

	uint64_t KMER_BIG_POOL_COUNT = KMER_CREATE_DATA_BASE * KMER_CREATE_DATA_MULT;
	uint64_t KMER_SMALL_POOL_COUNT = KMER_CREATE_DATA_UNIQ;

#ifndef NDEBUG
	printf("[INFO] Shard %u, Creating kmer SMALL POOL of %lu elements\n", 
		sh->shard_idx, KMER_SMALL_POOL_COUNT);
#endif
	sh->kmer_small_pool = (Kmer_s*) memalign(FIPC_CACHE_LINE_SIZE, 
		sizeof(Kmer_s) * KMER_SMALL_POOL_COUNT);
	
	if (!sh->kmer_small_pool)
	{
		printf("[ERROR] Shard %u, Cannot allocate memory for SMALL POOL\n", 
			sh->shard_idx);
	}
#ifndef NDEBUG
	printf("[INFO] Shard %u Creating kmer BIG POOL of %lu elements\n", 
		sh->shard_idx, KMER_BIG_POOL_COUNT);
#endif
	sh->kmer_big_pool = (Kmer_s*) memalign(FIPC_CACHE_LINE_SIZE, 
		sizeof(Kmer_s) * KMER_BIG_POOL_COUNT);
	
	if (!sh->kmer_big_pool)
	{
		printf("[ERROR] Shard %u, Cannot allocate memory for BIG POOL\n",
			sh->shard_idx);
	}

	char pool_filename[strlen(POOL_FILE_FORMAT)];
	sprintf(pool_filename, POOL_FILE_FORMAT, sh->shard_idx);

#ifdef READ_KMERS_FROM_DISK
	sh->kmer_big_pool = (Kmer_s*) read_data(sh, pool_filename, 
		KMER_BIG_POOL_COUNT);
#else
	generate_random_data_small_pool(sh, KMER_SMALL_POOL_COUNT);
	
	populate_big_kmer_pool(sh, KMER_SMALL_POOL_COUNT, KMER_BIG_POOL_COUNT);
#endif 


#ifdef WRITE_KMERS_TO_DISK
		write_data(sh, pool_filename, (const char*) sh->kmer_big_pool->data,
			KMER_BIG_POOL_COUNT);
#endif

	/* We are done with small pool. From now on, only big pool matters */
	free(sh->kmer_small_pool);
}


