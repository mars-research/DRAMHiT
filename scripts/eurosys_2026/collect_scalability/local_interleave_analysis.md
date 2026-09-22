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
| Why is 1r1w so far below read? | **2.0x RFO amplification x 1.33x a write-path ceiling** that no knob moves (same at 32/64 threads, random *and* sequential). Not the activate rate, not the data bus, not turnaround. §5 |
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
variation. The read:write ratio stays ~0.63 throughout. That is the signature of a
structural limit on writes rather than a DRAM-timing or locality effect, and AMD's fabric
is documented to carry less write than read bandwidth per CCD link — but this sweep has
not isolated *where* the limit sits (CCD link vs. controller write queue vs. DRAM), and I
am not going to claim a mechanism these counters did not show. What is measured:

- the ceiling is on writes specifically, and is ~0.63x the read ceiling;
- it is unaffected by access pattern, row locality, or thread count;
- turnaround from mixing reads and writes costs a point or two of occupancy, not more.

So the useful-store deficit (122 vs 334 GB/s, 2.7x) decomposes as **2.0x from RFO
amplification x 1.33x from the write-path ceiling**, with turnaround a rounding error.

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
