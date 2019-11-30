/* 
Kmer record in the hash table
*/

#define KMER_DATA_LENGTH 50 /* 50 bytes from kmer_struct */
#define KMER_COUNT_LENGTH (CACHE_LINE_SIZE - KMER_DATA_LENGTH) /*14 bytes */

typedef __int128 int128_t;
typedef unsigned __int128 uint128_t;

struct Kmer_r {
	char kmer_data[KMER_DATA_LENGTH];
	uint128_t kmer_count : KMER_COUNT_LENGTH * 8;
};

typedef struct Kmer_r Kmer_r; 

/*
TODO 
- Use char and bit manipulation instead of bit fields:
https://stackoverflow.com/questions/1283221/algorithm-for-copying-n-bits-at-arbitrary-position-from-one-int-to-another
*/

