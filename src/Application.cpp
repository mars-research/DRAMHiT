#include <errno.h>
#include <pthread.h>
#include <time.h>
#include <zlib.h>

#include <boost/program_options.hpp>
#include <chrono>
#include <cmath>
#include <ctime>
#include <fstream>

#include "ac_kseq.hpp"
#include "ac_kstream.hpp"
#include "kmer_data.cpp"
#include "misc_lib.h"
#include "types.hpp"

#include "./hashtables/cas_kht.hpp"
#include "./hashtables/robinhood_kht.hpp"
#include "./hashtables/simple_kht.hpp"
#include "Application.hpp"
#include "print_stats.h"

#ifdef WITH_PAPI_LIB
#include <papi.h>
#endif

namespace kmercounter {

extern uint64_t HT_TESTS_HT_SIZE;
extern uint64_t HT_TESTS_NUM_INSERTS;

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
    .ht_fill = 25};  // TODO enum

/* global config */
Configuration config;

/* for synchronization of threads */
static uint64_t ready = 0;
static uint64_t ready_threads = 0;

KmerHashTable *init_ht(const uint64_t sz, uint8_t id) {
  KmerHashTable *kmer_ht = NULL;

  // Create hash table
  if (config.ht_type == SIMPLE_KHT) {
    kmer_ht = new SimpleKmerHashTable(sz, id);
  } else if (config.ht_type == ROBINHOOD_KHT) {
    kmer_ht = new RobinhoodKmerHashTable(sz);
  } else if (config.ht_type == CAS_KHT) {
    /* For the CAS Hash table, size is the same as
    size of one partitioned ht * number of threads */
    kmer_ht = new CASKmerHashTable(sz * config.num_threads);
    /*TODO tidy this up, don't use static + locks maybe*/
  } else {
    fprintf(stderr, "STDMAP_KHT Not implemented\n");
  }
  return kmer_ht;
}

void Application::shard_thread(int tid) {
  Shard *sh = &this->shards[tid];
  KmerHashTable *kmer_ht = NULL;

  sh->stats =
      (thread_stats *)std::aligned_alloc(CACHE_LINE_SIZE, sizeof(thread_stats));

  switch (config.mode) {
    case FASTQ_WITH_INSERT:
      kmer_ht = init_ht(config.in_file_sz / config.num_threads, sh->shard_idx);
      break;
    case SYNTH:
    case PREFETCH:
    case BQ_TESTS_NO_BQ:
      kmer_ht = init_ht(HT_TESTS_HT_SIZE, sh->shard_idx);
      break;
    case FASTQ_NO_INSERT:
      break;
    default:
      fprintf(stderr, "[ERROR] No config mode specified! cannot run");
      return;
  }

  fipc_test_FAI(ready_threads);
  while (!ready) fipc_test_pause();

  // fipc_test_mfence();
  /* Begin insert loops */
  switch (config.mode) {
    case FASTQ_WITH_INSERT:
      this->test.pat.shard_thread_parse_and_insert(sh, kmer_ht);
      break;
    case SYNTH:
      this->test.st.synth_run_exec(sh, kmer_ht);
      break;
    case PREFETCH:
      this->test.pt.prefetch_test_run_exec(sh, kmer_ht);
      break;
    case BQ_TESTS_NO_BQ:
      this->test.bqt.no_bqueues(sh, kmer_ht);
      break;
    case FASTQ_NO_INSERT:
      this->test.pat.shard_thread_parse_no_inserts_v3(sh, config);
      break;
    default:
      break;
  }

  // Write to file
  if (config.mode != FASTQ_NO_INSERT && !config.ht_file.empty()) {
    std::string outfile = config.ht_file + std::to_string(sh->shard_idx);
    printf("[INFO] Shard %u: Printing to file: %s\n", sh->shard_idx,
           outfile.c_str());
    kmer_ht->print_to_file(outfile);
  }

  fipc_test_FAD(ready_threads);

  return;
}

int Application::spawn_shard_threads() {
  cpu_set_t cpuset;
  this->threads = new std::thread[config.num_threads];

  this->shards = (Shard *)std::aligned_alloc(
      CACHE_LINE_SIZE, sizeof(Shard) * config.num_threads);

  memset(this->shards, 0, sizeof(Shard) * config.num_threads);

  size_t seg_sz = 0;

  if ((config.mode != SYNTH) && (config.mode != PREFETCH)) {
    config.in_file_sz = get_file_size(config.in_file.c_str());
    printf("[INFO] File size: %lu bytes\n", config.in_file_sz);
    seg_sz = config.in_file_sz / config.num_threads;
    if (seg_sz < 4096) {
      seg_sz = 4096;
    }
  }

  /*   TODO don't spawn threads if f_start >= in_file_sz
    Not doing it now, as it has implications for num_threads,
    which is used in calculating stats */

  /*   TODO use PGROUNDUP instead of round_up()
    #define PGROUNDUP(sz) (((sz)+PGSIZE−1) & ~(PGSIZE−1))
    #define PGROUNDDOWN(a) (((a)) & ~(PGSIZE−1)) */

  if (config.numa_split) {
    size_t num_total_cpus = 0;
    size_t num_nodes = nodes.size();
    size_t threads_per_node = (size_t)config.num_threads / num_nodes;  // 3
    size_t threads_per_node_spill =
        (size_t)config.num_threads % num_nodes;  // 2

    for (auto i : nodes) num_total_cpus += i.cpu_list.size();

    // 3*4+2
    printf("[INFO] # nodes: %lu, # cpus (total): %lu\n", num_nodes,
           num_total_cpus);
    printf(
        "[INFO] # threads (from config): %u # threads per node: %lu, # threads "
        "spill: %lu\n",
        config.num_threads, threads_per_node, threads_per_node_spill);

    if (config.num_threads > num_total_cpus - 1) {
      fprintf(stderr,
              "[ERROR] More threads configured than cores available (Note: one "
              "core assigned completely for synchronization) \n");
      exit(-1);
    }

    size_t shard_idx_ctr = 0;
    size_t node_idx_ctr = 0;
    size_t cpu_idx_ctr = 0;
    size_t last_cpu_idx = 0;
    uint32_t i;

    for (i = 0; i < threads_per_node * num_nodes; i++) {
      Shard *sh = &this->shards[i];
      sh->shard_idx = i;
      sh->f_start = round_up(seg_sz * sh->shard_idx, PAGE_SIZE);
      sh->f_end = round_up(seg_sz * (sh->shard_idx + 1), PAGE_SIZE);

      this->threads[i] = std::thread(&Application::shard_thread, this, i);

      CPU_ZERO(&cpuset);
      uint32_t cpu_assigned = nodes[node_idx_ctr].cpu_list[cpu_idx_ctr];
      CPU_SET(cpu_assigned, &cpuset);
      pthread_setaffinity_np(this->threads[i].native_handle(),
                             sizeof(cpu_set_t), &cpuset);
      printf("[INFO] Thread %u: node: %lu, affinity: %u\n", sh->shard_idx,
             node_idx_ctr, cpu_assigned);

      cpu_idx_ctr += 1;
      if (cpu_idx_ctr == threads_per_node) {
        printf("---------\n");
        node_idx_ctr++;
        last_cpu_idx = cpu_idx_ctr;
        cpu_idx_ctr = 0;
      }
    }

    shard_idx_ctr = i - 1;
    node_idx_ctr = 0;
    for (auto i = 0u; i < threads_per_node_spill; i++) {
      Shard *sh = &this->shards[shard_idx_ctr];
      sh->shard_idx = shard_idx_ctr;

      sh->f_start = round_up(seg_sz * sh->shard_idx, PAGE_SIZE);
      sh->f_end = round_up(seg_sz * (sh->shard_idx + 1), PAGE_SIZE);

      this->threads[shard_idx_ctr] =
          std::thread(&Application::shard_thread, this, shard_idx_ctr);

      CPU_ZERO(&cpuset);
      uint32_t cpu_assigned = nodes[node_idx_ctr].cpu_list[last_cpu_idx];
      CPU_SET(cpu_assigned, &cpuset);
      pthread_setaffinity_np(threads[sh->shard_idx].native_handle(),
                             sizeof(cpu_set_t), &cpuset);
      printf("[INFO] Thread %u: node: %lu, affinity: %u\n", sh->shard_idx,
             node_idx_ctr, cpu_assigned);
      node_idx_ctr++;
    }
  }

  else if (!config.numa_split) {
    for (size_t i = 0; i < config.num_threads; i++) {
      Shard *sh = &this->shards[i];
      sh->shard_idx = i;
      sh->f_start = round_up(seg_sz * i, PAGE_SIZE);
      sh->f_end = round_up(seg_sz * (i + 1), PAGE_SIZE);

      /* TODO don't spawn threads if f_start >= in_file_sz */
      this->threads[i] = std::thread(&Application::shard_thread, this, i);

      CPU_ZERO(&cpuset);
      size_t cpu_idx = i % nodes[0].cpu_list.size();
      CPU_SET(nodes[0].cpu_list[cpu_idx], &cpuset);
      pthread_setaffinity_np(threads[i].native_handle(), sizeof(cpu_set_t),
                             &cpuset);

      printf("[INFO] Thread: %lu, set affinity: %u\n", i,
             nodes[0].cpu_list[cpu_idx]);
    }
  }

  CPU_ZERO(&cpuset);
  /* last cpu of last node  */
  auto last_numa_node = nodes[n->get_num_nodes() - 1];
  CPU_SET(last_numa_node.cpu_list[last_numa_node.num_cpus - 1], &cpuset);
  sched_setaffinity(0, sizeof(cpu_set_t), &cpuset);

  while (ready_threads < config.num_threads) {
    fipc_test_pause();
  }

  // fipc_test_mfence();
  ready = 1;

  /* TODO thread join vs sync on atomic variable*/
  while (ready_threads) fipc_test_pause();

  for (auto t = 0u; t < config.num_threads; t++) {
    if (this->threads[t].joinable()) {
      this->threads[t].join();
    }
  }

  print_stats(this->shards, config);

  delete [] threads;
  std::free(this->shards);

  return 0;
}

#ifdef WITH_PAPI_LIB
void papi_init(void) {
  if (PAPI_library_init(PAPI_VER_CURRENT) != PAPI_VER_CURRENT) {
    printf("Library initialization error! \n");
    exit(1);
  }
  printf("PAPI library initialized\n");
}
#else
void papi_init(void) {}
#endif

int Application::process(int argc, char *argv[]) {
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
        "ht-type",
        po::value<uint32_t>(&config.ht_type)->default_value(def.ht_type),
        "1: SimpleKmerHashTable \n2: "
        "RobinhoodKmerHashTable, \n3: CASKmerHashTable, \n4. "
        "StdmapKmerHashTable")(
        "out-file",
        po::value<std::string>(&config.ht_file)->default_value(def.ht_file),
        "Hashtable output file name.")(
        "in-file",
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

    if (config.ht_type == SIMPLE_KHT) {
      printf("[INFO] Hashtable type : SimpleKmerHashTable\n");
    } else if (config.ht_type == ROBINHOOD_KHT) {
      printf("[INFO] Hashtable type : RobinhoodKmerHashTable\n");
    } else if (config.ht_type == CAS_KHT) {
      printf("[INFO] Hashtable type : CASKmerHashTable\n");
    } else if (config.ht_type == STDMAP_KHT) {
      printf("[INFO] Hashtable type : StdmapKmerHashTable (NOT IMPLEMENTED)\n");
      printf("[INFO] Exiting ... \n");
      exit(0);
    }

    if (config.ht_fill) {
      if (config.ht_fill > 0 && config.ht_fill < 100) {
        HT_TESTS_NUM_INSERTS =
            static_cast<double>(HT_TESTS_HT_SIZE) * config.ht_fill * 0.01;
      }
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

  if (config.mode == BQ_TESTS_YES_BQ) {
    this->test.bqt.run_test(&config, this->n);
  } else {
    spawn_shard_threads();
  }

  return 0;
}
}  // namespace kmercounter
