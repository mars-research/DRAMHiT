#include "kmer_data.cpp"
// #include "kmer_class.h"
#include "slpht.h"

int main(void) {

	uint64_t base = 100000;
	uint64_t multiplier =2;
	uint64_t uniq_cnt = 100000;
	create_data(base, multiplier, uniq_cnt);	

	// TODO size of hash table should be less than the number of kmers
	auto s = new SimpleLinearProbingHashTable(KMER_BIG_POOL_COUNT);
	
	for (int i = 0; i < KMER_BIG_POOL_COUNT/1000+10; i++) {
		bool x = s->insert((base_4bit_t*)&kmer_big_pool[i]);
		printf("inserted %d, %d\n", i, x);
	}


}
