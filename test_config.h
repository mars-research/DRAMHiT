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

#ifndef FIPC_CACHE_LINE_SIZE
#define FIPC_CACHE_LINE_SIZE	64
#endif
*/

/*
Related to kmer data creation
*/
#define KMER_CREATE_DATA_BASE	1000000
#define KMER_CREATE_DATA_MULT	2  
#define KMER_CREATE_DATA_UNIQ	1000000

// #define ALPHANUM_KMERS

#endif  //_TEST_CONFIG_H_
