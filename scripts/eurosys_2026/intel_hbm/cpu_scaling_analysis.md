# Does a core buy a fixed slice of HBM bandwidth? Core-count sweep, node 0 -> node 2

Collected 2026-09-20 on the Xeon CPU Max 9462 described in
[`machine_spec_analysis.md`](machine_spec_analysis.md). CPUs from NUMA node 0,
memory bound to node 2 (socket 0's own HBM), so nothing crosses UPI and the only
variable is how many cores are pulling.

Data: [`intel_hbm_cpu_scaling.json`](intel_hbm_cpu_scaling.json) ·
figure: [`intel_hbm_cpu_scaling.png`](intel_hbm_cpu_scaling.png) ·
collector: `collect_cpu_scaling.py` · plotter: `plot_cpu_scaling.py`

The figure's four curves: HBM read (prefetchT1), the same run with plain
loads, HBM write, and the DDR read control.

## 0. Answer

**No. A core buys a fixed slice only for the first ~8 cores, and the marginal
gain then decays continuously to near zero.** Three regimes, all in one curve:

| regime | threads | marginal GB/s per added thread | what limits it |
|---|---|---|---|
| per-core | 1 - 8 | 12.96 -> 12.59 (97.6% of linear at 8) | the core's own outstanding-miss capacity |
| transition | 8 - 32 | 12.28 -> 9.84 (88.9% of linear at 32) | shared fabric, progressively |
| saturated | 33 - 64 | 1.4 - 1.9 | shared fabric, fully |

At 64 threads the socket delivers **424 GB/s**, which is **51% of what a fixed
12.96 GB/s slice per thread would predict** (832 GB/s) and **52% of the 819 GB/s
the HBM channels could carry**.

The departure from linearity begins around **8-12 threads (~150 GB/s)** — far
below the ceiling. That is the signature of a shared resource whose service
time rises with load, not of a hard wall hit at the end.

**And the onset is set by bandwidth, not by core count.** Rerunning the sweep
with plain loads instead of `prefetcht1` — which pull ~1.5x less per core — the
per-core slice stays fixed out to *20* threads instead of 8. The two curves lose
their first 3% at 12 and 24 threads — 2x apart — but at 150 and 196 GB/s, only
1.3x apart. Neither predictor is exact, but bandwidth is much the better one: a
core that pulls 1.5x harder reaches the bend with roughly half as many cores.
See section 3.

## 1. The measurement

`machine_stats/bandwidth.c` built as `bandwidth_rand`: random 64 B accesses,
`prefetcht1`, lookahead 64, hardware prefetchers off, cores pinned at 2.7 GHz
(`scripts/setup_hbm.sh`). Every run is measured at the memory controllers
themselves, not from the program's own byte count:

- HBM (nodes 2/3): 32 `uncore_hbm_*` boxes per socket, raw encodings
  `event=0x05,umask=0xcf` (rd) / `0xf0` (wr), **32 B per CAS**.
- DDR (nodes 0/1): 8 `uncore_imc_*` boxes per socket, the same encodings —
  `uncore_imc_0/events/cas_count_read` *is* `event=0x05,umask=0xcf` — but
  **64 B per CAS**, confirmed from that PMU's own
  `cas_count_read.scale` of 6.103515625e-5 MiB.

  > **8, not the 4 in `machine_spec_analysis.md`'s unit table.** Validated
  > against a known quantity: a 1-thread DDR run moved 200.00 GB and each of
  > the 8 boxes on S0 counted ~417.8 M CAS, i.e. 8 x 417.8M x 64 B = 213.9 GB.
  > Four boxes would give 107 GB — less than the program provably moved. This
  > is a PMU-instance count, so it is 8 channels (4 controllers x 2), which is
  > also what the DIMM population implies: 128 GB per socket in 16 GB DIMMs is
  > 8 channels, and 8 x 8 B x 4800 MT/s is the 307 GB/s that document already
  > uses.

Rates come from each row's own `run_ns`, not from wall time:
`GB/s = bytes_per_cas * boxes * sum(count) / sum(run_ns)`. 3 repetitions per
point, 20 ms perf intervals, counters read only between the program's own
`Start/End perf collection` markers.

### Two things that had to be fixed to get honest numbers

**Footprint.** The other collectors in this directory pass a constant 128 MB per
thread. Held constant across a core sweep that is not a constant experiment: at
1 thread, 128 MB sits inside the socket's 75 MB L3 + 2 MB L2 and a third of the
accesses never reach memory. Measured at 1 thread: **13.95 GB/s over 128 MB,
12.73 over 512 MB, 12.15 over 2 GB.** This sweep therefore targets a fixed
**16 GB total** footprint split across the threads, capped at 2 GB per thread so
the 1- and 2-thread runs finish (bandwidth.c always makes 100 passes). Every
point has at least 2 GB live, i.e. cache is under 4% of it.

**Peak interval, not run median, past 32 threads.** From 33 to 63 threads the
placement is unbalanced — at 33, one core runs two threads and 31 run one.
bandwidth.c gives every thread equal fixed work, so the paired threads take ~2x
as long and the machine idles while they straggle. The run median collapses
(353.6 -> 324.5 GB/s from 32 to 33 threads) while the peak interval, sampled
while every thread is still running, keeps rising (368.6 -> 369.2). The figure
plots the peak with the median shaded beneath; the band's width *is* the
straggler artifact. At the balanced points (1-32 and 64) the peak sits a uniform
~4% above the median. This is the same trap flagged in `machine_spec_analysis.md`
section 4 — "the run-average ... is an artifact, not a result".

### Where hyperthreading starts: thread 33, verified

`bandwidth.c:671` pins thread *t* to the *t*-th cpu of the node in ascending cpu
order. Node 0 enumerates as `0,2,...,62` then `64,66,...,126`. The first 32 are
32 distinct `thread_siblings` groups; cpu 64 — thread 33 — is the sibling of
cpu 0. Confirmed against the pinning lines in the 64-thread run log, and at
t=33 the placement is exactly 31 cores with one thread and 1 core with two.

**So every point up to 32 is one thread per physical core.** The per-core droop
below is not hyperthreading.

## 2. The data (HBM read, peak 20 ms interval, 3 reps)

| threads | GB/s | per thread | % of fixed-slice | marginal per added thread |
|---|---|---|---|---|
| 1 | 13.0 | 12.96 | 100.0% | 12.96 |
| 2 | 25.7 | 12.87 | 99.3% | 12.77 |
| 4 | 51.0 | 12.75 | 98.4% | 12.64 |
| 8 | 101.2 | 12.65 | 97.6% | 12.59 |
| 12 | 150.3 | 12.52 | 96.6% | 12.28 |
| 16 | 197.8 | 12.36 | 95.3% | 11.87 |
| 24 | 286.6 | 11.94 | 92.1% | 11.07 |
| 32 | 368.6 | 11.52 | 88.9% | 9.84 |
| 40 | 383.8 | 9.59 | 74.0% | 1.89 |
| 48 | 398.7 | 8.31 | 64.1% | 1.86 |
| 56 | 410.0 | 7.32 | 56.5% | 1.41 |
| 64 | **424.3** | 6.63 | **51.1%** | 1.79 |

DDR read control (node 0 -> node 0), same cores, same fabric:

| threads | 1 | 8 | 16 | 24 | 32 | 48 | 64 |
|---|---|---|---|---|---|---|---|
| GB/s | 14.5 | 107.3 | 185.9 | 221.7 | 230.7 | 232.0 | 231.6 |
| marginal | 14.50 | 12.50 | 8.66 | 3.23 | 0.63 | 0.01 | 0.01 |

HBM write (read+write traffic at the controllers; a store misses, so the line is
fetched by RFO and later written back, and the DRAM moves ~2x what the program
stores): 29.2 GB/s at 1 thread rising to **693 GB/s** at 64.

## 3. What the shape says

**The single-core point is core-limited, and the number works out exactly.**
12.96 GB/s at 137.7 ns local HBM latency (MLC, `machine_spec_analysis.md`
section 3) is `12.96 * 137.7 / 64` = **27.9 lines in flight** — a core's
outstanding-miss capacity, not anything about memory. One core cannot saturate
HBM and was never going to: it would need 28 x the concurrency.

**The droop starts at the second core.** 12.96 -> 12.87 -> 12.75 -> 12.65 by 8
threads. Nothing is shared between those cores except the fabric and the memory,
and at 101 GB/s neither is anywhere near capacity. A fixed per-core allocation
would hold flat here; it does not.

**Hyperthreading is not what flattens the curve** — the curve is already at 88.9%
of linear at 32 threads, with every thread on its own core. What SMT does is
expose how little headroom is left: 32 more threads buy 56 GB/s (+15%), i.e.
1.75 GB/s each against the first core's 12.96.

**The droop tracks aggregate bandwidth, not core count.** Every point above uses
`prefetcht1` with lookahead 64, the fastest access on this machine. The whole
sweep repeated with plain loads (series `hbm_read_load` in the json, drawn
dashed in the figure) gives the sharpest single piece of evidence here:

| threads | `prefetchT1` GB/s | per thread (% of its 1-thread rate) | plain `load` GB/s | per thread (% of its 1-thread rate) | t1 gain |
|---|---|---|---|---|---|
| 1 | 13.0 | 12.96 (100%) | 8.4 | 8.40 (100%) | +54% |
| 8 | 101.2 | 12.65 (98%) | 65.7 | 8.21 (98%) | +54% |
| 12 | 150.3 | 12.52 (**97%**) | 100.0 | 8.33 (99%) | +50% |
| 16 | 197.8 | 12.36 (95%) | 132.4 | 8.28 (98%) | +49% |
| 20 | 242.4 | 12.12 (93%) | 164.2 | 8.21 (98%) | +48% |
| 24 | 286.6 | 11.94 (92%) | 195.6 | 8.15 (**97%**) | +47% |
| 32 | 368.6 | 11.52 (89%) | 254.7 | 7.96 (95%) | +45% |
| 64 | 424.3 | 6.63 (51%) | 327.1 | 5.11 (61%) | +30% |

Plain loads hold a **genuinely fixed per-core slice out to 20 threads** — 8.40
down to 8.21 GB/s, under 3% — where prefetcht1 has already given up 7% by 20 and
is visibly bending by 12. The two curves lose their first 3% at **12 threads /
150 GB/s** and **24 threads / 196 GB/s** respectively: twice the core count, but
only a third more bandwidth.

That is the distinction the whole question turns on. A limit that lived in the
cores, or an allocation policy per core, would bend at a core count. Neither
predictor is exact here — 2x apart in cores, 1.3x in GB/s — but bandwidth is
much the better one, and a core that pulls 1.5x harder reaches the bend with
roughly half as many cores. The per-core slice is fixed right up until the
shared resource notices, and when that happens depends mostly on how much
total traffic is flowing through it.

The gap between the two also names the per-core mechanism: plain loads sustain
~18 outstanding lines (near the 16 L1 fill buffers), prefetching into L2
sustains ~28 — the mechanism `machine_spec_analysis.md` section 3 gives for the
same effect at 64 threads, confirmed here at 1 thread where nothing is shared.
And the advantage decays as the socket fills (+54% at 8 threads, +30% at 64):
once the fabric is the constraint, feeding it harder per core buys less.

Two practical consequences: the droop is **not** an artifact of prefetching
(both instructions saturate; load falls to 61% of its own 1-thread rate by 64
threads, t1 to 51%), and t1 is the right choice for measuring the ceiling —
plain loads would have put it at 327 GB/s, 23% low.

**The ceiling is not the HBM devices.** 424 GB/s is 52% of the 819 GB/s the
channels could carry, and the *same cores on the same fabric* push **693 GB/s**
once writes are in the mix. A limit in the memory could not be 63% higher for
one traffic mix than another.

**The ceiling is not shared with DDR's ceiling, but the shape is the same.** DDR
saturates hard and completely at ~232 GB/s (marginal 0.01 GB/s per thread by 48
threads); HBM is still gaining 1.8 at 64. Two different memory systems, two
different ceilings, both bending well before their own theoretical maximum and
both bending in the same core-count region.

## 4. What this does and does not establish

This sweep establishes **that** the socket saturates, **where** it starts
(~8-12 threads, ~150 GB/s), and **how much** each core is actually worth at each
point. It does **not**, on its own, uniquely localise the bottleneck — a
saturating curve is consistent with any shared resource.

The localisation is already done in
[`machine_spec_analysis.md`](machine_spec_analysis.md) section 4, by experiments
this sweep cannot substitute for:

- adding a *second socket's* 64 cores to node 2 does not raise it above ~430
  GB/s — the requesters are not the constraint;
- splitting cores between DDR and HBM yields 428 GB/s total, exactly what either
  reaches alone — two independent memory systems, one ceiling;
- the HBM read queue holds **0.79 entries** and drains in 9 ns — the controllers
  are starved, not backed up;
- the CHAs hold 6.5 read misses on average and never exceed ~24 — not a tracker
  shortage.

What is left there, and what this curve is consistent with, is **the socket's
mesh read-return path**. This sweep adds the part that analysis lacked — it had
only 32 vs 64 threads, and so could not show that the departure from linearity
begins at a *seventh* of the ceiling rather than at it.

### 4a. On the "~215 B per mesh cycle" figure, which does not survive checking

That document states the mesh "runs at **1.994 GHz** (4.318 G CHA clockticks
over a 2.166 s run), so 430 GB/s is **~215 bytes per mesh cycle**". Two things
are worth being clear about.

**It is arithmetic, not an independent limit.** 215 B/cycle is the observed
bandwidth divided by a clock. Nobody derived the mesh's structural width — rings
x bytes per cycle per link — and showed that 215 saturates it. The claim that
the mesh is the bottleneck rests on the *elimination* argument above (not the
DRAM, not the controllers, not the cores, not the CHA trackers), which is
strong; the bytes-per-cycle figure adds no evidence to it, it just restates the
ceiling in different units.

**And the clock it divides by is not a constant.** Measuring `uncore_cha`
clockticks across this sweep (all 40 boxes on socket 0, 100% counter running,
every box within 0.001 GHz of every other):

| threads | 1 | 8 | 16 | 32 | 64 | idle |
|---|---|---|---|---|---|---|
| mesh clock (GHz) | 2.494 | 2.380 | 2.154 | 1.864 | 1.854 | 2.495 |
| B per mesh cycle | 5.2 | 42.5 | 91.8 | 197.8 | 228.9 | — |

**The mesh clock falls 26% under load** — and it does so while
`/sys/devices/system/cpu/intel_uncore_frequency/package_00_die_00` is pinned at
`min_freq_khz = max_freq_khz = 2500000`, so the request is being overridden,
presumably by a package power limit with 32 cores held at 2.7 GHz. The 1.994 GHz
in the older document is a loaded measurement reported as a machine constant; it
sits inside the range measured here but is not a property of the machine.

Two consequences. First, bytes-per-mesh-cycle is **still rising at 64 threads**
(197.8 -> 228.9), so the socket is not sitting against a fixed
bytes-per-mesh-cycle wall; if 215 were structural we would already be past it.
Second, and more interesting for this sweep: **some of the per-core droop is the
fabric getting slower, not just busier.** From 1 to 32 threads the mesh loses 25%
of its clock while per-thread bandwidth loses 11%. That does not explain the
saturation on its own — from 32 to 64 the clock is flat (1.864 -> 1.854) while
per-thread bandwidth still halves — but any account of the ceiling that treats
the fabric clock as fixed is incomplete.

Pinning the uncore clock is the experiment that would separate the two, and the
sysfs knob above does not achieve it on this machine.

A caveat worth keeping: `bandwidth.c`'s `cycles per access` is
`elapsed_cycles / accesses`, i.e. algebraically the reciprocal of that thread's
throughput (`64 B * 2.7 GHz / cpa` reproduces the per-thread GB/s). It is in the
json and it tracks the droop, but it is **not** an independent latency
measurement and is not evidence of queueing on its own. Real loaded-latency and
queue-occupancy evidence is in `machine_spec_analysis.md` section 4b.

## 5. Consequences for DRAMHiT

- **Past ~16 threads per socket, extra cores stop buying read bandwidth.** A
  probe phase scaled from 16 to 32 threads gains 86%; from 32 to 64, 15%. If
  those cores have anything else to do, that is where to put them.
- **Budget per-core read bandwidth by where you are on the curve**, not from the
  single-thread number: 12.96 GB/s at 1 thread, 11.52 at 32, 6.63 at 64.
- **Mixed read/write phases use the hardware far better than pure reads** — 693
  vs 424 GB/s on identical cores. Interleaving inserts with probes is not just
  convenient, it is measurably cheaper per byte moved.
- **HBM's advantage over DDR is 1.8x, not the 2.7x the channel counts suggest**
  (424 vs 232), and it only appears past ~12 threads: at 8 threads HBM and DDR
  are within 6% of each other (101 vs 107 GB/s — DDR is *ahead*, its latency
  being 24% lower).

## 6. Reproducing

```bash
# machine setup (2.7 GHz fixed, turbo/C-states off, prefetchers off, hugepages)
cd /opt/DRAMHiT && ./scripts/setup_hbm.sh
sudo env PATH="$PATH" ./scripts/prefetch_control.sh off   # last step needs root

# the sweep needs ~16 GB of 2 MB hugepages on each node under test
for n in 0 2; do echo 9216 | sudo tee \
  /sys/devices/system/node/node$n/hugepages/hugepages-2048kB/nr_hugepages; done

cd scripts/eurosys_2026/machine_stats && make
cd ../intel_hbm

python3 collect_cpu_scaling.py                      # all 3 series, ~25 min
python3 collect_cpu_scaling.py --series hbm_read --threads 33 34 36
python3 collect_cpu_scaling.py --series hbm_read --inst load   # comparison curve
python3 plot_cpu_scaling.py

# mesh clock vs load (section 4a) -- all 40 CHA boxes, clockticks is event 0x01
CHA=$(for i in $(seq 0 39); do printf "uncore_cha_%d/event=0x01,umask=0x00,name=clk/," $i; done | sed 's/,$//')
sudo perf stat --per-socket -e "$CHA" -x, -- ../machine_stats/build/bandwidth_rand \
    -m 256mb -pattern "n0a2t64" -freq 2.7 -inst t1 -lookahead 64 -mode r
# per-box GHz = ticks / run_ns; compare against sleep 3 for the idle clock
```

`--series` / `--threads` / `--reps` all merge into the existing json, so one
point can be re-run without redoing the sweep.

> Collection is dominated by the low-thread points: `bandwidth.c` hardcodes
> `NUM_ITERATIONS 100`, so a run costs `chunk x 100 / per-thread bandwidth` —
> ~16 s at 2 GB/thread versus ~4.5 s at 256 MB. Five of the fifteen points eat
> 60% of the wall time. Guarding that `#define` with `#ifndef` would let a
> shorter variant be built and cut the sweep ~5x.
