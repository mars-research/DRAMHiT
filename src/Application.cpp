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
#include <functional>

#include "./hashtables/cas_kht.hpp"
#include "./hashtables/simple_kht.hpp"
#include "./hashtables/array_kht.hpp"
#include "misc_lib.h"
#include "print_stats.h"
#include "tests/PrefetchTest.hpp"
#include "types.hpp"

#if defined(WITH_PAPI_LIB) || defined(ENABLE_HIGH_LEVEL_PAPI)
#include <papi.h>
#endif

#ifdef WITH_PAPI_LIB
#include "PapiEvent.hpp"
#include "mem_bw_papi.hpp"
#endif

#ifdef WITH_VTUNE_LIB
#include <ittnotify.h>
#endif

namespace kmercounter {

class LynxQueue;
extern uint64_t HT_TESTS_HT_SIZE;
extern uint64_t HT_TESTS_NUM_INSERTS;
extern const uint64_t max_possible_threads = 128;
extern std::array<uint64_t, max_possible_threads> zipf_gen_timings;
extern void init_zipfian_dist(double skew, int64_t seed);

//void sync_complete(void);

// default configuration
const Configuration def = {
    .kmer_create_data_base = 524288,
    .kmer_create_data_mult = 1,
    .kmer_create_data_uniq = 1048576,
    .kmer_files_dir = std::string("/local/devel/pools/million/39/"),
    .alphanum_kmers = true,
    .stats_file = std::string(""),
    .ht_file = std::string(""),
    .in_file = std::string("/local/devel/devel/datasets/turkey/myseq0.fa"),
    .in_file_sz = 0,
    .K = 20,
    .num_threads = 1,
    .mode = BQ_TESTS_YES_BQ,  // TODO enum
    .numa_split = 3,
    .ht_type = 0,
    .ht_fill = 75,
    .ht_size = HT_TESTS_HT_SIZE,
    .insert_factor = 1,
    .n_prod = 1,
    .n_cons = 1,
    .num_nops = 0,
    .skew = 1.0,
    .seed = std::chrono::system_clock::now().time_since_epoch().count(),
    .pread = 0.0,
    .drop_caches = true,
    .hwprefetchers = false,
    .no_prefetch = false,
    .run_both = false,
    .batch_len = HT_TESTS_BATCH_LENGTH,
    .materialize = false,
    .relation_r = "r.tbl",
    .relation_s = "s.tbl",
    .relation_r_size = 128000000,
    .relation_s_size = 128000000,
    .delimitor = "|",
    .rw_queues = false,
    .pollute_ratio = 0
};  // TODO enum

// for synchronization of threads
static uint64_t ready = 0;
static std::atomic_uint num_entered{};

#if defined(WITH_PAPI_LIB)
static MemoryBwCounters *bw_counters;
#endif
extern bool stop_sync;
extern bool zipfian_finds;
extern bool zipfian_inserts;

ExecPhase cur_phase = ExecPhase::none;

uint64_t g_insert_start, g_insert_end;
uint64_t g_find_start, g_find_end;

void sync_complete(void) {
#if defined(WITH_PAPI_LIB)
  if (stop_sync) {
    PLOGI.printf("Stopping counters");
    bw_counters->stop();
    bw_counters->compute_mem_bw();
    stop_sync = false;
  } else {
    PLOGI.printf("Starting counters");
    if (!bw_counters)
      bw_counters = new MemoryBwCounters(2);
    bw_counters->start();
  }
#endif
  if (cur_phase == ExecPhase::finds) {
    if (!zipfian_finds) {
      g_find_start = RDTSC_START();
      zipfian_finds = true;
    } else {
      g_find_end = RDTSCP();
      PLOGI.printf("Finds took %lu cycles", g_find_end - g_find_start);
    }
  } else if (cur_phase == ExecPhase::insertions) {
    if (!zipfian_inserts) {
      g_insert_start = RDTSC_START();
      zipfian_inserts = true;
    } else {
      g_insert_end = RDTSCP();
      PLOGI.printf("inserts took %lu cycles", g_insert_end - g_insert_start);
    }
  }
  PLOGI.printf("Sync phase done!");
}

BaseHashTable *init_ht(const uint64_t sz, uint8_t id) {
  BaseHashTable *kmer_ht = NULL;

  // Create hash table
  switch (config.ht_type) {
    case PARTITIONED_HT:
      kmer_ht = new PartitionedHashStore<KVType, ItemQueue>(sz, id);
      break;
    case CASHTPP:
      /* For the CAS Hash table, size is the same as
          size of one partitioned ht * number of threads */
      kmer_ht =
          new CASHashTable<KVType, ItemQueue>(sz);  // * config.num_threads);
      break;
    case ARRAY_HT:
      kmer_ht =
          new ArrayHashTable<Value, ItemQueue>(sz);
      break;
    default:
      PLOG_FATAL.printf("HT type not implemented");
      exit(-1);
      break;
  }
  return kmer_ht;
}

void free_ht(BaseHashTable *kmer_ht) {
  PLOG_INFO.printf("freeing hashtable");
  delete kmer_ht;
}

void Application::shard_thread(int tid, std::barrier<std::function<void()>>* barrier) {
  Shard *sh = &this->shards[tid];
  BaseHashTable *kmer_ht = NULL;

  sh->stats =
      (thread_stats *)std::aligned_alloc(CACHE_LINE_SIZE, sizeof(thread_stats));

  switch (config.mode) {
    case FASTQ_WITH_INSERT:
      kmer_ht = init_ht(config.ht_size, sh->shard_idx);
      break;
    case FASTQ_WITH_INSERT_RADIX:
      break;
    case PREFETCH:
      // kmer_ht = new PartitionedHashStore<Prefetch_KV, PrefetchKV_Queue>(
      //    HT_TESTS_HT_SIZE, sh->shard_idx);
      break;
    case SYNTH:
    case RW_RATIO:
    case ZIPFIAN:
    case HASHJOIN:
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

  num_entered++;

#ifdef WITH_PAPI_LIB
  auto retval = PAPI_thread_init((unsigned long (*)(void))(pthread_self));
  if (retval != PAPI_OK) {
    PLOGE.printf("PAPI Thread init failed");
  }
#endif

  while (num_entered != config.num_threads) _mm_pause();

  switch (config.mode) {
    case SYNTH:
      this->test.st.synth_run_exec(sh, kmer_ht);
      break;
    case PREFETCH:
      this->test.pt.prefetch_test_run_exec(sh, config, kmer_ht);
      break;
    case CACHE_MISS:
      this->test.cmt.cache_miss_run(sh, kmer_ht);
      break;
    case ZIPFIAN:
      this->test.zipf.run(sh, kmer_ht, config.skew, config.seed, config.num_threads, barrier);
      break;
    case RW_RATIO:
      PLOG_INFO << "Inserting " << HT_TESTS_NUM_INSERTS << " pairs per thread";
      this->test.rw.run(*sh, *kmer_ht, HT_TESTS_NUM_INSERTS, barrier);
      break;
    case HASHJOIN:
      this->test.hj.join_relations_generated(sh, config, kmer_ht, config.materialize, barrier);
      break;
    case FASTQ_WITH_INSERT_RADIX:
      this->test.kmer.count_kmer_radix(sh, config, barrier, 
              this->radixContext);
      break;
    case FASTQ_WITH_INSERT:
      this->test.kmer.count_kmer(sh, config, kmer_ht, barrier);
      break;
    default:
      break;
  }

  // Write to file
  if (!config.ht_file.empty()) {
    // for CAS hashtable, not every thread has to write to file
    if (config.ht_type == CASHTPP && (sh->shard_idx > 0)) {
      goto done;
    }
    std::string outfile = config.ht_file + std::to_string(sh->shard_idx);
    PLOG_INFO.printf("Shard %u: Printing to file: %s", sh->shard_idx,
                     outfile.c_str());
    kmer_ht->print_to_file(outfile);
  }

  // free_ht(kmer_ht);

done:
  --num_entered;
  return;
}

int Application::spawn_shard_threads() {
  cpu_set_t cpuset;

  PLOG_INFO.printf("kosustartNumber of shards: %u", config.num_threads);
  this->shards = (Shard *)std::aligned_alloc(
      CACHE_LINE_SIZE, sizeof(Shard) * config.num_threads);

  memset(this->shards, 0, sizeof(Shard) * config.num_threads);

  size_t seg_sz = 0;

  if ((config.mode != SYNTH) && (config.mode != ZIPFIAN) &&
      (config.mode != PREFETCH) && (config.mode != CACHE_MISS) &&
      (config.mode != RW_RATIO) && (config.mode != HASHJOIN)) {
    config.in_file_sz = get_file_size(config.in_file.c_str());
    PLOG_INFO.printf("File size: %" PRIu64 " bytes", config.in_file_sz);
    seg_sz = config.in_file_sz / config.num_threads;
    if (seg_sz < 4096) {
      seg_sz = 4096;
    }
  }

  // split the num inserts equally among threads for a
  // non-partitioned hashtable
  if (config.ht_type == CASHTPP) {
    auto orig_num_inserts = HT_TESTS_NUM_INSERTS;
    HT_TESTS_NUM_INSERTS /= (double)config.num_threads;
    PLOGV.printf("Total inserts %" PRIu64 " | num_threads %u | scaled inserts per thread %" PRIu64 "",
          orig_num_inserts, config.num_threads, HT_TESTS_NUM_INSERTS);
  }

  if (config.insert_factor > 1) {
    PLOGI.printf("Insert factor %" PRIu64 ", Effective num insertions %" PRIu64 "", config.insert_factor,
        HT_TESTS_NUM_INSERTS * config.insert_factor);
  }

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

  std::function<void()> on_completion = []() noexcept {
    // For debugging
    // PLOG_INFO << "Phase completed.";
  };

  std::function<void()> on_sync_complete = sync_complete;

  std::barrier barrier(config.num_threads, on_sync_complete);
  uint32_t i = 0;
  for (uint32_t assigned_cpu : this->np->get_assigned_cpu_list()) {
    if (assigned_cpu == 0) continue;
    Shard *sh = &this->shards[i];
    sh->shard_idx = i;
    sh->f_start = round_up(seg_sz * sh->shard_idx, PAGE_SIZE);
    sh->f_end = round_up(seg_sz * (sh->shard_idx + 1), PAGE_SIZE);
    auto _thread = std::thread(&Application::shard_thread, this, i, &barrier);
    CPU_ZERO(&cpuset);
    CPU_SET(assigned_cpu, &cpuset);
    pthread_setaffinity_np(_thread.native_handle(), sizeof(cpu_set_t), &cpuset);
    PLOGV.printf("Thread %u: affinity: %u", sh->shard_idx, assigned_cpu);
    this->threads.push_back(std::move(_thread));
    i += 1;
  }
  
  PLOG_INFO.printf("kos i:%u", i);
  // Pin main application thread to cpu 0 and run our thread routine
  CPU_ZERO(&cpuset);
  CPU_SET(0, &cpuset);
  sched_setaffinity(0, sizeof(cpu_set_t), &cpuset);
  PLOGV.printf("Thread 'main': affinity: %u", 0);

  PLOGV.printf("Running master thread with id %d", i);
  {
    Shard *sh = &this->shards[i];
    sh->shard_idx = i;
    sh->f_start = round_up(seg_sz * sh->shard_idx, PAGE_SIZE);
    sh->f_end = round_up(seg_sz * (sh->shard_idx + 1), PAGE_SIZE);
    this->shard_thread(i, &barrier);
  }

  for (auto &th : this->threads) {
    if (th.joinable()) {
      th.join();
    }
  }
  if ((config.mode != CACHE_MISS) && (config.mode != HASHJOIN)) {
    print_stats(this->shards, config);
  }

  std::free(this->shards);

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
#endif
}

int Application::process(int argc, char *argv[]) {
  try {
    namespace po = boost::program_options;
    po::options_description desc("Program options");

    desc.add_options()("help", "produce help message")(
        "mode",
        po::value<uint32_t>((uint32_t *)&config.mode)->default_value(def.mode),
        "1: Dry run \n"
        "2: Read from disk (Saved HT?)\n"
        "3: write to disk (Save KMER HT to disk?)\n"
        "4: Fastq with insert (for kmer test)\n"
        "5: Fastq without insert (you don't want this)\n"
        "6/7: Synth/Prefetch\n"
        "8/9: Bqueue tests: with bqueues/without bequeues (can be built with "
        "zipfian)\n"
        "10: Cache Miss test\n"
        "11: Zipfian non-bqueue test\n"
        "12: RW-ratio test\n"
        "13: Hashjoin")(
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
        "Number of threads")("insert-factor",
                             po::value<uint64_t>(&config.insert_factor)
                                 ->default_value(def.insert_factor),
                             "Insert X times the size of hashtable")(
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
        "1: Partitioned HT\n"
        "3: Casht++\n"
        "4: Arrayht\n")(
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
        "adjust hashtable fill ratio [0-100] ")(
        "ht-size",
        po::value<uint64_t>(&config.ht_size)->default_value(def.ht_size),
        "adjust hashtable fill ratio [0-100] ")(
        "skew", po::value<double>(&config.skew)->default_value(def.skew),
        "Zipfian skewness")(
        "seed", po::value<int64_t>(&config.seed)->default_value(def.seed),
        "Zipfian distribution generation seed")(
        "hw-pref", po::value<bool>(&config.hwprefetchers)->default_value(def.hwprefetchers))(
        "no-prefetch",
        po::value<bool>(&config.no_prefetch)->default_value(def.no_prefetch))(
        "run-both",
        po::value<bool>(&config.run_both)->default_value(def.run_both))(
        "batch-len",
        po::value<uint32_t>(&config.batch_len)->default_value(def.batch_len))(
        "p-read",
        po::value<double>(&config.pread)->default_value(def.pread))
        ("materialize",
        po::value<bool>(&config.materialize)->default_value(def.materialize),
        "Materialize the hashjoin output")
        ("relation_r",
        po::value(&config.relation_r)->default_value(def.relation_r), "Path to relation R.")
        ("relation_s",
        po::value(&config.relation_s)->default_value(def.relation_s), "Path to relation S.")
        ("relation_r_size",
        po::value(&config.relation_r_size)->default_value(def.relation_r_size), "Number of elements in relation R. Only used when the relations are generated.")
        ("relation_s_size",
        po::value(&config.relation_s_size)->default_value(def.relation_s_size), "Number of elements in relation S. Only used when the relations are generated.")
        ("delimitor",
        po::value(&config.delimitor)->default_value(def.delimitor), "CSV delimitor for relation files.")(
          "rw-queues",
          po::value<bool>(&config.rw_queues)->default_value(def.rw_queues),
          "Enable R/W tests for queues tests"
        )("pollute-ratio", po::value(&config.pollute_ratio)->default_value(def.pollute_ratio), "Ratio of pollution events to ops (>1)");

    papi_init();

    po::variables_map vm;
    po::store(po::parse_command_line(argc, argv, desc), vm);
    po::notify(vm);

    plog::get()->setMaxSeverity(plog::info);

    if (vm.count("help")) {
      cout << desc << "\n";
      return 1;
    }

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

    if (config.mode == SYNTH) {
      PLOG_INFO.printf("Mode : SYNTH");
    } else if (config.mode == PREFETCH) {
      PLOG_INFO.printf("Mode : PREFETCH");
    } else if (config.mode == DRY_RUN) {
      PLOG_INFO.printf("Mode : Dry run ...");
      PLOG_INFO.printf(
          "base: %" PRIu64 ", mult: %u, uniq: %" PRIu64 "", config.kmer_create_data_base,
          config.kmer_create_data_mult, config.kmer_create_data_uniq);
    } else if (config.mode == READ_FROM_DISK) {
      PLOG_INFO.printf("Mode : Reading kmers from disk ...");
    } else if (config.mode == WRITE_TO_DISK) {
      PLOG_INFO.printf("Mode : Writing kmers to disk ...");
      PLOG_INFO.printf(
          "base: %" PRIu64 ", mult: %u, uniq: %" PRIu64 "", config.kmer_create_data_base,
          config.kmer_create_data_mult, config.kmer_create_data_uniq);
    } else if (config.mode == FASTQ_WITH_INSERT) {
      PLOG_INFO.printf("Mode : FASTQ_WITH_INSERT");
      if (config.in_file.empty()) {
        PLOG_ERROR.printf("Please provide input fasta file.");
        exit(-1);
      }
    } else if (config.mode == FASTQ_WITH_INSERT_RADIX) {
      PLOG_INFO.printf("Mode : FASTQ_WITH_INSERT_RADIX");
      auto nthreads = config.num_threads;
      uint32_t d = 0;
      while ((1 << (1 + d)) <= nthreads) {
          d++;
      }
      this->radixContext = RadixContext(d, 0, nthreads); 
      
      PLOG_INFO.printf("Mode : FASTQ_WITH_INSERT_RADIX D:%u, fanout: %u, multiplier: %u, nthreads_d: %u", 
              d, 
              this->radixContext.fanOut, 
              this->radixContext.multiplier, 
              this->radixContext.nthreads_d);
      if (config.in_file.empty()) {
        PLOG_ERROR.printf("Please provide input fasta file.");
        exit(-1);
      }
    } else if (config.mode == FASTQ_NO_INSERT) {
      PLOG_INFO.printf("Mode : FASTQ_NO_INSERT");
      if (config.in_file.empty()) {
        PLOG_ERROR.printf("Please provide input fasta file.");
        exit(-1);
      }
    } else if (config.mode == HASHJOIN) {
      // In our hashjoin tests, we always have equisize R and S tables, but
      // that need not be the case
      std::uint64_t max_join_size = config.relation_r_size;

      // We need a hashtable that is 75% full. So, increase the size of the HT
      if (config.ht_type == ARRAY_HT) {
        config.ht_size = max_join_size;
      } else {
        //config.ht_size = static_cast<double>(max_join_size) * 100 / config.ht_fill;
      }
      PLOGI.printf("Setting ht size to %llu for hashjoin test", config.ht_size);
    }

    switch (config.ht_type) {
      case PARTITIONED_HT:
        PLOG_INFO.printf("Hashtable type : Paritioned HT");
        config.ht_size /= config.num_threads;
        break;
      case CASHTPP:
        PLOG_INFO.printf("Hashtable type : Cas HT");
        break;
      case ARRAY_HT:
        PLOG_INFO.printf("Hashtable type : Array HT");
        break;
      default:
        PLOGE.printf("Unknown HT type %u! Specify using --ht-type",
                     config.ht_type);
        PLOG_INFO.printf("Exiting");
        exit(0);
    }

    if (config.ht_fill > 0 && config.ht_fill < 200) {
      HT_TESTS_NUM_INSERTS =
          static_cast<double>(config.ht_size) * config.ht_fill * 0.01;
    } else {
      PLOG_ERROR.printf("ht_fill should be in range [1, 99)");
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

  // Dump hwprefetchers msr - Needs msr-safe driver
  // (use scripts/enable_msr_safe.sh)
  auto rdmsr_set = this->msr_ctrl->read_msr(0x1a4);
  printf("MSR 0x1a4 has: { ");
  for (const auto &e : rdmsr_set) {
    printf("0x%lx ", e);
  }
  printf("}\n");

  config.dump_configuration();

  if ((config.mode == BQ_TESTS_YES_BQ) || (config.mode == FASTQ_WITH_INSERT) || (config.mode == FASTQ_WITH_INSERT_RADIX)) {
    bq_load = BQUEUE_LOAD::HtInsert;
  }

  if ((config.mode == BQ_TESTS_YES_BQ) || ((config.mode == FASTQ_WITH_INSERT || (config.mode == FASTQ_WITH_INSERT_RADIX)) && (config.ht_type == PARTITIONED_HT))) {
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
    switch (config.numa_split) {
      case THREADS_SPLIT_SEPARATE_NODES:
        this->np = new NumaPolicyThreads(config.num_threads,
                                         THREADS_SPLIT_SEPARATE_NODES);
        break;
      case THREADS_ASSIGN_SEQUENTIAL:
        this->np = new NumaPolicyThreads(config.num_threads,
                                         THREADS_ASSIGN_SEQUENTIAL);
        break;
      default:
        PLOGE.printf("Unknown numa policy. Exiting");
        exit(-1);
    }
  }

  if (config.mode == BQ_TESTS_YES_BQ || config.mode == ZIPFIAN || config.mode == RW_RATIO) {
    init_zipfian_dist(config.skew, config.seed);
  }

  if ((config.mode == HASHJOIN) || (config.mode == FASTQ_WITH_INSERT) || (config.mode == FASTQ_WITH_INSERT_RADIX)) {
    // for hashjoin, ht-type determines how we spawn threads
    if (config.ht_type == PARTITIONED_HT) {
      this->test.qt.run_test(&config, this->n, true, this->npq);
    } else if ((config.ht_type == CASHTPP) || (config.ht_type == ARRAY_HT)) {
      this->spawn_shard_threads();
    }
  } else if (config.mode == BQ_TESTS_YES_BQ) {
    this->test.qt.run_test(&config, this->n, false, this->npq);
  } else {
    this->spawn_shard_threads();
  }

  // If we start to run casht, reset the num_inserts and no_prefetch
  // to run cashtpp
  if (config.run_both) {
    PLOGI.printf("Running cashtpp now with the same configuration");
    if ((config.ht_type == CASHTPP) && config.no_prefetch &&
        (config.mode == ZIPFIAN)) {
      HT_TESTS_NUM_INSERTS = config.ht_size * config.ht_fill * 0.01;

      config.no_prefetch = 0;

      this->spawn_shard_threads();
    }
  }
  return 0;
}
}  // namespace kmercounter
