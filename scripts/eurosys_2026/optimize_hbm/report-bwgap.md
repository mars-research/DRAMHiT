# Why does dramblast (rck) reach ~270 GB/s of finds where bandwidth_rand reaches ~380–400 GB/s?

A re-measured, replicable comparison of `bandwidth_rand` (t1) and the dramblast `rck` build
on the Xeon Max 9462 HBM machine, testing the "compounding effect" hypothesis in `human.md`.
Everything here was produced by the scripts in `bwgap/`; raw logs are in `bwgap/logs/`, derived
tables in `bwgap/tables/`. Section 9 gives the reproduction recipe.

## 0. Summary

| | bandwidth_rand t1 | dramblast rck, fill 10 % | ratio |
|---|---|---|---|
| lines/s (E2, differential, median of 5) | 5.949 G | 4.203 G | **1.415** |
| as decimal GB (lines × 64 B) | 380.7 | 269.0 | |
| core clock (cycles:u / ref-cycles:u × 2.7) | 2.521 GHz | 2.276 GHz | 1.108 |
| cycles per line (Δcycles/Δlines) | 26.36 | 32.11 | 1.218 |
| instructions per line | 14.0 | 55.8 | 3.99 |
| unhalted-user fraction u (derived, §4) | 0.972 | 0.927 | 1.049 |

1. **The factorisation in `human.md` holds.** In E1 (as-shipped streams) 1.448 = 1.177 (clock) × 1.231 (cycles/line from rate), no third factor. In E2 (ratio of medians) a small third factor appears, the unhalted-user fraction u: 1.415 = 1.108 × 1.218 × 1.049. u measured per rep directly (Δref-cycles / (64 × 2.7e9 × ΔT)) is 0.974–0.977 for bw_t1 and 0.936–0.977 (median 0.954) for dramblast, so the per-rep u ratio is ~1.02; the 1.049 is partly an artifact of multiplying medians from different reps. u is a ≤ 5 % effect, cause unmeasured.
2. **Instructions per line, not memory-level parallelism, set the cycles-per-line gap — but only about half of it.** A ladder of extra instructions on bandwidth_rand (E4) is free in cycles up to ~40 instr/line, then costs ~0.19 cycle/instr; extrapolated to dramblast's 55.8 instr/line it predicts ~29 cycles/line, versus the measured 32.1 (bandwidth_rand: 26.4). So ≈ 2.6 of the 5.75 extra cycles are explained by instruction count; **≈ 3.1 cycles (~10 %) are not**.
3. **Memory-dependent instructions are few**: 0.98 loads + 5.95 dependent (`vpcmpequq`, `kortestb`, `je`, `kshiftlb`, `vpcompressq`, `vmovq` store) of 55.8 per find (10.7 %); the other 48.8 (87.6 %) are independent of the bucket line (hash, queue, prefetch addresses, harness). bandwidth_rand t1 has 1 load-add and 13 independent.
4. **Dependence per se was not detectably costly** in the ladder (2 reps, ~1 cycle noise): a serial chain on the loaded value (t1dpad) costs the same as independent padding for N ≤ 32 (≤ 1 cycle) and ~1.6 cycles more at N = 48. The "dependent instructions directly raise cycles" half of the hypothesis is therefore **not supported** (dramblast only has ~6 of them, none in a serial chain).
5. **Clock half: partly supported, not isolated.** Package power is pinned at ~348 W in every run. Independent padding (bw_double24) already lowers the clock 8 % and reproduces most of the E2 clock factor; in E1 dramblast is lower still, which instruction kind or the DDR key stream could explain, but this was not separated (§7).
6. Units: bandwidth_rand's printed "GB/s" is GiB/s (§1). Corrections to older reports are listed in §8.

## 1. Definitions (read first)

- **line**: for bandwidth_rand one loop iteration = one 64 B cache-line access (`lines = alloc_MB·2^20/64 × iterations`, i.e. 256 MB/thread → 4 194 304 lines/thread/iteration, ×64 threads). For dramblast one `find` (`find_ops` in the program output).
- **GB vs GiB.** bandwidth_rand prints `Total Data Proc : 1600.00 GB` for 64 × 256 MiB × 100 iterations = 1600 GiB and `Bandwidth: 367.08 GB/s` = 1600 / 4.3587 s: **GiB/s** (÷2^30), time from the TSC assumed 2.7 GHz. The HBM controller counters (CAS × 32 B) and "lines/s × 64 B" are decimal GB. Factor 1.0737. In this report "GB/s" is decimal unless it says "printed".
- **core GHz** = 2.7 × `cycles:u` / `ref-cycles:u` (ref-cycles tick at the 2.7 GHz TSC rate when the core runs). **mesh GHz** = uncore_cha_0 event 0x01 count / time_enabled.
- **cycles/line** = Δcycles:u(all 64 threads, socket 0) / Δlines (E2). Cross-check (b) = 64 × core GHz / (lines/s); the two differ by the unhalted fraction u = (a)/(b).
- **instr/line** = Δinstructions:u / Δlines.
- **memory-dependent / independent** (for the instruction split): see §5.

## 2. Machine and state (from `bwgap/logs/env_start.txt`, `env_end.txt`)

2-socket Xeon Max 9462 (32 cores × 2 HT / socket; L1d 48 KiB, L2 2 MiB, L3 75 MiB/socket), HBM = NUMA nodes 2 (socket 0) and 3. All runs: 64 threads pinned on node 0's even cpu ids, table/buffer on node 2 (HBM). State unchanged during the session: cpufreq governor min = max = 2.7 GHz on node 0, C-states disabled, hardware prefetchers off (MSR 0x1a4 = 0x2f), PL1 350 W / PL2 420 W (MSR 0x610 = 0x878d2000158af0), git HEAD a0515d1 with the uncommitted `cas_kht.hpp` (+87), `CMakeLists.txt` (+20), `bandwidth.c` (+156) changes. Package thermal margin before runs was kept ≥ 12 °C by `runlib.cooldown()` (it waits between runs). Hugepage pool (`reserve_hugepages.sh reset; … n2_12gb_17408mb n0_0gb_8192mb n1_0gb_8192mb`): node 2 has 12 × 1 GiB + 8704 × 2 MiB pages. Binaries (md5): dramblast rck `f209f705238b05f275871a33ae7e1a8b`, `bandwidth_rand_it100` `b91b7be1b7cd5b4a2d8b69a6f1afd47e`, `_it200` `91d9f8e5aea0438bfbc910bf1f4ef391`.
(Known tooling issue: the "idle package power" lines in `env_*.txt` print 0.0 W — the perf energy read in `env_snapshot.sh` returns nothing under sudo; do not use them. The ~313 W idle floor is from `report-throttling.md`.)

## 3. E1 — as-shipped interval streams (what the original 391 vs 275 numbers were)

**What it measures.** One `perf stat -a --per-socket -I 200 -x,` stream wrapped around each whole program, 5 repetitions each of: `bw_t1`, `bw_double24` (t2 far line + t0 near line + load with 24 independent adds, 51 instr/line), `dramhit_rck_f10` (fill 10, as `macro_uniform` runs it). Events (3 fixed + 4 programmable, no multiplexing; the parser asserts 100 % running): `cycles, instructions, ref-cycles, l1d_pend_miss.fb_full, offcore_requests_outstanding.data_rd, offcore_requests.data_rd, xq.full_cycles, power/energy-pkg/`, and for each of the 32 `uncore_hbm_N`: `event=0x05,umask=0xcf` (read CAS) and `0xf0` (write CAS), 32 B per CAS. Command lines: `logs/E1_stream/<w>_r<k>/cmd.txt`; combined stdout+perf: `combined.log`.

**Interpretation of the perf output** (`-x,` rows: `time,socket,ncpus,value,,event,run_ns,pct_running`): HBM GB/s = Σ(rd+wr counts)×32 B per interval ÷ interval length; core GHz = 2.7 × cycles/ref-cycles per interval; XQ-full % = `xq.full_cycles`/`cycles` ("fraction of cycles the L2→uncore request queue could not accept"); fb_full % = `l1d_pend_miss.fb_full`/`cycles` (L1 fill buffers all occupied); outstanding/thread = Σ`offcore_requests_outstanding.data_rd` ÷ Σ`cycles` over the socket (the counter adds the number of L2-miss reads in flight every cycle, so the ratio is the average in flight per thread, Little's law). Program lines/s in E1: bandwidth_rand printed GiB/s × 2^30 / 64; dramblast `get_mops` × 10^6. "Settled" intervals = the phase window with the first and last interval dropped, except that when a phase has ≤ 4 intervals (dramblast's find phase) all of them are kept. bandwidth_rand is also reported only after t ≥ 1.2 s because the first ~1 s runs before the power limit bites.

Results (`bwgap/tables/stream.md`, median (min–max) of 5 reps):

| metric | bw_double24 | bw_t1 | dramhit_rck_f10 |
|---|---|---|---|
| lines/s (G) [program] | 5.686 (5.626–5.716) | 6.192 (6.143–6.204) | 4.263 (4.157–4.351) |
| HBM GB/s [controllers] | 365.3 (361.3–367.3) | 400.9 (397.7–401.8) | 276.8 (274.5–280.4) |
| core GHz | 2.369 (2.323–2.390) | 2.567 (2.531–2.571) | 2.181 (2.153–2.201) |
| mesh GHz | 1.755 (1.735–1.765) | 1.863 (1.840–1.869) | 1.662 (1.644–1.701) |
| IPC | 1.92 | 0.54 | 1.74 (1.70–1.79) |
| package W | 348.8 | 349.1 | 347.7 |
| xq full % | 27.9 | 67.1 | 16.2 |
| fb_full % | 64.8 | 67.6 | 54.7 |
| L2-miss outstanding / thread | 26.5 | 25.2 | 26.2 |
| cycles/line (from rate) | 26.67 | 26.53 | 32.67 |

Observations: (i) bw_t1 reaches **401 GB/s at the controllers** in this session (the earlier "391" was an earlier session/thermal state; the 5 reps here span only 397.7–401.8), dramblast 277; ratio 1.448 at the controllers (lines/s ratio 1.452 here); (ii) outstanding L2 misses per thread are the same (~25–26) for all three, so the number of requests in flight is not the difference; (iii) bw_t1 has far more XQ-full time (67 % vs 16 %) — its queue is the saturated one; dramblast is *not* queue-limited, it issues fewer lines per cycle (32.7 vs 26.5 cycles/line); (iv) every run sits at the same ~348 W package power.
Raw excerpt (bandwidth_rand, `logs/E1_stream/bw_t1_r1/combined.log` tail) shows the program lines
`Total Data Proc : 1600.00 GB / Time Taken : 4.3587 seconds (based on 2.70 GHz) / Bandwidth : 367.08 GB/s / node 0 : 27.46 cycles/access` (this is from the E2 run `logs/E2_totals_core/bw_t1_x1_r1/program.out`; the stream log has the same format).

Caveat on E1: the stream includes power-limit transients (dramblast's find phase directly follows its insert phase), which is why E2 is the canonical number source.

## 4. E2 — differential totals (canonical per-line numbers)

**Method.** Each workload runs at 1× and 2× work: bandwidth_rand `NUM_ITERATIONS` 100 vs 200 (two binaries, built `gcc -O3 machine_stats/bandwidth.c -lpthread -lnuma -DRANDOM -DNUM_ITERATIONS=N`, which reproduces the md5 above bit-for-bit); dramblast `--read-factor 100` vs `200`. Around each process: `perf stat -a --per-socket -x, -e instructions:u,cycles:u,ref-cycles:u,<32 HBM rd/wr events>` (whole-process totals, socket 0 row, no intervals). Setup, allocation and the dramblast insert phase are identical in the two runs and cancel in the difference, so per line cost = (total₂ − total₁)/(lines₂ − lines₁); ΔT from the program (bandwidth_rand "Time Taken"; dramblast `find_ops/(get_mops·1e6)`). The 1× and 2× order alternates between reps. Why dramblast's `get_mops` is a valid ΔT: it is `2700 MHz × total_finds / avg_find_duration`, and every thread reports the same barrier-to-barrier duration, so throughput = finds / slowest-thread time.

Example raw excerpt (`logs/E2_totals_core/bw_t1_x1_r1/perf.csv`): 
`S0,64,375812383782,,instructions:u,…` `S0,64,693939439004,,cycles:u,…` `S0,64,735984354924,,ref-cycles:u,…` → 2.7 × 693.94/735.98 = 2.546 GHz; IPC 0.54; and per-box `S0,1,1673787289,,mem_rd,…` (CAS counts; ×32 B). dramblast raw: `logs/E2_totals_core/dramhit_rck_f10_x1_r1/program.out` ends with `global_find_cycle : 3466645254, find_ops : 5368709100, … get_mops : 4181`.

Median (min–max) over 5 reps (`tables/totals_E2_totals_core.md`; every rep in `tables/E2_per_rep.md`):

| workload | lines/s (G) | decimal GB/s of lines | core GHz | instr/line | cycles/line | IPC | HBM rd lines/line |
|---|---|---|---|---|---|---|---|
| bw_t1 | 5.949 (5.754–6.169) | 380.7 | 2.521 (2.511–2.548) | 14.0 | 26.36 (25.49–27.36) | 0.53 | 0.998 |
| bw_double24 | 5.704 (5.261–6.201) | 365.1 | 2.320 (1.892–2.386) | 51.0 | 26.33 (19.57–27.55) | 1.94 | 0.998 |
| dramhit_rck_f10 | 4.203 (4.116–4.295) | 269.0 | 2.276 (2.118–2.288) | 55.8 (55.3–55.8) | 32.11 (31.50–33.32) | 1.72 | 0.959 |
| dramhit_rck_f90 | 2.544 (2.492–2.702) | 162.8 | 2.033 (1.857–2.326) | 70.6 | 48.79 | 1.45 | 1.499 |

Notes: `bw_double24` rep 1 is an outlier (the 1× run took 5.46 s vs ~4.75 s in the other reps, so the difference is invalid: 19.6 cycles/line is not real); medians are used throughout. Reads per line < 1 for dramblast (0.96): some finds need no HBM read (cause untested: cache hits, skew, duplicates); 1.5 at fill 90 is the extra probe/line traffic. Writes/line ≈ 0.

**Decomposition (medians).** lines/s = 64 × GHz × u ÷ cycles/line:
- bw_t1: 64 × 2.521 / 26.36 = 6.121 G → u = 5.949/6.121 = 0.972.
- dramblast: 64 × 2.276 / 32.11 = 4.536 G → u = 4.203/4.536 = 0.927.
- ratio 5.949/4.203 = **1.415** = (2.521/2.276 = **1.108**) × (32.11/26.36 = **1.218**) × (0.972/0.927 = **1.049**, ratio of medians; direct per-rep u gives ~1.02).
u < 1 means some thread time is not counted in `cycles:u` (kernel time, blocking). The cause was not measured (a barrier wait cannot explain bw_t1's 0.97; for dramblast, early-finishing threads waiting at the barrier is one candidate). It is a ≤ 5 % effect favouring bandwidth_rand, not in the `human.md` factorisation.

## 5. E3 — instructions per line, and the memory-dependent / independent split

**Totals** are the E2 numbers above (hardware counter, no model): 14.0, 51.0, 55.8, 70.6 instr/line.

**Where they come from.** `perf record -e instructions:ppp -c 2000003` (precise, skid-free; one sample every 2 000 003 retired instructions) over a whole run of each program (`bwgap/run_sampling.sh` → `logs/E3_sampling/*.data`, program output `*.out`); the per-IP histogram is `perf script -F ip,sym | sort | uniq -c` (`bwgap/hist/*.ip.txt`). Since each retired instruction is sampled with equal probability, (samples at an address) × 2 000 003 / lines = executions of that instruction per line. Function disassembly: `bwgap/dis/` (`objdump -d -C`, from `nm -S`). `bwgap/sample_mix.py` combines them (output `tables/instr_mix.md`, which also lists every instruction of the loops with its sample count and class).

**Classification.** Taint analysis over the disassembly (`bwgap/instr_mix.py`): the source is the load of the line the prefetch brought in (the bucket `vmovdqa64 (%r10,%rdi,1),%zmm7` in find_batch; the `add (mem),reg` in bandwidth_rand). An instruction is **memory-dependent (D)** if it reads, through a register, a mask register or flags, anything derived from that load. Everything else is **independent (I)**. The load itself is reported as **L**. (A branch on loaded data makes the following instructions control-dependent; they are counted I — with a correctly predicted branch they do not wait for the data. Unknown mnemonics abort the script, so there is no silent default.)

**Results, rck find phase (fill 10), `tables/instr_mix.md`:**

| region | instr/find | class |
|---|---|---|
| find_batch hot loop (41 instr/iteration, 1 iteration per find): bucket load | 0.98 | L |
| … `vpcmpequq, kortestb, je, kshiftlb, vpcompressq, vmovq` (store of result) | 5.95 | **D** |
| … hash (`crc32`), queue pointer arithmetic, prefetch addresses, `prefetcht0/t2`, stores of the next batch entry | 34.02 | I |
| find_batch outside the loop (entry/exit, once per 16-key call: ~62 instr / 16) | 4.03 | I |
| harness find fill loop (`ZipfianTest::run`, 0x46ae80–0x46b090: key load, copy to the argument buffer, ID store, prefetch every 8 keys) | 10.79 | I (loads the *key stream*, not the table line) |
| **total** | **55.76** | measured 55.3–55.8 ✓ |

→ load 0.98 (1.8 %), memory-dependent 5.95 (10.7 %), independent 48.83 (87.6 %). The reprobe path of find_batch is never executed at fill 10 (its instructions have 0–1 samples), so r ≈ 0 and the 41-instr hit path is the whole story. bandwidth_rand t1 (`logs/E3_sampling/bw_t1`): loop of 14 instructions (the `instructions` counter counts the fused `cmp`+`jne` as two: exactly 14.00/line; sampling attributes both to the `jne`), 1 L (`add (%rdi,%rax,1),%r14`), 0 D, 13 I — the load result only feeds the accumulator, nothing else waits on it. bw_double24: 51-instr loop: 1 L, 0 D, 50 I (24 of them `add $1`).

Caveat: the loop-carried dependence classification is static; dependent ops of different finds are not chained (each find's mask is fresh), which is why a long serial chain (E4 t1dpad) is a pessimistic model of dramblast's dependent set.

## 6. E4 — instruction ladder (does dependence or just count matter?)

bandwidth_rand t1 plus N extra instructions per line, either independent (`-inst t1pad -pad N`: adds on registers unrelated to the loaded line) or dependent (`-inst t1dpad -pad N`: N serial adds on the loaded value). Same differential method, 2 reps (`tables/ladder.md`, medians):

| N | instr/line (indep) | cycles/line indep | cycles/line dep | core GHz indep / dep | GB/s of lines indep / dep |
|---|---|---|---|---|---|
| 0 | 14 | 27.03 | 26.06 | 2.526 / 2.594 | 374 / 397 |
| 8 | 24 | 26.16 | 25.56 | 2.466 / 2.526 | 378 / 394 |
| 16 | 32 | 25.40 | 25.86 | 2.437 / 2.527 | 384 / 390 |
| 24 | 40 | 26.51 | 26.21 | 2.515 / 2.491 | 381 / 382 |
| 32 | 48 | 27.56 | 27.56 | 2.531 / 2.497 | 371 / 366 |
| 48 | 64 | 30.57 | 32.16 | 2.579 / 2.565 | 342 / 323 |

Reading: cycles/line is flat at ~25.5–27 (the memory plateau; N = 0 differences of ~1 are run-to-run noise, bw_t1 spans 25.5–27.4 across E2 reps) until the loop reaches ~40–48 instr/line (IPC ≈ 1.5–1.7), then rises ~0.19 cycle per extra instruction (IPC → 2.1). Interpolating to dramblast's 55.8 instr (between N=32 and N=48): independent ≈ 29.0 cycles, dependent ≈ 30.1 (the dependent rows have one instruction fewer per line: 31/47/63 vs 32/48/64). Measured dramblast 32.1, bw_t1 26.36. So instruction count explains ≈ 2.6 of the 5.75-cycle gap and **≈ 3.1 cycles (≈ 10 %; ≈ 2.0 if the dependent ladder is the better model) are unexplained**. Noise: the ladder has 2 reps and the N = 0 rows (same code for t1pad/t1dpad) differ by ~1 cycle, as large as the dependent-vs-independent differences, so 'dependence did not raise cycles' means 'not detectable at this precision'. Instruction count is also not a clean predictor: dramblast at IPC 1.72 takes 32 cycles, ladder N=32 at IPC 1.74 takes 27.6; and with 64 threads on 32 cores two hardware threads share each core's issue width. Candidates (untested here): DDR key-stream reads and late fill-buffer hits (`report-fbfull.md §3`: fb_full is 55 % for dramblast), hash-table-queue stores, finds that need no HBM read (0.96 reads/line).
The ladder's clock column is flat (2.44–2.59 GHz) because adding instructions *lowers* the HBM traffic (342 vs 374 GB/s), freeing power; it does not isolate instruction power.

## 7. Verdict on the `human.md` hypothesis

| claim | result |
|---|---|
| 391/275 = 1.42 = 1.18 (clock) × 1.21 (cycles/line) | Reproduced: E1 1.448 = 1.177 × 1.231 (no third factor); E2 1.415 = 1.108 × 1.218 × 1.049 (u, ratio of medians; ~1.02 per rep). The E2 clock factor (1.108) is smaller than E1's (2.567/2.181 = 1.177). The differential method cancels setup and the insert→find transient, yet E2 dramblast is *higher* (2.276 vs 2.181) and E2 bw_t1 *lower* (2.521 vs 2.567), so 'transients' is not established as the reason; E2 dramblast clock is also bimodal across reps (2.12–2.14 vs 2.28). E1's dramblast window has only 4 intervals of 200 ms and `settled()` keeps all of them when ≤ 4 exist (dropping boundary intervals leaves 1–2; one rep gave 260 GB/s / 1.99 GHz), so E1's dramblast spread is understated. |
| "it is really instruction/line" | Mostly: 55.8 vs 14.0 instr/line (4×). In the ladder, instructions > ~40/line cost cycles; ≈ 2.6 of the 5.75 extra cycles (≈ 3.1 remain). |
| (1) memory-dependent instructions raise cycles/line directly | **Not supported (not detectable)**: dramblast has 5.95 (10.7 %), and a serial dependent chain in bandwidth_rand costs the same as independent padding within the ~1-cycle noise for N ≤ 32. |
| (2) memory-independent instructions raise power → lower clock | **Partly supported, not separable here**: power is ~348 W in all runs. bw_double24 (51 instr/line of plain independent `add`, plus a second far/near line stream) runs 2.37 GHz (E1) / 2.32 (E2) versus bw_t1's 2.57 / 2.52 — an 8 % drop, so independent padding does lower the clock (not a pure test: double also changes the traffic pattern). In E2 double24 (2.320) is already close to dramblast (2.276), so most of the clock factor is reproduced by padding-like work. In E1 dramblast is lower still (2.18 vs 2.37) with a lower mesh clock (1.66 vs 1.75) despite 24 % less HBM traffic and fewer instructions/s (~243 vs ~291 G/s socket-wide); that residual could be instruction kind or the DDR key stream, but this evidence does not decide it. The ladder's clock column is confounded by HBM traffic changing with N. A power-per-class experiment (as `report-energy.md`) on the dramblast loop is the next step; not run. |
| "dramblast is higher in both categories" | Yes for both: D 5.95 vs 0, I 48.8 vs 13. |

## 8. Corrections to earlier reports (GiB/GB)

bandwidth_rand's printed "GB/s" is GiB/s, so cycles/line computed from it in older reports is ~7.4 % too high: the bw_t1 plateau is ~26.4 cycles/line (not ~28.4), and "program GB/s vs controller GB/s differ by 8–10 %" in `report-throttling.md §4` is the GiB/GB factor (1.074), not an accounting gap. `report-fbfull.md §1.4/§4.3`, `report-attempt2.md` and the `report-throttling.md` AVX-512 table need the same correction; they are listed here and not yet rewritten in place.

## 9. Reproduction

```
cd /opt/DRAMHiT/scripts/eurosys_2026/optimize_hbm/bwgap
# 0. state (run once; or pass --reserve to run_totals.py/run_stream.py, which calls runlib.reserve_pool()):
#    sudo /opt/DRAMHiT/scripts/reserve_hugepages.sh reset; sudo /opt/DRAMHiT/scripts/reserve_hugepages.sh n2_12gb_17408mb n0_0gb_8192mb n1_0gb_8192mb
#    prefetchers off: for c in $(seq 0 127); do sudo wrmsr -p $c 0x1a4 0x2f; done ; cpufreq min=max=2.7 GHz on node 0's cpus (scripts/constant_freq.sh style), C-states disabled; need sudo for perf uncore events
./env_snapshot.sh > logs/env_start.txt
# binaries: dramblast rck = ../attempt4/rck/dramhit. Build: git checkout a0515d1, apply ../attempt4/cumulative.diff (the cas_kht.hpp/CMakeLists.txt options), then the paper flags + -DCAS_PREFETCH_INSERTION=DOUBLE -DPREFETCH=DOUBLE -DCAS_FIND_RING_OFFSETS=ON -DCAS_FIND_COMPRESS_VALUE=ON -DCAS_FIND_KSHIFT=ON (full list: ../report-attempt4.md, build table); check md5 f209f705…
# bandwidth.c needs the uncommitted changes: git apply bandwidth_all_changes.diff on a0515d1's machine_stats/bandwidth.c
gcc -O3 ../../machine_stats/bandwidth.c -o bin/bandwidth_rand_it100 -lpthread -lnuma -DRANDOM -DNUM_ITERATIONS=100   # md5 b91b7be1…
gcc -O3 ../../machine_stats/bandwidth.c -o bin/bandwidth_rand_it200 -lpthread -lnuma -DRANDOM -DNUM_ITERATIONS=200   # md5 91d9f8e5…
python3 run_totals.py --set core --reps 5       # E2  (≈ 30 min)   -> logs/E2_totals_core/
python3 run_stream.py --reps 5                  # E1               -> logs/E1_stream/
python3 run_totals.py --set ladder --reps 2     # E4               -> logs/E2_totals_ladder/
./run_sampling.sh                               # E3 samples       -> logs/E3_sampling/
for w in dramhit_f10 bw_t1 bw_double24; do perf script -i logs/E3_sampling/$w.data -F ip,sym | awk '{print $1,$2}' | sort | uniq -c | sort -k2 > hist/$w.ip.txt; done
python3 analyze_gap.py all                      # tables/*.md
python3 sample_mix.py                           # tables/instr_mix.md
./env_snapshot.sh > logs/env_end.txt
```
Exact commands per run are stored in `cmd.txt` beside each log. dramblast command (from `runlib.dramhit_cmd`): `dramhit --mode 11 --ht-type 3 --ht-size 536870912 --ht-fill 10 --num-threads 64 --numa-split 10 --np_cpu_node_msk 1 --np_mem_node_msk 4 --np_mem_local 0 --batch-len 16 --find_queue 64 --no-prefetch 0 --hw-pref 0 --insert-factor 100 --read-factor 100 --skew 0.01 --seed 1775762440565610239`. bandwidth_rand t1: `bandwidth_rand_it100 -m 256mb -pattern n0a2t64 -freq 2.7 -inst t1 -pad 0 -near 8 -lookahead 64 -mode r`. The `bandwidth.c` changes (modes t1pad/t1dpad/double, `-pad`, `-near`, overridable `NUM_ITERATIONS`) are in `bwgap/bandwidth_all_changes.diff`. Run-to-run variation: bw_t1 cycles/line 25.5–27.4, dramblast 31.5–33.3 across reps (the system is power-limited, so thermal state matters; `runlib.cooldown()` enforces ≥ 12 °C margin).

File map: `logs/` raw; `tables/` derived (`totals_*.md/json`, `E2_per_rep.md`, `stream.md/json`, `ladder.md`, `instr_mix.md`); `dis/`, `hist/` disassembly and sample histograms; `runlib.py` shared definitions; `instr_mix.py`, `sample_mix.py` classification.

## 10. Limits

Single machine; 5 reps (2 for the ladder); u and the unexplained ~3 cycles/line are not decomposed; power per instruction class not measured on the dramblast loop itself; the D/I split is static/taint-based, weighted by sampled execution counts; the sampling runs include the insert phase (histograms are restricted by address). E1 and E2 cycles/line use different definitions (E1 from rate, E2 from counters). Controller GB/s (277, E1) and lines×64 B (269, E2) differ because dramblast reads 0.96 lines per find and E1's window is 4 intervals. `dramhit_rck_f90` rows are for reference only. The mix step's addresses are valid only for the exact rck binary (md5 above); thread layout: 64 threads = 2 hardware threads on each of node 0's 32 cores (cpu ids 0,2,…,126).

## 11. E5 — building dramblast up from bw_double ("mimic" mode)

Idea (from the discussion): since independent padding is free in cycles (bw_double24 26.3 vs bw_t1 26.4), take the double-prefetch loop and add dramblast's remaining ingredients one at a time, to see which one moves cycles/line from 26 to 32. New `-inst mimic -stage S` in `bandwidth.c` (cumulative stages; `-pad` still adds independent adds):

| stage | adds (per line) | instructions it contributes |
|---|---|---|
| 1 | 64 B vector load of the line (`vmovdqa64 zmm`) instead of the 8 B scalar load; result xor-accumulated | load |
| 2 | key from an L1-resident array → `vpbroadcastq`, `vpcmpequq` (mask 0x55) on the loaded line, `kortestb`, `je` (never taken: every find hits) | the **memory-dependent** compare/branch set |
| 3 | `kshiftlb`, `vpcompressq`, `vmovq` store + 32-bit id store into a 64-entry result ring | rest of the dependent set (+ stores) |
| 4 | 3 stores of a 32 B queue entry into a 64-entry ring | queue writes |
| 5 | the key now comes from a per-thread 0.84 M × 8 B array **in DDR** (node 0), prefetcht0 every 8 keys, 16 keys ahead (as the harness does) | no new instructions; DDR key stream |

Same differential-totals method as E2, 3 reps, `-pad 0` (`logs/E2_totals_mimic/`, `tables/totals_E2_totals_mimic.md`, runner `run_totals.py --set mimic`, binaries `bin/bandwidth_rand_mimic_it{100,200}` md5 `f4205fcd…`/`973bf160…`). Medians:

| workload | instr/line | cycles/line | core GHz | lines/s (G) | GB/s of lines | IPC |
|---|---|---|---|---|---|---|
| bw_t1 (E2) | 14.0 | 26.36 | 2.521 | 5.949 | 380.7 | 0.53 |
| mimic stage 1 | 20.0 | 25.07 | 2.334 | 5.819 | 372.4 | 0.80 |
| mimic stage 2 | 34.1 | 25.45 | 2.293 | 5.800 | 371.2 | 1.34 |
| mimic stage 3 | 49.1 | 28.45 | 2.345 | 5.215 | 333.8 | 1.73 |
| mimic stage 4 | 58.1 | 29.68 | 2.308 | 4.877 | 312.1 | 1.96 |
| **mimic stage 5** | **58.1** | **32.41** | **2.202** | **4.317** | **276.3** | 1.79 |
| dramblast rck fill 10 (E2) | 55.8 | 32.11 | 2.276 | 4.203 | 269.0 | 1.72 |

Reading:
- **Stage 5 reproduces dramblast** (cycles/line 32.4 vs 32.1, 4.32 vs 4.20 G lines/s, similar instruction count and clock) with a loop that has none of the hash-table logic. This is a mimic, not proof that the causes are identical, but it is a strong constraint.
- **Dependent compare/branch (stage 2): free** (+0.4 cycles for +14 instructions, inside noise; the stage-2 reps span 17–26 cycles because one rep hit a fast outlier, so the median is what to read).
- **Stages 3–4 (compress, stores, queue writes): +4.2 cycles, but that is what instruction count alone predicts**: the padding ladder (E4) gives 27.6 at 48 and ~29.4 at 58 instr/line; the mimic gives 28.5 at 49 and 29.7 at 58. Adding 16 pad instructions to each stage costs another 3–5 cycles (the ~0.19 cycle/instr slope), in every stage.
- **Stage 5: +2.7 cycles with zero extra instructions.** That is the formerly unexplained part of the gap: the harness's DDR key stream (0.125 extra DDR lines per find, plus the key load and its fill-buffer occupancy) costs ≈ 2.7 cycles/line. HBM reads/line rise from 0.998 to 1.000.
- Clock: it falls from 2.52 (t1) to ~2.30 as soon as the loop reaches 20–35 instr/line (stage 1–2, power-limited), and to 2.20 at stage 5; mimic stage 5 and dramblast agree on it within 3 %.

Revised answer to "why are dramblast's cycles/line higher than bw_t1": ≈ 3 cycles from instruction count past ~40/line (the find logic, mostly independent), ≈ 2.7 from the DDR key stream, ~0 from the memory-dependent compare/branch set; the remaining ~0.3 is noise. This supersedes the "unexplained ≈ 3.1 cycles" in §0/§6/§7 — the stage-5 step is the candidate explanation, with the caveat that it is demonstrated on a mimic. Note the key stream belongs to the benchmark harness (`ZipfianTest::run`), not the hash table; the earlier `attempt5` lookahead experiments (16 → 512 keys) did not help, so it is not simply a late-prefetch problem.

## 12. E12 — bw_t1 vs dramblast (keys bound to HBM), 100 ms interval streams, everything in HBM

**Question.** With the harness keys also in HBM (§ `zipfian_key_bind.diff`), how do the two programs compare on HBM bandwidth, clocks, power, energy and instructions, sampled every 100 ms?

### 12.1 What was run (exact commands)
Build of the dramblast binary (rck options + the harness change; `DRAMHiT_VARIANT=2025_INLINE` is required, without it the build is ~25 % slower): in `attempt6/build`, `cmake ../../../../.. -DCMAKE_BUILD_TYPE=RelWithDebInfo -DBRANCH=simd -DBUCKETIZATION=ON -DCAS_FAST_PATH=ON -DCAS_PREFETCH_INSERTION=DOUBLE -DPREFETCH=DOUBLE -DCAS_FIND_RING_OFFSETS=ON -DCAS_FIND_COMPRESS_VALUE=ON -DCAS_FIND_KSHIFT=ON -DUNIFORM_PROBING=ON -DREAD_BEFORE_CAS=ON -DHASHER=crc -DCPUFREQ_MHZ=2700 -DKEY_LEN=8 -DKMER_LEN=8 -DBENCHMARK_BACKEND=NONE -DDRAMHiT_VARIANT=2025_INLINE && make -j16 dramhit`; binary `attempt6/ddrhbm/dramhit` md5 `bc1f859f35745461b2192a200bd513cb`. The harness change (`bwgap/zipfian_key_bind.diff`, `src/tests/zipfian_test.cpp`): when `--numa-split 10`, each thread allocates its hugepage-backed key partition empty (`reserve`), `mbind`s it to the same node as the table (`np_mem_node_msk`, or the nearest HBM node with `np_mem_local`), then fills it (`resize`) so the pages are first-touched on HBM. `NO_KEY_BIND=1` in the environment turns the bind off (reference run).

Runs (each program under `sudo perf stat -a --per-socket -I 100 -x,` with events `cycles, instructions, ref-cycles, l1d_pend_miss.fb_full, offcore_requests_outstanding.data_rd, offcore_requests.data_rd, xq.full_cycles, power/energy-pkg/`, the 32 `uncore_hbm_N` read/write CAS events and `uncore_cha_0` clock; program output interleaved in `combined.log`), 5 reps interleaved rep-major, ≥ 12 °C thermal margin before each run (`runlib.cooldown`):
```
cd bwgap
python3 run_stream.py --reps 5 --interval-ms 100 --read-factor 400 \
    --workloads bw_t1 dramhit_keyshbm_f10 dramhit_keysddr_f10 --out E12_100ms
python3 analyze_100ms.py            # -> tables/E12_summary.md (+ time series), tables/E12_intervals.csv (every interval)
```
- `bw_t1`: `bin/bandwidth_rand_it100 -m 256mb -pattern n0a2t64 -freq 2.7 -inst t1 -pad 0 -near 8 -lookahead 64 -mode r` (64 threads on node 0's even cpus, 256 MiB per thread = 16 GiB, bound to node 2).
- `dramhit_keyshbm_f10`: the standard dramblast command (§9) with `--read-factor 400` (find phase ≈ 5 s ⇒ 15 intervals), binary above, keys in HBM. `dramhit_keysddr_f10`: same with `NO_KEY_BIND=1` (keys in DDR, **not** all-HBM; reference only).
- State: `logs/env_e12.txt` (prefetchers off 0x2f, PL1 350 W, cpufreq min=max 2.7 GHz, margin 11 °C at the end), md5s in `logs/e12_md5.txt`.

### 12.2 Is all data really in HBM? (checked, not assumed)
`check_placement.sh` samples `/proc/<pid>/numa_maps` during the run (`logs/placement_*.txt`):
- bw_t1: hugetlb 16 384 MiB, all on node 2 (HBM); everything else < 2 MiB.
- dramblast (keys bound): hugetlb 8 704 MiB (8 192 table + 64 × 8 MiB key partitions), all on node 2. The only non-HBM memory: a 1 024 MiB ordinary-page allocation on node 1 and ~10 MiB of heap/files.
- Whether that 1 GiB is touched during find: DDR memory-controller counters (`uncore_imc/cas_count_read|write/`, both sockets, `logs/ddr_check_*.txt`, `tables/ddr_traffic_dramhit_find.md`) show ≤ 0.1 GB/s of DDR traffic through the whole dramblast run (background level), vs ~290 GB/s on HBM; bw_t1 max 0.16 GB/s. So during the measured window both programs read/write only HBM.

### 12.3 Results (`tables/E12_summary.md`; steady state = ≥ 1.0 s into the window, boundary intervals dropped; median over all steady intervals [median of per-rep medians; min–max of per-rep medians], 5 reps)
| metric | bw_t1 | **bw_t1, core held at 2.2 GHz** | **dramblast best (deep vectorization, queue 128 / batch 64, key prefetch 64 t2)** | dramblast, keys in HBM | dramblast, keys in DDR (ref.) |
|---|---|---|---|---|---|
| HBM GB/s (controllers) | 397.0 [397.6; 393.8–399.8] | **373.7** [373.1; 372.8–374.3] | **328.7** [327.4; 326.5–330.7] | **293.7** [293.8; 292.8–295.4] | 263.9 |
| core GHz | 2.536 [2.535; 2.530–2.564] | 2.195 [2.195; 2.194–2.195] | 2.115 [2.116; 2.106–2.131] | 2.203 [2.205; 2.188–2.209] | 2.173 |
| mesh GHz | 1.841 | 1.890 | 1.632 | 1.681 | 1.665 |
| IPC | 0.54 | 0.59 | 1.57 | 1.68 | 1.73 |
| instr rate per thread (G/s) | 1.36 | 1.28 | 3.32 | 3.70 | 3.74 |
| package W | 347.5 | 348.9 | 350.0 | 348.2 | 348.5 |
| xq full % / fb_full % | 67.4 / 67.5 | 63.0 / 66.3 | 41.2 / 60.4 | 13.8 / 53.8 | 14.1 / 54.3 |
| program lines (finds) per s (G) | 6.134 | 5.776 | 4.601 | 4.153 | 4.190 |
| window from program (s) | 4.38 | 4.65 | 4.67 | 5.17 | 5.13 |
| energy per program line (nJ) | 56.6 | 60.4 | 76.1 | 83.8 | 82.9 |
| energy per HBM line (nJ) | 56.4 | 59.8 | 68.2 | 75.6 | 84.5 |
| HBM lines per program line | 1.013 | 1.012 | 1.123 | 1.106 | 0.982 |
| cycles per HBM line (64 × core GHz ÷ HBM lines/s) | 26.1 | 24.1 | 26.4 | 30.6 | 33.7 |

The **dramblast best** column is the best configuration found later (§17–§20, scalar hash reads; §21 showed the SIMD-load variant is slower). Settings:
- Build `attempt10/deepvec/dramhit`: 16 B find-queue entries plus `-DDEEP_VECTORIZATION=ON`.
- `--find_queue 128 --batch-len 64`, env `KEY_PF_DIST=64 KEY_PF_HINT=t2`.
- Keys in HBM, fill 10.

It is computed from the E21 sweep runs (`logs/E21_qb/a10_dv_q128_b64_r{1,2,3}`, 3 reps, not 5; 13–14 steady intervals each) with the same formulas, via `bwgap/col_e12.py E21_qb a10_dv_q128_b64`. Those runs came days after the other columns, not interleaved with them.

Against the `dramblast, keys in HBM` column:
- HBM +12 % (293.7 → 328.7 GB/s) and finds/s +10.8 % (4.153 → 4.601 G).
- Cycles per HBM line 30.6 → 26.4, about bw_t1's 26.1. The core clock is lower (2.203 → 2.115).
- So the remaining gap to bw_t1 (397.0 / 328.7 = 1.21×) is now almost entirely clock: 2.536 / 2.115 = 1.20.

The `bw_t1 @ 2.2 GHz` column was added afterwards with the same protocol (5 reps, 100 ms, `analyze_100ms.py` reads it from the same directory as workload `bw_t1_c2200`): `python3 run_stream.py --reps 5 --interval-ms 100 --cap 2200 --workloads bw_t1_c2200 --out E12_100ms` (cpufreq min = max = 2200 MHz on node 0's cpus for the duration, restored to 2700 afterwards; verified). It was run after the other three, not interleaved with them.

Per-interval time series (HBM GB/s, core/mesh GHz, IPC, W per 0.5 s bin, median over reps) are in `tables/E12_summary.md`; every raw 100 ms row in `tables/E12_intervals.csv`. Shape: both programs start at higher clocks and power (bw_t1 2.69 GHz / 376 W in the first 0.5 s; dramblast 2.25 GHz / 377 W) and settle to ~348 W within ~1 s; after that the series are flat (bw_t1 core 2.53–2.56 GHz, HBM 397–399 GB/s; dramblast core 2.19–2.20 GHz, HBM 292–296 GB/s).

### 12.4 Reading it (north star: dramblast HBM bandwidth vs bw_t1)
- **Holding bw_t1's core clock at dramblast's (2.2 GHz) costs it only 6 % (397 → 374 GB/s)**, because it is memory-bound and its mesh clock rises (1.84 → 1.89 GHz). Its cycles per HBM line fall to 24.1. So at equal core clock the gap is still 373.7 / 293.7 = **1.27×, i.e. almost all of it is cycles per HBM line (30.6 / 24.1 = 1.27)**; the clock explains only ~6 % of the original 35 %.
- **The HBM-bandwidth gap is 397.0 / 293.7 = 1.35×.** (Part of dramblast's 294 GB/s is the key stream: 1.106 HBM lines per find, vs 1.0 for the table; the table-only bandwidth is ≈ 0.96 × 4.15 G × 64 B ≈ 255 GB/s.)
- **It factorises into the clock and the cycles per HBM line**, because HBM lines/s = 64 × core GHz ÷ cycles-per-HBM-line: 1.35 = **1.151** (core 2.536 / 2.203) × **1.172** (cycles per HBM line 30.6 / 26.1; product 1.349). So cycles per HBM line still matter: with the keys in HBM they are 30.6 vs 26.1, a 17 % gap, as large as the clock gap. (The per-find cycles, 33 for 1.1 lines, are 30 per line.)
- Power is identical (347.5 vs 348.2 W): both sit at the ~348 W limit; the energy per HBM line differs 56 vs 76 nJ (+34 %).
- Moving the keys to HBM raised dramblast's HBM bandwidth by 11 % (264 → 294 GB/s) but not its find throughput (4.19 → 4.15 G/s); the extra bytes are the key stream itself.
- What remains unexplained is why cycles per HBM line are 17 % higher: §5/§11 attribute ~2.6 cycles to instruction count and the rest to stores/key stream in the mimic; the clock drop is power-limited (§ throttling) and not separable here.

Caveats: 5 reps; the first 1.0 s of each window is excluded (power-limit transient); mesh clock is cha_0's; energy is package energy of socket 0 (includes the idle socket-0 floor); `bandwidth_rand` program lines/s use its printed GiB/s × 2^30 / 64.

### 12.5 The E5 mimic stages under the same 100 ms protocol, all in HBM

**What changed for this.** `bandwidth.c` reads `MIMIC_KEY_NODE` (default 0 = DDR, the E5 behaviour) to choose the node of stage 5's per-thread key array (`numa_alloc_onnode`, 838 860 × 8 B, ordinary 4 KiB pages; dramblast's key partitions are hugepages). Rebuilt with the §9 gcc line: `bin/bandwidth_rand_mimic_it100` md5 `3546815228ad8ac3ef16f894991befd3` (`logs/e12_mimic_md5.txt`). Stages 1–4 behave exactly as before; their 64 keys per thread live in an L1-resident array, so there is no key stream. Placement check (`check_placement.sh`, `logs/placement_mimic_s5_keynode{2,0}.txt`): with `MIMIC_KEY_NODE=2` the 16 384 MiB hugetlb buffer and 410 MiB of keys are on node 2 (HBM), with ~17 MiB of stacks/heap on node 0. With `MIMIC_KEY_NODE=0` the keys (426 MiB) are on node 0.

**Run:**
```
cd bwgap
python3 run_stream.py --reps 5 --interval-ms 100 --out E12_100ms \
    --workloads mimic_s1 mimic_s2 mimic_s3 mimic_s4 mimic_s5_keyshbm mimic_s5_keysddr
python3 analyze_100ms.py
```
- Each workload is `bin/bandwidth_rand_mimic_it100 -m 256mb -pattern n0a2t64 -freq 2.7 -inst mimic -stage S -pad 0 -near 8 -lookahead 64 -mode r`, with `env MIMIC_KEY_NODE=2|0` for stage 5.
- Same perf events, cooldown and rep-major interleaving as §12.1, and the same state (`logs/env_e12_mimic.txt`: 0x1a4 = 0x2f, PL1 350 W, 2.7 GHz).
- These runs came after the §12.3 columns, not interleaved with them.
- Rep 1 of stages 1–4 is low (e.g. s1 361 GB/s vs 390–404 in the others; it ran right after the placement test). The medians below are robust to it.

Medians (per-rep min–max for HBM GB/s are in `tables/E12_summary.md`):

| metric | bw_t1 | s1 vector load | s2 + dep. cmp/branch | s3 + compress/stores | s4 + queue writes | **s5, keys in HBM** | dramblast, keys in HBM | s5, keys in DDR (ref.) | dramblast, keys in DDR (ref.) |
|---|---|---|---|---|---|---|---|---|---|
| HBM GB/s | 397.0 | 394.2 | 369.6 | 331.5 | 310.4 | **308.4** | 293.7 | 281.6 | 263.9 |
| program lines (finds) / s (G) | 6.134 | 6.128 | 5.751 | 5.180 | 4.828 | **4.286** | 4.153 | 4.356 | 4.190 |
| core GHz | 2.536 | 2.400 | 2.327 | 2.284 | 2.240 | **2.314** | 2.203 | 2.305 | 2.173 |
| mesh GHz | 1.841 | 1.778 | 1.734 | 1.708 | 1.696 | 1.730 | 1.681 | 1.718 | 1.665 |
| IPC | 0.54 | 0.81 | 1.33 | 1.74 | 1.96 | 1.70 | 1.68 | 1.74 | 1.73 |
| instr rate / thread (G/s) | 1.36 | 1.93 | 3.09 | 3.98 | 4.40 | 3.93 | 3.70 | 3.99 | 3.74 |
| package W | 347.5 | 349.2 | 348.8 | 349.0 | 348.9 | 348.8 | 348.2 | 349.8 | 348.5 |
| xq full % / fb_full % | 67.4 / 67.5 | 78.3 / 76.9 | 42.2 / 67.3 | 9.7 / 60.0 | 2.4 / 56.0 | 2.4 / 61.0 | 13.8 / 53.8 | 2.2 / 62.0 | 14.1 / 54.3 |
| HBM lines per program line | 1.013 | 1.017 | 1.011 | 1.003 | 1.004 | 1.122 | 1.106 | 1.009 | 0.982 |
| energy per program line (nJ) | 56.6 | 57.1 | 60.8 | 67.4 | 72.3 | 81.2 | 83.8 | 80.2 | 82.9 |
| energy per HBM line (nJ) | 56.4 | 56.0 | 60.2 | 67.4 | 72.1 | 72.6 | 75.6 | 79.6 | 84.5 |
| **cycles per HBM line** | 26.1 | 25.0 | 25.6 | 28.3 | 29.8 | **30.7** | **30.6** | 33.5 | 33.7 |

Reading:
- **The mimic reproduces dramblast's cycles per HBM line with all data in HBM:** 30.7 vs 30.6 with keys in HBM, and 33.5 vs 33.7 with keys in DDR. What it does not reproduce is the clock: mimic s5 runs at 2.31 GHz vs dramblast's 2.20. That 5 % is why the mimic is 3–5 % faster (308 vs 294 GB/s; 4.29 vs 4.15 G finds/s). With 2.20 GHz and 30.7 cycles the mimic would give 64 × 2.20 / 30.7 × 64 B ≈ 293 GB/s.
- **Bandwidth step by step (HBM GB/s):** 397 → 394 (s1) → 370 (s2) → 332 (s3) → 310 (s4) → 308 (s5, keys in HBM). The two big steps are s2 (−6 %) and s3 (−10 %). In cycles per HBM line, s1 −1.1, s2 +0.6, s3 +2.7, s4 +1.5, s5 +0.9.
- **Factorised as clock × cycles per HBM line** (HBM lines/s = 64 × GHz ÷ cycles), bw_t1 → s4 is 397 / 310 = 1.28 = 1.13 (clock 2.536 / 2.240) × 1.14 (cycles 29.8 / 26.1).
  - The clock falls steadily with instruction rate: 1.36 → 4.40 G instr/s per thread gives 2.54 → 2.24 GHz.
  - s5 has *fewer* instructions per second than s4 (3.93 vs 4.40) and its clock comes back up to 2.31. This is consistent with the clock tracking instruction rate at a fixed ~349 W, as in §11.
- **The queue picture flips:** XQ-full falls from 67–78 % (bw_t1, s1) to ~2 % from s4 on, and fb_full falls from 77 % to ~56–62 %. bw_t1 and s1 keep the uncore request queue saturated. By s3–s4 the loop no longer issues misses fast enough to fill it. The cycles go to executing the find work between misses, not to waiting on a full memory pipe. This is the most direct pointer for the north star: dramblast leaves memory-level parallelism on the table, it isn't HBM-limited.
- **s5's key stream:**
  - With the keys in HBM it adds 0.12 HBM lines per find and costs +0.9 cycles per HBM line. Total HBM bandwidth is about flat vs s4 (310 → 308), but finds/s drop 11 % (4.83 → 4.29), because 11 % of the lines are now keys.
  - With the keys in DDR, HBM sees only table lines and the key latency costs +3.7 cycles per HBM line.
  - So "keys in HBM" is the better placement for HBM bandwidth but not for finds/s (4.29 vs 4.36 G/s for the DDR case).
- **Energy per program line** climbs with each stage (57 → 81 nJ) at constant ~349 W. It is power ÷ throughput, as in §12.4, not a separate cause.

### 12.6 Check: does every step factorise into clock × cycles per HBM line? (`bwgap/check_decomp.py` → `tables/E12_decomp.md`)
Per rep, medians of the steady intervals of: HBM GB/s, core GHz (2.7 × cycles / ref-cycles), **active cpus** (ref-cycles / (dt × 2.7 GHz), measured, the model assumes 64) and **cycles per HBM line measured directly** (socket-0 cycles / HBM lines, not derived from bandwidth). For each step A → B and each rep k (rep k of every workload ran in the same round): bandwidth ratio vs clock ratio × active ratio ÷ cycle ratio. Medians over reps 2–5 (rep 1 excluded as in §12.5; including it changes no ratio by more than 0.004):

| step | HBM GB/s ratio | clock ratio | cycles-per-line effect (1 / ratio) | model | residual (min..max over reps) |
|---|---|---|---|---|---|
| bw_t1 → s1 | 1.006 | 0.952 | 1.053 | 1.002 | −0.2 % (−0.2..+1.0) |
| s1 → s2 | 0.932 | 0.962 | 0.965 | 0.931 | +0.1 % (−0.6..+1.2) |
| s2 → s3 | 0.896 | 0.988 | 0.913 | 0.900 | −0.6 % (−0.9..+0.7) |
| s3 → s4 | 0.936 | 0.986 | 0.948 | 0.933 | +0.3 % (−0.9..+0.4) |
| s4 → s5 (keys HBM) | 0.990 | 1.027 | 0.964 | 0.990 | +0.1 % (−0.6..+0.5) |
| s5 (keys HBM) → dramblast (keys HBM) | 0.948 | 0.943 | 1.009 | 0.946 | +0.0 % (−0.7..+1.0) |
| **bw_t1 → dramblast (keys HBM)** | **0.740** | **0.869** | **0.856** | 0.740 | −0.0 % (−0.5..+0.9) |
| bw_t1 → bw_t1 @ 2.2 GHz | 0.939 | 0.866 | 1.086 | 0.942 | −0.1 % |
| s4 → s5 (keys DDR) | 0.903 | 1.018 | 0.884 | 0.900 | +0.3 % |

- Active cpus are 63.8–64.0 in every workload (no stalled or early-finishing threads in the steady window), and the measured cycles per HBM line agree with `64 × GHz ÷ lines/s` within 0.6 %. So the model holds with ≤ ~1 % residual for every step, and nothing else (thread count, idle time) is needed.
- Where each factor bites: the **clock** falls at bw_t1 → s1 (−4.8 %), s1 → s2 (−3.8 %) and mimic s5 → dramblast (−5.7 %); the **cycles per HBM line** rise at s1 → s2 (+3.5 %), s2 → s3 (+9.5 %), s3 → s4 (+5.5 %). bw_t1 → s1 and s4 → s5 are the two steps where a clock change and a cycles change cancel.
- End to end, bw_t1 → dramblast = 0.869 (clock) × 0.856 (cycles) ≈ half and half (log shares 46 % / 52 %, active 2 %).

## 13. E13 — deep vectorization of the find fast path (attempt 7)

**Idea:** process the find ring 4 entries at a time (pop 4, probe 4, write 4 results, push 4) instead of one. The plan, with designs and static verdicts, is in `~/.claude/plans/you-divide-number-of-recursive-scroll.md`. Gather probes and a vector push were rejected before building: `crc32` has no SIMD form, and `prefetcht2` needs each index in a GPR.

**Code:** `attempt7/vec4.diff` (`include/hashtables/cas_kht.hpp`, `CMakeLists.txt`) adds three options, all OFF by default:
- `CAS_FIND_EMBCAST`: compare the bucket line against the queue entry's key as a `{1to8}` memory-broadcast operand.
  - gcc does not fold `_mm512_set1_epi64(*p)` into the compare, so this is done with a small inline-asm helper, `cmp_key_bcast`.
  - Side effect: gcc then tests the hit with `kmovb` + `test` instead of `kortestb`.
- `CAS_FIND_VEC4`: 4 finds per iteration when the ring does not wrap inside the group and all 4 hit; otherwise the scalar body handles the item. Results are written as one 64 B store built with `vpermt2d`/`vpermt2q`.
- `CAS_FIND_VEC4_SCALAR_RES`: the same 4-wide loop with scalar result stores, to isolate the vector part.

**Builds:** `attempt7/build_all.sh` (attempt6 cmake line + options) produces `attempt7/{base,emb,vec4s,vec4}/dramhit` (md5s in `attempt7/md5.txt`). All four report `found == find_ops` at fill 10 and fill 90 (`attempt7/smoke/`).

**Static (objdump + `llvm-mca -mcpu=sapphirerapids`):**
- Instructions per find in the hit loop: base 41 → vec4s 33.5 → vec4 32.5.
- The `llvm-mca` port bound stays at about 8 cycles/find in every variant, against ~34 measured. The loop is not port-bound before or after.

**Run:**
```
python3 run_stream.py --reps 5 --interval-ms 100 --read-factor 400 \
    --workloads a7_base_f10 a7_emb_f10 a7_vec4s_f10 a7_vec4_f10 --out E12_100ms
python3 analyze_100ms.py; python3 check_decomp.py
```
- Same protocol as §12, fill 10, keys in HBM.
- A first attempt ran with `--read-factor 100` because of a bug in `run_stream.py`; those runs are kept in `logs/E13_bad_readfactor/` and not used.

**Results** (median of steady intervals, 5 reps; `tables/E12_summary.md`, `tables/E13_vec_decomp.md`):

| | dramblast keys HBM (§12) | a7 base | emb | vec4s | vec4 |
|---|---|---|---|---|---|
| finds/s (G, program) | 4.153 | 4.084 | 4.082 | 4.191 (+2.6 %) | **4.205 (+3.0 %)** |
| HBM GB/s | 293.7 | 291.9 | 281.5 | 286.5 | **297.7** |
| core GHz | 2.203 | 2.181 | 2.196 | 2.259 | 2.196 |
| instr per find (rate ÷ finds/s per thread) | — | 56.9 | 57.4 | 49.2 | 50.4 |
| cycles per find (64 × GHz ÷ finds/s) | — | 34.2 | 34.4 | 34.5 | 33.4 |
| cycles per HBM line | 30.6 | 30.6 | 31.5 | 31.3 | 30.2 |
| IPC | 1.68 | 1.68 | 1.69 | 1.48 | 1.51 |
| xq full % / fb_full % | 13.8 / 53.8 | 13.6 / 53.6 | 11.5 / 54.0 | 16.5 / 53.4 | 18.4 / 55.4 |

Paired per-rep ratios vs a7 base (check_decomp; residual of the clock × cycles model ≤ 1.4 %):
- emb: HBM −2 %.
- vec4s: HBM +0 to +1.5 %; clock +1.4 to +3.2 %; cycles per line −2 to −3 %.
- vec4: HBM **+2.8 to +3.5 %**.
- a7 base reproduces §12's dramblast (HBM ratio 0.999), so run-to-run drift is ≤ 1 %.

Reading:
- **The 4-wide loop removes 6.5–7.7 instructions per find, as statically predicted for the loop (−8.5), but buys only ~+3 % finds/s**, against the predicted +8–15 %.
  - In vec4, 6.5 fewer instructions saved 0.8 cycles/find, i.e. 0.12 cycles per instruction. That is below the mimic slope (0.175) and far below the attempt-4 KSHIFT rate.
  - In vec4s, cycles/find did not drop at all; its gain came from a higher clock (2.26 GHz).
  - IPC fell from 1.68 to 1.5, so the same stall time now has fewer instructions in it.
- **The vector part itself (vec4 vs vec4s) is about +1 %, inside rep noise.** One 64 B store built with permutes buys roughly what scalar stores do.
- **The forced `{1to8}` compare made things slightly worse (−2 %)** despite one fewer instruction. Cycles per line rose 0.9.
- **Fill 90:** single unrepeated runs (`attempt7/smoke`) show vec4 −10 % and vec4s −7 % vs base, which fits frequent fallback to the scalar body on misses. This has not been measured with reps.
- **Conclusion for the north star:** dramblast's per-find instruction count is not what binds its cycles per HBM line. Trimming 7 instructions per find moved bandwidth ~3 %, and vec4 is still 1.31× from bw_t1, split ~half clock and half cycles per line (as in §12.6). The remaining cycles are stall time that does not shrink with fewer instructions: the loop sits at ~4× its port bound, and xq_full is only 18 %.

## 14. E14/E15 — what changes in the CPU when work is added per line

**Port pressure (E14, `bwgap/mca/`, `tables/E14_mca.md`, llvm-mca 14 with the SKX port model):**
- Port-bound cycles per line: bw_t1 3.0, s1 4.3, s2 9.0, s3 10.1, s4 11.5, dramblast 7.7, vec4 8.1.
- Measured cycles per line are 2.6–9× larger in every case, so no loop is port-bound.

**Little's law on the offcore counters (`bwgap/mlp_littles_law.py`, `tables/E14_mlp.md`):**
- Core counters: `OFFCORE_REQUESTS_OUTSTANDING.DATA_RD` (event 0x20 umask 0x08: per cycle, the number of data reads, demand or prefetch, outstanding in the L2's offcore queue) and `OFFCORE_REQUESTS.DATA_RD` (0x21/0x08: the number of such reads).
  - Outstanding ÷ cycles = misses in flight per core.
  - Outstanding ÷ requests = time per miss, in core cycles; ÷ core GHz gives ns.
- At 64 threads, misses in flight stay at 26–30 per core in every program.
- Time per miss rises: bw_t1 264 ns → s2 314 → s3 366 → s4 390, dramblast 365 ns.
- Cycles per line = time per miss ÷ misses in flight reproduces the measured cycles per line in every row.

**Locating that time (E15, `bwgap/run_e15.sh`, `bwgap/analyze_e15.py`, `tables/E15.md`, `logs/E15_*`).** Workloads: bw_t1, s2, s4, dramblast (attempt7 base, keys in HBM); 100 ms streams; 2–3 reps.
- **Coherence / extra mesh traffic: none.**
  - CHA TOR inserts from cores per HBM line: 2.01 for bw_t1, s2 and s4; 2.11 for dramblast (the key stream).
  - Modified-line writebacks (`ia_wbmtoi`): 0.001 per line. Snoops sent: 0.000. RFOs: 0.
  - Software prefetches arrive as plain DRd (1.00 per line).
- **Time in the CHA tracker** (`unc_cha_tor_occupancy.ia_miss / unc_cha_tor_inserts.ia_miss`, CHA clocks → ns): 47–51 ns in every program. It does not rise with the stage.
- **Time in the HBM controller read queue** (RPQ occupancy ÷ inserts, pseudo-channel 0; `E15_hbmq`): 4.7 / 4.3 / 3.4 / 3.3 controller clocks for bw_t1 / s2 / s4 / dramblast. Tiny, and falling with bandwidth as queueing predicts.
- **Mesh clock pinned to 1.6 GHz for all** (sysfs `intel_uncore_frequency` min = max = 1600000 on socket 0, restored to 2500000/2500000 afterwards; `E15_mesh1600`, 3 reps):

  | | bw_t1 | s2 | s4 | dramblast |
  |---|---|---|---|---|
  | HBM GB/s | 350.6 | 354.4 | 315.9 | 297.8 |
  | core time per miss (ns) | 297 | 322 | 383 | 360 |
  | CHA time per miss (ns) | 58 | 58 | 54 | 54 |

  - At equal mesh clock the per-miss difference persists (297 vs 360–383 ns), so the mesh clock is not the cause.
  - The bw_t1 / dramblast gap shrinks to 1.18×: bw_t1 loses 12 %, while dramblast gains ~1 % as its core clock rises to 2.38 GHz.
- **16 threads (low load; `E15_t16`, 2 reps; core 2.69 GHz, mesh 2.1–2.2 GHz):**

  | | bw_t1 | s2 | s4 |
  |---|---|---|---|
  | HBM GB/s | 191.0 | 168.7 | 136.9 |
  | time per miss (ns) | 170 | 178 | 184 |
  | misses in flight per core | 8.0 | 7.4 | 6.2 |

  At low load, time per miss is nearly equal. The heavier loops lose bandwidth because they keep fewer misses in flight, a core-local issue-rate effect.

**Reading:**
- The extra instructions do not create mesh or coherence traffic.
- At 64 threads, the extra ~100–125 ns per miss is not spent in the CHA tracker or the HBM read queue, and does not go away with an equal mesh clock.
- It must be in a part of the path these counters do not cover: the transport between the core's L2 and memory across the tiles, the HBM-side mesh-to-memory block, or the HBM device. Note that `uncore_mdf` (the die-to-die fabric) is available but not yet measured.
- It is a full-load effect: at 16 threads the per-miss time is the same for all programs.

## 15. E16 — die-to-die fabric, CHA ingress, and bw_t1's own latency curve (`bwgap/run_e16.sh`, `analyze_e16.py`, `tables/E16.md`, `tables/E16_lookahead.md`)

**Die-to-die fabric (MDF, 20 boxes per socket) and CHA ingress, 2 reps:**
- Crossings per HBM line are the same for bw_t1 and s1–s4: requests 1.97, data 2.09. dramblast is 2.08 / 2.40, the extra being its key stream.
- Fabric congestion is negligible and falls with the heavier loops: bounces ≤ 0.36 % of mesh cycles, distress ≤ 0.29 %.
- CHA ingress rejects: 0.00–0.03 per insert, also falling.
- So no uncore or memory component is busier for the heavier loops (cf. §14: CHA tracker time flat, HBM read-queue wait falling).

**bw_t1 with shorter prefetch lookahead** (`E16_lookahead`, same program, no added instructions; 2 reps):

| lookahead | 4 | 8 | 12 | 16 | 24 | 32 | 48 | 64 |
|---|---|---|---|---|---|---|---|---|
| HBM GB/s | 249.8 | 292.1 | 326.3 | 353.2 | 390.2 | 401.7 | 404.1 | 402.9 |
| misses in flight per thread | 26.9 | 26.2 | 27.5 | 28.0 | 27.6 | 26.3 | 25.5 | 25.9 |
| time per miss (ns) | 443 | 368 | 345 | 323 | 289 | 268 | 258 | 262 |
| xq full % | 0.0 | 0.2 | 7.4 | 22.2 | 53.6 | 68.0 | 68.7 | 67.3 |

**Reading:**
- bw_t1 alone, with zero extra instructions, shows the same pattern as the mimic stages. Counted misses in flight stay pinned at ~26–28 per hardware thread, and the counted "time per miss" rises as bandwidth falls. s4 (310 GB/s, 390 ns) lies close to this curve (la8: 292 GB/s, 368 ns).
- So the extra instructions are not making memory slower. The counter-derived "time per miss" follows bandwidth because the counted occupancy is pinned.
- Both hyperthreads of every core run the workload (node 0 = 32 cores × 2 threads). The pinned ~26–28 per thread is therefore consistent with the core's shared L2 miss queue sitting at capacity in every configuration.
- When that queue is full, the extra time per request is spent inside the core's queue, not in the uncore. Every uncore counter shows the same or less waiting.
- This is a working hypothesis. The next steps are a true load-to-use latency probe (pointer chase) and a one-thread-per-core run.

## 16. E17/E18 — do software prefetches hold core resources? Where do the cycles go? (`bwgap/run_e17.sh`, `run_e18.sh`, `analyze_e17.py`, `tables/E17.md`, `E18_ports.md`, `E18_td.md`)

**Setup:**
- Alternative core event sets via `run_stream.py --core-set` (`runlib.CORE_SETS`): fill buffers, software prefetches, stalls, L2, execution ports, issue/top-down.
- 64 threads = both hyperthreads of all 32 cores. `*_t32` = one thread per core.
- All idle states are disabled on this machine, so the idle siblings in `t32` runs spin in the kernel poll loop. Those runs count core events in user mode only (`--cpus user`), and the siblings still share each core.
- 2 reps each.

**Results at 64 threads:**

| | bw_t1 | s1 | s2 | s3 | s4 | dramblast |
|---|---|---|---|---|---|---|
| L1 fill buffers full, % of cycles | 67 | 77 | 68 | 60 | 56 | 54 |
| L1 miss blocked because L2 had no room, % | 1.4 | 1.4 | 0.2 | 0.1 | 0.1 | 0.1 |
| store buffer full, % of cycles | 0 | 0 | 0 | 0 | 0 | **16** |
| loads hitting a still-in-flight sw prefetch, per line | 0.00 | 0.15 | 0.01 | 0.005 | 0.004 | **0.17** |
| core cycles per HBM line (per core) | 13.2 | 12.4 | 12.7 | 14.0 | 14.7 | 15.2 |
| uops issued per HBM line | 13.2 | 20.2 | 32.5 | 48.6 | 58.8 | 52.9 |
| uops issued per core cycle (of 6) | 1.00 | 1.63 | 2.55 | 3.48 | **4.00** | 3.49 |
| backend-bound / memory-bound, % of slots | 82 / 65 | 69 / 38 | 55 / 12 | 39 / 6 | 31 / 4 | 36 / 16 |
| busiest port group, uops per core cycle | p5+11: 0.20 | 0.35 | 0.65 | 0.80 | 0.88 (of 2) | 0.70 |

`int_misc.mba_stalls` (memory-bandwidth-allocation throttling) is 0 everywhere.

**One thread per core:** bw_t1 354 GB/s, s4 252 GB/s (1.41×, vs 1.28× with both threads). s4 then issues 3.0 uops per core cycle.

**Reading:**
1. **Software prefetches do occupy L1 fill buffers.** The FBs are full 54–77 % of cycles in every program, although the mimic stages' demand loads hit L1.
   - They cannot hold an FB for the whole memory trip: 16 FBs per core over ~300–400 ns would cap the socket near 90 GB/s.
   - The L2 almost never refuses an L1 miss (≤ 1.4 %), so the L2 miss queue is not the limiter either.
2. **bw_t1, s1 and s2 are memory-side bound:** 65 / 38 / 12 % of slots memory-bound. Up to s2 the added instructions hide behind the misses (§11).
3. **From s3 on the loop is issue-bound.** s4 issues 4.0 uops per core cycle out of the 6 that both hyperthreads share, with only 4 % of slots memory-bound. Its cycles per line equal uops per line ÷ uops per cycle (58.8 ÷ 4.0 = 14.7). Every added uop now costs about ¼ core cycle per line. That is why stages 3–4 cost what their instruction count predicts.
   - The "time per miss" rise (§14) is the memory-side view of this: the prefetch stream is issued more slowly, while the per-thread outstanding count stays put.
   - No single port is saturated (port 5 busiest, 0.88 of 2).
4. **dramblast sits between the two regimes:** 3.49 uops per core cycle, 16 % of slots memory-bound. It has two stalls none of the mimic stages show:
   - store buffer full 16 % of cycles (8 stores per find: 3 harness `items[]`, 3 queue entry, 2 result);
   - 0.17 loads per line arriving while their software prefetch is still in flight (late prefetch).
   - This explains why E13's instruction trimming bought only 3 %: removing uops lowered the issue rate (IPC 1.68 → 1.51) rather than the cycles, because the store-buffer and late-prefetch stalls remain.

## 17. E19 — where and how far ahead to prefetch the harness key stream (attempt 8)

**Change:** `src/tests/zipfian_test.cpp`, `do_batch_find` (`attempt8/zipfian_keypf.diff`). The find loop's key-stream prefetch is configurable from the environment; with none set it behaves as before:
- `KEY_PF_DIST`: keys ahead; 0 turns the prefetch off.
- `KEY_PF_HINT`: t0 / t1 / t2 / nta.
- `KEY_PF_MODE`:
  - `inline`: as before, in the per-key loop, one prefetch per 8-key line;
  - `batch`: at the start of each batch, every key line of the batch `KEY_PF_DIST` keys ahead.

**Binary:** `attempt8/build.sh` → `attempt8/dramhit` (md5 443e5328…): the attempt7 base options plus this change. It logs the active setting (`find key prefetch: ...`).

**Run:** `bwgap/run_e19.sh`, 3 interleaved reps, 100 ms streams, fill 10, keys in HBM. Analysis: `bwgap/analyze_e19.py` → `tables/E19.md`.

| config | finds/s (M) [min–max] | vs original | HBM GB/s | core GHz | instr/find | thread-cycles / HBM line | late sw-prefetch loads / line |
|---|---|---|---|---|---|---|---|
| inline, 16 ahead, t0 (original) | 4075 [4027–4101] | – | 290.3 | 2.160 | 58.3 | 30.6 | 0.168 |
| no key prefetch | 3244 | −20.4 % | 229.3 | 2.496 | 52.2 | 44.3 | 0.002 |
| inline, 32, t0 | 4127 | +1.3 % | 293.7 | 2.147 | 58.6 | 29.7 | |
| inline, 64, t0 | 4183 | +2.7 % | 296.9 | 2.162 | 58.2 | 29.8 | 0.005 |
| inline, 128, t0 | 4185 | +2.7 % | 298.8 | 2.182 | 58.5 | 29.8 | 0.005 |
| inline, 256, t0 | 4212 | +3.4 % | 298.9 | 2.179 | 58.2 | 29.7 | |
| inline, 64, t2 | **4232 [4179–4242]** | **+3.9 %** | 300.1 | 2.163 | 58.7 | 29.4 | |
| inline, 128, t2 | 4220 | +3.6 % | 302.1 | 2.169 | 59.0 | 29.3 | |
| batch start, 64, t0 | **4231 [4198–4282]** | **+3.8 %** | 302.3 | 2.204 | 55.1 | 29.6 | |
| batch start, 128, t0 | 4197 | +3.0 % | 298.4 | 2.173 | 55.5 | 29.7 | 0.005 |

Late-prefetch counts are from a separate 2-rep run with the prefetch counter set (`E19_keypf_swpf`).

**Reading:**
- **The late prefetches in §16 were the key stream.**
  - At 16 keys ahead, 0.168 loads per HBM line found their key line still in flight.
  - From 64 keys ahead this drops to 0.005, the same as the mimic stages.
  - Without the key prefetch at all, finds drop 20 %, so the prefetch itself is essential.
- **Fixing it is worth +3–4 %:** 4075 → ~4230 M finds/s, 290 → ~300 GB/s, cycles per HBM line 30.6 → ~29.4.
  - The best settings (inline 64 with t2; batch start 64 with t0) are separated from the original by their rep ranges.
  - Batch mode also removes ~3 instructions per find, since it no longer tests per key.
- **The store-buffer stall (§16) is untouched by this** and is the next target.

## 18. E20 — 16 B find-queue entries and 4-entry block push/pop (attempt 9)

**Code:** `attempt9/queue16.diff` (`include/hashtables/cas_kht.hpp`, `CMakeLists.txt`). New options, all OFF by default:
- `CAS_FIND_QUEUE16`: the find queue gets its own 16 B entry `{key, hash, key_id}`.
  - `hash` is the full 32-bit crc32 value. crc32 results are 32 bits, so the old 8 B `key_hash` held nothing more.
  - bucket index = `hash & HT_BUCKET_MASK`; the unmasked value seeds the next probe on a reprobe.
  - The insert queue keeps `ItemQueue`. All find-queue paths use the new entry: fast path, `add_to_find_queue`, `pop_find_queue`, `flush_if_needed`, `__find_simd`, `__find_one`, `__find_empty`.
  - The fast path keeps `HT_BUCKET_MASK` in a local. Without that, the first build reloaded it every find and spilled the input and result pointers.
- `CAS_FIND_QUEUE16_XMM`: write an entry with one 16 B store.
- **Block design:** with `CAS_FIND_VEC4`, a group's 4 entries are one 64 B line.
  - Pop: one zmm load gives the 4 `key_id`s for the 64 B result store.
  - Push: the 4 new entries are built in one zmm and written with one 64 B store. Keys and ids come from two loads of the 4 input arguments and one `vpermt2d`; the 4 hashes go in with one `vpexpandd`.

**Builds:** `attempt9/build_all.sh` produces `attempt9/{base,q16,q16x,q16v,v4}/dramhit` (md5s in `attempt9/md5.txt`). All are on the attempt8 harness.

**Correctness:** all report `found == find_ops` at fill 10 and fill 90 (`attempt9/smoke/`).

**Run:** `bwgap/run_e20.sh` → `analyze_e20.py` → `tables/E20.md`. 3 interleaved reps, fill 10, keys in HBM, key prefetch 64 ahead with t2 (`KEY_PF_DIST=64 KEY_PF_HINT=t2`). Store-buffer counters come from a separate 2-rep run.

| variant | finds/s (M) [min–max] | vs a9 base | HBM GB/s | core GHz | instr/find | thread-cycles / HBM line | store buffer full % |
|---|---|---|---|---|---|---|---|
| 32 B entries (a9 base) | 4181 [4051–4218] | – | 297.7 | 2.135 | 58.8 | 29.3 | 16.0 |
| 16 B entries | 4162 [4024–4257] | −0.5 % | 294.1 | 2.119 | 60.5 | 29.6 | 13.0 |
| 16 B, one 16 B store | 3994 [3975–4184] | −4.5 % | 282.9 | 2.079 | 64.3 | 29.9 | 12.3 |
| **16 B + 4-entry block push/pop** | **4366 [4235–4473]** | **+4.4 %** | **309.6** | 2.088 | 51.8 | **27.8** | **6.0** |
| 32 B + vec4 group | 4270 [4133–4296] | +2.1 % | 304.6 | 2.150 | 54.7 | 28.9 | 13.9 |

**Reading:**
- **The 16 B entry alone does nothing.** It removes one store per find (store buffer full 16 → 13 %) but adds ANDs and packing.
- **The one-16 B-store form is worse:** −4.5 %, from +5 instructions per find to build the xmm.
- **The block form is the best variant so far:** +4.4 % finds/s, store buffer full 16 → 6 %, cycles per HBM line 29.3 → 27.8, instructions per find 58.8 → 51.8.
  - It beats the 32 B vec4 group (+2.1 %), so the 64 B block push contributes beyond the 4-wide loop.
  - Against the original key prefetch (attempt8 base, 4075 M) it is +7.1 % in total.
- **Still open:** the find-queue length and batch length were tuned for 32 B entries and scalar processing, so they should be swept again for this design.

## 19. Cleanup (attempt 10): 16 B find queue by default, `DEEP_VECTORIZATION`

**Code** (`attempt10/cleanup.diff` = full diff of `include/hashtables/cas_kht.hpp` and `CMakeLists.txt` against HEAD):
- **Removed:** the attempt7/9 options `CAS_FIND_VEC4`, `CAS_FIND_VEC4_SCALAR_RES`, `CAS_FIND_QUEUE16` (as an option) and `CAS_FIND_QUEUE16_XMM`, together with the 32 B-entry 4-wide code. `CAS_FIND_EMBCAST` is kept (separate scalar-path option, OFF).
- **16 B find-queue entry `{key, 32-bit hash, key_id}`** (`CAS_FIND_QUEUE16`, now defined automatically at the top of `cas_kht.hpp`) is used whenever it is exact:
  - `KEY_LEN == 8`, `CAS_SIMD`, no `LATENCY_COLLECTION`;
  - and either crc32 hashing (its values are 32 bits) or linear probing.
  - Otherwise the find queue keeps the 32 B `ItemQueue`. The insert queue always does.
- **`DEEP_VECTORIZATION`** (CMake option, OFF): `find_batch` takes 4 finds at a time whenever ≥ 4 inputs remain, the ring does not wrap inside the group, and all 4 hit.
  - Pop 4 = one 64 B block load for the ids, plus 4 bucket loads and compares; the 4 results go out as one 64 B store.
  - Push 4 = one 64 B block store.
  - Anything else falls back to the scalar body for that item.
  - It requires the 16 B entry plus `CAS_FIND_RING_OFFSETS`, `CAS_FIND_COMPRESS_VALUE`, `CAS_FIND_KSHIFT` and `PREFETCH=DOUBLE` (`#error` otherwise).

**Builds** (`attempt10/build_all.sh`, md5s in `attempt10/md5.txt`):
- `q16`: default, 16 B entries.
- `deepvec`: `-DDEEP_VECTORIZATION=ON`.
- Compile checks: `chk_city` (`HASHER=city`) and `chk_2023` (`DRAMHiT_VARIANT=2023`).

**Smoke runs** (`attempt10/smoke/`, key prefetch 64 ahead with t2; single runs, not performance measurements):
- q16 and deepvec: `found == find_ops` at fill 10 and 90, find-queue entry 16 B. Fill 10 single runs: 4046 and 4526 M finds/s.
- chk_2023: 16 B entries through the `flush_if_needed` / `__find_one` / `add_to_find_queue` paths, all found.
- chk_city: falls back to the 32 B entry as intended, but finds only 409 800 of 5.37 G. **This is pre-existing:** the 2025_INLINE fast path in HEAD hashes new keys with `_mm_crc32_u64` directly (`git show HEAD:include/hashtables/cas_kht.hpp`, line 717), while inserts use the configured hasher. So the fast path only works with `HASHER=crc`.

## 20. E21 — find-queue length × batch length with `DEEP_VECTORIZATION` (`bwgap/run_e21.sh`, `analyze_e21.py`, `tables/E21.md`)

**Setup:**
- `attempt10/deepvec/dramhit` at find queue 32/64/128/256 × `--batch-len` 16/32/64.
- Reference: `attempt10/q16` (16 B scalar) at the old 64/16.
- Fill 10, keys in HBM, key prefetch 64 ahead with t2; 3 interleaved reps, 100 ms streams.

**finds/s (M), median [min–max] (vs reference 4056):**

| find queue \ batch | 16 | 32 | 64 |
|---|---|---|---|
| 32 | 4166 (+2.7 %) | 4272 (+5.3 %) | 4390 (+8.2 %) |
| 64 | 4405 (+8.6 %) | **4563 [4546–4583] (+12.5 %)** | 4533 (+11.8 %) |
| 128 | 4413 (+8.8 %) | 4546 (+12.1 %) | **4601 [4515–4666] (+13.4 %)** |
| 256 | 4317 (+6.4 %) | 4416 (+8.9 %) | 4349 (+7.2 %) |

**Reading:**
- **Plateau:** finds/s are flat at ~4530–4600 M over find queue 64–128 × batch 32–64. The differences inside it are within rep spread.
- **Best points:** 128 / 64 (4601 M, 327 GB/s) and 64 / 32 (4563 M, 324 GB/s, tightest reps). The highest HBM bandwidth is 64 / 64 (332.6 GB/s).
- **Why a larger batch helps:** it amortises the per-call cost. Instructions per find fall from 51.9 (64 / 16) to 48.3 (64 / 64), and xq full rises from 25 to 40 %, so more requests are in flight.
- **Queue length:** 32 is too short (the prefetch-to-use distance shrinks); 256 is worse again.
- **Cumulative:** against the original build (attempt8 base at 16-key prefetch, 4075 M finds/s, 290 GB/s), the best point is +12.9 % finds/s and ~327–333 GB/s HBM. The gap to bw_t1 (397 GB/s) narrows from 1.35× to ~1.2×.
- **Not measured here:** the batch length also applies to inserts, whose throughput this sweep does not measure; attempt 4 saw batch 64 cost inserts 1–3 %.

## 21. E22 — pop with one SIMD load of the 4 entries (`DEEP_VEC_SIMD_POP`)

**Variant:** `DEEP_VEC_SIMD_POP`, a CMake option under `DEEP_VECTORIZATION`, OFF by default; build `attempt10/deepvec_sp`.
- Each block of 4 find-queue entries (the pop block, and the block 8 slots ahead used for prefetching) is read with one 64 B load.
- The 4 hash fields are gathered into the low xmm with `vpermd`, masked with `vpand`, and extracted with `vmovd` plus 3 `vpextrd`.
- The `key_id`s for the results come from the same register. Keys are still broadcast from memory.
- Static: same instruction count as `deepvec`, but each `vpextrd` is 2 uops on port 5.
- Correct at fill 10 and 90.

**Result** (3 reps; `tables/E22.md`):

| build | queue / batch | finds/s (M) [min–max] | HBM GB/s | uops issued / HBM line (2-rep td run) |
|---|---|---|---|---|
| deepvec | 128 / 64 | 4498 [4375–4668] | 324.8 | 43.1 |
| deepvec_sp | 128 / 64 | 4365 [4231–4495] | 314.6 | 46.0 |
| deepvec | 64 / 32 | 4525 [4339–4572] | 323.9 | |
| deepvec_sp | 64 / 32 | 4338 [4247–4394] | 308.8 | |

**Reading:** the SIMD pop is 3–4 % slower at both settings, and the 2-rep top-down run agrees (4624 vs 4420). It issues +2.9 uops per HBM line: 4 scalar load-and-mask uops on idle load ports are replaced by register extracts on port 5. Reading the hash fields with scalar loads stays the better choice.

## 22. E23 — fill 10–90: `DEEP_VECTORIZATION` vs the same build without it (`bwgap/analyze_e23.py`, `tables/E23.md`)

**Setup:**
- `attempt10/q16` (16 B entries, scalar) and `attempt10/deepvec`, both at queue 128 / batch 64, key prefetch 64 ahead with t2, keys in HBM.
- 5 interleaved reps per point, 100 ms streams.
- Read factor scaled with fill, `(4000 + f/2) / f`, so the find phase stays ~5 s (21.3–21.6 G finds).
- All runs `found == find_ops`.
- Fallback rates: stats-only build `attempt10/deepvec_stats` (`-DDEEP_VEC_STATS=ON`, counters printed at exit), one run per fill (`attempt10/stats/`).

| fill | scalar finds/s (M) [min–max] | deep-vec finds/s (M) [min–max] | deep-vec vs scalar | scalar / deep-vec HBM GB/s | scalar / deep-vec instr per find | finds in 4-wide groups | miss fallbacks (% of finds) |
|---|---|---|---|---|---|---|---|
| 10 | 4348 [4265–4472] | 4465 [4453–4583] | +2.7 % | 314.1 / 326.3 | 56.7 / 47.2 | 96.5 % | 0.04 % |
| 20 | 4242 [4213–4291] | 4475 [4365–4532] | +5.5 % | 314.1 / 326.1 | 57.8 / 46.8 | 96.0 % | 0.46 % |
| 30 | 4265 [4213–4340] | 4265 [4218–4304] | +0.0 % | 314.7 / 320.1 | 57.1 / 49.3 | 94.3 % | 1.83 % |
| 40 | 4187 [4101–4266] | 4107 [4087–4250] | −1.9 % | 312.1 / 312.2 | 57.3 / 51.6 | 91.2 % | 4.53 % |
| 50 | 4002 [3966–4089] | 3878 [3844–3956] | −3.1 % | 306.4 / 298.3 | 58.8 / 55.5 | 86.6 % | 8.72 % |
| 60 | 3879 [3830–3917] | 3553 [3538–3631] | −8.4 % | 301.7 / 281.7 | 59.0 / 60.5 | 80.6 % | 14.28 % |
| 70 | 3598 [3562–3616] | 3181 [3145–3219] | −11.6 % | 293.5 / 266.5 | 60.9 / 67.6 | 73.6 % | 20.83 % |
| 80 | 3122 [3068–3145] | 2778 [2743–2779] | −11.0 % | 284.8 / 255.9 | 65.2 / 76.0 | 66.2 % | 27.76 % |
| 90 | 2615 [2574–2646] | 2304 [2297–2333] | −11.9 % | 289.6 / 257.9 | 73.3 / 89.9 | 59.2 % | 34.29 % |

**Reading:**
- **Deep vectorization pays only at low fill:** +2.7 % at fill 10, +5.5 % at fill 20, break-even at 30, then −2 to −12 % from fill 40 on.
- **Most of §20's +13 % came from tuning, not vectorization.** That figure was against the scalar build at the old 64 / 16. The scalar build tuned to 128 / 64 is itself at 4348 M, so deep vectorization proper adds +2.7 % at fill 10.
- **A miss fallback costs far more than estimated.** At fill 90 deep-vec executes +16.6 instructions per find for 0.34 fallbacks per find, ~48 extra instructions per fallback. The pre-implementation estimate was 15–25.
- **That matches the mechanism:** the abandoned group's work (4 bucket loads, compares, tests), one scalar find, and the next group attempt redoing 3 of the same entries.
- **So handling reprobes inside the group is worth doing.** It targets exactly this loss: up to ~12 % at fill 70–90 to recover, plus whatever the vector path gains over scalar there.

## 23. E24 — finishing reprobe groups inside the vector path (`DEEP_VEC_INGROUP`, attempt 10): not a win yet

**Code:** `DEEP_VEC_INGROUP` (option, OFF), with `DEEP_VEC_RESULT_REGCOMPRESS` selecting the partial-result store. When not all 4 entries of a group hit on this probe:
- the hits are written with one compress store (`_mm512_mask_compressstoreu_epi64`, mask `_pdep_u32(hit, 0x55) * 3`), or with a register compress plus a masked store;
- definite misses count as not found (unchanged behaviour);
- the R reprobes plus C = 4 − R new inputs are pushed (scalar `fq_put` in this first version);
- only C inputs are consumed, so the queue stays exactly full.

All builds report `found == find_ops` (fills 10/50/90). With it, 94.5 % of finds complete in the vector path at fill 90 (stats build), against 59 % with the fallback.

**Three code-generation versions, measured:**
1. **Inlined:** `find_batch` grew from 427 to 750 instructions with 93 stack references. Fill 10 went 47.9 → 55.8 instructions per find. Speed (3 reps, `logs/E24_pick`): −5 % at fill 10, +4 % vs fallback at fill 90.
2. **Out of line, arguments by reference:** the 4 bucket registers and masks were stored to the frame on every group, and `vp_result` lived in memory. Fill 10 was still 55.5 instructions per find (`logs/E24_pick2`): −6 % at fill 10, −4 % at fill 90.
3. **Out of line, arguments by value** (buckets in zmm registers, masks and counts packed): fill 10 is 51.6 vs 47.8 instructions per find, fill 90 99.0 vs 89.0 (1 rep, `logs/E24_quick3`). Speed is about equal to the fallback (4352 vs 4411 at fill 10, 2329 vs 2333 at fill 90).
   - The call inside the loop clobbers every caller-saved register, so loop state and constants go to the stack frame.
   - The out-of-line reprobe path costs ~100 instructions per group with R > 0 (snapshot, branchy classification, scalar pushes of the new inputs, call overhead). That is more than the fallback it replaces.

**Bottom line so far:**
- The scalar build is still best at high fill: 2640 M at fill 90, against 2316 (fallback) and ~2210–2330 (in-group).
- For in-group handling to win, the R > 0 path must cost roughly ≤ 40 instructions per group without disturbing the all-hit path: branchless classification, a vector-built push block, no call.
- A simpler practical option: choose the path by table fill (deep vectorization below ~30 % fill, scalar above).

## 24. E24 (cont.) — cleaned-up in-group path, inline and branch-free

**Code** (`attempt10/cleanup.diff`, build `attempt10/ig`): the 4-wide group is one inline block with commented stages:
1. probe;
2. 4 results in one register, 0 for a non-hit;
3. hash, prefetch and arrange the next 4 inputs as a block;
4. classify branch-free: masks packed one byte per bucket, reduced with `pext`;
5. compress-store the hits;
6. advance the reprobe hashes, with a branch-free prefetch target (next bucket, or the entry's own L1 line);
7. push block = reprobe entries compressed to the front + new inputs expanded behind;
8. one 64 B push.

Stages 1–3 and 8 are shared with the all-hit case. Other changes:
- Loop invariants are lifted: local `ht` (the static `hashtable` was reloaded after stores), the masks and the permute constants.
- No function call.
- `DEEP_VEC_SIMD_POP` and `DEEP_VEC_RESULT_REGCOMPRESS` are removed (both measured slower, §21 and §23).

**Result** (3 reps, `logs/E24_pick3`; all `found == find_ops`):

| fill | scalar (16 B) | 4-wide, fallback | 4-wide, in-group |
|---|---|---|---|
| 10 | 4420 [4253–4427] (56.3 instr/find) | 4461 [4345–4614] (46.3) | 4397 [4214–4518] (48.9) |
| 50 | 4075 [4014–4089] (58.0) | 3977 [3873–4040] (54.4) | 4022 [3978–4092] (53.7) |
| 90 | 2589 [2583–2670] (73.4) | 2329 [2251–2334] (88.9) | 2342 [2287–2365] (88.2) |

**Reading:**
- **The all-hit path is back to near its old cost** (48.9 vs 46.3 instructions per find at fill 10). The in-group build is now as fast as the fallback build at every fill, within rep spread, but not faster.
- **At fill 90 both 4-wide builds stay ~10 % behind scalar.** A reprobe costs the 4-wide path ~90 instructions against ~37 in scalar:
  - ~50 from the reprobe block, ~125 instructions per group with R > 0, shared by ~2.3 reprobes;
  - ~30 from re-popping the entry in a later group;
  - plus re-hashing the inputs a partial group did not consume.
  - Even a ~40-instruction reprobe block would only reach parity at fill 90.
- **At fill 10, 4-wide saves 8–10 instructions per find but is not faster than scalar in this run** (all three within rep spread). At queue 128 / batch 64 the find loop is no longer limited by instruction issue, so fewer instructions do not convert into throughput. This differs from E23, where 4-wide was +2.7 % at fill 10.
- **Conclusion:** neither 4-wide variant (fallback or in-group) improves on the tuned scalar 16 B build in a robust way. The gains of this whole series come from:
  - the key-stream prefetch distance (§17);
  - the queue/batch tuning (§20);
  - the 16 B find-queue entry, which enables the block idea but is neutral alone.

**Where the in-group build loses at fill 90** (`attempt10/prof/`; `perf stat` totals and `perf record -e cycles:u` of `attempt10/ig` vs `q16`, fill 90, one run each):
- Against scalar over the whole run: +13.2 instructions per find, +4.2 thread-cycles per find, and only +0.06 branch mispredictions per find. Mispredictions are not the cause.
- `find_batch` holds 24.6 % of the run's samples (inserts 61 %). Within `find_batch`, the reprobe block (130 instructions) holds **29.8 %**:
  - (4) classify: 7.1 %
  - (5) partial results: 2.9 %. The `vpcompressq` store itself is 0.2 %.
  - (6) next hashes (4 × crc32 on the popped hashes) and the prefetch-target select: 12.4 %
  - (7) build and store the push block: 7.3 %
- The remaining 70 % is the all-hit path, the scalar path and the loop. Its top samples are the bucket-load / prefetch stalls of stage (1), as at low fill.
- So the cost of a partial group is not the partial result write; it is recomputing and selecting the reprobe hashes, classifying, and building the mixed block.
- A block of ~40 instructions instead of 130 would remove roughly two thirds of that 30 %, ~20 % of `find_batch` time. That is enough to beat scalar at fill 90, so the earlier "at best a tie" estimate (§24) was too pessimistic.

## 25. Deep pop / deep push (DEEP_VECTORIZATION rewritten; E25, E26)

**Design** (`attempt10/cleanup.diff`; `deep_pop_find_queue` and the `find_batch` fast path in `cas_kht.hpp`):
- All earlier 4-wide code is removed (speculative 4-bucket group, all-hit fallback, in-group reprobes, stats).
- **Deep pop** = `pop_find_queue` × 4: each completion retries through reprobes, pushing a reprobe back with its next hash.
  - The 4 completed entries can be anywhere in the ring, so each hit's `key_id` and value are loaded on their own and placed in lane k of one register (`_mm512_mask_broadcast_i32x4`).
  - The 4 results go out with one 64 B store, or a compress store if a lane was not found.
- **Deep push:** the next 4 arguments as one 64 B block of 16 B entries; 4 entry stores if the block would wrap the ring.
- Used while ≥ 4 arguments remain; the rest go through the scalar code. The queue stays exactly full.
- `deep_pop_find_queue` is the standalone reference form. The fast path inlines it with tail and head in registers.
- Correct (`found == find_ops`) at fills 10–90.

**E25, fill 10–90** (queue 128 / batch 64, key prefetch 64 t2, 5 reps; `tables/E25.md`):
- 2.2–4.1 % below scalar at every fill: 4242 vs 4343 M at fill 10, 2557 vs 2626 at fill 90.
- Instructions per find are the same as scalar (57.3 vs 57.2 at fill 10, 73.2 vs 73.0 at fill 90).
- So the high-fill collapse of the earlier 4-wide designs (−12 %) is gone.

**E26, find queue × batch** (fill 10 and 90, 3 reps; `tables/E26.md`):
- **Batch 64 is best at every queue length and both fills.** Batch 16 loses 6–8 % at fill 10 and 9–15 % at fill 90, with 4–15 more instructions per find.
- **Best points vs scalar at 128 / 64:**
  - fill 10: queue 64 / batch 64, 4325 M vs 4327 M (−0.0 %); 128 / 64 is −0.6 %.
  - fill 90: queue 256 / batch 64, 2577 M vs 2612 M (−1.3 %); 128 / 64 is −2.1 %.
- At its best settings, deep pop/push is level with scalar (within rep spread) at low fill and 1–2 % behind at high fill.
- The batch trend has not flattened at 64, so larger batches (128, 256) are the next thing to test.

## 26. E27 — where the best deep pop/push configuration spends its time (`tables/E27.md`, `attempt10/prof/dp_f*.data`)

Best settings from E26: deep pop/push at queue 64 / batch 64 (fill 10) and 256 / 64 (fill 90); scalar at 128 / 64. 2 reps per counter set (`logs/E27_{td,stall,fb}`).

| config | finds/s (M) | HBM GB/s | core GHz | uops issued / core cycle (of 6) | backend / memory-bound % of slots | store-buffer full % | fb full % |
|---|---|---|---|---|---|---|---|
| deep, fill 10 | 4225 | 310.5 | 2.118 | 3.73 | 31 / 11 | 9.0 | 58.3 |
| scalar, fill 10 | 4398 | 315.1 | 2.113 | 3.75 | 32 / 12 | 10.4 | 58.4 |
| deep, fill 90 | 2561 | 283.3 | 2.076 | 4.36 | 15 / 5 | 3.3 | 51.9 |
| scalar, fill 90 | 2591 | 289.5 | 2.042 | 4.46 | 14 / 4 | 3.4 | 53.0 |

**Static (objdump of `attempt10/deepvec`):**
- One completion's hit path is ~28 instructions: 7 for the next-slot prefetch address, 13 for pop and probe, 8 to put `{key_id, value}` in lane k.
- The push is ~12 per find and the harness ~15 per find, which matches the measured 57 per find.
- Small source-level savings exist (~3–4 per pop): a register copy for each `& bmask`, the key going through a GPR plus `vpbroadcastq`, and a taken `jmp` on the hit path.

**Profile** (`perf record -e cycles:u`, one run each):
- fill 10: `find_batch` 59 % of samples, the harness (`ZipfianTest::run`) 21 %, inserts 19 %.
- fill 90: inserts 63 %, `find_batch` 22 %, harness 14 %.

**Reading against the north star (328 GB/s at every fill):**
- **Fill 90 is issue-bound.** 4.4 of 6 uops per core cycle is near the practical limit seen in §16 (4.0 for s4), and only 4–5 % of slots are memory-bound.
  - At fill 90 a find reads ~1.73 HBM lines (1.44 buckets + keys), so 328 GB/s needs ~2.96 G finds/s, +16 % over today.
  - That means ~16 % fewer uops per find.
- **Fill 10 is mixed:** 3.7 uops per cycle, 11 % memory-bound, store buffer full 9 %.
- **The largest remaining block is the harness**, about a quarter of find-phase cycles at fill 10. It writes 3 stores per find into `items[]` that `find_batch` immediately reads back.
  - Fusing it (`find_batch` reading the key array directly, ids = base + i) removes ~10 instructions and 3 stores per find.
  - Next are the per-pop trims above.

## 27. Code reorganisation: deep path as its own scope

`find_batch`'s fast path is now `#ifdef DEEP_VECTORIZATION { deep body } #else { scalar body } #endif`, each self-contained (`attempt10/cleanup.diff`).
- **Deep body:** the whole batch in steps of 4 (deep pop, then deep push) with no scalar tail. The fast path is taken only when the queue is full and `kp.size() % 4 == 0`.
- **Other sizes** go to the generic slow path (`pop_find_queue` / `add_to_find_queue`), e.g. the harness's final partial batch or a configured batch length that is not a multiple of 4. The constructor warns once in that case.
- **Scalar body:** unchanged.

**Checks** (single runs, `attempt10/smoke/split_*`; all `found == find_ops`):
- deep fill 10 at 64 / 64: 4190 M
- deep fill 90 at 256 / 64: 2462 M
- deep fill 50 with batch 30: 3058 M (slow path, warning printed)
- scalar fill 50 at 128 / 64: 4115 M

## 28. Batch check in the constructor, pop-path trims, batch 64–256 (E28, `tables/E28.md`)

**Code** (`attempt10/cleanup.diff`):
- **Constructor:** with `DEEP_VECTORIZATION`, it aborts if `batch_len % 4 != 0` (checked: batch 30 aborts with the message). `find_batch` no longer tests sizes.
- **Short final batch:** the deep loop covers the multiple-of-4 part of the batch. The 1–3 leftover arguments of a caller's short final batch go through the generic `pop_find_queue` / `add_to_find_queue`. This occurs in the harness's last call per thread, e.g. 38 left at fill 30. Fill 30 is correct.
- **Pop-path trims:**
  - bucket index via BMI1 `andn` (inline asm, because gcc folded `__andn_u32(~bmask, h)` back into a 2-operand AND that needs a register copy);
  - key broadcast from memory (`vpbroadcastq m64`, inline asm);
  - hit branch `[[likely]]`, so the 4 completions fall through without taken jumps.
  - Result: ~24 instructions per completion, from ~26.

**Result** (3 reps; pre-trim build `attempt10/deepvec_pretrim`; all `found == find_ops`):
- **Trims:** instructions per find 57.5 → 54.5 at fill 10 (64 / 64) and 72.0 → 69.2 at fill 90 (256 / 64). Finds/s +2.2 % at fill 10 (4235 → 4327) and +0.5 % at fill 90 (2589 → 2603).
- **fill 10 best:** queue 128 / batch 128, 4371 M (+0.4 % vs scalar 4352, 311.6 GB/s). The highest bandwidth is 64 / 64, 4327 M and 316.7 GB/s.
- **fill 90 best:** queue 256 / batch 128, 2616 M (+0.2 % vs scalar 2611, 281.1 GB/s). 256 / 64 gives 2603 M and 283.6 GB/s.
- **Batches 128 and 256** cut instructions per find further (51 at batch 256) but do not raise finds/s. Bandwidth falls slightly with batch 256.
- **Deep pop/push now matches scalar at both fills** (within ±1 %) and uses 4–5 fewer instructions per find.
- **Instructions are no longer what limits fill 90:** 4 fewer instructions per find than scalar, at the same speed.
- **North star:** 328 GB/s is not reached. Best is ~317 GB/s at fill 10 (−3.5 %) and ~284 GB/s at fill 90 (−13 %).

## 29. Profile of the trimmed deep path, and the L1 prefetch distance (E29, `tables/E29.md`)

**Profile** (`perf record -e cycles:u`, queue 64 / batch 64, `attempt10/prof/trim_f*`):
- About half of `find_batch`'s cycles land on the 4 `kortestb` right after each bucket compare (11–14 % each at fill 10, 9–11 % at fill 90): the wait for the bucket line.
- Deep pop region: 60.5 % (fill 10) / 55 % (fill 90). Deep push + loop: 17.9 % / 14.3 %. The 4-result store is < 0.1 %.
- One source-level item: the loop-end pointer is kept on the stack (`cmp %r10,-0x28(%rsp)`, 1.9 %).

**L1 prefetch distance:**
- `PREFETCH_FIND_NEXT_DISTANCE` is now settable with `-DFIND_PF_DIST=N` (default 8, unchanged).
- Builds `attempt10/pf{8,16,24,32}` (checked: next-slot offset 0x80/0x100/0x180/0x200).
- Batch 64, 3 reps, all `found == find_ops`.

| fill | queue | distance 8 | 16 | 24 | 32 |
|---|---|---|---|---|---|
| 10 | 64 | 4316 (316.3 GB/s) | 4393, +1.8 % (318.8) | 4357, +0.9 % (318.7) | 4330, +0.3 % (318.0) |
| 10 | 128 | 4306 (313.2) | 4348, +1.0 % (315.7) | **4410, +2.4 % (318.4)** | 4412, +2.5 % (318.1) |
| 90 | 64 | 2545 (284.1) | 2573, +1.1 % (285.9) | 2569, +0.9 % (286.2) | 2553, +0.3 % (285.6) |
| 90 | 128 | 2576 (283.3) | 2595, +0.7 % (285.8) | **2614, +1.5 % (286.2)** | 2573, −0.1 % (285.9) |

**Reading:**
- A longer distance helps only a little: +1–2.5 % finds/s and +2–5 GB/s, partly inside rep spread.
- The best single setting is queue 128 / batch 64 / distance 24: 4410 M and 318.4 GB/s at fill 10, 2614 M and 286.2 GB/s at fill 90.
- The stall at the compare is not mainly a too-late prefetch. L1 fill buffers stay full 59–61 % of cycles (50–52 % at fill 90) at every distance. A software prefetch to L1 needs a fill buffer, so issuing it earlier does not make more of them available.
- North star: still ~3 % short of 328 GB/s at fill 10 and ~13 % short at fill 90.

## 30. E30 — SIMD multiplicative hash (`HASHER=mult`)

**Code** (`attempt10/cleanup.diff`):
- **New hasher:** `HASHER=mult` (`hasher.hpp`, `CMakeLists.txt`): h = bits 32..63 of the low 64 bits of key × 0x9E3779B97F4A7C15. That is what `vpmullq` computes, and it fits the 16 B entry's 32-bit hash. Inserts use it through `Hasher`.
- **`hash_u64()` in `cas_kht.hpp`:** replaces every hard-coded `_mm_crc32_u64` in the find paths (scalar, deep, reprobe chains, `deep_pop_find_queue`). The fast paths now match inserts for any hasher, which fixes the `HASHER=city` mismatch noted in §19.
- **Deep push under `HASHER=mult`:** the 4 keys in the block register are hashed with one `vpmullq`. One permute moves bits 32..63 into the hash slots, the block is stored, and the 4 bucket prefetches read the hashes back from the entries just written.
- **Diagnostic option `DEEP_VEC_SCALAR_HASH`:** the same mult hash computed with 4 scalar `imul`s.

**Builds** (`attempt10/`): `dc24` (deep, crc), `dm24` (deep, SIMD mult), `dm24s` (deep, scalar mult), `qc` / `qm` (scalar crc / mult). Deep builds use L1 prefetch distance 24; all use queue 128 / batch 64. All `found == find_ops` at fills 10/50/90.

**Result** (3 reps, `tables/E30.md`):

| fill | scalar crc | scalar mult | deep crc | deep mult, SIMD hash |
|---|---|---|---|---|
| 10 | 4394 M, 312.7 GB/s | 4325, 312.9 | **4428, 319.2** | 4028, 289.0 (−9 %) |
| 50 | 4060, 307.9 | 4074, 307.0 | 4023, 310.1 | 3836, 285.8 (−5 %) |
| 90 | 2630, 290.0 | **2665**, 288.5 | 2589, 286.5 | 2519, 275.4 (−3 %) |

- Inserts are 1–3 % faster with `mult` (e.g. 2070 vs 2009 M/s at fill 90).
- Buckets read per find are the same within 0.03 for both hashes, so `mult` does not change the reprobe rate.

**Reading:**
- **The SIMD hash is slower, not faster**, even though it runs ~1.4 fewer instructions per find at a higher core clock (2.19 vs 2.10 GHz). Total stall cycles rose from 36 % to 44 %.
- **Not store forwarding:** `ld_blocks.store_forward` is 0.01 per find.
- **The vector multiply is the cause.** In a 2-rep diagnostic at fill 10 (`logs/E30_diag`):
  - deep crc 4326 / 4388 M;
  - deep mult with scalar `imul` 4292 / 4373 M;
  - deep mult with `vpmullq` 4100 / 4146 M.
- The scalar multiplicative hash matches crc, so the cost is in the 512-bit multiply and the readback that depends on it. This is consistent with a 512-bit multiply affecting the core (e.g. a power/frequency license effect), which this kernel exposes no counters for.
- **Recommendation:** keep crc for the deep path. `HASHER=mult` is neutral for finds and +1–3 % for inserts. `hash_u64()` is worth keeping regardless, as the hasher bug fix.

**Reverted (after §30):**
- The SIMD hash and `HASHER=mult` are removed (`hasher.hpp`, `CMakeLists.txt`, the `vpmullq` push path, `DEEP_VEC_SCALAR_HASH`, `hash_u64()`). All find paths call `_mm_crc32_u64` directly again, as before §30.
- Check: the rebuilt deep build at distance 24 (`attempt10/dc24`) has an instruction sequence for `find_batch` identical to the pre-§30 `attempt10/pf24`.
- Single runs, all found: 4411 M at fill 10, 2643 M at fill 90.
- `attempt10/cleanup.diff` is regenerated. The `FIND_PF_DIST` knob (§29) stays.
- With the direct crc32 calls, the find fast paths again match inserts only under `HASHER=crc` (as in HEAD, §19).

## 31. E31 — current deep build vs scalar, fill 10–90 (`bwgap/plot_e31.py`, `tables/E31.md`, `figures/E31_fill.png`)

**Setup:**
- Deep pop/push (`attempt10/dc24`: crc32, L1 prefetch distance 24) vs scalar (`attempt10/qc`).
- Both at queue 128 / batch 64, key prefetch 64 ahead with t2, keys in HBM.
- Read factor scaled with fill; 3 interleaved reps per point; all `found == find_ops`.

| fill | deep finds/s (M) | scalar finds/s (M) | deep vs scalar | deep HBM GB/s | scalar HBM GB/s |
|---|---|---|---|---|---|
| 10 | 4311 | 4343 | −0.7 % | 315.7 | 311.6 |
| 20 | 4305 | 4371 | −1.5 % | 318.0 | 314.9 |
| 30 | 4258 | 4315 | −1.3 % | 318.9 | 318.1 |
| 40 | 4224 | 4260 | −0.8 % | 317.0 | 313.0 |
| 50 | 4031 | 4022 | +0.2 % | 308.0 | 304.2 |
| 60 | 3814 | 3894 | −2.1 % | 301.2 | 305.3 |
| 70 | 3575 | 3575 | +0.0 % | 297.8 | 291.8 |
| 80 | 3074 | 3128 | −1.7 % | 281.2 | 285.0 |
| 90 | 2643 | 2610 | +1.3 % | 286.6 | 289.4 |

**Reading:**
- The two builds are within ±2 % of each other at every fill, inside rep spread at most points.
- Finds/s fall from ~4.3 G to ~2.6 G as fill goes from 10 to 90, the reprobe cost.
- HBM bandwidth stays between 281 and 319 GB/s. It peaks at 317–319 GB/s for deep at fill 20–40, ~3 % short of 328, and is lowest at fill 80 (281–285 GB/s).

## 32. E32 — 16 B find / insert arguments (`SPLIT_ARGS`; `bwgap/plot_e32.py`, `tables/E32.md`, `figures/E32_split.png`)

**Code** (`attempt10/cleanup.diff`):
- **`types.hpp`:** `FindArgument {key, 4 unused bytes, id}` (laid out like the 16 B find-queue entry) and `InsertArgument {key, value}`, 16 B each.
- **`cas_kht.hpp`:**
  - The 2025_INLINE `find_batch` / `insert_batch` bodies and `add_to_find_queue` / `add_to_insert_queue` are templates on the argument type.
  - The virtual `InsertFindArguments` methods call them unchanged; every other hash table and caller keeps the 24 B `InsertFindArgument`.
  - New overloads take `FindArguments` / `InsertArguments`.
  - With 16 B find arguments the deep push loads the 4 arguments as one 64 B block and only inserts the hashes; no permute.
  - Checked: with `SPLIT_ARGS` off, the deep build's `find_batch` is instruction-for-instruction identical to before.
- **`zipfian_test.cpp`** (CMake `SPLIT_ARGS`): builds 16 B arrays (2 stores per request instead of 3) and calls the CAS table's new overloads.

**Run:** builds `attempt10/{dc24, dc24s, qc, qcs}` (deep at distance 24 / scalar, each 24 B or 16 B), queue 128 / batch 64, 3 interleaved reps. All `found == find_ops` (fill 30 included, which has short final batches).

| fill | deep 24 B → 16 B finds/s (M) | scalar 24 B → 16 B | HBM GB/s deep 24 → 16 B | inserts/s deep 24 → 16 B |
|---|---|---|---|---|
| 10 | 4407 → **4661 (+5.8 %)** | 4318 → 4541 (+5.2 %) | 317.2 → **328.2** | 3220 → 3290 |
| 30 | 4250 → 4494 (+5.7 %) | 4272 → 4445 (+4.0 %) | 317.8 → 324.8 | 3109 → 3185 |
| 50 | 4055 → 4252 (+4.9 %) | 4125 → 4191 (+1.6 %) | 310.7 → 319.1 | 2972 → 3049 |
| 70 | 3521 → 3688 (+4.7 %) | 3612 → 3648 (+1.0 %) | 294.3 → 302.0 | 2628 → 2707 |
| 90 | 2624 → 2694 (+2.7 %) | 2606 → 2633 (+1.0 %) | 287.2 → 293.6 | 2004 → 2080 |

**Reading:**
- Split arguments help everywhere: +2.7 to +5.8 % finds/s for the deep build and +1 to +5 % for scalar. Inserts are +2–4 %.
- The deep build gains more than scalar at mid and high fill (+4.7–4.9 % vs +1.0–1.6 % at fill 50–70). Its push now uses the arguments as loaded.
- With split arguments, deep is ahead of scalar at every fill (+2.6 % at fill 10, +1.1 % at 30, +1.5 % at 50, +1.1 % at 70, +2.3 % at 90).
- **North star:** deep with split arguments reaches **328.2 GB/s at fill 10**, the target, and 324.8 GB/s at fill 30. Higher fills are still short: 319 / 302 / 294 GB/s at fill 50 / 70 / 90.

## 33. E33 — no `key_id` in the insert queue (`tables/E33.md`)

**Code** (`attempt10/cleanup.diff`):
- The CAS table no longer writes `ItemQueue::key_id` on any insert-queue write. There are 5 sites: the fast-path push and its reprobe push, the two branched/SIMD insert reprobe paths, and `add_to_insert_queue`.
- Nothing on the insert path reads it; `key_id` is only read when writing find results. The field stays in `ItemQueue`, which other code still shares (find-queue fallback, tests). The entry is 32 B either way.
- The `arg_id` helper is removed.
- All `found == find_ops` (fills 10/30/50/90).

**Result** (deep, 16 B arguments, distance 24, queue 128 / batch 64, 3 interleaved reps; `attempt10/dc24s_kid` = before, `dc24s` = after):

| fill | inserts/s (M) before → after | finds/s (M) | HBM GB/s |
|---|---|---|---|
| 10 | 3286 → 3274 (−0.4 %) | 4665 → 4638 | 329.4 → 326.1 |
| 50 | 2942 → 2904 (−1.3 %) | 4204 → 4221 | 314.9 → 316.0 |
| 90 | 2088 → 2093 (+0.2 %) | 2740 → 2698 | 297.9 → 293.0 |

**Reading:**
- No measurable effect; all changes are within rep spread.
- A smaller insert-queue footprint would need a dedicated entry type. Key + value + 32-bit hash is 20 B, so it does not fit 16 B the way the find entry does.
