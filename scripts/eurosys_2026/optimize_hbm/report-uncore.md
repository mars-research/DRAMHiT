# Open research 1: what makes the mesh (uncore) clock drop?

From `human.md` ("Investigate uncore mesh frequency drop condition", the open item in
`report-throttling.md`). Machine: Xeon Max 9462, socket 0's 64 cpus (node 0), HBM node 2,
hw prefetchers off. All clock numbers below are *measured*, not configured.

**Summary.**
- **The mesh clock falls before the core clock does.** The mesh is lowered within the first
  0.1–0.2 s of a heavy run, while the cores stay at 2.69 GHz for another ~0.9 s.
- **Memory traffic is not required.** A memory-free 512-bit multiply loop on 64 threads
  pulls the mesh down to 1.95 GHz with 0 GB/s of HBM traffic.
- **The onset is at the 350 W package limit, and the depth tracks how far above it the
  workload would go.** All 18 runs whose package power stayed at or below 347 W held the mesh at
  exactly 2.494 GHz for the whole run; every run at 350 W or above lost mesh clock at some point.
  Above the limit the mesh falls steadily: 2.49 → 2.28 → 2.16 → 2.02 → 1.86 GHz as memory-bound
  threads go 8 → 16 → 24 → 32 → 64.
- **dramhit pays more than the bandwidth microbenchmark.** Mesh 1.65 GHz on finds and
  1.54–1.65 GHz on inserts, against 1.86 GHz for `bandwidth_rand` at 64 threads.
- **Not established:** a causal test (lowering the power limit), and how much throughput
  actually depends on the mesh clock. Both need a system setting changed; see §6.

## 1. How the clocks were measured

- **Mesh clock:** `uncore_cha_0/event=0x01` (UNC_CHA_CLOCKTICKS) divided by time enabled, in the
  same `perf stat --per-socket -I 100` stream as HBM CAS counts and RAPL package energy, so
  every interval has all of them aligned. Idle reads 2.494 GHz on both sockets.
- **Two more clocks, same method:** `uncore_mdf_0/event=0x01` is identical to the CHA clock in
  every interval (same clock domain, or the event counts the same source). The HBM controller
  clock (`uncore_hbm_0/event=0x01`) is 0.798 GHz in every run, idle or loaded: **the HBM side is
  not throttled**.
- **Core clock:** cycles / ref-cycles × 2.7 GHz, from a second perf on the cpus doing the work.
- **OS-visible limits cannot move it.** `intel_uncore_frequency/package_0*/` reports
  `min_freq_khz = max_freq_khz = initial_min = initial_max = 2500000` on both sockets, so it is
  already pinned at 2.5 GHz from software's side and the range cannot be widened. The
  hardware lowers it anyway, as it does the core clock.

## 2. Workloads (`throttling/uncore_sweep.py`, 3 reps each, 100 ms intervals)

| workload | what it is | memory traffic |
|---|---|---|
| `idle` | nothing runs; cpus spin in POLL (C-states off) | none |
| `mem_t1_<N>` | `bandwidth_rand -m 256mb -inst t1`, N threads on node 0 | HBM random reads |
| `spin_scalar_<N>` | `throttling/spin.c`: 8 imul + 4 add chains per thread, no loads | none |
| `spin_zmmlight_<N>` | 512-bit `vpaddq` / `vpxorq` chains | none |
| `spin_zmmheavy_<N>` | 512-bit `vpmullq` chains | none |

`spin.c` is new: pinned threads, register-only inline asm so the compiler cannot fold or remove
the loop, 5 s timed window, with the same Start/End markers `bandwidth_rand` prints. A 3 s pause
separates runs, so one run's power does not feed the next run's ~1 s RAPL average.

```
cd scripts/eurosys_2026/optimize_hbm/throttling
gcc -O2 -mavx512f -mavx512dq -pthread spin.c -o build/spin
python3 uncore_sweep.py --reps 3          # -> results/uncore/uncore_sweep.json, logs/
python3 uncore_summary.py [--series mem_t1_64]
```

16 GB of 2 MB hugepages on node 2 are reserved for the run, and the dramhit reservation is
restored afterwards.

## 3. Results

Each cell is the median over 3 reps of that run's median over its in-window 100 ms intervals.
"mesh < 2.45 at" is the time within the run at which the mesh clock first dipped below
2.45 GHz; "core < 2.65 at" likewise for the core clock.

| workload | pkg W | core GHz | mesh GHz | mesh min | HBM GB/s | mesh<2.45 at (s) | core<2.65 at (s) |
|---|---|---|---|---|---|---|---|
| idle | 312 | 2.69 | **2.49** | 2.49 | 0 | – | – |
| spin_scalar_16 / 32 / 64 | 320 / 327 / 319 | 2.69 | **2.49** | 2.49 | 0 | – | – |
| spin_zmmlight_64 | 344 (344–347) | 2.69 | **2.49** | 2.49 | 0 | – | – |
| spin_zmmheavy_16 | 344 (343–347) | 2.69 | **2.49** | 2.49 | 0 | – | – |
| mem_t1_8 | 356 (351–357) | 2.69 | 2.49 | 2.39 | 99 | 1.9 | – |
| mem_t1_16 | 358 | 2.69 | 2.28 | 2.07 | 193 | 0.2 | – |
| mem_t1_24 | 364 | 2.69 | 2.16 | 1.80 | 282 | 0.2 | 1.0 |
| mem_t1_32 | 371 | 2.69 | 2.02 | 1.62 | 363 | 0.2 | 1.0 |
| mem_t1_48 | 354 | 2.69 | 2.03 | 1.61 | 357 | 0.2 | 1.0 |
| mem_t1_64 | 351 | 2.57 | 1.86 | 1.59 | 387 | 0.2 | 0.9 |
| spin_zmmheavy_32 | 350 | 2.69 | 2.19 | 2.02 | 0 | 1.0 | – |
| spin_zmmheavy_64 | 353 | 2.69 | 1.95 | 1.78 | 0 | 0.2 | 1.1 |

HBM controller clock: 0.80 GHz in every row.

### The first second of three runs (rep 1)

```
mem_t1_16                 mem_t1_64                 spin_zmmheavy_64
t     W  core mesh HBM    t     W  core mesh HBM    t     W  core mesh
0.2  373 2.69 2.46  196   0.2  381 2.69 2.01  417   0.2  380 2.69 2.23
0.5  376 2.69 2.46  196   0.5  374 2.69 2.00  415   0.5  377 2.69 2.21
0.9  377 2.69 2.45  196   0.9  371 2.57 1.97  400   0.9  376 2.69 2.19
1.0  358 2.69 2.31  194   1.0  309 1.99 1.61  354   1.0  350 2.58 1.96
1.1  335 2.69 2.11  190   1.1  325 2.37 1.67  368   1.1  302 2.27 1.71
1.2  339 2.69 2.15  191   1.2  372 2.69 2.02  407   1.2  353 2.67 1.96
1.3  368 2.69 2.38  195   1.3  374 2.68 2.00  404   1.3  372 2.69 2.19
```

## 4. What this shows

1. **The mesh is the first thing to give.** In every run that throttles, the mesh sits below its
   nominal 2.49 GHz from the first or second interval. The core clock does not move until
   t ≈ 0.9–1.1 s, and in `mem_t1_16` / `_32` / `_48` and `spin_zmmheavy_32` it never moves
   at all (core median 2.69 GHz while the mesh median is 1.9–2.3).
2. **The mesh level is set by demand, and it is already set in the first ~0.9 s.** In that
   window all three runs draw 371–385 W (above the 350 W limit, inside the 420 W short-term
   limit), the cores run at full clock, and the mesh sits at three different levels: 2.46 GHz
   (16 threads), 2.2 (zmmheavy ×64), 2.0 (64 threads of memory traffic). So this is not a switch
   that flips when the ~1 s average crosses 350 W. It is graded.
3. **Then a limit cycle.** At t ≈ 1.0 s power overshoots *down* to 302–309 W and both clocks
   fall hard (mesh 1.61, core 1.99 GHz), then recover and oscillate with a period of ~0.4–0.5 s
   (seen in the 64-thread series above; I did not check every run). The sustained clocks in §3
   are averages over that oscillation.
4. **HBM traffic is not what lowers the mesh.** `spin_zmmheavy_64` has no loads and still lowers
   the mesh to 1.95 GHz. It is power that matters. Memory traffic is a heavy power consumer here
   (it reaches the drop with 16 threads, where the compute-only loops need 32), but not a
   required one.
5. **Instruction type matters through power.** At 64 threads, scalar integer ops (319 W) and
   light 512-bit ops (344 W) leave the mesh alone; 512-bit multiplies (353 W) do not. This is
   consistent with `report-throttling.md` §5 (no frequency *license*; the effect is power).
6. **The onset sits at the 350 W limit.** Runs at 347 W or below (idle, all scalar, zmmlight ×64,
   zmmheavy ×16: 18 runs) never moved the mesh off 2.494 GHz. Runs at 350 W or above all did:
   `spin_zmmheavy_32` (350–351 W) from the first or second second, and `mem_t1_8` (351, 357,
   356 W per rep) only late, with its mesh dipping to 2.39 GHz at 1.84 s and 2.05 s in two reps
   and not at all within the 1.9 s window of the third. The onset time grows as the excess over
   350 W shrinks, which fits a ~1 s power average being held to PL1. The "power" in §3 is
   measured *after* the controller has acted, so it cannot be read as the demand: the demand is
   higher than the table says for the runs that were throttled.
7. **Not thermal, for the workloads in §3 and §5.** For those the die stayed 10–23 °C under
   TjMax with every `thermal_throttle` counter at 0 (`report-throttling.md` §2). **This does not
   hold for dense 512-bit work:** see §7, where the heavy `vpmullq` spin on 64 threads took the
   package from 12 °C to 5 °C below TjMax in a few seconds at the *stock* 350 W limit. `human.md` describes the chain
   as "processor gets hot → frequency drops"; the measured chain is **power over budget →
   frequency drops**. The energy-per-op argument in `human.md` is unaffected, and in fact it
   is stronger for it: the limit is a power budget, so energy per op is exactly what converts
   into throughput.

## 5. Does it matter to dramhit? Instruction trimming vs mesh clock

`run_uniform_hbm.py --energy` now also records `mesh_ghz` per phase (events
`uncore_cha_0/event=0x01,name=clk_cha/`; parser `parse_energy`). Base, ring, cmp, rc and l1
from `report-attempt3.md`, 3 reps each, interleaved on one hugepool, a second session on a
different day (`results/m_<variant>_r<rep>/`, `attempt3/summary_mesh.json`):

```
python3 attempt3/summarize.py --prefix m --variants base ring cmp rc l1
```

Find (get), median of 3:

| fill | variant | Mops | vs base | core GHz | **mesh GHz** | nJ/find |
|---|---|---|---|---|---|---|
| 10 | base | 3941 | – | 2.29 | 1.68 | 87.6 |
| 10 | ring | 4134 | +4.9% | 2.21 | 1.67 | 84.5 |
| 10 | cmp | 4036 | +2.4% | 2.20 | 1.68 | 88.1 |
| 10 | rc | 4201 | +6.6% | 2.17 | 1.66 | 83.5 |
| 10 | l1 | 3249 | −17.6% | 2.58 | **1.82** | 106.6 |
| 50 | base | 3653 | – | 2.19 | 1.69 | 95.6 |
| 50 | rc | 3861 | +5.7% | 2.12 | 1.63 | 90.2 |
| 50 | l1 | 3076 | −15.8% | 2.51 | **1.81** | 113.4 |
| 90 | base | 2428 | – | 2.15 | 1.65 | 143.7 |
| 90 | rc | 2614 | +7.7% | 2.08 | 1.60 | 133.4 |
| 90 | l1 | 2170 | −10.6% | 2.36 | **1.76** | 160.8 |

Insert (control; same code in every variant): mesh 1.54–1.69 GHz, within ±0.05 GHz of base at
every fill.

- **The attempt-3 results replicate.** `rc` +5.7% to +7.7%, `l1` −10.6% to −17.6%; base fill-90
  finds read 2428 Mops in both sessions.
- **dramhit's mesh is 1.60–1.69 GHz on finds, about a third below nominal**, lower than
  `bandwidth_rand` at 64 threads (1.86) even though dramhit moves less HBM bandwidth
  (242–261 vs 387 GB/s). So in this regime dramhit is not limited by HBM bandwidth *because* of
  the mesh clock alone; per-line core work draws power that the mesh pays for.
- **The faster variant has a slightly *lower* mesh clock** (rc 1.60–1.66 vs base 1.65–1.69),
  and the slower one (l1) a higher one (1.76–1.82). Same pattern as the cores. A variant that
  completes more finds moves more HBM traffic and draws more power per second, so the clocks go
  down; a variant that stalls draws less, and the clocks go up.
- **The mesh clock cannot be used as a score for an optimization.** Higher mesh and core clocks
  went with *worse* throughput here. Throughput and nJ/op are the numbers to compare.
- **What this cannot tell us: how sensitive throughput is to the mesh clock.** Every variant
  changes the mesh clock only as a side effect of changing its own power draw, so the effect of
  the mesh on throughput is confounded with the change that caused it. The same is true across
  workloads.

## 6. Open questions and the experiments that would settle them

None of these were run, because each changes a machine-wide setting. They are listed so you can
decide.

1. **Is it a power-limit decision? (causality)** *Done in the lowering direction, see §7; raising
   PL1 was found unsafe for 512-bit loads.* Original proposal: lower PL1 (via
   `/sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw`, root, restorable) to, say,
   300 W. If the controller is what lowers the mesh, the `spin_scalar_64` and `spin_zmmlight_64`
   workloads that are untouched at 319–344 W should now lose mesh clock too, at a depth set by
   how far they exceed 300 W. Lowering is the safe direction. Raising PL1 above 350 W is
   probably refused by firmware (`constraint_0_max_power_uw` = 350 W).
   **Correction (checked later, read-only):** that was wrong. `constraint_0_max_power_uw` reports
   the thermal spec power (TDP), not a hard cap: `MSR_PKG_POWER_LIMIT` (0x610) has its lock bit
   clear, and `MSR_PKG_POWER_INFO` (0x614) lists a maximum of 812 W. PL1 may well be settable
   above 350 W. It has not been tried.
2. **How much does the mesh clock cost throughput? (sensitivity)** Cap the mesh with the
   uncore-ratio MSR (0x620) at a fixed lower value while the package is *under* its power limit
   (e.g. `mem_t1_16`, 358 W, mesh 2.28 → capped at 1.6 GHz), and measure HBM bandwidth and
   `fb_full`. That separates the mesh's own effect from the power effect. This writes an MSR
   (restorable, and the sysfs range cannot do it: its min and max are both 2.5 GHz).
3. **Core vs uncore power split.** RAPL on this machine exposes package, DRAM and psys only, so
   the split of power between cores and mesh is not directly measurable. One hint in the data:
   `spin_zmmheavy_32` (350–351 W) ends at a mesh of 2.15–2.20 GHz, while `mem_t1_16` (355–362 W)
   keeps a *higher* mesh, 2.27–2.34 GHz, at *more* total power; the rep ranges do not overlap.
   If only total package power set the mesh clock, the higher-power run should have the lower
   mesh clock. One reading is that heavy core work (`vpmullq` on 32 threads) takes mesh clock
   that memory traffic of a similar power does not. That is a hypothesis from two workloads
   5–12 W apart, not a result.

Files: `throttling/spin.c`, `throttling/uncore_sweep.py`, `throttling/uncore_summary.py`,
`throttling/results/uncore/` (json, logs), `run_uniform_hbm.py` (`--energy` now includes
`mesh_ghz`), `attempt3/summarize.py` (`--prefix`, mesh column), `results/m_*`,
`attempt3/summary_mesh.json`.

## 7. PL1 test: does the package power limit control the mesh clock? (yes)

`throttling/pl1_check.py`, `throttling/restore_pl1.sh`, `throttling/results/pl1/pl1_check.json`.
Socket 0's PL1 is set through `/sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw`;
a monitor thread polls the temperature margin (MSR 0x1b1) and kills the workload at <= 5 °C; PL1
is restored in a `finally` block and MSR 0x610 compared bit for bit with its start value
(`0x878d2000158af0`, identical after every run of the script).

### 7.1 Raising PL1 was not possible: the thermal abort fired at the stock limit

The first design raised PL1 (380 / 400 / 420 W) under `spin_zmmheavy_64`. Its very first run, at
the **unchanged 350 W**, took the package from a 12 °C margin to 5 °C (95 °C) within a few
seconds and tripped the abort. The package then cooled from 95 °C to 82 °C in about 30 s. So:

- the margin to TjMax is thin under dense 512-bit work even at the stock limit, and the die
  temperature responds on a timescale of seconds;
- the idle floor already sits at 85–88 °C (margin 12–15 °C), because C-states are disabled and
  every cpu spins at 2.7 GHz (~313 W);
- raising PL1 under a heavy 512-bit load would push toward TjMax, and was not tried. Raising it
  for a cooler, memory-bound load is untested (open, see §8).

This qualifies the earlier "not thermal" statements: they hold for dramhit and `bandwidth_rand`
(84–90 °C), not for every workload. I did not check whether the thermal log bits fired during
that heavy run.

### 7.2 Lowering PL1 under a cool workload: dose-response

`spin_scalar_32` (integer ops, 32 threads of node 0, no memory) draws ~331 W at stock and leaves
the mesh at its full 2.494 GHz. PL1 is then set below that demand, 2 reps per level; the list
ran 350 → 335 → 325 → 315 → 350 (control).

| PL1 (W) | pkg W (reps) | mesh GHz median (min) | live `0x621` ratio | RAPL-throttled time (`0x613`) | core GHz | margin |
|---|---|---|---|---|---|---|
| 350 | 332, 335 | 2.494 (2.49) | 25 | 0% | 2.694 | 12 °C |
| 335 | 335, 335 | 2.494 (2.43) | 25 | 4%, 7% | 2.694 | 11–12 °C |
| 325 | 323.6, 323.7 | **2.38** (2.26) | 24.2 | **53%**, 53% | 2.694 | 11–12 °C |
| 315 | 314.0, 314.4 | **2.30–2.33** (2.29) | 23.2–23.5 | **94%**, 84% | 2.694 | 12–13 °C |
| 350 (control, after) | 331, 331 | 2.494 (2.49) | 25 | 0% | 2.694 | 14 °C |

- **PL1 controls the mesh clock.** With the same workload and nothing else changed, lowering PL1
  below the workload's demand lowers the mesh clock, deeper the lower the limit, and returning
  to 350 W restores 2.494 GHz exactly. The control rows rule out drift.
- **The mesh gives first, again.** Through all of this the core stayed at 2.694 GHz; only the
  mesh moved (2.49 → 2.38 → 2.30 GHz).
- **The measured package power lands just under the limit** (323.6 W at 325 W, 314.0 at
  315 W), as a clamp would produce.
- **The throttled-time counter (`0x613`) tracks the same thing**, from 0% to 4–7% to 53% to
  84–94% as PL1 drops. It is the quickest indicator that the limit is active.
- **The first dip shows up when PL1 is close to the demand.** At 335 W (the run drew ~335 W),
  the mesh dipped to 2.43 GHz for a few percent of the run only.
- **The workload's demand drifts a few watts with temperature** (331–335 W between runs at the
  margin of 14 vs 11–12 °C). The control at the end ran cooler and drew 331 W.

### 7.3 What this settles and what it does not

- Settled, for a compute-only workload: the package power limit is the control that lowers the
  mesh clock, in preference to the core clock, with `UNCORE_RATIO_LIMIT` (`0x620`, min = max
  = 25) not honored as a floor (ratios of 23–24 were observed live).
- Not settled: that the same holds for the memory-bound mesh drops in §3 (they behave
  consistently with it, but the PL1 lowering was not run with a memory workload); and what the
  firmware does when the cores must give: at PL1 = 315 W the mesh alone absorbed a 16 W cut.
- Not run: raising PL1 (see §7.1).

## 7b. Raising PL1 with a memory-bound workload: no effect, a second limiter exists

`pl1_check.py --workload mem_t1_16 --mem 512mb --levels 350 360 370 380 350 --reps 2 --out pl1_mem16`
(16 threads of node 0 reading HBM node 2 at ~192 GB/s, ~4 s per run, 9 GB hugepage reservation,
restored afterwards; same 5 °C abort and cooldown wait before each run).

First, `mem_t1_64` was tried at the stock 350 W: it tripped the abort too (margin 12 → 5 °C over
its ~4 s run, `results/pl1_mem/`), so a raise under that load was not attempted either.

| PL1 (W) | pkg W | mesh GHz median (min) | live `0x621` | RAPL-throttled | HBM GB/s | min margin |
|---|---|---|---|---|---|---|
| 350 | 349.8, 350.3 | 2.183, 2.159 (2.04, 2.00) | 22.2 | 88%, 91% | 192.0, 191.5 | 12 °C |
| 360 | 353.4, 350.3 | 2.156, 2.129 (1.97, 1.96) | 22.1 | 92%, 92% | 191.4, 190.9 | 11 °C |
| 370 | 350.5, 350.7 | 2.142, 2.168 (1.96, 1.97) | 22.4 | 92%, 92% | 191.1, 191.7 | 11 °C |
| 380 | 350.3, 350.7 | 2.193, 2.195 (2.00, 2.00) | 22.3–22.8 | 91%, 88% | 192.2, 192.2 | 12–13 °C |
| 350 (control) | 349.6, 349.6 | 2.195, 2.195 (2.06, 2.06) | 23.0–23.2 | 86%, 84% | 192.4, 192.3 | 14–15 °C |

- **Raising PL1 changed nothing.** Package power stays at 350 ± 0.5 W, RAPL throttling stays at
  84–92%, and the mesh stays at 2.13–2.20 GHz with HBM bandwidth flat at 191–192 GB/s, at every
  level. The differences between levels are inside the run-to-run spread.
- **The write did take effect in the register.** After `echo 380000000 > constraint_0_power_limit_uw`,
  `MSR 0x610` read `0x878d2000158be0`: PL1 field 380 W, PL2 420 W, lock bit 0.
- **So the OS-visible PL1 is not the only limiter.** Lowering it (§7.2) works because the
  effective limit is the lowest of several; something else holds the package at 350 W.

### Which limiter? What the limit-reasons register shows (`MSR 0x64F`)

The sticky log bits of `0x64F` were cleared on socket 0 (a write of 0 to a log register, a
diagnostic; it read `0x1840000` before, sticky since boot), then a 3 s load was run:

| trial | PL1 | RAPL-throttled time | `0x64F` after the run |
|---|---|---|---|
| scalar ×32 | lowered to 315 W | 1.6 s | `0x0` (no bits) |
| scalar ×32 | 350 W | 0.0 s | `0x0` |
| zmmheavy ×32 | 350 W (stock) | 2.6 s | `0x40000` (bit 18) |
| zmmheavy ×32 | raised to 380 W | 2.7 s | `0x40000` (bit 18) |

- When the **OS PL1** is what binds (trial 1), the register shows no bit at all. When the
  limiter that holds the package at 350 W under heavy load binds (trials 3 and 4), bit 18 is
  set both at stock and with PL1 raised to 380 W. These are two different mechanisms.
- **I cannot say what bit 18 is.** I remember the layout of this register for other Intel
  parts (status bit 10 = PL1, 11 = PL2, 8 = other, 7 = VR design current, log = status + 16) but
  could not confirm it for this part, and bit 18 is not one of those. Do not read more into it
  than "a different limiter, not PL1".
- **Candidates I can name but not separate:** a platform or BMC power cap that the CPU honors
  alongside its own PL1 (the machine has IPMI and `acpi_power_meter` modules, `ipmitool` is not
  installed so I could not query it), an internal firmware limit configured by the BIOS, or an
  electrical limit. The package sitting at 350.3 ± 0.5 W in all eight runs fits a power limit
  more than a current limit.

### A further observation: the mesh stays down below the power limit

In the core-cap sweep (`report-energy.md` §5), at a 1600 MHz core cap dramhit's package power
is 339 W for finds at fill 10, below the 350 W limit, and the mesh is still at 1.89 GHz
instead of 2.49. A throttle that only reacted to package power at 350 W would have released the
mesh. This is consistent with the second limiter above, but does not identify it.

### What this means for the question in `human.md`

- On this machine, 350 W is not a limit I can raise from the OS, even though MSR 0x610 says
  it is unlocked and accepts 380 W. The limit I can *lower* (PL1) and the limit that binds at
  350 W are different things.
- The experiments above show the stock behaviour is the only one reachable from software.
  Raising it would need whatever sets the second limiter: BIOS settings or BMC power policy.
  Whether the lab allows that on this node I do not know.
- **A lever that is reachable from software and not yet tried:** lowering the *core* clock.
  Under the cap the firmware keeps the cores near 2.2–2.7 GHz and gives up mesh clock first
  (mesh 1.6–1.7 GHz under dramhit). A core frequency cap (`scaling_max_freq`) frees power that
  the mesh could keep. Whether the net effect on find throughput is positive is an open
  question, and the experiment is cheap.

## 8. Next, if wanted

- ~~Raise PL1 under a cooler memory workload~~ done in §7b: no effect, a second limiter binds.
- Cap the core clock (`scaling_max_freq` 2.0–2.4 GHz) and measure whether the mesh clock and
  find throughput change under dramhit (see end of §7b).
- Re-enable C-states on the idle cpus to lower the 313 W floor: this lowers the temperature
  and leaves more of the 350 W for work.
