# dlht's lookup on the AMD box, against both Intel machines

Question: dlht's `get` throughput is much worse on `amd-9354p` than on the Intel
machines, and that is not true of every other table. What is wrong on this machine?

**Answer.** Two effects, and they have to be separated because they act on different
tables:

1. **Compute budget.** The AMD box has 32 cores at 3.25 GHz = 104 core-GHz; the 6548Y+
   has 64 at 2.5 = 160. A table that is core-bound on both machines gets 104/160 = 0.65
   of its 6548Y throughput here and nothing is wrong. **folklore is exactly this case**,
   and it is the control that shows the method works.
2. **A real per-core deficit, specific to dlht and dramhit.** At equal core count
   (`intel-max9462-hbm`, also 32 cores) dlht does **0.57-0.66x** the work per core-GHz on
   AMD, and dramhit 0.78-0.85x, while folklore and dramblast are level. That part is not
   a compute-budget effect.

**dlht's share of (2) is a prefetch-shape artifact, not a property of the machine**
(section 7). `DlhtHashTable::find_batch` fires one `prefetcht0` per key for the whole
batch as a burst and then drains with nothing in flight, so batch length *is* its
prefetch depth -- 32 per thread, 64 per SMT core. Zen4 discards a software prefetch that
cannot allocate a Miss Address Buffer entry, and the counters show **39% of dlht's
prefetches are dropped at batch 32** (17% at 16, 56% at 64) and come back as exposed
demand misses. Two consequences:

- dlht is already 13.6% faster on this machine at `--batch-len 16` (2327 vs 2048
  get_mops), and is correct at every batch length from 4 to 256 -- the earlier claim that
  "it needs 32" is wrong.
- Giving `find_batch` a sliding prefetch window instead of a burst -- dramhit's shape --
  is **+44%** (2912 get_mops, past dramhit's 2749). That puts dlht at 0.80 of its HBM per
  core-GHz, the same ratio dramhit has, and the dlht-specific anomaly disappears.

dramhit's share of (2) is unexplained and is a smaller effect.

Data: [`amd/amd-9354p_uniform.json`](amd/amd-9354p_uniform.json),
[`intel/intel-6548y_uniform.json`](intel/intel-6548y_uniform.json),
[`intel_hbm/intel-max9462-hbm_uniform.json`](intel_hbm/intel-max9462-hbm_uniform.json).

## 0. Match the prefetcher first, or the comparison is wrong

The AMD collection runs all four tables with the hardware prefetcher **off**. In
`intel-6548y_uniform.json`, `cas` and `cas23` are off but **`folklore` and `dlht` are
prefetcher-ON**; their off-variants live under the separate keys `folklore_nopref` and
`dlht_nopref`. Comparing the default keys across machines compares different
configurations, and on this workload that is not a small difference:

| 6548Y, fill 10 | prefetcher ON | prefetcher OFF |
|---|---|---|
| folklore get_mops | 1800 | **2661** (+48%) |
| folklore lookup bw | 336 GB/s | **200 GB/s** |
| dlht get_mops | 3478 | **4793** (+38%) |

The prefetcher is spending ~136 GB/s of folklore's bandwidth on lines it never uses —
a random-access lookup has nothing for it to predict — and costs 33% of the throughput.
**Everything below uses the prefetcher-off series on all three machines.** An earlier
draft of this document did not, which is what made folklore look bandwidth-saturated on
the 6548Y when it is not, and sent the whole analysis off course.

## 1. The three machines

| | AMD EPYC 9354P | Intel Xeon CPU Max 9462 | Intel Xeon Gold 6548Y+ |
|---|---|---|---|
| sockets / **cores** / threads | 1 / **32** / 64 | 1 / **32** / 64 | 2 / **64** / 128 |
| clock | 3.25 GHz | 2.7 GHz | 2.5 GHz |
| **core-GHz** | **104** | **86.4** | **160** |
| memory under test | DDR5 | HBM | DDR5 |
| measured read ceiling | 353 GB/s | 406 GB/s | ~350 GB/s |

The Max 9462 matching AMD's core count is what makes the per-core question answerable.

## 2. Who is bandwidth-bound and who is core-bound

Lookup, fill 10, prefetcher off everywhere:

| table | get_mops (AMD / HBM / 6548Y) | Mops per core-GHz | lookup bw, % of that machine's ceiling |
|---|---|---|---|
| dramblast | 4738 / 3866 / 5052 | 45.6 / 44.7 / 31.6 | **100%** / 59% / **105%** |
| dramhit | 2753 / 2937 / 4614 | 26.5 / 34.0 / 28.8 | 58% / 46% / **101%** |
| folklore | 1768 / 1586 / 2661 | 17.0 / 18.4 / 16.6 | 37% / 25% / 57% |
| dlht | 2057 / 3018 / 4793 | 19.8 / 34.9 / 30.0 | 43% / 48% / **102%** |

- **dramblast** is saturated on both DDR5 machines. It does not care how many cores it
  has, which is why it is the one table whose aggregate barely moves between AMD and the
  6548Y (0.94) despite the 2x core difference.
- **dramhit and dlht** are saturated on the 6548Y only. Their 6548Y per-core entries are
  therefore floors, not capabilities.
- **folklore is core-bound on all three machines** (25-57% of ceiling). It is the only
  table where all three numbers mean the same thing.

## 3. folklore: the compute-budget case, and the control

Because folklore is core-bound everywhere, its per core-GHz figures are directly
comparable — and all three machines agree to within 10%:

| | AMD | HBM | 6548Y |
|---|---|---|---|
| folklore, Mops per core-GHz | 17.0 | 18.4 | 16.6 |

Stable across fill: AMD/6548Y is 1.02, 1.03, 1.02, 1.01 at fills 10-40, and AMD/HBM is
0.93 throughout.

So an AMD core does folklore about as well as either Intel core per clock, and folklore's
aggregate ratio is nothing but the compute budget:

> predicted AMD / 6548Y = 104 / 160 = **0.65**, measured 1768 / 2661 = **0.66**

That is the answer to "how do you explain folklore": once the prefetcher is matched,
folklore is a clean core-bound table, it is equally efficient per core on all three
machines, and it scales with core-GHz exactly as it should. Nothing about folklore is
anomalous — the anomaly in the earlier draft was an artifact of comparing its
prefetcher-on run against AMD's prefetcher-off run.

## 4. dlht and dramhit: a genuine per-core deficit

Per core-GHz ratios, across the fill range each pair shares:

| table | AMD / HBM (32c vs 32c, both core-bound) | AMD / 6548Y (6548Y capped, so a floor) |
|---|---|---|
| dramblast | 1.02 0.99 0.98 1.01 | 1.44 1.50 1.51 1.57 |
| folklore | 0.93 0.93 0.93 0.94 | 1.02 1.03 1.02 1.01 |
| dramhit | 0.78 0.81 0.83 0.85 | 0.92 0.94 0.95 0.94 |
| **dlht** | **0.57 0.59 0.62 0.66** | 0.66 0.64 0.68 0.71 |

dlht is the outlier by a wide margin: an AMD core does 0.57-0.66x the dlht work per clock
that a Max 9462 core does, and the 6548Y column says the same (<=0.71, and that is
against a capped Intel number, so the true gap is larger). dramhit shows a smaller
version of the same thing. folklore and dramblast show none of it.

So the original observation was right. dlht is genuinely slower on this machine per core,
on top of the machine having fewer cores.

## 5. What the dlht deficit is not

- **Not bandwidth.** dlht uses 152 GB/s of AMD's 353 GB/s ceiling — less than half.
- **Not memory latency.** The natural guess is that the Max 9462 wins on memory, but its
  HBM is *slower* in latency than DDR5 — 137.7 ns vs 111.3 ns, measured in
  [`../intel_hbm/machine_spec_analysis.md`](../intel_hbm/machine_spec_analysis.md), which
  notes latency-bound workloads gain nothing from it. dlht is 1.5x faster per core on the
  machine with the worse latency.
- **Not the front end.** Frontend stall is 1.8-3.3% on every table on AMD.

On AMD both weak tables are memory-stall dominated (IPC 0.58 for dlht, 0.41 for folklore,
against 1.26 for dramblast), but folklore stalls harder *and* is level with Intel, so low
IPC does not separate the two cases.

## 6. It is memory-level parallelism, measured

Zen4 exposes the counter this needs. `ls_alloc_mab_count` sums in-flight L1 data-cache
misses (Miss Address Buffer occupancy) every cycle, so dividing by cycles gives the
average number of misses a core keeps outstanding. Profiling the **find phase only**
(cut to the program's `test find start/end` markers; `--insert-factor 1 --read-factor 50`
so find dominates regardless), fill 10, 64 threads, prefetcher off:

| metric | dramhit | dlht | dlht/dramhit |
|---|---|---|---|
| get_mops | 2732 | 2043 | **0.75** |
| **MLP: avg in-flight L1 misses** | **6.80** | **4.68** | **0.69** |
| IPC | 1.03 | 0.59 | 0.57 |
| cycles stalled on load data | 77.8% | 85.7% | 1.10 |
| any no-retire | 86.2% | 91.3% | 1.06 |
| loads / 1k cycles | 280 | 176 | 0.63 |
| L2 misses / 1k cycles | 15.8 | 11.3 | 0.71 |
| demand DRAM fills / 1k cycles (local + remote) | 3.74 | 4.40 | 1.18 |

(Six events exceeded the free counters, so these ran at 82-83% enabled — perf scales for
it, and the ratios are what matter here, not the absolute values.)

**The MLP ratio (0.69) and the throughput ratio (0.75) agree.** That is what Little's law
predicts: throughput = concurrency / latency, and the two tables face the same memory
latency on the same machine, so throughput should track how many misses each keeps in
flight. It does. dlht's deficit against dramhit on AMD is a concurrency deficit.

Two things rule out its doing more work per lookup:

- **Same DRAM bytes per lookup.** From the controller counters, dlht moves 73.9 B per
  lookup and dramhit 74.8 B — about 1.15 lines each. L2 misses per lookup are also
  equal (~1.15-1.2 for both, once the per-1k-cycle figures above are divided by each
  table's ops per cycle).
- **But dlht's prefetch covers less of it.** Demand DRAM fills — the misses software
  prefetch failed to cover — are 0.45 per lookup for dlht against 0.28 for dramhit,
  1.6x as many exposed misses for identical total traffic.

So both tables fetch the same amount of memory per lookup; dlht just has more of it
arriving as an exposed stall and sustains fewer concurrent misses while it waits.

### Why this lands on dlht and on this machine

dlht runs a 32-deep batch against dramhit's 16. On this core that 32-deep batch turns
into only 4.68 misses actually outstanding -- the depth the algorithm asks for is not the
depth the core delivers. Section 7 finds out why: on Zen4 a batch that deep is past the
point where the core will even accept the prefetches.

That is also why the spare bandwidth on AMD does dlht no good. It uses 152 of 353 GB/s,
but bandwidth is only reachable through outstanding requests, and it is short of those,
not of bandwidth.

> **Aside, a real bug found while sweeping batch length:** cas23/dramhit at
> `--batch-len 32` or `64` reports 1,073,741,820 find_ops and **16,380 found** — it
> returns almost nothing while still reporting a throughput number (a spurious 2.6x
> "speedup"). Its supported setting is 16, which is what every collection uses, so no
> published data is affected; but the failure is silent rather than an error. dlht is
> correct at every batch length tested (found == find_ops at 16, 32 and 64).


## 7. The concurrency deficit is dlht's prefetch *shape*, and it is fixable

Section 6 stopped at "dlht sustains fewer concurrent misses". This section finds the
mechanism in the code, measures it, and removes it.

### 7.1 The two tables issue their prefetches in different shapes

`dlht_kht.hpp::find_batch` is two passes over the batch:

```c++
// Pass 1: Prefetch memory locations
for (uint64_t i = 0; i < kp.size(); i++)
  __builtin_prefetch(&primary_table[kp[i].key & mask], 0, 3);

// Pass 2: Execute Gets
for (uint64_t i = 0; i < kp.size(); i++) { ... }
```

Pass 1 fires the whole batch as one burst -- gcc unrolls it 8x, so 32 `prefetcht0`s
leave in ~40 cycles -- and then pass 2 drains the batch with **no further prefetch
issued at all**. Batch length *is* dlht's prefetch depth, and the window collapses to
zero for the rest of the batch.

`cas23_kht.hpp::find_batch` never does that. It keeps a persistent 64-entry ring
(`PREFETCH_FIND_QUEUE_SIZE`) across calls and only ever drains down to
`FLUSH_THRESHOLD = 32`:

```c++
this->flush_if_needed(values, collector);              // drain to 32
for (auto &data : kp) add_to_find_queue(&data, ...);   // prefetch + enqueue
this->flush_if_needed(values, collector);              // drain to 32
```

so a prefetch is issued for every result consumed and the window *slides* instead of
bursting. dramhit's `--batch-len 16` is not its prefetch depth; its queue is.
folklore has no prefetch at all, which is why it is a clean latency-bound control.

### 7.2 Zen4 drops the tail of the burst, and the counters say so

Find phase only, fill 10, 64 threads, prefetcher off (82-83% enabled):

| metric | dlht b8 | dlht b16 | dlht b32 | dlht b64 | dramhit b16 |
|---|---|---|---|---|---|
| get_mops | 2206 | 2297 | 2024 | 1844 | 2737 |
| `ls_pref_instr_disp.all` /1k cyc | 12.4 | 12.8 | 11.6 | 10.4 | 15.8 |
| `ls_sw_pf_dc_fills.all` /1k cyc | 11.9 | 10.1 | 6.8 | 4.4 | 11.5 |
| **fills / dispatched** | **0.96** | **0.79** | **0.58** | **0.42** | 0.73 |
| **dropped** (disp - inef - fills) | **~0%** | **17%** | **39%** | **56%** | 23% |
| `ls_dmnd_fills_from_sys.all` /1k cyc | 0.44 | 2.90 | 4.97 | 6.51 | 5.53 |
| MAB occupancy (MLP) | 5.20 | 5.50 | 4.82 | 4.30 | 6.83 |

A software prefetch that cannot allocate a Miss Address Buffer entry on Zen4 is
**discarded**, not queued and not retried. At 8 per thread essentially every prefetch
lands (96%) and almost nothing is left exposed (0.44 demand fills per 1k cycles). At the
published 32 per thread, **39% of dlht's prefetches are thrown away** and come back as
exposed demand misses -- 4.97 per 1k cycles, 11x the batch-8 figure. Deeper is worse,
not better: at 64 more than half are dropped.

The knee is between 8 and 16 prefetches per thread. The run is 64 threads on 32 SMT
cores and the MAB is shared by both siblings, so that is 16-32 in flight per *core*,
which is where a ~24-entry Zen4 MAB would be expected to fill up. dlht asks for 64 per
core. dramhit, whose sliding queue issues one prefetch per result consumed, asks for far
fewer at any instant and keeps a higher MAB occupancy (6.83) out of *fewer* requests in
flight per thread -- which is the whole point.

This is the AMD-specific part. Nothing in the code changed between machines; what
changed is that a 32-deep burst fits the Max 9462's per-core fill machinery and does not
fit this one. It is also why dlht gets no benefit from the spare DRAM bandwidth: a
dropped prefetch is a request the memory system never saw.

### 7.3 Batch length alone: dlht is run 14% below its own optimum

`sweep_dlht_batch_amd.py`, fill 10, median of 3, everything but `--batch-len` identical
to `collect_data_amd.py` ([`amd/dlht_batch_sweep.json`](amd/dlht_batch_sweep.json)):

| batch | 4 | 8 | 12 | **16** | 20 | 24 | **32** | 48 | 64 | 128 | 256 |
|---|---|---|---|---|---|---|---|---|---|---|---|
| get_mops | 1540 | 2237 | 2306 | **2327** | 2247 | 2207 | **2048** | 1930 | 1897 | 1809 | 1770 |
| set_mops | 1210 | 1468 | 1544 | **1564** | 1519 | 1490 | **1410** | 1371 | 1344 | 1313 | 1293 |

(run-to-run spread under 1%; dramhit at batch 16 is 2749.)

This is not just a sweep result. The batch-16 configuration is now collected as a full
series next to the published one, 5 reps per point with bandwidth sampling, prefetcher
off, under the key **`dlht_batch16`** in
[`amd/amd-9354p_uniform.json`](amd/amd-9354p_uniform.json) -- added alongside `dlht`
rather than replacing it, the same way `intel-6548y_uniform.json` carries
`dlht_nopref` next to `dlht`:

| fill | get b32 | get b16 | delta | set b32 | set b16 | delta | lookup GB/s |
|---|---|---|---|---|---|---|---|
| 10 | 2057 | 2324 | **+13.0%** | 1428 | 1564 | +9.5% | 152 -> 171 |
| 20 | 1881 | 2149 | **+14.2%** | 1363 | 1497 | +9.8% | 142 -> 162 |
| 30 | 1722 | 1970 | **+14.4%** | 1288 | 1417 | +10.0% | 134 -> 152 |
| 40 | 1569 | 1795 | **+14.4%** | 1211 | 1329 | +9.7% | 125 -> 142 |

Every rep passed the collector's `found == find_ops` check (`failures: []` for all four
fills), so this is +13 to +14% on lookup and ~+10% on insert, and the gain is stable
across the whole fill range rather than an artefact of the fill-10 point. Lookup
bandwidth rises with it -- 152 -> 171 GB/s at fill 10 -- which is the signature the
drop-rate table predicts: the prefetches that used to be discarded are now reaching DRAM
instead of arriving later as exposed demand misses.

The fill range is unchanged at 10-40. dlht still aborts with "Resize required: Global
link bucket pool exhausted" at fill 50, verified at batch 16 -- it is an insert-capacity
limit (the link pool is `capacity/8`), independent of batch length.

Two corrections to this document's earlier claims:

- **"dlht needs 32; 16 is not an option for it" is wrong.** dlht returns
  `found == find_ops == 5,368,709,100` at *every* batch length from 4 to 256. 16 is not
  just an option, it is dlht's best: **2327 vs 2048, 13.6% faster on get and 11% on
  set**. The published dlht column is measured past its own knee while the other three
  tables are measured at 16.
- The curve is single-peaked at 16 and monotone in both directions, exactly the shape
  the drop-rate table predicts.

### 7.4 Removing the burst: +44%, and the anomaly disappears

Replacing pass 1's burst with a sliding window of depth D -- prefetch D ahead, then
issue one prefetch per key consumed, which is dramhit's shape -- and leaving everything
else in `find_batch` untouched. Published insert/read factors, fill 10, correctness
checked on every run:

| batch / window | get_mops | vs published dlht | found == find_ops |
|---|---|---|---|
| 32 / 32 (= today's code) | 2024 | -- | yes |
| 32 / 12 | 2599 | **+28%** | yes |
| 64 / 12 | 2706 | +34% | yes |
| 128 / 12 | 2840 | +40% | yes |
| 256 / 10 | 2875 | +42% | yes |
| **256 / 12** | **2912** | **+44%** | yes |

Larger batches keep helping once the window is decoupled from the batch, because the
only thing batch length still controls is how big a fraction of the batch is the
un-prefetched tail drain.

At 2912 Mops dlht is **ahead of dramhit on this machine** (2749), which is the
relationship it has on the Max 9462 (34.9 vs 34.0 Mops per core-GHz) and did not have
here. In per core-GHz terms:

| | published (b32 burst) | tuned batch (b16 burst) | sliding window (b256/w12) |
|---|---|---|---|
| dlht, Mops per core-GHz | 19.8 | 22.4 | **28.0** |
| AMD / HBM | 0.57 | 0.64 | **0.80** |

0.80 against dramhit's 0.78. **The dlht-specific per-core deficit in section 4 is
entirely a prefetch-shape artifact.** What is left is the same generic AMD/HBM ratio
every other batched table on this machine has, and that part is not specific to dlht.

### 7.5 Two code notes found on the way

- **dlht's seqlock does not exist in the binary.** `find_batch` reads
  `Bin_hdr header_value = *header_ptr`, scans, re-reads the header and retries if
  `version` changed. In the disassembly of
  `DlhtHashTable<Item, ItemQueue>::find_batch` there is exactly one load of the header
  (`mov (%r8),%edi`, the 32-bit `states` at offset 0), the `version` field at offset 4
  is never loaded, and the `do { } while (retry)` loop is gone. `header_ptr` is a plain
  non-`atomic`, non-`volatile` pointer, so the compiler is entitled to assume nothing
  else writes it and folds the version check to false. It does not affect the read-only
  measurements here -- and it makes dlht's find *cheaper*, not dearer, so it is not
  behind any of the above -- but the concurrency control this table is supposed to
  implement is not being compiled.
- `find_batch` dereferences `get_slot()` without the null check that `insert_batch` has
  on the same call (`if (slot && slot->key == ...)` there, `if (slot->key == ...)`
  here). Unreachable at these fills, since `get_slot` only returns null for an
  unallocated link bucket and a state bit says the slot is `VALID`, but the two paths
  should not disagree.

### 7.6 What to do

1. The cheapest honest fix for the paper's numbers is `"batch_len": 16` for dlht in
   `collect_data_amd.py`, which is correct, is +13.6%, and puts dlht on the same batch
   length as the other three tables.
2. The real fix is to give `DlhtHashTable::find_batch` the sliding window (and, to drop
   the tail drain entirely, a persistent queue like cas23's -- note that would also need
   a real `flush_find_queue`, which dlht currently stubs out to `return 0`, and the
   `vp.first < config.batch_len` cap cas23 uses, because `uniform_test.cpp` sizes its
   results array at `batch_len`).
3. Both machines should then be re-collected, since the window depth that is right here
   is not necessarily the one that is right on the Max 9462.
