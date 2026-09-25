# Why dramblast insert moves ~244 GB/s on the amd-9354p, not ~290

Question: the 1r1w microbenchmark reaches ~290 GB/s of DRAM traffic on the AMD EPYC
9354P, but dramblast (`cas`, ht-type 3) insertion in `amd/amd-9354p_uniform.json`
sits at ~244 GB/s (fill 10, 64 threads). Where does the difference go?

Collected 2026-09-24. Supersedes the open end of
[`insert_bandwidth_analysis.md`](insert_bandwidth_analysis.md) §6 ("what the remaining
~8% is: not established").

## 0. Answers

| question | answer |
|---|---|
| Is the ~290 GB/s reference measured the way dramhit runs? | No. It is the 1r1w microbenchmark at **32 threads** (one per physical core). At dramhit's **64 threads** the same microbenchmark's median drops to 264–273 GB/s. Its **peak** interval stays at ~287–296. §1 |
| Is dramblast's number a collection artifact? | Only slightly, and in dramblast's favour: the old collector overstated every AMD bandwidth by ~2.5%. That is fixed and the json rederived. §2 |
| Is dramblast out of instructions? | No. On an in-cache table one thread needs **15.8 cycles/insert**; on the 8 GiB table alone it needs 23.9; with all 32 cores busy it needs **56.5**. The extra time is the memory system, not the instruction stream. §4 |
| Is it waiting on DRAM loads? | No — its loads almost never miss (0.02 demand fills per prefetch fill); only 16–30% of pipeline slots wait on memory, against 85–89% for the microbenchmark. §5 |
| Then what is the core doing? | **Stalled with a full store queue: 58% of cycles at 32 threads, 77% at 64**, against 6–11% for the microbenchmark. It keeps only 2.7 (32 thr) / 4.0 (64 thr) L1 misses in flight per core to the microbenchmark's ~19–20. §5 |
| Does a deeper insert queue help? | No. 32 → 256 entries: ±1%. §6 |
| Does prefetching for write earlier help? | No. Moving `prefetchw` to 16/32 inserts ahead: 0 to +1.7%. Using `prefetchw` at enqueue instead of `prefetcht1` **removes** the store-queue stall (→ 1–11%) but throughput moves −10% to +3%: the stall moves to the L1 miss buffers, 10–14% of prefetches are dropped, and demand misses reappear. §6 |
| Is the double prefetch needed? | No. **`PREFETCHT1_ONLY`** (the enqueue `prefetcht1` without the dequeue `prefetchw`) matches it within 0.6% everywhere, with the same store-queue stall. The `prefetchw` is dead weight. Every scheme that prefetches at enqueue ends at 235–245 GB/s at 64 threads; no prefetch collapses to ~1100 Mops. §6 |
| Why does the store queue fill? | **Lines shared between CCXs.** ~7–8% of bucket stores hit a line another CCX's cache also holds, so the store needs an ownership upgrade at commit, and in-order commit stalls every store behind it. Same table and 4 threads: packed on one CCX → 0 upgrades, store queue full 0.2%, 578 Mops; spread over four CCXs → 0.065 upgrades/insert, full 46%, **369 Mops (−36%)**. The microbenchmark never shares a line, which is why it never pays this. §9 |

## 1. The microbenchmark, and which of its numbers to compare against

**Source:** [`../machine_stats/bandwidth.c`](../machine_stats/bandwidth.c), built by
[`../machine_stats/Makefile`](../machine_stats/Makefile) as
`../machine_stats/build/bandwidth_rand` (`gcc -O3 -DRANDOM`, `-lpthread -lnuma`).

**What it does.** Each thread gets its own buffer (`-m`, per-thread size), `mbind`'d
`MPOL_INTERLEAVE` over the nodes in its pattern's memory mask (`a0-3` = all four NPS4
nodes, the same policy dramhit's `--numa-split 1` gives the global table). The pattern
string pins threads: `n0a0-3t8` is "8 threads on node 0's cpus, memory on nodes 0–3", and
cpus are taken in ascending order, so 8 per node lands on the physical cores (0–7, 8–15,
…) and 16 per node adds the SMT siblings (32–39, …). It then walks every cache line of
its buffer once per iteration in a hashed order — the line index is
`_mm_crc32_u64(seed, i) & (lines - 1)` — so the access stream is random with no stored
key array. In write mode (`-mode w`) the loop body is

```c
// -inst t1: prefetch the line `lookahead` iterations ahead, then store 8 B into this one
GET_IDX(idx, i, state_var);
GET_LOOKAHEAD_IDX(idx_lookahead, i, state_var);
_mm_prefetch((const char *)&t->buffer[idx_lookahead * 8], _MM_HINT_T1);
t->buffer[idx * 8] = 0xff;
```

An 8 B store into a line it does not own is two DRAM transactions — the read-for-ownership
and, on eviction, the writeback — so this is the "1r1w" stream: DRAM traffic splits 50/50
read/write (measured 144.9 rd / 144.7 wr at 32 threads). About 14 instructions per access.
`-inst` picks the prefetch flavour (`load` = none, `t0`, `t1`, `t2`, `nta`,
`prefetchw`, `ntstore`); `-lookahead` its distance (64 here). The program prints
`Start perf collection` / `End perf collection` around the measured loop.

**Command lines used here** (same as
[`../collect_scalability/collect_cpu_scaling_amd.py`](../collect_scalability/collect_cpu_scaling_amd.py)):

```
bandwidth_rand -m 512mb -pattern 'n0a0-3t8 n1a0-3t8 n2a0-3t8 n3a0-3t8'   -freq 3.25 -inst t1 -lookahead 64 -mode w  # 32 thr
bandwidth_rand -m 256mb -pattern 'n0a0-3t16 n1a0-3t16 n2a0-3t16 n3a0-3t16' -freq 3.25 -inst t1 -lookahead 64 -mode w  # 64 thr
```

16 GiB total footprint either way — twice dramhit's 8 GiB table, both far past the 256 MB
of L3.

**Which number.** From `../collect_scalability/amd-9354p_cpu_scaling.json` (1r1w series,
GB/s at the controllers):

| series | 32 thr median | 64 thr median | 64 thr peak | best peak, any thread count |
|---|---|---|---|---|
| `write_load` (no sw prefetch) | 286.7 | 266.5 | 283.7 | 287.2 |
| `write_prefetchw` | 286.4 | 267.0 | 286.7 | 287.0 |
| `write_t1` | 295.9 | 272.9 | 295.3 | 296.5 |
| `write_t2` | 295.9 | 273.3 | 295.3 | 296.6 |

"Median" is the median 100 ms interval of a run, "peak" the largest interval (median
across 3 reps of each rep's largest; see
[`PEAK_VS_MEDIAN.md`](../collect_scalability/PEAK_VS_MEDIAN.md)). At 64 threads the
median is flat through the run at ~273 (not an idle tail), and the peak is the odd
interval that reaches the 32-thread plateau. My back-to-back re-measurement for this
note (with the counter set of §3) gave **289.6 GB/s at 32 threads, 263.7 at 64**.

So there are two defensible ceilings for dramblast's 64-thread insert: the **sustained**
64-thread number (~264–273), which is what a 64-thread workload has been shown to hold,
and the **peak / best-configuration** number (~290), which is what the memory system can
deliver at all. The uniform-panel plots now draw the latter (§8).

## 2. Collection fix: interval normalisation

`collect_data_amd.py` samples `perf stat -I 100 -M umc_mem_read_bandwidth,umc_mem_write_bandwidth`.
perf computes that metric as `count × 64 B / 100 ms` — the **nominal** interval — but
the intervals actually run 101–105 ms (visible in the perf timestamps, and in the
`run_ns` column: 12 boxes × ~0.1008 s). Every AMD bandwidth value was therefore ~2.5%
high: cas fill 10 read 250.2, true 243.6. `parse_bw` now rescales each interval by
`100 ms / (ts_i − ts_{i−1})`, and `amd-9354p_uniform.json` was rederived from the
existing logs (`--rederive-bw`; the pre-fix json is kept as
`amd/amd-9354p_uniform.json.pre-intervalfix.bak`). This also explains the one
unexplained number in `insert_bandwidth_analysis.md` §2: a direct per-box measurement
gave 243.8 against the json's 249.3. The collect_scalability scripts divide by `run_ns`
and were never affected.

Sampling depth is not a problem: each uniform point is the median of 5 reps, each rep the
median of 12–345 settled intervals, and the reps agree within ~1%.

## 3. Method and counters

**Build and run conditions (all dramhit runs).** `/opt/DRAMHiT/build/dramhit`, configured
exactly as `collect_data_amd.py`'s `CMAKE_FLAGS` (2025_INLINE, BUCKETIZATION, simd branch,
AVX, PREFETCH=DOUBLE, CAS_PREFETCH_INSERTION=DOUBLE, UNIFORM_PROBING, READ_BEFORE_CAS,
CAS_NO_ABSTRACT=OFF). Command line as the collection's, apart from `--num-threads` and a
shorter find phase:

```
dramhit --mode 11 --ht-type 3 --ht-size 536870912 --ht-fill {10,70} --num-threads {32,64}
        --numa-split 1 --batch-len 16 --find_queue 64 --no-prefetch 0 --hw-pref 0
        --insert-factor 100 --read-factor 1 --skew 0.01 --seed 1775762440565610239
```

`--numa-split 1` places threads 8 (or 16) per node on each node's first cpus, so 32
threads are cpus 0–31 — the physical cores, the same pinning as the 32-thread
microbenchmark (checked in both programs' logs). Hardware prefetchers off
(`prefetch_control_amd.sh off`, MSR `0xC0000108 = 0x2f`, read back on every cpu) for every
run, dramhit and microbenchmark alike. Core clock fixed at 3.25 GHz.

**Windowing.** Everything is `sudo perf stat -a -x, -I 100 -e <events> -- <program>`.
Per-interval counts are summed across cpus and boxes, cut to the program's own phase
markers (`zipfian test insert start/end` for dramhit, `Start/End perf collection` for
bandwidth_rand), and the first and last interval inside the window are dropped because
they straddle a marker. Rates divide by the sum of actual interval lengths from the perf
timestamps. Ratios below are of window totals (e.g. total MAB occupancy / total cycles).

**The NMI watchdog holds one core counter**, leaving five programmable core counters per
run; each counter set below is sized to that so nothing multiplexes. The `amd_l3` and
`amd_umc` events are on their own PMUs and add no core-counter pressure.

| counter | PMU | what it counts | used as |
|---|---|---|---|
| `amd_umc_<0..11>/umc_cas_cmd.rd/`, `.../umc_cas_cmd.wr/` | UMC (one per DDR5 channel) | read / write CAS commands, 64 B each | DRAM GB/s = 64 × count / time, summed over 12 channels |
| `ls_not_halted_cyc` | core | unhalted cycles | denominator for every per-cycle ratio |
| `ex_ret_instr` | core | retired instructions | IPC; instructions per insert |
| `ls_alloc_mab_count` | core | Miss Address Buffer occupancy summed per cycle | **L1D misses in flight** = count / cycles (per thread; ×2 per core under SMT) |
| `ls_dmnd_fills_from_sys.all` | core | L1D fills caused by demand loads/stores, from L2 or beyond | exposed misses |
| `ls_dispatch.store_dispatch` | core | store ops dispatched to the load-store unit (`event=0x29,umask=0x2`) | stores per insert = count / (set_mops × window length) |
| `ls_pref_instr_disp.all` | core | software prefetch instructions dispatched | prefetches issued |
| `ls_sw_pf_dc_fills.all` | core | L1D fills caused by software prefetches, any source | prefetches that landed in L1 |
| `ls_sw_pf_dc_fills.local_l2` | core | … of which the line came from the local L2 | share of `prefetchw` fills that found the line already in L2 |
| `ls_inef_sw_pref.all` | core | software prefetches that were redundant (already in L1, or matched an in-flight MAB) | issued − redundant − filled = did not fill L1 (for a `prefetcht1` that is the expected outcome — it targets L2; for `prefetchw` it is a real drop) |
| `l3_xi_sampled_latency.all`, `l3_xi_sampled_latency_requests.all` | amd_l3 | sampled L3-miss latency and sample count | latency in core clocks = 10 × latency / requests (perf's `l3_read_miss_latency` metric) |
| `de_no_dispatch_per_slot.no_ops_from_frontend` | core | dispatch slots empty for lack of frontend ops | top-down frontend-bound = / (6 × cycles) |
| `de_no_dispatch_per_slot.backend_stalls` | core | dispatch slots lost to backend stalls | top-down backend-bound |
| `ex_ret_ops` | core | retired macro-ops | top-down retiring |
| `de_src_op_disp.all` | core | ops dispatched | bad speculation = (dispatched − retired) / slots |
| `ex_no_retire.not_complete`, `ex_no_retire.load_not_complete` | core | cycles nothing retired because the oldest op is incomplete / is an incomplete load | splits backend-bound into memory (load) vs "core" (anything else) |
| `de_no_dispatch_per_slot.smt_contention` | core | slots given to the sibling thread | SMT share |
| `de_dis_dispatch_token_stalls1.store_queue_rsrc_stall` | core | cycles dispatch stalled because the store queue is full | **store-queue-full fraction** |
| `de_dis_dispatch_token_stalls1.load_queue_rsrc_stall` | core | … load queue full | control (0.00 everywhere) |
| `de_dis_dispatch_token_stalls2.retire_token_stall` | core | … retire queue (ROB) full | control |

Instruction attribution: `perf record -e cycles -C 0-7` over a 32-thread insert-heavy
run (`--insert-factor 300`), `perf annotate` on the two hot symbols. Plain `cycles` on Zen
skids, so a stall is charged to the instruction *after* the one that caused it; read the
annotations as "the neighbourhood of", not "this exact instruction".

## 4. Not instruction-bound

Single thread, same binary and flags, `--num-threads 1`:

| table | set Mops | cycles / insert |
|---|---|---|
| 32768 entries (512 KB, L2-resident), `--insert-factor 100000` | 206 | **15.8** |
| 8 GiB (the collection's table), `--insert-factor 2` | 136 | 23.9 |
| 8 GiB, 32 threads (fill 10) | 1773 total | **56.5** per core |

One core against DRAM, alone, sustains 136 M inserts/s — ~17 GB/s from one core. With 32
cores busy each insert costs 3.6× the in-cache cost. The instruction stream (~70
instructions per insert, `ex_ret_instr` / inserts) is not what sets the pace; contention
in the shared memory path is.

## 5. Not load-bound either: it is store-queue-bound

fill 10, `--find_queue 64`, microbenchmark `-inst t1 -lookahead 64`:

| | micro 32 thr | micro 64 thr | dramblast 32 thr | dramblast 64 thr |
|---|---|---|---|---|
| set Mops | — | — | 1768 | 1846 |
| DRAM GB/s (rd + wr) | **289.6** | 263.7 | 232.3 | 243.2 |
| read / write GB/s | 144.9 / 144.7 | 132.0 / 131.7 | 124.4 / 107.8 | 130.3 / 112.9 |
| instructions per access / insert | 14 | 14 | 70 | 68 |
| IPC (per thread) | 0.32 | 0.15 | 1.25 | 0.66 |
| L1 misses in flight, per thread | 18.9 | 9.9 | **2.67** | 2.01 |
| … per core | 18.9 | 19.8 | 2.7 | 4.0 |
| L3-miss latency, core clocks | 314 | 319 | 201 | 298 |
| top-down: retiring | 5% | 3% | 21% | 11% |
| top-down: backend, waiting on a load | **85%** | 89% | 30% | 16% |
| top-down: backend, oldest op not a load | 8% | 5% | **48%** | **68%** |
| cycles with store queue full | 11% | 6% | **58%** | **77%** |
| cycles with ROB full | 1% | 14% | 9% | 5% |
| demand fills per software-prefetch fill | (all demand) | (all demand) | 0.02 | 0.05 |

Reading it:

- **The microbenchmark is the textbook memory-bound loop**: ~19–20 L1 misses in flight
  per core, 85–89% of slots waiting on a load. It keeps the memory system saturated.
- **dramblast hides its latency** — 0.02 demand fills per prefetch fill means its loads
  essentially never wait for DRAM — **but its store queue is full most of the time**, and
  it keeps only 2.7–4 L1 misses in flight per core. Loaded L3-miss latency at 32 threads
  is 201 clocks against the microbenchmark's 314: the memory system is being driven less
  hard, not refusing requests.
- **Where the time lands in the code** (`perf annotate`, 32 threads): `insert_batch` is
  75% of insert-phase cycles and the benchmark driver (`ZipfianTest::run`, which copies
  keys from the workload array into the batch) 23%. In `insert_batch` the heaviest
  sample (24%) sits immediately after the upsert store `bucket[offset + 1] = q->value`
  (`cas_kht.hpp`, the fast path of `insert_batch`), the next (10%) after the
  `insert_queue[head]` field stores; in the driver the hot samples are all right after
  the `items[i]` stores. Every hot spot follows a store.
- **Traffic per insert.** `rd − wr` ≈ 16.6 GB/s at 32 threads is almost exactly the key
  stream the driver reads from the workload array, 8 B × 1768 M/s = 14.1 GB/s — traffic
  the microbenchmark does not have. Writes are 1.69 G lines/s against 1.77 G inserts/s:
  ~5% of inserts hit a line still in L3 (the fill-10 working set is ~3.4 GB against 256 MB
  of L3). Counted as lines dirtied per second, dramblast reaches **75% of the
  microbenchmark at 32 threads and 86% at 64**.

## 6. Knobs tried

**Insert queue depth** (`--find_queue`, which sizes `CASHashTable::insert_queue`; the
enqueue-time `prefetcht1` therefore runs that many inserts ahead). fill 10, one run each:

| queue | 32 thr Mops | 32 thr GB/s | 64 thr Mops | 64 thr GB/s | `prefetchw` fills from L2 |
|---|---|---|---|---|---|
| 16 | 1507 | 204.5 | 1877 | 249.6 | 33–38% |
| 32 | 1736 | 231.7 | 1848 | 244.3 | 77–80% |
| **64** (collection) | 1773 | 233.6 | 1858 | 243.7 | 89% |
| 128 | 1772 | 233.7 | 1863 | 244.3 | 89% |
| 256 | 1772 | 233.4 | 1850 | 243.9 | 89% |

Past 32 nothing moves. The prefetch pipeline is not starved for distance; at 64 the L2
prefetch has landed for 89% of inserts by the time the dequeue-time `prefetchw` fires.
(16 is too shallow at 32 threads; at 64 threads the sibling covers for it.)

**Prefetch scheme** (builds from `dramblast_insert_amd/build_variants.sh`; all other
flags identical; 2 reps each, interleaved):

- `base` — the collection build: `prefetcht1` at enqueue (`__builtin_prefetch(p, 0, 2)`; locality 2 is T1) + `prefetchw` 8 inserts ahead at dequeue.
- `dist16`, `dist32` — the same, `PREFETCH_INSERT_NEXT_DISTANCE` 8 → 16 / 32.
- `pw_enq` — `-DCAS_PREFETCH_INSERTION=PREFETCHW`: a single `prefetchw` at enqueue (64 inserts ahead), no second prefetch.

| fill | thr | build | Mops | vs base | DRAM GB/s | SQ full | L1 misses in flight / thr | `prefetchw` fills from L2 |
|---|---|---|---|---|---|---|---|---|
| 10 | 32 | base | 1773 | — | 233.0 | 0.58 | 2.68 | 0.89 |
| 10 | 32 | dist16 | 1770 | −0.2% | 232.9 | 0.58 | 2.69 | 0.89 |
| 10 | 32 | dist32 | 1774 | +0.1% | 233.0 | 0.58 | 2.91 | 0.85 |
| 10 | 32 | pw_enq | 1593 | **−10.2%** | 211.4 | **0.01** | 10.79 | — |
| 10 | 64 | base | 1852 | — | 244.1 | 0.77 | 2.00 | 0.89 |
| 10 | 64 | dist16 | 1848 | −0.2% | 243.8 | 0.78 | 2.03 | 0.88 |
| 10 | 64 | dist32 | 1849 | −0.1% | 243.4 | 0.78 | 2.28 | 0.85 |
| 10 | 64 | pw_enq | 1832 | −1.1% | 244.2 | **0.11** | 7.05 | — |
| 70 | 32 | base | 1492 | — | 219.9 | 0.53 | 2.60 | 0.90 |
| 70 | 32 | dist16 | 1494 | +0.1% | 219.4 | 0.53 | 2.60 | 0.90 |
| 70 | 32 | dist32 | 1518 | +1.7% | 222.8 | 0.52 | 2.79 | 0.87 |
| 70 | 32 | pw_enq | 1456 | −2.4% | 212.6 | **0.01** | 11.23 | — |
| 70 | 64 | base | 1618 | — | 237.2 | 0.73 | 2.00 | 0.90 |
| 70 | 64 | dist16 | 1618 | 0.0% | 237.4 | 0.73 | 2.02 | 0.90 |
| 70 | 64 | dist32 | 1626 | +0.5% | 238.5 | 0.73 | 2.17 | 0.87 |
| 70 | 64 | pw_enq | 1668 | +3.1% | 243.3 | **0.10** | 7.18 | — |

Prefetch fate for `base` vs `pw_enq`, fill 10:

| | issued | redundant | filled L1 | did not fill L1 | demand fills per prefetch fill |
|---|---|---|---|---|---|
| base 32 thr | 10.60 G | 4.7% | 51.8% | 43.6% (the `prefetcht1`s — they target L2) | 0.02 |
| pw_enq 32 thr | 6.03 G | 9.0% | 81.0% | **10.0% dropped** | 0.22 |
| base 64 thr | 10.84 G | 2.7% | 52.5% | 44.8% | 0.05 |
| pw_enq 64 thr | 5.89 G | 7.8% | 78.2% | **13.9% dropped** | 0.48 |

`pw_enq` is the informative one: it takes the store-queue stall away almost completely,
and throughput does not follow. Its 64-deep `prefetchw`s now all hold an L1 Miss Address
Buffer entry while in flight (7–11 per thread, up from 2–3); when the buffers are full
Zen4 discards the prefetch, 10–14% are lost, and the stores behind them become demand
misses. The limit moved from the store queue to the L1 miss buffers and landed in
roughly the same place — ~244 GB/s at 64 threads.

**Single-prefetch schemes.** Does the insert path need two prefetches at all? Five
builds, same flags otherwise, fill 10 and 70 × 32 and 64 threads, 2 reps each,
interleaved (`dramblast_insert_amd/variants2.py`, `results/variants2.json`). The
instruction mix of each build's `insert_batch` was checked with `objdump`:

- `base` — the collection build, `DOUBLE`: `prefetcht1` at enqueue + `prefetchw` 8 ahead at dequeue.
- `t1only` — **`-DCAS_PREFETCH_INSERTION=PREFETCHT1_ONLY`** (new build option, defines
  `CAS_INSERT_PREFETCHT1_ONLY`): the enqueue `prefetcht1` alone.
- `pw_enq` — `PREFETCHW`: `prefetchw` at enqueue alone.
- `t0only` — `prefetcht0` at enqueue alone (patched source copy; `build_variants.sh`).
- `none` — `NONE`: no insert-path prefetch.

Two more counters join the set: `ls_dmnd_fills_from_sys.all` (demand fills into L1 from
L2 or beyond) and `ls_dispatch.store_dispatch` (stores dispatched). Per-insert values
divide window totals by `set_mops × window length`.

| fill | thr | scheme | Mops | vs base | DRAM GB/s | rd / wr | SQ full | L1 misses in flight / thr | demand fills / insert | stores / insert |
|---|---|---|---|---|---|---|---|---|---|---|
| 10 | 32 | base | 1768 | — | 233.5 | 125.1 / 108.4 | 0.58 | 2.68 | 0.03 | 8.0 |
| 10 | 32 | **t1only** | 1778 | +0.6% | 234.2 | 125.5 / 108.7 | 0.57 | 2.68 | 1.03 | 8.2 |
| 10 | 32 | pw_enq | 1591 | −10.0% | 211.3 | 113.3 / 98.0 | 0.01 | 10.75 | 0.22 | 8.6 |
| 10 | 32 | t0only | 1571 | −11.1% | 208.7 | 111.9 / 96.8 | 0.35 | 11.22 | 0.16 | 8.4 |
| 10 | 32 | none | 932 | −47.3% | 126.1 | 67.6 / 58.4 | 0.05 | 5.17 | 1.05 | 9.3 |
| 10 | 64 | base | 1856 | — | 244.3 | 130.9 / 113.4 | 0.78 | 2.00 | 0.05 | 7.8 |
| 10 | 64 | **t1only** | 1860 | +0.2% | 244.3 | 130.9 / 113.4 | 0.77 | 2.01 | 1.05 | 7.9 |
| 10 | 64 | pw_enq | 1827 | −1.6% | 244.9 | 131.4 / 113.5 | 0.11 | 7.04 | 0.45 | 8.5 |
| 10 | 64 | t0only | 1762 | −5.1% | 234.6 | 125.8 / 108.8 | 0.30 | 7.01 | 0.45 | 8.3 |
| 10 | 64 | none | 1098 | −40.8% | 146.7 | 78.7 / 68.0 | 0.09 | 3.14 | 1.06 | 8.1 |
| 70 | 32 | base | 1503 | — | 220.7 | 126.2 / 94.6 | 0.53 | 2.61 | 0.05 | 10.7 |
| 70 | 32 | **t1only** | 1500 | −0.2% | 220.2 | 125.7 / 94.5 | 0.51 | 2.45 | 1.17 | 11.7 |
| 70 | 32 | pw_enq | 1456 | −3.2% | 212.6 | 121.0 / 91.5 | 0.01 | 11.23 | 0.21 | 11.9 |
| 70 | 32 | t0only | 1406 | −6.4% | 205.8 | 117.3 / 88.5 | 0.37 | 11.59 | 0.15 | 11.6 |
| 70 | 32 | none | 727* | −51.6% | 106.1 | 60.3 / 45.8 | 0.05 | 4.98 | 1.24 | 13.3 |
| 70 | 64 | base | 1606 | — | 236.0 | 134.9 / 101.2 | 0.72 | 2.00 | 0.08 | 9.7 |
| 70 | 64 | **t1only** | 1606 | 0.0% | 235.9 | 134.7 / 101.2 | 0.72 | 1.93 | 1.21 | 10.3 |
| 70 | 64 | pw_enq | 1661 | +3.4% | 242.5 | 137.9 / 104.6 | 0.10 | 7.18 | 0.50 | 10.8 |
| 70 | 64 | t0only | 1592 | −0.9% | 232.5 | 132.3 / 100.2 | 0.31 | 7.18 | 0.50 | 10.4 |
| 70 | 64 | none | 940 | −41.5% | 136.2 | 77.1 / 59.1 | 0.09 | 3.20 | 1.21 | 10.2 |

\* One rep overlapped a compile on the machine (704 vs 750 Mops); every other pair agrees within 1.2%.

What it shows:

- **The dequeue `prefetchw` does nothing.** Without it each insert takes one demand fill
  (1.03–1.21 per insert, served from L2 because the `prefetcht1` has landed) and throughput,
  bandwidth and the store-queue stall are unchanged. So the `prefetchw` neither causes nor
  relieves the stall — which rules out the "late `prefetchw` blocks the store queue"
  explanation an earlier draft of §7 gave.
- **The store-queue stall goes away only when the line is in L1 well ahead** — `prefetchw`
  or `prefetcht0` 64 inserts early (SQ full 0.01–0.37). Then the L1 miss buffers fill
  instead (7–12 in flight per thread), and at 32 threads those schemes are 3–11% slower.
- **At 64 threads the prefetching schemes converge**: 232–245 GB/s whatever the
  instruction. Prefetching at enqueue is essential (none is ~40–50% slower); which
  prefetch it is, and whether there is a second one, barely matters.
- **Stores per insert, measured**: 7.8–8.6 at fill 10, 9.7–11.9 at fill 70 (a longer probe
  re-enqueues, which writes the queue entry again). The 64-entry store queue holds about
  6–8 inserts' worth.

**Threads.** fill 70, 5 reps each, interleaved: 32 threads 1495 Mops / 221.2 GB/s,
64 threads 1617 / 237.5 (−7.5% insert, −21% lookup at 32). The SMT sibling adds
outstanding requests the single thread cannot; dramblast does not get the microbenchmark's
32-thread bonus because it never reaches the memory-bound regime where that bonus lives.

## 7. What is established, and what is inferred

Established by the counters above:

1. Against the matched 64-thread sustained reference the gap is ~8–10%; against the
   ~290 peak it is ~16%.
2. dramblast is not instruction-bound (§4) and not waiting on DRAM loads (§5).
3. It spends 58–77% of cycles with the store queue full, keeps 2.7–4 L1 misses in flight
   per core against ~19–20 for the microbenchmark, and so drives the memory system less
   hard (lower loaded latency).
4. Neither prefetch distance nor queue depth moves it; replacing the store-queue stall
   with `prefetchw`-at-enqueue just moves the limit to the miss buffers.
5. The second (dequeue-time) prefetch is unnecessary: `PREFETCHT1_ONLY` equals `DOUBLE`.
   Whether that `prefetchw` fires, and how early, has no effect on the store-queue stall.
6. Each insert dispatches ~8 stores at fill 10 and ~10–12 at fill 70
   (`ls_dispatch.store_dispatch`), so the 64-entry store queue covers only 6–8 inserts.

**Why the store queue fills** is answered in §9: roughly 7% of bucket stores land on a
line that another CCX also holds, need an ownership upgrade at commit, and — stores
committing in order — hold up everything behind them. (An earlier draft of this section
blamed late `prefetchw`s, then an L2 round trip or dirty evictions; §6 and §9 rule those
out.)

## 8. Plot ceiling

The insertion panel's reference line in `plot_data_bw.py` (`CEILINGS_AMD_9354P["set"]`)
is now the **1r1w peak, 290 GB/s** (§1), replacing the 64-thread sustained 274. The lookup
line is unchanged at 353. Read the insertion panel with §1 in mind: 290 is what the memory
system delivers at its best configuration (32 threads, or the best 100 ms interval at 64);
a 64-thread workload has been shown to sustain ~264–273.

## 9. Why the store queue fills: ownership upgrades on lines shared across CCXs

### 9.1 Where the time goes, precisely

IBS in cycle mode (`perf record -e cycles:pp`, Zen4's precise sampling; `-c 200003`,
cpus 0–7, 32 threads, fill 10, `--insert-factor 300`) puts 69% of insert-phase samples in
`insert_batch` and 27% in the driver loop. Within them no single instruction dominates:
the samples spread over the enqueue block (`prefetcht1` then the four `insert_queue[head]`
field stores, 3–8% each) and the driver's `items[i]` stores (5–7% each). In cycle mode IBS
tags the next op to *dispatch*, so under a full store queue the sample lands on whichever
store is waiting for a slot — the spread is the signature of a store-queue stall, not a
pointer to its cause.

IBS memory sampling (`perf mem record`, i.e. `ibs_op//`, same run) gives each sampled op's
data source:

| instruction | samples | result |
|---|---|---|
| bucket SIMD load (`vmovdqa64`) | 857 | 99.1% L1 hit, 0.9% L2 |
| **bucket upsert store** (`mov %rbx,(%rax,%r15,8)`) | 3786 | 45.2% L1 hit, 3.8% L2 hit, **50.4% no valid cache status** |
| `insert_queue[head]` stores (4) | 3125–16670 each | 99.5–99.8% L1 hit |
| driver `items[i]` stores (5) | 347–4506 each | 98.6–100% L1 hit |

Only the bucket store behaves differently.

### 9.2 Two hypotheses, and the tests

- **H1 (ownership).** The bucket line is present but not writable when the store commits;
  the store must get ownership then, and in-order commit blocks the queue behind it.
- **H2 (volume).** The ~8 bookkeeping stores per insert fill the 64-entry store queue on
  their own; the bucket store is not special.

Counters added for this (`sq_hypotheses.py`; two 5-event passes per case, fill 10):
`l2_request_g1.change_to_x` (L1→L2 requests to make a line writable),
`l2_cache_req_stat.ls_rd_blk_x` (L1→L2 store / state-change requests that hit),
`l2_cache_req_stat.ls_rd_blk_l_hit_s` / `ls_rd_blk_l_hit_x` (L1→L2 reads that hit a
non-modifiable / modifiable line), `l2_cache_req_stat.ls_rd_blk_c` (L1→L2 requests that
miss), `ls_st_commit_cancel2.st_commit_cancel_wcb_full` (store commits cancelled for a full
write-combining buffer), plus the §3 stall set. A new diagnostic build, `nostore`
(`build_variants.sh`), skips the upsert's bucket store when the value is already there —
which after the first pass it always is (value == key) — and changes nothing else.

| case | Mops | SQ full | stores / op | ownership upgrades / op | L2 read hits on a modifiable line / op | on a non-modifiable line / op |
|---|---|---|---|---|---|---|
| base, 32 thr | 1770 | **0.58** | 7.9 | **0.080** | (served by the `prefetchw`: 1.08 store/state-change hits) | 0.002 |
| `t1only`, 32 thr | 1777 | **0.57** | 8.2 | **0.080** | 0.937 | 0.081 |
| `pw_enq`, 32 thr | 1588 | 0.01 | 8.6 | 0.002 | 0.047 | 0.001 |
| `t0only`, 32 thr | 1575 | 0.37 | 8.4 | 0.087 | 0.051 | 0.005 |
| **`nostore`**, 32 thr | **3880** | **0.00** | 6.8 | 0.001 | 0.012 | 0.006 |
| base, 64 thr | 1860 | 0.77 | 7.8 | 0.079 | (served by the `prefetchw`: 1.08 store/state-change hits) | 0.003 |
| **`nostore`**, 64 thr | **4728** | 0.27 | 7.1 | 0.000 | 0.031 | 0.008 |
| base, **1 thread**, 512 KB table | 205 | **0.00** | 8.1 | 0.000 | 0.151 | 0.003 |
| base, **1 thread**, 8 GiB table | 149 | **0.00** | 7.8 | 0.000 | 0.023 | 0.004 |
| base, 32 thr, **find** phase | 3879 get | **0.05** | **8.1** | 0.000 | — | — |

Write-combining-buffer commit cancels are 0.000–0.001 per op everywhere.

**H2 is refuted three ways.** The find phase dispatches the same 8.1 stores (and 69
instructions) per op with the store queue full 5% of the time; one thread dispatches the
same ~8 stores per insert with it full 0%; and `nostore`, which removes only the bucket
store, takes it to 0%. The bookkeeping stores are not the problem.

**H1 as first stated is refuted too**: most bucket lines *are* writable when reached —
under `t1only` 0.94 per insert hit a modifiable line in L2, only 0.08 a non-modifiable
one. **What survives is a narrower H1**: about 8% of inserts need an ownership upgrade
(`change_to_x` 0.080), and that fraction tracks the stall across builds — present
wherever the store queue fills (base, `t1only`, `t0only`), ~0 where it does not
(`pw_enq`, `nostore`, one thread). One thread never needs an upgrade at all, in cache or
on DRAM: an upgrade needs another holder of the line.

### 9.3 The holder is another CCX

Same binary, same table (interleaved over all four nodes either way — both placements
take the default branch of `distribute_mem_to_nodes`), same 4 threads; only placement
changes (`ccx_sharing.py`, 2 reps each, agreeing within 0.5%):

| 4 threads | Mops | DRAM GB/s | SQ full | ownership upgrades / insert | cycles / insert / thread |
|---|---|---|---|---|---|
| packed on **one CCX** (`--numa-split 2`, cpus 0–3) | **578** | 78.9 | **0.002** | **0.000** | 23.4 |
| spread over **four CCXs** (`--numa-split 1`, cpus 0/8/16/24) | **369** | 50.0 | **0.46** | **0.065** | 36.2 |

Spreading gives each thread its own L3 and its own fabric link — if anything it should
help. Instead it costs 36%, all of it arriving with the upgrades and the store-queue
stall. Four threads sharing one L3 never need an upgrade, because the L3 serves them all
and no other cache holds the lines. The packed run's 23.4 cycles/insert is the same as a
single thread alone on DRAM (§4).

The extra ~12.8 cycles per insert over 6.5% of inserts is ~200 cycles (~60 ns) per
upgrade — a plausible coherence round trip at this light load. The same arithmetic on the
32-thread base run (0.58 × 56.5 cycles over 8% of inserts) gives ~400 cycles, and at 64
threads ~1000, in step with the loaded latency rising (§5).

### 9.4 The mechanism, and how it fits everything earlier

Keys are disjoint per thread, but lines are not: a 64 B bucket holds four slots, and at
fill 10 a third of lines also hold another thread's key (more at fill 70). When one CCX
has recently upserted a line and still caches it, another CCX's read-intent prefetch
(`prefetcht1`) gets the line without write permission. The line is in L1 by the time
the bucket store commits — so the load hits — but the store needs an ownership upgrade
(`change_to_x`) through the IO die, and because stores commit in order, all ~6–8
inserts' worth of stores behind it wait too. Once the 64 entries are used, dispatch stops.

- **`prefetchw` at enqueue** requests ownership 64 inserts early, so the upgrade happens
  off the critical path (0.002 upgrades/insert, queue full 1–11%) — and the limit moves to
  the L1 miss buffers instead (§6).
- **The dequeue-time `prefetchw`** does not fix it (base and `t1only` both 0.080
  upgrades/insert; distance 16/32 no better). Whether that `prefetchw` fails to upgrade a
  non-writable line or does so too late is not resolved here.
- **`prefetcht0` at enqueue** is read intent, so it keeps the upgrades (0.087) and a
  partial stall.
- **Coherence share vs cost.** Only 2.4–3.3% of lines are *fetched* from another CCX's
  cache (`coherence.py`, measured on `pw_enq`, where fills come straight from the origin),
  and that fetch latency is hidden by the prefetch — which is why an earlier look at those
  numbers dismissed coherence. The cost is not the fetch; it is the upgrade, taken at store
  commit, on the in-order critical path.
- **Why the microbenchmark reaches ~290.** Every `bandwidth_rand` thread writes only its
  own buffer, so no line is ever held by two CCXs and no store ever needs an upgrade.

### 9.5 What follows

- **The ceiling gap is a coherence cost, not a memory one.** dramblast's insert path
  pays for sharing lines between CCXs even though no two threads insert the same key.
- **Levers**, none tried here beyond `pw_enq`:
  - get ownership early without flooding the L1 miss buffers (a write-intent prefetch far
    ahead, but fewer outstanding at once);
  - fewer lines shared across CCXs (e.g. partitioning keys by CCX so each line has one
    owner);
  - skip redundant stores. `nostore` shows the scale: 2.2× the inserts at 32 threads and
    read-bound (352 GB/s) at 64. But it only works because this benchmark's upserts rewrite
    the identical value; a real update, or kmer counting's increment, cannot skip the store.
- **Not yet shown:** the ~8% upgrade rate against a model of sharing and residence time,
  and whether the dequeue `prefetchw` drops or delays the upgrade.

## Reproduce

Scripts and result files are in [`dramblast_insert_amd/`](dramblast_insert_amd/). Each
takes an output directory for its logs; run from that directory.

| script | produces |
|---|---|
| `mlp.py <out>` | §5 table rows: DRAM rd/wr, L1 misses in flight, IPC, L3 latency, demand / sw-prefetch fills, for microbench 32/64 and dramblast fill 10/70 × 32/64 → `results/mlp_results.json` |
| `topdown.py <out>` | §5 top-down rows (two 5-event passes per case) → `results/topdown.json` |
| `stalls.py <out>` | §5 store-queue / load-queue / ROB-full fractions |
| `qsweep.py <out>` | §6 queue-depth table |
| `build_variants.sh` | builds `build_pw/`, `build_t1only/`, `build_none/` (from the repo's own `CAS_PREFETCH_INSERTION` options) and `build_d16/`, `build_d32/`, `build_t0only/` (patched source copies) beside the scripts; leaves `/opt/DRAMHiT/build` alone |
| `variants.py <out>` | §6 prefetch-scheme table → `results/variants.json` (needs `build_variants.sh` first) |
| `coherence.py <out>` | §9.4 fill sources (local L2 / own CCX / other CCX / DRAM) for base and `pw_enq` → `results/coherence.json` |
| `sq_hypotheses.py <out>` | §9.2 table: store-queue stall, stores/op, ownership upgrades and L2 hit states for base, `t1only`, `pw_enq`, `t0only`, `nostore`, one thread, and the find phase → `results/sq_hypotheses.json` |
| `ccx_sharing.py <out>` | §9.3: 4 threads packed on one CCX vs spread over four → `results/ccx_sharing.json` |
| `variants2.py <out>` | §6 single-prefetch table (base, `PREFETCHT1_ONLY`, `PREFETCHW`, t0-only, none) → `results/variants2.json` |
| `pfdrop.py <out>` | §6 prefetch-fate table |
| `t32.py <out>` | §6 threads comparison (uses `collect_data_amd.py`'s command builder and parser) → `results/t32_vs_t64_fill70.json` |

The single-thread in-cache / on-DRAM numbers of §4 are two plain dramhit runs with
`--num-threads 1` and `--ht-size 32768 --insert-factor 100000` or
`--ht-size 536870912 --insert-factor 2`; cycles/insert = 3250 / set_mops.
