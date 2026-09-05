# Join benchmarks — Intel Xeon Gold 6548Y+ (2 sockets, 2.5 GHz)

Two BIOS snoop modes are collected, in separate trees:

| tree | BIOS mode | sets |
|---|---|---|
| `directory/` | directory | relation_size + skew, both numa configs |
| `snoop/` | snoop | skew only, both numa configs |

Findings 1-4 below are from `directory/`, which is the complete collection.
The snoop-mode section says which of them reproduce.

64 cores / 128 threads, 2 NUMA nodes, ~128 GB DDR each, 2 MB L2 per core
(1 MB per hyperthread). Collected with `run_join.py` via `run_all.sh`.

| set | numa-split | threads | hashtable placement |
|---|---|---|---|
| `single_*` | 4 (`THREADS_LOCAL_NUMA_NODE`) | 64, all node 0 | `MPOL_BIND` node 0 |
| `dual_*`   | 1 (`THREADS_SPLIT_SEPARATE_NODES`) | 128, 64 per node | `MPOL_INTERLEAVE` both nodes |

`relation_size` sweeps r = s over 256 MB … 8 GB. `skew` sweeps the zipf
exponent 0.1 … 1.2 at r = 1 GB, s = 15 GB. All 20 runs exited 0; every
hash-join run reports `joined : N out of N, 100.00%`.

## Findings

**1. Radix wins on size, hash joins win on skew.** The two sweeps point in
opposite directions, and the effect is much larger than the spread between
hashtables. Radix is flat-to-rising in relation size but falls monotonically
with skew (single: 2919 → 1487 mops); every hashtable does the reverse
(cas23 single: 2772 → 4291). Skewed probes concentrate on hot keys that stay
cached for a hash join, but for radix they pile into a few oversized
partitions that no longer fit L2 and stall the one thread that owns each.
Crossover is around skew 0.5 on single socket and 0.8 on dual.

**2. Radix's 8 GB cliff is the partition phase, not the join.** Single-socket
radix drops 2068 → 1129 mops from 4 GB to 8 GB. The per-phase counters put it
entirely in partitioning:

| tuples | partitions | partition cyc/tuple | join cyc/tuple |
|---|---|---|---|
| 268435456 | 8192 | 44 | 37 |
| 536870912 | 16384 | **105** | 36 |

`get_optimal_radix` picks radix 14 at 8 GB, and 2^14 × 64 B of software write
buffers is exactly the 1 MB L2 budget per hyperthread — the point where the
function already prints its "input size is too big" warning. The join phase is
unaffected (36 vs 37). Capping radix, or sizing it against 2 MB per core when
not both hyperthreads are active, is the obvious thing to try next.

**3. Doubling sockets does not come close to doubling hash-join throughput.**
At 2× the threads, `dual/single` on `relation_size` is:

| join | speedup |
|---|---|
| radix | 1.43 → 1.86 (grows with size) |
| cas23 | ~1.38 |
| cas | ~1.18 |
| dlht | ~1.10 |
| folklore | ~1.05 |

The global table is interleaved, so roughly half of every probe crosses UPI
and eats most of the added cores. Radix scales best and improves with size
because its partitions are thread-local and first-touched on the running
thread's own node, so almost nothing crosses the interconnect. Note this
makes radix the *only* join whose dual-socket advantage grows with the
relation — worth keeping in mind for the scalability story.

**4. cas is fastest on one socket; cas23 overtakes it on two.**
Single socket, cas leads everywhere: 1927–1756 mops on `relation_size`
(~1.15× cas23, ~2.1× folklore) and ahead of cas23 at 9 of 12 skew points.
On dual socket they tie on `relation_size` (~2130 vs ~2120) and cas23 leads
the whole skew sweep (6249 vs 5543 at 1.2). That is finding 3 restated:
cas23 scales 1.38× across sockets against cas's 1.18×, so the ordering flips
purely on NUMA scaling, not on single-socket speed. Order is otherwise
stable: cas/cas23 > dlht > folklore, with folklore ~2× below cas throughout.
dlht is flat across relation size (993–1035 mops single) but pays for its
`capacity>>3` link table in memory: 54 GB reserved vs 34 GB for the others.

Single-socket cas matches `../collect_radix/intel_single_*.json` (same
ht-type 3) to within 1–2% on `relation_size` and 4% on skew, so these
numbers reproduce the earlier collection.

The dual-socket flip is **not** explained by cross-socket coherence. Two
candidate mechanisms were tested and both eliminated: forcing the insert
prefetch to `prefetchw` (`CAS_PREFETCHW=ON`, so the line arrives exclusive
and the CAS needs no S→E upgrade) moved nothing, and switching the BIOS to
snoop mode lifted both tables by nearly the same factor (1.13x vs 1.16x)
leaving cas23 ahead at 11/12 skew points in both modes.

It also disagrees with the uniform microbenchmark (`compare_uniform.py`,
mode 11, same 8 GB table). At fill 50 on dual socket cas leads cas23 on
*both* operations — set 1.07x, get 1.18x — where the join at the same fill
has cas losing the build phase. The join build inserts each key once into a
cold table in a single pass; the uniform test re-inserts the same keys 100x
(`--insert-factor 100`) into a warm one. That difference is the open lead.

## Snoop mode vs directory mode (skew sweep)

Ratio of snoop-mode to directory-mode throughput, summed over the sweep:

| | cas | cas23 | dlht | folklore | radix |
|---|---|---|---|---|---|
| single | 1.03 | 1.05 | 0.96 | 0.99 | 0.99 |
| dual | 1.13 | 1.16 | 1.05 | **1.24** | **0.99** |

Snoop mode helps only where memory crosses sockets, and only the hash
joins. Single socket is flat within noise. Dual gains 5–24% for every hash
table but leaves radix at 0.99x — which is finding 3's mechanism confirmed
from the other direction: radix's partitions are thread-local and
first-touched on the running thread's own node, so it barely touches the
interconnect and a snoop-filter change has nothing to improve. folklore
gains most (1.24x), consistent with it having the most coherence stall time
to recover.

Everything qualitative survives the BIOS change: hash tables rise with
skew, radix falls monotonically, the crossover stays near skew 0.8–0.9, and
cas23 still leads cas on dual (mean ratio 0.89 in both modes).

## Methodology note: dataset generation contaminates the first run of a set

`init_hashjoin_dist()` writes each generated dataset to `/opt/DRAMHiT/cache/`
with a plain `ofstream` and no `fsync`, then starts the join immediately. For
the skew sweep that is an 8 GB file per point (96 GB over the sweep), and the
kernel flushes those dirty pages *during* the timed region — which costs a
memory-bound benchmark up to ~20%, unevenly.

`run_all.sh` runs cas first in every set, so cas absorbs this for whichever
set has to generate. It hit `single/skew` only (the one set with no cached
datasets), depressing that series by up to 20% at some points while leaving
others untouched. The first collection recorded 2325 mops at skew 0.1 where a
cached re-run gives 2959.

`run_join.py` now detects `Generating hashjoin dataset` in a run's log,
`sync`s, and re-measures that point against the cached file, so the effect
cannot silently reach the data again. **The published numbers are all
cache-warm.** To avoid paying for it at all, generate the datasets once before
a fresh collection.

Residual run-to-run variance is roughly ±5%: repeating single/skew cas at
skew 1.1 three times gave 3743 / 3724 / 3905 mops.

**Every point in both trees is a single measurement**, and dual socket is
the noisier config. Five repeats of dual/relation_size 8gb gave sd ≈ 50 on
~2100 mops (2.4%) in snoop mode, and directory mode was worse — two
identical runs gave cas build 1630 and 1767 (8% apart). For contrast the
uniform microbenchmark, which averages 100 iterations, repeats to ±0.2%.
Read trends across a sweep, not individual points; a single cas-vs-cas23
ratio in the dual series is near the noise floor.

## Layout

```
<snoop-mode>/                          e.g. directory/ , snoop/
  {single,dual}_{relation_size,skew}/
    intel_<config>_<join>_<param>.json throughput_mops + the run's config
    intel_<config>_<param>.png         that set's figure
    logs/<join>/<param>_<value>.log    raw dramhit output (180 files per mode)
  intel_joins_overview.png             all four sets as a 2x2 grid
```

Collect: `./run_all.sh <snoop-mode> [param ...]` — the mode name is
required, so it cannot be forgotten after a BIOS change. Plot: `python3
plot_data.py <snoop-mode>`, or name sets to plot only those. A partly
collected mode plots what it has (`snoop/` has skew only, so its overview
is a 1x2 grid).

Cross-check against a different workload: `python3 compare_uniform.py` runs
the `../macro_uniform` test (mode 11) for cas and cas23 on both numa
configs.
