#ifndef BQ_TESTS
#define BQ_TESTS

#define BQ_MAGIC_64BIT 0xD221A6BE96E04673UL
#define BQ_TESTS_BATCH_LENGTH 32
#define BQ_TESTS_NUM_INSERTS (1ULL << 26)
#define BQ_TESTS_HT_SIZE (BQ_TESTS_NUM_INSERTS * 16)

static int *bqueue_halt;
struct bq_kmer {
  char data[KMER_DATA_LENGTH];
};

void *producer_thread(void *arg)
{
  __shard *sh = (__shard *)arg;
  struct xorwow_state xw_state;
  uint64_t k = 0;
  // uint64_t num_inserts = 0;
  uint64_t t_start, t_end;
  queue_t **q = prod_queues[sh->prod_idx];
  uint8_t cons_id = 0;
  uint64_t transaction_id;

  xorwow_init(&xw_state);
  fipc_test_FAI(ready_producers);
  while (!test_ready) fipc_test_pause();
  fipc_test_mfence();

  printf("[INFO]: Producer %u starting. Total inserts :%llu \n", sh->prod_idx,
         BQ_TESTS_NUM_INSERTS * consumer_count);

  t_start = RDTSC_START();

  /* BQ_TESTS_NUM_INSERTS * consumer_count enqueues per consumer */
  cons_id = 0;
  for (transaction_id = 0u;
       transaction_id < BQ_TESTS_NUM_INSERTS * consumer_count;) {
    /* BQ_TESTS_BATCH_LENGTH enqueues in one batch, then move on to next
     * consumer */
    for (int i = 0; i < BQ_TESTS_BATCH_LENGTH; i++) {
      k = xorwow(&xw_state);
      k = k << 32 | xorwow(&xw_state);
      // *((uint64_t *)&kmers[i].data) = k;

      if (enqueue(q[cons_id], (data_t)k) != SUCCESS) {
        /* if enqueue fails, move to next consumer queue */
        // printf("[ERROR] Producer %u -> Consumer %u \n", sh->prod_idx,
        // cons_id);
        break;
      }
      transaction_id++;
      if (transaction_id % (BQ_TESTS_NUM_INSERTS * consumer_count / 10) == 0) {
        printf("[INFO]: Producer %u, transaction_id %lu\n", sh->prod_idx,
               transaction_id);
      }
    }

    ++cons_id;
    if (cons_id >= consumer_count) cons_id = 0;
  }

  /* enqueue halt messages */
  for (cons_id = 0; cons_id < consumer_count; cons_id++) {
    while (enqueue(q[cons_id], (data_t)BQ_MAGIC_64BIT) != SUCCESS)
      ;
    transaction_id++;
  }

  t_end = RDTSCP();

  printf(
      "[INFO] Producer %u finished, sending %lu messages (cycles per message "
      "%lu)\n",
      sh->prod_idx, transaction_id, (t_end - t_start) / transaction_id);

  fipc_test_FAI(completed_producers);
  return NULL;
}

void *consumer_thread(void *arg)
{
  __shard *sh = (__shard *)arg;
  uint64_t t_start, t_end;
  KmerHashTable *kmer_ht = NULL;
  uint8_t finished_producers;
  uint64_t k = 0;
  uint64_t transaction_id = 0;
  uint8_t prod_id = 0;
  queue_t **q = cons_queues[sh->cons_idx];
  // bq_kmer[BQ_TESTS_BATCH_LENGTH*consumer_count];

  kmer_ht = init_ht(BQ_TESTS_HT_SIZE);
  fipc_test_FAI(ready_consumers);
  while (!test_ready) fipc_test_pause();
  fipc_test_mfence();
  t_start = RDTSC_START();

  printf("[INFO]: Consumer %u starting\n", sh->cons_idx);

  prod_id = 0;
  while (finished_producers < producer_count) {
    for (int i = 0; i < BQ_TESTS_BATCH_LENGTH; i++) {
      /* Receive and unmarshall */
      if (dequeue(q[prod_id], (data_t *)&k) != SUCCESS) {
        /* move on to next producer queue to dequeue */
        // printf("[ERROR] Consumer %u <- Producer %u \n", sh->cons_idx,
        // prod_id);
        break;
      }

      // *((uint64_t *)&bq_kmer[i].data) = k;
      kmer_ht->insert((void *)&k);

      if ((data_t)k == BQ_MAGIC_64BIT) {
        fipc_test_FAI(finished_producers);
        printf(
            "[INFO] Consumer %u, received HALT from prod_id %u. "
            "finished_producers :%u\n",
            sh->cons_idx, prod_id, finished_producers);
      }

      transaction_id++;
      if (transaction_id % (BQ_TESTS_NUM_INSERTS * consumer_count / 10) == 0) {
        printf("[INFO]: Consumer %u, transaction_id %lu\n", sh->cons_idx,
               transaction_id);
      }
    }
    ++prod_id;
    if (prod_id >= producer_count) {
      prod_id = 0;
    }
  }

  t_end = RDTSCP();
  printf(
      "[INFO] Consumer %u finished, receiving %lu messages (cycles per "
      "message %lu)\n",
      sh->cons_idx, transaction_id, (t_end - t_start) / transaction_id);

  /* Write to file */
  if (!config.ht_file.empty()) {
    std::string outfile = config.ht_file + std::to_string(sh->cons_idx);
    printf("[INFO] Shard %u: Printing to file: %s\n", sh->cons_idx,
           outfile.c_str());
    kmer_ht->print_to_file(outfile);
  }

  // End test
  fipc_test_FAI(completed_consumers);
  return NULL;
}

#endif