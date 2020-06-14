#include <errno.h>
#include <pthread.h>
#include <time.h>
#include <zlib.h>

#include <boost/program_options.hpp>
#include <chrono>
#include <cmath>
#include <ctime>
#include <fstream>

#include "./include/data_types.h"
#include "./include/misc_lib.h"
#include "kmer_data.cpp"
// #include "./include/timestamp.h"
#include "./include/libfipc/libfipc_test_config.h"
#include "./include/numa.hpp"
// #include "shard.h"
// #include "test_config.h"
#include "./include/ac_kseq.h"
// #include "kseq.h"

#include "./hashtables/cas_kht.hpp"
#include "./hashtables/robinhood_kht.hpp"
#include "./hashtables/simple_kht.hpp"
#include "./include/print_stats.h"
#include "hashtable_tests.cpp"

/* Numa config */
Numa n;
std::vector<numa_node> nodes = n.get_node_config();

/* default config */
const Configuration def = {
    .kmer_create_data_base = 524288,
    .kmer_create_data_mult = 1,
    .kmer_create_data_uniq = 1048576,
    .num_threads = 1,
    .mode = BQUEUE,  // TODO enum
    .kmer_files_dir = std::string("/local/devel/pools/million/39/"),
    .alphanum_kmers = true,
    .numa_split = false,
    .stats_file = std::string(""),
    .ht_file = std::string(""),
    .in_file = std::string("/local/devel/devel/datasets/turkey/myseq0.fa"),
    .ht_type = 1,
    .in_file_sz = 0,
    .drop_caches = true,
    .n_prod = 1,
    .n_cons = 1};  // TODO enum

/* global config */
Configuration config;

/* for synchronization of threads */
static uint64_t ready = 0;
static uint64_t ready_threads = 0;

/* for bqueues */
#define BQ_MAGIC_64BIT 0xD221A6BE96E04673UL
#define BQ_TESTS_BATCH_LENGTH 32
#define BQ_TESTS_NUM_INSERTS (1ULL << 26)
#define BQ_TESTS_HT_SIZE  (BQ_TESTS_NUM_INSERTS*16)
static int *bqueue_halt;
struct bq_kmer {
  char data[KMER_DATA_LENGTH];
};

KmerHashTable *init_ht(uint64_t sz)
{
  KmerHashTable *kmer_ht = NULL;

  /* Create hash table */
  if (config.ht_type == 1) {
    kmer_ht = new SimpleKmerHashTable(sz);
  } else if (config.ht_type == 2) {
    kmer_ht = new RobinhoodKmerHashTable(sz);
  } else if (config.ht_type == 3) {
    /* For the CAS Hash table, size is the same as
    size of one partitioned ht * number of threads */
    kmer_ht = new CASKmerHashTable(sz * config.num_threads);
    /*TODO tidy this up, don't use static + locks maybe*/
  }
  return kmer_ht;
}

void shard_thread_parse_no_inserts(__shard *sh)
{
  uint64_t t_start, t_end;
  kseq seq;
  int l = 0;
  uint64_t num_inserts = 0;
  int found_N = 0;
  char *kmer;
  t_start = RDTSC_START();

  kstream ks(sh->shard_idx, sh->f_start, sh->f_end);

  while ((l = ks.readseq(seq)) >= 0) {
    for (int i = 0; i < (l - KMER_DATA_LENGTH + 1); i++) {
      kmer = seq.seq.data() + i;
      if (found_N != -1) {
        found_N = find_last_N(kmer);
        if (found_N >= 0) {
          i += found_N;
          continue;
        }
      }
      char last_char = kmer[KMER_DATA_LENGTH - 1];
      if (last_char == 'N' || last_char == 'n') {
        found_N = KMER_DATA_LENGTH - 1;
        i += found_N;
        continue;
      }
      /*** Perform the "insert" ***/
      num_inserts++;
    }
    found_N = 0;
  }
  t_end = RDTSCP();

  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = num_inserts;

  sh->stats->ht_fill = 0;
  sh->stats->ht_capacity = 0;
  sh->stats->max_count = 0;
}

inline void shard_thread_parse_and_insert(__shard *sh, KmerHashTable *kmer_ht)
{
  uint64_t t_start, t_end;
  kseq seq;
  int l = 0;
  int res;
  uint64_t num_inserts = 0;
  int found_N = 0;
  char *kmer;

#ifdef CALC_STATS
  uint64_t avg_read_length = 0;
  uint64_t num_sequences = 0;
#endif

  kstream ks(sh->shard_idx, sh->f_start, sh->f_end);

  while ((l = ks.readseq(seq)) >= 0) {
    // std::cout << seq.seq << std::endl;
    for (int i = 0; i < (l - KMER_DATA_LENGTH + 1); i++) {
      kmer = seq.seq.data() + i;

      /*  search through whole string of N if first kmer OR if we found an N
       as last character of previous kmer */
      if (found_N != -1) {
        found_N = find_last_N(kmer);
        if (found_N >= 0) {
          i += found_N;
          continue;
        }
      }

      /* if last charcter is a kmer skip this kmer*/
      char last_char = kmer[KMER_DATA_LENGTH - 1];
      if (last_char == 'N' || last_char == 'n') {
        found_N = KMER_DATA_LENGTH - 1;
        i += found_N;
        continue;
      }

      res = kmer_ht->insert((void *)kmer);
      if (!res) {
        printf("FAIL\n");
      } else {
        num_inserts++;
      }

#ifdef CALC_STATS
      if (!avg_read_length) {
        avg_read_length = seq.seq.length();
      } else {
        avg_read_length = (avg_read_length + seq.seq.length()) / 2;
      }
#endif
    }
    found_N = 0;
  }
  t_end = RDTSCP();

  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = num_inserts;
  get_ht_stats(sh, kmer_ht);
  printf("[INFO] Shard %u: DONE\n", sh->shard_idx);
}

void *shard_thread(void *arg)
{
  __shard *sh = (__shard *)arg;
  KmerHashTable *kmer_ht;

  sh->stats = (thread_stats *)memalign(__CACHE_LINE_SIZE, sizeof(thread_stats));

  if (config.mode == FASTQ_WITH_INSERT) {
    kmer_ht = init_ht(config.in_file_sz / config.num_threads);
  }

  fipc_test_FAI(ready_threads);
  while (!ready) fipc_test_pause();

  // fipc_test_mfence();
  /* Begin insert loops */

  printf("[INFO] Shard %u: f_start! %lu, f_end: %lu\n", sh->shard_idx,
         sh->f_start, sh->f_end);
  if (config.mode == FASTQ_NO_INSERT) {
    printf("[INFO] Shard %u: Begin loop:  shard_thread_parse_no_inserts \n",
           sh->shard_idx);
    shard_thread_parse_no_inserts(sh);
  } else if (config.mode == FASTQ_WITH_INSERT) {
    shard_thread_parse_and_insert(sh, kmer_ht);
  }

  /* Write to file */
  if (!config.ht_file.empty()) {
    std::string outfile = config.ht_file + std::to_string(sh->shard_idx);
    printf("[INFO] Shard %u: Printing to file: %s\n", sh->shard_idx,
           outfile.c_str());
    kmer_ht->print_to_file(outfile);
  }

  fipc_test_FAD(ready_threads);

  return NULL;
}

void *producer_thread(void *arg)
{
  __shard *sh = (__shard *)arg;
  struct xorwow_state xw_state;
  uint64_t k = 0;
  uint64_t num_inserts = 0;
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
      k = k << 32 & ~((1 << 32) - 1) | xorwow(&xw_state);
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
            "[INFO] Consumer %lu, received HALT from prod_id %u. "
            "finished_producers :%u\n",
            sh->cons_idx, prod_id, finished_producers);
      }

      transaction_id++;
      if (transaction_id % (BQ_TESTS_NUM_INSERTS * consumer_count / 10) == 0) {
        printf("[INFO]: Consumer %lu, transaction_id %lu\n", sh->cons_idx,
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
      "[INFO] Consumer %lu finished, receiving %lu messages (cycles per "
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

int spawn_shard_threads_bqueues()
{
  cpu_set_t cpuset;
  uint64_t e, i, j;

  /*TODO numa split */
  if (config.n_prod + config.n_cons > nodes[0].cpu_list.size()) {
    printf(
        "[ERROR] producers [%u] + consumers [%u] exceeded number of available "
        "CPUs on node 0 [%lu]\n",
        config.n_prod, config.n_cons, nodes[0].cpu_list.size());
    exit(-1);
  }

  // pthread_self()
  producer_count = config.n_prod;
  consumer_count = config.n_cons;
  printf("[INFO]: Controller starting ... nprod: %u, ncons: %u\n",
         producer_count, consumer_count);

  /* Stats data structures */
  __shard *all_shards = (__shard *)memalign(FIPC_CACHE_LINE_SIZE,
                                            sizeof(__shard) * consumer_count);

  memset(all_shards, 0, sizeof(__shard) * config.num_threads);

  /* Queue Allocation */
  queue_t *queues = (queue_t *)memalign(
      FIPC_CACHE_LINE_SIZE, producer_count * consumer_count * sizeof(queue_t));

  for (i = 0; i < producer_count * consumer_count; ++i) init_queue(&queues[i]);

  prod_queues = (queue_t ***)memalign(FIPC_CACHE_LINE_SIZE,
                                      producer_count * sizeof(queue_t **));
  cons_queues = (queue_t ***)memalign(FIPC_CACHE_LINE_SIZE,
                                      consumer_count * sizeof(queue_t **));

  bqueue_halt = (int *)malloc(consumer_count * sizeof(*bqueue_halt));

  /* For each producer allocate a queue connecting it to <consumer_count>
   * consumers */
  for (i = 0; i < producer_count; ++i)
    prod_queues[i] = (queue_t **)memalign(FIPC_CACHE_LINE_SIZE,
                                          consumer_count * sizeof(queue_t *));

  for (i = 0; i < consumer_count; ++i) {
    cons_queues[i] = (queue_t **)memalign(FIPC_CACHE_LINE_SIZE,
                                          producer_count * sizeof(queue_t *));
    bqueue_halt[i] = 0;
  }

  /* Queue Linking */
  for (i = 0; i < producer_count; ++i) {
    for (j = 0; j < consumer_count; ++j) {
      prod_queues[i][j] = &queues[i * consumer_count + j];
      printf("[INFO] prod_queues[%d][%d] = %p\n", i, j,
             &queues[i * consumer_count + j]);
    }
  }

  for (i = 0; i < consumer_count; ++i) {
    for (j = 0; j < producer_count; ++j) {
      cons_queues[i][j] = &queues[i + j * consumer_count];
      printf("[INFO] cons_queues[%d][%d] = %p\n", i, j,
             &queues[i + j * consumer_count]);
    }
  }

  fipc_test_mfence();

  /* Thread Allocation */
  pthread_t *prod_threads = (pthread_t *)memalign(
      FIPC_CACHE_LINE_SIZE, sizeof(pthread_t) * producer_count);
  pthread_t *cons_threads = (pthread_t *)memalign(
      FIPC_CACHE_LINE_SIZE, sizeof(pthread_t) * consumer_count);

  /* Spawn producer threads */
  for (size_t x = 0; x < producer_count; x++) {
    __shard *sh = &all_shards[x];
    sh->prod_idx = x;
    e = pthread_create(&prod_threads[x], NULL, producer_thread, (void *)sh);
    if (e != 0) {
      printf(
          "[ERROR]: pthread_create: Could not create thread: "
          "producer_thread\n");
      exit(-1);
    }
    CPU_ZERO(&cpuset);
    size_t cpu_idx = (x % nodes[0].cpu_list.size()) * 2;
    CPU_SET(nodes[0].cpu_list[cpu_idx], &cpuset);
    pthread_setaffinity_np(prod_threads[x], sizeof(cpu_set_t), &cpuset);
    printf("[INFO]: Spawn producer_thread %lu, affinity: %u\n", x,
           nodes[0].cpu_list[cpu_idx]);
  }

  /* Spawn consumer threads */
  for (size_t x = 0; x < consumer_count; x++) {
    __shard *sh = &all_shards[x];
    sh->cons_idx = x;
    e = pthread_create(&cons_threads[x], NULL, consumer_thread, (void *)sh);
    if (e != 0) {
      printf(
          "[ERROR] pthread_create: Could not create thread: consumer_thread\n");
      exit(-1);
    }
    CPU_ZERO(&cpuset);
    size_t cpu_idx = (x % nodes[0].cpu_list.size()) * 2 + 1;
    // CPU_SET(nodes[0].cpu_list[cpu_idx], &cpuset);
    pthread_setaffinity_np(cons_threads[x], sizeof(cpu_set_t), &cpuset);
    printf("[INFO]: Spawn consumer_thread %lu, affinity: %u\n", x,
           nodes[0].cpu_list[cpu_idx]);
  }

  CPU_ZERO(&cpuset);
  /* last cpu of last node  */
  auto last_numa_node = nodes[n.get_num_nodes() - 1];
  CPU_SET(last_numa_node.cpu_list[last_numa_node.num_cpus - 1], &cpuset);
  sched_setaffinity(0, sizeof(cpu_set_t), &cpuset);

  /* Wait for threads to be ready for test */
  while (ready_consumers < consumer_count) fipc_test_pause();
  while (ready_producers < producer_count) fipc_test_pause();

  fipc_test_mfence();

  /* Begin Test */
  test_ready = 1;
  fipc_test_mfence();

  /* Wait for producers to complete */
  while (completed_producers < producer_count) fipc_test_pause();

  fipc_test_mfence();

  /* Tell consumers to halt */
  for (i = 0; i < consumer_count; ++i) {
    bqueue_halt[i] = 1;
  }

  /* Wait for consumers to complete */
  while (completed_consumers < consumer_count) fipc_test_pause();

  fipc_test_mfence();

  /* Tell consumers to halt once producers are done */

  return 0;

  // TODO free everything
}

int spawn_shard_threads()
{
  cpu_set_t cpuset;
  int e;

  pthread_t *threads = (pthread_t *)memalign(
      __CACHE_LINE_SIZE, sizeof(pthread_t) * config.num_threads);

  __shard *all_shards = (__shard *)memalign(
      __CACHE_LINE_SIZE, sizeof(__shard) * config.num_threads);

  memset(all_shards, 0, sizeof(__shard) * config.num_threads);

  size_t seg_sz = 0;

  if ((config.mode != SYNTH) && (config.mode != PREFETCH)) {
    config.in_file_sz = get_file_size(config.in_file.c_str());
    printf("[INFO] File size: %lu bytes\n", config.in_file_sz);
    seg_sz = config.in_file_sz / config.num_threads;
    if (seg_sz < 4096) {
      seg_sz = 4096;
    }
  }

  if (config.numa_split) {
    size_t num_nodes = nodes.size();
    size_t shards_per_node = config.num_threads / num_nodes;

    /* TODO support uneven splits, and spills after splits :*/
    // size_t shards_per_node_spill = config.num_threads % num_nodes;

    for (size_t x = 0; x < num_nodes; x++) {
      for (size_t y = 0; y < shards_per_node; y++) {
        uint32_t tidx = shards_per_node * x + y;
        __shard *sh = &all_shards[tidx];
        sh->shard_idx = tidx;
        sh->f_start = round_up(seg_sz * sh->shard_idx, __PAGE_SIZE);
        sh->f_end = round_up(seg_sz * (sh->shard_idx + 1), __PAGE_SIZE);
        /* TODO don't spawn threads if f_start >= in_file_sz
        Not doing it now, as it has implications for num_threads,
        which is used in calculating stats */
        e = pthread_create(&threads[sh->shard_idx], NULL, shard_thread,
                           (void *)sh);
        if (e != 0) {
          printf(
              "[ERROR] pthread_create: "
              " Could not create create shard thread");
          exit(-1);
        }
        CPU_ZERO(&cpuset);
        CPU_SET(nodes[x].cpu_list[y], &cpuset);
        pthread_setaffinity_np(threads[sh->shard_idx], sizeof(cpu_set_t),
                               &cpuset);
        printf("[INFO] Thread %u: affinity: %u\n", tidx, nodes[x].cpu_list[y]);
      }
    }
  }

  else if (!config.numa_split) {
    for (size_t x = 0; x < config.num_threads; x++) {
      __shard *sh = &all_shards[x];
      sh->shard_idx = x;
      sh->f_start = round_up(seg_sz * x, __PAGE_SIZE);
      sh->f_end = round_up(seg_sz * (x + 1), __PAGE_SIZE);

      /* TODO don't spawn threads if f_start >= in_file_sz */
      e = pthread_create(&threads[x], NULL, shard_thread, (void *)sh);
      if (e != 0) {
        printf("[ERROR] pthread_create: Could not create create_shard thread");
        exit(-1);
      }
      CPU_ZERO(&cpuset);
      size_t cpu_idx = x % nodes[0].cpu_list.size();
      CPU_SET(nodes[0].cpu_list[cpu_idx], &cpuset);
      pthread_setaffinity_np(threads[x], sizeof(cpu_set_t), &cpuset);
      printf("[INFO] Thread: %lu, set affinity: %u\n", x,
             nodes[0].cpu_list[cpu_idx]);
    }
  }

  CPU_ZERO(&cpuset);
  /* last cpu of last node  */
  auto last_numa_node = nodes[n.get_num_nodes() - 1];
  CPU_SET(last_numa_node.cpu_list[last_numa_node.num_cpus - 1], &cpuset);
  sched_setaffinity(0, sizeof(cpu_set_t), &cpuset);

  while (ready_threads < config.num_threads) {
    fipc_test_pause();
  }

  // fipc_test_mfence();
  ready = 1;

  /* TODO thread join vs sync on atomic variable*/
  while (ready_threads) fipc_test_pause();

  printf("Print stats here\n");
  print_stats(all_shards);

  free(threads);
  free(all_shards);

  return 0;
}

int main(int argc, char *argv[])
{
  try {
    namespace po = boost::program_options;
    po::options_description desc("Program options");

    desc.add_options()("help", "produce help message")(
        "mode",
        po::value<uint32_t>((uint32_t *)&config.mode)->default_value(def.mode),
        "1: Dry run \n2: Read K-mers from disk \n3: Write K-mers to disk "
        "\n4: Read FASTQ + insert to ht (--in_file)"
        "\n5: Read FASTQ, DO NOT insert to ht (--in_file) "
        "\n6/7: Synth/Prefetch,")(
        "base",
        po::value<uint64_t>(&config.kmer_create_data_base)
            ->default_value(def.kmer_create_data_base),
        "Number of base K-mers")(
        "mult",
        po::value<uint32_t>(&config.kmer_create_data_mult)
            ->default_value(def.kmer_create_data_mult),
        "Base multiplier for K-mers")(
        "uniq",
        po::value<uint64_t>(&config.kmer_create_data_uniq)
            ->default_value(def.kmer_create_data_uniq),
        "Number of unique K-mers (to control the ratio)")(
        "num-threads",
        po::value<uint32_t>(&config.num_threads)
            ->default_value(def.num_threads),
        "Number of threads")(
        "files-dir",
        po::value<std::string>(&config.kmer_files_dir)
            ->default_value(def.kmer_files_dir),
        "Directory of input files, files should be in format: '\\d{2}.bin'")(
        "alphanum",
        po::value<bool>(&config.alphanum_kmers)
            ->default_value(def.alphanum_kmers),
        "Use alphanum_kmers (for debugging)")(
        "numa-split",
        po::value<bool>(&config.numa_split)->default_value(def.numa_split),
        "Split spawning threads between numa nodes")(
        "stats",
        po::value<std::string>(&config.stats_file)
            ->default_value(def.stats_file),
        "Stats file name.")(
        "httype",
        po::value<uint32_t>(&config.ht_type)->default_value(def.ht_type),
        "1: SimpleKmerHashTable \n2: "
        "RobinhoodKmerHashTable, \n3: CASKmerHashTable, \n4. "
        "StdmapKmerHashTable")(
        "outfile",
        po::value<std::string>(&config.ht_file)->default_value(def.ht_file),
        "Hashtable output file name.")(
        "infile",
        po::value<std::string>(&config.in_file)->default_value(def.in_file),
        "Input fasta file")(
        "drop-caches",
        po::value<bool>(&config.drop_caches)->default_value(def.drop_caches),
        "drop page cache before run")(
        "nprod", po::value<uint32_t>(&config.n_prod)->default_value(def.n_prod),
        "for bqueues only")(
        "ncons", po::value<uint32_t>(&config.n_cons)->default_value(def.n_cons),
        "for bqueues only");

    po::variables_map vm;
    po::store(po::parse_command_line(argc, argv, desc), vm);
    po::notify(vm);

    if (config.drop_caches) {
      printf("[INFO] Dropping the page cache\n");
      if (system("sudo bash -c 'echo 3 > /proc/sys/vm/drop_caches'") < 0) {
        perror("drop caches");
      }
    }

    if (config.mode == SYNTH) {
      printf("[INFO] Mode : SYNTH\n");
    } else if (config.mode == PREFETCH) {
      printf("[INFO] Mode : PREFETCH\n");
    } else if (config.mode == DRY_RUN) {
      printf("[INFO] Mode : Dry run ...\n");
      printf("[INFO] base: %lu, mult: %u, uniq: %lu\n",
             config.kmer_create_data_base, config.kmer_create_data_mult,
             config.kmer_create_data_uniq);
    } else if (config.mode == READ_FROM_DISK) {
      printf("[INFO] Mode : Reading kmers from disk ...\n");
    } else if (config.mode == WRITE_TO_DISK) {
      printf("[INFO] Mode : Writing kmers to disk ...\n");
      printf("[INFO] base: %lu, mult: %u, uniq: %lu\n",
             config.kmer_create_data_base, config.kmer_create_data_mult,
             config.kmer_create_data_uniq);
    } else if (config.mode == FASTQ_WITH_INSERT ||
               config.mode == FASTQ_NO_INSERT) {
      if (config.in_file.empty()) {
        printf("[ERROR] Please provide input fasta file.\n");
        exit(-1);
      }
    }

    if (config.mode == FASTQ_WITH_INSERT) {
      printf(
          "[INFO] Mode : Reading fasta from disk + inserting into hashtables "
          "...\n");
    } else if (config.mode == FASTQ_NO_INSERT) {
      printf("[INFO] Mode : Reading fasta from disk, no inserts ...\n");
    }

    if (config.ht_type == 1) {
      printf("[INFO] Hashtable type : SimpleKmerHashTable\n");
    } else if (config.ht_type == 2) {
      printf("[INFO] Hashtable type : RobinhoodKmerHashTable\n");
    } else if (config.ht_type == 3) {
      printf("[INFO] Hashtable type : CASKmerHashTable\n");
    } else if (config.ht_type == 4) {
      printf("[INFO] Hashtable type : StdmapKmerHashTable (NOT IMPLEMENTED)\n");
      printf("[INFO] Exiting ... \n");
      exit(0);
    }

    if (vm.count("help")) {
      cout << desc << "\n";
      return 1;
    }
  } catch (std::exception &e) {
    std::cout << e.what() << "\n";
    exit(-1);
  }

  if (config.mode == SYNTH) {
    synth_run_exec();
  } else if (config.mode == PREFETCH) {
    prefetch_test_run_exec();
  } else if (config.mode != BQUEUE)
    spawn_shard_threads();
  else
    spawn_shard_threads_bqueues();

  return 0;
}
