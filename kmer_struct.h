#ifndef _KMER_STRUCT_H
#define _KMER_STRUCT_H

#define LENGTH					50
#define CACHE_LINE_SIZE			64

uint64_t KMER_SMALL_POOL_COUNT; //= 10* 1000000;
uint64_t KMER_BIG_POOL_COUNT; //= 20 * 1000000;


// kmer (key)
struct 	Kmer_s {
		char data[LENGTH];
};

typedef struct Kmer_s Kmer_s;

Kmer_s *kmer_big_pool;
Kmer_s *kmer_small_pool;

#endif /* _KMER_STRUCT_H */
