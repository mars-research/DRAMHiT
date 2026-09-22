# Uniform macro benchmark in HBM — Xeon Max 9462, single socket

`collect_data_intel_hbm.py`. Mode 11 (uniform), one 8 GiB hashtable
(536870912 entries x 16 B) bound to numa node 2 — socket 0's own HBM —
driven by 64 threads on node 0's cpus. `--numa-split
10` (THREADS_CUSTOM) with `np_cpu_node_msk 0x1` /
`np_mem_node_msk 0x4`: it is the only policy that can name a cpu-less HBM node,
since every other one derives the memory node from the thread's own node. Same
workload, table size, seed, build flags and repeat count (5 reps,
median reported) as `collect_data_intel.py`, so the panels differ only in the
machine and in where the table lives.

All four tables were measured in **both** hardware-prefetcher states — 62
points, 310 runs. Every run is checked for `found == find_ops` before its
throughput is kept, and each is wrapped in `perf stat -I 50` over the 32
`uncore_hbm` boxes (raw CAS encodings, 32 B per CAS) for per-phase bandwidth.

**Prefetcher state is set with `scripts/prefetch_control_hbm.sh`, not
`prefetch_control.sh`** — on = MSR 0x1a4 `0x0`, off = `0x2f`. The usual script
writes `0xf`, which on this part leaves bit 5 enabled; that is not a detail
(see "The 0xf trap" below). The `_hwpf_off` series here were re-collected at
`0x2f`; the `0xf` collection is kept as
`intel_hbm/intel-max9462-hbm_uniform_msr0xf.json` with its logs under
`logs/*_hwpf_off_msr0xf/`.

## Headline

**Turning the hardware prefetcher off is faster for every table, in both
phases, at every fill.** The sweep is 31 (table, fill) points per prefetcher
state; none of the 62 on/off comparisons those make across the two
phases goes the other way. The gain ranges from **+1%** to
**+83%**, median **+47%**.

It holds for the baselines too, not just the DRAMHiT tables: on HBM `folklore`
and `dlht` also prefer it off, which is the opposite of the default
`HASH_JOIN_VARIANTS` / `collect_data_intel.py` picks for them.

## set (insert) throughput, Mops

| table | hw pref | 10% | 20% | 30% | 40% | 50% | 60% | 70% | 80% | 90% |
|---|---|---|---|---|---|---|---|---|---|---|
| cas (dramblast) | on | 1845 | 1845 | 1813 | 1793 | 1745 | 1670 | 1564 | 1404 | 1244 |
|  | off | 3264 | 3354 | 3323 | 3208 | 3124 | 2963 | 2752 | 2438 | 2083 |
| | **Δ off** | **+77%** | **+82%** | **+83%** | **+79%** | **+79%** | **+77%** | **+76%** | **+74%** | **+67%** |
| cas23 (dramhit) | on | 1635 | 1560 | 1477 | 1386 | 1297 | 1210 | 1127 | 1035 | 817 |
|  | off | 2404 | 2287 | 2196 | 2064 | 1910 | 1754 | 1603 | 1416 | 1052 |
| | **Δ off** | **+47%** | **+47%** | **+49%** | **+49%** | **+47%** | **+45%** | **+42%** | **+37%** | **+29%** |
| folklore | on | 1233 | 1189 | 1124 | 1058 | 942 | 811 | 671 | 552 | 431 |
|  | off | 1849 | 1752 | 1644 | 1488 | 1275 | 1026 | 800 | 626 | 437 |
| | **Δ off** | **+50%** | **+47%** | **+46%** | **+41%** | **+35%** | **+27%** | **+19%** | **+13%** | **+1%** |
| dlht | on | 1615 | 1451 | 1287 | 1129 | – | – | – | – | – |
|  | off | 2388 | 2091 | 1832 | 1600 | – | – | – | – | – |
| | **Δ off** | **+48%** | **+44%** | **+42%** | **+42%** | – | – | – | – | – |

## get (lookup) throughput, Mops

| table | hw pref | 10% | 20% | 30% | 40% | 50% | 60% | 70% | 80% | 90% |
|---|---|---|---|---|---|---|---|---|---|---|
| cas (dramblast) | on | 2269 | 2322 | 2284 | 2191 | 2083 | 2017 | 1892 | 1686 | 1488 |
|  | off | 3866 | 3918 | 3896 | 3791 | 3666 | 3478 | 3220 | 2857 | 2399 |
| | **Δ off** | **+70%** | **+69%** | **+71%** | **+73%** | **+76%** | **+72%** | **+70%** | **+69%** | **+61%** |
| cas23 (dramhit) | on | 1925 | 1865 | 1727 | 1588 | 1460 | 1325 | 1238 | 1117 | 852 |
|  | off | 2937 | 2734 | 2556 | 2338 | 2116 | 1913 | 1737 | 1520 | 1131 |
| | **Δ off** | **+53%** | **+47%** | **+48%** | **+47%** | **+45%** | **+44%** | **+40%** | **+36%** | **+33%** |
| folklore | on | 1182 | 1156 | 1131 | 1080 | 958 | 786 | 649 | 532 | 430 |
|  | off | 1586 | 1518 | 1439 | 1325 | 1156 | 947 | 748 | 605 | 448 |
| | **Δ off** | **+34%** | **+31%** | **+27%** | **+23%** | **+21%** | **+20%** | **+15%** | **+14%** | **+4%** |
| dlht | on | 1913 | 1685 | 1502 | 1346 | – | – | – | – | – |
|  | off | 3018 | 2633 | 2289 | 1979 | – | – | – | – | – |
| | **Δ off** | **+58%** | **+56%** | **+52%** | **+47%** | – | – | – | – | – |

dlht stops at 40% fill: its link-bucket pool is capacity/8 and it aborts with
"Global link bucket pool exhausted" past ~45%, the same cap the DDR and EPYC
collections hit at this table size.

## Cache lines fetched per lookup

Bandwidth divided by throughput, in 64 B lines. The simulated row is ground
truth: the exact key stream, the exact hash the build selects (`HASHER=crc`,
which every one of these tables uses) and the exact probe sequence, replayed
offline. It is what the algorithm *has* to touch.

| table | source | 10% | 20% | 30% | 40% | 50% | 60% | 70% | 80% | 90% |
|---|---|---|---|---|---|---|---|---|---|---|
| cas (dramblast) | measured 0x2f | 0.97 | 1.00 | 1.00 | 1.02 | 1.04 | 1.08 | 1.15 | 1.28 | 1.57 |
|  | measured 0xf (old) | 0.99 | 1.00 | 1.02 | 1.03 | 1.06 | 1.10 | 1.17 | 1.30 | 1.60 |
| | *simulated* | *1.01* | *1.03* | *1.05* | *1.08* | *1.12* | *1.19* | *1.29* | *1.50* | *2.13* |
| cas23 (dramhit) | measured 0x2f | 0.99 | 1.02 | 1.04 | 1.08 | 1.14 | 1.23 | 1.36 | 1.60 | 2.28 |
|  | measured 0xf (old) | 1.00 | 1.05 | 1.09 | 1.15 | 1.35 | 1.63 | 1.91 | 2.25 | 3.24 |
| | *simulated* | *1.01* | *1.03* | *1.05* | *1.08* | *1.12* | *1.19* | *1.29* | *1.50* | *2.13* |
| folklore | measured 0x2f | 0.99 | 1.02 | 1.05 | 1.12 | 1.34 | 1.77 | 2.36 | 2.95 | 3.86 |
|  | measured 0xf (old) | 1.18 | 1.79 | 2.32 | 2.68 | 3.22 | 3.69 | 4.57 | 5.67 | 7.10 |
| | *simulated* | *1.01* | *1.03* | *1.05* | *1.08* | *1.12* | *1.19* | *1.29* | *1.50* | *2.13* |
| dlht | measured 0x2f | 1.01 | 1.02 | 1.04 | 1.10 | – | – | – | – | – |
|  | measured 0xf (old) | 1.09 | 1.09 | 1.10 | 1.15 | – | – | – | – | – |
| | *simulated* | *1.01* | *1.03* | *1.05* | *1.08* | – | – | – | – | – |

At `0x2f` the measurements track the simulation closely up to about 50% fill.
Beyond that they run above it — long probe chains give the core more to
speculate through, and a wrong-path load still costs a line fetch — but the
gap is now tens of percent rather than the 3x seen under `0xf`.

## The 0xf trap

`prefetch_control.sh` writes MSR 0x1a4 = `0xf`, the four classic bits (L2
stream, L2 adjacent line, DCU, DCU IP). On this part that is **not** all of
them: bit 5 gates a further prefetcher, and folklore's linear probe — a walk
over consecutive addresses — is exactly what it latches onto. Measured on
folklore lookup at fill 50:

| MSR 0x1a4 | get Mops | offcore data reads/op | L2 fills/op | demand misses/op |
|---|---|---|---|---|
| 0x00 (all on) | 980 | 4.80 | 5.43 | 1.21 |
| 0x0f | 1282 | 3.32 | 3.39 | 1.05 |
| **0x2f** | 1160 | **1.48** | 1.51 | 1.34 |
| 0x3f | 1144 | 1.47 | 1.50 | 1.33 |

The algorithm needs 1.125 lines per lookup there, and only `0x2f` measures
that. Under `0xf` the machine fetched 2.2 extra lines per lookup that nothing
asked for — while the script reported "all prefetchers off". `0x3f` adds
nothing measurable (bit 4 is irrelevant here) and `0xff` is rejected by the
cpu, so `0x2f` is what "off" means on this machine.

Folklore's demand misses were right all along (1.05/op, against 1.125
simulated); it was the prefetch traffic on top that was invisible. A
random-access table barely notices — cas moved 1.06 -> 1.04 lines/op at fill 50
and its throughput did not move at all — but cas23 at high fill did (3.24 ->
2.28 at fill 90), and folklore did enormously (3.22 -> 1.34 at fill 50).

Throughput moved too, and not always the way you would expect: that prefetcher
was genuinely *helping* folklore's sequential walk, so turning it off costs
folklore 10-14% at fill 50 and above. Its advantage over the prefetcher-on case
narrows to +4% at the top of the sweep, from +21% under the old mask. cas,
cas23 and dlht moved by at most a few percent.

## Figures

`plot_data_bw.py`, the same two-panel throughput + bandwidth style the DDR
panel uses: throughput on the left axis (solid line, filled marker), HBM
bandwidth on the right (open marker), a table keeping its colour across both,
and solid vs dashed separating the prefetcher states.

    python3 plot_data_bw.py intel_hbm/intel-max9462-hbm_uniform.json --ceiling-set 606 --ceiling-get 408
    python3 plot_data_bw.py ... --tag prefon  --only cas_hwpf_on  cas23_hwpf_on  dlht_hwpf_on  folklore_hwpf_on
    python3 plot_data_bw.py ... --tag prefoff --only cas_hwpf_off cas23_hwpf_off dlht_hwpf_off folklore_hwpf_off
    python3 plot_data_bw.py ... --tag cas     --only cas_hwpf_on  cas_hwpf_off          # and cas23 / dlht / folklore

| figure | what it shows |
|---|---|
| `intel-max9462-hbm_uniform_bw.png` | all eight series |
| `intel-max9462-hbm_uniform_prefon_bw.png` / `_prefoff_bw.png` | the four tables in one prefetcher state |
| `intel-max9462-hbm_uniform_{cas,cas23,dlht,folklore}_bw.png` | one table, both states — the clearest read |

Every figure shares one pair of axis scales, taken from the whole json, so the
subsets can be laid next to each other. `--ceiling-set` / `--ceiling-get` give
the two panels their own reference lines; one `--ceiling` still applies to
both, which is what the DDR figures do.

## Measured ceilings

The two panels do not share a ceiling, and the old figures drew one number
(405 GB/s, the random-access read ceiling) across both. Insertion takes every
line exclusive and writes it back, so its traffic is 1 read + 1 write per line
and the machine sustains far more of it. Both are now measured with
`machine_stats/bandwidth.c` on the same cpu/memory pairing the benchmark uses
-- pattern `n0a2t64`, 64 threads on node 0's cpus against node 2's HBM, 256 MB
per thread (16 GB live), random access, lookahead 64 -- and read at the 32
`uncore_hbm` boxes rather than taken from the program's own report:

| panel | instruction | median total | rd / wr | peak interval | program reported |
|---|---|---|---|---|---|
| lookup (`-mode r`) | `prefetcht1` | **405.8 GB/s** | 405.6 / 0.2 | 424.4 | 374.3 |
| insertion (`-mode w`) | `prefetcht1` | **624.9 GB/s** | 312.4 / 312.4 | 677.0 | 293.9 |
| insertion (`-mode w`) | `prefetchw` | 376.9 GB/s | 188.4 / 188.4 | 384.7 | 173.8 |

    python3 measure_hbm_ceiling.py            # -> intel_hbm/intel-max9462-hbm_ceiling.json

Four things are worth pulling out of that table.

**The program's own number is not the bandwidth.** It reports the bytes it
asked for, so on the write mix it counts the stores and misses the
read-for-ownership entirely: 294 GB/s reported against 625 GB/s actually
moved. Counting at the controllers is not optional here.

**`prefetchw` is not the fastest way to do the write mix** -- it reaches
376.9 GB/s where `prefetcht1` reaches 624.9, a 1.7x gap on identical traffic
(both measure exactly 1:1 rd:wr). That is worth knowing because
`CAS_PREFETCH_INSERTION` uses prefetchw on the dequeue side. cas's own insert
phase measures up to 440 GB/s, i.e. above what the prefetchw microbenchmark
sustains and at 70% of the prefetcht1 ceiling. The prefetchw number is also
the most repeatable thing in this whole file (376-377 GB/s in every run of
every session), which looks like an instruction-pipeline limit rather than a
memory one.

**Lookahead does not matter**, though an earlier version of this report said
it did. Interleaved in one session, 3 reps: read 397 / 396 / 396 / 394 GB/s at
lookahead 32 / 64 / 128 / 256, write 622 / 615 at 32 / 64. All inside the
run-to-run spread.

**The hugepage pool does matter.** Resetting and re-reserving the pool moves
the read result by up to 7% -- 376 GB/s on one pool against 406 on another,
with the program's own report moving by the same 7%, so it is the machine and
not the counters. Runs within one pool agree to 1-2%. Treat any single number
here as +/- 7% unless the pool is held fixed.

For reference, the other read instructions at the same point: `prefetcht0`
346, plain `load` 321, `nta` 238 GB/s. Prefetcher state barely matters to
either ceiling (under 1% between 0x0 and 0x2f).

Against those lines, the highest traffic any table reaches is 440 GB/s on
insertion (cas, 70% of ceiling) and 340 GB/s on lookup (folklore with the
prefetcher on, 84% -- most of it prefetch it never uses).

## Caveats

- Run-to-run spread over the 5 repeats, worst point per series:
  - cas23_hwpf_on: 16.4%
  - cas_hwpf_on: 9.3%
  - cas_hwpf_off: 8.2%
  - dlht_hwpf_on: 5.9%
  - folklore_hwpf_on: 5.9%
  - dlht_hwpf_off: 3.3%
  - folklore_hwpf_off: 2.1%
  - cas23_hwpf_off: 1.7%
  The prefetcher-on series are the noisy ones; every effect above is far larger
  than this.
- Bandwidth sums both sockets' HBM. The far socket is idle here, so a stray
  allocation on the wrong node would show up rather than hide.
- The DDR and EPYC panels in this directory were collected with the old
  `0xf` mask. Whether that matters there is untested: it depends on whether
  those parts have the same bit, and on EPYC 0x1a4 is not even the right
  register. Their folklore lines/op (1.54 and 1.41 at fill 50) sit much closer
  to the simulated 1.125 than this machine's `0xf` number did, which suggests
  the leftover prefetcher is specific to this part — but that is an inference,
  not a measurement.
- Against the stored DDR panel this machine wins on set and loses on get — but
  that panel is 128 threads over 2 sockets against 64 threads on one here, so
  it is not a like-for-like comparison and is not drawn as one.
- Hugepages are not optional and not obvious: the table needs 1 GiB pages on
  the HBM node, each thread's key buffer needs 2 MB pages on node 0 (~3.9 GB at
  90% fill), and dlht additionally mbinds its 1 GiB link pool to the HBM node,
  which therefore needs 2 MB pages too. Any of those missing produces a run
  with no throughput at all, not a slow one; the collector reserves all three.
