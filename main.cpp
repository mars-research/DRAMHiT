#include "kmer_data.cpp"
#include "skht.h"
#include "timestamp.h"
#include "numa.hpp"
#include "test_config.h"
#include "shard.h"
#include <pthread.h>
#include <errno.h>
#include "libfipc_test_time.h"

// TODO Where do you get this from? /proc/cpuinfo
#define CPUFREQ_MHZ				(2200.0)
static const float one_cycle_ns = ((float)1000 / CPUFREQ_MHZ);

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
	create_data(td->shard);

	size_t HT_SIZE = KMER_CREATE_DATA_BASE*KMER_CREATE_DATA_MULT;

	/* Create hash table */
	skht_map skht_ht(HT_SIZE);
	
	fipc_test_FAI(ready_threads);

	while(!ready)
		fipc_test_pause();

	// fipc_test_mfence();

	start = RDTSC_START();

	for (size_t i = 0; i < HT_SIZE; i++) {
#ifndef NO_INSERTS
		bool res = skht_ht.insert((base_4bit_t*)&td->shard->kmer_big_pool[i]);
		if (!res){
			printf("FAIL\n");
		}
#endif 
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

	// threads = (pthread_t*) malloc(sizeof(pthread_t*) * num_shards);

	pthread_t* threads = (pthread_t*) memalign(CACHE_LINE_SIZE, 
			sizeof(pthread_t) * num_shards);
	// thread_data all_td[num_shards] = {{0}};
	thread_data* all_td = (thread_data*) memalign(CACHE_LINE_SIZE, 
			sizeof(thread_data)*num_shards);

	memset(all_td, 0, sizeof(thread_data*)*num_shards);

	for (i = 0; i < num_shards; i++){

		// thread_data *td = (thread_data*) memalign(CACHE_LINE_SIZE, 
		// 	sizeof(thread_data));
		thread_data *td = &all_td[i];
		td->thread_idx = i;

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

	uint64_t kmer_big_pool_size_per_shard = \
			(KMER_CREATE_DATA_BASE * KMER_CREATE_DATA_MULT);
	uint64_t total_kmer_big_pool_size = kmer_big_pool_size_per_shard * num_shards; 

	uint64_t kmer_small_pool_size_per_shard = KMER_CREATE_DATA_UNIQ;
	uint64_t total_kmer_small_pool_size = kmer_small_pool_size_per_shard * num_shards;

	uint64_t all_total_cycles = 0;
	double all_total_time_ns = 0;

	for (size_t k = 0; k < num_shards; k++) {
		printf("Thread %2d: %lu cycles (%f ms) for %lu insertions (%lu cycles per insertion)\n", 
			all_td[k].thread_idx, 
			all_td[k].insertion_cycles,
			(double) all_td[k].insertion_cycles * one_cycle_ns / 1000,
			kmer_big_pool_size_per_shard,
			all_td[k].insertion_cycles / kmer_big_pool_size_per_shard);
		all_total_cycles += all_td[k].insertion_cycles;
		all_total_time_ns += (double)all_td[k].insertion_cycles * one_cycle_ns;
	}
	printf("===============================================================\n");
		printf("Average  : %lu cycles (%f ms) for %lu insertions (%lu cycles per insertion)\n", 
			all_total_cycles / num_shards, 
			(double) all_total_time_ns * one_cycle_ns / 1000,
			kmer_big_pool_size_per_shard,
			all_total_cycles / num_shards / kmer_big_pool_size_per_shard);
	printf("===============================================================\n");
	printf("Total cumulative cycles for %u threads: %lu\n", num_shards, 
		all_total_cycles);
	printf("Total cumulative time (ns) for %u threads: %f\n", num_shards, 
		all_total_time_ns);
	printf("Average cycles per insertion per thread: %lu\n", 
		all_total_cycles/total_kmer_big_pool_size/num_shards);
	printf("===============================================================\n");


	return 0;
}

int main(void) {

	uint32_t num_threads = nodes[0].num_cpus;
#ifdef NUM_THREADS
	num_threads = NUM_THREADS;
#endif	
	spawn_shard_threads(num_threads);



}


