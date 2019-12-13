#include "kmer_data.cpp"
#include "skht.h"
#include "timestamp.h"
#include "numa.hpp"
#include "test_config.h"
#include "shard.h"
#include <pthread.h>
#include <errno.h>
#include "libfipc_test_time.h"

// TODO Where do you get this from?
#define CPUFREQ_HZ				(2500.0 * 1000000)
static const float one_cycle_ns = ((float)1000000 / CPUFREQ_HZ);

#define fipc_test_FAI(X)       __sync_fetch_and_add( &X, 1 )
#define fipc_test_FAD(X)       __sync_fetch_and_add( &X, -1 )
#define fipc_test_mfence()   asm volatile ( "mfence" : : )
#define fipc_test_pause()    asm volatile ( "pause\n": : :"memory" );
static uint64_t ready = 0;
static uint64_t ready_threads=0;

/* Numa config */
Numa n;
std::vector <numa_node> nodes = n.get_node_config();

/* Test config */
typedef struct{
	uint32_t thread_idx; // set before calling create_shards
	uint64_t base; // set before calling create_shards
	uint64_t multiplier; // set before calling create_shards
	uint64_t uniq_cnt; // set before calling create_shards
	Shard* shard; // to be set by create_shards
	uint64_t insertion_cycles; //to be set by create_shards
} thread_data;

typedef SimpleKmerHashTable skht_map;

void* create_shards(void *arg) {

	thread_data* td = (thread_data*) arg;
	uint64_t start, end;
#ifndef NDEBUG
	printf("[INFO] Thread %u. Creating new shard\n", td->thread_idx);
#endif
	Shard* s = (Shard*)memalign(CACHE_LINE_SIZE, sizeof(Shard));
	td->shard = s;
	td->shard->shard_idx = td->thread_idx;
	create_data(td->base, td->multiplier, td->uniq_cnt, td->shard);

	size_t HT_SIZE = td->base * td->multiplier;

	/* Create hash table */
	skht_map skht_ht(HT_SIZE);
	
	fipc_test_FAI(ready_threads);

	while(!ready)
		fipc_test_pause();

	// fipc_test_mfence();

	start = RDTSC_START();

	for (size_t i = 0; i < HT_SIZE; i++) {
		bool res = skht_ht.insert((base_4bit_t*)&td->shard->kmer_big_pool[i]);
		if (!res){
			printf("FAIL\n");
		}
	}

	end = RDTSCP();
	td->insertion_cycles = (end - start);
	fipc_test_FAD(ready_threads);

	return NULL;
}	

int spawn_shard_threads(uint32_t num_shards) {
	
	cpu_set_t cpuset; 
	int s;
	size_t i;

	// TODO malloc vs. memalign?
	// threads = (pthread_t*) malloc(sizeof(pthread_t*) * num_shards);

	pthread_t* threads = (pthread_t*) memalign(CACHE_LINE_SIZE, 
			sizeof(pthread_t) * num_shards);
	// thread_data all_td[num_shards] = {{0}};
	thread_data* all_td = (thread_data*) memalign(CACHE_LINE_SIZE, 
			sizeof(thread_data)*num_shards);

	memset(all_td, 0, sizeof(thread_data*)*num_shards);
	
	for (i = 0; i < num_shards; i++){

		// TODO memalign vs malloc?
		// thread_data *td = (thread_data*) memalign(CACHE_LINE_SIZE, 
		// 	sizeof(thread_data));
		thread_data *td = &all_td[i];
		td->thread_idx = i;
		td->base = KMER_CREATE_DATA_BASE / num_shards;
		td->multiplier = KMER_CREATE_DATA_MULT;
		td->uniq_cnt = KMER_CREATE_DATA_UNIQ / num_shards;

		s = pthread_create(&threads[i], NULL, create_shards, (void*)td);
  		if (s != 0){
  			printf("[ERROR] pthread_create: Could not create create_shard \
  				thread");
			exit(-1);
  		}
		CPU_ZERO(&cpuset);
#ifndef NDEBUG
		printf("[INFO] thread: %lu, affinity: %u,\n", i, nodes[0].cpu_list[i]);
#endif
		CPU_SET(nodes[0].cpu_list[i], &cpuset);
		pthread_setaffinity_np(threads[i], sizeof(cpu_set_t), &cpuset);
	}

	CPU_ZERO(&cpuset);
	/* last cpu of last node  */
	auto last_numa_node = nodes[n.get_num_nodes()-1];
	CPU_SET(last_numa_node.cpu_list[last_numa_node.num_cpus -1], 
		&cpuset);
	sched_setaffinity(0, sizeof(cpu_set_t), &cpuset);

	while(ready_threads < num_shards)
		fipc_test_pause();

	// fipc_test_mfence();
	ready = 1;

	/* TODO thread join vs sync on atomic variable*/
	while(ready_threads)
		fipc_test_pause();

	uint64_t all_total_cycles = 0;
	double all_total_time_ns = 0;
	uint64_t kmer_big_pool_size_per_shard = (KMER_CREATE_DATA_BASE*KMER_CREATE_DATA_MULT)/num_shards;

	for (size_t k = 0; k < num_shards; k++) {
		printf("Thread %u: %lu cycles (%f ns) for %lu insertions (%lu cycles per insertion)\n", 
			all_td[k].thread_idx, 
			all_td[k].insertion_cycles,
			(double) all_td[k].insertion_cycles * one_cycle_ns,
			all_td[k].base*all_td[k].multiplier,
			all_td[k].insertion_cycles / (all_td[k].base*all_td[k].multiplier));
		all_total_cycles += all_td[k].insertion_cycles;
		all_total_time_ns += (double)all_td[k].insertion_cycles * one_cycle_ns;
	}
	printf("===============================================================\n");
	printf("Total threads: %u\n", num_shards); 
	printf("Total cycles: %lu\n", all_total_cycles);
	printf("Total time (ns): %f\n", all_total_time_ns);
	printf("Average cycles per thread for %lu insertions: %ld\n", kmer_big_pool_size_per_shard, (all_total_cycles / num_shards));
	printf("Average time per thread: %f (ns)\n", all_total_time_ns /num_shards);
	// printf("Average cycles per insertion per thread: %lu\n", all_total_cycles/(KMER_CREATE_DATA_BASE*KMER_CREATE_DATA_MULT)/num_shards);
	// printf("Average time per insertion per thread: %lu\n", all_total_time_ns/(KMER_CREATE_DATA_BASE*KMER_CREATE_DATA_MULT)/num_shards);
	// printf("Average time per insertion: %f (ms)\n", all_total_cycles/KMER_CREATE_DATA_BASE*KMER_CREATE_DATA_MULT);
	printf("===============================================================\n");
	// cout << "Cycles for " << total_threads << " threads to finish insertion : " << g_total_cycles / total_threads
	// 		<< "(" << g_total_time / total_threads << " seconds)" << endl;
	// cout << "time taken for single insertion " << g_insertion_nsecs / total_threads << " ns "<< endl;

// 	{
// 		timestamp t(KMER_CREATE_DATA_BASE * KMER_CREATE_DATA_MULT, 
// 			"simple_linear_probing_hash_table");	
// 		ready =1;

// 		for (i = 0; i < num_shards; i++)
// 		{
// 			pthread_join(threads[i], NULL);
// #ifndef NDEBUG
// 			printf("[INFO] %s, joined thread %lu\n", __func__, i);
// #endif
// 		}

// 	}
// 	while(ready_threads)
// 		fipc_test_pause();

	return 0;
}

int main(void) {

	uint32_t num_threads = nodes[0].num_cpus;
#ifdef NUM_THREADS
	num_threads = NUM_THREADS;
#endif	
	spawn_shard_threads(num_threads);



}


