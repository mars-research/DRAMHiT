
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


Radix join with the hardware prefetcher off (single socket, 64 threads)
-----------------------------------------------------------------------
run_single_join.py now takes --prefetcher on|off for --join-type radix too
(it used to hardcode "on", and only hash join could set it); set_prefetcher
re-invokes prefetch_control.sh under sudo when the caller is not root, since
the msr write needs root and that script deliberately does not sudo itself.
The stored radix curves were all collected with the prefetcher ON.

Both states were re-measured in the same session, 3 repeats, median:

  point                        pf on   pf off   delta   partition   join
  skew 1.0 (r=1gb, s=15gb)      2450     1792   -26.9%   37 -> 41   32 -> 54
  relation_size r=s=8gb         1493     1400    -6.2%   73 -> 77   41 -> 45

  (phases in cycles/tuple of r+s; totals 69 -> 95 and 114 -> 122)

Samples: skew 1.0 on 2456/2446/2450, off 1793/1783/1792; 8gb on 1493/1493/1448,
off 1427/1400/1388. The two ranges do not overlap at either point.

The on-state re-runs sit 5% under the stored skew-1.0 point (2580) and 4% over
the stored 8gb point (1436), which is why the comparison is against the fresh
on-runs and not against the json.

The two points react very differently because they partition at different
fanouts: r=1gb picks radix 11 (2048 partitions), r=8gb picks radix 14 (16384),
where get_optimal_radix already warns that partition runtime will go up. At
8gb the partition pass is 64% of the run and is bound by scattered writes over
16384 buckets, which the hardware prefetcher does nothing for -- so switching
it off costs only 6%. At skew 1.0 the join pass dominates the loss (+69%): it
streams each partition pair sequentially out of hbm, and that is exactly the
access pattern the l2 streamer covers. Radix join issues no software
prefetches, so it has nothing to fall back on there, unlike the cas curves
which are collected with the prefetcher off by design.


dlht / folklore with the hardware prefetcher off
-------------------------------------------------
Same two points and the same protocol as the radix comparison above (3
repeats, median, both states re-measured in the same session). dlht and
folklore are the two hashtables HASH_JOIN_VARIANTS runs with the prefetcher
ON, so their stored curves are the "on" column here.

  point                     table      pf on   pf off    delta   build     probe
  skew 1.0 (r=1gb,s=15gb)   dlht        2434     4310   +77.1%   194->154  62->32
                            folklore    1822     2674   +46.8%   228->166  85->57
  relation_size r=s=8gb     dlht         858     1103   +28.6%   279->242  123->69
                            folklore     804     1049   +30.5%   261->192  167->137

  (build/probe in cycles/op, medians of the 3 repeats)

Both tables get FASTER with the prefetcher off, at both points -- the opposite
sign from radix join, which loses 27% / 6% there. Samples: dlht skew 1.0 on
2434/2452/2428 off 4346/4310/4255; dlht 8gb on 865/858/849 off 1098/1107/1103;
folklore skew 1.0 on 1803/1847/1822 off 2661/2674/2686; folklore 8gb on
776/804/808 off 1021/1049/1061. No range overlaps its counterpart.

The on-runs reproduce the stored curves (dlht 2434 vs 2504 and 858 vs 865,
folklore 1822 vs 1833 and 804 vs 813), so the effect is the prefetcher, not
drift.

This is the same reason cas and cas23 are pinned to "off" in
HASH_JOIN_VARIANTS: these tables already software-prefetch their batched
probes into an otherwise random access stream, and the hardware prefetcher
adds nothing to predict -- it just fetches the neighbouring lines of each
random bucket, burning hbm bandwidth and evicting lines the software prefetch
already brought in. It costs most where the run is most probe-bound: dlht's
probe halves at skew 1.0 (62 -> 32 cycles/op).

So the stored dlht and folklore curves understate both tables. Their
HASH_JOIN_VARIANTS defaults ("dlht": on, "folklore": on) are worth revisiting
before those curves are used for a comparison against cas/cas23, which are
collected with the prefetcher off.


Re-collecting dlht / folklore with the prefetcher off (PAUSED, incomplete)
---------------------------------------------------------------------------
Started re-collecting the full skew and relation_size sweeps for dlht and
folklore with --prefetcher off, and stopped partway through the first sweep
by request. Nothing the plotters read was overwritten, and no graph was
redrawn: the relation_size sweeps (which write straight into the plotted
per-variant json) had not started yet, and the skew sweep writes its own file
that still has to be spliced in with merge_skew_points.py.

Backups of the prefetcher-on state, taken before starting:
  intel_hbm_single_hash_dlht_relation_size_prefetcher_on.json
  intel_hbm_single_hash_folklore_relation_size_prefetcher_on.json
  intel_hbm_single_skew_prefetcher_on.json

What was measured (dlht, skew sweep, prefetcher off, 3 repeats, median):
  skew        0.1    0.2    0.3    0.4    0.5    0.6
  pf off     2983   3051   3104   3098   3139  (3312)
  pf on      1643   1693   1885   1874   1948   1978   <- stored curve
  delta      +82%   +80%   +65%   +65%   +61%   (+67%)
0.6 is a single run, not a median of three -- the sweep was stopped during its
second repeat. Saved as intel_hbm_single_hash_dlht_skew_pf_off_partial.json,
recovered from logs/intel_hbm_single_hash_dlht_skew/*.log: run_single_join.py
only writes its json after the last point, so an interrupted sweep leaves
nothing behind but the per-run logs (and those logs carry no --out-suffix, so
the skew-1.0 spot-checks from earlier in the day share the directory -- the
salvage filtered by mtime).

Still to do when this resumes:
  - dlht skew 0.7 .. 1.2, then folklore's full skew sweep
  - both relation_size sweeps (dlht 1/2/4/8 gb, folklore 1/2/4/8/16 gb)
  - merge_skew_points.py <file> dlht|folklore, then plot_skew.py /
    plot_relation_size.py
  - decide whether HASH_JOIN_VARIANTS should flip dlht and folklore to
    "prefetcher": "off" so a later re-run reproduces the stored curve instead
    of the old one


Radix join re-collected: equal relation size, uniform keys, with bandwidth
---------------------------------------------------------------------------
./run_single_join.py --join-type radix --param-name relation_size \
    --relation-sizes-gib 1 2 4 8 16 --repeats 3 --prefetcher on|off --bandwidth
  -> intel_hbm_single_radix_relation_size_uniform_pf_{on,off}.json

Two things are new here. run_single_join.py now drives the prefetcher through
prefetch_control_hbm.sh (off = MSR 0x1a4 0x2f, not 0xf -- 0xf leaves bit 5
enabled on this part, and radix's partition pass is exactly the sequential
pattern that prefetcher serves). And --bandwidth samples both memories at the
controllers while the run is in flight, per phase: the join benchmark uses hbm
for the partition buckets and the hashtable but leaves the r/s relations in the
cpu node's ddr, so counting only hbm would hide half the partition traffic.
hashjoin_test.cpp gained "Join phase start/end" markers for this; the partition
phase already had its pair, the join phase could not be windowed at all.

Throughput, R = S, skew 0.01 (uniform), 64 threads, median of 3:

          1gb   2gb   4gb   8gb  16gb
  pf on  2237  2259  2025  1510  1119
  pf off 1313  1330  1279  1048   872
  delta  -41%  -41%  -37%  -31%  -22%
  stored 2227  2221  1966  1436  1086   <- the old curve, 1 rep, prefetcher on

The on column reproduces the stored curve (within 0.5-5%), which confirms what
that curve was: prefetcher on. The off column is new, and radix is the one
join that badly WANTS the hardware prefetcher -- it loses 22-41% without it,
where the hashtables all gain 4-77% (see ../macro_uniform/). Radix issues no
software prefetches, and its partition pass streams; there is nothing to fall
back on.

Bandwidth per phase, bytes per input tuple (R+S), from the perf window:

           partition B/t        join B/t
          pf on  pf off      pf on  pf off
   1gb     83.2    44.7       32.7    18.6
   2gb     45.7    40.1       28.2    21.7
   4gb     37.6    38.3       27.0    21.8
   8gb     70.2    74.1       27.3    21.4
  16gb    181.9   172.4       26.2    21.1

The join phase is flat at ~21-27 B per tuple at every size: it reads each tuple
once out of an L2-resident partition and that is all. The partition phase is
flat at ~38-45 B/t up to 4gb -- read the tuple from ddr, write it to its bucket
in hbm -- and then explodes: 74 B/t at 8gb and 172-182 B/t at 16gb, 4x the
small-size cost.

The controllers say what changes. Up to 4gb the partition phase reads ddr and
only writes hbm (8gb pf off: ddr r37, hbm w80 -- but also hbm r46). Past that
the hbm side starts READING during partition, which it never did before: r46 at
8gb and r118 at 16gb. That is the write-combining buffers falling out of cache.
Each thread keeps 64 bytes per partition, so radix 14 (16384 partitions, what
8gb picks) is 1mb per thread and radix 15 is 2mb -- against 2mb of L2 shared by
two hyperthreads. Once a buffer line is evicted before it is full, the next
write to that partition has to fetch it back, so a streaming write turns into a
read-modify-write. get_optimal_radix already warns "input size is too big,
partition runtime will go up"; this is what that costs in traffic.

Against the hash joins at the same sizes (their stored curves):

                        1gb   2gb   4gb   8gb  16gb
  hash cas             2842  2732  2594  2553  2479
  hash cas23           1958  1908  1882  1860  1791
  hash dlht             920   905   882   865     -
  hash folklore         837   835   839   813   789
  radix (pref on)      2237  2259  2025  1510  1119
  radix (pref off)     1313  1330  1279  1048   872

cas beats radix at every size even in radix's best configuration, and the gap
widens with size (1.3x at 1gb, 1.7x at 8gb, 2.2x at 16gb) because cas's curve is
nearly flat while radix's falls with the partition blowup. Radix only beats
cas23 below 4gb.

Caveat: the hash-join rows are the stored curves, collected before the msr
finding, i.e. cas/cas23 with "off" = 0xf. For random-access tables that
difference measured under 2% (see ../macro_uniform/INTEL_HBM_UNIFORM_REPORT.md),
so they are comparable, but they are not re-collected numbers.


Hash joins re-collected: equal relation size, prefetcher fully off
-------------------------------------------------------------------
./run_single_join.py --join-type hash --hashtable <t> --param-name relation_size \
    --relation-sizes-gib 1 2 4 8 16 --repeats 3 --prefetcher off --bandwidth
  -> intel_hbm_single_hash_<t>_relation_size_pf_off.json

"off" here is prefetch_control_hbm.sh, MSR 0x1a4 = 0x2f. The stored curves are
not that: cas and cas23 were collected at 0xf (which leaves bit 5 enabled) and
dlht and folklore were collected with the prefetcher ON, per HASH_JOIN_VARIANTS.
hashjoin_test.cpp gained "Build phase start/end" and "Probe phase start/end"
markers so the two phases can be windowed, the same way the radix path now is.

Throughput, R = S, median of 3:

              1gb   2gb   4gb   8gb  16gb   vs stored
  cas        2655  2662  2577  2582  2505   -7% .. +1%   (stored: off @0xf)
  cas23      1900  1916  1887  1856  1795   -3% .. +0%   (stored: off @0xf)
  dlht       1117  1109  1103  1087     -   +21% .. +26% (stored: prefetcher ON)
  folklore   1004   993   975   962   952   +16% .. +21% (stored: prefetcher ON)

dlht and folklore want the prefetcher off, by 16-26%, at every size and not
just at the 8gb spot check that first showed it. cas and cas23 barely move,
which is the expected shape: the leftover bit-5 prefetcher only has something
to latch onto when the access pattern walks consecutive addresses, and those
two probe a bucketized table through a software prefetch queue. cas loses 6.6%
at 1gb and gains ~1% at 8-16gb, so even there it is close to a wash.

Note folklore's true-off number is BELOW the 0xf spot check taken earlier
(962 against 1049 at 8gb): bit 5 helps its linear probe walk, so "more off" is
slower for it. Its advantage over the prefetcher-on curve is still +18% at that
size.

Per-phase bandwidth, GB/s, median of 3 (hbm holds the hashtable, ddr holds the
r/s relations):

              size   build hbm/ddr   probe hbm/ddr
  cas          1gb       210 / 31       250 / 51
  cas          8gb       287 / 36       246 / 60
  cas23        8gb       235 / 28       161 / 36
  dlht         8gb        92 / 11       162 / 40
  folklore     8gb       121 / 14        96 / 19

cas moves roughly 3x the memory traffic folklore does per unit time and is 2.7x
faster, which is the same story the uniform panel tells: the fast tables are
not using less bandwidth, they are converting more of it into completed
operations.

A hugepage bug fixed on the way: dlht's secondary store is a separate
allocation, and calloc_ht picks its page size by size alone -- over 1gb it maps
1gb pages, at or under it maps 2mb ones. At r=1gb and 2gb that store is 512mb
and 1gb, so it wanted 2mb pages on the MEM node, where reserve_hugepages was
asking for 1gb pages only (n<node>_<gb>gb_0mb). The mmap and the mbind both
succeed and the run then dies faulting the pages in, leaving a truncated log
and no error -- exactly the failure the macro_uniform collector hit. The mem
node now gets MEM_NODE_2MB_RESERVE_MB of 2mb pages when the table is dlht, and
those two points were re-run and merged (see "repaired" in the json).


intel_hbm_single_relation_size.png redrawn: each join in the state it wants
----------------------------------------------------------------------------
plot_relation_size.py now reads, per series:

  cas / cas23 / dlht / folklore  *_relation_size_pf_off.json   (0x2f, all off)
  radix                          *_radix_relation_size_uniform_pf_on.json
  radix (all cpus)               intel_hbm_allcpu_radix_relation_size.json

i.e. the hashtables with the hardware prefetcher off and both radix curves with
it on, because that is what each one measures fastest by a wide margin (16-26%
for dlht/folklore off, 22-41% for radix on). The panel title says so, since the
series no longer share a machine configuration.

The single-socket radix line is the new 3-repeat collection rather than the old
single-run curve; it differs from it by 0.5-5%. The all-cpu line is unchanged --
it was collected when radix hardcoded the prefetcher on, which is the state this
figure wants anyway.

What the figure now shows at equal relation size:
  - cas is flat (2655 -> 2505) and is the fastest single-socket join at every
    size past 4gb.
  - radix on one socket falls steeply (2237 -> 1119), crossing below cas23
    around 5gb, for the partition-phase reason documented above.
  - radix on all 128 threads starts well above everything (3299 at 1gb) and
    still crosses below cas between 8 and 16gb, ending at 1934 against 2505 --
    twice the machine, less throughput.
