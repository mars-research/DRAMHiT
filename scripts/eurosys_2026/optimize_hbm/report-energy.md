# Open research 4: instruction swaps by energy, and where the 350 W goes

From `human.md`: if two instruction sequences do the same work and one costs less energy, use
it; build a benchmark that issues one operation in a loop and measure energy per op. This report
does that, and puts the result on the scale of the whole package budget, because the answer
depends on the scale.

**Result in one paragraph.** Light instructions (scalar ALU, loads, stores, compares, shuffles,
prefetches, 512-bit adds and loads) cost about **150–290 pJ each**, within about 2× of one
another, so swapping one for another is worth ≤ 0.3 nJ per find, ~0.4% of the ~83 nJ package
energy per find: smaller than the run-to-run noise of any throughput measurement here. Two
things are far outside that range: a **512-bit integer multiply (~1.7 nJ)** and, above all,
**memory traffic: a 64-byte line costs ~22–25 nJ, about as much as ~100 light instructions**.
So the lever with the most energy in it is fewer lines per find, not different instructions.
Capping the core clock to give the mesh more power does not help (§5).

## 1. Method, and what the numbers are relative to

- **Everything is measured with one perf stream** (`throttling/uncore_sweep.py`'s helper): RAPL
  package energy for socket 0 (`power/energy-pkg/`, per 100 ms interval), and on the busy cpus
  only, cycles, ref-cycles and instructions. The run's power is the median over its settled
  intervals.
- **Instruction classes** (`throttling/spin.c`, `fbfull/energy_classes.py`): register-only
  loops, 8 independent chains unrolled 8× (64 instructions per loop iteration, ~4% loop
  overhead), L1-resident data, one thread per core on 16 cores. Each class is bracketed by
  an idle run before and after (the median of the two idle runs is subtracted), 3 reps.
  16 threads keep nearly every class under the 350 W cap, so core and mesh clocks stay at 2.694
  and 2.494 GHz; 4 of the 45 runs touched the cap and are flagged in the table.
- **All energies are relative to the POLL idle loop.** C-states are disabled on this machine
  (`scripts/constant_freq.sh`), so an "idle" cpu spins in POLL at 2.7 GHz (IPC 0.13) and is not
  free. `dW` is the extra package power when a cpu runs the class instead of POLL; "pJ per
  instruction" is `dW` ÷ the extra instruction rate. These are not absolute per-instruction
  energies.
- **Per-instruction numbers depend on IPC.** A core running at high IPC burns roughly the same
  watts as one at moderate IPC, so pJ per instruction falls as IPC rises (`add`, 148 pJ at IPC
  4.2) and rises as it falls (the 512-bit multiply, IPC 0.58).

## 2. Energy per instruction class

16 threads, 2.694 GHz, median of 3 (min–max):

| class (8 independent chains) | W per cpu | IPC | pJ per instruction | note |
|---|---|---|---|---|
| `add` | 1.61 (1.46–1.62) | 4.17 | **148** (134–149) | |
| `imul` | 0.80 (0.76–0.90) | 1.73 | 187 (176–209) | |
| `crc32q` | 0.97 (0.87–1.00) | 1.99 | 193 (173–199) | |
| 512-bit `vpaddq` / `vpxorq` | 1.12 (1.06–1.18) | 2.32 | 190 (180–200) | |
| store (L1) | 1.16 (1.11–1.26) | 2.21 | 206 (198–225) | |
| `vpcmpeqq` zmm → mask | 1.61 (1.58–1.69) | 3.00 | 208 (205–219) | 1 of 3 runs hit the cap |
| load (L1) | 1.61 (1.58–1.66) | 2.95 | 213 (208–219) | |
| `nop` | 1.69 (1.63–1.73) | 3.00 | 219 (211–224) | |
| `prefetcht0` (L1 hit) | 1.80 (1.79–1.84) | 2.95 | 238 (237–242) | |
| zmm load (L1) | 1.97 (1.59–2.06) | 3.20 | 239 (192–250) | 1 of 3 hit the cap |
| `vpbroadcastq` | 1.92 (1.87–1.92) | 2.92 | 255 (249–256) | |
| ymm `vpaddq` | 1.97 (1.57–2.00) | 2.97 | 257 (205–261) | 1 of 3 hit the cap |
| `vmovd` + `vpinsrd` + `vmovq` (the SIMD pack) | 2.07 (2.06–2.17) | 3.00 | 268 (266–281) | per instruction of the 3 |
| `vpcompressq` | 1.26 (1.23–1.35) | 1.78 | 286 (279–305) | |
| 512-bit `vpmullq` (multiply) | 2.10 (1.76–2.14) | 0.58 | **1742** (1466–1777) | 1 of 3 hit the cap |

- **Light instructions span ~150–290 pJ.** Power per cpu is 0.8–2.1 W, and it follows how busy
  the core is more than which instruction runs.
- **Wide vectors are not special at this scale**: 512-bit `vpaddq`/`vpxorq` (190 pJ) is no dearer
  than 256-bit `vpaddq` (257 pJ; not like for like, the mixes and IPCs differ), and a 512-bit
  load (239) is close to a scalar one (213). The same
  conclusion as `report-throttling.md` §5 (no frequency penalty for light 512-bit work), now in
  energy.
- **The multiply is the outlier**, 6–10× a light instruction. It is not on the find path.
- A first version of the `store` and `pack` classes shared one buffer between threads and ran at
  IPC 0.01 from cache-line ping-pong; that was a bug in the loop, fixed by giving each thread its
  own buffer, and only the re-run numbers are shown.

## 3. The scale: what the package power is made of

### 3.1 Power against the core clock (idle spin, and `add` on 32 cores)

`fbfull/power_vs_freq.py`: cpufreq cap on node 0's cpus (restored afterwards), median of 2:

| core clock | idle spin, 64 cpus | `add` ×32 | mesh GHz in the `add` run |
|---|---|---|---|
| 0.8 GHz | 274 W | 280 W | 2.49 |
| 1.2 | 276 | 292 | 2.49 |
| 1.6 | 283 | 308 | 2.49 |
| 2.0 | 294 | 328 | 2.49 |
| 2.4 | 309 | 352 | 2.47 |
| 2.7 | 323 | 350 | **2.27** |

- **About 274 W of the idle floor does not depend on the core clock.** Static power, the mesh
  at 2.5 GHz, the HBM stacks. The clock-dependent part of the idle floor is ~50 W for the whole
  0.8–2.7 GHz range.
- **32 busy cores add only ~44 W at 2.4 GHz** and ~6 W at 0.8 GHz.
- **At the cap, core clock and mesh clock trade against each other**: 32 cores of `add` at
  2.7 GHz hit 350 W with the mesh at 2.27 GHz; at a 2.4 GHz core cap the same work draws 352 W
  with the mesh at 2.47. About 0.3 GHz of core clock costs the watts of ~0.2 GHz of mesh.

### 3.2 Memory traffic

`bandwidth_rand t1`, 2–8 threads (below the cap, nothing throttled, cores 2.694 / mesh 2.494 GHz),
bracketed by idle, 3 reps:

| threads | HBM GB/s | extra package power vs idle | per GB/s |
|---|---|---|---|
| 2 | 21.4 | 14.3 W | 0.66 W |
| 4 | 47.7 | 24.8 W | 0.52 W |
| 6 | 72.9 | 33.6 W | 0.46 W |
| 8 | 98.0 | 43.6 W | 0.44 W |

The incremental slope between these points is **0.35–0.40 W per GB/s** (10.5 W per 26.3 GB/s,
8.8 W per 25.2, 10.0 W per 25.1), i.e. **0.35–0.40 nJ per byte = 22–25 nJ per 64-byte line**,
including the threads' own core activity (~1 W each at these IPCs, i.e. under 1 nJ per line).
This is the cost at the nominal clocks; I did not measure it at the throttled mesh clock of
1.65 GHz.

### 3.3 Putting it on one scale (rough)

At dramhit's `rck` finds (fill 10): 4.2–4.3 G finds/s at ~350 W is **83 nJ per find**, ~56
instructions (47 in `find_batch` plus the harness), and 60 bytes (about one line) of HBM
traffic. At nominal clocks that is:

| ingredient | per find | share of 83 nJ |
|---|---|---|
| instructions, 56 × (150–290 pJ) | 8–16 nJ (central ~12 nJ) | ~10–19% |
| memory path, 60 B × (0.35–0.40 nJ/B) | 21–24 nJ | ~25–29% |
| idle-spin floor at 2.1 GHz (~298 W ÷ 4.25 G finds/s) | ~70 nJ | ~85% |

These **do not sum to 83 nJ** (they sum to ~100), because they were measured under different
clocks and are not independent: at dramhit's throttled clocks the dynamic parts are smaller, and
the POLL floor is partly replaced by the work. So the split is not established; what is robust
is the ordering: **the floor dominates, a line costs about twice what the instructions of a
find cost, and one instruction is ~0.25% of a find's energy.**

## 4. What that means for instruction swaps

| candidate | change per find | ≈ nJ per find | share of 83 nJ |
|---|---|---|---|
| scalar pack instead of SIMD pack (attempt 4, `CAS_FIND_SCALAR_PACK`) | 3 SIMD (3 × 268 pJ) → 1 load + 2 stores (213 + 2 × 206 pJ) | −0.2 | −0.2% |
| one fewer light instruction | −1 instruction | −0.2 | −0.25% |
| ten fewer instructions (attempt 4, `kshift` etc.) | −10 instructions | −2 | −2.5% |
| `vpcompressq` instead of kmov / tzcnt / reload | about the same instruction count | ~0 | ~0 |
| 256-bit instead of 512-bit compare | none measurable (ymm add costs more here) | ~0 | ~0 |
| one fewer cache line per find (e.g. a reprobe avoided) | −64 B of HBM traffic | **−22 to −25** | **−27–30%** at fill 10, ~−17–19% at fill 90 |

- **Instruction swaps are not where the energy is.** The measured spread between light
  instruction classes is ~0.1 nJ per instruction; no swap on the find path is worth more than
  ~0.2–0.3 nJ per find, and the one I tested (the scalar pack, attempt 4) measured as no
  change, as this predicts.
- **Even instruction removal is mostly not an energy effect.** Ten fewer instructions is ~2 nJ
  (~2.5%) of a find's energy, ~8–9 W of the 350 W at 4.2 G finds/s; the measured throughput gain
  was +9–10%, so most of that came from cycles (the in-core floor, `report-fbfull.md`), not from
  clock returned by lower power.
- **A line of HBM traffic is worth ~100 instructions.** Bytes per find are 60 at fill 10 but 98
  at fill 90 (about 1.5 lines, from reprobes): at fill 90 the memory share of a find rises to
  ~35–39 nJ of 129–134 nJ. Reducing reprobes is the energy lever with some size; it changes the
  data layout and is not something I tried.
- **IPC is the other lever.** Per-cpu power is nearly flat in IPC above ~2 (1.6–2.1 W), so a
  loop that retires more instructions per cycle at the same watts spends less energy per
  instruction. Under the cap what matters is watts, and the same watts at higher IPC means more
  throughput. This is the same direction as item 3 (in-core ILP), reached from the energy side.
- **What I did not test:** swaps whose two sides differ in the *number* of uops by more than
  one or two, because none occur on the find path; wider comparisons of vector widths on
  data from memory (these were L1-resident loops); and any cross-term between instruction mix and
  frequency (every class ran at 2.694 GHz).

## 5. The core-clock-cap lever (from my earlier proposal): no gain

Idea: lower the core clock so the saved power lets the mesh run faster. `fbfull/core_cap_sweep.py`,
dramhit `rck`, fills 10 and 90, one run per setting, with the stock 2700 MHz first and last to
show drift (cpufreq cap on node 0, restored afterwards; `results/cap_*`):

| cap | finds, fill 10 (Mops) | finds, fill 90 | mesh GHz (f10 / f90) | effective core GHz (f10 / f90) | nJ/find (f10) |
|---|---|---|---|---|---|
| 2700 (stock, first) | 4156 | 2692 | 1.65 / 1.62 | 2.09 / 2.11 | 84.9 |
| 2400 | 4226 | 2594 | 1.64 / 1.60 | 2.10 / 2.02 | 82.9 |
| 2200 | 4297 | 2631 | 1.85 / 1.60 | 2.09 / 2.04 | 85.0 |
| 2000 | 4129 | 2593 | 1.74 / 1.65 | 1.90 / 2.00 | 85.4 |
| 1800 | 4077 | 2477 | 1.92 / 1.85 | 1.80 / 1.80 | 88.2 |
| 1600 | 3827 | 2258 | 1.89 / 2.00 | 1.60 / 1.60 | 88.7 |
| 2700 (stock, last) | 4236 | 2605 | 1.64 / 1.60 | 2.13 / 2.04 | 82.7 |

- **Under the stock setting the firmware already holds the cores at ~2.1 GHz**, so caps of 2200
  and above do not bind and their differences are noise (the two stock rows differ by 2–3%).
- **Caps that bind (≤ 2000) let the mesh recover (1.6 → up to 2.0 GHz) but throughput falls**,
  −2% to −15% against the mean of the two stock rows (4196 and 2648 Mops). This workload's cost is dominated by the ~23-cycle in-core floor, so core clock
  matters more than mesh clock here. Giving the mesh the power at the cores' expense does not pay.
- **An unexplained observation:** at the 1600 MHz cap the package draws only 339 W (finds, fill
  10), below the 350 W limit, yet the mesh is still at 1.89 GHz, not 2.49. So the mesh drop is not
  purely "package power at the limit"; something else keeps it down. See `report-uncore.md`
  §7b: there is more than one limiter.

## 6. Open questions

1. **A measured split of the 350 W** at dramhit's actual clocks (floor / cores / mesh / HBM).
   The RAPL domains here are package, DRAM and platform only, so it can only be inferred by
   differences like those above.
2. **What holds the mesh down at 339 W** (§5). Together with the second limiter of
   `report-uncore.md` §7b this suggests the mesh clock is governed by more than package power.
3. **Reprobe reduction** as an energy lever at high fill (§4): the only candidate with a
   double-digit effect on a find's energy. It touches the table layout.

## 7. Files

- `throttling/spin.c` (13 new instruction classes, per-thread buffers), `throttling/uncore_sweep.py`
  (adds IPC and a settable per-thread buffer size).
- `fbfull/energy_classes.py`, `fbfull/power_vs_freq.py`, `fbfull/core_cap_sweep.py`,
  `fbfull/cpufreq_cap.py`; results in `fbfull/results/{classes_merged.json, power_vs_freq/,
  memwatts/}` and `results/cap_*`.
- Run history: the first class run is `fbfull/results/classes_run1/` (its `store` and `pack`
  rows were invalid, see §2); the re-run of the five buffer-touching classes is in
  `fbfull/results/classes/`; `classes_merged.json` combines them.
- Machine state afterwards: core clocks back at min = max = 2.7 GHz on node 0, the dramhit
  hugepage reservation restored, PL1 at 350 W.
