# Join benchmarks — Intel Xeon Gold 6548Y+ (2 sockets, 2.5 GHz)

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

**4. Hashtable ranking is stable and independent of both axes.**
cas ≈ cas23 > dlht > folklore on `relation_size`; cas23 pulls ahead of cas
under skew and on dual socket. folklore is consistently the slowest, ~2×
below cas. dlht is flat across relation size (993–1035 mops single) but pays
for its `capacity>>3` link table in memory: 54 GB reserved vs 34 GB for the
others.

## Caveat

`single/skew` for **cas** is visibly noisier than the other three tables
(2406 at 0.5 and 2733 at 0.8 against a rising trend, where cas23/dlht/folklore
are smooth). Treat the individual cas dips as run-to-run variance, not
structure — a repeat run would be worth it before publishing that series.

## Layout

```
single_relation_size/  single_skew/  dual_relation_size/  dual_skew/
  intel_<config>_<join>_<param>.json   throughput_mops + the run's config
  intel_<config>_<param>.png           that set's figure
  logs/<join>/<param>_<value>.log      raw dramhit output (180 files total)
intel_joins_overview.png               all four sets as a 2x2 grid
```

Regenerate figures with `python3 plot_data.py` (all sets + overview) or
`python3 plot_data.py single_skew` for one.
