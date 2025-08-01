




# 07/28

revisitng the equation: 
T = SIZE / TIME 
T = (#lfb * cacheline_size) / LFB_LATENCY  *  num_cores = (16 * 64) / latency * 32 * ((10^9) / (1<<30))  
=  XGB/s


250 GB/s is measure by vtune and mlc for max single socket bandwidth. 
that suggests latency to retire 1 lfb slot is 122 ns. 


LFB_LATENCY is not the same as DRAM Latency



I just run a simple random prefetch loop with 8gb 10% with XORWOW. ( also run it on 50%, similar performance). 
                 
32 threads:  18 cycle/op
64 threads:  36 cycle/op

each op would be 1 prefetch.
both saturate memory bw, 250 GB/s

so LFB must be

# 07/24


In dramhit, at hig17h fill, with dual socket

final performance for get = reprobe + contention + base memory. 

Simple prefetch loop:

No getfill:

8gb 
10%: 59
70%: 67


Counter are collected by vtune (1 sample per 10ms), a snapshot comparison. 

F:  I   : A   : S 
10% 2.7 : 2   : 0.7
70% 1.1 : 0.5 : 3.2
----------------- No warm up 

F:  I   : A   : S 
10% 1.8 : 1.2 : 2.0
70% 0.9 : 0.3 : 3.5
-----------------  warm up 


getfill:

8gb 
10%: 68
70%: 69


Cache per socket:

1.5 MB + 64 MB + 60 MB = 125.5 MB

Cache total:
251 MB 

8GB * 10% = 0.8 GB = 819 MB
8GB * 70% = 5.6 GB

# 07/23


In the Xeon Scalable Processor, the in-memory directory has three states: I, A, and S. I (invalid) state
means the data is clean and does not exist in any other socket’s cache. The A (snoopAll) state
means the data may exist in another socket in an exclusive or modified state. S (Shared) state
means the data is clean and may be shared across one or more socket's caches.
When doing a read to memory, if the directory line is in the A state, we must snoop all the other
sockets because another socket may have the line in modified state. If this is the case, the snoop
will return the modified data. However, it may be the case that a line is read in A state and all the
snoops come back a miss. This can happen if another socket reads the line earlier and then silently
dropped it from its cache without modifying it. If the [Stale AtoS] feature is [Enabled], in the
situation where a line in A state returns only snoop misses, the line will transition to S state. That
way, subsequent reads to the line will encounter it in S state and not have to snoop, saving latency
and snoop bandwidth. [Stale AtoS] may be beneficial in a workload where there are many crosssocket reads.


Mem state | Action 
    I     | allocate a piece of memory on socket 0.  
    I     | local thread prefetch mem 
    A     | remote socket prefetch mem  
    I     | local thread prefetch mem <- we want S here.
    A     | remote socket prefetch mem  
    I     | local thread prefetch mem 


whenenver mem state changes, write back needs to happen.
clflush will gurantee to change mem state from A back to I.



# july 17

run at 10%

dual theoritical get = (local + remote)/2 = (47+85)/2 = 66

single socket local = { set_cycles : 107, get_cycles : 47, upsert_cycles : 106, set_mops : 1495.327, get_mops : 3404.255, upsert_mops : 1509.434 }

single socket remote = { set_cycles : 157, get_cycles : 85, upsert_cycles : 158, set_mops : 1019.108, get_mops : 1882.353, upsert_mops : 1012.658 } 

1882 * 64 = 120 GB/s matches mlc remote memory bandwidth. under vtune, upi is saturated.

dual socket = { set_cycles : 140, get_cycles : 71, upsert_cycles : 141, set_mops : 2285.714, get_mops : 4507.042, upsert_mops : 2269.504 }

run at 70%

dual theoritical get = (101+58)/2 = 80 

single socket local = { set_cycles : 119, get_cycles : 58, upsert_cycles : 117, set_mops : 1344.538, get_mops : 2711.864, upsert_mops : 1367.521 }
single socket remote = { set_cycles : 177, get_cycles : 101, upsert_cycles : 171, set_mops : 903.955, get_mops : 1584.158, upsert_mops : 935.673 }
dual socket = { set_cycles : 162, get_cycles : 96, upsert_cycles : 163, set_mops : 1975.309, get_mops : 3333.333, upsert_mops : 1963.190 }  

8G 70% (no reprobe)

(49+84)/2=66

single local: { set_cycles : 119, get_cycles : 49, upsert_cycles : 117, set_mops : 1344.538, get_mops : 3265.306, upsert_mops : 1367.521 }
single remote: { set_cycles : 178, get_cycles : 84, upsert_cycles : 173, set_mops : 898.876, get_mops : 1904.762, upsert_mops : 924.855 }
dual: { set_cycles : 162, get_cycles : 82, upsert_cycles : 163, set_mops : 1975.309, get_mops : 3902.439, upsert_mops : 1963.190 } 

8g,  

generate workload base skew 0.01, 70% * 8gb 
each thread, 70% *8gb / thread 

60.5 in theory for dual. 
single local: 43
single remote: 78
dual: 78

8g f10% * 8gb prefetch loop skew 0.01
single local: 43
single remote: 77
dual: 62

x   y
x -> 
1/10 
_ _ X_ _ _ _ _ _ _ _ 

70%

8g 70% prefetch loop skew 0.01 64 threads
dual: 41

8g 10% prefetch loop skew 0.01 64 threads
dual: 33

8g 50% prefetch loop skew 0.01
dual: 76

4g 100% prefetch loop skew 0.01
dual: 74


8g 70% prefetch loop skew 1.0 (0.45 fill factor)

dual: 56 

how can 45% fill factor be faster than 10%? 

does it happen on single socket? 


70% f 1.0 skew: single-local 32 <- num_op = 
10% f 0.01 skew: single-local 43



8g prefetch loop xorwow at 70%

single local: 36
single remote: 76
dual: 87

we need a experiemnt that explores prefetch on same address from two 
different socket and see latency/throughput.

8g prefetch loop xorwow at 10%
dual: 51

we think that at higher fill factor, more cacheline are shared between socket, thus making memory access much more expensive. 
increasing skewness of the data.

skewness 1.0 

(39+60)/2 = 50
single socket local = { set_cycles : 238, get_cycles : 39, upsert_cycles : 185, set_mops : 672.269, get_mops : 4102.564, upsert_mops : 864.865 }
single socket remote = { set_cycles : 236, get_cycles : 60, upsert_cycles : 184, set_mops : 677.966, get_mops : 2666.667, upsert_mops : 869.565 }
dual socket = { set_cycles : 552, get_cycles : 52, upsert_cycles : 478, set_mops : 579.710, get_mops : 6153.846, upsert_mops : 669.456 }

so not related. 



# july 15


remote 128

{ set_cycles : 129, get_cycles : 62, upsert_cycles : 129, set_mops : 2480.620, get_mops : 5161.290, upsert_mops : 2480.620 }



# jun 26


simple prefetch loop on 8gb 70%, 64 threads.

prefetchtz2

OFFCORE_REQUESTS_OUTSTANDING.CYCLES_WITH_DATA_RD:36.8098:2.16148e+08
CYCLE_ACTIVITY.CYCLES_MEM_ANY:8.52183:5.00404e+07
L1D_PEND_MISS.FB_FULL:33.1189:1.94475e+08
cycles:36.8563:2.16421e+08
MEM_LOAD_RETIRED.L1_MISS:0.000200783:1179


prefetchtz1

OFFCORE_REQUESTS_OUTSTANDING.CYCLES_WITH_DATA_RD:36.7524:2.15811e+08
CYCLE_ACTIVITY.CYCLES_MEM_ANY:8.5242:5.00543e+07
L1D_PEND_MISS.FB_FULL:33.0624:1.94143e+08
cycles:36.8032:2.16109e+08
MEM_LOAD_RETIRED.L1_MISS:0.000219005:1286

prefetchtz0

OFFCORE_REQUESTS_OUTSTANDING.CYCLES_WITH_DATA_RD:40.6283:2.38571e+08
CYCLE_ACTIVITY.CYCLES_MEM_ANY:10.0995:5.93044e+07
L1D_PEND_MISS.FB_FULL:35.8317:2.10404e+08
cycles:40.7527:2.39301e+08
MEM_LOAD_RETIRED.L1_MISS:0.000435284:2556


prefetchnta


prefetchw






# jun 24

8gb 128 threads, two numa node, queue sz 32

baseline no prefetch store, 155 cycles per op
prefetch2z -> prefetch0z -> store, 155 cycles per op
prefetch2z -> prefetchwz -> store, 141 cycles per op
prefetch2z -> store, 141 cycles per op

baseline no prefetch cas, 214 cycles per op
prefetch2z -> prefetch0z -> cas, 141 cycles per op
prefetch2z -> prefetchwz -> cas, 141 cycles per op
prefetch2z -> cas, 140 cycles per op

queue sz 64 prefetch2z -> prefetchwz -> cas, 141 cycles per op
queue sz 128 prefetch2z -> prefetchwz -> cas, 140 cycles per op


# jun 23


8gb table, 64 threads, single numa node: 

prefetchw -> store, 102 cycles per op 
prefetch2z -> store, 96 cycles per op. 
prefetchnta -> store, 105 cycles per op. 
prefetch0z -> store, 97 cycles per op. 

prefetch2z -> prefetchw, 64 threads, 39 cycles per op
prefetch2z -> prefetchw -> store, 64 threads, 99 cycles per op
prefetch2z -> prefetchw -> load, 64 threads, 39 cycles per op
prefetch2z -> prefetchw -> cas, 64 threads, 98 cycles per op

prefetch2z -> prefetch0z, 64 threads, 39 cycles per op
prefetch2z -> prefetch0z -> store, 64 threads, 99 cycles per op
prefetch2z -> prefetch0z -> load, 64 threads, 39 cycles per op
prefetch2z -> prefetch0z -> cas, 64 threads, 98 cycles per op

queue_sz 32, prefetch2z -> store, 98 cycles per op. 
queue_sz 64, prefetch2z -> store, 99 cycles per op. 
queue_sz 128, prefetch2z -> store, 98 cycles per op. 



----- 

| size | threads | fill | cpo  | mops | bandwidth | probing |
| ---- | ------  | ---- | ---- | ---- | --------- | ------- |
|  2G  | 56      | 10%  | 35   | 3360 | 196 GB/s  | linear  |
|  2G  | 56      | 70%  | 51   | 2305 | 191 GB/s  | linear  |
|  2G  | 56      | 10%  | 36   | 3266 | 181 GB/s  | uniform |
|  2G  | 56      | 70%  | 45   | 2613 | 178 GB/s  | uniform |



8gb 10% linear 
{ set_cycles : 157, get_cycles : 77, set_mops : 2038.217, get_mops : 4155.844 }

8gb 70% linear
{ set_cycles : 174, get_cycles : 92, set_mops : 1839.080, get_mops : 3478.261 }



-- 4/16/25 -- 


Articial test with more accurate representation of actual workload: 

cycles: 31.6477
CYCLE_ACTIVITY.CYCLES_MEM_ANY: 21.0894
CYCLE_ACTIVITY.CYCLES_L1D_MISS: 8.494
L1D.REPLACEMENT: 0.128532
MEM_LOAD_RETIRED.FB_HIT: 0.185956
MEM_LOAD_RETIRED.L1_HIT: 8.25812
MEM_LOAD_RETIRED.L1_MISS: 0.000630315
MEM_LOAD_RETIRED.L2_HIT: 0.00016706
MEM_LOAD_RETIRED.L2_MISS: 0.000434716
MEM_LOAD_RETIRED.L3_HIT: 0.00013752
MEM_LOAD_RETIRED.L3_MISS: 0.000244457
instructions: 39.776
CYCLE_ACTIVITY.STALLS_L1D_MISS: 6.61418
CYCLE_ACTIVITY.STALLS_L2_MISS: 0.0664822
CYCLE_ACTIVITY.STALLS_L3_MISS: 0.05001
CYCLE_ACTIVITY.STALLS_TOTAL: 18.2312
MEMORY_ACTIVITY.STALLS_L1D_MISS: 6.60548
MEMORY_ACTIVITY.STALLS_L2_MISS: 6.60453
MEMORY_ACTIVITY.STALLS_L3_MISS: 5.06298
INST_RETIRED.STALL_CYCLES: 26.733




Artificial test: 

large hashtable
randomly prefetch.
split means per core, 1thread prefetch l1, 1thread prefetch to l2.

|cache level | prefetch value | 56 threads | 28 threads | 56 threads split | 
|l2          | 1              | 30         | 16         | 27               |
|l1          | 3              | 33         | 19         | 33               |

--- 4/14/25 --
# L2 pref, dram test, vars lifed out:
{ set_cycles : 84, get_cycles : 30, set_mops : 1400.000, get_mops : 3920.000 }
Thread ID: 0 Sample counts: 239674000
cycles:30.9619:7.42075e+09
CYCLE_ACTIVITY.CYCLES_MEM_ANY:20.2836:4.86144e+09
CYCLE_ACTIVITY.CYCLES_L1D_MISS:10.0908:2.41851e+09
instructions:32.3287:7.74834e+09
# vars in for loop:
{ set_cycles : 84, get_cycles : 30, set_mops : 1400.000, get_mops : 3920.000 }
Thread ID: 0 Sample counts: 239674000
cycles:30.9586:7.41998e+09
CYCLE_ACTIVITY.CYCLES_MEM_ANY:20.256:4.85484e+09
CYCLE_ACTIVITY.CYCLES_L1D_MISS:10.0688:2.41322e+09
instructions:32.3271:7.74795e+09



# L1 non-virtual dram bandwidth, lifted out
{ set_cycles : 84, get_cycles : 33, set_mops : 1400.000, get_mops : 3563.636 }

Thread ID: 0 Sample counts: 239674000
cycles:33.3089:7.98328e+09
CYCLE_ACTIVITY.CYCLES_MEM_ANY:11.9725:2.86949e+09
CYCLE_ACTIVITY.CYCLES_L1D_MISS:2.35076:5.63416e+08
instructions:28.0161:6.71472e+09

# 56-thread large, dram bandwidth test, vars lifted out:
Thread ID: 0 Sample counts: 239674000
cycles:33.5878:8.05013e+09
CYCLE_ACTIVITY.CYCLES_MEM_ANY:15.2708:3.66002e+09
CYCLE_ACTIVITY.CYCLES_L1D_MISS:1.79108:4.29276e+08
instructions:32.3302:7.7487e+09
CYCLE_ACTIVITY.STALLS_TOTAL:21.9911:5.27069e+09
CYCLE_ACTIVITY.STALLS_L1D_MISS:1.37954:3.30641e+08
CYCLE_ACTIVITY.STALLS_L2_MISS:0.0489019:1.17205e+07
CYCLE_ACTIVITY.STALLS_L3_MISS:0.041023:9.83216e+06

# counters
cycles
CYCLE_ACTIVITY.CYCLES_MEM_ANY
CYCLE_ACTIVITY.CYCLES_L1D_MISS
instructions

CYCLE_ACTIVITY.STALLS_TOTAL
CYCLE_ACTIVITY.STALLS_L1D_MISS
CYCLE_ACTIVITY.STALLS_L2_MISS
CYCLE_ACTIVITY.STALLS_L3_MISS

# 56-thread large, no virtual
Thread ID: 0 Sample counts: 
cycles:34.6503:8.30477e+09
CYCLE_ACTIVITY.CYCLES_MEM_ANY:31.4284:7.53257e+09
CYCLE_ACTIVITY.CYCLES_L1D_MISS:3.08608:7.39653e+08
instructions:76.084:1.82353e+10
CYCLE_ACTIVITY.STALLS_TOTAL:8.12251:1.94675e+09
CYCLE_ACTIVITY.STALLS_L1D_MISS:2.01876:4.83844e+08
CYCLE_ACTIVITY.STALLS_L2_MISS:0.0575608:1.37958e+07
CYCLE_ACTIVITY.STALLS_L3_MISS:0.044647:1.07007e+07



Do we stall on prefetch on 27 threads ? 

----- Apr 09 2025 ----


# 56 threads max bandwidth usage:

Thread ID: 0 Sample counts: 239674000

cycles:30.1726:7.23159e+09
CYCLE_ACTIVITY.CYCLES_MEM_ANY:19.4786:4.66852e+09
CYCLE_ACTIVITY.CYCLES_L1D_MISS:9.63884:2.31018e+09
instructions:32.1399:7.70311e+09
CYCLE_ACTIVITY.STALLS_TOTAL:18.9254:4.53592e+09
CYCLE_ACTIVITY.STALLS_L1D_MISS:7.36739:1.76577e+09
CYCLE_ACTIVITY.STALLS_L2_MISS:0.0482402:1.15619e+07
CYCLE_ACTIVITY.STALLS_L3_MISS:0.0386563:9.26492e+06
MEMORY_ACTIVITY.CYCLES_L1D_MISS:9.47035:2.2698e+09
MEMORY_ACTIVITY.STALLS_L1D_MISS:7.54711:1.80885e+09
MEMORY_ACTIVITY.STALLS_L2_MISS:7.54635:1.80866e+09
MEMORY_ACTIVITY.STALLS_L3_MISS:5.55343:1.33101e+09


# 56 threads: 

Thread ID: 0 Sample counts: 239673985

cycles:35.1437:8.42303e+09
CYCLE_ACTIVITY.CYCLES_MEM_ANY:32.1354:7.70202e+09
CYCLE_ACTIVITY.CYCLES_L1D_MISS:2.77589:6.6531e+08 

instructions:77.8974:1.867e+10
CYCLE_ACTIVITY.STALLS_TOTAL:7.89796:1.89294e+09
CYCLE_ACTIVITY.STALLS_L1D_MISS:1.84391:4.41937e+08  // compute stall 6 
CYCLE_ACTIVITY.STALLS_L2_MISS:0.0635058:1.52207e+07
CYCLE_ACTIVITY.STALLS_L3_MISS:0.0488662:1.1712e+07

MEMORY_ACTIVITY.CYCLES_L1D_MISS:2.82421:6.76889e+08
MEMORY_ACTIVITY.STALLS_L1D_MISS:1.86787:4.4768e+08
MEMORY_ACTIVITY.STALLS_L2_MISS:1.78222:4.27152e+08
MEMORY_ACTIVITY.STALLS_L3_MISS:1.27205:3.04876e+08

IDQ_UOPS_NOT_DELIVERED.CORE:3.50643:8.404e+08
IDQ_UOPS_NOT_DELIVERED.CYCLES_0_UOPS_DELIV_CORE:0.311061:7.45532e+07


# 56 threads no l1 prefetch

Thread ID: 0 Sample counts: 239673985

cycles:35.8317:8.58793e+09
CYCLE_ACTIVITY.CYCLES_MEM_ANY:35.1782:8.43129e+09
CYCLE_ACTIVITY.CYCLES_L1D_MISS:9.132:2.1887e+09

instructions:73.1472:1.75315e+10
CYCLE_ACTIVITY.STALLS_TOTAL:9.03661:2.16584e+09
CYCLE_ACTIVITY.STALLS_L1D_MISS:3.16538:7.58659e+08 // compute stall 6
CYCLE_ACTIVITY.STALLS_L2_MISS:0.819026:1.96299e+08
CYCLE_ACTIVITY.STALLS_L3_MISS:0.764624:1.8326e+08

MEMORY_ACTIVITY.CYCLES_L1D_MISS:9.21801:2.20932e+09
MEMORY_ACTIVITY.STALLS_L1D_MISS:3.31061:7.93467e+08
MEMORY_ACTIVITY.STALLS_L2_MISS:1.44886:3.47254e+08
MEMORY_ACTIVITY.STALLS_L3_MISS:1.08601:2.60289e+08

IDQ_UOPS_NOT_DELIVERED.CORE:4.56724:1.09465e+09
IDQ_UOPS_NOT_DELIVERED.CYCLES_0_UOPS_DELIV_CORE:0.447611:1.07281e+08

27 threads.
Thread ID: 0 Sample counts: 497100985

cycles:22.8879:1.13776e+10
CYCLE_ACTIVITY.CYCLES_MEM_ANY:21.8815:1.08773e+10
CYCLE_ACTIVITY.CYCLES_L1D_MISS:3.1192:1.55056e+09

instructions:77.8927:3.87206e+10
CYCLE_ACTIVITY.STALLS_TOTAL:4.18986:2.08279e+09
CYCLE_ACTIVITY.STALLS_L1D_MISS:1.88017:9.34634e+08 // compute stall ~2.5
CYCLE_ACTIVITY.STALLS_L2_MISS:0.189119:9.40112e+07
CYCLE_ACTIVITY.STALLS_L3_MISS:0.0249615:1.24084e+07

MEMORY_ACTIVITY.CYCLES_L1D_MISS:3.11515:1.54854e+09
MEMORY_ACTIVITY.STALLS_L1D_MISS:1.86812:9.28646e+08
MEMORY_ACTIVITY.STALLS_L2_MISS:1.73532:8.62628e+08
MEMORY_ACTIVITY.STALLS_L3_MISS:1.32:6.56174e+08

IDQ_UOPS_NOT_DELIVERED.CORE:19.1788:9.53381e+09
IDQ_UOPS_NOT_DELIVERED.CYCLES_0_UOPS_DELIV_CORE:1.98081:9.84663e+08




---- Apr 08 2025 ----

56* means no l1 prefetch
all units are billions
| Threads | Cycles | L1 Miss Cycles | Instructions | Execution Stalls | L1D Stall | L2 Stall | L3 Miss Stall | % Cycles on Mem | % Instr Stalled | % Stalls Mem | % Stalls L1 | % Stalls L2 | % Stalls L3 |
|---------|--------|----------------|--------------|------------------|-----------|----------|----------------|------------------|------------------|----------------|--------------|--------------|--------------|
| 56      | 350    | 26.8           | 719          | 78.4             | 16.1      | 15.9     | 9              | 7.7%             | 10.9%            | 20.5%         | 0.3%         | 12.6%        | 11.5%        |
| 27      | 215.4  | 23.2           | 719          | 31.2             | 12.8      | 11.1     | 9.2            | 10.8%            | 4.3%             | 41.0%         | 5.4%         | 6.1%         | 29.5%        |
| 56*     | 370    | 108.2          | 653          | 94.6             | 36        | 13       | 9              | 29.2%            | 14.5%            | 38.1%         | 24.3%        | 4.2%         | 9.5%         |



formula: 

percent of cycle cpu spends on servicing memory = l1 miss cycles / cycles
percent of instructions cpu stalled  = execution stalls / instructions
percent of stalls cpu due to memory =  l1 stall / execution stalls  
percent of stalls cpu due to l1 miss = (l1 stall - l2 stall) / execution stalls 
percent of stalls cpu due to l2 miss = (l2 stall - l3 stall) / execution stalls 
percent of stalls cpu due to l3 miss = l3 stall / execution stalls 
 

-------------------------

-------- March 31 2025 ------

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

