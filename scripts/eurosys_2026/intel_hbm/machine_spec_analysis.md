# Xeon CPU Max 9462: how much HBM bandwidth can this machine actually use?

Everything below was measured on the machine (`perf` uncore counters, Intel MLC,
and `machine_stats/bandwidth.c`) rather than taken from a spec sheet, except
where marked *nominal*. Collected 2026-09-11, directory snoop mode, turbo off,
all cores pinned at 2.7 GHz.

## 1. The machine

| | |
|---|---|
| CPU | 2 x Intel Xeon CPU Max 9462, 32 cores / 64 threads each |
| DDR5 | 128 GB per socket, 16 GB DIMMs at 4800 MT/s configured (5600 rated) |
| HBM | 64 GB per socket = NUMA nodes 2 (socket 0) and 3 (socket 1) |
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

## 2. Theoretical HBM bandwidth, derived from the machine

Two quantities measured rather than assumed:

- **32 B per CAS.** A sequential read run moved 858.99 GB of lines and the
  counters reported 27.065 G CAS: 858.99 / 27.065 = 31.7 B/CAS.
- **0.8 GHz per channel.** 112.76 G clockticks / 64 boxes / 2.14 s = 0.823 GHz,
  and an idle 5 s sample gives 0.800 GHz. The controller does not clock up
  under load.

A 128-bit channel at DDR moves 32 B per clock, so at 1 CAS per clock per
channel:

```
32 channels x 32 B x 0.8 GHz = 819 GB/s per socket   (1.64 TB/s per machine)
```

> **Caveat.** Whether that 0.8 GHz counter is the full DRAM clock or a half-rate
> domain is not resolvable from this machine: HBM2e is *nominally* 3.2 GT/s,
> which would make the raw stack ceiling 1638 GB/s per socket and halve every
> utilisation percentage below. `dmidecode` enumerates only the DDR5 DIMMs, so
> it cannot settle it; Intel's spec sheet for the 9462 would. Every *relative*
> conclusion here is unaffected.

## 3. What the machine actually delivers (one HBM node)

| workload | GB/s | CAS/clk/channel | % of 819 |
|---|---|---|---|
| read only, `bandwidth_rand` 64 thr | 387 (peak interval 432) | 0.473 | 47% |
| read only, MLC | 362 - 418 | - | 44 - 51% |
| sequential read, `bandwidth_seq` | 405 | - | 49% |
| **read-modify-write** (`-mode w`, RFO makes it ~1:1) | **571** (rd 284 + wr 287) | **0.697** | **70%** |
| 1:1 read/write, MLC | 558 | - | 68% |
| 3:1 read/write, MLC | 425 | - | 52% |

Latency, from MLC (`--latency_matrix`, ns):

| from \ to | node 0 DDR | node 1 DDR | node 2 HBM | node 3 HBM |
|---|---|---|---|---|
| socket 0 | 111.3 | 238.6 | **137.7** | 243.2 |
| socket 1 | 239.8 | 110.8 | 243.0 | **136.2** |

**HBM on this part is 24% slower than local DDR5** (137.7 vs 111.3 ns). It buys
channel count, not latency.

## 4. Where the read ceiling comes from

A read-only workload tops out near **430 GB/s per HBM node**, about half the
819 GB/s the channels could carry. Writes are not subject to the same ceiling:
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

### What this rules in and out

- **Not DRAM bank/row timing.** Random and sequential reads are within 3%
  (394 vs 405 GB/s). If row locality mattered, they would differ a lot.
- **Not our benchmark.** Intel's own MLC lands in the same place (362-418).
- **Not core concurrency.** The experiment above: more cores, same ceiling.
- **Not the pins.** The same channels carry 571 GB/s when the traffic is mixed,
  so ~30% more data is physically deliverable than a read stream can extract.
- **Consistent with a read-path resource** between the mesh and the HBM
  controllers -- outstanding-read trackers at M2M, or read scheduling in the HBM
  controller. Reads occupy a tracker for the full ~138 ns latency; writes are
  posted and retire immediately, which is why adding writes adds throughput.

An earlier draft of this analysis concluded "core-limited" from Little's law
(430 GB/s x 138 ns / 64 B = 927 lines in flight, ~29 per core, near the per-core
outstanding-miss capacity). That arithmetic is consistent but not sufficient:
the two-socket experiment shows the cores are *not* the binding constraint,
because doubling them changes nothing. Little's law tells you the concurrency
present, not who is rationing it.

## 5. Consequences for DRAMHiT

- **Budget ~430 GB/s per socket for probe-heavy (read) phases**, not the
  advertised HBM figure. Two sockets with node-local placement: ~860 GB/s.
- **Mixed insert/probe traffic gets more out of the memory system** than either
  alone -- 571 vs 430 GB/s. A phase that interleaves reads and writes uses the
  hardware better than a pure-read phase.
- **Prefetch depth matters more than usual here.** HBM's 138 ns latency is
  higher than DDR's; `prefetchT1` outperforming `prefetchT0` (see `readme.txt`)
  fits, since T1 targets L2, whose queue is deeper than the 16 L1 fill buffers.
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

# vendor cross-checks
cd /opt/DRAMHiT/tools/mlc
sudo ./mlc --bandwidth_matrix
sudo ./mlc --latency_matrix
sudo numactl --cpunodebind=0 --membind=2 ./mlc --max_bandwidth
```
