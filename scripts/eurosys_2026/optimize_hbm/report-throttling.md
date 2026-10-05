# Frequency throttling on the Xeon Max 9462 (HBM)

Machine: 2 × Intel Xeon Max 9462 (32 cores / 64 threads per socket), HBM in flat mode. Node 2 is
socket 0's HBM. Every measurement here uses socket 0's 64 threads (node 0) with memory on
node 2, the configuration the uniform HBM benchmarks use.

**Summary.**
- **It is power, not heat.** The cores do not hold their configured 2.7 GHz under
  HBM-bandwidth workloads. The cause is the package power limit (RAPL PL1 = 350 W, averaged over
  ~1 s). The chip is not thermally throttling, and the cpufreq governor has no effect.
- **What gets throttled.** Once the ~1 s power average reaches 350 W, the core clock drops (to
  ~2.15 GHz under the dramhit hashtable, ~2.5 GHz under the bandwidth microbenchmark) and so does
  the mesh/uncore clock.
- **Why the budget is tight.** HBM on Xeon Max is inside the package, so memory traffic draws
  on the same 350 W as the cores. With C-states disabled by the setup scripts, each socket
  already draws ~315 W while idle.
- **Sustained HBM read ceiling: ~395–400 GB/s**, not 420. 420 GB/s holds only for the first
  ~0.8 s, before the limit engages.
- **AVX-512 licensing costs no frequency at this pinned 2.7 GHz.** Light and heavy 512-bit work
  both hold 2.694 GHz at 8 threads. At 64 threads, AVX-512 costs clock only through power: light
  (zmm load + compare) −0.09 GHz and about the same bandwidth as scalar (386 vs 375 GB/s); heavy
  (`vpmullq`) −0.23 GHz and 321 GB/s. See section 5.

## 1. Setup state of the machine

| setting | value | source |
|---------|-------|--------|
| cpufreq driver | intel_pstate, active, HWP | `/sys/devices/system/cpu/intel_pstate/status` |
| governor / EPP | powersave / balance_performance (all 128 cpus) | `cpu*/cpufreq/scaling_governor`, `energy_performance_preference` |
| scaling min / max | 2.7 / 2.7 GHz; hardware range 0.8–3.5 GHz, base 2.7 GHz | `cpu0/cpufreq/*` |
| turbo | off (`intel_pstate/no_turbo` = 1) | |
| C-states | POLL, C1, C1E, C6 all disabled, so idle cpus spin in POLL (POLL% ≈ 99.5) | `cpu*/cpuidle/state*/disable` |
| package power limits | PL1 350 W over a 1 s window, PL2 420 W over 11.7 ms; both enabled and clamping. The lock bit of MSR 0x610 is clear and MSR 0x614 lists TDP 350 W, min 220 W, max 812 W, so 350 W is the SKU's default policy, not a hard maximum (corrected from an earlier version of this row) | `/sys/class/powercap/intel-rapl:{0,2}` |
| TjMax | 100 °C | MSR 0x1a2 |
| hw prefetchers | off (MSR 0x1a4 = 0x2f) | `scripts/prefetch_control_hbm.sh` |

All of the pinning comes from `scripts/setup_hbm.sh` → `scripts/constant_freq.sh 2.7GHZ`, which
sets min = max = 2.7 GHz, turns turbo off and disables every C-state.

Idle power with C-states off: turbostat shows ~313–320 W per package with nothing running (both
sockets, 99.77% "busy" in the POLL loop). That is ~90% of PL1 before any work starts.

## 2. The cause is the package power limit

Evidence from a dramhit uniform run (fill 10, 64 threads on node 0, table on node 2):

| check | result |
|-------|--------|
| `perf stat -e cycles,ref-cycles` over the run | cycles 2.199 GHz vs ref-cycles 2.700 GHz: the cores average 19% below base |
| cycles/ref-cycles every 0.5 s (`perf stat -a -C 0,2,4,6 -I 500`) | 2.69 GHz during setup, 1.93–2.30 GHz from insert start to find end, 2.69 GHz after |
| turbostat, cpu 0 | setup 2700 MHz / 316–325 W / uncore 2500 MHz; insert+find 2142–2225 MHz / 337–367 W / uncore 1200–1700 MHz; teardown back to 2700 MHz |
| governor `performance` + EPP `performance` instead | no change: 2143–2225 MHz, get 3936 vs 3909 Mops (settings restored afterwards) |
| thermal throttle counters (`cpu0/thermal_throttle/*`) | all 0 (for dramhit / bandwidth_rand; **dense 512-bit work is hotter**: `spin_zmmheavy_64` at the stock limit took the margin from 12 °C to 5 °C in seconds, see `report-uncore.md` §7.1) |
| `IA32_THERM_STATUS` (0x19c) after clearing the log bits | power-limit log (bit 11) set by the run, thermal log (bit 1) not set; 77–90 °C, 10–23 °C below TjMax |

How to read this:
- **2.7 GHz is a base frequency, not a guarantee.** Intel only guarantees it while the package
  stays within TDP (350 W) on Intel's reference workload. When the ~1 s power average exceeds
  PL1, the package power controller overrides the OS's 2.7 GHz request, lowering the core clock
  and the uncore/mesh clock.
- **The governor cannot help.** With intel_pstate, the governor and EPP only pick a frequency
  inside [min, max]. Both are 2.7 GHz, and the hardware power limit sits below that.
- **HBM traffic counts against the same budget.** On Xeon Max the HBM stacks and the mesh are
  on the package, so moving ~250–400 GB/s spends part of the 350 W that would otherwise go to
  the cores.
- **What C-states off does, and does not do.** During these benchmarks all 64 cpus of socket 0
  are working, so the POLL spinning is not what triggers the throttle. It does show that 64
  threads merely spinning at 2.7 GHz already cost ~315 W, which leaves ~35 W for everything the
  workload adds.

## 3. Throttling under dramhit vs bandwidth_rand

`machine_stats/bandwidth.c` (bandwidth_rand) is the random-access HBM microbenchmark.

Commands:

```
cd scripts/eurosys_2026/machine_stats && mkdir -p build && make build/bandwidth_rand
# 64 x 128 MB of 2 MB pages on node 2:
scripts/reserve_hugepages.sh reset && scripts/reserve_hugepages.sh n2_0gb_9216mb n0_0gb_2048mb
sudo perf stat -e cycles,ref-cycles,instructions -- ./build/bandwidth_rand -m 128mb \
  -pattern "n0a2t64" -freq 2.7 -inst t1 -lookahead 64 -mode r
# alongside: sudo turbostat --quiet --cpu 0 --show CPU,Bzy_MHz,PkgWatt,UncMHz -i 0.5
```

|                              | bandwidth_rand t1           | bandwidth_rand t0           | dramhit find, fill 10               |
|------------------------------|-----------------------------|-----------------------------|-------------------------------------|
| bandwidth                    | 370 GB/s (program's figure) | 324 GB/s (program's figure) | ~246 GB/s (HBM controllers)         |
| run length                   | 2.2 s                       | 2.5 s                       | insert 1.6 s + find 1.4 s           |
| avg core clock (cycles/ref)  | 2.56 GHz                    | 2.63 GHz                    | 2.20 GHz                            |
| clock after the first ~1 s   | 2461–2559 MHz               | 2559–2641 MHz               | 2142–2225 MHz                       |
| peak package power           | 377 W                       | 376 W                       | 367 W                               |
| instructions per cache line  | ~15                         | ~15                         | ~57 in find_batch, plus harness     |

bandwidth_rand is not kept under the limit either: it goes over PL1 by more than dramhit does. It
loses less clock for two reasons:

1. **Head start.** PL1 is a ~1 s running average, and PL2 allows 420 W short-term, so the first
   ~1 s of a bandwidth_rand run is at 2.7 GHz and 373–377 W. dramhit's clock drops within the
   first second of its insert phase, and its find phase starts already throttled. One plausible
   reason is that its setup draws ~316–325 W, against ~307–309 W before bandwidth_rand's loop,
   so it starts with less banked headroom. That is inferred from 1 s samples, not measured
   directly.
2. **Less core work per line.** ~15 instructions per line against ~57+. Both have to fit under
   the same 350 W, and the hashtable spends more core energy per byte, so the controller has to
   cut its clock further.

## 4. Sustained HBM read ceiling (`measure_hbm_ceiling.py`)

Command. `optimize_hbm/ceiling_with_power.py` reuses `measure_hbm_ceiling.run()` unchanged and
writes to `results/ceiling/`, so the stored ceiling json is not touched:

```
python3 ceiling_with_power.py --reps 3
# = sudo perf stat --per-socket -e <uncore_hbm_* rd/wr CAS> -I 100 -x, -- \
#     machine_stats/build/bandwidth_rand -m 256mb -pattern n0a2t64 -freq 2.7 -inst t1 -lookahead 64 -mode r
#   + turbostat on cpu 0; hugepages n2_0gb_17408mb n0_0gb_2048mb, dramhit reservation restored after
```

HBM bandwidth at the controllers, inside the program's measurement window (~4.1 s,
41 × 100 ms intervals):

| rep | median | peak interval | first 1 s | after 1 s, median | program's own figure |
|-----|--------|---------------|-----------|-------------------|----------------------|
| 1   | 404.8  | 420.8         | 419–421   | 400               | 367.7                |
| 2   | 399.2  | 419.3         | 418–419   | 398               | 365.5                |
| 3   | 394.1  | 418.6         | 418–419   | 392               | 363.0                |

For comparison, the stored value in `../macro_uniform/intel_hbm/intel-max9462-hbm_ceiling.json`
is 405.8 median and 424.4 peak.

Rep 1 time series (GB/s per 100 ms): `421 420 420 420 419 419 419 419 419 | 392 347 400 421 416 ...`

| time       | core MHz  | package W | uncore MHz |
|------------|-----------|-----------|------------|
| first ~1 s | 2700      | 367–376   | 2000–2100  |
| after      | 2424–2587 | 337–352   | 1500–2000  |

- **~420 GB/s is the unthrottled ceiling.** It holds for ~0.8 s.
- **What happens next.** The power average reaches 350 W, bandwidth dips to ~347 GB/s for one
  or two intervals, and then swings between ~370 and 420 GB/s at 2.42–2.59 GHz.
- **The sustained ceiling is ~395–400 GB/s.** That is the fair target for any phase longer
  than ~1 s; the hashtable find phase is ~1.4 s.
- **The program's own figure reads 8–10% below the controllers.** This report uses the
  controller numbers.

## 5. AVX-512: HBM bandwidth and frequency licensing

### New bandwidth_rand modes

`-inst avx512` already existed, but it is a zmm load with **no prefetch**, so it cannot be
compared with `-inst t1`. Two prefetched modes were added to `machine_stats/bandwidth.c` (read
mode, private buffers). They are additive `-inst` names, so existing runs are unchanged. The full
diff is in `optimize_hbm/bandwidth_avx512.diff`.

```c
+            case INST_PREFETCH_T1_AVX512:
+            case INST_PREFETCH_T1_AVX512_HEAVY: {
+                const int heavy = (t->inst_type == INST_PREFETCH_T1_AVX512_HEAVY);
+                ...
+                    for (uint64_t i = 0; i < ops; i++) {
+                        GET_IDX(idx, i, state_var);
+                        GET_LOOKAHEAD_IDX(idx_lookahead, i, state_var);
+                        _mm_prefetch((const char*)&t->buffer[idx_lookahead * 8], _MM_HINT_T1);
+                        __m512i vec = _mm512_loadu_si512((const void*)&t->buffer[idx * 8]);
+                        __mmask8 m = _mm512_mask_cmpeq_epu64_mask(0x55, vec, key);
+                        local_dummy += _mm_popcnt_u32(m);
+                        if (heavy) {
+                            __m512i v = _mm512_mullo_epi64(vec, mulk);
+                            v = _mm512_mullo_epi64(v, vec);   // operands depend on vec so
+                            v = _mm512_mullo_epi64(v, vec);   // gcc cannot fold to one multiply
+                            acc = _mm512_xor_si512(acc, v);
+                        }
+                    }
```

| `-inst`         | per line                                                                             | AVX-512 class |
|-----------------|--------------------------------------------------------------------------------------|---------------|
| `load`          | scalar 8 B load, no prefetch                                                         | none          |
| `avx512`        | zmm load, no prefetch (existing)                                                     | light         |
| `t1`            | prefetcht1 64 lines ahead + scalar load (existing; the ceiling config)               | none          |
| `t1avx512`      | prefetcht1 64 ahead + zmm load + masked `vpcmpequq` + popcnt; the hashtable probe's SIMD work | light  |
| `t1avx512heavy` | as `t1avx512` + 3 × 512-bit `vpmullq` per line                                       | heavy (512-bit integer multiply) |

The asm was checked with `objdump`:
- `t1avx512` compiles to `vmovdqu64 zmm`, `vpcmpequq {k1}`, `kmovb`, `popcnt` and `prefetcht1`.
- The first heavy version was folded by gcc into a single `vpmullq`, because
  `(v·k)·k·k = v·k³`. The final version keeps 3 `vpmullq` per line.

### Measurement

```
python3 throttling/license_sweep.py --threads 64 8 --reps 3
# per run (all sampled every 100 ms):
sudo perf stat --per-socket -I 100 -x, -e <uncore_hbm_* rd/wr CAS>,power/energy-pkg/ -- \
  perf stat -C <the N busy cpus> -I 100 -x, -e cycles,ref-cycles -o <core.csv> -- \
  machine_stats/build/bandwidth_rand -m 256mb -pattern n0a2t<N> -freq 2.7 -inst <inst> -lookahead 64 -mode r
```

- Configuration: the same as `measure_hbm_ceiling.py` (256 MB per thread, node 0 cpus, node 2
  HBM, hw prefetchers off).
- HBM bandwidth is taken at the controllers and package power from RAPL `energy-pkg`.
- Core clock is cycles/ref-cycles × 2.7 GHz on **only the cpus running the threads**. turbostat on
  one cpu cannot separate working cpus from idle ones, because with C-states off the idle cpus spin
  in POLL and also look 100% busy.
- Only intervals inside the program's `Start/End perf collection` markers are used, and the first
  and last interval are dropped.
- Median of 3 reps.
- Output: `throttling/results/license_sweep.json` (with per-interval series); logs in
  `throttling/results/logs/`.
- Why 8 threads: it is the license-isolation point. 8 working cores leave the package clock
  free of the power limit (see below), so any clock drop there would have to be the AVX-512
  license.

| threads | -inst | first 1 s: HBM GB/s | GHz | pkg W | after 1 s: HBM GB/s (range) | GHz | pkg W | program GB/s |
|---|---|---|---|---|---|---|---|---|
| 64 | t1            | 382 | 2.61 | 363 | 375 (375–384) | 2.53 | 349 | 345 |
| 64 | load          | 288 | 2.64 | 356 | 287 (287–288) | 2.69 | 349 | 266 |
| 64 | avx512        | 239 | 2.69 | 348 | 243 (234–256) | 2.69 | 349 | 227 |
| 64 | t1avx512      | 402 | 2.58 | 372 | 386 (383–388) | 2.44 | 348 | 353 |
| 64 | t1avx512heavy | 338 | 2.50 | 373 | 321 (320–321) | 2.30 | 348 | 297 |
| 8  | t1            | 100 | 2.69 | 344 | 100 (100–100) | 2.69 | 343 |  94 |
| 8  | load          |  66 | 2.69 | 329 |  66 (66–66)   | 2.69 | 329 |  63 |
| 8  | avx512        |  51 | 2.69 | 324 |  51 (51–51)   | 2.69 | 324 |  48 |
| 8  | t1avx512      |  91 | 2.69 | 344 |  91 (91–91)   | 2.69 | 343 |  87 |
| 8  | t1avx512heavy |  71 | 2.69 | 349 |  71 (71–71)   | 2.69 | 349 |  68 |

### What it shows

**1. The AVX-512 license does not lower the clock at this fixed 2.7 GHz.**
- With 8 threads, every mode holds 2.694 GHz for the whole run. That includes `t1avx512heavy`,
  which executes 3 × 512-bit `vpmullq` per line. Its throughput drops from 91 to 71 GB/s, which
  confirms the multiplies are really in the loop.
- So at this machine's pinned base clock (turbo off), neither light nor heavy AVX-512 costs
  frequency through licensing.
- I did not find, and so do not quote, Intel's published AVX-512 frequency table for the 9462.
  The claim is only what was measured at 2.7 GHz with turbo off. With turbo on, the license
  would cap the turbo bins, and the answer could differ.
- This perf build exposes no `core_power.*license*` events, so license residency itself was not
  counted. The evidence is the clock.

**2. At 64 threads, every clock difference is the power limit.** Package power sits at
348–349 W in every row, which is PL1. The clock is then set by how much power each mode burns
per unit of work:

| 64 threads, after 1 s | HBM GB/s | core GHz | vs `t1` clock |
|---|---|---|---|
| `load`, `avx512` (no prefetch) | 243–287 | 2.69 | not throttled; too little memory parallelism to use the budget |
| `t1` | 375 | 2.53 | reference |
| `t1avx512` | 386 | 2.44 | −0.09 GHz (−3.6%) |
| `t1avx512heavy` | 321 | 2.30 | −0.23 GHz (−9%) |

- **Light AVX-512 work** (a zmm load and a compare per line) costs about 0.09 GHz, and it costs
  that only through power, not through the license. It still sustains the same or slightly
  more HBM bandwidth than scalar `t1` (386 vs 375 GB/s). The difference is inside the
  hugepage-pool variation noted in section 4.
- **Heavy AVX-512 work** costs 0.23 GHz and 14% of the bandwidth (321 GB/s). Here the extra core
  power at a fixed 350 W both lowers the clock and slows the loop.

**3. The hashtable's SIMD probe is not what throttles dramhit.** The probe's own AVX-512 work
(`t1avx512`) still sustains ~386 GB/s at 2.44 GHz. dramhit's find runs at ~2.15 GHz and
~246 GB/s. The difference has to come from the rest of its per-op work: the queue loads and
stores, the second prefetch, CRC, result stores and harness, ~57+ instructions per line against
~19 in the `t1avx512` loop. It does not come from the 512-bit width. It fits section 3's picture: at a fixed
350 W, energy per op sets the clock.

**4. `t1` is lower in this session than in section 4.**
- The sustained figure is 375 GB/s, against 392–400 in section 4. The first-1-s figure is
  382–417, against 418–421 there.
- Rep 1 reached 417 GB/s in its first second, while reps 2–3 reached ~381. So the difference
  comes from the physical pages backing the buffer (the hugepage pool was re-reserved between
  the two sessions), which `measure_hbm_ceiling.py`'s docstring puts at up to ±7%. Compare
  modes within one session, as the table does, not across sessions.

**5. Without prefetch, the zmm load is slower than the scalar load.**
- 243 vs 287 GB/s at 64 threads, and 51 vs 66 GB/s at 8 threads, with the clock at 2.69 GHz in
  both cases. So this is not frequency.
- The loops differ only in load width. A plausible cause is how many demand misses the core
  keeps in flight for 64 B zmm loads versus 8 B loads, but it was not investigated. It does not
  matter for the prefetched modes, which is how the hashtable accesses memory.

**6. Package power at 8 threads is ~324–349 W, although only 8 cores work.**
- The other 56 cpus of socket 0 spin in POLL at 2.7 GHz (C-states off, section 1), and that
  alone costs ~315 W.
- `t1avx512heavy` at 8 threads reaches 349 W, right at PL1, and still holds 2.694 GHz. Whether
  the controller would cut the clock next depends on the running average. Re-enabling C-states
  on idle cpus would give the 8-thread point real headroom, and it is the cleaner way to repeat
  this isolation test.

## Implications for the hashtable work

- **Budgets must use the real clock.** At the sustained ~2.15 GHz, reaching 400 GB/s needs
  64 × 2.15e9 × 64 B / 400 GB/s ≈ 22 core cycles per find. `hbm-debug.md`'s 26 cycles assumes
  2.7 GHz. The find currently costs ~37.5 core cycles (46 TSC cycles).
- **Energy per op is a lever.** Every instruction per op competes with HBM traffic for the same
  350 W. Removing instructions saves cycles and also returns clock. The branch-free find in
  `report-attempt2.md` did the opposite (+46% instructions per find).
- **Microbenchmark ceilings must be read in the sustained window.** A run of ~2 s gets up to
  1 s unthrottled. Report the after-1 s numbers.
- **Still open:**
  - The mesh clock drops to 1.2–1.7 GHz under dramhit, against 1.5–2.1 GHz under
    bandwidth_rand. A slower mesh plausibly adds memory latency, which would lower the
    bandwidth each core can reach through its fill buffers. The test is to pin the uncore
    frequency (`/sys/devices/system/cpu/intel_uncore_frequency/`) and compare.
  - Re-enabling C-states on the idle socket and on unused cpus would show how much of the ~315 W
    idle floor can be recovered. It does not help while all 64 cpus of socket 0 are busy.
