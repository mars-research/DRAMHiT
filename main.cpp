#include "kmer_data.cpp"
#include "slpht.h"
#include "timestamp.h"
#include "numa.hpp"
#include "shard.h"
#include <pthread.h>
#include <errno.h>

#define fipc_test_FAI(X)       __sync_fetch_and_add( &X, 1 )
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
} thread_data;

/*hardcoded TODO move to a testconfig file */
uint64_t base = 100000;
uint64_t multiplier =2;
uint64_t uniq_cnt = 100000;


typedef SimpleLinearProbingHashTable slpht_map;

void* create_shards(void *arg) {

	thread_data* td = (thread_data*) arg;

	printf("[INFO] Thread %u. Creating new shard\n", td->thread_idx);

	Shard* s = (Shard*)memalign(CACHE_LINE_SIZE, sizeof(Shard));
	td->shard = s;
	td->shard->shard_idx = td->thread_idx;
	create_data(td->base, td->multiplier, td->uniq_cnt, td->shard);

	size_t HT_SIZE = td->base * td->multiplier;

	/* Create hash table */
	slpht_map slpht_ht(HT_SIZE);
	
	fipc_test_FAI(ready_threads);

	while(!ready)
		fipc_test_pause();

	fipc_test_mfence();

	for (size_t i = 0; i < HT_SIZE; i++) {
		slpht_ht.insert((base_4bit_t*)&td->shard->kmer_big_pool[i]);
	}

	return NULL;
}	

int spawn_shard_threads(uint32_t num_shards) {
	
	pthread_t* threads;
	cpu_set_t cpuset; 
	int s;
	size_t i;

	// TODO malloc vs. memalign?
	threads = (pthread_t*) malloc(sizeof(pthread_t*) * num_shards);

	for (i = 0; i < num_shards; i++){

		// TODO memalign vs malloc?
		thread_data *td = (thread_data*) memalign(CACHE_LINE_SIZE, 
			sizeof(thread_data));
		td->thread_idx = i;
		td->base = base/num_shards;
		td->multiplier = multiplier;
		td->uniq_cnt = uniq_cnt/num_shards;

		s = pthread_create(&threads[i], NULL, create_shards, (void*)td);
  		if (s != 0){
  			printf("[ERROR] pthread_create: Could not create create_shard \
  				thread");
			exit(-1);
  		}
		CPU_ZERO(&cpuset);
		printf("[INFO] thread: %lu, affinity: %u,\n", i, nodes[0].cpu_list[i]);
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

	fipc_test_mfence();
	{
		timestamp t(base*multiplier, "simple_linear_probing_hash_table");	
		ready =1;

		for (i = 0; i < num_shards; i++)
		{
			pthread_join(threads[i], NULL);
			printf("[INFO] %s, joined thread %lu\n", __func__, i);
		}

	}
	return 0;
}

int main(void) {

	uint32_t num_threads = nodes[0].num_cpus;
	spawn_shard_threads(num_threads);

}


