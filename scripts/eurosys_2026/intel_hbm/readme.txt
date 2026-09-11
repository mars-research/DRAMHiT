
Dual socket:
 ./build/bandwidth_rand -m 128mb -pattern "n0a2,3t64 n1a2,3t64" -freq 2.7 -inst t1 -lookahead 64 -mode r
 Bandwidth       : 207.72 GB/s

Single socket:

 ./build/bandwidth_rand -m 128mb -pattern "n0a2t64" -freq 2.7 -inst t1 -lookahead 64 -mode r
Bandwidth       : 348.24 GB/s

facts:

1. hbm bandwidth test.
using different prefetch inst results in different memory bandwidth.
- t0 350gb/s
- t1 400gb/s

2. prefetchT1 stalls cpu if continously issued at 16.

for fact 2, explanation is prefetcht1 allocate lfb, and stalls, then
by lfb model math and the above fact, you can only increase
throughput if we increase lfb size or reduce memory latency.

if lfb size have increased due to prefetchT1, then how are we wil bottlneck at some higher number for prefetchT1.
so the only explanation is that prefetchT1 reduces latency by 30 cycles. This is
a little too high....

3. hyperthreading increases bandwidth

If we believe hyperthreads does not increase lfb size, then why does it increase system bandwidth.

l1d_pend_miss.fb_full
l1d.replacement
l1d_pend_miss.pending
l1d_pend_miss.pending_cycles
  l1d.replacement
       [Counts the number of cache lines replaced in L1 data cache]
  l1d_pend_miss.fb_full
       [Number of cycles a demand request has waited due to L1D Fill Buffer (FB) unavailability]
  l1d_pend_miss.fb_full_periods
       [Number of phases a demand request has waited due to L1D Fill Buffer (FB) unavailability]
  l1d_pend_miss.l2_stalls
       [Number of cycles a demand request has waited due to L1D due to lack of L2 resources]
  l1d_pend_miss.pending
       [Number of L1D misses that are outstanding]
  l1d_pend_miss.pending_cycles
       [Cycles with L1D load Misses outstanding]
  l2_rqsts.all_demand_miss
       [Demand requests that miss L2 cache]
  l2_rqsts.all_demand_references
       [Demand requests to L2 cache]
  l2_rqsts.swpf_hit
       [SW prefetch requests that hit L2 cache]
  l2_rqsts.swpf_miss
       [SW prefetch requests that miss L2 cache]
  mem_load_retired.l1_hit
       [Retired load instructions with L1 cache hits as data sources Supports address when precise (Precise event)]
  mem_load_retired.l1_miss
       [Retired load instructions missed L1 cache as data sources Supports address when precise (Precise event)]
  mem_load_retired.l2_hit
       [Retired load instructions with L2 cache hits as data sources Supports address when precise (Precise event)]
  mem_load_retired.l2_miss
       [Retired load instructions missed L2 cache as data sources Supports address when precise (Precise event)]
  sw_prefetch_access.t0
       [Number of PREFETCHT0 instructions executed]
  sw_prefetch_access.t1_t2
       [Number of PREFETCHT1 or PREFETCHT2 instructions executed]



Configuration: Binding, Random

PrefetchT1
prefetch test.
single thread:
./prefetch_test_rand_bind 3 100000000 1 2
  Cycles/Op:    16.79
hyperthread:
./prefetch_test_rand_bind 3 100000000 2 2
  Cycles/Op:    22.48

Throughput test:
No hyperthreading:
./benchmark_rand -m 128m -pattern "n0a2t32" -inst t0
    Average cycle per operation: 18.27 cycles/op
    Predicted peak banwidth: 364.22 GB/s
With hyperthreading:
./benchmark_rand -m 128m -pattern "n0a2t64" -inst t1
    Average cycle per operation: 28.59 cycles/op
    peak banwidth: 465.64 GB/s


PrefetchT0
prefetch test
single thread:
./prefetch_test_rand_bind 2 100000000 1 2
  Cycles/Op:    16.72
hyperthread:
./prefetch_test_rand_bind 2 100000000 2 2
  Cycles/Op:    27.00

Throughput test

No Hyperthreading:
./benchmark_rand -m 128m -pattern "n0a2t32" -inst t0
    Average cycle per operation: 18.55 cycles/op
    Predicted peak banwidth: 358.76 GB/s
With hyperthreading:
./benchmark_rand -m 128m -pattern "n0a2t64" -inst t0
    Average cycle per operation: 33.65 cycles/op
    Predicted peak banwidth: 395.58 GB/s


Whole-machine radix join (all cpus, thread-local HBM)
-----------------------------------------------------
./run_allcpu_radix.sh          # nohup-friendly, sweeps skew + relation_size, redraws both graphs
  -> intel_hbm_allcpu_radix_skew.json / intel_hbm_allcpu_radix_relation_size.json
  -> overlaid on intel_hbm_single_skew.png and intel_hbm_single_relation_size.png

128 threads over both sockets (--np_cpu_node_msk 3) instead of 64 on node 0.
Memory is NOT one shared mask: --np_mem_local 1 makes every radix-join thread
bind its own arena -- partition buckets and the join hashtable -- to the
cpu-less (HBM) node closest to its own cpu node, so node 0 cpus allocate from
node 2 and node 1 cpus from node 3. Interleaving over {2,3} instead would put
half of every thread's table across the interconnect.

dramhit verifies this per thread rather than trusting mbind: after the arena
is faulted in it reads back the node of the hashtable's first and last page
and logs "hashtable local: ... on numa node N" (or "hashtable NOT local"), and
logs where the unbound r/s relation arena landed too. run_single_join.py
echoes the summary after each run. Every run of this sweep reported 64 threads
on node 2 + 64 on node 3, 0 non-local, with the relations on nodes 0/1.

skew (r=1gb, s=15gb): 5178 Mops at 0.1 vs 3484 for the 64-thread single-socket
run; the two curves cross around skew 1.1 and meet at 1.2 (1634 vs 1614) --
past that point skew, not memory bandwidth, is what bounds the radix join.
relation size (r=s): 3299 / 3463 / 3284 / 2672 Mops at 1/2/4/8 gb.


Tuning the cas prefetches (build-time)
--------------------------------------
-DPREFETCH=<DOUBLE|L1|L2|L3|NTA|NONE>  drives the cas *find* path, and the
insert path too unless overridden.
-DCAS_PREFETCH_INSERTION=<AUTO|DOUBLE|PREFETCHW|NONE>  drives the cas *insert*
path on its own:
  DOUBLE     prefetcht1 when the entry is queued + prefetchw when it is
             dequeued (two prefetches per insert)
  PREFETCHW  one prefetchw, issued when the entry is queued
  NONE       no software prefetch on the insert path
  AUTO       (default) follow PREFETCH: DOUBLE -> DOUBLE, NONE -> NONE,
             anything else -> PREFETCHW. Every pre-existing -DPREFETCH= command
             line therefore builds exactly what it used to.
Values are upper-case only, and cmake prints the resolved choice as
"-- cas insert-path prefetch: ...". Verify a build with:
  nm build/dramhit | grep " T _ZN11kmercounter12CASHashTableINS_4ItemENS_9ItemQueueEE12insert_batch"
  objdump -d build/dramhit | awk -v s="<SYM>:" 'index($0,s){f=1;next} f&&/^$/{exit} f' | grep -c prefetch

Phase comparison at one point (R = S = 8 gb, single socket, skew 0.1 and 1.0):
  python3 compare_prefetch_phases.py                      # sweeps PREFETCH
  python3 compare_prefetch_phases.py --prefetch-builds \
      --insert-builds DOUBLE PREFETCHW NONE               # sweeps the insert knob
It reports each join's two phases (hash: build/probe, radix: partition/join) as
cycles per tuple of R+S, the denominator both joins share, and runs radix under
every build as a control -- radix issues no software prefetches, so its spread
is the run-to-run noise floor.

cas, R = S = 8 gb, single socket (cycles/tuple normalised to R+S):
  build       skew 0.1                      skew 1.0
  DOUBLE      2790 Mops, build 38.5 probe 23.0   2774 Mops, build 42.0 probe 19.5
  L1          2692 Mops, build 40.5 probe 23.0   2885 Mops, build 41.0 probe 18.5
  NONE         942 Mops, build 126.5 probe 56.5  1092 Mops, build 126.5 probe 31.5
  radix ctl   1631 / 1642 Mops (DOUBLE/L1)       1583 / 1604 Mops (DOUBLE/L1)
The second prefetch (DOUBLE vs L1) is worth -3.5% at skew 0.1 and +4% at skew
1.0 -- it flips sign, against a ~1% noise floor, so it is close to a wash here.
Dropping software prefetch altogether is not: 3.3x on build, 1.7-2.5x on probe.


Equal-relation-size curves refreshed (R = S, 1/2/4/8/16 gb)
-----------------------------------------------------------
./run_relation_size_update.sh   # cas re-collected; 16gb added to the rest

cas was re-collected end to end with CAS_PREFETCH_INSERTION=DOUBLE (measured
~6% faster on the build phase than a single prefetchw, see above); its stored
curve predated that. The insert knob only gates cas_kht, so cas23 / folklore /
radix kept their points and only gained 16gb -- each re-ran 8gb as a check
first, and merge_relation_size_points.py compares the re-run against the stored
value before the new point is trusted. dlht stops at 8gb: at 16gb its table
plus secondary store does not fit node 2's hbm.

              1gb    2gb    4gb    8gb   16gb
  cas        2842   2732   2594   2553   2479
  cas23      1958   1908   1882   1860   1791
  dlht        920    905    882    865      -
  folklore    837    835    839    813    789
  radix      2227   2221   1966   1436   1086
  radix all  3299   3463   3284   2672   1934   (128 threads, thread-local hbm)

8gb re-run vs stored: cas23 +0.6%, radix +0.5%, folklore -3.3%, all-cpu radix
-13.1% -- that last one was an outlier, two repeats gave 2604 / 2587 against
the stored 2672, so the stored point was kept.

Repeatability is looser at 16gb than at 8gb: cas 16gb measured 2479 / 2524 /
2538 / 2654 over four runs (~7% spread), all-cpu radix 16gb 1934 / 1953 / 1955
(~1%). Treat single 16gb points as +/- 3%.

Hugepage reservation is no longer a flat 2x(R+S): at 16gb that asks for 64gb
from a 64gb hbm node. It is now computed from what the code actually allocates
-- next_pow2(R*100/fill)*16 for the hash table, the estimate_bytes_needed
formula for radix arenas, per-thread page rounding for the relations -- capped
at 85% of the node and never below the real requirement.
