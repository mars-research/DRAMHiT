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
#include "misc_lib.h"
#include "print_stats.h"
#include "types.hpp"

#if defined(WITH_PAPI_LIB) || defined(ENABLE_HIGH_LEVEL_PAPI)
#include <papi.h>
#endif

#ifdef WITH_PAPI_LIB
#include "PapiEvent.hpp"
#endif

#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

const char *ht_type_strings[] = {
    "", "PARTITIONED", "ROBINHOOD", "CAS", "", "STDMAP",
};

namespace kmercounter {
extern uint64_t HT_TESTS_HT_SIZE;
extern uint64_t HT_TESTS_NUM_INSERTS;

// default configuration
const Configuration def = {
    .kmer_create_data_base = 524288,
    .kmer_create_data_mult = 1,
    .kmer_create_data_uniq = 1048576,
    .kmer_files_dir = std::string("/local/devel/pools/million/39/"),
    .alphanum_kmers = true,
    .stats_file = std::string("stats.json"),
    .ht_file = std::string(""),
    .in_file = std::string("/local/devel/devel/datasets/turkey/myseq0.fa"),
    .in_file_sz = 0,
    .K = 20,
    .num_threads = 1,
    .mode = BQ_TESTS_YES_BQ,  // TODO enum
    .numa_split = 3,
    .ht_type = 1,
    .ht_fill = 75,
    .ht_size = HT_TESTS_HT_SIZE,
    .n_prod = 1,
    .n_cons = 1,
    .num_nops = 0,
    .skew = 1.0,
    .pread = 0.0,
    .drop_caches = true,
    .hwprefetchers = false,
};  // TODO enum

// global config
Configuration config;

// for synchronization of threads
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
  switch (config.ht_type) {
    case SIMPLE_KHT:
      kmer_ht = new PartitionedHashStore<KVType, ItemQueue>(sz, id);
      break;
    case ROBINHOOD_KHT:
      kmer_ht = new RobinhoodKmerHashTable(sz);
      break;
    case CAS_KHT:
      /* For the CAS Hash table, size is the same as
          size of one partitioned ht * number of threads */
      kmer_ht =
          new CASHashTable<KVType, ItemQueue>(sz);  // * config.num_threads);
      break;
    default:
      PLOG_ERROR.printf("STDMAP_KHT Not implemented");
      break;
  }
  return kmer_ht;
}

void free_ht(BaseHashTable *kmer_ht) {
  PLOG_INFO.printf("freeing hashtable");
  delete kmer_ht;
}

void read_prefetchers(MsrHandler &msr_ctrl) {
  // Dump hwprefetchers msr - Needs msr-safe driver
  // (use scripts/enable_msr_safe.sh)
  auto rdmsr_set = msr_ctrl.read_msr(0x1a4);
  printf("MSR 0x1a4 has: { ");
  for (const auto &e : rdmsr_set) printf("0x%lx ", e);
  printf("}\n");
}

void Application::shard_thread(int tid, bool mainthread) {
  Shard *sh = &this->shards[tid];
  BaseHashTable *kmer_ht = NULL;

  sh->stats.reset((thread_stats *)std::aligned_alloc(CACHE_LINE_SIZE,
                                                     sizeof(thread_stats)));

  switch (config.mode) {
    case FASTQ_WITH_INSERT:
      kmer_ht = init_ht(config.in_file_sz / config.num_threads, sh->shard_idx);
      break;
    case PREFETCH:
      // kmer_ht = new PartitionedHashStore<Prefetch_KV, PrefetchKV_Queue>(
      //    HT_TESTS_HT_SIZE, sh->shard_idx);
      break;

    case SYNTH:
    case ZIPFIAN:
    case RW_RATIO:
    case BQ_TESTS_NO_BQ:
      kmer_ht = init_ht(config.ht_size, sh->shard_idx);
      break;
    case FASTQ_NO_INSERT:
      break;
    case CACHE_MISS:
      kmer_ht = init_ht(HT_TESTS_HT_SIZE, sh->shard_idx);
      break;

    default:
      PLOGF.printf("No config mode specified! cannot run");
      return;
  }

#ifndef WITH_PAPI_LIB
  if (!mainthread) {
    fipc_test_FAI(ready_threads);
  }
#else
  fipc_test_FAI(ready_threads);
  auto retval = PAPI_thread_init((unsigned long (*)(void))(pthread_self));
  if (retval != PAPI_OK) {
    PLOGE.printf("PAPI Thread init failed");
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

  std::atomic_uint entered_threads{config.num_threads};
  if (mainthread) {
    while (ready_threads < (config.num_threads - 1)) {
      fipc_test_pause();
    }
#if !defined(WITH_PAPI_LIB)
    ready = 1;
#else
    // If papi is enabled, main thread has to wait as well until ready is
    // signalled. ready is signalled by the last enetering thread.
    while (!ready) fipc_test_pause();
#endif
  } else {
    while (!ready) fipc_test_pause();
  }

  // fipc_test_mfence();
  /* Begin insert loops */
  switch (config.mode) {
    case SYNTH:
      this->test.st.synth_run_exec(sh, kmer_ht);
      break;
    case PREFETCH:
      this->test.pt.prefetch_test_run_exec(sh, config, kmer_ht);
      break;
    case BQ_TESTS_NO_BQ:
      this->test.bqt.no_bqueues(sh, kmer_ht);
      break;
    case CACHE_MISS:
      this->test.cmt.cache_miss_run(sh, kmer_ht);
      break;
    case ZIPFIAN:
      this->test.zipf.run(sh, kmer_ht, config.skew, config.num_threads);
      break;

    case RW_RATIO:
      this->test.rw_ratio.run(*sh, *kmer_ht, HT_TESTS_NUM_INSERTS);

    default:
      break;
  }

  // Write to file
  if (!config.ht_file.empty()) {
    // for CAS hashtable, not every thread has to write to file
    if ((config.ht_type == CAS_KHT) && (sh->shard_idx > 0)) {
      goto done;
    }

    const auto outfile = config.ht_file + std::to_string(sh->shard_idx);
    PLOG_INFO.printf("Shard %u: Printing to file: %s", sh->shard_idx,
                     outfile.c_str());
    kmer_ht->print_to_file(outfile.c_str());
  }

  // free_ht(kmer_ht);

done:

#ifndef WITH_PAPI_LIB
  if (!mainthread) {
    fipc_test_FAD(ready_threads);
  }
#else
  fipc_test_FAD(ready_threads);
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

  this->shards.resize(config.num_threads);
  size_t seg_sz = 0;

  switch (config.mode) {
    case SYNTH:
    case ZIPFIAN:
    case PREFETCH:
    case RW_RATIO:
    case CACHE_MISS:
      break;

    default:
      config.in_file_sz = get_file_size(config.in_file.c_str());
      PLOG_INFO.printf("File size: %lu bytes", config.in_file_sz);
      seg_sz = config.in_file_sz / config.num_threads;
      if (seg_sz < 4096) {
        seg_sz = 4096;
      }

      break;
  }

  if (config.ht_type == CAS_KHT)
    HT_TESTS_NUM_INSERTS /= (float)config.num_threads;

  /*   TODO don't spawn threads if f_start >= in_file_sz
    Not doing it now, as it has implications for num_threads,
    which is used in calculating stats */

  /*   TODO use PGROUNDUP instead of round_up()
    #define PGROUNDUP(sz) (((sz)+PGSIZE−1) & ~(PGSIZE−1))
    #define PGROUNDDOWN(a) (((a)) & ~(PGSIZE−1)) */

  if (config.num_threads >
      static_cast<uint32_t>(this->n->get_num_total_cpus())) {
    PLOGE.printf(
        "More threads configured than cores available (Note: one "
        "cpu assigned completely for synchronization)");
    exit(-1);
  }

  uint32_t i = 0;
  for (uint32_t assigned_cpu : this->np->get_assigned_cpu_list()) {
    if (assigned_cpu == 0) continue;
    Shard *sh = &this->shards[i];
    sh->shard_idx = i;
    sh->core_id = assigned_cpu;
    sh->f_start = round_up(seg_sz * sh->shard_idx, PAGE_SIZE);
    sh->f_end = round_up(seg_sz * (sh->shard_idx + 1), PAGE_SIZE);
    auto _thread = std::thread{[this, i] { shard_thread(i, false); }};

    CPU_ZERO(&cpuset);
    CPU_SET(assigned_cpu, &cpuset);
    pthread_setaffinity_np(_thread.native_handle(), sizeof(cpu_set_t), &cpuset);
    PLOG_INFO.printf("Thread %u: affinity: %u", sh->shard_idx, assigned_cpu);
    this->threads.push_back(std::move(_thread));
    i += 1;
  }

  // Pin main application thread to cpu 0 and run our thread routine
  CPU_ZERO(&cpuset);
  CPU_SET(0, &cpuset);
  sched_setaffinity(0, sizeof(cpu_set_t), &cpuset);
  PLOG_INFO.printf("Thread 'main': affinity: %u", 0);

  PLOG_INFO.printf("Running master thread with id %d", i);
  {
    Shard *sh = &this->shards[i];
    sh->shard_idx = i;
    sh->core_id = 0;
    sh->f_start = round_up(seg_sz * sh->shard_idx, PAGE_SIZE);
    sh->f_end = round_up(seg_sz * (sh->shard_idx + 1), PAGE_SIZE);
    this->shard_thread(i, true);
  }

#if 0
  while (ready_threads < config.num_threads) {
    fipc_test_pause();
  }

#if !defined(WITH_PAPI_LIB)
  ready = 1;
#endif
#endif  // if 0

  /* TODO thread join vs sync on atomic variable*/
  while (ready_threads) fipc_test_pause();

  for (auto &th : this->threads) {
    if (th.joinable()) th.join();
  }

  if (config.mode != CACHE_MISS) print_stats(this->shards.data(), config);

  return 0;
}

// TODO: Move me @David
void papi_init() {
#if defined(WITH_PAPI_LIB) || defined(ENABLE_HIGH_LEVEL_PAPI)
  if (PAPI_library_init(PAPI_VER_CURRENT) != PAPI_VER_CURRENT) {
    PLOGE.printf("Library initialization error! ");
    exit(1);
  }

  PLOGI.printf("PAPI library initialized");
}
#endif
}  // namespace kmercounter

int Application::process(int argc, char *argv[]) {
  try {
    namespace po = boost::program_options;
    po::options_description desc("Program options");

    desc.add_options()("help", "produce help message")(
        "mode",
        po::value<uint32_t>((uint32_t *)&config.mode)->default_value(def.mode),
        "1: Dry run \n"
        // Huh? don't look at me. The numbers are not continuous for a reason.
        // We stripped the kmer related stuff.
        "6/7: Synth/Prefetch\n"
        "8/9: Bqueue tests: with bqueues/without bequeues (can be built with "
        "zipfian)\n"
        "10: Cache Miss test\n"
        "11: Zipfian non-bqueue test"
        "12: RW-Ratio benchmark")(
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
        po::value<uint32_t>(&config.numa_split)->default_value(def.numa_split),
        "Split spawning threads between numa nodes")(
        "stats",
        po::value<std::string>(&config.stats_file)
            ->default_value(def.stats_file),
        "Stats file name.")(
        "ht-type",
        po::value<uint32_t>(&config.ht_type)->default_value(def.ht_type),
        "1: SimpleKmerHashTable\n"
        "2: RobinhoodKmerHashTable,\n"
        "3: CASKmerHashTable\n"
        "4. StdmapKmerHashTable")(
        "out-file",
        po::value<std::string>(&config.ht_file)->default_value(def.ht_file),
        "Hashtable output file name.")(
        "in-file",
        po::value<std::string>(&config.in_file)->default_value(def.in_file),
        "Input fasta file")(
        "drop-caches",
        po::value<bool>(&config.drop_caches)->default_value(def.drop_caches),
        "drop page cache before run")(
        "v", po::bool_switch()->default_value(false), "enable verbose logging")(
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
        "adjust hashtable fill ratio [0-100]")(
        "ht-size",
        po::value<uint64_t>(&config.ht_size)->default_value(def.ht_size),
        "adjust hashtable fill ratio [0-100]")(
        "skew", po::value<double>(&config.skew)->default_value(def.skew),
        "Zipfian skewness")("hw-pref", po::value<bool>(&config.hwprefetchers)
                                           ->default_value(def.hwprefetchers))(
        "p-read", po::value<double>(&config.pread)->default_value(def.pread),
        "Read probability");

    papi_init();

    po::variables_map vm;
    po::store(po::parse_command_line(argc, argv, desc), vm);
    po::notify(vm);

    plog::get()->setMaxSeverity(plog::info);

    // Enable verbose logging
    if (vm["v"].as<bool>()) {
      plog::get()->setMaxSeverity(plog::verbose);
    }

    // Control hw prefetcher msr
    if (vm["hw-pref"].as<bool>()) {
      // XXX: 0x1a4 is prefetch control;
      // 0 - all enabled; f - all disabled
      this->msr_ctrl->write_msr(0x1a4, 0x0);
    } else {
      this->msr_ctrl->write_msr(0x1a4, 0xf);
    }

    PLOG_INFO << run_mode_strings.at(config.mode);
    switch (config.mode) {
      case RW_RATIO:
        PLOG_INFO << "With R/W = ";
        break;

      case DRY_RUN:
      case WRITE_TO_DISK:
        PLOG_INFO.printf(
            "base: %lu, mult: %u, uniq: %lu", config.kmer_create_data_base,
            config.kmer_create_data_mult, config.kmer_create_data_uniq);

        break;

      case FASTQ_WITH_INSERT:
      case FASTQ_NO_INSERT:
        if (config.in_file.empty()) {
          PLOG_ERROR.printf("Please provide input fasta file.");
          exit(-1);
        }

        break;

      default:
        break;
    }

    switch (config.ht_type) {
      case SIMPLE_KHT:
        PLOG_INFO.printf("Hashtable type : SimpleKmerHashTable");
        config.ht_size /= config.num_threads;
        break;

      case ROBINHOOD_KHT:
        PLOG_INFO.printf("Hashtable type : RobinhoodKmerHashTable");
        break;

      case CAS_KHT:
        PLOG_INFO.printf("Hashtable type : CASKmerHashTable");
        break;

      case STDMAP_KHT:
        PLOG_INFO.printf(
            "Hashtable type : StdmapKmerHashTable (NOT IMPLEMENTED)");
        PLOG_INFO.printf("Exiting ... ");
        exit(0);
        break;
    }

    if (config.ht_fill > 0 && config.ht_fill < 100) {
      HT_TESTS_NUM_INSERTS =
          static_cast<double>(config.ht_size) * config.ht_fill * 0.01;
    } else {
      PLOG_ERROR.printf("ht_fill should be in range [1, 99)");
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
    PLOG_INFO.printf("Dropping the page cache");
    if (system("sudo bash -c 'echo 3 > /proc/sys/vm/drop_caches'") < 0) {
      perror("drop caches");
    }
  }

  read_prefetchers(*this->msr_ctrl);
  config.dump_configuration();
  if (config.mode == BQ_TESTS_YES_BQ) {
    switch (config.numa_split) {
      case PROD_CONS_SEPARATE_NODES:
        this->npq = new NumaPolicyQueues(config.n_prod, config.n_cons,
                                         PROD_CONS_SEPARATE_NODES);
        break;
      case PROD_CONS_SEQUENTIAL:
        this->npq = new NumaPolicyQueues(config.n_prod, config.n_cons,
                                         PROD_CONS_SEQUENTIAL);
        break;
      case PROD_CONS_EQUAL_PARTITION:
        this->npq = new NumaPolicyQueues(config.n_prod, config.n_cons,
                                         PROD_CONS_EQUAL_PARTITION);
        break;
      default:
        break;
    }
  } else {
    if (config.numa_split)
      this->np = new NumaPolicyThreads(config.num_threads,
                                       THREADS_SPLIT_SEPARATE_NODES);
    else
      this->np =
          new NumaPolicyThreads(config.num_threads, THREADS_ASSIGN_SEQUENTIAL);
  }

  switch (config.mode) {
    case BQ_TESTS_YES_BQ:
#ifdef BQ_TESTS_RW_RATIO
      this->test.bqt.run_test(&config, this->n, this->npq);
#endif
      this->test.bqt_rw.run_test(&config, this->n, this->npq);
      break;

    default:
      this->spawn_shard_threads();
      break;
  }

  return 0;
}
}  // namespace kmercounter
