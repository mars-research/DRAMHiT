
#include "kmer_data.cpp"
#include "kmer_struct.h"
#include "kmer_class.h"

/*main.c:
   for i (1...10){
      kmerobj = new Kmer(key, value);
      hashtable.insert(Kmer)
   }*/

int main(void) {

	uint64_t base = 100000;
	uint64_t multiplier =2;
	uint64_t uniq_cnt = 100000;
	create_data(base, multiplier, uniq_cnt);	

	Kmer_s empty;
	memset(empty.data, 0x0, sizeof(empty.data));
	Kmer empty_kmer((base_4bit_t*)empty.data, LENGTH);
	for (int i = 0; i < KMER_BIG_POOL_COUNT; i++) {
		Kmer k = Kmer((base_4bit_t*)kmer_big_pool[i].data, LENGTH);
	}

}


