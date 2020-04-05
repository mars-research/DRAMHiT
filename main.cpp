#include <errno.h>
#include <pthread.h>
#include <time.h>
#include <zlib.h>

#include <boost/program_options.hpp>
#include <chrono>
#include <ctime>
#include <fstream>

#include "kmer_data.cpp"
#include "misc_lib.hpp"
// #include "timestamp.h"
#include "data_types.h"
#include "libfipc.h"
#include "numa.hpp"
// #include "shard.h"
// #include "test_config.h"
#include "cas_kht.hpp"
#include "kseq.h"
#include "robinhood_kht.hpp"
#include "simple_kht.hpp"

KSEQ_INIT(gzFile, gzread)

/*From /proc/cpuinfo*/
#define CPUFREQ_MHZ (2200.0)
static const float one_cycle_ns = ((float)1000 / CPUFREQ_MHZ);

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
    .in_file = std::string("/local/devel/devel/master/testfiles/turkey.fna"),
    .ht_type = 1,
    .in_file_sz = 0};  // TODO enum

/* global config */
Configuration config;

/* for synchronization of threads */
static uint64_t ready = 0;
static uint64_t ready_threads = 0;

void print_stats(__shard *all_sh)
{
  // uint64_t kmer_big_pool_size_per_shard =
  //     (config.kmer_create_data_base * config.kmer_create_data_mult);
  // uint64_t total_kmer_big_pool_size =
  //     (kmer_big_pool_size_per_shard * config.num_threads);

  // uint64_t kmer_small_pool_size_per_shard = config.kmer_create_data_uniq;
  // uint64_t total_kmer_small_pool_size =
  //     (kmer_small_pool_size_per_shard * config.num_threads);

  uint64_t all_total_cycles = 0;
  double all_total_time_ns = 0;
  uint64_t all_total_num_inserts = 0;
  // uint64_t all_total_reprobes = 0;

  uint64_t all_total_find_cycles = 0;
  double all_total_find_time_ns = 0;

  //  printf("[INFO] Thread %u. cycles/insertion: %lu, fill: %lu of %lu (%f %)
  //  \n",
  //        sh->shard_idx,
  //        sh->stats->insertion_cycles / kmer_big_pool_size_per_shard,
  //        sh->stats->ht_fill, sh->stats->ht_capacity,
  //        (double)sh->stats->ht_fill / sh->stats->ht_capacity * 100);
  printf("===============================================================\n");
  for (size_t k = 0; k < config.num_threads; k++)
  {
    printf(
        "Thread %2d: "
        "%lu cycles/insert, "
        // "%lu cycles/find "
        "{ "
        "fill: %lu of %lu (%f %)"
        " }"
#ifdef CALC_STATS
        " [num_reprobes: %lu, "
        "num_memcmps: %lu, "
        "num_memcpys: %lu, "
        "num_queue_flushes: %lu, "
        "num_hashcmps: %lu, "
        "max_distance_from_bucket: %lu, "
        "avg_distance_from_bucket: %f]"
#endif  // CALC_STATS
        "\n",
        all_sh[k].shard_idx,
        all_sh[k].stats->insertion_cycles / all_sh[k].stats->num_inserts,
        // all_sh[k].stats->find_cycles / all_sh[k].stats->num_inserts,
        all_sh[k].stats->ht_fill, all_sh[k].stats->ht_capacity,
        (double)all_sh[k].stats->ht_fill / all_sh[k].stats->ht_capacity * 100
#ifdef CALC_STATS
        ,
        all_sh[k].stats->num_reprobes, all_sh[k].stats->num_memcmps,
        all_sh[k].stats->num_memcpys, all_sh[k].stats->num_queue_flushes,
        all_sh[k].stats->num_hashcmps,
        all_sh[k].stats->max_distance_from_bucket,
        all_sh[k].stats->avg_distance_from_bucket
#endif  // CALC_STATS
    );
    all_total_cycles += all_sh[k].stats->insertion_cycles;
    all_total_time_ns +=
        (double)all_sh[k].stats->insertion_cycles * one_cycle_ns;
    all_total_num_inserts += all_sh[k].stats->num_inserts;
    // all_total_reprobes += all_sh[k].stats->num_reprobes;

    // all_total_find_cycles += all_sh[k].stats->find_cycles;
    // all_total_find_time_ns =
    //     (double)all_sh[k].stats->find_cycles * one_cycle_ns;
  }
  printf("===============================================================\n");
  printf(
      "Average (insertion) : %lu cycles (%f ms) for %lu insertions (%lu cycles "
      "per insertion)\n",
      all_total_cycles / config.num_threads,
      (double)all_total_time_ns * one_cycle_ns / 1000,
      all_total_num_inserts / config.num_threads,
      all_total_cycles / all_total_num_inserts / config.num_threads);
  // printf(
  //     "Average (find): %lu cycles (%f ms) for %lu finds (%lu cycles per "
  //     "find)\n",
  //     all_total_find_cycles / config.num_threads,
  //     (double)all_total_find_time_ns * one_cycle_ns / 1000,
  //     kmer_big_pool_size_per_shard,
  //     all_total_find_cycles / config.num_threads /
  //         kmer_big_pool_size_per_shard);
  printf("===============================================================\n");
}

/* insert kmer to non-standard (our) table */
template <typename Table>
int insert_kmer_to_table(Table *ktable, void *data)
{
  return ktable->insert(data);
}

void *shard_thread(void *arg)
{
  __shard *sh = (__shard *)arg;
  uint64_t t_start, t_end;
  gzFile fp;
  kseq_t *seq;
  int l;
  z_off_t curr_pos;

  sh->stats = (thread_stats *)memalign(__CACHE_LINE_SIZE, sizeof(thread_stats));
  // read_fasta(sh);

  // estimate of HT_SIZE TODO change
  size_t HT_SIZE = get_ht_size(config.in_file_sz, KMER_DATA_LENGTH) /
                   (30 * config.num_threads);
  printf("hashtable size: %lu\n", HT_SIZE);

  /* Create hash table */
  KmerHashTable *kmer_ht = NULL;
  if (config.ht_type == 1)
  {
    kmer_ht = new SimpleKmerHashTable(HT_SIZE);
  }
  else if (config.ht_type == 2)
  {
    kmer_ht = new RobinhoodKmerHashTable(HT_SIZE);
  }
  else if (config.ht_type == 3)
  {
    /* For the CAS Hash table, size is the same as
    size of one partitioned ht * number of threads */
    kmer_ht = new CASKmerHashTable(HT_SIZE * config.num_threads);
    /*TODO tidy this up, don't use static + locks maybe*/
  }

  // open file
  fp = gzopen(config.in_file.c_str(), "r");
  // jump to start of segment
  if (gzseek(fp, sh->f_start, SEEK_SET) == -1)
  {
    printf("[ERROR] Shard %u: Unable to seek", sh->shard_idx);
  }

  fipc_test_FAI(ready_threads);
  while (!ready) fipc_test_pause();

  // fipc_test_mfence();

  /* Begin insert loop */
  seq = kseq_init(fp);  // initialize seq data struct
  t_start = RDTSC_START();
  // each time kseq_read is called, it tries to read the next record starting
  // with > if kseq_read is called at a position in the middle of a sequence, it
  // will skip to the next record
  uint64_t num_inserts = 0;
  while ((l = kseq_read(seq)) >= 0)
  {
    // TODO i type
    for (int i = 0; i < l; i += KMER_DATA_LENGTH)
    {
      // printf("[INFO] Shard %u: i = %lu", sh->shard_idx, i);
      int res = insert_kmer_to_table(kmer_ht, (void *)(seq->seq.s + i));
      // bool res = skht_ht.insert((base_4bit_t *)&td->shard->kmer_big_pool[i]);
      if (!res)
      {
        printf("FAIL\n");
      }
      num_inserts++;
    }
    kmer_ht->flush_queue();

    // checking if reached end of assigned segment
    curr_pos = gztell(fp);
    if (curr_pos >= sh->f_end)
    {
      break;
    }
  }
  t_end = RDTSCP();
  kseq_destroy(seq);
  gzclose(fp);

  sh->stats->insertion_cycles = (t_end - t_start);
  sh->stats->num_inserts = num_inserts;
  printf("[INFO] Thread %u: Inserts complete\n", sh->shard_idx);
  /* Finish insert loop */

  sh->stats->ht_fill = kmer_ht->get_fill();
  sh->stats->ht_capacity = kmer_ht->get_capacity();
  sh->stats->max_count = kmer_ht->get_max_count();

  /* Write to file */
  if (!config.ht_file.empty())
  {
    std::string outfile = config.ht_file + std::to_string(sh->shard_idx);
    printf("[INFO] Shard %u: Printing to file: %s\n", sh->shard_idx,
           outfile.c_str());
    kmer_ht->print_to_file(outfile);
  }

#ifdef CALC_STATS
  td->num_reprobes = kmer_ht->num_reprobes;
  td->num_memcmps = kmer_ht->num_memcmps;
  td->num_memcpys = kmer_ht->num_memcpys;
  td->num_queue_flushes = kmer_ht->num_queue_flushes;
  td->num_hashcmps = kmer_ht->num_hashcmps;
  td->avg_distance_from_bucket =
      (double)(kmer_ht->sum_distance_from_bucket / HT_SIZE);
  td->max_distance_from_bucket = kmer_ht->max_distance_from_bucket;
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
  size_t seg_sz = config.in_file_sz / config.num_threads;
  if (seg_sz < 4096)
  {
    seg_sz = 4096;
  }

  if (config.numa_split)
  {
    size_t num_nodes = nodes.size();
    size_t shards_per_node = config.num_threads / num_nodes;

    /* TODO support uneven splits, and spills after splits :*/
    // size_t shards_per_node_spill = config.num_threads % num_nodes;

    for (size_t x = 0; x < num_nodes; x++)
    {
      for (size_t y = 0; y < shards_per_node; y++)
      {
        uint32_t tidx = shards_per_node * x + y;
        __shard *sh = &all_shards[tidx];
        sh->shard_idx = tidx;
        sh->f_start = round_up(seg_sz * sh->shard_idx, __PAGE_SIZE);
        sh->f_end = round_up(seg_sz * (sh->shard_idx + 1), __PAGE_SIZE);
        e = pthread_create(&threads[sh->shard_idx], NULL, shard_thread,
                           (void *)sh);
        if (e != 0)
        {
          printf(
              "[ERROR] pthread_create: "
              " Could not create create shard thread");
          exit(-1);
        }
        CPU_ZERO(&cpuset);
        CPU_SET(nodes[x].cpu_list[y], &cpuset);
        pthread_setaffinity_np(threads[sh->shard_idx], sizeof(cpu_set_t),
                               &cpuset);
        printf("[INFO] Thread: %u, set affinity: %u\n", tidx,
               nodes[x].cpu_list[y]);
      }
    }
  }

  else if (!config.numa_split)
  {
    for (size_t x = 0; x < config.num_threads; x++)
    {
      __shard *sh = &all_shards[x];
      sh->shard_idx = x;
      sh->f_start = round_up(seg_sz * x, __PAGE_SIZE);
      sh->f_end = round_up(seg_sz * (x + 1), __PAGE_SIZE);
      e = pthread_create(&threads[x], NULL, shard_thread, (void *)sh);
      if (e != 0)
      {
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

  while (ready_threads < config.num_threads)
  {
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
  try
  {
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
        "num_threads",
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
        "numa_split",
        po::value<bool>(&config.numa_split)->default_value(def.numa_split),
        "Split spwaning threads between numa nodes")(
        "stats",
        po::value<std::string>(&config.stats_file)
            ->default_value(def.stats_file),
        "Stats file name.")(
        "ht_type",
        po::value<uint32_t>(&config.ht_type)->default_value(def.ht_type),
        "1: SimpleKmerHashTable \n2: "
        "RobinhoodKmerHashTable, \n3: CASKmerHashTable, \n4. "
        "StdmapKmerHashTable")(
        "out_file",
        po::value<std::string>(&config.ht_file)->default_value(def.ht_file),
        "Hashtable output file name.")(
        "in_file",
        po::value<std::string>(&config.in_file)->default_value(def.in_file),
        "Input fasta file");

    po::variables_map vm;
    po::store(po::parse_command_line(argc, argv, desc), vm);
    po::notify(vm);

    if (!config.in_file.empty())
    {
      config.read_write_kmers = 4;
    }

    if (config.read_write_kmers == 1)
    {
      printf("[INFO] Mode : Dry run ...\n");
      printf("[INFO] base: %lu, mult: %u, uniq: %lu\n",
             config.kmer_create_data_base, config.kmer_create_data_mult,
             config.kmer_create_data_uniq);
    }
    else if (config.read_write_kmers == 2)
    {
      printf("[INFO] Mode : Reading kmers from disk ...\n");
    }
    else if (config.read_write_kmers == 3)
    {
      printf("[INFO] Mode : Writing kmers to disk ...\n");
      printf("[INFO] base: %lu, mult: %u, uniq: %lu\n",
             config.kmer_create_data_base, config.kmer_create_data_mult,
             config.kmer_create_data_uniq);
    }
    else if (config.read_write_kmers == 4)
    {
      printf("[INFO] Mode : Reading fasta from disk ...\n");
      if (config.in_file.empty())
      {
        printf("[ERROR] Please provide input fasta file.\n");
        exit(-1);
      }
    }

    if (config.ht_type == 1)
    {
      printf("[INFO] Hashtable type : SimpleKmerHashTable\n");
    }
    else if (config.ht_type == 2)
    {
      printf("[INFO] Hashtable type : RobinhoodKmerHashTable\n");
    }
    else if (config.ht_type == 3)
    {
      printf("[INFO] Hashtable type : CASKmerHashTable\n");
    }
    else if (config.ht_type == 4)
    {
      printf("[INFO] Hashtable type : StdmapKmerHashTable (NOT IMPLEMENTED)\n");
      printf("[INFO] Exiting ... \n");
      exit(0);
    }

    if (vm.count("help"))
    {
      cout << desc << "\n";
      return 1;
    }
  }
  catch (std::exception &e)
  {
    std::cout << e.what() << "\n";
    exit(-1);
  }

  spawn_shard_threads();
}
