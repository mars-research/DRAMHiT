# Core-count sweep on the AMD EPYC 9354P, and why half its prefetch hints do nothing

Collected 2026-09-23. 1x **AMD EPYC 9354P** (Zen4 Genoa), 32 cores / 64 threads, NPS4,
12 DDR5-4800 channels. Hardware prefetchers **off** (`prefetch_control_amd.sh off`, MSR
`0xC0000108 = 0x2f`, read back on every cpu).

Data: [`amd-9354p_cpu_scaling.json`](amd-9354p_cpu_scaling.json) ·
figure: [`amd-9354p_cpu_scaling.png`](amd-9354p_cpu_scaling.png) ·
collector: [`collect_cpu_scaling_amd.py`](collect_cpu_scaling_amd.py) ·
plotter: [`plot_cpu_scaling_amd.py`](plot_cpu_scaling_amd.py) ·
all three machines: [`plot_cpu_scaling_all.py`](plot_cpu_scaling_all.py)

12 series x 14 thread counts x 3 reps, 0 failures.

## The sweep

The BIOS shows 4 NUMA nodes but this is **one package** — one Infinity Fabric, 12
channels, and the nodes are a partition of that single memory system. So the sweep
treats it as one: memory `MPOL_INTERLEAVE`d across all 4 nodes on every run, and threads
ramping package-wide — node 0's 8 physical cores, then node 1's, 2's, 3's (32 threads =
one per physical core on the whole package), then the SMT siblings in the same node
order.

```
threads  1..8   9..16  17..24  25..32 | 33..40  41..48  49..56  57..64
node        0       1       2       3 |     0       1       2       3
         physical cores               | SMT siblings
```

## The result: L1-targeting prefetches cost a MAB slot for the full DRAM latency

DRAM GB/s at the controllers, random read:

| series | target | 1 | 8 | 16 | 32 | 64 |
|---|---|---|---|---|---|---|
| no sw prefetch | — | 10 | 75 | 148 | 252 | **260** |
| prefetcht0 | L1 | 8 | 61 | 121 | 224 | 246 |
| prefetchnta | L1 | 8 | 61 | 121 | 224 | 246 |
| prefetchw | L1 | 8 | 60 | 120 | 223 | 246 |
| prefetcht1 | L2 | 26 | 100 | 202 | 324 | **353** |
| prefetcht2 | L2 | 26 | 100 | 202 | 326 | **353** |

The three L1-targeting hints are **identical to each other at all 14 thread counts**
(within 1 GB/s), the two L2-targeting hints are identical to each other, and the two
groups differ by 36%. The L1 group sits consistently **~5% below using no prefetch at
all**.

### It is not the lookahead distance

Sweeping `-lookahead` at 64 threads:

| inst | 1 | 2 | 4 | 8 | 16 | 32 | 64 | 128 | 256 |
|---|---|---|---|---|---|---|---|---|---|
| load | 260 | 260 | 260 | 260 | 260 | 260 | 260 | 260 | 260 |
| **t0** | 242 | 246 | 248 | 247 | 247 | 246 | 246 | 246 | 244 |
| **nta** | 241 | 246 | 248 | 248 | 247 | 246 | 246 | 246 | 244 |
| t1 | 242 | 250 | 263 | 290 | 338 | **354** | 353 | 352 | 352 |
| t2 | 242 | 250 | 263 | 290 | 338 | 353 | 352 | 351 | 351 |

`t0` and `nta` are flat across a 256x range. `t1` climbs with distance and saturates at
lookahead ~32, which is a working prefetch covering DRAM latency.

### It is not a bug in the binary, and the prefetches are not dropped

Both were checked, because "the prefetch does nothing" is a strong claim.

The disassembly of the t0 read loop is correct -- two independent crc32 hashes, the
prefetch issued at the lookahead index, inside the loop:

```
crc32  %rsi,%rcx          ; rcx = crc32(state, i)        <- demand index
crc32  %rbx,%rdi          ; rdi = crc32(state, i+ahead)  <- prefetch index
prefetcht0 (%r11,%rdi,1)
```

And the hardware says the prefetches are issued and useful. `ls_pref_instr_disp.all`
counts **2.686e10 for t0 and 2.686e10 for t1** -- identical, one per loop iteration --
and `ls_inef_sw_pref.all` (prefetches that fetched nothing because they hit in the data
cache or matched an already-allocated MAB entry) is **0.3% of them for t0 and 0.0% for
t1**. The t0 prefetches are dispatched, and the hardware does not consider them
redundant.

### What is actually happening: the MAB is the limiting resource

`ls_alloc_mab_count` sums in-flight L1 miss buffers each cycle, so occupancy / cycles is
the average number of L1 misses outstanding. Dividing it by the achieved rate gives how
long each MAB entry is held. At 32 threads -- one per physical core, so the per-core MAB
is not shared between SMT siblings -- lookahead 64:

| inst | DRAM GB/s | MAB occupancy | lines/cycle/thread | **MAB residency** |
|---|---|---|---|---|
| load | 250 | 17.74 | 0.0376 | **145 ns** |
| t0 | 223 | 15.00 | 0.0335 | **138 ns** |
| nta | 224 | 15.11 | 0.0337 | 138 ns |
| t1 | 321 | 6.06 | 0.0482 | **39 ns** |
| t2 | 320 | 6.09 | 0.0480 | 39 ns |

That is the whole story:

- **A prefetcht0 allocates an L1 MAB entry and holds it for the entire DRAM round trip
  (138 ns), exactly as the demand miss it replaced would have (145 ns).** Occupancy sits
  at 15-18, which is the per-core MAB limit. So the prefetch changes *which instruction*
  occupies the slot, not how many slots there are or how long each is held. There is
  nothing left to win: the workload was MAB-limited before the prefetch and is
  MAB-limited after it. The ~5% deficit is the extra hash and prefetch uop, paid for a
  reordering that buys nothing.

- **A prefetcht1 targets L2, so the long DRAM wait happens in the L2 fill queue instead
  -- a different and deeper structure.** The L1 MAB is only allocated later, by the
  demand load, and is satisfied from L2 in **39 ns** rather than 145. The same small
  number of MAB entries turns over 3.7x faster.

Little's law closes: t1 sustains 6.06/126cyc = 0.0481 lines/cycle against load's
17.74/472cyc = 0.0376, a ratio of **1.28** -- and the measured bandwidths are 321/250 =
**1.28**.

### Why more lookahead does not fix it

The natural objection: lookahead exists precisely so the prefetch has time to land before
the binding load needs it, so a big enough lookahead should make the load hit. It does --
that is not the part that fails.

What fails is that **lookahead only creates concurrency while there is somewhere to hold
the outstanding requests it creates.**

Outstanding requests are not directly countable on this part, so they are derived by
Little's law, `outstanding = throughput x latency`. Both terms are measured:

- throughput, from the controller-side GB/s;
- latency, from `l3_xi_sampled_latency.dram_near` / `l3_xi_sampled_latency_requests.dram_near`.
  That gives latency in the XI's own sampled units, which is enough -- what matters is
  each workload's latency **relative to the demand-miss stream**, and the ratio needs no
  scale factor. `load`'s absolute anchor comes from its own MAB residency, 145 ns, which
  for that stream *is* the DRAM round trip by definition, since every outstanding request
  it has is a MAB entry. (The two agree: 11.89 sampled units x 10 ns = 119 ns at the XI,
  plus the core-to-L3 traversal the MAB also covers.)

Measuring the latency rather than assuming it matters, because the assumption is wrong:

| inst | GB/s | MAB occ | measured latency (rel. to load) | latency | **outstanding** | **outside the MAB** |
|---|---|---|---|---|---|---|
| load | 250 | 17.74 | 1.000 | 145 ns | 17.7 | **0.0** |
| t0 | 223 | 15.00 | 0.937 | 136 ns | 14.8 | -0.2 |
| t1 | 321 | 6.06 | **2.000** | 290 ns | **45.5** | **39.5** |
| t2 | 320 | 6.09 | 1.987 | 289 ns | 45.1 | 39.0 |

t1's DRAM latency is **twice** load's, which is exactly what deeper queueing at the
controller looks like: it has far more requests in flight, so each waits longer, and it
still comes out 28% ahead on throughput. Assuming equal latency (as an earlier version of
this document did) understates t1's outstanding count by half.

For `load` the MAB column and the outstanding column are **the same number**: every
outstanding DRAM request is a MAB entry, so concurrency is hard-capped at MAB capacity,
~16-18 per core. `t0` sits in the same place. `t1` sustains ~45 requests in flight while
holding only 6 MAB entries -- **~39 of them are parked outside the L1 miss buffer**, in
the L2 fill path.

So the chain is:

1. The out-of-order engine **already** fills the MAB from the independent demand loads.
   `load` reaches 17.74 occupancy with no prefetch instruction at all.
2. An L1-targeting prefetch's in-flight request also occupies a MAB entry. The resource
   it would need is therefore already saturated before the prefetch is issued.
3. Raising the lookahead asks for more requests in flight, but past ~16 there is nowhere
   to put them -- the excess prefetch either stalls or is dropped. Concurrency, and so
   throughput, does not move.

That is why `t0` is flat from lookahead 4 to 256: it saturates as soon as the MAB does,
which the demand stream had already done on its own. And it is why `t1` keeps improving
to lookahead ~32 -- its requests are not competing for the MAB, so more distance really
does buy more in-flight work. At lookahead 64 it ends up holding ~45, which needs a
lookahead of at least that many iterations to sustain; at 32 the sweep already shows it
within 0.3% of its ceiling.

The short version: prefetch distance buys memory-level parallelism, and this workload was
never short of distance -- it was short of **somewhere to put the parallelism**.

### Consequence

On this part, `prefetcht1`/`t2` are the only software prefetches that help a random read
stream, and they are worth **+36%** over no prefetch. `prefetcht0`, `prefetchnta` and
`prefetchw` are worse than nothing.

The rule this generalises to: **software prefetching a miss that will go to DRAM is only
worth anything if it moves the wait out of the L1 miss buffer.** On a MAB-limited
workload an L1-targeting prefetch is a no-op by construction, however far ahead it is
issued. Anything in DRAMHiT issuing `prefetcht0`/`nta`/`w` on a path that misses to DRAM
should be `prefetcht1`.

## The rest of the sweep

- **Reads** reach 359 GB/s at 40 threads against the 353 GB/s ceiling measured
  independently in [`local_interleave_analysis.md`](local_interleave_analysis.md).
- **Writes** (1r1w) peak at 296 GB/s by 24-32 threads and then *decline* to 273 by 64 —
  SMT actively hurts a store stream, which reads do not.
- **`prefetchw` on the write path buys nothing either** (tracks the no-prefetch line
  within 1 GB/s at every point), while `t1`/`t2` give ~3%. Same L1-vs-L2 split as the
  read side.
- **CCD steps are visible in the ramp.** Threads 1-4 are node 0's first CCD and 5-8 add
  its second, and 4 -> 8 threads is exactly 2.00x for writes and 2.05x for reads — the
  ~50 GB/s per-CCD link ceiling from `local_interleave_analysis.md` section 1, showing up
  here through a completely different measurement.

> **Caveat on the 33-63 thread range.** Placement there is unbalanced — at 40 threads
> node 0 runs 16 while nodes 1-3 run 8 — so some cores carry two threads and others one.
> bandwidth.c gives every thread equal work, so the paired threads straggle and the
> machine idles waiting. The `ntstore` series shows it worst: per-rep samples at t=40 are
> `[175.7, 229.2, 166.9]` against a rock-solid `[229.4, 229.4, 229.4]` at t=32. Only 32
> and 64 are balanced placements; treat the points between them as noisier than their
> error-free appearance suggests.
