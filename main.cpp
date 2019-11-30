#include "kmer_data.cpp"
#include "kmer_struct.h"
#include "kmer_class.h"
#include "slpht.h"

int main(void) {

	uint64_t base = 100000;
	uint64_t multiplier =2;
	uint64_t uniq_cnt = 100000;
	create_data(base, multiplier, uniq_cnt);	

	Kmer_s empty;
	memset(empty.data, 0x0, sizeof(empty.data));
	Kmer empty_kmer((base_4bit_t*)empty.data, LENGTH);
	for (int i = 0; i < KMER_BIG_POOL_COUNT; i++) {
		// Kmer k = Kmer((base_4bit_t*)kmer_big_pool[i].data, LENGTH);
		Kmer_r *k = (Kmer_r*) malloc(sizeof(Kmer_r));
		memcpy(k->kmer_data, &kmer_big_pool[i], KMER_DATA_LENGTH);
		k->kmer_count = ((uint128_t)0x0000aaaabbbbcccc << 64) | 0xeeeeffff99998887;
		k->kmer_count++;
		printf("kmer_data:\n");
		print_c(k->kmer_data);
		printf("\nkmer_count:\n");
		printf("0x%8x\n", k->kmer_count);
		break;
	}
}

/*main.cpp:
   for i (1...10){
      kmerobj = new Kmer(key, value);
      hashtable.insert(Kmer)
   }*/

/*

kmer_class.cpp:

struct kmer_record {
	data;
	count;
} 64 bit aligned

	array[kmer_record]
	insert():

*/

