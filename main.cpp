#include <errno.h>
#include <pthread.h>
#include <time.h>
#include <zlib.h>

#include <boost/program_options.hpp>
#include <chrono>
#include <cmath>
#include <ctime>
#include <fstream>

#include "./include/misc_lib.h"
#include "kmer_data.cpp"
// #include "./include/timestamp.h"
#include "./include/data_types.h"
#include "./include/libfipc.h"
#include "./include/numa.hpp"
// #include "shard.h"
// #include "test_config.h"
#include "./include/ac_kseq.h"
// #include "kseq.h"

#include "./hashtables/cas_kht.hpp"
#include "./hashtables/robinhood_kht.hpp"
#include "./hashtables/simple_kht.hpp"
#include "./include/print_stats.h"

/* Numa config */
Numa n;
std::vector<numa_node> nodes = n.get_node_config();

/* default config */
const Configuration def = {
    .kmer_create_data_base = 524288,
    .kmer_create_data_mult = 1,
    .kmer_create_data_uniq = 1048576,
    .num_threads = 10,
    .read_write_kmers = 1,  // TODO enum
    .kmer_files_dir = std::string("/local/devel/pools/million/39/"),
    .alphanum_kmers = true,
    .numa_split = false,
    .stats_file = std::string(""),
    .ht_file = std::string(""),
    .in_file = std::string("/local/devel/devel/datasets/turkey/myseq0.fa"),
    .ht_type = 1,
    .in_file_sz = 0,
    .drop_caches = true};  // TODO enum

/* global config */
Configuration config;

/* for synchronization of threads */
static uint64_t ready = 0;
static uint64_t ready_threads = 0;

/* insert kmer to non-standard (our) table */
template <typename Table>
inline int __attribute__((optimize("O0")))
insert_kmer_to_table(Table *ktable, void *data, uint64_t *num_inserts)
{
  (*num_inserts)++;
  return ktable->insert(data);
}

void *shard_thread(void *arg)
{
  __shard *sh = (__shard *)arg;
  uint64_t t_start, t_end;
  int fp;
  off64_t curr_pos;
  kseq seq;
  int l = 0;
  FunctorRead r;
  int res;
  KmerHashTable *kmer_ht = NULL;

  sh->stats = (thread_stats *)memalign(__CACHE_LINE_SIZE, sizeof(thread_stats));
  printf("[INFO] Thread %u: f_start %lu, f_end: %lu\n", sh->shard_idx,
         sh->f_start, sh->f_end);

  // open file
  fp = open(config.in_file.c_str(), O_RDONLY);
  // jump to start of segment
  /*   if (sh->shard_idx != 0) {
      if (lseek64(fp, sh->f_start, SEEK_SET) == -1) {
        printf("[ERROR] Shard %u: Unable to seek", sh->shard_idx);
      }
    } else {
      if (lseek64(fp, sh->f_start, SEEK_SET) == -1) {
        printf("[ERROR] Shard %u: Unable to seek", sh->shard_idx);
      }
    } */

  if (lseek64(fp, sh->f_start, SEEK_SET) == -1) {
    printf("[ERROR] Shard %u: Unable to seek", sh->shard_idx);
  }

  kstream<int, FunctorRead> ks(fp, r, sh->shard_idx, sh->f_start, sh->f_end);

  /* estimate of ht_size TODO change */
  size_t ht_size = config.in_file_sz / config.num_threads;

  /* Create hash table */
  if (config.ht_type == 1) {
    kmer_ht = new SimpleKmerHashTable(ht_size);
  } else if (config.ht_type == 2) {
    kmer_ht = new RobinhoodKmerHashTable(ht_size);
  } else if (config.ht_type == 3) {
    /* For the CAS Hash table, size is the same as
    size of one partitioned ht * number of threads */
    kmer_ht = new CASKmerHashTable(ht_size * config.num_threads);
    /*TODO tidy this up, don't use static + locks maybe*/
  }

  fipc_test_FAI(ready_threads);
  while (!ready) fipc_test_pause();

  // fipc_test_mfence();
  printf("[INFO] Thread %u: begin insert loop \n", sh->shard_idx);

  /* Begin insert loop */
  t_start = RDTSC_START();

  uint64_t avg_read_length = 0;
  uint64_t num_sequences = 0;

  uint64_t num_inserts = 0;
  while ((l = ks.read(seq)) >= 0) {
    for (int i = 0; i < (l - KMER_DATA_LENGTH + 1); i++) {
      char *kmer = seq.seq.data() + i;
      int found_N = find_last_N_in_seq(kmer);
      if (found_N >= 0) {
        i += found_N;
        continue;
      }

      res = insert_kmer_to_table(kmer_ht, (void *)kmer, &num_inserts);
      if (!res) {
        printf("FAIL\n");
      }

#ifdef CALC_STATS
      num_sequences++;
      if (!avg_read_length) {
        avg_read_length = seq.seq.length();
      } else {
        avg_read_length = (avg_read_length + seq.seq.length()) / 2;
      }
#endif
    }
  }
  t_end = RDTSCP();
  close(fp);
  // kseq_destroy(seq);
  // gzclose(fp);
  printf("[INFO] Thread %u: last seq: %s\n", sh->shard_idx, seq.seq.data());
  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = num_inserts;
  printf("[INFO] Thread %u: Inserts complete\n", sh->shard_idx);
  /* Finish insert loop */

  sh->stats->ht_fill = kmer_ht->get_fill();
  sh->stats->ht_capacity = kmer_ht->get_capacity();
  sh->stats->max_count = kmer_ht->get_max_count();

  /* Write to file */
  if (!config.ht_file.empty()) {
    std::string outfile = config.ht_file + std::to_string(sh->shard_idx);
    printf("[INFO] Shard %u: Printing to file: %s\n", sh->shard_idx,
           outfile.c_str());
    kmer_ht->print_to_file(outfile);
  }

#ifdef CALC_STATS
  sh->stats->num_reprobes = kmer_ht->num_reprobes;
  sh->stats->num_memcmps = kmer_ht->num_memcmps;
  sh->stats->num_memcpys = kmer_ht->num_memcpys;
  sh->stats->num_queue_flushes = kmer_ht->num_queue_flushes;
  sh->stats->num_hashcmps = kmer_ht->num_hashcmps;
  sh->stats->avg_distance_from_bucket =
      (double)(kmer_ht->sum_distance_from_bucket / ht_size);
  sh->stats->max_distance_from_bucket = kmer_ht->max_distance_from_bucket;
  sh->stats->avg_read_length = avg_read_length;
  sh->stats->num_sequences = num_sequences;
#endif

  fipc_test_FAD(ready_threads);

  return NULL;
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

  config.in_file_sz = get_file_size(config.in_file.c_str());
  printf("[INFO] File size: %lu bytes\n", config.in_file_sz);
  size_t seg_sz = config.in_file_sz / config.num_threads;
  if (seg_sz < 4096) {
    seg_sz = 4096;
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

int main(int argc, char *argv[])
{
  try {
    namespace po = boost::program_options;
    po::options_description desc("Program options");

    desc.add_options()("help", "produce help message")(
        "mode",
        po::value<uint32_t>(&config.read_write_kmers)
            ->default_value(def.read_write_kmers),
        "1: Dry run \n2: Read K-mers from disk \n3: Write K-mers to disk \n4: "
        "Read Fasta from disk (--in_file)")(
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
        "files_dir",
        po::value<std::string>(&config.kmer_files_dir)
            ->default_value(def.kmer_files_dir),
        "Directory of input files, files should be in format: '\\d{2}.bin'")(
        "alphanum",
        po::value<bool>(&config.alphanum_kmers)
            ->default_value(def.alphanum_kmers),
        "Use alphanum_kmers (for debugging)")(
        "numa-split",
        po::value<bool>(&config.numa_split)->default_value(def.numa_split),
        "Split spwaning threads between numa nodes")(
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
        "drop page cache before run");

    po::variables_map vm;
    po::store(po::parse_command_line(argc, argv, desc), vm);
    po::notify(vm);

    if (config.drop_caches) {
      printf("[INFO] Dropping the page cache\n");
      if (system("sudo bash -c 'echo 3 > /proc/sys/vm/drop_caches'") < 0) {
        perror("drop caches");
      }
    }

    if (!config.in_file.empty()) {
      config.read_write_kmers = 4;
    }

    if (config.read_write_kmers == 1) {
      printf("[INFO] Mode : Dry run ...\n");
      printf("[INFO] base: %lu, mult: %u, uniq: %lu\n",
             config.kmer_create_data_base, config.kmer_create_data_mult,
             config.kmer_create_data_uniq);
    } else if (config.read_write_kmers == 2) {
      printf("[INFO] Mode : Reading kmers from disk ...\n");
    } else if (config.read_write_kmers == 3) {
      printf("[INFO] Mode : Writing kmers to disk ...\n");
      printf("[INFO] base: %lu, mult: %u, uniq: %lu\n",
             config.kmer_create_data_base, config.kmer_create_data_mult,
             config.kmer_create_data_uniq);
    } else if (config.read_write_kmers == 4) {
      printf("[INFO] Mode : Reading fasta from disk ...\n");
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

  spawn_shard_threads();
}