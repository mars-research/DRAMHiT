#include "kmer_data.cpp"
#include "slpht.h"
#include "timestamp.h"

typedef SimpleLinearProbingHashTable slpht_map;

int main(void) {

	uint64_t base = 100000;
	uint64_t multiplier =2;
	uint64_t uniq_cnt = 100000;
	create_data(base, multiplier, uniq_cnt);	

	// TODO size of hash table?
	slpht_map slpht_ht(KMER_BIG_POOL_COUNT);
	{
		timestamp t(KMER_BIG_POOL_COUNT, "simple_linear_probing_hash_table");
		for (size_t i = 0; i < KMER_BIG_POOL_COUNT; i++) {
			slpht_ht.insert((base_4bit_t*)&kmer_big_pool[i]);
		}
	}
	std::cout << "kmer count : " << slpht_ht.count() << std::endl;
	slpht_ht.display();
}
