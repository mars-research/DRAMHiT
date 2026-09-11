# AVX-512 bucket scan vs scalar load: what a probe costs when the line is cached

Microbenchmark isolating the two probe idioms DRAMHiT's `cas` and `cas23`
hashtables use. It exists to answer one question left open by
`../collect_join/cas_vs_cas23_skew_crossover.md`: at high skew, once the
probe working set is cache-resident, `cas23` beats `cas` by ~1.2x on the probe
phase. Is that because an AVX-512 bucket scan is intrinsically slower than a
scalar load when the data is already in cache?

**Short answer: not as stated.** Single-threaded on L1-resident data the two
idioms are within 2% of each other. The penalty is produced by two separate
effects, both measured below:

1. a 512-bit load must wait for the **whole** cacheline, where a scalar load
   needs only the critical word — this scales with memory distance and is
   present with one thread;
2. with SMT active, the double-pumped 512-bit op **contends for the shared
   256-bit datapath** — this is what penalises *cache-resident* data, where
   effect 1 contributes nothing.

## The three idioms

| variant | inner loop | mirrors |
|---|---|---|
| `scalar1` | 8 B load + `cmp` | `cas23`: its hash points at one 16 B slot (`cas23_kht.hpp:340` `__find_branched` -> `kvtypes.hpp:187` `Item::find`) |
| `scalar4` | up to 4x (8 B load + `cmp`) | a 4-way search **without** vectors — separates "vector cost" from "searching 4 slots" |
| `simd4` | `vpbroadcastq` / `vmovdqa64` / `vpcmpequq` / `kortestb` / `kmovb` | `cas`: its hash points at a cacheline-aligned 4-slot bucket (`cas_kht.hpp:567` `find_batch`, `DRAMHiT_2025_INLINED`) |

`simd4` is not an approximation of `cas` — `make check-codegen` shows gcc emits
the identical sequence for both:

```
vpbroadcastq %rax,%zmm0
vmovdqa64    (%rdx),%zmm1
vpcmpequq    %zmm0,%zmm1,%k0{%k1}      # KEYMSK = 0x55, the 4 key lanes
kortestb     %k0,%k0
kmovb        %k0,%eax
```

## Results (AMD EPYC 9354P, NPS4, prefetchers off)

`cyc/probe`, and the ratio of the vector idiom to each scalar one:

### 1 thread
| footprint | scalar1 | scalar4 | simd4 | simd4/scalar1 | simd4/scalar4 |
|---|---|---|---|---|---|
| 16 KB (L1) | 23.95 | 21.46 | 23.46 | **0.98x** | 1.09x |
| 512 KB (L2) | 24.61 | 22.26 | 25.09 | **1.02x** | 1.13x |
| 16 MB (L3) | 26.67 | 26.17 | 32.39 | 1.21x | 1.24x |
| 1 GB (DRAM) | 34.73 | 36.47 | 57.34 | **1.65x** | 1.57x |

### 32 threads — one per physical core, no SMT sharing
| footprint | scalar1 | scalar4 | simd4 | simd4/scalar1 |
|---|---|---|---|---|
| 16 KB (L1) | 25.17 | 24.36 | 26.20 | 1.04x |
| 512 KB (L2) | 24.83 | 24.29 | 28.75 | 1.16x |
| 16 MB (L3) | 27.25 | 27.31 | 36.47 | 1.34x |
| 1 GB (DRAM) | 41.48 | 43.02 | 63.54 | 1.53x |

### 64 threads — 2 per core, as the join actually runs
| footprint | scalar1 | scalar4 | simd4 | simd4/scalar1 |
|---|---|---|---|---|
| 16 KB (L1) | 27.71 | 26.63 | 34.81 | **1.26x** |
| 512 KB (L2) | 29.02 | 30.56 | 37.55 | **1.29x** |
| 16 MB (L3) | 36.36 | 37.80 | 46.18 | 1.27x |
| 1 GB (DRAM) | 62.25 | 64.75 | 85.83 | 1.38x |

Read the L1 row across the three tables: **0.98x -> 1.04x -> 1.26x**. Nothing
about the memory system changed; only the SMT sibling appeared.

`scalar1` and `scalar4` are within noise of each other at every footprint, so
searching 4 slots instead of 1 is essentially free. `simd4/scalar4` is as large
as `simd4/scalar1`, so the cost is the vector ops, not the 4-way associativity.

## perf verification

### Claim 1 — same cachelines fetched, the vector load just waits longer

1 GB footprint, 1 thread (so SMT cannot be involved):

| | scalar1 | simd4 |
|---|---|---|
| `ls_any_fills_from_sys.dram_io_near` | 35,067,734 | 35,058,612 |
| `ls_any_fills_from_sys.dram_io_far` | 17,044,095 | 17,245,239 |
| `ls_any_fills_from_sys.local_ccx` (L3) | 12,619,260 | 12,516,502 |
| `ls_any_fills_from_sys.local_l2` | 7,868,828 | 7,982,122 |
| `de_no_dispatch_per_slot.backend_stalls` | 6,712,131,024 | **8,849,930,564** (+31.8%) |
| `de_no_dispatch_per_slot.smt_contention` | 18,407,215 | 16,467,153 (negligible) |
| cyc/probe | 34.99 | 55.68 |

Fill counts match to within 0.6% in every category — both idioms pull exactly
the same lines from exactly the same places. What differs is that `simd4`
accumulates **31.8% more backend stall slots** for identical memory traffic.
That is the signature of waiting on the same line for longer: `scalar1` is
satisfied by the critical word, `vmovdqa64` needs all 64 bytes. SMT contention
is ~0.2% of stalls here, confirming effect 2 plays no part at 1 thread.

### Claim 2 — on cached data the penalty *is* SMT datapath contention

16 KB footprint (fully L1-resident), dispatch-slot breakdown (Zen 4 dispatches
6 slots/cycle):

| | threads | backend | **smt_contention** | frontend | cyc/probe |
|---|---|---|---|---|---|
| scalar1 | 1 | 2,676,349,681 | 1,783,791 | 139,476,722 | 24.01 |
| simd4 | 1 | 2,792,905,419 | 1,478,881 | 145,754,740 | 26.82 |
| scalar1 | 64 | 118,181,111,039 | 43,071,963,785 | 3,183,010,010 | 27.71 |
| simd4 | 64 | 93,984,159,920 | **96,537,825,794** | 5,737,294,174 | 34.94 |

As a fraction of all dispatch slots at 64 threads:

| | backend | **smt_contention** | frontend |
|---|---|---|---|
| scalar1 | 0.659 | 0.240 | 0.018 |
| simd4 | 0.416 | **0.427** | 0.025 |

At 64 threads on L1-resident data, `simd4`'s SMT contention is **2.24x**
`scalar1`'s and becomes the single largest stall category — larger than its own
backend stalls. At 1 thread the same counter is ~0.05% of slots for both. The
vector penalty on cached data is therefore not latency and not bandwidth: it is
two hyperthreads competing for one 256-bit-wide vector datapath, which a
double-pumped 512-bit op occupies for twice as long.

## Relevance to the cas/cas23 crossover

The join runs 64 threads with a ~116 MB 90%-mass working set at skew 1.0 —
i.e. the L3/DRAM boundary with SMT active, where this benchmark measures a
**1.27-1.38x** vector penalty. The observed `cas`/`cas23` probe ratio there is
49/41 ~ **1.20x**. The idiom accounts for the whole gap.

Suggested code change: a scalar, or 256-bit (`_mm256`, not double-pumped on
Zen 4), variant of `find_batch` in the `DRAMHiT_2025_INLINED` path. It would
keep the deep prefetch queue that wins `cas` the low-skew case while removing
the penalty that loses it the high-skew case.

## Caveats

- `cyc/probe` is `rdtsc` around the probe loop only; `perf stat` spans the
  whole process and so also counts the table and index initialisation (a 1 GB
  memset at the largest footprint). Absolute perf cycle counts are therefore
  higher than `cyc/probe * probes`; the setup cost is identical between
  variants, so comparisons hold but absolute normalisation does not.
- The 6-event groups multiplexed at ~83%; perf scaled the counts. Differences
  of a few percent in the fill table are not meaningful — which is the point,
  since the fills are supposed to be equal.
- `simd4` executes ~1.5x more instructions per probe than `scalar1` here
  (20.3 vs 13.3 at 64 threads/L1). In the real join `cas` executes *fewer*
  instructions than `cas23` overall, because the two hashtables differ in more
  than the bucket scan. This benchmark isolates the idiom, not the tables.
- `rdtsc` is used as a cycle count, which is valid only at fixed frequency;
  `scripts/constant_freq_amd.sh` pins this box to 3.25 GHz.
- Single-thread L1 `simd4/scalar1` came out 0.98x in the sweep and 1.12x in the
  isolated perf run. Either way the effect is absent at 1 thread and clear at
  64; do not read the second decimal.

## Reproducing

```bash
make probe_idiom
make check-nodiv        # no integer division in the inner loop
make check-codegen      # simd4 emits cas's exact sequence

./probe_idiom 1  all all      # isolated idiom cost
./probe_idiom 32 all all      # one thread per core
./probe_idiom 64 all all      # as the join runs

# perf needs one variant + one footprint per process to attribute counters
perf stat -e de_no_dispatch_per_slot.backend_stalls,\
de_no_dispatch_per_slot.smt_contention,\
de_no_dispatch_per_slot.no_ops_from_frontend,cycles,instructions \
  -- ./probe_idiom 64 simd4 l1
```

Two earlier versions of this benchmark were wrong in ways worth recording:
`ITERS` was not a power of two, so `& (ITERS-1)` collapsed the index stream
onto a small cache-resident subset and every footprint reported the same
~7.5 cyc/probe; and `% nbuckets` sat in the inner loop, putting a runtime
integer division on the critical path. `make check-nodiv` guards the second.
