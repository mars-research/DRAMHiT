/**
 * @File     : main.c
 * @Author   : Abdullah Younis
 */
#include <sched.h>
#define vmalloc malloc
#define vfree free
#define pr_err printf
#include <malloc.h>

#include "include/libfipc/libfipc_test_config.h"

uint64_t CACHE_ALIGNED prod_sum = 0;
uint64_t CACHE_ALIGNED cons_sum = 0;
int* halt;

int null_invocation(void)
{
  asm volatile("nop");
  return 0;
}

void* producer(void* data)
{
  uint64_t transaction_id;
  uint64_t start;
  uint64_t end;
  uint64_t cons_id = 0;
  int i;

  /*
  We have a fixed size object pool, we pick one object from that pool as
  transaction_id mod pool_size
  */
  uint64_t obj_id_mask = ((1UL << mem_pool_order) - 1);

  uint64_t thread_id = *(uint64_t*)data;
  node_t* t = node_tables[thread_id];
  queue_t** q = prod_queues[thread_id];

  pr_err("[%lu]: Producer %lu starting...\n", pthread_self(), thread_id);

  /* Touching data */
  // for ( transaction_id = 0; transaction_id < mem_pool_size; transaction_id++
  // )
  //{
  //	t[transaction_id].field = 0;
  //}

  /* Begin test */
  // fipc_test_thread_take_control_of_CPU();

  /* Wait for everyone to be ready */
  fipc_test_FAI(ready_producers);

  while (!test_ready) fipc_test_pause();

  fipc_test_mfence();

  start = RDTSC_START();

  /*
  Enqueue <consumer_count> * <transactions> messages in total. E.g. 4 * 10000000
  = 40000000 messages in total, approximately 10000000 messages per consumer.
  Enqueue <batch_size> messages for one consumer, before moving to the next and
  then wrapping back 	to the first. Stop when transactions (100000000)
  messages are enqueued per consumer.
  */
  for (transaction_id = 0; transaction_id < consumer_count * transactions;) {
    // pr_err("[%lu]: transaction_id = %ld\n", pthread_self(), transaction_id);
    // pr_err("[%lu] cons_id: %lu\n", pthread_self(), cons_id);
    // if (transaction_id % 1000 == 0)
    // pr_err("[%lu]: transaction_id = %ld\n", pthread_self(), transaction_id);

    for (i = 0; i < batch_size; i++) {
      node_t* node = &t[transaction_id & obj_id_mask];

      node->field = transaction_id;
      // prod_sum += transaction_id; /* node->field; */
      // pr_err("Sending, thread_id:%lu, mask%lu, mod:%lu\n",
      //		transaction_id, obj_id_mask, transaction_id &
      //obj_id_mask);

      // pr_err("[%lu] transaction_id: %lu\n", pthread_self(), transaction_id);
      if (enqueue(q[cons_id], (data_t)node) != SUCCESS) {
        /* if enqueue fails, move to next consumer queue */
        break;
      }
      transaction_id++;
      if (transaction_id % (transactions / 10) == 0) {
        pr_err("[%lu]: Producer %lu, transaction_id %lu, node->field: %lu \n",
               pthread_self(), thread_id, transaction_id, node->field);
      }
    };

    ++cons_id;

    if (cons_id >= consumer_count) cons_id = 0;
  }

  /* after enqueuing transactions messages, enqueue halt messages */
  for (cons_id = 0; cons_id < consumer_count; cons_id++) {
    while (enqueue(q[cons_id], (data_t)0X0000000000000001) != SUCCESS)
      ;
    transaction_id++;
    pr_err(
        "[%lu]: Producer %lu, transaction_id %lu, data_t: 0X0000000000000001 "
        "\n",
        pthread_self(), thread_id, transaction_id);
  }

  end = RDTSCP();

  // End test
  pr_err(
      "[%lu]: Producer %lu finished, sending %lu messages (cycles per message "
      "%lu) (prod_sum:%lu)\n",
      pthread_self(), thread_id, transaction_id, (end - start) / transaction_id,
      prod_sum);

  fipc_test_thread_release_control_of_CPU();
  fipc_test_FAI(completed_producers);
  return 0;
}

void* consumer(void* data)
{
  uint64_t start;
  uint64_t end;
  uint64_t prod_id = 0;
  uint64_t transaction_id = 0;
  node_t* node;
  int i;
  uint8_t finished_producers;
#ifdef PREFETCH_VALUE
  int j;
#endif

  uint64_t thread_id = *(uint64_t*)data;
  queue_t** q = cons_queues[thread_id];

  pr_err("[%lu]: Consumer %lu starting\n", pthread_self(), thread_id);

  /* Begin test */
  // fipc_test_thread_take_control_of_CPU();

  /* Wait for everyone to be ready */
  fipc_test_FAI(ready_consumers);

  while (!test_ready) fipc_test_pause();

  fipc_test_mfence();

  start = RDTSC_START();

  /*
  controller waits till producers complete all their enqueues
  then halt the consumers
  dequeue <batch_size> messages from the queue connected to
  producer <prod_id> into <node>
  then move to next producer, and dequeue. And so on.
  Wrap around back to first producer
  */
  while (finished_producers < producer_count) {
    for (i = 0; i < batch_size; i++) {
      /* Receive and unmarshall */
      if (dequeue(q[prod_id], (data_t*)&node) != SUCCESS) {
        /* move on to next producer queue to dequeue */
        break;
      }

      /* TOOD put this in TOUCH_VALUE? */
      if ((data_t)node == 0X0000000000000001) {
        fipc_test_FAI(finished_producers);
        pr_err(
            "[%lu]: Consumer %lu, prod_id %lu, 0X0000000000000001, "
            "finished_producers :%u [---HALT---]\n",
            pthread_self(), thread_id, prod_id, finished_producers);
      }

#ifdef TOUCH_VALUE
      cons_sum += node->field;
#endif

#ifdef PREFETCH_VALUE
      // rw flag (0 -- read, 1 -- write),
      // temporal locality (0..3, 0 -- no locality)
      __builtin_prefetch(node, 0, 0);
#endif
      transaction_id++;

      if (transaction_id % (transactions / 10) == 0) {
        pr_err(
            "[%lu]: Consumer %lu, prod_id %lu, transaction_id %lu, node->field "
            "%lu\n",
            pthread_self(), thread_id, prod_id, transaction_id, node->field);
      }
      // if (thread_id == 1){
      // 	pr_err("[%lu]: Consumer %lu: %d\n", pthread_self(), thread_id,
      // halt[thread_id]);
      // }
    }

#ifdef PREFETCH_VALUE
    for (j = 0; j < i; j++) {
      cons_sum += node->field;
    }
#endif
    ++prod_id;
    if (prod_id >= producer_count) {
      prod_id = 0;
    }
  }

  end = RDTSCP();

  // End test
  fipc_test_mfence();
  pr_err(
      "[%lu]: Consumer %lu finished, receiving %lu messages (cycles per "
      "message %lu) (cons sum:%lu)\n",
      pthread_self(), thread_id, transaction_id, (end - start) / transaction_id,
      cons_sum);

  fipc_test_thread_release_control_of_CPU();
  fipc_test_FAI(completed_consumers);
  return 0;
}

void* controller(void* data)
{
  uint64_t i;
  uint64_t j;

// #ifdef _NUMA
//   struct numa_node* _nodes = get_numa_config();

//   if (!_nodes)
//     printf("%s, nodes is null\n", __func__);
//   else
//     printf("%s, nodes %p\n", __func__, _nodes);
// #endif
  pr_err("[%lu]: Controller starting...\n", pthread_self());

  mem_pool_size = 1 << mem_pool_order;

  /* Queue Allocation */
  queue_t* queues = (queue_t*)memalign(
      FIPC_CACHE_LINE_SIZE, producer_count * consumer_count * sizeof(queue_t));

  for (i = 0; i < producer_count * consumer_count; ++i) init_queue(&queues[i]);

  prod_queues = (queue_t***)memalign(FIPC_CACHE_LINE_SIZE,
                                     producer_count * sizeof(queue_t**));
  cons_queues = (queue_t***)memalign(FIPC_CACHE_LINE_SIZE,
                                     consumer_count * sizeof(queue_t**));

  halt = (int*)vmalloc(consumer_count * sizeof(*halt));

  /* For each producer allocate a queue connecting it to <consumer_count>
   * consumers */
  for (i = 0; i < producer_count; ++i)
    prod_queues[i] = (queue_t**)memalign(FIPC_CACHE_LINE_SIZE,
                                         consumer_count * sizeof(queue_t*));

  for (i = 0; i < consumer_count; ++i) {
    cons_queues[i] = (queue_t**)memalign(FIPC_CACHE_LINE_SIZE,
                                         producer_count * sizeof(queue_t*));
    halt[i] = 0;
  }

  /* Queue Linking */
  for (i = 0; i < producer_count; ++i) {
    for (j = 0; j < consumer_count; ++j) {
      prod_queues[i][j] = &queues[i * consumer_count + j];
    }
  }

  for (i = 0; i < consumer_count; ++i) {
    for (j = 0; j < producer_count; ++j) {
      cons_queues[i][j] = &queues[i + j * consumer_count];
    }
  }

  /* Node Table Allocation */
  node_tables = (node_t**)vmalloc(producer_count * sizeof(node_t*));

  for (i = 0; i < producer_count; ++i) {
    pr_err(
        "[%lu]: Allocating %lu bytes for the pool of %lu objects (pool "
        "order:%lu)\n",
        pthread_self(), mem_pool_size * sizeof(node_t), mem_pool_size,
        mem_pool_order);

    node_tables[i] =
        (node_t*)memalign(FIPC_CACHE_LINE_SIZE, mem_pool_size * sizeof(node_t));
    if (!node_tables[i]) {
      pr_err("[%lu]: Failed to allocate nodes\n", pthread_self());
      return NULL;
    }
    pr_err("[%lu]: Check nodes are mem aligned: (%p):%s\n", pthread_self(),
           node_tables[i],
           ((uint64_t)node_tables[i] & (FIPC_CACHE_LINE_SIZE - 1))
               ? "not aligned"
               : "aligned");
  }

  fipc_test_mfence();

  /* Thread Allocation */
  pthread_t** cons_threads =
      (pthread_t**)vmalloc(consumer_count * sizeof(pthread_t*));
  pthread_t** prod_threads = NULL;

  /*
  In case there is only one producer, the controller thread becomes that
  producer
  */
  if (producer_count > 1)
    prod_threads =
        (pthread_t**)vmalloc((producer_count - 1) * sizeof(pthread_t*));

  uint64_t* p_rank = (uint64_t*)vmalloc(producer_count * sizeof(uint64_t));
  uint64_t* c_rank = (uint64_t*)vmalloc(consumer_count * sizeof(uint64_t));

  /* controller is rank 0 when it becomes producer */
  p_rank[0] = 0;

  /* Spawn Threads */
  for (i = 1; i < producer_count; ++i) {
    p_rank[i] = i;

// #ifdef _NUMA
//     printf("producer %lu : queued on %u\n", i, _nodes[0].cpu_list[i * 2]);
//     prod_threads[i] = fipc_test_thread_spawn_on_CPU(producer, &p_rank[i],
//                                                     _nodes[0].cpu_list[i * 2]);
// #else
    prod_threads[i - 1] =
        fipc_test_thread_spawn_on_CPU(producer, &p_rank[i], producer_cpus[i]);
// #endif
    if (prod_threads[i - 1] == NULL) {
      pr_err("%s\n", "Error while creating thread");
      return NULL;
    }
  }

  for (i = 0; i < consumer_count; ++i) {
    c_rank[i] = i;

// #ifdef _NUMA
//     cons_threads[i] = fipc_test_thread_spawn_on_CPU(
//         consumer, &c_rank[i], _nodes[0].cpu_list[(i * 2) + 1]);
// #else
    cons_threads[i] =
        fipc_test_thread_spawn_on_CPU(consumer, &c_rank[i], consumer_cpus[i]);
// #endif

    if (cons_threads[i] == NULL) {
      pr_err("%s\n", "Error while creating thread");
      return NULL;
    }
  }

  /* Wait for threads to be ready for test */
  while (ready_consumers < consumer_count) fipc_test_pause();

  while (ready_producers < (producer_count - 1)) fipc_test_pause();

  fipc_test_mfence();

  /* Begin Test */
  test_ready = 1;

  fipc_test_mfence();

  /* This thread is also a producer */
  pr_err("[%lu]: Controller becoming producer \n", pthread_self());
  // sleep(5);
  producer(&p_rank[0]);

  /* Wait for producers to complete */
  while (completed_producers < producer_count) fipc_test_pause();

  fipc_test_mfence();

  /* Tell consumers to halt */
  for (i = 0; i < consumer_count; ++i) {
    halt[i] = 1;
    // pr_err("[%lu] halt[%lu]: %d \n", pthread_self(), i, halt[i]);
  }

  /* Wait for consumers to complete */
  while (completed_consumers < consumer_count) fipc_test_pause();

  fipc_test_mfence();

  /* Clean up */
  vfree(c_rank);
  vfree(p_rank);

  for (i = 0; i < consumer_count; ++i) {
    fipc_test_thread_free_thread(cons_threads[i]);
  }

  for (i = 0; i < (producer_count - 1); ++i) {
    fipc_test_thread_free_thread(prod_threads[i]);
  }

  vfree(cons_threads);

  if (prod_threads != NULL) vfree(prod_threads);

  vfree(halt);

  for (i = 0; i < producer_count; ++i) free(node_tables[i]);

  vfree(node_tables);

  for (i = 0; i < consumer_count; ++i) free(cons_queues[i]);

  for (i = 1; i < producer_count; ++i) free(prod_queues[i]);

  free(cons_queues);
  free(prod_queues);

  for (i = 0; i < producer_count * consumer_count; ++i) free_queue(&queues[i]);

  free(queues);

  /* End Experiment */
  fipc_test_mfence();
  test_finished = 1;
  return 0;
}

int main(int argc, char *argv[])
{
  if (argc == 2) {
    transactions = (uint64_t)strtoul(argv[1], NULL, 10);
    printf("Starting test with %lu transactions\n", transactions);

  } else if (argc == 3) {
    producer_count = strtoul(argv[1], NULL, 10);
    consumer_count = strtoul(argv[2], NULL, 10);
    printf("Starting test with prod count %d, cons count %d\n", producer_count,
           consumer_count);
  } else if (argc == 5) {
    producer_count = strtoul(argv[1], NULL, 10);
    consumer_count = strtoul(argv[2], NULL, 10);
    transactions = (uint64_t)strtoul(argv[3], NULL, 10);
    batch_size = (uint64_t)strtoul(argv[4], NULL, 10);

    printf(
        "Starting test with prod count %d, cons count %d, %lu transactions, "
        "and batch size %lu\n",
        producer_count, consumer_count, transactions, batch_size);
  }

  /* controller thread is always on 1st CPU */
  pthread_t* controller_thread =
      fipc_test_thread_spawn_on_CPU(controller, NULL, producer_cpus[0]);
  if (controller_thread == NULL) {
    pr_err("%s\n", "Error while creating thread");
    return -1;
  }

  fipc_test_thread_wait_for_thread(controller_thread);

  fipc_test_mfence();
  fipc_test_thread_free_thread(controller_thread);
  pr_err("Test finished\n");

  return 0;
}
