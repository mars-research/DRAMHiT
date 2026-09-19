# Intel iMC reverse-channel: verification and single-controller thread sweep

Machine: 2x INTEL(R) XEON(R) GOLD 6548Y+ (Emerald Rapids, family 6 model 207),
32 cores / 64 threads per socket, 8 memory controllers per socket, DDR5 with
two sub-channels per controller. Node 0 is the **even** cpus.

All measurements below were taken with the **hardware prefetchers disabled**
(`sudo env PATH="$PATH" ../../prefetch_control.sh off`, MSR `0x1a4 = 0xf` on
every cpu, read back to confirm). The software prefetch inside the probe's
access loop is part of the benchmark and stays on -- it is what keeps the
controller supplied.

## What is being verified

`reversed_intel.c` claims physical address bits select one of 8 controllers:

```
c0 = a9 ^ a15 ^ a23
c1 = a8 ^ a14 ^ a22
c2 = a8 ^ a11 ^ a17 ^ a25
imc = (c2 << 2) | (c1 << 1) | c0
```

It only ever uses this to pick the lines where `imc == 0`. The hash reads the
1 GiB hugepage's *offset* rather than a physical address, which is sound here
but only by construction: a 1 GiB hugepage is 1 GiB-aligned (this run got
`0x3c0000000`), and every bit the hash touches is below bit 30, so offset and
physical address agree on all of them.

## Why checking channel 0 alone is not enough

Showing that the predicted-channel-0 lines all land on one controller does not
identify the hash. Any function that permutes the output bits -- swap `c0` and
`c1`, say -- selects a *different* set of lines that is still confined to a
single controller, and still passes. `verify_hash.py` therefore sweeps the
predicted channel k = 0..7 and requires the 8 predicted classes to land on 8
**distinct** controllers.

## Method

`imc_probe.c` generalises `reversed_intel.c` in three ways:

1. the target channel is an argument rather than hardcoded 0;
2. threads are pinned to an explicit cpu list. The original does `CPU_SET(i)`,
   and since node 0 is the even cpus, its "16 threads" straddles both sockets
   and sends half the traffic over UPI;
3. `CLOCK_MONOTONIC` marks bracket the access loop, so a `perf stat -I` series
   can be cut to the steady-state window. This matters: the probe memsets and
   flushes the whole 1 GiB page first, and that init traffic is spread over all
   8 controllers, so a whole-run `perf stat` shows traffic everywhere no matter
   how good the hash is.

Counters are read with `perf stat -C 0` (the iMC PMU cpumask is `0-1`, one cpu
per socket, so `-C 0` scopes them to socket 0).

## Verification result: PASS

`python3 verify_hash.py 8 1000` (8 cores, ~3.5 s of steady state per channel):

```
predicted iMC 0 -> uncore_imc_0   98.35% of socket-0 read CAS
predicted iMC 1 -> uncore_imc_1   98.43%
predicted iMC 2 -> uncore_imc_2   98.43%
predicted iMC 3 -> uncore_imc_3   98.43%
predicted iMC 4 -> uncore_imc_4   98.37%
predicted iMC 5 -> uncore_imc_5   98.43%
predicted iMC 6 -> uncore_imc_6   98.42%
predicted iMC 7 -> uncore_imc_7   98.42%
```

| check | result |
| --- | --- |
| predicted -> measured | identity, bijective over all 8 |
| lines per class | 2097152, exactly 1/8 of the page's 16777216 |
| DRAM writes (reads are clflushopt'd clean, so should be ~0) | 0.16% of reads |
| perf CAS bytes vs the program's own bandwidth | agree within 2.24% |

The last two are what rule out the boring failure modes: write traffic would
mean the loop is not doing what it claims, and a disagreement between perf and
the program would mean the window is misaligned.

### The residual 1.6% is not noise

Grouping the off-target traffic by `predicted XOR measured` separates it
cleanly from the background (an idle socket reads ~16 MiB/3 s/channel):

| xor | share of target traffic | |
| --- | --- | --- |
| 2 | 1.245% | real |
| 1 | 0.169% | real |
| 5 | 0.103% | real |
| 3, 4, 6, 7 | 0.020 - 0.029% | at the idle noise floor |

A misrouted line shows up at `xor = 2` when bit `c1` is wrong, so the error is
concentrated almost entirely in `c1 = a8 ^ a14 ^ a22`: a small population of
lines needs a term that bit does not model. At 98.4% concentration this does
not threaten the single-controller experiment, but the hash is not exact and
`c1` is where to look.

## Thread sweep against one controller

`sweep_imc.py` then drives 1..16 cores -- socket 0, distinct physical cores,
no smt sharing (even cpus 0..30) -- over iMC 0 only, 3 repeats per point.
`plot_imc_sweep.py` draws `imc_thread_sweep.png` from `imc_thread_sweep.csv`.

| cores | bw GB/s | RPQ occ | inserts M/s | RPQ latency (iMC clk) |
| --- | --- | --- | --- | --- |
| 1 | 6.50 | 3.48 | 103.1 | 43.9 |
| 2 | 12.49 | 7.27 | 198.4 | 47.6 |
| 3 | 18.57 | 12.31 | 297.1 | 53.8 |
| 4 | 24.20 | 17.67 | 384.7 | 59.6 |
| 5 | 28.90 | 25.93 | 460.8 | 73.0 |
| 6 | 32.01 | 37.13 | 506.9 | 95.1 |
| 7 | 32.74 | 46.29 | 515.3 | 116.6 |
| 8 | 32.66 | 48.35 | 512.1 | 122.5 |
| 12 | 32.92 | 52.60 | 516.6 | 132.1 |
| 16 | 33.01 | 52.67 | 517.2 | 132.2 |

One controller saturates at **33.0 GB/s**, which is 79% of the 41.6 GB/s a
DDR5-5200 channel can carry (`dmidecode`: 16 single-rank DDR5 DIMMs configured
at 5200 MT/s, one per channel).

The knee is at 6 cores and the three panels agree on where it comes from.
Bandwidth and insertion rate both flatten there -- 517 M inserts/s x 64 B =
33.1 GB/s, so every RPQ insertion is one read CAS and the two panels are the
same measurement reached two ways. Occupancy does *not* flatten with them: it
keeps climbing to ~52 entries, and queueing delay triples from 44 to 132 iMC
clocks. Past 6 cores the extra cores add only queue depth, not throughput.

### The two sub-channels are not symmetric

At 16 cores the DDR5 sub-channel pair takes identical load but holds different
amounts of it:

```
inserts    pch0 = 764.5M   pch1 = 764.4M   ratio 1.0001
occupancy  pch0 =  91.09G  pch1 = 110.98G  ratio 0.8208
latency    pch0 =  119.2   pch1 =  145.2   iMC clocks
```

Arrivals are balanced to 0.01%, so this is a service-latency asymmetry (pch1 is
22% slower), not a routing imbalance -- worth knowing before reading a
single-sub-channel counter as representative of the channel.

## Reproducing

```sh
sudo env PATH="$PATH" ../../prefetch_control.sh off   # MSR 0x1a4 = 0xf
make imc_probe
python3 verify_hash.py 8 1000     # 8-way bijection check, exits nonzero on fail
python3 sweep_imc.py              # -> imc_thread_sweep.csv  (~11 min)
python3 plot_imc_sweep.py         # -> imc_thread_sweep.png
sudo env PATH="$PATH" ../../prefetch_control.sh on    # restore prefetchers
```
