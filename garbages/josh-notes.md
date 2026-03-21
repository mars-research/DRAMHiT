# 2025
/opt/DRAMHiT/build/dramhit --perf_cnt_path ./perf_cnt.txt --perf_def_path ./perf-cpp/perf_list.csv --find_queue 64 --ht-fill 90 --ht-type 3 --insert-factor 1 --read-factor 1 --num-threads 64 --numa-split 4 --no-prefetch 0 --mode 11 --ht-size 268435456 --skew 1.1 --hw-pref 0 --batch-len 16
2025-09-19 08:30:40.288 INFO  [1581693] [initializeLogger@17] ------------------------
2025-09-19 08:30:40.288 INFO  [1581693] [initializeLogger@18] Plog library initialized
2025-09-19 08:30:40.288 INFO  [1581693] [initializeLogger@19] ------------------------
2025-09-19 08:30:40.288 INFO  [1581693] [main@27] Starting dramhit
2025-09-19 08:30:40.289 INFO  [1581693] [MsrHandler::msr_open@46] msr-safe loaded!
2025-09-19 08:30:40.290 INFO  [1581693] [kmercounter::Application::process@762] Hashtable type : Cas HT
2025-09-19 08:30:40.290 INFO  [1581693] [kmercounter::Application::process@803] Dropping the page cache
2025-09-19 08:30:41.224 INFO  [1581693] [kmercounter::init_zipfian_dist@76] HT_TESTS_NUM_INSERTS 241591910
2025-09-19 08:30:41.225 INFO  [1581693] [kmercounter::init_zipfian_dist@81] /opt/zipfian/1.1_268435456_90.bin 0
2025-09-19 08:30:41.225 INFO  [1581693] [kmercounter::init_zipfian_dist@88] Initializing global zipf with skew 1.100000, seed 1758292239999718991
2025-09-19 08:30:56.480 INFO  [1581693] [kmercounter::init_zipfian_dist@93] Zipfian dist generated. size 241591910
Assinging (64) cpus: 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70, 72, 74, 76, 78, 80, 82, 84, 86, 88, 90, 92, 94, 96, 98, 100, 102, 104, 106, 108, 110, 112, 114, 116, 118, 120, 122, 124, 126
Run configuration {
  num_threads 64
  numa_split 4
  mode 11 - ZIPFIAN
  ht_type 3 - CASHT++
  ht_size 268435456 (4 GiB)
  K 20
  P(read) 0.000000
  Pollution Ratio 0
BQUEUES:
  n_prod 1 | n_cons 1
  ht_fill 90
ZIPFIAN:
  skew: 1.100000
  seed: 1758292239999718991
  HW prefetchers disabled
  SW prefetch engine enabled
  Run both disabled
  batch length 16
  relation_r r.tbl
  relation_s r.tbl
  relation_r_size 128000000
  relation_s_size 128000000
  delimitor |
  perf cnt path ./perf_cnt.txt
  perf def path ./perf-cpp/perf_list.csv
}
2025-09-19 08:30:57.759 INFO  [1581693] [kmercounter::Application::spawn_shard_threads@404] total kv 241591910, num_threads 64, op per thread (per run) 3774873
2025-09-19 08:30:57.759 INFO  [1581814] [kmercounter::calloc_ht@133] requesting to mmap 4294967296 bytes
2025-09-19 08:30:57.759 INFO  [1581814] [kmercounter::calloc_ht@141] mmap returns 0x7aa340000000
2025-09-19 08:30:57.759 INFO  [1581814] [kmercounter::distribute_mem_to_nodes@65] addr 0x7aa340000000, alloc_sz 4294967296 | all_nodes 3
2025-09-19 08:30:59.195 INFO  [1581814] [KVQ>::CASHashTable@82] Hashtable base: 0x7aa340000000 Hashtable size: 268435456
2025-09-19 08:30:59.195 INFO  [1581814] [KVQ>::CASHashTable@84] queue item sz: 24
2025-09-19 08:31:00.392 INFO  [1581814] [kmercounter::sync_complete@218] insert duration 2717829376
2025-09-19 08:31:00.974 INFO  [1581858] [kmercounter::sync_complete@201] find duration 169455798
2025-09-19 08:31:00.974 INFO  [1581814] [kmercounter::ZipfianTest::run@392] get fill 0.182
2025-09-19 08:31:01.264 INFO  [1581814] [kmercounter::free_mem@161] Entering!
{total_reprobes : 160821, total_finds : 241591872, avg_cachelines_accessed : 1.0007}
{reprobe_factor : 1.0007}
===============================================================
average_insert_task_duration : 2717829376, total_insert_tas_duration : 2717829376
insert_ops : 241591872, insert_ops_per_run : 241591872
average_find_task_duration : 169455798, total_find_duration : 169455798
find_ops : 241591872, find_ops_per_run : 241591872
{ set_cycles : 719, get_cycles : 44, set_mops : 222.229, get_mops : 3564.231 }
===============================================================
100x
{ set_cycles : 704, get_cycles : 44, set_mops : 227.199, get_mops : 3589.626 }

# 2023
/opt/DRAMHiT/build/dramhit --perf_cnt_path ./perf_cnt.txt --perf_def_path ./perf-cpp/perf_list.csv --find_queue 64 --ht-fill 90 --ht-type 3 --insert-factor 1 --read-factor 1 --num-threads 64 --numa-split 4 --no-prefetch 0 --mode 11 --ht-size 268435456 --skew 1.1 --hw-pref 0 --batch-len 16
2025-09-19 08:34:07.565 INFO  [1583496] [initializeLogger@17] ------------------------
2025-09-19 08:34:07.565 INFO  [1583496] [initializeLogger@18] Plog library initialized
2025-09-19 08:34:07.565 INFO  [1583496] [initializeLogger@19] ------------------------
2025-09-19 08:34:07.565 INFO  [1583496] [main@27] Starting dramhit
2025-09-19 08:34:07.566 INFO  [1583496] [MsrHandler::msr_open@46] msr-safe loaded!
2025-09-19 08:34:07.567 INFO  [1583496] [kmercounter::Application::process@762] Hashtable type : Cas HT
2025-09-19 08:34:07.567 INFO  [1583496] [kmercounter::Application::process@803] Dropping the page cache
2025-09-19 08:34:08.948 INFO  [1583496] [kmercounter::init_zipfian_dist@76] HT_TESTS_NUM_INSERTS 241591910
2025-09-19 08:34:08.949 INFO  [1583496] [kmercounter::init_zipfian_dist@81] /opt/zipfian/1.1_268435456_90.bin 1
Assinging (64) cpus: 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48, 50, 52, 54, 56, 58, 60, 62, 64, 66, 68, 70, 72, 74, 76, 78, 80, 82, 84, 86, 88, 90, 92, 94, 96, 98, 100, 102, 104, 106, 108, 110, 112, 114, 116, 118, 120, 122, 124, 126
Run configuration {
  num_threads 64
  numa_split 4
  mode 11 - ZIPFIAN
  ht_type 3 - CASHT++
  ht_size 268435456 (4 GiB)
  K 20
  P(read) 0.000000
  Pollution Ratio 0
BQUEUES:
  n_prod 1 | n_cons 1
  ht_fill 90
ZIPFIAN:
  skew: 1.100000
  seed: 1758292447281210137
  HW prefetchers disabled
  SW prefetch engine enabled
  Run both disabled
  batch length 16
  relation_r r.tbl
  relation_s r.tbl
  relation_r_size 128000000
  relation_s_size 128000000
  delimitor |
  perf cnt path ./perf_cnt.txt
  perf def path ./perf-cpp/perf_list.csv
}
2025-09-19 08:34:10.052 INFO  [1583496] [kmercounter::Application::spawn_shard_threads@404] total kv 241591910, num_threads 64, op per thread (per run) 3774873
2025-09-19 08:34:10.052 INFO  [1583551] [kmercounter::calloc_ht@133] requesting to mmap 4294967296 bytes
2025-09-19 08:34:10.052 INFO  [1583551] [kmercounter::calloc_ht@141] mmap returns 0x7f78c0000000
2025-09-19 08:34:10.052 INFO  [1583551] [kmercounter::distribute_mem_to_nodes@65] addr 0x7f78c0000000, alloc_sz 4294967296 | all_nodes 3
2025-09-19 08:34:11.489 INFO  [1583551] [KVQ>::CASHashTable@82] Hashtable base: 0x7f78c0000000 Hashtable size: 268435456
2025-09-19 08:34:11.489 INFO  [1583551] [KVQ>::CASHashTable@84] queue item sz: 24
2025-09-19 08:34:12.643 INFO  [1583595] [kmercounter::sync_complete@218] insert duration 2591287614
2025-09-19 08:34:13.230 INFO  [1583603] [kmercounter::sync_complete@201] find duration 178599428
2025-09-19 08:34:13.230 INFO  [1583551] [kmercounter::ZipfianTest::run@392] get fill 0.182
2025-09-19 08:34:13.522 INFO  [1583551] [kmercounter::free_mem@161] Entering!
{total_reprobes : 160885, total_finds : 241591872, avg_cachelines_accessed : 1.0007}
{reprobe_factor : 1.0007}
===============================================================
average_insert_task_duration : 2591287614, total_insert_tas_duration : 2591287614
insert_ops : 241591872, insert_ops_per_run : 241591872
average_find_task_duration : 178599428, total_find_duration : 178599428
find_ops : 241591872, find_ops_per_run : 241591872
{ set_cycles : 686, get_cycles : 47, set_mops : 233.081, get_mops : 3381.756 }
===============================================================
100x
{ set_cycles : 686, get_cycles : 46, set_mops : 233.193, get_mops : 3446.692 }