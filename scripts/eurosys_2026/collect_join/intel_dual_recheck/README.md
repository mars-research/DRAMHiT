# cas vs cas23, dual socket, re-run against the best-known cas build

Intel Xeon Gold 6548Y+, 2 sockets, 64c/128t, 2 numa nodes of ~128 GiB,
2 MiB L2 per core (1 MiB per hyperthread). 2.5 GHz locked, prefetchers off,
BIOS in **directory** mode (established below, not assumed).

Collected with `run_join.py intel-6548y.json`; compare with
`python3 compare_cas_cas23.py intel_dual_recheck`.

Only the `dual` configuration is here: `--numa-split 1 --num-threads 128`,
threads 64/64 across the sockets, the one global hashtable MPOL_INTERLEAVE'd
over both nodes. That is the same configuration as `directory/dual_*`.

## What changed since `directory/`

The cas build. `directory/` predates commit f65f6ac, which replaced the
`CAS_PREFETCHW` on/off switch with `CAS_PREFETCH_INSERTION`; this tree is the
first dual-socket collection with

```
-DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON -DBRANCH=simd
-DPREFETCH=DOUBLE -DCAS_PREFETCH_INSERTION=DOUBLE
-DUNIFORM_PROBING=ON -DGROWT=ON -DCPUFREQ_MHZ=2500
```

`CAS_PREFETCH_INSERTION=DOUBLE` gives the insert path a `prefetcht1` when the
entry is queued and a `prefetchw` when it is dequeued, so the line arrives
exclusive and the CAS pays no S->E upgrade. Under `directory/`'s flags the
same path issued two *read-only* prefetches. `PREFETCH=DOUBLE` drives the find
path as before. Nothing else in either table's inner loop changed:
`cas23_kht.hpp` is untouched since `directory/` was collected, and the
`hashjoin_test.cpp` edits since then are radix/HBM-only or gated behind an
unset `HASHJOIN_TARGET_DENSITY`.

The `constexpr` queue-geometry change proposed in
`cas_vs_cas23_skew_crossover.md` section 13a is **not** in this build and is
not planned -- it was judged too machine-specific. `find_queue_sz` and the
queue masks remain runtime members.

## Control: cas23 reproduces its own old numbers

cas23's code and flags are unchanged, so it doubles as a rig check. Its dual
skew sweep against the two old BIOS trees:

| | geomean of new/old |
|---|---|
| vs `directory/` | **1.007** |
| vs `snoop/`     | 0.862 |

So the box is in directory mode, and cas23 reproduces that tree to within
0.7%. Any movement in cas is therefore the build flags, not machine drift.

## Results

`relation_size` at 10 reps/point, `skew` at cas 10 / cas23 3 (the skew set was
cut short for turnaround; see Caveats). Ratios are cas/cas23, above 1 = cas
faster. All 304 runs report `joined : N out of N, 100.00%`.

### relation_size (r = s, ht-fill 50) -- cas wins outright

| size | cas | cas23 | ratio | t | build cyc/op | probe cyc/op |
|---|---|---|---|---|---|---|
| 256 MB | 2354 | 2225 | 1.058 | +5.4 | 160 vs 161 | 111 vs 126 |
| 512 MB | 2254 | 2158 | 1.045 | +5.4 | 168 vs 172 | 114 vs 124 |
| 1 GB | 2224 | 2122 | 1.048 | +11.3 | 172 vs 174 | 114 vs 126 |
| 2 GB | 2188 | 2086 | 1.049 | +7.3 | 176 vs 178 | 115 vs 127 |
| 4 GB | 2160 | 2086 | 1.035 | +7.4 | 178 vs 178 | 117 vs 127 |
| 8 GB | 2144 | 2076 | 1.033 | +6.2 | 180 vs 178 | 116 vs 129 |

**geomean 1.045, 6 of 6 points decided for cas.** `directory/` had these two
tied here (~2130 vs ~2120), so this is a flip.

### skew (r = 1 GB, s = 15 GB, ht-fill 7) -- cas23 still ahead, but barely

| skew | cas | cas23 | ratio | t | build cyc/op | probe cyc/op |
|---|---|---|---|---|---|---|
| 0.1 | 3448 | 3557 | 0.969 | -4.5 | 174 vs 161 | 87 vs 85 |
| 0.2 | 3480 | 3534 | 0.985 | -1.9 | 172 vs 163 | 86 vs 85 |
| 0.3 | 3505 | 3608 | 0.971 | -2.6 | 174 vs 164 | 85 vs 83 |
| 0.4 | 3574 | 3685 | 0.970 | -10.1 | 174 vs 163 | 84 vs 81 |
| 0.5 | 3692 | 3710 | 0.995 | -1.5 | 176 vs 162 | 80 vs 81 |
| 0.6 | 3890 | 4097 | 0.950 | -1.7 | 174 vs 161 | 76 vs 72 |
| 0.7 | 4146 | 4403 | 0.942 | -4.1 | 176 vs 164 | 70 vs 66 |
| 0.8 | 4592 | 4807 | 0.955 | -1.4 | 174 vs 162 | 62 vs 59 |
| 0.9 | 5178 | 5309 | 0.975 | -0.4 | 174 vs 163 | 54 vs 53 |
| 1.0 | 5551 | 5759 | 0.964 | -1.8 | 174 vs 163 | 50 vs 48 |
| 1.1 | 5871 | 5692 | 1.031 | +1.0 | 174 vs 161 | 46 vs 49 |
| 1.2 | 5812 | 6027 | 0.964 | -2.4 | 174 vs 162 | 46 vs 45 |

**geomean 0.972, 5 points decided for cas23, 7 indistinguishable, 0 for cas.**

## Findings

**1. The insert-path change is worth 5-13% to cas, and it did not come out of
cas23.** Against its own `directory/` numbers cas is up at every one of the 18
points: skew +0.8% to +14.4% (median +6.8%), relation_size +0.5% to +8.1%.
With the cas23 control flat at 1.007, that gain is the flags.

**2. It flipped `relation_size` and did not flip `skew`.** The old finding 4
("cas23 overtakes cas on two sockets") is now half wrong: cas leads
`relation_size` 6/6. On `skew` cas23 still leads, but the margin fell from
**0.89 geomean in `directory/` to 0.972 here** -- an ~11% deficit cut to
~2.8%, with 7 of 12 points no longer separable at all.

**3. The two sweeps disagree because of fill, and that is the open lead.**
The phase counters put cas's remaining skew deficit entirely in build, and the
number is oddly rigid: **cas 172-176 cyc/op against cas23 161-164, at every
skew from 0.1 to 1.2**, a flat ~12 cyc/op gap that does not care about the
access distribution at all. Probe over the same sweep is near-tied (cas 0 to
-4 cyc/op). On `relation_size` the picture inverts: build is a dead heat
(cas ahead at the three smallest sizes) and cas wins on probe by a steady
10-13 cyc/op.

The configurations differ in table fill. `skew` runs ht-fill 7 -- 67 M keys in
a 2^30-slot table, 6.25% occupied -- while `relation_size` runs ht-fill 50.
So on this machine cas's probe advantage appears at high fill and vanishes at
low fill, and cas's build disadvantage appears at low fill and vanishes at
high fill. Neither effect is explained here. A fill sweep at fixed r and s
would separate fill from skew, which no set in this tree does.

## Caveats

- **cas23's skew set is 3 reps, cas's is 10.** The Welch t handles unequal n
  but loses power, so the 7 ties in the skew table are partly a reps artifact:
  read the sweep's shape, not the individual points. `--reps 10` on
  `dual_cas23 --param skew` would firm it up (~30 min, datasets are cached).
- Every point is cache-warm. `run_join.py` discards any run that generated its
  dataset and re-measures. All 18 datasets (~112 GB) are cached under
  `/opt/DRAMHiT/cache` and nothing cleans them up.
- The two tables were collected in sequence, not interleaved, so slow machine
  drift would land on cas23. The cas23-vs-`directory/` control bounds that at
  under a percent.
- cas is the noisier table, as on AMD: its skew 1.2 samples span 4463-5993
  while cas23's span 5904-6194.

## Reproduce

```bash
./scripts/setup.sh                       # msr-safe, 2.5 GHz, hugepages, prefetch off
cd scripts/eurosys_2026/collect_join
nix --extra-experimental-features 'nix-command flakes' develop --command \
  python3 -u run_join.py intel-6548y.json          # ~95 min from a cold cache
python3 compare_cas_cas23.py intel_dual_recheck
python3 plot_data.py intel_dual_recheck
```

`run_join.py` shells out to `cmake`, `wrmsr` and `rdmsr`, so it must run
inside the nix dev shell or it fails at the first build / prefetcher step.
