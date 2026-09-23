# Does a core buy a fixed slice of HBM bandwidth? Core-count sweep, Intel Xeon CPU Max 9462

Collected 2026-09-23 on the Xeon CPU Max 9462 described in
[`../intel_hbm/machine_spec_analysis.md`](../intel_hbm/machine_spec_analysis.md):
2x 32 cores / 64 threads, 128 GB DDR5 per socket, and **64 GB of HBM2e per socket
exposed as cpu-less NUMA nodes 2 and 3** (flat mode, not cache mode).

Cpus on node 0, memory bound to **node 2** — socket 0's own HBM, so nothing
crosses UPI and the only variable is how many cores are pulling. This is the
same question [`cpu_scaling_analysis_amd.md`](cpu_scaling_analysis_amd.md) asks
of the EPYC's DDR5 and [`collect_cpu_scaling_intel.py`](collect_cpu_scaling_intel.py)
asks of the 6548Y's, carried to the one tier in this fleet whose channels are
not the obvious suspect: 32 HBM channels per socket could carry 819 GB/s.

Data: [`intel-max9462_hbm_cpu_scaling.json`](intel-max9462_hbm_cpu_scaling.json) ·
figures: [`intel-max9462_hbm_cpu_scaling.png`](intel-max9462_hbm_cpu_scaling.png),
[`intel-max9462_hbm_cpu_scaling_prog.png`](intel-max9462_hbm_cpu_scaling_prog.png) ·
collector: [`collect_cpu_scaling_intel_hbm.py`](collect_cpu_scaling_intel_hbm.py) ·
plotter: [`plot_cpu_scaling_intel_hbm.py`](plot_cpu_scaling_intel_hbm.py)

Twelve series, 12 thread counts, 3 reps, every run measured at the 32
`uncore_hbm_*` boxes. `read_load`/`t0`/`t1` and `write_load`/`prefetchw`/`ntstore`
are exactly the 6548Y set, and the full twelve now match
[`collect_cpu_scaling_amd.py`](collect_cpu_scaling_amd.py) series for series, so
all three machines' jsons line up.

| | instructions |
|---|---|
| **rand read** | `load` (no sw prefetch), `prefetcht0`, `prefetcht1`, `prefetcht2`, `prefetchnta`, `prefetchw` |
| **1r1w store** | `load`, `prefetchw`, `prefetcht0`, `prefetcht1`, `prefetcht2`, `ntstore` (full-line non-temporal = 0r1w control) |

## 0. Answers

| question | answer |
|---|---|
| Does a core buy a fixed slice? | **No.** At 64 threads the socket delivers **51%** of what its 1-thread slice extrapolates to (424 vs 832 GB/s with `prefetcht1`). |
| Where is the read ceiling? | **424-427 GB/s** — 52% of the 819 GB/s the HBM channels could carry. §2 |
| Does the access instruction matter? | Enormously, and it is the *only* source of MLP here: `t1`/`t2` **+30%** over plain loads at 64 threads, +51% at 1 thread. `t0` sits between. §2 |
| Is `prefetchw` worth it on a *read* stream? | **No — it is the worst hint of the six**, 0.65x plain loads. Asking for a line in Modified state costs even when nothing is written. AMD agrees in sign (0.94x). §3 |
| Is `prefetchnta` ever worth it? | **No, it is actively harmful** — the only series that *falls* past 32 threads, and it moves **1.46x** the HBM traffic the program consumes. §3 |
| Does `prefetchw` help stores? | **Essentially not: +2.8%.** Same answer the EPYC gives. §4 |
| What does help stores? | **`prefetcht1`/`t2`: 1.85x** the HBM traffic of a plain store (691 vs 375 GB/s). The RFO half of a store is a read, so stores want the same L2 prefetch reads do — not `prefetchw`. §4 |
| What if you only count useful bytes? | Then **`ntstore` wins: 2.33x** (392 vs 168 GB/s stored), because it never fetches the line. Two metrics, two different winners. §4 |
| Is the ceiling the memory? | **No.** Stores sustain **691 GB/s** where reads stop at 427 — **62% higher**, on the same cores, fabric and HBM. §5 |
| Does SMT help? | For reads yes (+14% from 32 to 64 threads). For **stores, nothing** (+0.8% plain, +2.5% with `t1`) — they are done at 32. §4 |

## 1. Method, and two things that had to be fixed

`machine_stats/bandwidth.c` built for random access, lookahead 64, hardware
prefetchers off, cores pinned at 2.7 GHz (`scripts/setup_hbm.sh`).

**HBM is not `uncore_imc`.** perf enumerates the HBM controllers off the uncore
discovery table, so they carry no event list and need raw codes — CAS is
`event=0x05`, `umask=0xcf` (rd) / `0xf0` (wr). There are **32 boxes per socket**
and perf does not merge them, so each event returns 32 rows that must be summed,
and **an HBM CAS moves 32 B, not 64**. Rates come from each row's own `run_ns`,
not the timestamp delta.

> A trap worth naming: `uncore_hbm_free_running_*` also matches a
> `uncore_hbm_*` glob *and* ends in a digit. Matching a trailing number alone
> double-counts those boxes, and the failure is silent — it simply reports twice
> the real bandwidth. The collector matches the name to the end.

**Footprint.** A per-thread size held constant across a core sweep is not a
constant experiment: at 1 thread the 128 MB the other collectors pass sits inside
this socket's 75 MB L3 + 2 MB L2 and a third of the accesses never reach HBM.
Measured at 1 thread: **13.95 GB/s over 128 MB, 12.73 over 512 MB, 12.15 over
2 GB.** This sweep targets a fixed **16 GB total**, capped at 2 GB per thread so
the 1- and 2-thread runs finish (bandwidth.c always makes 100 passes).

**Peak interval, not run median, past 32 threads.** From 33 to 63 the placement
is unbalanced — at 40 threads, 8 cores run two threads and 24 run one. With fixed
work per thread the paired threads take ~2x as long and the machine sits nearly
idle while they straggle. `..._prog.png` shows the damage plainly: *every* series
dips at 40 threads and recovers by 64. The peak interval samples the machine
while all threads are still running and is monotone across the whole sweep; at
the balanced points (1..32 and 64) the two agree within a few percent.

**Where SMT starts: thread 33, verified.** `bandwidth.c` pins thread *t* to the
*t*-th cpu of the node in ascending order; node 0 is cpus `0,2,...,62` then
`64,66,...,126`. The first 32 are 32 distinct `thread_siblings` groups, and cpu
64 — thread 33 — is the sibling of cpu 0, confirmed against the pinning lines in
a 64-thread run log. So every point up to 32 is one thread per physical core, and
the per-core droop below is **not** hyperthreading.

## 2. Reads: the instruction sets the height, the socket sets the ceiling

Peak HBM GB/s:

| threads | `load` | `t0` | `t1` | `t2` | `nta` | `prefetchw` |
|---|---|---|---|---|---|---|
| 1 | 8.6 | 11.2 | 13.0 | 13.0 | 9.5 | 7.2 |
| 8 | 65.8 | 87.0 | 101.4 | 100.4 | 72.0 | 55.3 |
| 16 | 132.5 | 175.2 | 197.2 | 197.5 | 137.8 | 109.3 |
| 32 | 255.3 | 326.5 | 370.6 | 369.3 | 255.6 | 212.1 |
| 64 | **327.3** | **362.1** | **424.3** | **427.2** | **240.8** | **213.4** |
| vs `load` at 64 | 1.00x | 1.11x | 1.30x | 1.31x | 0.74x | **0.65x** |
| % of a fixed slice at 64 | 59.5% | 50.5% | 51.0% | 51.3% | 39.6% | 46.3% |

`t1` and `t2` are indistinguishable (424.3 vs 427.2, 0.7% apart) and both beat
`t0` by 17% and plain loads by 30%. That ordering is the L2 story: prefetching
into L2 lets a core track more outstanding misses than the 16 L1 fill buffers,
and at 1 thread the gap is +51% (13.0 vs 8.6 GB/s) — pure per-core concurrency,
with nothing shared yet.

**Per-core efficiency at a given core count falls fastest for the instruction
that pulls hardest** (per-thread rate as % of that series' own 1-thread rate):

| threads | `load` | `t0` | `t1` | `t2` |
|---|---|---|---|---|
| 8 | 95.6% | 97.1% | 97.5% | 96.5% |
| 16 | 96.3% | 97.8% | 94.8% | 95.0% |
| 32 | **92.8%** | **91.1%** | **89.1%** | **88.8%** |

**At 32 threads** the ordering is exactly inverse to per-core demand: the harder
an instruction pulls, the smaller the share of it the core actually gets
(8.6 GB/s -> 92.8%, 11.2 -> 91.1%, 13.0 -> 89.1/88.8%). That is what a shared
resource does and what a per-core allocation would not. At 8 and 16 threads the
ordering is not yet established — everything is within ~3% of its own linear
line, which is inside the run-to-run spread, so the table above should not be
read as a trend there. The finer-grained version of this comparison — plain loads
holding a genuinely fixed slice out to 20 threads where `t1` is bending by 12 —
is in the earlier sweep preserved as
[`intel-max9462_hbm_vs_ddr.json`](intel-max9462_hbm_vs_ddr.json), which also
carries the DDR control this HBM-only collector drops (DDR saturates flat at
~232 GB/s).

## 3. The two ways a read hint can lose, and they are not the same

`nta` and `prefetchw` are both net losses against issuing no prefetch at all —
0.74x and 0.65x — but the counters show they fail for different reasons.

**`prefetchnta` wastes traffic.** It is the only series that *goes down* with
threads (255.6 GB/s at 32, 240.8 at 64), and its amplification — HBM bytes per
byte the program consumed — is far off everything else:

| | `load` | `t0` | `t1` | `t2` | `prefetchw` | `nta` |
|---|---|---|---|---|---|---|
| amplification @32 | 1.10x | 1.13x | 1.14x | 1.17x | 1.12x | **1.46x** |
| amplification @64 | 1.11x | 1.13x | 1.16x | 1.16x | 1.12x | **1.61x** |

NTA places the line so it is evicted quickly rather than retained, so a
meaningful fraction of what it prefetches is gone before the demand load arrives
and has to be fetched twice. Adding threads makes it worse, because the other
threads' NTA traffic evicts it sooner — hence the only downward-sloping curve on
the figure, and the only amplification that *grows* with thread count. The prior
comparison in `machine_spec_analysis.md` (nta worst of six, in program
bandwidth) recorded the symptom; the 1.46 -> 1.61x is the mechanism.

**`prefetchw` wastes none — it is simply slower.** Its amplification is 1.12x,
right alongside plain loads, so every byte it fetches is a byte the program uses.
The whole of its 35% deficit is in the *rate*: 7.2 GB/s per core against 8.6
unprefetched. Asking for a line in Modified state when the stream never writes
buys an ownership transaction and no concurrency, so it costs latency in the
request path rather than bandwidth on the bus.

### The same question on the EPYC

[`amd-9354p_cpu_scaling.json`](amd-9354p_cpu_scaling.json) runs the identical six
read series on an EPYC 9354P against DDR5 (max GB/s, relative to its own `load`):

| | `load` | `t0` | `t1` | `t2` | `nta` | `prefetchw` |
|---|---|---|---|---|---|---|
| Xeon Max 9462 (HBM) | 1.00x | **1.11x** | 1.30x | 1.31x | 0.74x | 0.65x |
| EPYC 9354P (DDR5) | 1.00x | **0.94x** | 1.38x | 1.38x | 0.95x | 0.94x |

Three things carry across both vendors: **`t1`/`t2` are the only hints that ever
help** (+30% / +38%), they are **indistinguishable from each other** on both, and
**`prefetchw` on a read stream is a loss** on both.

Where they differ is instructive. On the EPYC, `t0`, `nta` and `prefetchw` land
on 0.94, 0.95 and 0.94 — within noise of each other and all slightly *below*
baseline, i.e. that part collapses every non-L2 hint into the same
slightly-harmful behaviour. The Xeon separates them: `t0` genuinely helps
(1.11x), while `nta` and `prefetchw` hurt by distinct amounts through the two
distinct mechanisms above. The Xeon also punishes the wrong hint far harder
(0.65x against 0.94x), so on this machine the instruction choice is worth 2x
between best and worst, against 1.5x on the EPYC.

## 4. Stores: the RFO is a read, so stores want a read prefetch

An 8 B store into a 64 B line is two DRAM transactions — the line is fetched
(RFO) and written back later — so the controllers move about twice what the
program stores. **The fetch half is an ordinary read**, which is why the hint
that matters for stores is the one that matters for reads, and why `prefetchw`
— the write-specific hint — is nearly useless here.

Peak HBM traffic / bytes the program actually stored, GB/s:

| threads | `load` | `prefetchw` | `t0` | `t1` | `t2` | `ntstore` |
|---|---|---|---|---|---|---|
| 16 | 201 / 91 | 208 / 94 | 320 / 145 | 408 / 182 | 409 / 181 | 320 / 269 |
| 32 | 372 / 165 | 382 / 169 | 512 / 226 | 674 / 276 | 678 / 278 | 486 / 386 |
| 64 | 375 / **168** | 385 / **173** | 616 / **269** | **692** / 299 | **691** / 300 | 484 / **392** |
| vs `load` (HBM) | 1.00x | 1.03x | 1.64x | **1.85x** | **1.85x** | 1.29x |
| vs `load` (stored) | 1.00x | 1.03x | 1.60x | 1.78x | 1.78x | **2.33x** |
| amplification | 2.23x | 2.23x | 2.29x | 2.31x | 2.31x | **1.23x** |

- **`prefetchw` buys 2.8%.** It removes the ownership stall, not the transfer;
  the line still has to be fetched. The EPYC sweep reaches the same verdict (0%
  there), so this is not a quirk of one part.
- **`prefetcht1`/`t2` buy 1.85x** — the single largest effect in this table, and
  the one easiest to miss: a write sweep of `load`/`prefetchw`/`ntstore` alone
  never reaches it. They are indistinguishable from each other (691.5 vs 691.4),
  exactly as on the read side.
- **Which one "wins" depends on the metric.** Counting bus traffic, `t1`/`t2`
  (691 GB/s); counting bytes the application actually stored, `ntstore` (392 vs
  300). NT stores move 1.23x per store where everything else moves 2.3x, so they
  deliver more useful work per unit of bus — but they need the algorithm to write
  a whole 64 B line.
- **Stores get nothing from SMT.** Plain stores go 371.6 -> 374.5 GB/s from 32 to
  64 threads (+0.8%), `t1` 674 -> 692 (+2.5%), where reads gain 14%. The store
  path is already saturated at one thread per physical core.

> This table is why an earlier version of this sweep disagreed with
> `machine_spec_analysis.md`, which reports **571 GB/s** for read-modify-write.
> That figure was measured with `-inst t1`; a write series of
> `load`/`prefetchw`/`ntstore` tops out at 484 and cannot reproduce it. With
> `t1` in the set the number comes back — 691.5 GB/s here, against 693.2 in the
> earlier sweep preserved as `intel-max9462_hbm_vs_ddr.json`.

## 5. The ceiling is not the memory

Reads stop at 424-427 GB/s — 52% of the 819 GB/s those 32 channels could carry.
On the **same cores, the same fabric, the same HBM**, a 1r1w store stream with
`prefetcht1` sustains **691.5 GB/s**, **62% more**, and even the NT-store control
manages 484. A limit in the channels or the DRAM devices cannot be 62% higher
for one traffic mix than another — and 691.5 GB/s is 84% of the channels'
theoretical 819, so the memory is demonstrably capable of far more than reads
ever extract from it.

That points where [`../intel_hbm/machine_spec_analysis.md`](../intel_hbm/machine_spec_analysis.md)
§4 already points, by experiments this sweep does not repeat: a second socket's
64 cores added to node 2 raise it no further; cores split between DDR and HBM
reach the same total as either alone; and the HBM read queue holds 0.79 entries,
i.e. the controllers are starved rather than backed up. What is left is the
socket's **mesh read-return path**.

> **On the "~215 B per mesh cycle" figure in that document — it does not survive
> checking.** It is arithmetic (observed bandwidth ÷ a clock), not a derived
> structural width, and the clock is not a constant. Measuring `uncore_cha`
> clockticks across load (all 40 boxes on socket 0, 100% counter running, every
> box within 0.001 GHz of the others): **2.494 GHz at 1 thread, 2.154 at 16,
> 1.864 at 32, 1.854 at 64** — a 26% drop, while
> `/sys/devices/system/cpu/intel_uncore_frequency/package_00_die_00` is pinned at
> `min_freq_khz = max_freq_khz = 2500000`, so the request is being overridden
> (presumably a package power limit with 32 cores at 2.7 GHz). Bytes per mesh
> cycle is therefore **still rising at 64 threads** (197.8 -> 228.9), so the
> socket is not against a fixed bytes-per-cycle wall. And some of the per-core
> droop is the fabric getting *slower*, not just busier: from 1 to 32 threads the
> mesh loses 25% of its clock. That does not explain saturation on its own —
> from 32 to 64 the clock is flat while per-thread bandwidth still halves — but
> any account treating the fabric clock as fixed is incomplete. Pinning the
> uncore clock would separate the two; the sysfs knob does not achieve it here.

## 6. Consequences for DRAMHiT

- **Probe (read) phases: budget ~424 GB/s per socket**, and stop adding threads
  past ~32. 16 -> 32 threads gains 87%; 32 -> 64 gains 14%.
- **Always prefetch into L2.** `t1`/`t2` are worth 30% over plain loads at full
  occupancy and 51% at low thread counts. `t0` leaves 17% on the table.
- **Never `prefetchnta`** for data that will be read: it costs 1.46-1.61x the
  memory traffic and gets *worse* with more cores.
- **Never `prefetchw` for a read-only stream** either — worst of the six here at
  0.65x plain loads. It wastes no traffic (1.12x, normal), it is just slower:
  an ownership transaction bought for nothing. The EPYC agrees in sign.
- **Prefetch into L2 for insert phases too, not just probes.** `prefetcht1`
  ahead of a store is worth **1.78x** the bytes stored over an unprefetched
  store loop — the RFO is a read and wants the same treatment. `prefetchw` is
  not worth the instruction slot (+3%).
- **Where a whole 64 B line can be written, full-line NT stores beat even that:
  2.33x**, because they are the only option here that changes bytes-on-the-bus
  (1.23x amplification against 2.31x) rather than just hiding latency.
- **Do not size store phases by core count past 32** — the store path saturates
  exactly at one thread per physical core.

## 7. Reproducing

```bash
# machine setup (2.7 GHz fixed, turbo/C-states off, prefetchers off, hugepages)
cd /opt/DRAMHiT && nix-shell --run './scripts/setup_hbm.sh'
nix-shell --run 'sudo env PATH="$PATH" ./scripts/prefetch_control.sh off'
echo 9216 | sudo tee \
  /sys/devices/system/node/node2/hugepages/hugepages-2048kB/nr_hugepages

nix-shell --run 'make -C scripts/eurosys_2026/machine_stats'
cd scripts/eurosys_2026/collect_scalability

python3 collect_cpu_scaling_intel_hbm.py --dry-run     # 288 runs, ~1 h
python3 collect_cpu_scaling_intel_hbm.py
nix-shell --run 'python3 plot_cpu_scaling_intel_hbm.py intel-max9462_hbm_cpu_scaling.json'
nix-shell --run 'python3 plot_cpu_scaling_intel_hbm.py intel-max9462_hbm_cpu_scaling.json --metric prog'

# mesh clock vs load (section 5) -- all 40 CHA boxes, clockticks is event 0x01
CHA=$(for i in $(seq 0 39); do printf "uncore_cha_%d/event=0x01,umask=0x00,name=clk/," $i; done | sed 's/,$//')
sudo perf stat --per-socket -e "$CHA" -x, -- ../machine_stats/build/bandwidth_rand \
    -m 256mb -pattern "n0a2t64" -freq 2.7 -inst t1 -lookahead 64 -mode r
# per-box GHz = ticks / run_ns; compare against `sleep 3` for the idle clock
```

> Collection is dominated by the low-thread points: `bandwidth.c` hardcodes
> `NUM_ITERATIONS 100`, so a run costs `chunk x 100 / per-thread bandwidth` —
> ~16 s at 2 GB/thread against ~4.5 s at 256 MB, and proportionally worse for the
> slower instructions. Guarding that `#define` with `#ifndef` would let a shorter
> variant be built and cut the sweep several-fold.
