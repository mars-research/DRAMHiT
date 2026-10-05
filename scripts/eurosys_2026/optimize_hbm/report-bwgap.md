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
| metric | bw_t1 | **bw_t1, core held at 2.2 GHz** | dramblast, keys in HBM | dramblast, keys in DDR (ref.) |
|---|---|---|---|---|
| HBM GB/s (controllers) | 397.0 [397.6; 393.8–399.8] | **373.7** [373.1; 372.8–374.3] | **293.7** [293.8; 292.8–295.4] | 263.9 |
| core GHz | 2.536 [2.535; 2.530–2.564] | 2.195 [2.195; 2.194–2.195] | 2.203 [2.205; 2.188–2.209] | 2.173 |
| mesh GHz | 1.841 | 1.890 | 1.681 | 1.665 |
| IPC | 0.54 | 0.59 | 1.68 | 1.73 |
| instr rate per thread (G/s) | 1.36 | 1.28 | 3.70 | 3.74 |
| package W | 347.5 | 348.9 | 348.2 | 348.5 |
| xq full % / fb_full % | 67.4 / 67.5 | 63.0 / 66.3 | 13.8 / 53.8 | 14.1 / 54.3 |
| program lines (finds) per s (G) | 6.134 | 5.776 | 4.153 | 4.190 |
| window from program (s) | 4.38 | 4.65 | 5.17 | 5.13 |
| energy per program line (nJ) | 56.6 | 60.4 | 83.8 | 82.9 |
| energy per HBM line (nJ) | 56.4 | 59.8 | 75.6 | 84.5 |
| HBM lines per program line | 1.013 | 1.012 | 1.106 | 0.982 |
| cycles per HBM line (64 × core GHz ÷ HBM lines/s) | 26.1 | 24.1 | 30.6 | 33.7 |

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
