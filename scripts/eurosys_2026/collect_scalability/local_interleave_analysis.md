# Local vs interleaved bandwidth scaling, read and write — AMD EPYC 9354P

Collected 2026-09-21 on the same box as
[`cpu_scaling_analysis_amd.md`](cpu_scaling_analysis_amd.md): 1x AMD EPYC 9354P (Zen4
Genoa), 32 cores / 64 threads, NPS4 (4 NUMA nodes x 8 cores x 3 DDR5-4800 channels).

Data: [`amd_local_interleave.json`](amd_local_interleave.json) ·
figures: [`amd_local_scaling.png`](amd_local_scaling.png),
[`amd_interleave_scaling.png`](amd_interleave_scaling.png) ·
collector: [`collect_local_interleave.py`](collect_local_interleave.py) ·
plotter: [`plot_local_interleave.py`](plot_local_interleave.py)

Two sweeps, each in read and write:

| sweep | placement | memory |
|---|---|---|
| **local** | 1..16 threads on **every** node at once (total 4..64) | bound to each thread's own node (`n0a0tT n1a1tT n2a2tT n3a3tT`) |
| **interleave** | 1..64 threads total, thread *i* -> node *i%4* | `MPOL_INTERLEAVE` across all 4 nodes (`n0a0-3tX n1a0-3tY ...`) |

Read is `prefetcht1`, lookahead 64. Write is a plain store (`-inst load -mode w`).
3 reps per point, 20 ms perf intervals, all 12 `amd_umc` boxes counted every run.

Bandwidth is **traffic at the DRAM controllers** (rd+wr CAS x 64 B). For reads that is
essentially all reads; for writes it is ~2.2x what the program stores — see section 3.

## 0. Answers

| question | answer |
|---|---|
| Does a core buy a fixed slice? | Only to ~2 threads/node. At 64 threads the machine delivers **22.6% (read) / 21.9% (write)** of what the 1-thread slice extrapolates to. |
| Where is the first ceiling? | **Not the DRAM channels** — it is each CCD's own fabric link, hit at 4 threads/node with half the machine's CCDs still idle. |
| Read vs write ceiling | read **367 GB/s**, write **291 GB/s** of controller traffic — but only **130 GB/s** of lines dirtied. |
| Cost of interleaving? | **~2%** (0.2-2.7% past 12 threads; ~5% at 4-8 threads). Essentially free. |
| Why is 1r1w so far below read? | **Bank occupancy.** A store holds its bank for two row cycles, 52 ns + 86 ns, against a read's 52 ns; 138/52 = 2.65x, which is the whole deficit. The extra 34 ns is tWR. Not the activate rate, not the data bus, not turnaround. §5 |
| Is that fabric or DRAM? | DRAM. One controller driven alone shows the same ratio, and restricting the stream to N of its 64 banks reproduces it from DRAM timings alone. §5 |
| Would better DIMMs help? | These are **1Rx8** parts: 64 banks per controller. Reads need ~24 and are done; writes are still gaining 11% per 33% more banks when they run out. A dual-rank part should close most of the gap. §5 |
| Does prefetchW / prefetchT1 help writes? | `prefetchw` **no** (0% at every thread count). `prefetcht1` +20% at 8 threads, +2.4% at saturation — an MLP fix, not a bandwidth fix. Full-line **NT stores give 1.64x**. §5 |

## 1. The first ceiling is per-CCD, not per-channel

The read curve does something odd: it flattens at ~200 GB/s for 3-4 threads/node, then
**resumes climbing** at 5.

```
threads/node   1      2      3      4   |   5      6      7      8   |   9 ... 16
read GB/s    100.4  180.8  199.3  199.9 | 266.2  298.8  315.6  325.6 | 367.0 ... 363.0
```

12 -> 16 threads (+33% cores) bought **+0.3%**. Then 16 -> 20 bought **+33%**.

That is a hardware boundary, and it is the CCD. This chip is 8 CCDs of 4 cores, each
with its own L3 and its own fabric link to the IO die:

```
CCD0 cpus 0-3,32-35    CCD1 cpus 4-7,36-39     <- NUMA node 0
CCD2 cpus 8-11,40-43   CCD3 cpus 12-15,44-47   <- NUMA node 1   (etc.)
```

So each NPS4 node is **2 CCDs**, and `bandwidth.c` pins thread *t* to the *t*-th cpu of
its node in ascending order — which means threads 1-4 per node land **entirely on that
node's first CCD**, and the second CCD does not carry a single beat until thread 5.

Confirmed directly at the fabric, with `amd_df`'s per-CCD ports:

```
perf stat -a -e amd_df/local_socket_inf0_inbound_data_beats_ccm{0..7}/ -- bandwidth_rand ...

 4 threads/node:  ccm0-3 = 3.39e9 beats each,  ccm4-7 = ~1e5  (idle)
 8 threads/node:  all 8 ccm = 3.39e9 beats each
```

Half the CCDs are doing nothing at 4 threads/node, and the four that are working are
pinned at ~200/4 = **~50 GB/s per CCD** — which is the CCD link's number, not the
channels'. The node's own 3 channels could carry 115 GB/s, and the machine's 12 carry
367 GB/s once all 8 CCDs are engaged.

### The bottleneck hands off: links first, DRAM second

Engaging the second CCD of every node takes the machine from 200 to 367 GB/s — not to
2 x 200. The reason is that the constraint moves. Measured at both ends of the path per
thread count (`amd_df ccm<0-7>` inbound beats at 32 B/beat, and `amd_umc` CAS +
data-bus occupancy; fabric and DRAM totals agree within 1-2% everywhere, so nothing is
being lost inside the IOD):

| threads/node | live CCDs | DRAM GB/s | DRAM bus util | fabric GB/s | per-CCD |
|---|---|---|---|---|---|
| 1 | 4 | 99.4 | 21.6% | 101.1 | 25.3 |
| 2 | 4 | 180.1 | 39.1% | 181.7 | 45.4 |
| 4 | 4 | 198.7 | **43.1%** | 199.7 | **49.9** |
| 6 | 8 | 297.5 | 64.6% | 300.5 | 37.6 |
| 8 | 8 | 329.9 | 71.6% | 325.4 | 40.7 |
| 12 | 8 | 361.5 | 78.5% | 364.7 | 45.6 |
| 16 | 8 | 363.7 | **78.9%** | 363.1 | **45.4** |

At 4 CCDs the per-CCD rate is pinned at ~50 GB/s while the DRAM bus is **43% idle-ish** —
the links are the constraint and the memory has headroom to spare. At 8 CCDs the
per-CCD rate settles at 45.4, *below* the 50 it demonstrably can do, while bus occupancy
pins at ~79%. The links stop being the thing that binds; 8 x 50 = 400 GB/s is what they
could carry and the DRAM only takes ~364.

The clean proof is to change DRAM efficiency and nothing else. The sequential build
walks rows instead of hashing addresses, over the *same* links and IOD:

| | 4 CCDs (4 thr/node) | 8 CCDs (8 thr/node) |
|---|---|---|
| random | 184.3 GB/s, 43.0% util | 287.9 GB/s, 66.9% util |
| sequential | 182.2 GB/s, 42.5% util | 360.2 GB/s, 83.0% util |
| gain | **-1%** | **+25%** |

At 4 CCDs, better DRAM behaviour is worth nothing — you are waiting on the links. At
8 CCDs the identical change is worth 25%, which it could not be if the links or the IOD
were the cap there. **So: 4 CCDs -> CCD-link limited; 8 CCDs -> DRAM limited**, with
~83% bus occupancy the practical ceiling this memory reaches (the missing ~17% is
activate/precharge overhead — see section 5).

The counters that show each layer, for anyone repeating this:
`amd_df/local_socket_inf0_inbound_data_beats_ccm<0-7>` (CCD <-> IOD, 32 B/beat),
`amd_df/local_processor_read_data_beats_cs<0-11>` (IOD <-> controller, one per channel),
and `amd_umc_<0-11>/umc_data_slot_clks.all` vs `umc_mem_clk` (the DRAM data bus itself).
The last one is what answers "is the memory the limit": 43% means no, 79% means yes.

**This is not a footprint artifact.** The harness sizes each thread's chunk as
16 GB/threads rounded down to a power of two, so chunk size changes at exactly the
thread counts where the curve jumps — a plausible confound, and wrong. Holding threads
fixed and sweeping the chunk over a 16x range moves nothing:

| threads | 128 MB | 256 MB | 512 MB | 1024 MB |
|---|---|---|---|---|
| 16 | 199.3 | 200.5 | 199.8 | 199.9 |
| 64 | 367.6 | 363.0 | — | — |

> **Correction to [`cpu_scaling_analysis_amd.md`](cpu_scaling_analysis_amd.md).** That
> writeup reads the 4-8 threads/node regime as "the node's 3 DDR5 channels filling up".
> It is the per-CCD link instead; the channels are not the constraint until all 8 CCDs
> are loaded. Its top-end conclusions (~367 GB/s ceiling at ~80% of theoretical, no
> fabric-wide bottleneck above the controllers, SMT worth nothing) are unaffected.

## 2. Linear scaling holds to about 2 threads per node

Both figures draw a dashed line through each curve's own first point — a fixed slice
per thread, extrapolated. Read leaves it almost immediately:

| threads/node | 1 | 2 | 4 | 8 | 16 |
|---|---|---|---|---|---|
| read, measured | 100.4 | 180.8 | 199.9 | 325.6 | 363.0 |
| read, linear from 1 thr | 100.4 | 200.8 | 401.6 | 803.2 | 1606 |
| % of linear | 100% | 90% | 50% | 41% | **22.6%** |

Write follows the same shape (21.9% of linear at 64 threads). The departure is not a
wall hit at the end — it starts at 2 threads/node and decays continuously, with the CCD
plateau of section 1 layered on top.

## 3. Read vs write: a store costs about 2.2x its own bytes

A store that misses fetches the line first (read-for-ownership) and writes it back
later, so the controllers move roughly double what the program thinks it stores. The
counters show it cleanly — read and write CAS counts stay within 0.2% of each other at
every single point:

| threads | program stores | controller rd | controller wr | total | ratio |
|---|---|---|---|---|---|
| 4 | 34.1 | 38.7 | 38.6 | 77.3 | 2.27x |
| 16 | 92.5 | 103.8 | 103.7 | 207.5 | 2.24x |
| 32 | 130.0 | 145.0 | 144.8 | 289.9 | 2.23x |
| 64 | 122.3 | 135.7 | 135.5 | 271.2 | 2.22x |

So the write ceiling is **291 GB/s of DRAM traffic but only ~130 GB/s of lines
dirtied**, against ~324 GB/s of useful reads on the same hardware. Section 5 takes that
gap apart: it is *not* mostly RFO, and it is *not* bus turnaround.

## 4. Interleaving across all 4 nodes is nearly free

At equal total thread count, spreading every thread's memory over all 4 nodes instead
of keeping it node-local costs:

| total threads | 4 | 8 | 16 | 32 | 48 | 64 |
|---|---|---|---|---|---|---|
| read | -4.8% | -4.3% | -0.2% | -1.4% | -1.9% | -2.7% |
| write | -5.0% | -3.7% | -1.2% | -1.2% | -1.3% | -1.8% |

~2% across the useful range, ~5% at very low thread counts where per-thread latency
matters most and 3/4 of accesses are now a fabric hop away.

That is much smaller than NUMA intuition from dual-socket machines would suggest, and
the reason is what "remote" means here: NPS4 nodes are BIOS partitions of **one**
socket's memory system. A remote access crosses to another quadrant of the same IO die
— there is no socket-to-socket link in the path, because there is no second socket.
Locality on this machine is worth ~2%, not the 30-50% a real inter-socket hop costs.

The practical consequence for DRAMHiT: on this box, a hash table interleaved across all
4 nodes gives up almost nothing versus a carefully node-partitioned one — but **which
CCDs the threads sit on matters a great deal** (section 1). Thread placement is worth
optimising; memory placement, on this machine, mostly is not.

## 5. Why 1r1w lands so far below read — and what does (and doesn't) fix it

The write workload puts a 1:1 read/write stream on the DRAM (RFO fetch + writeback per
store) and tops out at 290 GB/s, against 363 GB/s for pure read. The intuition that a
1r1w stream "should generate about as much traffic as a read stream" is reasonable and
it is wrong here. Three candidate causes, all measurable at the controller:

| workload | traffic GB/s | act/CAS | data-bus util | wr frac |
|---|---|---|---|---|
| pure read (`-inst t1 -mode r`) | 363.2 | 0.99 | 76.2% | 1.3% |
| 1r1w store (`-inst load -mode w`) | 272.4 | 1.05 | 56.8% | 50.0% |
| pure NT write (`-inst ntstore -mode w`) | 229.3 | 0.99 | 49.5% | 98.9% |

(64 threads, all 4 nodes local, 100% counters enabled — `umc_cas_cmd.rd/.wr`,
`umc_act_cmd.all`, `umc_data_slot_clks.all`, `umc_mem_clk`. `amd_umc` has 4 counters per
box, so activates and bus occupancy are taken in separate passes.)

**It is not row locality.** `act/CAS` is ~1.0 for every workload: one DRAM row opened per
64 B access, in all three cases. Random access over gigabytes has no row-buffer locality
to lose, and writes do not lose more of it than reads.

**It is not the data bus.** Bus occupancy never exceeds 78%, and is *lowest* — 49.5% —
for the pure write stream that is fastest per transaction to put on the wire. The bus
sits idle regardless; something upstream of it is metering the transactions.

**It is not turnaround either** (this was my first hypothesis and the NT-store run
refutes it). If mixing reads and writes were expensive, a *pure* write stream would beat
a mixed one. It does not: pure NT writes reach 229 GB/s against the mixed stream's 272.
And the mixed stream's bus occupancy, 56.8%, sits almost exactly midway between pure
read's 76.2% and pure write's 49.5% (midpoint 62.9%) — i.e. the mix behaves like the
average of its two halves, with turnaround worth a point or two, not fifteen.

**And it is not the activate rate either** — which I did first conclude, from the random
data alone, and the sequential build disproves. `bandwidth.c` has a `-DSEQUENTIAL` build
(`make build/bandwidth_seq`) that walks lines in order instead of hashing an index, so it
gets real row reuse. Same two-pass counters, same patterns, 64 threads:

| build | workload | traffic | act/CAS | lines/activate | bus util |
|---|---|---|---|---|---|
| random | pure read (t1) | 334.7 | 0.993 | 1.0 | 76.6% |
| **seq** | pure read (t1) | **352.8** | **0.628** | **1.6** | **80.0%** |
| random | 1r1w store (load) | 122.2 | 1.049 | 1.0 | 56.7% |
| **seq** | 1r1w store (load) | **137.9** | **0.915** | **1.1** | **63.7%** |
| random | pure NT write | 213.5 | 0.993 | 1.0 | 49.4% |
| **seq** | pure NT write | **213.5** | **0.756** | **1.3** | **49.5%** |

(At 32 threads the sequential read does even better on locality — act/CAS 0.547, 1.8
lines per activate, 82.3% occupancy — for 359.1 GB/s.)

Sequential access cuts activates per access by **37%** on read and still buys only
**+5.4%** of bandwidth. On the NT write it cuts them by 24% and buys **nothing at all**
(213.5 both ways, occupancy 49.4% vs 49.5%). If the activate rate were the binding
constraint, removing a third of the activates would not be worth five percent. It is not
the constraint.

(Row reuse is real but modest even so — 1.6 lines per activate, not the ~16 a 1 KB row
would suggest. Consecutive lines are interleaved across the node's 3 channels, and 8-16
threads per node are streaming independently, so each channel sees many interleaved
streams rather than one march through a row.)

**What the evidence actually supports** is a ceiling on the write path that none of the
knobs move. Pure NT writes sit at 213.5 GB/s and ~49.5% bus occupancy identically at 32
and 64 threads, under random *and* sequential access — invariant to thread count, to
access order, and to row locality. Reads sit at 76-82% occupancy under the same
variation. The read:write ratio stays ~0.63 throughout. What is measured:

- the ceiling is on writes specifically, and is ~0.63x the read ceiling;
- it is unaffected by access pattern, row locality, or thread count;
- turnaround from mixing reads and writes costs a point or two of occupancy, not more.

### Where the limit lives: at the controller, not the fabric

An earlier draft stopped here, saying this sweep could not tell a CCD-link or fabric
limit from a controller one. It can now, by driving a **single memory controller** on
its own. `../reverse_channel/amd_channel_probe.c` uses `reversed_amd.c`'s address
predicate to select only the lines one controller owns out of a 1 GiB hugepage, and adds
a 1r1w store mode plus a repeating loop long enough for a `perf stat -I` median to land
on the steady state rather than on the 1 GiB init that precedes it.

On nodes 1 and 2 the predicate isolates exactly one controller (umc4 and umc7
respectively; every other box on the node stays under 1.5 GB/s), driven by that node's
own 16 cpus. Both nodes give the same numbers:

| single controller, 16 local threads | GB/s | % of the 38.4 GB/s channel peak |
|---|---|---|
| read | **33.7** | 88% |
| 1r1w (rd+wr at the controller) | **26.0** | 68% |
| ratio | **0.77** | |

The asymmetry survives complete isolation. One controller, fed by 16 cpus on its own
node, with the other eleven channels idle and the CCD links carrying a fraction of what
section 1 shows they can — and a 1r1w stream still tops out at 0.77 of that same
controller's read ceiling, against 272/363 = 0.75 for the whole machine. **The write
ceiling is a property of the memory controller and the DRAM behind it, not of the fabric
or the CCD links.**

It also puts a number on what the machine loses to sharing: 12 x 33.7 = 404 GB/s of
per-controller read capability against 363 measured with all of them running (90%), and
12 x 26.0 = 312 against 272 for 1r1w (87%).

(On node 0 the same predicate straddles *two* controllers — umc0 and umc2, evenly —
because the hugepage landed at a different 12 MB cycle offset. Driven the same way that
pair gives 32.2 read / 25.6 1r1w per channel, consistent with the single-controller
figures. The probe prints the per-box breakdown on every run precisely so the number of
channels in play is read off the counters rather than assumed; `reversed_amd.c`'s claim
to select "UMC 1" does not hold on this machine in NPS4.)

### What the write path is actually waiting for: bank occupancy

The controller answer above still says nothing about *why* a controller serves writes at
0.77x its read rate. It is bank occupancy, and the numbers fall out cleanly once you can
vary the number of banks a stream is allowed to use.

`../reverse_channel/amd_channel_probe.c` grew a `-b N` mode to do that. Banks cannot be
selected by address: clamping bits does nothing, because the UMC hashes the bank index.
Sweeping every physical address bit from 6 to 25 one at a time, only bits 6 and 7 move
the read rate at all (-6.9% and -5.1%, which is column locality inside the 256 B
interleave chunk); bits 8 through 25 are flat to within 1%. The same sweep on the
*normalized* address -- the address the controller sees, with the interleave selector
removed, where the r-th line this controller owns sits at r*64 -- gives the identical
answer. Clamping twelve normalized bits cumulatively shrinks the working set from 358 MB
to 92 KB and swings activates per access from 0.70 through 0.14 and back to 0.66, and
read stays between 30.4 and 33.1 GB/s and 1r1w between 27.5 and 29.0 the whole way.
Lines a megabyte apart in normalized space still reach full bandwidth, which they could
not if the bank index were a contiguous address field -- they would all be one bank in
different rows.

So `-b N` finds banks by timing instead. Two lines on the same channel in different banks
can be open at once; two in the same bank in different rows cannot, and the second pays a
precharge and an activate. That gap is ~40 ns here (pair latency p50 390 cycles, p99 520),
and it does not care how the index is hashed. Clustering the controller's own lines by it
finds **64 banks** -- exactly the 2 subchannels x 8 bank groups x 4 banks of a
single-rank DIMM -- and the clustering checks out: lines within a cluster conflict
196-199 times out of 200, lines across clusters 0 out of 200.

Then the workload is built round-robin over N of those clusters. Per point: node 1, umc4
alone (umc3 and umc5 stay at 0.02 GB/s), 16 threads, 8192 lines total however they are
split, 3 s of steady state, traffic from `umc_cas_cmd.rd/.wr`. `ns/bank` is the bank time
per 64 B moved, 64*N/GB-per-s:

| banks | read | act/CAS | ns/bank | 1r1w | act/CAS | ns/bank | NT write | act/CAS | ns/bank | 1r1w/read |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 1.23 | 0.97 | **51.8** | 0.90 | 0.98 | 71.0 | 0.74 | 0.97 | **86.0** | 0.730 |
| 2 | 2.41 | 0.99 | 53.1 | 1.78 | 0.99 | 72.0 | 1.43 | 0.99 | 89.7 | 0.738 |
| 4 | 4.76 | 0.99 | 53.7 | 3.45 | 1.00 | 74.1 | 2.79 | 0.99 | 91.8 | 0.725 |
| 8 | 9.38 | 1.00 | 54.6 | 6.68 | 1.02 | 76.6 | 5.49 | 1.00 | 93.2 | 0.712 |
| 16 | 18.89 | 0.99 | 54.2 | 12.63 | 1.03 | 81.1 | 10.41 | 1.00 | 98.4 | 0.669 |
| 24 | 26.56 | 1.00 | 57.8 | 17.53 | 1.04 | 87.6 | 14.76 | 1.00 | 104.1 | 0.660 |
| 32 | 28.34 | 1.00 | 72.3 | 21.10 | 1.05 | 97.0 | 18.40 | 1.00 | 111.3 | 0.745 |
| 48 | 29.50 | 1.00 | 104.1 | 24.28 | 1.06 | 126.5 | 22.56 | 1.01 | 136.2 | 0.823 |
| 64 | 29.91 | 1.00 | 137.0 | 26.98 | 1.07 | 151.8 | 25.11 | 1.01 | 163.1 | 0.902 |

The left end is the answer. At one to eight banks nothing downstream is anywhere near
saturated -- one bank is 3% of the channel -- so `ns/bank` is pure DRAM timing, and it is
flat:

```
read      52 ns of bank time per 64 B   = tRC
NT write  86 ns                         = tRC + 34 ns
1r1w     142 ns per line touched        = 52 + 86, to within 3%
```

A **store occupies a bank for two row cycles, and the write one is 1.65x the read one**.
That is the whole thing. The 34 ns is write recovery: the bank cannot precharge until
tWR after the last write beat, JEDEC's 30 ns at DDR5-4800, and nothing about access
pattern, row locality or thread count changes it. (Inferred from this measurement, not
read off the module -- this box has no `spd5118` driver bound and no `decode-dimms`, so
the SPD timings could not be checked directly.)

Every number in section 5 follows from those three:

| claim in this report | predicted from bank time | measured |
|---|---|---|
| 1r1w traffic vs read, one controller | 128 B/138 ns vs 64 B/52 ns = 0.75 | 0.766 |
| 1r1w traffic vs read, whole machine | 0.75 | 272/363 = 0.75 |
| useful stores vs read (122 vs 334) | 138/52 = 2.65x | 2.7x |
| NT store gain over 1r1w | (64/86) / (64/138) = 1.60x | 1.64x |

And the two factors the earlier draft split the deficit into turn out to be the same
thing seen twice. The "2.0x RFO amplification" is the second row cycle existing at all;
the "1.33x write-path ceiling that no knob moves" is that the second one is longer --
(52+86)/(52+52) = 1.33. There was never a separate ceiling to find.

**Why this machine feels it.** Read needs 29.9/1.23 = ~24 banks to reach its ceiling and
has 64. A store stream needs roughly twice that and does not have it: from 48 to 64 banks
(+33%) read buys **+1.4%** while 1r1w buys **+11%** and NT writes **+11%** -- read is
done, writes are still climbing when the banks run out. These are **1Rx8 RDIMMs**
(`dmidecode -t 17`: twelve 16 GB DDR5, `Rank: 1`, 1 DPC, configured 4800 MT/s), so 64
banks per controller is all there is. A dual-rank part would double it, and this curve
predicts most of the read/write gap would close, with reads gaining almost nothing --
which is a cheap thing to check on a machine with 2R DIMMs and worth doing before
treating 0.75 as a property of DDR5 in general rather than of this configuration.

Above ~32 banks none of the three is bank-limited any more (at 64 banks a bank is busy
38% of the time on reads, 47% on 1r1w, 53% on NT), and the remaining ceiling -- read at
78% of the channel -- is the activate/refresh overhead section 5 already bounded.

Method notes for repeating it. The clamped and bank-restricted working sets are small,
down to 512 KB, so `-f 64` flush-behind is on throughout: each access clflushopt's the
line accessed 64 iterations earlier, which makes every access a DRAM miss no matter how
small the set. That is not free and it is not neutral -- at the full 358 MB set, where it
is unnecessary, it costs reads 10% and gains 1r1w 4%:

| clamp 0, 358 MB, umc4 | read | 1r1w | ratio |
|---|---|---|---|
| flush-behind off | 33.85 | 25.93 | **0.766** |
| flush-behind on | 30.48 | 27.04 | 0.887 |

The off row reproduces the 33.7 / 26.0 of the previous section, so the probe's other
changes (index array bound to a different node so its stream misses the controller under
test, 32-bit line indices, deadline-based run length) did not move the baseline. The on
row is the control the `-b` sweep should be read against, and `-b 64` -- 64 banks, 512 KB
-- gives 29.91 / 26.98, reproducing it. The restriction machinery is not distorting
anything; the bank count is doing the work.

So the useful-store deficit (122 vs 334 GB/s, 2.7x) is one number, not two: a store
holds its bank for a read row cycle plus a write row cycle, 138 ns against a read's 52,
and 138/52 = 2.65x. Turnaround is the 3% the sum does not account for.

One practical side effect: the write regression past 32 threads is a random-access
artifact. Random 1r1w falls from 135.0 (32 thr) to 122.2 (64 thr); sequential 1r1w holds
at 138.9 -> 137.9.

### Does prefetchW or prefetchT1 help? Measured: prefetchW not at all, prefetchT1 only when unsaturated

Every `-inst` variant, write mode, controller traffic in GB/s:

| threads | `load` (no pf) | `t0` | `t1` | `nta` | `prefetchw` |
|---|---|---|---|---|---|
| 8 | 141.1 | 141.0 | **169.2** | 141.2 | 140.8 |
| 32 | 289.8 | 289.5 | 297.1 | 290.0 | 289.7 |
| 64 | 271.5 | 271.8 | 278.1 | 273.1 | 272.5 |

- **`prefetchw` buys nothing, at any thread count** (140.8 vs 141.1 at 8 threads; 289.7
  vs 289.8 at 32). Its advantage is fetching the line straight into Modified state so the
  store needs no separate ownership upgrade — but the line is coming from DRAM, where
  nothing else holds it, so there is no upgrade to save. The RFO still happens; it just
  happens earlier. The DRAM does exactly the same work.
- **`prefetcht1` helps +20% at 8 threads and +2.4% at saturation.** That is the signature
  of a memory-level-parallelism fix, not a bandwidth fix: with few threads the core
  cannot keep enough stores in flight to cover DRAM latency, and the prefetch covers it;
  once 32 threads are supplying more requests than the controllers can retire, there is
  nothing left to hide. `t0` and `nta` do not help even at 8 threads.

**What does help is not prefetching at all — it is not doing the RFO.** A full-cache-line
non-temporal store (added as `-inst ntstore`, `_mm512_stream_si512`) skips the fetch
entirely — measured `umc_rd` drops to 0.0-0.1 GB/s, traffic becomes 98.9% writes — and
lifts lines-dirtied-per-second from 130 to **213 GB/s, a 1.64x gain**, flat from 32
threads up.

> **The catch, and it matters for DRAMHiT.** That 1.64x is only available to a workload
> that writes *whole* cache lines. The `-inst load` write path stores 8 B into each 64 B
> line, so its "130 GB/s" is lines dirtied, not bytes written (the program architecturally
> wrote an eighth of that); the line still has to be fetched because 56 of its bytes must
> survive. An NT store is only legal when you are overwriting all 64 B. A hash-table
> insert touching one 16 B slot cannot use one directly — it would need writes batched or
> staged so that a full line is produced at once. Where that restructuring is possible,
> this is the single largest write-side win available on this machine; where it is not,
> the 2x RFO cost is simply the price of a partial-line store.

## 6. Method notes

Everything in [`cpu_scaling_analysis_amd.md`](cpu_scaling_analysis_amd.md) section 1
applies unchanged (node -> `amd_umc` box mapping, 3.25 GHz clock, 64 B/CAS,
space-separated `-pattern` groups). Two things specific to this run:

- **All 12 UMC boxes are counted for every point**, not just those of active cpu nodes:
  under interleave the memory is spread over all 4 nodes however few cpu nodes run. All
  36 events (12 boxes x rd/wr/clk) counted at 100% enabled with no multiplexing —
  verified in the logs' perf percentage column.
- **`prog_bw_gbs` undershoots the counters at high thread counts** (~10% at 32 threads,
  up to ~30% at 40-48), same as the earlier sweep. The controller-side number is taken
  as authoritative; the program's own figure is kept per point in the json.
