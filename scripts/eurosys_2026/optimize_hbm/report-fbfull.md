# Open research 3: can the find path avoid `fb_full`?

From `human.md`: assume the line-fill-buffer (LFB) status were known for free; could the code be
written so that a prefetch never hits `fb_full`, and would that be efficient? The question has
two parts, and the data answer them differently:

1. **Is `fb_full` costing throughput?** Mostly no. It is a symptom of the memory system running
   at its throughput plateau, not a cost on top of it.
2. **How much is there to win at all?** About 17–24% in throughput, against a microbenchmark that
   runs the same prefetch pattern at a similar instruction count (55–64 per line; dramhit is
   ~56). Roughly half is core clock (a power effect) and half is cycles, and the cycles part
   is mostly the in-core floor of the real code (instruction-level parallelism), not the
   memory stall.

Everything here is `attempt4/rck` (the best build so far) on 64 threads of node 0, table in HBM
node 2, hardware prefetchers off, unless stated. Counters were taken in separate runs per event
group (a core has few programmable counters) and each row is **one run**, with only 1–5 settled
200 ms intervals per phase; treat differences of a few percent as noise.

## 1. Measurements

### 1.1 The tools

- `fbfull/mlp_profile.py`: runs a command under `perf stat -a --per-socket -I 200` with three event
  groups, splits socket 0's rows by the program's own phase markers, and derives clock, IPC,
  `fb_full`, L2→mesh queue occupancy, HBM bandwidth and mesh clock per phase.
- `machine_stats/bandwidth.c`: two new calibration modes (diff below), plus `-pad`, `-near`
  and an overridable `NUM_ITERATIONS`:
  - `-inst t1pad`: the `t1` loop plus `-pad N` independent ALU instructions per line.
  - `-inst double`: dramhit's find pattern. A `prefetcht2` `-lookahead` lines ahead (the
    enqueue-time prefetch, HBM→L2), a `prefetcht0` `-near` lines ahead (the dequeue-time
    prefetch, L2→L1), then the demand load; also takes `-pad N`.

### 1.2 Queue occupancy, one row per workload

`HBM GB/s` is counted at the controllers. `L2q/thr` is the mean number of outstanding L2-miss
reads per thread (`offcore_requests_outstanding.data_rd`, summed over cpus, ÷ cycles, scaled by
cpus ÷ active threads); `xq full` is `xq.full_cycles` ÷ cycles. `fb_full` is
`l1d_pend_miss.fb_full` ÷ cycles.

```
workload                phase  HBM GB/s  mesh  core  IPC  fb_full%  L2q/thr  xq full%
bandwidth_rand t1 x8    run         98   2.37  2.69  0.24      8       30        4
bandwidth_rand t1 x16   run        191   2.18  2.69  0.35     16       30       11
bandwidth_rand t1 x32   run        330   1.82  2.50  0.53     32       32       30
bandwidth_rand t1 x48   run        350   1.87  2.56  0.46     44       26       42
bandwidth_rand t1 x64   run        391   1.84  2.51  0.53     67       25       67
bandwidth_rand load x64 run        321   2.07  2.69  0.24     82       25        1
bandwidth_rand t1avx512 run        388   1.81  2.47  0.70     64       26       58
bandwidth_rand heavy    run        320   1.72  2.29  0.75     55       28        3
dramhit base            find       253   1.71  2.31  1.78     51       24        5
dramhit l1 (1 pf, t0)   find       206   1.89  2.54  1.23     98       25        0
dramhit l2 (1 pf, t1)   find       239   1.74  2.32  1.55     45       24        2
dramhit rck             find       275   1.65  2.13  1.74     55       26       16
dramhit rck, fill 90    find       262   1.61  2.12  1.41     48       28        8
dramhit rck, queue 16   find       235   1.78  2.42  1.33     52       25        1
dramhit rck, queue 32   find       278   1.62  2.15  1.73     54       25       14
dramhit rck, queue 128  find       271   1.60  2.10  1.74     55       25       16
```

What it shows:

- **The microbenchmark is memory-stalled; dramhit is mostly executing.** IPC 0.5 against 1.7,
  and the L2→mesh queue is full 67% of the time against 16%.
- **`fb_full` does not rank the variants.** `rck` has more `fb_full` than `base` (55% vs 51%)
  and more throughput; the build with the most (`l1`, 98%) is the slowest; the trivial loop
  at the system's maximum has 67%. High `fb_full` goes with being at, or past, the memory
  limit.
- **The `l1` build is the one that is genuinely fill-buffer-bound.** One `prefetcht0` per find
  holds an LFB until the line arrives in L1. 16 buffers × 32 cores × 64 B ÷ 206 GB/s = 159 ns,
  which is the unloaded memory latency (the `bandwidth_rand` rows at 8 and 16 threads, where
  nothing queues, give 155–157 ns). So the 16-buffers-per-core arithmetic holds there, and the
  DOUBLE scheme exists to avoid it: its first prefetch only has to reach L2, and its second
  one (L2→L1) holds a buffer for the L2 latency of ~7 ns, which needs about one of the 16
  buffers at dramhit's rate.
- **Queue depth.** 16 entries is clearly worse (235 GB/s); 32, 64, 128 are the same (278,
  275, 271). By Little's law the lookahead must cover the latency ÷ the time per find:
  ~300 ns ÷ 15 ns ≈ 20 entries, which is between 16 and 32. The queue depth of 64 has spare
  room.
- **A column I do not trust:** the latency derived as `outstanding ÷ requests` reads 155 ns
  at 8 threads (plausible) but 350–420 ns for dramhit's finds and 420 ns for `l1`, where the
  LFB arithmetic above implies ~159 ns. I do not know what the counter includes, so I do not
  use it as a round-trip latency.
- **`l1d_pend_miss.pending` is not usable for fill-buffer occupancy:** it is ~0.1–0.9
  outstanding per thread everywhere, so it counts demand-load misses only, not software
  prefetches.

### 1.3 Where the cycles go: cache-resident vs HBM-resident (dramhit `rck`)

Same binary, table shrunk (`--ht-size`, `--read-factor` raised to keep ~60 M finds per thread).

| table | lines come from | core GHz | IPC | cycles/find | `fb_full` |
|---|---|---|---|---|---|
| 2^22 entries (64 MiB) | L2 | 2.69 | 2.50 | **23.0** | 0.2% |
| 2^26 (1 GiB) | HBM | 2.29 | 1.79 | 34.1 | 48% |
| 2^29 (8 GiB, the benchmark) | HBM | 2.13 | 1.74 | 32.0 | 55% |

- **The in-core floor is ~23 cycles per find at IPC 2.5.** The 400 GB/s cycle budget from
  `report-throttling.md` (~22 cycles at 2.15 GHz) is therefore already used up by the code
  itself with every memory stall removed.
- Two other table sizes were run (2^20 and 2^24). The 2^20 run gave 40 cycles and the 2^24 run
  33 cycles with almost no HBM traffic; I cannot explain either and **do not use them**. An
  earlier version of this analysis concluded from the 2^24 run that "lines beyond L2 cost the
  same whether from L3 or HBM". The controlled test in §1.5 shows that is wrong.

### 1.4 Calibration: cycles per line against instructions per line (`bandwidth_rand`)

64 threads, 256 MB per thread (HBM), instructions per line from perf on socket 0:

| `t1pad`: instr/line → cycles/line | `double`: instr/line → cycles/line |
|---|---|
| 15 → 28.5 | 22 → 27.4 |
| 26 → 28.2 | 39 → 26.8 |
| 35 → 28.1 | 48 → 27.5 |
| 44 → 28.6 | 55 → 28.6 |
| 52 → 29.7 | 64 → 30.8 |
| 69 → 33.0 | 81 → 36.5 |

For the same code on L2-resident data (256 KB per thread, longer runs): `t1pad` 5.8 → 22.7 and
`double` 8.0 → 26.7 cycles per line as instructions go from 15 → 69 and 22 → 81.

- **A flat plateau at 27–29 core cycles per line** (~400 GB/s at a ~2.4–2.5 GHz core and
  ~1.8 GHz mesh) from 15 up to ~50 instructions per line. Extra instructions there cost no
  cycles: the memory system sets the pace. Compute only counts above ~50–55 instructions
  per line.
- **dramhit sits at that knee.** ~56 instructions per find with the harness. The microbenchmark
  with the same scheme and instruction count costs 28.6–30.8 cycles; dramhit costs 32.
- **Below ~48 instructions per line, trimming buys nothing in cycles.** Between 48 and 64 the
  slope is 0.15–0.26 cycles per instruction.
- **The plateau is not a symptom of the loop being too simple.** The trivial loop at the plateau
  has `fb_full` at 76% and still delivers the system's maximum.
- **A side effect that matters for the power story:** in the HBM `double` series the core
  clock rises from 2.33 to 2.52 GHz as the pad grows, while HBM traffic falls from 387 to
  304 GB/s. The memory traffic, not the ALU instructions, is what eats the 350 W budget
  (see `report-energy.md`).

### 1.5 Where the plateau starts: the `double` loop at ~55 instructions per line

| buffer per thread | where the lines are | core GHz | IPC | cycles/line | `fb_full` | HBM GB/s |
|---|---|---|---|---|---|---|
| 256 KB | L2 | 2.69 | 3.04 | 18.1 | 0% | 0.2 |
| 1 MB | L2 | 2.69 | 3.04 | 18.1 | 0% | 0.2 |
| 4 MB | mostly L3 | 2.51 | 2.94 | 18.6 | 15% | 51 |
| 16 MB | HBM | 2.39 | 2.01 | 27.7 | 66% | 364 |
| 64 MB | HBM | 2.38 | 1.95 | 28.3 | 66% | 367 |
| 256 MB | HBM | 2.38 | 1.92 | 28.7 | 65% | 365 |

**L3-sourced lines cost the same as L2-resident ones; the step of ~10 cycles per line appears
only when lines come from HBM.** It is the HBM-throughput plateau. dramhit's own step is
+9 cycles (23.0 → 32.0), the microbenchmark's is +10.6 (18.1 → 28.7).

## 2. What this says about the question

**Would a perfect LFB-aware scheduler help?** Its ceiling is the microbenchmark at the same
scheme and instruction count. Counting lines per second (program's line rate × 64 B; dramhit's
finds × 64 B = 274 GB/s):

| matched at | microbenchmark | gap | core clock | cycles per line |
|---|---|---|---|---|
| 55 instr/line | 339 GB/s | +24% | 2.37 vs 2.13 GHz (+11%) | 28.6 vs 32.0 (+12%) |
| 64 instr/line | 321 GB/s | +17% | 2.42 vs 2.13 GHz (+14%) | 30.8 vs 32.0 (+4%) |

dramhit is ~56 instructions per find, so the first row is the closer match. The gap is therefore
roughly half core clock, half cycles:

- **Core clock, 11–14%:** 2.13 GHz for dramhit against 2.37–2.42 at the same 350 W. This is a
  power effect, not a stall effect.
- **Cycles per line, 4–12%:** at the same instruction count the real code runs at IPC 2.5
  against the microbenchmark's 3.04 on cached data, 23 against 18 cycles, a 5-cycle
  difference in the in-core floor.

Interpolating the calibration to 56 instructions per line gives ~29 cycles for the HBM case, so
the observed 32 is ~3 cycles (~10%) above it. **That ~10% is the most a scheme that removed every
fill-buffer-related stall could recover from this code**, and it assumes the whole excess is
stalls. Part of it is more likely the in-core floor (the 5-cycle ILP difference above), not
stalls.

**The L1-capacity question.** The L1D is 48 KiB per core (768 lines; 384 per thread). With the
second prefetch 8 queue slots ahead, ~8 lines per thread (16 per core, ~2% of the L1) are in
L1 waiting for their compute. L1 capacity is not the limit, and the fill-buffer occupancy of
the L2→L1 hop is about 1 of 16 buffers (0.13 G finds/s per core × ~7 ns). The limit that binds
for the `l1` build (all prefetches to L1) is different: each holds a buffer for ~159 ns.

**What an "LFB status" signal would not change:** the plateau is a downstream throughput limit.
The trivial loop shows `fb_full` at 65–77% while moving 391–405 GB/s; a scheduler that avoided
every stall would issue the same requests at the same rate, because the requests, not the
waiting, are what the memory system limits.

**Prefetch engine:** the find queue already is one, with its depth as the lookahead. Depth ≥ 32
is enough here (§1.2); more buys nothing.

## 3. Candidate directions, ranked by what the data supports

1. **In-core ILP of the find loop** (23 against ~18 cycles of floor at the same instruction
   count). This is new: instruction *count* is nearly exhausted (§1.4), but the achieved IPC is
   2.5 where the synthetic loop reaches 3.04. Candidates: remove loop-carried dependencies
   through `tail`/`head`/`vp_result`, process two keys per iteration (software pipelining). It
   needs a perf look at the stall reasons of the cache-resident run (e.g. `cycle_activity.*`,
   port utilization) before any code change; I have not done that.
2. **Fewer lines per find at high fill.** Bytes per find rise from 60 at fill 10 to 98 at fill
   90, and a line costs ~22–25 nJ against ~0.2 nJ per instruction (`report-energy.md`).
3. **The remaining overlap near the knee:** at most 7–10% of cycles, and not obviously reachable.
4. **Not worth pursuing:** dropping or reshaping prefetches (the `l1`/`l2` builds), a deeper
   queue, or LFB-status tricks.

## 4. Follow-up: where the rest of the gap to `bandwidth_rand t1 x64` comes from

The question: dramhit `rck` finds reach 275 GB/s and `bandwidth_rand t1` ×64 reaches 391 GB/s;
frequency explains part of it, so what is the rest, and is dramhit issuing its memory requests
less efficiently? (`fbfull/results/cmp_*`, `fbfull/results/tma_*`, `attempt5/`.)

### 4.1 What XQ is

`xq.full_cycles` is, in perf's own words, the "number of cycles when the thread is active and the
uncore cannot take any further requests (for example prefetches, loads or stores initiated by the
Core that miss the L2 cache)". It is back-pressure from the mesh on the core's L2-miss traffic:
the core has requests ready and the interface towards the uncore has no room.

### 4.2 The two data points

| | `bandwidth_rand t1` ×64 | dramhit `rck` finds | what it says |
|---|---|---|---|
| HBM GB/s | 391 | 275 | |
| core / mesh GHz | 2.51 / 1.84 | 2.13 / 1.65 | |
| IPC | 0.53 | 1.74 | |
| **xq full** | **67%** | **16%** | the mesh is saturated in the first, not in the second |
| top-down: backend memory-bound | **66.2%** | 11.8% | the first is stalled on memory, the second mostly executing |
| top-down: retiring | 16.0% | 57.4% | |
| outstanding L2-miss reads per thread | 25 | 26 | the same request-level parallelism |

**`bandwidth_rand t1` saturates the fabric (requests wait for the uncore; its cores spend
two-thirds of their slots stalled on memory). dramhit does not: its requests are accepted
promptly and its cores are busy computing.** dramhit is limited by how fast its cores can
produce requests, not by the fabric. That is the headline difference, and it is the opposite of
"the memory requests are being issued badly".

### 4.3 How the 1.42× splits

lines/s ÷ lines/s = (core clock ratio) × (cycles-per-line ratio):

- 391 / 275 = 1.42 = **1.18 (core clock 2.51 / 2.13)** × **1.21 (cycles per line 31.8 / 26.3)**.
- Of the cycles part, a loop of dramhit's instruction count (~55 per line) already costs 28.6
  cycles in the microbenchmark with the same prefetch pattern (§1.4), against 26.3 for the 15-
  instruction `t1` loop: that is **+2.3 cycles** that any 55-instruction find pays. The remaining
  **+3.2 cycles** (31.8 vs 28.6) are specific to dramhit.
- In logarithms (shares of the 1.42): core clock ≈ 47%, instruction count ≈ 24%, dramhit-specific
  ≈ 30%.
- The clock itself is not explained: the equal-instruction microbenchmark runs at 2.37 GHz while
  moving *more* HBM traffic (365 GB/s) than dramhit (275), so dramhit's package draws more power
  per line moved. Candidate causes not separated: its 512-bit load/compare (the AVX-512 test in
  `report-throttling.md` §5 measured −0.09 GHz, ~3.6%, for that), the harness work, the queue
  traffic.

### 4.4 Is dramhit issuing prefetches less efficiently? Four tests, all negative

1. **Scheme and instruction count reproduced in the microbenchmark** (§1.4): 339 GB/s against
   dramhit's 275, so the prefetch pattern itself is not the limit.
2. **Prefetch acceptance.** `l2_rqsts.swpf_hit + swpf_miss` ÷ `sw_prefetch_access.*` is 0.68
   for dramhit and 0.68 / 0.64 for the equivalent `double` loops (pad 24 / pad 0). The raw
   fraction is below 1 even for an unpressured 8-thread control (0.41), so the counter
   undercounts regardless of load; **my first reading of 0.68 as "32% of prefetches dropped"
   was wrong, and I withdraw it**.
3. **Do the table lines arrive?** Demand loads that miss L1 (`mem_load_retired.l1_miss`) are
   0.006 per find and L2 misses 0.002. The prefetches work: the hash-table line is almost always
   in L1 when it is loaded.
4. **Late prefetches exist, but they are the harness's key reads, and they are cheap.**
   `mem_load_retired.fb_hit` (a demand load that found its line still in flight) is 0.085 per
   loop iteration in dramhit against 0.008 for the equal-instruction microbenchmark. Sampling the
   event: 56% of the samples are in `ZipfianTest::run` and only 7% in `find_batch`; by line,
   44% are `zipfian_test.cpp:169`, `value = workload[idx];`. The harness prefetches that per-thread,
   replayed 6.7 MB key array only 16 keys ahead with `prefetcht0`. A diagnostic build made the
   distance configurable (`attempt5/zipfian_key_prefetch.diff`; **reverted afterwards, the
   benchmark source is unchanged**) and found no effect: median finds 4222 / 4326 / 4240 Mops
   at 16 / 128 / 512 keys (fill 10, 5 reps interleaved, ranges overlap) and 2652 / 2650 / 2579 at
   fill 90 (3 reps). Whatever those loads cost, lengthening the lookahead does not recover it.

### 4.5 Top-down comparison at equal instruction count (TMA level 2, share of slots)

| | retiring | frontend | bad spec | backend memory | backend core |
|---|---|---|---|---|---|
| `bandwidth_rand t1` ×64 (HBM) | 16.0 | 1.8 | 0.1 | **66.2** | 15.9 |
| `bandwidth_rand double` +24 instr ×64 (HBM) | 61.4 | 8.0 | 0.7 | 4.6 | 25.3 |
| **dramhit `rck` finds (HBM)** | 57.4 | 7.7 | 0.8 | 11.8 | 24.4 |
| dramhit, cache-resident table (2^22) | 81.9 | 5.0 | 0.7 | 7.7 | 4.5 |
| `double` +24 instr, L2-resident | 99.2 | 0.4 | 0 | 0 | 0.4 |

- **At equal instruction count dramhit and the microbenchmark are nearly the same**, 57 vs 61%
  retiring; dramhit has about 7 more points of memory-bound slots (11.8 vs 4.6) and 4 fewer
  retiring. That is ~2–3 of dramhit's 32 cycles, which is the size of the unexplained
  dramhit-specific part (3.2 cycles) in §4.3. What those 7 points are I do not know. The late key
  loads above are one candidate, but lengthening their lookahead gave nothing.
- **A large block of "core-bound" slots (24–25%) appears with HBM-resident data in both
  programs and not with cached data** (0.4% for the microbenchmark, 4.5% for dramhit). Together
  with `fb_full` going from ~0% to 55–65%, my reading is that these are slots lost to prefetches
  waiting for a fill buffer, which top-down files under "core" because no demand load is
  outstanding. **That is a hypothesis, not tested**; a level-3 breakdown could check it.
- **The in-core efficiency is a separate item** (retiring 82% on cached data, against 99% for
  the synthetic loop): dramhit loses ~18% of its slots even with no memory stalls.

### 4.6 Summary of the answer

The gap to `bandwidth_rand t1` is mostly: core clock (a power effect, ~47%), the instructions a
find has to execute that a pure prefetch loop does not (~24%), and a dramhit-specific remainder
(~30%) made of some extra memory-bound slots and of in-core efficiency. **No evidence that the
prefetches themselves are issued less efficiently**: their acceptance matches the equivalent
microbenchmark, they arrive in time, and the one place where late loads show up (the harness's key
reads) is not where the time goes.

## 5. Files

- `fbfull/tma_profile.py` (top-down level 2 per phase), `attempt5/zipfian_key_prefetch.diff` and
  `attempt5/{d16,d128,d512}/dramhit` (the reverted harness diagnostic and its binaries),
  `fbfull/results/{cmp_*,tma_*,fbhit/}`.
- `fbfull/mlp_profile.py`, `fbfull/run_table.sh`, `fbfull/pad_sweep.sh`, `fbfull/results/*.json`,
  `fbfull/results/{table,pad_sweep,size_sweep}.log`, `fbfull/logs/` (raw perf output).
- `machine_stats/bandwidth.c` changes: `bandwidth_all_changes.diff` in this directory (against
  HEAD): the AVX-512 modes from the throttling work plus the new `-inst t1pad|double`, `-pad`,
  `-near`, and an overridable `NUM_ITERATIONS`. The binaries `build/bandwidth_rand_it<N>` are
  the same source built with `-DNUM_ITERATIONS=<N>` for small buffers.
- Counter caveats: every row is one run; 1–5 settled intervals per phase.
