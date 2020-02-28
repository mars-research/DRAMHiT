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

#ifndef PAGE_SIZE
#define PAGE_SIZE 4096
#endif

/*
create kmer data (per thread)
*/
#define KMER_CREATE_DATA_BASE	1048576
#define KMER_CREATE_DATA_MULT	1
#define KMER_CREATE_DATA_UNIQ   1048576

#define ALPHANUM_KMERS

/* for hash table */
// #define MAX_REPROBES 62 /*from jellyfish*/
#define NUM_THREADS 1 // TODO have in an argv
//#define READ_KMERS_FROM_DISK
#define WRITE_KMERS_TO_DISK
#define CALC_STATS
////

#endif  //_TEST_CONFIG_H_


/*
39:
524288 
1
1048576

63:
1048576 
1
1048576

86
1048576
2
1048576

98
1048576
4
1048576


*/
