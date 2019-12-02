#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include "kmer_struct.h"

void insert_kmer_to_small_pool(char* s, size_t i)
{
	memcpy(kmer_small_pool[i].data, s, LENGTH);
}

void print_c(char* s){
	for(int i = 0; i<LENGTH; i++){
		printf("%c", s[i]);
	}
}

void print_pools(){
	printf("\n############################\n");
	for(int i = 0; i<KMER_SMALL_POOL_COUNT; i++){
		print_c(kmer_small_pool[i].data);
		printf("\n=================\n");
	}

	printf("\n############################\n");
	for(int i = 0; i<KMER_BIG_POOL_COUNT; i++){
		print_c(kmer_big_pool[i].data);
		printf("\n=================\n");
	}	
}

// generate random data
void generate_random_data_small_pool(void)
{
	size_t i, j;
	char s[LENGTH] = {'\0'};

	srand(0);
	
	printf("Populating small kmer pool ...\n");

	for (i = 0; i < KMER_SMALL_POOL_COUNT; i++) {
		
		/* rand() returns an int. to fill up char array, we need to memcpy.
		*/
		for (j =0; j<LENGTH-sizeof(int); j+=sizeof(int)){
			int r = random();
			memcpy(s+j, &r, sizeof(int));			
		}
		/* copy remaining */
		int r = random();
		memcpy(s+j, &r, LENGTH-j);			

		// print_generated_data(s);
		insert_kmer_to_small_pool(s, i);
	}
}

void populate_big_kmer_pool(void)
{
	srand(11);
	int r;
	for (int i = 0; i < KMER_BIG_POOL_COUNT; i++) {		
		r = rand() % KMER_SMALL_POOL_COUNT;
		memcpy(kmer_big_pool[i].data, kmer_small_pool[r].data, LENGTH);
	}	
}


void create_data(uint64_t base, uint32_t multiplier, uint32_t uniq_cnt)
{
	/* 
	The small pool and big pool is there to carefully control 
	the ratio of total k-mers to unique k-mers.
	*/
	KMER_BIG_POOL_COUNT = base * multiplier;
	KMER_SMALL_POOL_COUNT = uniq_cnt;

	printf("Creating kmer data\n");
	printf("KMER_SMALL_POOL_COUNT: %lu\n", KMER_SMALL_POOL_COUNT);
	printf("KMER_BIG_POOL_COUNT: %lu\n", KMER_BIG_POOL_COUNT);

	kmer_big_pool = (Kmer_s*) malloc(sizeof(Kmer_s) * KMER_BIG_POOL_COUNT);
	kmer_small_pool = (Kmer_s*) malloc(sizeof(Kmer_s) * KMER_SMALL_POOL_COUNT);

	if (!kmer_small_pool)
		printf("Cannot allocate memory for small pool\n" );

	if (!kmer_big_pool)
		printf("Cannot allocate memory for big pool\n");

	// Generates random data in the small pool
	generate_random_data_small_pool();

	// populate k-mer data into the big kmer pool
	populate_big_kmer_pool();

	// print_pools();

	// we are done with small pool. From now on, only big pool matters
	free(kmer_small_pool);
}

