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

/* for hash table */
// #define MAX_REPROBES 62 /*from jellyfish*/
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
