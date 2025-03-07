

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

1. Cost of prefetch due to limited LFB buffer. (roughly 10 cycles extra)
2. Since each cpu cache are under high contention, memory instructions associated with DRAMHiT itself such as logic of prefetch 
engine also increases due to potential misses (not sure why, cpu cache likely will keep find_queue in cache). 
3. More reprobes in total when we run large table ?

-----------------------

