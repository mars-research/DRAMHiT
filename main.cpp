#include <errno.h>
#include <pthread.h>
#include <time.h>
#include <zlib.h>

#include <boost/program_options.hpp>
#include <chrono>
#include <cmath>
#include <ctime>
#include <fstream>

#include "data_types.h"
#include "kmer_data.cpp"
#include "misc_lib.h"
// #include "timestamp.h"
#include "libfipc/libfipc_test_config.h"
#include "numa.hpp"
// #include "shard.h"
// #include "test_config.h"
#include "ac_kseq.h"
#include "ac_kstream.h"
// #include "kseq.h"

#include "./hashtables/cas_kht.hpp"
#include "./hashtables/robinhood_kht.hpp"
#include "./hashtables/simple_kht.hpp"
#include "bq_tests.cpp"
#include "hashtable_tests.cpp"
#include "parser_tests.cpp"
#include "print_stats.h"

#ifdef WITH_PAPI_LIB
#include <papi.h>
#endif

/* Numa config */
Numa n;
std::vector<numa_node> nodes = n.get_node_config();

/* default config */
const Configuration def = {
    .kmer_create_data_base = 524288,
    .kmer_create_data_mult = 1,
    .kmer_create_data_uniq = 1048576,
    .num_threads = 1,
    .mode = BQ_TESTS_YES_BQ,  // TODO enum
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
    .n_cons = 1,
    .K = 20,
    .ht_fill = 50};  // TODO enum

/* global config */
Configuration config;

/* for synchronization of threads */
static uint64_t ready = 0;
static uint64_t ready_threads = 0;

KmerHashTable *init_ht(uint64_t sz, uint8_t id)
{
  KmerHashTable *kmer_ht = NULL;

  /* Create hash table */
  if (config.ht_type == 1) {
    kmer_ht = new SimpleKmerHashTable(sz, id);
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

void *shard_thread(void *arg)
{
  __shard *sh = (__shard *)arg;
  KmerHashTable *kmer_ht = NULL;

  sh->stats = (thread_stats *)memalign(__CACHE_LINE_SIZE, sizeof(thread_stats));

  if (config.mode == FASTQ_WITH_INSERT) {
    kmer_ht = init_ht(config.in_file_sz / config.num_threads, sh->shard_idx);
  } else if (config.mode == SYNTH || config.mode == PREFETCH) {
    kmer_ht = init_ht(HT_TESTS_HT_SIZE, sh->shard_idx);
  } else if (config.mode == BQ_TESTS_NO_BQ) {
    kmer_ht = init_ht(BQ_TESTS_HT_SIZE, sh->shard_idx);
  } else if (config.mode == FASTQ_NO_INSERT) {
    // no ht needed
  } else {
    fprintf(stderr, "[ERROR] No config mode specified! cannot run");
    return NULL;
  }

  fipc_test_FAI(ready_threads);
  while (!ready) fipc_test_pause();

  // fipc_test_mfence();
  /* Begin insert loops */
  if (config.mode == FASTQ_NO_INSERT) {
    shard_thread_parse_no_inserts_v3(sh);
  } else if (config.mode == FASTQ_WITH_INSERT) {
    shard_thread_parse_and_insert(sh, kmer_ht);
  } else if (config.mode == SYNTH) {
    synth_run_exec(sh, kmer_ht);
  } else if (config.mode == PREFETCH) {
    prefetch_test_run_exec(sh, kmer_ht);
  } else if (config.mode == BQ_TESTS_NO_BQ) {
    no_bqueues(sh, kmer_ht);
  }

  /* Write to file */
  if (config.mode != FASTQ_NO_INSERT && !config.ht_file.empty()) {
    std::string outfile = config.ht_file + std::to_string(sh->shard_idx);
    printf("[INFO] Shard %u: Printing to file: %s\n", sh->shard_idx,
           outfile.c_str());
    kmer_ht->print_to_file(outfile);
  }

  fipc_test_FAD(ready_threads);

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
  __shard *all_shards =
      (__shard *)memalign(FIPC_CACHE_LINE_SIZE,
                          sizeof(__shard) * (producer_count + consumer_count));

  memset(all_shards, 0, sizeof(__shard) * (producer_count + consumer_count));

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
      printf("[INFO] prod_queues[%lu][%lu] = %p\n", i, j,
             &queues[i * consumer_count + j]);
    }
  }

  for (i = 0; i < consumer_count; ++i) {
    for (j = 0; j < producer_count; ++j) {
      cons_queues[i][j] = &queues[i + j * consumer_count];
      printf("[INFO] cons_queues[%lu][%lu] = %p\n", i, j,
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
    sh->shard_idx = x;
    e = pthread_create(&prod_threads[x], NULL, producer_thread, (void *)sh);
    if (e != 0) {
      printf(
          "[ERROR]: pthread_create: Could not create thread: "
          "producer_thread\n");
      exit(-1);
    }
    CPU_ZERO(&cpuset);
    size_t cpu_idx = (x % nodes[0].cpu_list.size()) * 2;  // {0,2,4,6,8}
    CPU_SET(nodes[0].cpu_list[cpu_idx], &cpuset);
    pthread_setaffinity_np(prod_threads[x], sizeof(cpu_set_t), &cpuset);
    printf("[INFO]: Spawn producer_thread %lu, affinity: %u\n", x,
           nodes[0].cpu_list[cpu_idx]);
  }

  /* Spawn consumer threads */
  for (size_t x = producer_count, y = 0; x < producer_count + consumer_count;
       x++, y++) {
    __shard *sh = &all_shards[x];
    sh->shard_idx = x;
    e = pthread_create(&cons_threads[y], NULL, consumer_thread, (void *)sh);
    if (e != 0) {
      printf(
          "[ERROR] pthread_create: Could not create thread: consumer_thread\n");
      exit(-1);
    }
    CPU_ZERO(&cpuset);
    size_t cpu_idx = (y % nodes[0].cpu_list.size()) * 2 + 1;  //{1,3,5,7,9}
    CPU_SET(nodes[0].cpu_list[cpu_idx], &cpuset);
    pthread_setaffinity_np(cons_threads[y], sizeof(cpu_set_t), &cpuset);
    printf("[INFO]: Spawn consumer_thread %lu, affinity: %u\n", y,
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

  config.num_threads = producer_count + consumer_count;
  print_stats(all_shards);

  /* Tell consumers to halt once producers are done */
  return 0;

  /* TODO free everything */
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

  print_stats(all_shards);

  free(threads);
  free(all_shards);

  return 0;
}

#ifdef WITH_PAPI_LIB
void papi_init(void)
{
  if (PAPI_library_init(PAPI_VER_CURRENT) != PAPI_VER_CURRENT) {
    printf("Library initialization error! \n");
    exit(1);
  }
  printf("PAPI library initialized\n");
}
#else
void papi_init(void) {}
#endif

int main(int argc, char *argv[])
{
  try {
    namespace po = boost::program_options;
    po::options_description desc("Program options");

    desc.add_options()("help", "produce help message")(
        "mode",
        po::value<uint32_t>((uint32_t *)&config.mode)->default_value(def.mode),
        "1: Dry run \n2: Read K-mers from disk \n3: Write K-mers to disk "
        "\n4: Read FASTQ, and insert to ht (specify --in_file)"
        "\n5: Read FASTQ, but do not insert to ht (specify --in_file) "
        "\n6/7: Synth/Prefetch,"
        "\n8/9: Bqueue tests: with bqueues/without bequeues")(
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
        "for bqueues only")(
        "k", po::value<uint32_t>(&config.K)->default_value(def.K),
        "the value of 'k' in k-mer")(
        "ht-fill",
        po::value<uint32_t>(&config.ht_fill)->default_value(def.ht_fill),
        "adjust hashtable fill ratio [0-100] ");

    papi_init();

    po::variables_map vm;
    po::store(po::parse_command_line(argc, argv, desc), vm);
    po::notify(vm);

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
    } else if (config.mode == FASTQ_WITH_INSERT) {
      printf("[INFO] Mode : FASTQ_WITH_INSERT\n");
      if (config.in_file.empty()) {
        printf("[ERROR] Please provide input fasta file.\n");
        exit(-1);
      }
    } else if (config.mode == FASTQ_NO_INSERT) {
      printf("[INFO] Mode : FASTQ_NO_INSERT\n");
      if (config.in_file.empty()) {
        printf("[ERROR] Please provide input fasta file.\n");
        exit(-1);
      }
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

  if (config.drop_caches) {
    printf("[INFO] Dropping the page cache\n");
    if (system("sudo bash -c 'echo 3 > /proc/sys/vm/drop_caches'") < 0) {
      perror("drop caches");
    }
  }

  if (config.mode == BQ_TESTS_YES_BQ)
    spawn_shard_threads_bqueues();
  else
    spawn_shard_threads();

  return 0;
}
