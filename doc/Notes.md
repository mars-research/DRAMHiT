

--- Apr 08 2025 ----

56* means no l1 prefetch
all units are billions
| threads | cycles | l1 miss cycles | instructions | execution stalls | l1d stall | l2 stall | l3 miss stall| 
| 56  | 350   | 26.8  | 719 | 78.4 | 16.1 | 15.9 | 9 |
| 27  | 218.8 | 25.2  | 717 | 33.8 | 14.4 | 12.3 | 10 |
| 56* | 370   | 108.2 | 653 | 94.6 | 36   | 13   | 9 |


formula: 

percent of cycle cpu spends on servicing memory = l1 miss cycles / cycles
percent of instructions cpu stalled  = execution stalls / instructions
percent of stalls cpu due to memory =  l1 stall / execution stalls  
percent of stalls cpu due to l1 miss = (l1 stall - l2 stall) / execution stalls 
percent of stalls cpu due to l2 miss = (l2 stall - l3 stall) / execution stalls 
percent of stalls cpu due to l3 miss = l3 stall / execution stalls 
 
in 56 threads: 

7.4% total cpu cycles are spend servicing l1 misses
10.9 % instructions are stalled 
20.5 % stalls are due to memory

in 27 threads:

11.5% cpu cycles are spend servicing l1 misses
4.7% instructions are stalled
42.6% stalls are due to memory


small 1 thread 
------- PERFCPP ------- 

Thread ID: 0 Sample counts: 163799985
BR_MISP_RETIRED.ALL_BRANCHES:0.00119316
BR_MISP_RETIRED.INDIRECT:2.32234e-05
BR_MISP_RETIRED.COND:0.00116917

-----------------------

------- PERFCPP ------- 

Thread ID: 0 Sample counts: 2899985
BR_MISP_RETIRED.ALL_BRANCHES:0.00144173 
BR_MISP_RETIRED.INDIRECT:0.000105863
BR_MISP_RETIRED.COND:0.00130346

----------------------- 


------- - March 31 2025 ------

small: 256 KB
large: 2 GB
fill factor: 10%

Table: manually inlined find_batch
cycle per operation for get.
|       | 1 thread  | 56 threads | 
| small |     21    |     31     |   
| large |     23    |     38     |

Table: regular find_batch, no optimization
cycle per operation for get.
|       | 1 thread  | 56 threads | 
| small |     25    |     37     |   
| large |     26    |     42     |

Table: find_batch simply returns (do zero work).
This is purely measuring the outer benchmark loop.
cycle per operation for get.
|       | 1 thread  | 56 threads | 
| small |     5     |     8      |   
| large |     9     |     9      |

--------- unknown ----------- 

Number of insertions per sec (Mops/s): 76.364
print_stats, num_threads 2
Number of finds per sec (Mops/s): 113.514
{ set_cycles : 55, get_cycles : 37, set_mops : 76.364, get_mops : 113.514 }

Number of insertions per sec (Mops/s): 56.757
print_stats, num_threads 1
Number of finds per sec (Mops/s): 84.000
{ set_cycles : 37, get_cycles : 25, set_mops : 56.757, get_mops : 84.000 }

--- March 17 2025 ---

Comparing cache-sized ht with 4gb ht at 56, 28, & 1 threads

> 4GiB HT, 10% fill
print_stats, num_threads 56
{ set_cycles : 90, get_cycles : 43, set_mops : 1306.667, get_mops : 2734.884 }
print_stats, num_threads 28
{ set_cycles : 51, get_cycles : 28, set_mops : 1152.941, get_mops : 2100.000 }
print_stats, num_threads 1
{ set_cycles : 45, get_cycles : 26, set_mops : 46.667, get_mops : 80.769 }

> L1 (32KiB) HT, 10% fill 
print_stats, num_threads 56
{ set_cycles : 94, get_cycles : 44, set_mops : 1251.064, get_mops : 2672.727 }
print_stats, num_threads 28
{ set_cycles : 65, get_cycles : 27, set_mops : 904.615, get_mops : 2177.778 }
print_stats, num_threads 1
{ set_cycles : 37, get_cycles : 25, set_mops : 56.757, get_mops : 84.000 }

---- March 14 25  -----
Notes:
- With find batch modified to do 0 work, we still lose 5-6 cyles on 1024ht size with 28vs56 threads, which we believe is instr cache contention
- With prefetch commented out and find_one commented out, on 2048ht we observe 28vs56 threads on vtune, 56th still some L1d misses, some internal data structure may be getting evicted

----- March 13 25 -----

tests: 4gb 10%fill (aligned queue) 
removing fluff from ht_test:
{ set_cycles : 89, get_cycles : 41, set_mops : 1321.348, get_mops : 2868.293 }
L1+L2 prefetch + prefetch tail variable:
{ set_cycles : 90, get_cycles : 43, set_mops : 1306.667, get_mops : 2734.884 }
L1+L2 prefetch:
{ set_cycles : 90, get_cycles : 44, set_mops : 1306.667, get_mops : 2672.727 }
L2:
{ set_cycles : 91, get_cycles : 45, set_mops : 1292.308, get_mops : 2613.333 }
L1:
{ set_cycles : 91, get_cycles : 47, set_mops : 1292.308, get_mops : 2502.128 }

Observation:
We observe that get_cycles increases when using hyperthreading, ie 31 cycles for 28th and 51 cycles for 56th. This happens on both
4gb hashtable and cache-sized(4096) hashtable. 

----- March 05 25 -----

Observation: 

    An 10 percent filled with 32kB size hashtable with linear probing revealing cost of a single find ops 25 cycles. (all in cache)
    At 90%, about 56 cycles, about 2.24X cost maching roughly 2X reprobe factor also, matches performance data at 4G in 02-24.txt. 

Command: 

    sudo ./build/dramhit --ht-fill 10 --insert-factor 100000 --num-threads 1 --ht-type 3 --numa-split 1 --no-prefetch 0 --mode 11 --ht-size 2048 --skew 0.01 --hw-pref 0 --batch-len 16 --find_queue_sz 8

Observation:

    At different bandwidth, latency of a load request changes. 

    At idle 0 bandwidth usage, latency is 98 ns per load, with 2.1GHZ, we have 2.1 * 98 = 205 cycles. 
    At ~180 GB/s, latency is 134 ns per load, we have 2.1 * 134 = 281 cycles.

    With this increased latency, we need definitely perform more operations for memory to be prefetched.

    Still though, this increase in latency still doesn't fully explain why such dramatical increases in 
    batch size of 8 to 16 to see lower vmov cpi. Either cpu can magically get through queues in faster
    manner (potentially due to speculation), or there are some other hidden factor of increasing memory
    latency.

Command:  

    sudo ./tools/mlc/mlc --loaded_latency -h -Z -d120


Observation:

    25 cycles -> 50 cycles per op when running HT size 32kB to 4GB
    An addition 25 cycles overhead. 

Hypothesis:

1. Cost of prefetch due to limited LFB buffer. (roughly 10 cycles extra), [eliminated with L1+L2 combined prefetching]
2. Since each cpu cache are under high contention, memory instructions associated with DRAMHiT itself such as logic of prefetch 
engine also increases due to potential misses (not sure why, cpu cache likely will keep find_queue in cache). 
1. More reprobes in total when we run large table ?

-----------------------

