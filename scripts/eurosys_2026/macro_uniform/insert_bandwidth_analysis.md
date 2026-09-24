# Why cas/dramblast insert sits at ~244 GB/s, and what it is actually short of

Question: the 1r1w microbenchmark ceiling is ~290-300 GB/s, but `amd-9354p_uniform.json`
reports cas (dramblast) insert at ~249 GB/s. Where does the rest go — is the first
insert pass's atomic `cmpxchg` the cost, with the other 99 passes being plain-`mov`
upserts?

Short answer: **the gap is about 8%, not 17%, and the CAS pass is not the reason.** The
ceiling being compared against was measured under conditions DRAMHiT does not run in.

Microbenchmark reference: [`../collect_scalability/local_interleave_analysis.md`](../collect_scalability/local_interleave_analysis.md).
Measurements below use the same per-box `amd_umc` counters, against the same binary
(`/opt/DRAMHiT/build/dramhit`, built 2026-09-20) and the same flags the collection used.

## 1. The reported number is a total, and its rd/wr split is not real

*(Fixed and re-collected 2026-09-22. The pre-fix data is kept as
`amd/amd-9354p_uniform.json.pre-bwfix.bak`; this section describes the bug that produced
it. See section 5 for what the corrected collection shows.)*

`collect_data_amd.py` asked perf only for the combined `umc_mem_bandwidth` metric, and
then appended every sample as `(ts, value, 0.0)` — the write column was a **hardcoded
literal `0.0`**, not a measurement. So in the pre-fix json:

- `set_bw_gbps` — correct: total DRAM traffic (read + write).
- `set_bw_rd_gbps` — the same number copied. Not a read measurement.
- `set_bw_wr_gbps` — `0.0` everywhere, for every table at every fill. Not a measurement.

An insert workload that dirties lines cannot move zero write bytes. The collector now
asks for `umc_mem_read_bandwidth` and `umc_mem_write_bandwidth` separately and tells
them apart by the metric name perf puts in the CSV unit column, so both halves are
measured; their sum reproduces the old total (250.5 vs 249.3 at cas fill 10), which is
the check that the old totals were right even though the split was not.

The old logs cannot be re-derived — `-M umc_mem_bandwidth` records only
`umc_cas_cmd.all`, with no rd/wr breakdown — so the data was re-collected.

## 2. Measured directly, insert really is 1r1w

cas, fill 10, 64 threads, `--numa-split 1`, `--hw-pref 0` — i.e. exactly the
collection's command line — with all 12 `amd_umc` boxes counted at 100% enabled:

| phase | rd GB/s | wr GB/s | total | wr frac | bus util | app |
|---|---|---|---|---|---|---|
| insert | 130.6 | 113.2 | **243.8** | 46.4% | **52.9%** | 1839 set_mops |
| find | 341.1 | 0.8 | **341.9** | 0.2% | **74.2%** | — |

243.8 GB/s reproduces the json's 249.3, and 1839 reproduces its 1838 set_mops. So the
traffic model in the question is right: each insert reads a line and writes it back,
46.4% of controller traffic is writes, and the insert path is a 1r1w stream.

## 3. The ceiling to compare against is ~274 GB/s, not 300

The ~290 GB/s 1r1w peak is measured at **32 threads with node-local memory**. DRAMHiT
runs **64 threads with the table `MPOL_INTERLEAVE`d over all 4 nodes**. Re-running the
microbenchmark at DRAMHiT's operating point (`-pattern "n0a0-3t16 n1a0-3t16 n2a0-3t16
n3a0-3t16"`), back to back with the DRAMHiT runs above so both see identical machine
state:

| | bus util | traffic |
|---|---|---|
| microbench 1r1w, 64 thr, interleaved | **57.3%** | ~274 GB/s |
| **DRAMHiT insert** | **52.9%** | **243.8 GB/s** |
| microbench read, 64 thr, interleaved | **74.4%** | ~330 GB/s |
| **DRAMHiT find** | **74.2%** | **341.9 GB/s** |

> **Prefetcher state, now verified:** MSR `0xC0000108` reads `0x2f` on every cpu —
> L1/L2 prefetchers **disabled** — for all of the measurements above and for the
> collection they are compared against.
>
> This took a correction. `prefetch_control_amd.sh` resolves `rdmsr`/`wrmsr` with
> `which`, so running *the script itself* under sudo resolves against sudo's
> `secure_path`, which does not include the nix store where msr-tools lives: the
> variables came back empty, `sudo ${WRMSR} -a ...` became `sudo -a 0xC0000108 0x2F`,
> and the script printed "Done. Prefetchers disabled." having done nothing. That is how
> I first invoked it, which is why an earlier draft of this document called the
> prefetcher an uncontrolled variable. It was not: `collect_data_amd.py` calls the
> script **without** sudo, where `which` resolves correctly and the write lands. The
> collection was always running with prefetchers off.
>
> The script now resolves the tools before any privilege change, falls back to the nix
> store when run under sudo, refuses to run if it cannot find them, and reads the MSR
> back on every cpu to prove the write landed — so it can no longer report success
> without having done anything.

Two things fall out:

- **find is at the ceiling.** 74.2% against the microbenchmark's 74.4% — DRAMHiT's read
  path extracts everything the memory system will give at this operating point. There is
  no headroom there to chase.
- **insert reaches ~92% of its matched ceiling** (52.9 / 57.3). The shortfall is ~8%,
  not the ~17% that comparing against 290-300 suggests. Most of the apparent gap was the
  ceiling being quoted from a different operating point (32 threads, node-local).

## 4. The CAS pass is not the cost — it is the fastest part

Two independent checks, both negative.

**The bandwidth time series is flat.** Per-100 ms intervals across the whole insert
phase, there is no first-pass transient — the first complete interval is already at the
steady rate and stays there:

```
 3.68s   27.9 rd  30.6 wr  12.7%   <- partial interval at phase start
 3.78s  137.7     119.9     55.9%
 3.89s  128.4     111.2     52.0%
 3.99s  131.5     113.7     53.2%
 4.10s  130.4     112.8     52.8%
 4.20s  130.5     113.1     52.9%   ... flat for all 26 intervals
```

**Varying how much of the work is CAS makes it no worse.** `--insert-factor N` runs the
first pass against empty slots (CAS) and the remaining N-1 as upserts, so N=1 is 100%
CAS and N=100 is 1%:

| insert-factor | CAS share | set_mops |
|---|---|---|
| 1 | 100% | **2047** |
| 2 | 50% | 2055 |
| 10 | 10% | 1848 |
| 100 | 1% | 1851 |

The all-CAS run is the *fastest*, not the slowest. (The 2050 vs 1850 step between N=2 and
N=10 is more likely a short-run artifact — at N=1-2 the run is a fraction of a second and
part of the table is still cache-resident — than evidence that upserts are genuinely
slower; either way it is the opposite of the CAS pass being expensive.)

And arithmetically it could not have mattered: at `--insert-factor 100` the CAS pass is
1% of the work, so even if it ran at half speed it would move the average by well under
a percent.

## 5. What the re-collection shows: the write share falls as the table fills

With the split actually measured, the whole sweep is re-collected
(`amd-9354p_uniform.json`, 31 points x 5 reps, prefetchers verified off at `0x2f` before
every table). Throughput reproduces the pre-fix collection to within ~0.5% everywhere —
dramblast fill 10 set 1845 vs 1838, folklore fill 90 set 512 vs 512 — so the only thing
that changed is that the read/write columns are now real.

Insert-phase DRAM traffic, GB/s:

| | fill 10 | fill 50 | fill 90 |
|---|---|---|---|
| **dramblast** total / rd / wr | 250.2 / 134.1 / 116.1 | 249.9 / 136.6 / 113.1 | 229.4 / 146.8 / 83.4 |
| write share | **46.4%** | 45.3% | **36.4%** |
| **dramhit** total / rd / wr | 245.2 / 132.1 / 113.1 | 237.8 / 135.8 / 102.2 | 219.9 / 156.7 / 63.2 |
| write share | **46.1%** | 43.0% | **28.7%** |
| **folklore** write share | 46.1% | 42.0% | **24.9%** |

Every table starts at ~46% writes — the 1r1w signature of section 2, near the 50% a pure
RFO-plus-writeback stream gives — and every table's write share falls as the table
fills. The reads do not fall with it; they *rise* (dramblast 134.1 -> 146.8, dramhit
132.1 -> 156.7) even as total traffic drops.

That is what a growing probe length looks like at the controller. A successful insert
dirties exactly one line however long the probe was, so the write traffic tracks
completed inserts and falls with throughput. The reads do not: each extra probe is
another line fetched and not dirtied. Reads per dirtied line go from 1.16 at fill 10 to
1.76 at fill 90 for dramblast, and to 2.48 for dramhit — i.e. by 90% fill dramhit is
fetching about two and a half lines for every one it writes.

It also explains why insert throughput degrades more gracefully than lookup: the extra
probe traffic partly displaces write traffic rather than adding to a fixed total, so
total insert bandwidth only falls from 250 to 229 GB/s across the whole fill range.

## 6. What the remaining ~8% is

*(Followed up in [`amd_dramblast_insert_analysis.md`](amd_dramblast_insert_analysis.md):
the core is store-queue-bound, 58–77% of cycles, not memory-bound. That note also shows
the bandwidth numbers here were ~2.5% high from perf's nominal-interval normalisation —
the 243.8 vs 249.3 in §2 — and the insertion plot ceiling is now the 290 GB/s 1r1w peak.)*

Not established here. What is ruled out: it is not the CAS pass (§4), not a read/write
mix different from the microbenchmark's (§2, 46.4% vs 50.0%), and not the memory system
being saturated — at 52.9% bus occupancy the DRAM still has headroom, and the
microbenchmark demonstrably reaches 57.3% on the same hardware in the same
configuration.

That leaves app-side effects that keep slightly fewer requests in flight than the
microbenchmark's tight prefetch-and-store loop: probe comparisons, the batching queue
depth (`--batch-len 16`, `--find_queue 64`), and the small read excess over writes
(rd:wr is 1.15:1, not 1:1) that suggests some accesses read more lines than they dirty.
Isolating those would need per-op counters rather than controller-side ones.
