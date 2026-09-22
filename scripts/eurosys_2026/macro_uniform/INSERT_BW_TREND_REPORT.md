# Why insertion bandwidth falls with fill on the HBM box

The uniform panels show something that looks alarming: with the hardware
prefetcher off, **every** table's insertion bandwidth falls as the table fills,
on this machine only. cas goes 430 -> 343 GB/s between 10% and 90% fill, and
the other three do the same. The DDR panel is flat, and this machine's own
lookup curve is flat. This is what is behind that.

Short version: **nothing is degrading.** Writes are structurally one cache line
per operation, so write bandwidth tracks throughput and nothing else;
throughput falls with fill because probe chains lengthen; and this machine has
enough spare memory bandwidth that nothing expands to take the space the writes
vacate. The DDR box is flat for the opposite reason -- it is saturated, so
reads expand into exactly the room the writes give up.

## 1. The write side is one line per operation, everywhere

Insert-phase write traffic divided by insert throughput, in 64 B lines per op:

| table / machine | 10% | 20% | 30% | 40% | 50% | 60% | 70% | 80% | 90% |
|---|---|---|---|---|---|---|---|---|---|
| cas, hbm | 1.03 | 1.02 | 1.01 | 1.01 | 1.01 | 1.01 | 1.01 | 1.02 | 1.03 |
| cas23, hbm | 1.00 | 0.99 | 0.99 | 1.00 | 1.00 | 1.00 | 1.00 | 1.00 | 1.03 |
| folklore, hbm | 0.99 | 1.00 | 1.01 | 1.01 | 1.02 | 1.03 | 1.03 | 1.03 | 1.06 |
| cas, ddr | 0.97 | 0.99 | 0.99 | 1.00 | 1.00 | 1.00 | 1.01 | 1.02 | 1.06 |
| folklore, ddr | 0.97 | 0.99 | 1.00 | 1.00 | 1.01 | 1.03 | 1.04 | 1.04 | 1.06 |

0.97 to 1.06 lines, across four tables, three machines and nine fills. That is
the structure of the workload, not a property of any table: an insert (or, on
passes 2..100, an update) dirties exactly one line, and a dirty line is written
back exactly once. So **insert write bandwidth = throughput x 64 B**, and any
change in it is a change in throughput.

## 2. The read side grows per op, and its rate is flat

cas on HBM, insert phase, cache lines per op and line rate:

| cas, hbm insert | 10% | 20% | 30% | 40% | 50% | 60% | 70% | 80% | 90% |
|---|---|---|---|---|---|---|---|---|---|
| reads/op | 1.03 | 1.03 | 1.01 | 1.03 | 1.05 | 1.09 | 1.15 | 1.28 | 1.55 |
| writes/op | 1.03 | 1.02 | 1.01 | 1.01 | 1.01 | 1.01 | 1.01 | 1.02 | 1.03 |
| **read Glines/s** | 3.36 | 3.44 | 3.36 | 3.29 | 3.27 | 3.23 | 3.17 | 3.13 | 3.22 |
| **write Glines/s** | 3.36 | 3.44 | 3.34 | 3.23 | 3.14 | 2.99 | 2.79 | 2.49 | 2.14 |
| throughput Mops | 3264 | 3354 | 3323 | 3208 | 3124 | 2963 | 2752 | 2438 | 2083 |

Reads per op rise 1.03 -> 1.55 (longer probe chains), the read line rate stays
put around 3.2-3.4 G lines/s, so throughput has to fall. Writes stay at 1 per
op, so the write line rate falls with throughput -- from 3.36 down to 2.14.
Total = flat reads + falling writes = the falling curve on the figure.

## 3. Why DDR looks different: it is saturated and this machine is not

Total insert line rate, cas, across the three machines:

| machine | 10% | 20% | 30% | 40% | 50% | 60% | 70% | 80% | 90% |
|---|---|---|---|---|---|---|---|---|---|
| hbm | 6.73 | 6.88 | 6.70 | 6.52 | 6.42 | 6.22 | 5.96 | 5.62 | 5.36 |
| ddr | 5.54 | 5.54 | 5.54 | 5.54 | 5.54 | 5.55 | 5.55 | 5.56 | 5.57 |
| amd | 3.90 | 3.86 | 3.89 | 3.87 | 3.87 | 3.83 | 3.76 | 3.67 | 3.53 |

The DDR box holds 5.54-5.57 G lines/s across all nine fills -- 0.6% spread,
which is not a workload behaving consistently, it is a hard ceiling. Its read
line rate *rises* (2.94 -> 3.45) by exactly as much as its write rate falls
(2.60 -> 2.12): the memory system is full, and reads expand into the room the
writes give up. Bandwidth is pinned, and throughput absorbs the whole cost of
the longer chains.

This machine is nowhere near that. Insert peaks at 440 GB/s against a measured
mixed-traffic ceiling of 625 GB/s (see the ceilings section of
INTEL_HBM_UNIFORM_REPORT.md) -- about 70%. With spare bandwidth, the reads have
no reason to expand, so the write traffic simply leaves and the total drops.
The spread across fills is 22% here, 9% on AMD, 0.6% on DDR, which orders the
three exactly by how close each is to its own ceiling.

## 4. Why lookup on the same machine is flat

The lookup phase has no write component. Its read line rate is flat on its own
(3.74 -> 3.77 G lines/s for cas), so the bandwidth is flat too -- reads per op
rise and throughput falls by the same factor. Insert differs only in carrying a
write that is tied to the op rate.

## 5. What the core counters say

cas, prefetcher off (MSR 0x1a4 = 0x2f), windowed separately to each phase:

| metric | insert 10% | insert 50% | insert 90% | lookup 10% | lookup 90% |
|---|---|---|---|---|---|
| IPC | 0.84 | 0.88 | 0.75 | 0.88 | 0.72 |
| fb_full, % of cycles | 23.1% | 21.8% | 17.0% | 23.1% | 20.2% |
| L2 lines in /op | 1.099 | 1.181 | 1.660 | 1.129 | 1.697 |
| demand data reads /op | 0.005 | 0.004 | 0.006 | 0.003 | 0.005 |
| resource_stalls.sb, % cycles | 0.5% | 0.3% | 0.2% | 3.8% | 1.9% |
| RFO misses /op | 0.010 | 0.006 | 0.010 | 0.010 | 0.010 |

Three things to read off it:

- **The two phases look the same per operation.** L2 fills per op track the
  lines/op derived from the controllers, and they are within 3% of each other
  between insert and lookup at the same fill. Nothing about the insert path is
  getting worse in a way the lookup path avoids.
- **Demand reads are ~0.005/op**: essentially all traffic is software prefetch,
  as expected for cas. This is also why the L1 MLP counters
  (l1d_pend_miss.pending) are not meaningful here -- prefetcht1 lands in L2, so
  the lines are not outstanding L1D misses.
- **Fill buffers are the pressure point, not the store buffer.** fb_full sits
  at 17-23% of cycles in both phases while resource_stalls.sb is under 4%. The
  line rate is limited by how many line fills a core can have in flight, which
  is why it sits at half the memory's capability and why it does not rise when
  the writes go away.

## 6. So what

The falling insertion bandwidth is a *consequence* of falling throughput, not a
cause of it, and not a sign of the memory system degrading. On a saturated
machine bandwidth is the right thing to watch, because it is the binding
constraint; on this one it is not binding, and throughput (or lines per op) is
what carries the information. Reading the HBM insert curve as "the memory
system gets worse as the table fills" would be exactly backwards -- the memory
system is idling at 70% while the cores run out of fill buffers.

Two practical notes. The gap between 440 GB/s achieved and 625 GB/s available
is the headroom a deeper insert pipeline could claim. And the same measurement
on the DDR box would tell you nothing, because at 101% of its read ceiling that
machine cannot show you this effect at all.

## Caveats

- The DDR and AMD numbers come from their stored json; those machines are not
  this one and could not be re-measured here. Their ceilings are inferred from
  the flatness of their own line rates, not measured -- the DDR figure of "101%
  of ceiling" compares its insert bandwidth against the 350 GB/s read ceiling
  its own collector uses as a default, which is a read-only number standing in
  for a mixed one.
- `l2_lines_out.non_silent` is not a DRAM-writeback proxy (it counts non-silent
  evictions, clean ones included) and is left out of the table above; the write
  traffic here is the controllers' own count.
- Counters are system-wide (`perf stat -a`) over a machine running 64 threads
  on 128 cpus, so cycle-percentage rows are ratios within the same counter set
  and not per-thread occupancies.
