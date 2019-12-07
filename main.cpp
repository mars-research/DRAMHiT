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
	uint64_t multiplier; // set before ""
	uint64_t uniq_cnt; // set before ""
	Shard* shard; // to be set by create_shards
} thread_data;

uint64_t base = 100000;
uint64_t multiplier =2;
uint64_t uniq_cnt = 100000;


typedef SimpleLinearProbingHashTable slpht_map;

void* create_shards(void *arg) {

	thread_data* td = (thread_data*) arg;

	std::cout << "Creating new shard " << std::endl;
	// 	s->kmer_big_pool = (Kmer_s*) memalign(CACHE_LINE_SIZE, sizeof(Kmer_s) * KMER_BIG_POOL_COUNT);
	Shard* s = (Shard*)memalign(CACHE_LINE_SIZE, sizeof(Shard));
	td->shard = s;
	create_data(td->base, td->multiplier, td->uniq_cnt, td->shard);

	size_t HT_SIZE = td->base * td->multiplier;
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

// prepare shards on node 0
// for all cpus on node 0, spawn a thread
// except cpu 
int spawn_shard_threads(uint32_t num_shards) {
	
	pthread_t* threads;
	cpu_set_t cpuset; 
	int s;
	size_t i;

	threads = (pthread_t*) malloc(sizeof(pthread_t*) * num_shards);

	for (i = 0; i < num_shards; i++){
		thread_data *td = (thread_data*) memalign(CACHE_LINE_SIZE, 
			sizeof(thread_data));
		td->thread_idx = i;
		td->base = base/num_shards;
		td->multiplier = multiplier;
		td->uniq_cnt = uniq_cnt/num_shards;
		s = pthread_create(&threads[i], NULL, create_shards, (void*)td);
  		if (s != 0)
			std::cout << "ERROR: Could not create create_shard thread " 
				<< std::endl;
		CPU_ZERO(&cpuset);
		std::cout << "INFO: CPU Affinity: " << nodes[0].cpu_list[i] 
			<< std::endl;
		CPU_SET(nodes[0].cpu_list[i], &cpuset);
		pthread_setaffinity_np(threads[i], sizeof(cpu_set_t), &cpuset);
	}

	CPU_ZERO(&cpuset);
	// struct last_node_idx = n.get_num_nodes()-1;
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
			printf("%s, joined thread %lu\n", __func__, i);
		}

	}
	return 0;
}

int main(void) {

	uint32_t num_threads = nodes[0].num_cpus;
	// spawn_shard_threads(num_threads);
	spawn_shard_threads(10);
	// for(auto cpu : nodes[0].cpu_list){
	// 	std::cout << cpu << std::endl;
	// }

	// 		timestamp t(HT_SIZE, "simple_linear_probing_hash_table");

#if 0
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
#endif
}


