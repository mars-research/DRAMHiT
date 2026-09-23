# Does a core buy a fixed slice of DDR5 bandwidth? Core-count sweep, AMD EPYC 9354P

Collected 2026-09-21 on the AMD box this repo's `collect_bw/`, `macro_uniform/amd/`
etc. already run on: 1x **AMD EPYC 9354P** (Zen4 "Genoa"), 32 cores / 64 threads,
booted **NPS4** — the BIOS splits the single socket into 4 NUMA nodes, each with its
own 8 cores and its own 3 DDR5-4800 channels (24x 16 GB DIMMs, 2 per channel, 12
channels total):

```
node 0: cpus 0-7,32-39     node 1: cpus 8-15,40-47
node 2: cpus 16-23,48-55   node 3: cpus 24-31,56-63
```
(0-31 physical, 32-63 their SMT siblings; cpu *N* and *N+32* share a core.)

This is the same question `collect_cpu_scaling_intel_hbm.py` asks — does each added
core buy a fixed slice of bandwidth, or does something shared saturate first — carried
over to hardware with no HBM tier and no second socket to hold a control against. The
analogous "shared thing" here is the single Infinity Fabric all 4 memory controllers
sit behind.

Data: [`amd_cpu_scaling.json`](amd_cpu_scaling.json) ·
figure: [`amd_cpu_scaling.png`](amd_cpu_scaling.png) ·
collector: [`collect_cpu_scaling_amd.py`](collect_cpu_scaling_amd.py) · plotter:
[`plot_cpu_scaling_amd.py`](plot_cpu_scaling_amd.py)

Two series, both `machine_stats/bandwidth.c` (random access, `prefetcht1`, lookahead
64, private per-thread buffers, no sharing):

| series | cores used | what it isolates |
|---|---|---|
| `node_local` | node 0 only, 1-16 threads (its 8 physical cores, then their 8 SMT siblings) | one memory controller triad's own ceiling |
| `system_local` | all 4 nodes, thread *i* -> node *i%4* (every node gains a thread in turn, physical cores first), 1-64 threads | the whole machine, every controller loaded from its own local cores |

Every `system_local` point on the main grid (4, 8, 12, ..., 64) puts an **equal**
thread count on every active node, so — unlike the Intel sweep, whose 1-thread steps
land one node's placement unevenly right at its SMT boundary — there is no straggler
artifact here to plot around. Median across 3 reps is reported directly.

## 0. Answer

**Yes, up to about one thread per physical core (8/node, 32 machine-wide) — and past
that point, the ceiling is per-channel, not per-fabric.** The `system_local` curve
tracks `node_local` almost exactly at every thread-per-node level (see the figure:
the two lines sit on top of each other from 1 thread through 16), which means running
all 4 controllers at once neither helps nor hurts any one of them — **the single
Infinity Fabric linking them is not the bottleneck anywhere on this sweep.**

| regime | threads/node | per-node GB/s | machine GB/s (x4) | what limits it |
|---|---|---|---|---|
| linear | 1 - 4 | 25.0 -> 49.6 (~99% of linear at 4) | 100.5 | a core's own outstanding-miss capacity |
| bending | 4 - 8 | 49.6 -> 83.3 (81% of linear at 8) | 326.3 | the per-CCD fabric link — see correction below |
| saturated | 8 - 16 (SMT) | 83.3 -> ~91, +-10% noise | 360-367, flat | the same 3 channels — SMT buys ~0 |

> **Correction (2026-09-21), from the denser sweep in
> [`local_interleave_analysis.md`](local_interleave_analysis.md) §1.** The "bending"
> row's mechanism is wrong. Each NPS4 node is **2 CCDs of 4 cores**, and `bandwidth.c`
> fills a node's cpus in ascending order, so 1-4 threads/node sit entirely on that
> node's *first* CCD — confirmed with `amd_df` per-CCD port counters, which show
> ccm4-ccm7 completely idle at 4 threads/node. The flattening at ~50 GB/s/node in that
> regime is that one CCD's fabric link saturating, not the node's channels: bandwidth
> resumes climbing as soon as the second CCD is engaged at thread 5. This sweep's
> thread grid (1, 2, 4, 6, 8, ...) steps straight over the plateau, which is why it
> reads here as a smooth bend. The rows above and below, and everything in the rest of
> this document, are unaffected.

Machine-wide peak observed: **366.7 GB/s** at 40 threads (10/node). Per-channel
theoretical peak at this box's configured 4800 MT/s is 38.4 GB/s, so 12 channels give
460.8 GB/s — the sweep reaches **79.6%** of that, and one node alone reaches
**79.1%** of its 3-channel, 115.2 GB/s share. Those two efficiency numbers agreeing
to within half a point, at completely different scales (3 channels vs. 12), is the
same evidence again: nothing above the channels is taking a cut.

**SMT is worth nothing here.** 8 -> 16 threads/node (physical cores full, add their
siblings) moves the node from 83 to a noisy 78-91 GB/s band — no clean gain, just
run-to-run variance at what is already the channels' ceiling. Machine-wide, the sweep
actually peaks below the top of the SMT range (40 threads, not 64) and 48-64 sit
flat at 361-364 GB/s, a hair under the 40-thread point and well inside its own
variance.

## 1. The measurement

Built with `make build/bandwidth_rand` in `machine_stats/`. Read at the DRAM
controllers via **`amd_umc_<N>`** (12 instances — 3 per NUMA node), not from the
program's own byte count, the same principle the Intel sweep uses and for the same
reason: a number the program computes from its own timer can't tell a real ceiling
from the timer being miscalibrated.

`GB/s = bytes_per_cas * boxes * sum(count) / sum(run_ns)`, boxes/count/run_ns summed
per NUMA node across its 3 UMCs, over the interior 20 ms perf intervals between the
program's own `Start`/`End perf collection` markers (first and last interval are
partial and discarded — same as the Intel collector). 3 reps per point.

### Four things that don't carry over from the Intel sweep, checked rather than assumed

**1. UMC-to-node mapping isn't in sysfs — it had to be measured.** Every
`/sys/devices/amd_umc_*/cpumask` reads `0`: perf just needs one CPU to open the
counter fd on and picks CPU 0 for all 12 boxes regardless of which node's
controller they actually are. That kills both `--per-socket` (one socket, useless)
and `--per-node` (would bucket every uncore box under node 0) — both of which the
Intel sweep leans on for its HBM/DDR split. Instead: pin 8 threads to node 0 only,
watch which `amd_umc_*` counters move. Boxes 0, 1, 2 moved (~2.3B CAS each over a
6.5 s run); boxes 3-11 sat at baseline (~2-4 x10^5, the same as a 3 s idle-system
control). Repeating per node gives the mapping used throughout:
`node n -> amd_umc_{3n, 3n+1, 3n+2}`. Node identity is then threaded through perf's
own `name=` tag per box (`mem_rd_n<node>_b<box>`) and summed back up by node in the
parser — there is no aggregation flag doing it automatically here.

**2. This machine's actual base clock is 3.25 GHz, not the Intel box's 2.7.**
`bandwidth.c -freq` is not measured — it is what you tell the program to divide its
own `rdtsc`-based elapsed-cycle count by. Passing the Intel sweep's 2.7 silently
produces a wrong "Bandwidth :" line (this is exactly the kind of number a PMU
cross-check exists to catch). Cross-checked by comparing the program's own elapsed
cycles against wall-clock time recovered independently from perf's `-I` interval
timestamps on a calibration run: **3.25 GHz agreed to within 0.4%; 2.7 GHz was 17%
off.** 3.25 also matches `collect_bw/collect_threads.sh`'s existing
`-DCPUFREQ_MHZ=3250` for this same box.

**3. `bandwidth.c -pattern` splits groups on a literal space, not a comma.** Its
parser is `strtok(pattern_str, " ")`; a comma only ever separates a memory-node list
*inside* one group (`a0,1` = interleave that group across nodes 0 and 1). A
comma-joined multi-node pattern — `"n0a0t1,n1a1t1,n2a2t1,n3a3t1"`, read naturally off
the Intel script's own docstring example — parses as **one** group and silently
spawns 1 thread total, not 4; every other argument stays valid so nothing errors.
Caught by a sanity check (`system_local` at 4 threads first came back at the same
GB/s as `node_local` at 1 thread, instead of ~4x it) before it could reach the real
sweep. Fixed by space-joining pattern groups in `run_one()`.

**4. CAS width and the footprint budget both needed their own numbers.**
`amd_umc_*/umc_cas_cmd.{rd,wr}` exposes no `.scale`/`.unit` the way Intel's
`uncore_imc` does, so **64 B/CAS** (DDR5, 2x32B sub-channels bursting together) was
checked the same way as the frequency: summing `(rd+wr)*64B` over a calibration run's
interior intervals and comparing to the program's own freq-corrected GB/s. They agree
to within **~8%** across the whole sweep (UMC consistently a bit above prog — Table
in the JSON, `umc_all_gbs` vs `prog_bw_gbs`), the same order of non-demand-traffic gap
(refresh, the prefetcher, partial lines) the Intel report documents between its own
two numbers. Separately, `node_local` gets its own, smaller 6 GB total-footprint
target (vs. `system_local`'s 16 GB): `enable_hugepages.sh` reserves 2 MB hugepages
*per NUMA node* (~8 GB/node here), and a single-node run can't spend another node's
reserved pool.

### One gap this sweep doesn't close

`prog_bw_gbs` increasingly undershoots the UMC number as thread count rises past 32
(ratio ~1.09 at 8 threads, ~1.28-1.37 at 40-48) — more than the steady ~8% baseline
gap. The UMC number is taken as authoritative here (it is read at the DRAM
controllers directly), but *why* the program's own wall-clock accounting degrades
specifically at high SMT-heavy thread counts was not run down; it is left as
recorded data (both numbers are in the JSON per point) rather than explained.

## 2. What's in the figure

`amd_cpu_scaling.png`: left panel, GB/s per node (`node_local`'s one node vs.
`system_local`'s per-node share of its total) against threads-per-node — the two
lines sit on each other the whole way, which is the "no fabric bottleneck" finding
made visual. Right panel, GB/s per thread on the same x-axis — the per-core slice
holds through ~4 threads, then decays continuously, exactly matching the Intel
sweep's own shape (a hard ceiling would instead show a flat region followed by a
sudden drop at a fixed thread count).

Numbers behind both panels, and the full per-node and per-rep breakdown, are in
`amd_cpu_scaling.json`; `config.node_umc_boxes` records the node -> UMC mapping and
`config.bytes_per_cas` / `config.cpu_freq_ghz` record the two calibrated constants
above.
