# Xeon CPU Max 9462: how much HBM bandwidth can this machine actually use?

Everything below was measured on the machine (`perf` uncore counters, Intel MLC,
and `machine_stats/bandwidth.c`) rather than taken from a spec sheet, except
where marked *nominal*. Collected 2026-09-11, directory snoop mode, turbo off,
all cores pinned at 2.7 GHz.

## 0. Summary

- The HBM is **HBM2e**: 4 Samsung stacks x 16 GB per socket at 3200 MT/s
  (`dmidecode -t 17`), 8 channels per stack = the 32 `uncore_hbm` boxes.
- Theoretical HBM: **1638 GB/s per socket** (4 stacks x 1024 bit x 3.2 GT/s,
  equivalently 32 channels x 2 pseudo-channels x 32 B x 0.8 GHz). An earlier
  draft said 819 GB/s by counting one pseudo-channel per box; see section 2.
- Achieved, read-only: **~430 GB/s per socket** (26%), **890 GB/s** for the
  machine with node-local placement.
- Achieved, mixed read/write: **571 GB/s per socket** (35%).
- The read ceiling is **not** the HBM: its read queue is 24x shallower than
  DDR's under the same load, DDR and HBM share one ~430 GB/s ceiling when the
  cores are split between them, and neither more cores nor deeper prefetch moves
  it. It is the socket's mesh read-return path, ~215 B per 1.994 GHz mesh cycle.
- **HBM is also 24% slower than DDR5 in latency** (137.7 vs 111.3 ns), so
  latency-bound workloads gain nothing from it.

## 1. The machine

| | |
|---|---|
| CPU | 2 x Intel Xeon CPU Max 9462, 32 cores / 64 threads each |
| DDR5 | 128 GB per socket, 16 GB DIMMs at 4800 MT/s configured (5600 rated) |
| HBM | HBM2e, 64 GB per socket (4 x 16 GB Samsung stacks, 3200 MT/s) = NUMA nodes 2 (socket 0) and 3 (socket 1) |
| L2 | 2 MB per core, 64 MB per socket |
| L3 | 75 MB per socket (150 MB total) |
| mode | flat (HBM as its own NUMA nodes), not cache mode |

### Units between a core and HBM

Counted from `/sys/devices/uncore_*`. Every box has cpumask `0-1`, i.e. each
name is instantiated **per socket**, so these are per-socket counts:

| unit | per socket | role |
|---|---|---|
| `uncore_cha` | 40 | caching/home agent: LLC slice + coherence, tracks a miss end to end |
| `uncore_mdf` | 40 | mesh fabric joining the 4 tiles of the SPR die |
| `uncore_m2m` | 4 | mesh-to-memory bridge; directory lookups live here |
| `uncore_hbm` | **32** | HBM channel controllers |
| `uncore_imc` | 4 | DDR5 controllers (separate path) |
| `uncore_upi`, `uncore_m3upi` | 3, 4 | cross-socket links |
| `uncore_pcu` | 1 | power/frequency control |

32 HBM boxes per socket matches 4 HBM2e stacks x 8 channels. Only `uncore_imc`
publishes named events (`cas_count_read`, `cas_count_write`, `clockticks`);
CHA / M2M / MDF / HBM must be programmed with raw `event=`/`umask=` encodings,
which is why `collect_dual_socket_upi/run_intel_hbm_bandwidth.py` hardcodes the
HBM ones.

### How the HBM is organised

`sudo dmidecode -t 17` lists the stacks directly, as `CPU0_HBMIO0-3` and
`CPU1_HBMIO0-3`: `Type: HBM2`, `Speed: 3200 MT/s`, 16 GB each, manufacturer
`0xCE` (Samsung). SMBIOS has no separate HBM2e type code, and the speed settles
the generation: plain HBM2 stops at 2.4 GT/s and HBM3 starts at 4.8 GT/s, so
3.2 GT/s is HBM2e (Samsung Flashbolt, 8 dies x 2 GB per stack).

```
        one socket (Sapphire Rapids package, 4 compute tiles)
 ┌─────────────────────────────────────────────────┐
 │  [HBM stack 0]            [HBM stack 1]         │
 │       ║ EMIB                   ║ EMIB           │
 │  ┌─────────────┐          ┌─────────────┐       │
 │  │ compute tile│── mesh ──│ compute tile│       │
 │  │ 8 hbm boxes │          │ 8 hbm boxes │       │
 │  │ DDR5 IMC    │          │ DDR5 IMC    │       │
 │  └─────────────┘          └─────────────┘       │
 │        │ mesh                    │ mesh         │
 │  ┌─────────────┐          ┌─────────────┐       │
 │  │ compute tile│── mesh ──│ compute tile│       │
 │  │ 8 hbm boxes │          │ 8 hbm boxes │       │
 │  │ DDR5 IMC    │          │ DDR5 IMC    │       │
 │  └─────────────┘          └─────────────┘       │
 │       ║ EMIB                   ║ EMIB           │
 │  [HBM stack 2]            [HBM stack 3]         │
 └─────────────────────────────────────────────────┘
```

Each stack is an independent device: a tower of DRAM dies on a base logic
die, attached to one tile over an EMIB bridge, with its own 8 channels and
controllers. The node's addresses are interleaved across all 4 stacks, so
one HBM NUMA node spans every stack on its socket.

Up to HBM2e, a stack's 1024-bit interface splits into 8 channels of 128 bits,
each of which runs as 2 pseudo-channels of 64 bits:

| level | width | math | bandwidth |
|---|---|---|---|
| pseudo-channel | 64 bit | 8 B x 3.2 GT/s | 25.6 GB/s |
| channel (= 1 `uncore_hbm` box) | 128 bit, 2 pseudo-channels | 16 B x 3.2 GT/s | **51.2 GB/s** |
| stack | 1024 bit, 8 channels | 8 x 51.2 | **409.6 GB/s** |
| socket | 4 stacks | 4 x 409.6 | **1638 GB/s** |

That each box is a full channel, not a pseudo-channel, is visible in the PMU:
every `uncore_hbm` box has separate RPQ/WPQ events for pseudo-channel 0 and 1
(section 4b). HBM3 would instead show 16 x 64-bit channels per stack, 64 boxes
per socket.

## 2. Theoretical HBM bandwidth, derived from the machine

Two quantities measured rather than assumed:

- **32 B per CAS.** A sequential read run moved 858.99 GB of lines and the
  counters reported 27.065 G CAS: 858.99 / 27.065 = 31.7 B/CAS.
- **0.8 GHz per channel.** 112.76 G clockticks / 64 boxes / 2.14 s = 0.823 GHz,
  and an idle 5 s sample gives 0.800 GHz. The controller does not clock up
  under load.

Both fit the 3.2 GT/s that `dmidecode` reports. At 3.2 GT/s the HBM clock is
1.6 GHz (data on both edges). A 64-bit pseudo-channel doing a 4-beat burst
moves 8 B x 4 = **32 B** in 2 HBM clocks, i.e. one CAS per 0.8 GHz tick per
pseudo-channel. The 0.8 GHz counter is therefore most likely the controller
running at half the 1.6 GHz HBM clock (inferred, not documented for this part).
With 2 pseudo-channels per box, a box can issue up to **2 CAS per tick**:

```
32 channels x 2 pseudo-channels x 32 B x 0.8 GHz = 1638 GB/s per socket
                                                   (3.28 TB/s per machine)
```

which is exactly the JEDEC figure, 4 stacks x 1024 bit x 3.2 GT/s / 8.

> **Correction.** An earlier draft assumed 1 CAS per tick per box and quoted
> 819 GB/s per socket, and a caveat claimed `dmidecode` lists only DDR5 and so
> could not settle the clock. Both were wrong: `dmidecode -t 17` lists the HBM
> stacks at 3200 MT/s, and each box covers two pseudo-channels. The
> utilisation percentages below are now against 1638 GB/s, half what they were.
> The *relative* conclusions (sections 4, 4b) do not change.

## 3. What the machine actually delivers (one HBM node)

CAS/clk/channel has a ceiling of 2.0 (two pseudo-channels per box).

| workload | GB/s | CAS/clk/channel | % of 1638 |
|---|---|---|---|
| read only, `bandwidth_rand` 64 thr | 387 (peak interval 432) | 0.473 | 24% |
| read only, MLC | 362 - 418 | - | 22 - 26% |
| sequential read, `bandwidth_seq` | 405 | - | 25% |
| **read-modify-write** (`-mode w`, RFO makes it ~1:1) | **571** (rd 284 + wr 287) | **0.697** | **35%** |
| 1:1 read/write, MLC | 558 | - | 34% |
| 3:1 read/write, MLC | 425 | - | 26% |

Access instruction matters as much as thread count (64 threads, lookahead 64,
run-average GB/s): `t1` 342, `t2` 342, `t0` 298, plain `load` 267, `avx512` 236,
`nta` 149. Prefetching into L2 (`t1`/`t2`) wins because L2 tracks more
outstanding misses than the 16 L1 fill buffers; `nta` is worst because it
bypasses the cache the prefetch was meant to fill.

Latency, from MLC (`--latency_matrix`, ns):

| from \ to | node 0 DDR | node 1 DDR | node 2 HBM | node 3 HBM |
|---|---|---|---|---|
| socket 0 | 111.3 | 238.6 | **137.7** | 243.2 |
| socket 1 | 239.8 | 110.8 | 243.0 | **136.2** |

**HBM on this part is 24% slower than local DDR5** (137.7 vs 111.3 ns). It buys
channel count, not latency.

## 4. Where the read ceiling comes from

A read-only workload tops out near **430 GB/s per HBM node**, about a quarter
of the 1638 GB/s the channels could carry. Writes are not subject to the same ceiling:
mixing them in reaches 571 GB/s total on the same hardware.

### The decisive experiment

If the read ceiling were core-side memory-level parallelism, then adding an
*independent* set of cores should raise it. Socket 1's cores can reach node 2
over UPI, so point both sockets at node 2 and watch node 2's own controllers
(socket 0's `uncore_hbm` boxes), sampled at 100 ms so the answer is not
averaged away:

| config | peak interval | steady while active |
|---|---|---|
| socket 0 -> node 2 (64 thr) | 432 GB/s | 427 |
| **both sockets -> node 2 (128 thr)** | **425 GB/s** | - |
| socket 1 -> node 2 only | 81 GB/s (UPI bound) | - |

**Adding 64 more cores did not raise node 2 above ~430 GB/s.** Socket 1's
~80 GB/s displaced socket 0's traffic instead of adding to it. That is a
saturated resource on the memory side of the mesh, not a shortage of requesters.

Varying how the requesters are split confirms it -- top-8 100 ms intervals of
node 2 read bandwidth, GB/s:

| requesters on node 2 | top-8 intervals |
|---|---|
| 64 local (`n0a2t64`) | 399 399 402 403 404 407 414 **435** |
| 64 local + 16 remote | 382 385 386 388 390 390 394 **399** |
| 32 local + 32 remote | 349 350 372 372 373 374 376 **385** |

More requesters never buys more bandwidth, and substituting remote ones for
local ones makes it *worse*: a read arriving over UPI holds node 2's read
resources for the whole cross-socket round trip (243 ns vs 138 ns), so it
occupies the scarce resource longer per line delivered.

> Note on methodology: the run-average for "both sockets" reads only 154 GB/s,
> which is an artifact, not a result. The benchmark is fixed-work, so socket 1's
> UPI-bound threads keep running for ~8 s after socket 0's finish, leaving node 2
> nearly idle for most of the run. Only the interval series answers the question.

### The second experiment: give the cores a different memory system

If the ceiling belonged to the HBM subsystem, then sending some of the cores to
DDR instead should add bandwidth -- DDR has its own controllers, channels and
DIMMs, sharing nothing with HBM downstream of the mesh. Peak 100 ms interval,
socket 0:

| config | peak total | breakdown |
|---|---|---|
| HBM only, 64 thr | 427 GB/s | HBM 427 |
| DDR only, 64 thr | 241 GB/s | DDR 241 |
| **HBM 32 thr + DDR 32 thr** | **428 GB/s** | HBM 217 + DDR 212 |

**Two independent memory systems, one ceiling.** Splitting the cores between
them yields exactly the total that either reaches alone. Whatever is rationing
reads sits upstream of both.

### What this rules in and out

- **Not DRAM bank/row timing.** Random and sequential reads are within 3%
  (394 vs 405 GB/s). If row locality mattered, they would differ a lot.
- **Not our benchmark.** Intel's own MLC lands in the same place (362-418).
- **Not the HBM controllers.** Their read queue averages 0.79 entries and drains
  in 9 ns (section 4b). They are starved, not backed up.
- **Not the memory subsystem at all.** DDR + HBM together cap where each caps
  alone, and the same channels carry 571 GB/s once writes are mixed in.
- **Not core concurrency.** More cores (even a second socket's) do not raise it,
  and neither does deeper prefetch: a lookahead sweep at 64 threads gives 320 /
  347 / 343 / 340 / 340 GB/s at 16 / 32 / 64 / 128 / 256. It saturates by 32 and
  then flattens, so the cores are not short of requests in flight.
- **Not the CHAs' tracking capacity.** 6.5 outstanding read misses per CHA on
  average, >=16 for 1% of cycles, never >=24.
- **What is left: the socket's mesh read-return path.** The mesh runs at
  **1.994 GHz** (4.318 G CHA clockticks over a 2.166 s run), so 430 GB/s is
  **~215 bytes per mesh cycle** for the whole socket. Every read has to cross it
  and nothing else in the path is full.

The cap is strictly per socket, so the machine scales: both sockets reading
their own local HBM simultaneously reach **890.7 GB/s** (node 2: 443, node 3:
447). Remote access does not scale, because a remote read consumes the home
socket's fabric *and* the UPI link.

> Closing the last step would need `uncore_m2m` counters, to see whether the
> mesh-to-memory bridges are the specific choke point. On this machine that PMU
> does not respond to the standard `event=0x01` clockticks encoding, and the SPR
> M2M event codes are not something to guess at: the two encodings used above
> were each validated against an independently known quantity first (RPQ inserts
> = CAS/2 exactly; CHA TOR inserts = 13.348 G vs 13.356 G read lines), and any
> M2M number should clear the same bar before it is believed.

An earlier draft of this analysis concluded "core-limited" from Little's law
(430 GB/s x 138 ns / 64 B = 927 lines in flight, ~29 per core, near the per-core
outstanding-miss capacity). That arithmetic is consistent but not sufficient:
the two-socket experiment shows the cores are *not* the binding constraint,
because doubling them changes nothing. Little's law tells you the concurrency
present, not who is rationing it.

## 4b. Queue counters: the HBM controllers are starving, not saturated

The HBM PMU has no `events/` directory, but it accepts the **IMC encodings**, so
the read/write pending queue counters that exist for regular DRAM are all
available on `uncore_hbm` -- they just have to be written out by hand:

| what | encoding on `uncore_hbm_N` |
|---|---|
| RPQ inserts, pseudo-channel 0 / 1 | `event=0x10,umask=0x01` / `umask=0x02` |
| RPQ occupancy, pch 0 / 1 | `event=0x80` / `event=0x81` |
| WPQ inserts, pch 0 | `event=0x20,umask=0x01` |
| WPQ occupancy, pch 0 / 1 | `event=0x82` / `event=0x83` |
| CAS read / write | `event=0x05,umask=0xcf` / `umask=0xf0` |
| clockticks | `event=0x01,umask=0x00` |

Both encodings were validated rather than trusted: **RPQ inserts / CAS.rd =
0.500 exactly**, which is what it must be -- the queue tracks 64 B line requests
and CAS counts 32 B column accesses, so 2 CAS per insert. That also confirms the
32 B/CAS figure used in section 2 independently.

The CHA is reachable the same way. `TOR_INSERTS.IA_MISS_DRD` =
`event=0x35,umask=0xC816FE01` and `TOR_OCCUPANCY.IA_MISS_DRD` = `event=0x36`
with the same umask (low byte lands in `config:8-15`, the rest in `config:32+`).
Validated: TOR inserts 13.348 G vs 13.356 G RPQ inserts for the same run.

Measured on `n0a2t64`, one HBM node (pch0 figures):

| mode | RPQ depth per channel | RPQ residency | WPQ depth per channel |
|---|---|---|---|
| read | **0.79** | 9.1 ns | 0.07 |
| write | 2.74 | 40.6 ns | **35.88** |

| CHA TOR (read misses, socket 0) | value |
|---|---|
| average occupancy | 6.47 entries per CHA (259 socket-wide) |
| residency | 87 CHA clocks ~ 32 ns |
| cycles with >= 8 outstanding | 41% |
| cycles with >= 16 outstanding | 1% |
| cycles with >= 24 outstanding | 0% |

**Neither end is full.** The HBM read queue averages 0.79 of an entry and drains
in 9 ns; the controllers sit idle waiting for work. The CHAs hold 6.5 read
misses on average and never exceed ~24, well inside what a TOR can track. The
read transaction is not waiting at the memory controller and it is not blocked
for want of a CHA tracker -- it is spending its time in the fabric between them,
which is where the ~430 GB/s ceiling lives. Closing that last step needs M2M
(`uncore_m2m`) tracker counters, whose SPR encodings are not something to guess
at; the two validated ones above were confirmed against independent quantities
first, and any M2M number should clear the same bar before it is believed.

The same counters on DDR make the contrast unmissable. Identical cores,
identical benchmark, only the memory target changes:

| target | queue depth per box | residency | achieved | % of its own peak |
|---|---|---|---|---|
| HBM node 2 | **0.79** | 9.1 ns | 430 GB/s | 26% of 1638 |
| DDR node 0 | **18.63** | 86 ns | 221 GB/s | 72% of 307 |

DDR's read queue is 24x deeper. DDR is genuinely memory-limited -- requests back
up at the DRAM because the DRAM is the slow stage. HBM is not: its controllers
idle because the fabric never delivers enough requests to keep them busy. The
two numbers are the same system seen from both sides of the same ~430 GB/s
fabric limit: DDR's own ceiling (307) sits below it, HBM's (1638) sits nearly 4x above it.

The write side is the contrast that makes the point: **the write queue holds ~36
entries per channel**, 45x the read queue. A deep queue lets the controller
schedule for row hits and bank parallelism; a queue holding less than one
request cannot be scheduled at all. That, not raw pin bandwidth, is why mixed
traffic reaches 571 GB/s where reads alone stop at 430.

## 5. Consequences for DRAMHiT

- **Budget ~430-450 GB/s per socket for probe-heavy (read) phases**, not the
  advertised HBM figure. Both sockets on local HBM: 890 GB/s measured.
- **HBM helps less than its spec suggests, and DDR is closer to its own limit
  than it looks.** HBM delivers 1.9x DDR's read bandwidth (430 vs 221), not the
  5.3x the raw peaks imply (1638 vs 307), because the same fabric caps both.
- **Mixed insert/probe traffic gets more out of the memory system** than either
  alone -- 571 vs 430 GB/s. A phase that interleaves reads and writes uses the
  hardware better than a pure-read phase.
- **Prefetch into L2, and stop tuning depth past ~32 lines.** `prefetchT1`/`T2`
  beat `T0` by 15% and plain loads by 28%; lookahead saturates at 32. Beyond
  that the fabric, not the core, is the limit.
- **Hyperthreading buys little on reads**: 32 threads reach 316 GB/s, 64 reach
  345 (run-average). The second thread shares the same L2 request queue.
- **Cross-socket access is not a substitute for capacity.** A remote HBM node is
  UPI-bound at ~81 GB/s, five times worse than local.

## 6. Reproducing

```bash
cd /opt/DRAMHiT/scripts/eurosys_2026/machine_stats && make

# per-channel CAS and clockticks (32 boxes/socket)
HBM=$(for i in $(seq 0 31); do printf "uncore_hbm_%d/event=0x05,umask=0xcf,name=rd/,\
uncore_hbm_%d/event=0x05,umask=0xf0,name=wr/,uncore_hbm_%d/event=0x01,umask=0x00,name=clk/," $i $i $i; done | sed 's/,$//')

# read-only vs read-modify-write on one HBM node
sudo perf stat -a -e "$HBM" -x, -- ./build/bandwidth_rand -m 128mb \
    -pattern "n0a2t64" -freq 2.7 -inst t1 -lookahead 64 -mode r
sudo perf stat -a -e "$HBM" -x, -- ./build/bandwidth_rand -m 128mb \
    -pattern "n0a2t64" -freq 2.7 -inst t1 -lookahead 64 -mode w

# the two-socket experiment: -I 100 is essential, the average lies
sudo perf stat -a --per-socket -e "$HBM" -I 100 -x, -- ./build/bandwidth_rand \
    -m 128mb -pattern "n0a2t64 n1a2t64" -freq 2.7 -inst t1 -lookahead 64 -mode r

# queue occupancy at the HBM controllers (RPQ/WPQ, IMC encodings work here)
RPQ=$(for i in $(seq 0 31); do printf "uncore_hbm_%d/event=0x80,umask=0x00,name=rpq_occ/,\
uncore_hbm_%d/event=0x82,umask=0x00,name=wpq_occ/,\
uncore_hbm_%d/event=0x10,umask=0x01,name=rpq_ins/,\
uncore_hbm_%d/event=0x01,umask=0x00,name=clk/," $i $i $i $i; done | sed 's/,$//')
sudo perf stat -a --per-socket -e "$RPQ" -x, -- ./build/bandwidth_rand -m 128mb \
    -pattern "n0a2t64" -freq 2.7 -inst t1 -lookahead 64 -mode r
# depth per channel = sum(occ)/sum(clk);  node total = sum(occ)/(sum(clk)/32)

# CHA outstanding read misses, and the occupancy distribution via thresh=N
CHA=$(for i in $(seq 0 39); do printf "uncore_cha_%d/event=0x36,umask=0xC816FE01,thresh=8,name=ge8/," $i; done | sed 's/,$//')
sudo perf stat -a --per-socket -e "$CHA" -x, -- ./build/bandwidth_rand -m 128mb \
    -pattern "n0a2t64" -freq 2.7 -inst t1 -lookahead 64 -mode r

# vendor cross-checks
cd /opt/DRAMHiT/tools/mlc
sudo ./mlc --bandwidth_matrix
sudo ./mlc --latency_matrix
sudo numactl --cpunodebind=0 --membind=2 ./mlc --max_bandwidth
```
