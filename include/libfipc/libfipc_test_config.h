/**
 * @File     : test.h
 * @Author   : Abdullah Younis
 *
 * NOTE: This test assumes an x86 architecture.
 */

#ifndef LIBFIPC_TEST_QUEUE_TEST
#define LIBFIPC_TEST_QUEUE_TEST

#include "../bqueue.h"

// Test Variables
[[maybe_unused]] static uint64_t transactions = 100000000;
// static uint64_t transactions = 200000000;

static uint8_t producer_count = 1;
static uint8_t consumer_count = 1;

uint64_t batch_size = 1;

uint64_t mem_pool_order = 16;
uint64_t mem_pool_size;



#ifdef __KERNEL__
module_param( producer_count, byte, 0 );
module_param( consumer_count, byte, 0 );
#endif

//d820 Numa nodes
//NUMA node0 CPU(s):     0,4,8,12,16,20,24,28
//NUMA node1 CPU(s):     1,5,9,13,17,21,25,29
//NUMA node2 CPU(s):     2,6,10,14,18,22,26,30
//NUMA node3 CPU(s):     3,7,11,15,19,23,27,31

[[maybe_unused]] static uint8_t producer_cpus[10] = {0, 2, 4, 6, 8, 10, 
                                                        12, 14, 16, 18};
[[maybe_unused]] static uint8_t consumer_cpus[10] = {1, 3, 5, 7, 9, 11, 
                                                        13, 15, 17, 19};

//static uint8_t producer_cpus[32] = { 0, 4, 8, 12,
// 								     1, 5, 9, 13,
// 								     2, 6, 10, 14,
// 								     3, 7, 11, 15,  
// 								     16, 20, 24, 28,
// 								     17, 21, 25, 29, 
// 								     18, 22, 26, 30, 
// 								     19, 23, 27, 31};

// static uint8_t consumer_cpus[32] = {16, 20, 24, 28,
// 									17, 21, 25, 29, 
// 									18, 22, 26, 30, 
// 									19, 23, 27, 31,  
// 									0, 4,  8, 12, 
// 									1,  5,  9, 13, 
// 									2,  6, 10, 14,  
// 									3,  7, 11, 15 };
#define pr_err printf

// Queue Variables
static queue_t*** prod_queues = NULL;
static queue_t*** cons_queues = NULL;
[[maybe_unused]] static node_t**   node_tables = NULL;

// Request Types
#define MSG_ENQUEUE         1
#define MSG_HALT            2

// Thread Locks
static uint64_t completed_producers = 0;
static uint64_t completed_consumers = 0;
static uint64_t ready_consumers     = 0;
static uint64_t ready_producers     = 0;
static uint64_t test_ready          = 0;
[[maybe_unused]] static uint64_t test_finished       = 0;

#endif
