#ifndef _TEST_CONFIG_H_
#define _TEST_CONFIG_H_

/*
#define KMER_LENGTH		50 // bytes

#define KMER_ALIGNMENT		64

// Allocate kmer->data in aligned fashion
#define CONFIG_ALIGNED_ALLOC

// optimized data placement for easier cache access
// k->uint128, v-> std::pair<Kmer*,Kmer_value_t>
#define CONFIG_OPT_DATA_PLACEMENT

*/

#ifndef FIPC_CACHE_LINE_SIZE
#define FIPC_CACHE_LINE_SIZE	64
#endif

/*
create kmer data (per thread)
*/
#define KMER_CREATE_DATA_BASE	1000000
#define KMER_CREATE_DATA_MULT	2  
#define KMER_CREATE_DATA_UNIQ	1000000

//#define ALPHANUM_KMERS

/* for hash table */
// #define QUADRATIC_REPROBING 
// #define MAX_REPROBES 62 /*from jellyfish*/
// #define ONLY_CITYHASH
// #define NO_INSERTS
// #define ONLY_MEMCPY
#define DO_PREFETCH
//#define NUM_THREADS 1 // TODO have in an argv
//#define CALC_AVG_REPROBES
#define READ_KMERS_FROM_DISK
//#define WRITE_KMERS_TO_DISK

#endif  //_TEST_CONFIG_H_
