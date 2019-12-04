#include "kmer_data.cpp"
#include "slpht.h"

int main(void) {

	uint64_t base = 1000;
	uint64_t multiplier =2;
	uint64_t uniq_cnt = 100;
	create_data(base, multiplier, uniq_cnt);	

	// TODO size of hash table should be less than the number of kmers
	// KMER_BIG_POOL_COUNT
	auto s = new SimpleLinearProbingHashTable(100);
	
	for (int i = 0; i < 1000; i++) {
		bool x = s->insert((base_4bit_t*)&kmer_big_pool[i]);
		printf("inserted %d, %d\n", i, x);
	}

	s->display();


}
