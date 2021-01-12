#include "Application.hpp"

#include <errno.h>
#include <pthread.h>
#include <time.h>
#include <zlib.h>

#include <boost/program_options.hpp>
#include <chrono>
#include <cmath>
#include <ctime>
#include <fstream>

#include "./hashtables/cas_kht.hpp"
#include "./hashtables/robinhood_kht.hpp"
#include "./hashtables/simple_kht.hpp"
#include "PrefetchTest.hpp"
#include "ac_kseq.hpp"
#include "ac_kstream.hpp"
#include "kmer_data.cpp"
#include "misc_lib.h"
#include "print_stats.h"
#include "types.hpp"

#ifdef WITH_PAPI_LIB
#include <papi.h>

#include "PapiEvent.hpp"
#endif

#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
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
    .num_nops = 0,
    .K = 20,
    .ht_fill = 25};  // TODO enum

/* global config */
Configuration config;

/* for synchronization of threads */
static uint64_t ready = 0;
static uint64_t ready_threads = 0;

#ifdef WITH_PAPI_LIB
PapiEvent pr(6);
PapiEvent pw(6);

PapiEvent pr1(6);
PapiEvent pw1(6);
#endif

BaseHashTable *init_ht(const uint64_t sz, uint8_t id) {
  BaseHashTable *kmer_ht = NULL;

  // Create hash table
  if (config.ht_type == SIMPLE_KHT) {
    kmer_ht = new PartitionedHashStore<Item, ItemQueue>(sz, id);
  } else if (config.ht_type == ROBINHOOD_KHT) {
    kmer_ht = new RobinhoodKmerHashTable(sz);
  } else if (config.ht_type == CAS_KHT) {
    /* For the CAS Hash table, size is the same as
    size of one partitioned ht * number of threads */
    kmer_ht =
        new CASHashTable<Aggr_KV, ItemQueue>(sz);  // * config.num_threads);
    /*TODO tidy this up, don't use static + locks maybe*/
  } else if (config.ht_type == CAS_NOPREFETCH) {
    kmer_ht = new CASHashTable<Aggr_KV, ItemQueue>(sz * config.num_threads);
  } else {
    fprintf(stderr, "STDMAP_KHT Not implemented\n");
  }
  return kmer_ht;
}

void free_ht(BaseHashTable *kmer_ht) {
  printf("Calling free_ht\n");
  delete kmer_ht;
}

void Application::shard_thread(int tid) {
  Shard *sh = &this->shards[tid];
  BaseHashTable *kmer_ht = NULL;

  sh->stats =
      (thread_stats *)std::aligned_alloc(CACHE_LINE_SIZE, sizeof(thread_stats));

  switch (config.mode) {
    case FASTQ_WITH_INSERT:
      kmer_ht = init_ht(config.in_file_sz / config.num_threads, sh->shard_idx);
      break;
    case PREFETCH:
      kmer_ht = new PartitionedHashStore<Prefetch_KV, PrefetchKV_Queue>(
          HT_TESTS_HT_SIZE, sh->shard_idx);
      break;
    case SYNTH:
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

#ifdef WITH_PAPI_LIB
  auto retval = PAPI_thread_init((unsigned long (*)(void))(pthread_self));
  if (retval != PAPI_OK) {
    printf("PAPI Thread init failed\n");
  }

  if (ready_threads == config.num_threads) {
    pr.init_event(0);
    pr1.init_event(1);

    pw.init_event(0);
    pw1.init_event(1);

    std::string cha_box("skx_unc_cha");
    std::string imc_box("skx_unc_imc");

    std::string req_read("UNC_C_REQUESTS:READS");
    std::string req_wr("UNC_C_IMC_WRITES_COUNT:FULL");

    std::string cas_rd("UNC_M_CAS_COUNT:RD");
    std::string cas_wr("UNC_M_CAS_COUNT:WR");

    // pr.add_event(req_read, cha_box);
    // pr1.add_event(req_read, cha_box);

    // pw.add_event(req_wr, cha_box);
    // pw1.add_event(req_wr, cha_box);

    pr.add_event(cas_rd, imc_box);
    pr1.add_event(cas_rd, imc_box);

    pw.add_event(cas_wr, imc_box);
    pw1.add_event(cas_wr, imc_box);

    pr.start();
    pw.start();

    pr1.start();
    pw1.start();

    ready = 1;
  }
#endif

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
      this->test.pt.prefetch_test_run_exec(sh, config, kmer_ht);
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
    // for CAS hashtable, not every thread has to write to file
    if ((config.ht_type == CAS_KHT) && (sh->shard_idx > 0)) {
      goto done;
    }
    std::string outfile = config.ht_file + std::to_string(sh->shard_idx);
    printf("[INFO] Shard %u: Printing to file: %s\n", sh->shard_idx,
           outfile.c_str());
    kmer_ht->print_to_file(outfile);
  }

  // free_ht(kmer_ht);

done:

  fipc_test_FAD(ready_threads);

#ifdef WITH_PAPI_LIB
  if (ready_threads == 0) {
    pr.stop();
    pw.stop();

    pr1.stop();
    pw1.stop();
  }  // PapiEvent scope
#endif
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

  if (config.ht_type == CAS_KHT) {
    HT_TESTS_NUM_INSERTS /= (float)config.num_threads;
  }

  /*   TODO don't spawn threads if f_start >= in_file_sz
    Not doing it now, as it has implications for num_threads,
    which is used in calculating stats */

  /*   TODO use PGROUNDUP instead of round_up()
    #define PGROUNDUP(sz) (((sz)+PGSIZE−1) & ~(PGSIZE−1))
    #define PGROUNDDOWN(a) (((a)) & ~(PGSIZE−1)) */

  if (config.num_threads >
      static_cast<uint32_t>(this->n->get_num_total_cpus()) - 1) {
    fprintf(stderr,
            "[ERROR] More threads configured than cores available (Note: one "
            "cpu assigned completely for synchronization) \n");
    exit(-1);
  }

  uint32_t i = 0;
  for (uint32_t assigned_cpu : this->np->get_assigned_cpu_list()) {
    Shard *sh = &this->shards[i];
    sh->shard_idx = i;
    sh->f_start = round_up(seg_sz * sh->shard_idx, PAGE_SIZE);
    sh->f_end = round_up(seg_sz * (sh->shard_idx + 1), PAGE_SIZE);
    this->threads[i] = std::thread(&Application::shard_thread, this, i);
    CPU_ZERO(&cpuset);
    CPU_SET(assigned_cpu, &cpuset);
    pthread_setaffinity_np(this->threads[i].native_handle(), sizeof(cpu_set_t),
                           &cpuset);
    printf("[INFO] Thread %u: affinity: %u\n", sh->shard_idx, assigned_cpu);
    i += 1;
  }

  /* pin this thread to last cpu of last node. */
  /* TODO don't waste one thread on synchronization  */
  CPU_ZERO(&cpuset);
  uint32_t last_cpu = this->np->get_unassigned_cpu_list()[0];
  CPU_SET(last_cpu, &cpuset);
  sched_setaffinity(0, sizeof(cpu_set_t), &cpuset);
  printf("[INFO] Thread 'main': affinity: %u\n", last_cpu);

  while (ready_threads < config.num_threads) {
    fipc_test_pause();
  }

  // fipc_test_mfence();
#if !defined(WITH_PAPI_LIB)
  ready = 1;
#endif

  /* TODO thread join vs sync on atomic variable*/
  while (ready_threads) fipc_test_pause();

  for (auto t = 0u; t < config.num_threads; t++) {
    if (this->threads[t].joinable()) {
      this->threads[t].join();
    }
  }

  print_stats(this->shards, config);

  delete[] threads;
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
        "\n8/9: Bqueue tests: with bqueues/without bequeues"
        "\n12/13/14/15/16: Lock tests:"
        "\n    Spinlock\n    Atomic\n    CAS"
        "\n    Uncontended lock\n    Uncontended CAS"
        "\n    Uncontended increment")(
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
        "num_nops",
        po::value<uint32_t>(&config.num_nops)->default_value(def.num_nops),
        "number of nops in bqueue cons thread")(
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
    if (config.numa_split)
      this->npq = new NumaPolicyQueues(config.n_prod, config.n_cons,
                                       PROD_CONS_SEPARATE_NODES);
    else
      this->npq = new NumaPolicyQueues(config.n_prod, config.n_cons,
                                       PROD_CONS_SEQUENTIAL);
  } else {
    if (config.numa_split)
      this->np = new NumaPolicyThreads(config.num_threads,
                                       THREADS_SPLIT_SEPARATE_NODES);
    else
      this->np =
          new NumaPolicyThreads(config.num_threads, THREADS_ASSIGN_SEQUENTIAL);
  }

  if (config.mode == BQ_TESTS_YES_BQ) {
    this->test.bqt.run_test(&config, this->n, this->npq);
  } else if (config.mode == LOCK_TEST_SPINLOCK) {
    this->test.lt.spinlock_increment_test_run(config);
  } else if (config.mode == LOCK_TEST_ATOMIC_INC) {
    this->test.lt.atomic_increment_test_run(config);
  } else if (config.mode == LOCK_TEST_CAS_INC) {
    this->test.lt.cas_increment_test_run(config);
  } else if (config.mode == LOCK_TEST_UNCONTENDED_INC) {
    this->test.lt.uncontended_increment_test_run(config);
  } else if (config.mode == LOCK_TEST_UNCONTENDED_LOCK) {
    this->test.lt.uncontended_lock_test_run(config);
  } else if (config.mode == LOCK_TEST_UNCONTENDED_CAS) {
    this->test.lt.uncontended_cas_test_run(config);
  } else {
    this->spawn_shard_threads();
  }

  return 0;
}
}  // namespace kmercounter
