# Why dlht "beats" dramblast on insertion at 10% fill

Intel Xeon Gold 6548Y+, 2 sockets / 128 threads, 2.5 GHz pinned, 8 GiB table,
mode 11. Follow-up to the first `intel/intel-6548y_uniform.json`, where dlht
inserted at 3102 Mops against dramblast's 2671 at 10% fill and then fell below
it by 30%.

> **Status: fixed.** Sections 1-6 are the investigation of the original data.
> Section 8 records the change that was made to `dlht_kht.hpp` and
> `prefetch_control.sh` as a result, and the numbers after it.

**Answer: dlht is not doing the same work.** The benchmark replays the same key
set 100 times, so 99% of the measured "insertions" are inserts of a key that is
already present. On that path dramblast writes the value back; dlht does
nothing at all. dramblast therefore pays a dirty cacheline -- a full 64 B
writeback to DRAM -- on 99% of the ops, and dlht pays none. Both saturate DRAM,
so the one moving less traffic wins. The lead is an artifact of the workload and
of the dlht integration, not a property of the table.

## 1. Almost every measured insert is a duplicate

`UniformTest::run` inserts `ht_size * ht_fill / 100` distinct keys, and
`do_uniform_inserts` repeats that whole set `insert_factor` times
(`src/tests/uniform_test.cpp:139`). The collector uses `INSERT_FACTOR = 100`, and
the timer covers all 100 passes. Pass 1 is fresh inserts; passes 2-100 re-insert
keys that are already there. 99% of the reported op count is the duplicate path.

The generated value equals the key (`uniform_test.cpp:41`), so skipping the
update is invisible to the find phase that follows -- `found == find_ops` still
holds, and the collector's own consistency check cannot catch it.

## 2. The duplicate path is asymmetric

dramblast, on a key match, stores the value (`include/hashtables/cas_kht.hpp:317`):

    if (key_cmp > 0) {
      __mmask8 offset = _bit_scan_forward(key_cmp);
      ...
      bucket[(offset + 1)] = q->value;   // dirties the line
      break;
    }

dlht, on a key match, returns without touching the bucket
(`include/hashtables/dlht_kht.hpp:509-536`) -- the update is commented out in the
source:

    // Slot* slot = get_slot(primary_bucket, slot_index);
    // slot->key = kp[i].key;
    // slot->value = kp[i].value;
    ...
    // DLHT returns value if found, our interface doesn't return on
    // inserts so do nothing for now
    ...
    if (found) continue;

The same commented-out update and the same `if (found) continue;` appear a second
time at `dlht_kht.hpp:631-659`, in the re-check inside the insert CAS retry loop,
so both duplicate paths are no-ops.

So dlht's line is fetched (the batch prefetch at `dlht_kht.hpp:468` even asks for
write ownership, `rw=1`) but never modified: it stays clean and is dropped, not
written back.

## 3. Measured: identical reads, 12.5x difference in writes

`perf stat -a -e uncore_imc/cas_count_read/,uncore_imc/cas_count_write/` around an
insert-only run (`--read-factor 0`, which reproduces the collected set_mops to
within 0.3%), fill 10, **hardware prefetchers off for every table** so the only
variable is the table:

| table     | Mops | DRAM rd B/op | DRAM wr B/op | total B/op | achieved |
|-----------|-----:|-------------:|-------------:|-----------:|---------:|
| dramblast | 2676 |         76.8 |     **65.3** |      142.1 | 380 GB/s |
| dramhit   | 2611 |         77.7 |     **65.0** |      142.7 | 373 GB/s |
| folklore  | 2180 |         77.9 |     **65.4** |      143.4 | 313 GB/s |
| dlht      | 4169 |         78.2 |      **5.2** |       83.4 | 348 GB/s |

Every table reads the same ~77 B/op -- one cacheline per op, as expected for
random 64 B access. Three of the four write back a full line per op. dlht writes
5.2 B/op, i.e. nothing beyond the 1% of ops that are genuine inserts.

dramblast and dlht both land at 350-380 GB/s of DRAM traffic, which is this box's
random-access ceiling. They are both bandwidth-bound, and the throughput ratio
(4169/2676 = 1.56) tracks the inverse traffic ratio (142.1/83.4 = 1.70) rather
than any difference in efficiency. dlht is faster because it moves 41% less
memory, not because it does the work better. Note it is also the *most*
instruction-heavy of the four; it wins anyway because instructions are not the
bottleneck.

## 4. Decisive test: remove the duplicates and the ordering reverses

Same conditions, varying `--insert-factor` so the duplicate fraction changes:

| insert-factor | duplicate ops | dramblast Mops | dlht Mops |
|--------------:|--------------:|---------------:|----------:|
|             1 |            0% |           2538 |  **1883** |
|             2 |           50% |           2588 |      2236 |
|             5 |           80% |           2540 |      3416 |
|            20 |           95% |           2661 |      3910 |
|           100 |           99% |           2672 |  **4024** |

With no duplicates dlht is **35% slower** than dramblast; at the collector's
setting it is 51% faster. dramblast is flat across the whole range (2538-2672)
because it does the same probe-and-write either way. dlht's entire curve is the
duplicate path progressively replacing real work with a no-op. This is the
experiment that settles it.

## 5. Why dlht still loses by 30% fill

dlht's traffic per op stays flat as the table fills (83.4 -> 79.8 -> 81.5 B/op at
fill 10/20/40) but its throughput drops 4169 -> 3796 -> 2902, i.e. from 348 to
237 GB/s. It falls *off* the bandwidth ceiling: the per-op CPU cost grows with
occupancy (the match scan walks up to `MAX_SLOTS`=15 slot states, the version
re-check can retry, and past 3 keys per bucket the chain spills into link
buckets) until dlht is latency/compute-bound rather than bandwidth-bound.
dramblast stays pinned near the ceiling over the same range (380 -> 360 GB/s,
2676 -> 2583 Mops), so it simply stops losing and the lines cross around 30%.

That is also the same mechanism that ends dlht's sweep at 40%: the link pool
(`capacity/8`) is exhausted past ~45% fill.

## 6. Side finding: the prefetcher setting in the collector is backwards here

While controlling for the hardware prefetcher I found two things worth acting on.

**`scripts/prefetch_control.sh` was a silent no-op when run under `sudo`.** It
resolved its tools with `RDMSR=$(which rdmsr)` at the top, and sudo's
`secure_path` does not contain them, so `WRMSR` expanded to nothing and the line
became `sudo 0x1a4 -a 0x0` -> `sudo: 0x1a4: command not found`, leaving the MSR
untouched. Called *without* sudo (as `collect_data_intel.py` did) it worked, so
the collected data was never wrong -- but an hour went into chasing the
discrepancy, and anyone toggling prefetchers with sudo by hand was changing
nothing. Fixed; see section 8.

`scripts/prefetch_control_amd.sh` still has the identical pattern (`$(which)` at
the top plus an internal `sudo`) and should get the same treatment before the
next AMD collection.

**Prefetchers-on is not the baselines' best case on this machine.** The
collector gives folklore and dlht the hardware prefetcher on, on the assumption
that it favours them. Measured at fill 10, insert-only:

| table     | prefetchers off | prefetchers on | effect of "on" |
|-----------|----------------:|---------------:|---------------:|
| dramblast |            2677 |           2676 |            -0% |
| folklore  |            2173 |           2026 |            -7% |
| dlht      |            4237 |           3021 |        **-29%** |

The access stream is random, so the prefetcher generates only useless traffic,
and it competes for the same bandwidth the table needs. dramblast is unaffected
(it already drives the memory system from its own queue); the two baselines are
actively hurt. **The dlht and folklore rows of `intel-6548y_uniform.json` are
therefore not those tables' best case** -- dlht's insert numbers are understated
by roughly 29%. The comparison in the paper is conservative in the baselines'
favour in intent but against them in fact, which is worth fixing before the
figure is used.

## 7. What to conclude

- The 10% fill result should not be read as "dlht inserts faster than
  dramblast". It measures dlht skipping the update that the other three tables
  perform.
- If the paper wants an insert comparison, either set `insert_factor = 1` (all
  fresh inserts, where dramblast leads by 35%) or restore dlht's update so all
  four tables have the same semantics. **Done** -- see section 8.
- Re-collect dlht and folklore with the hardware prefetcher off, or state in the
  caption that the per-series prefetcher state differs and is not each series'
  optimum.

## 8. The fix

**`include/hashtables/dlht_kht.hpp`** -- a duplicate insert now overwrites the
value, as it already did in the other three tables. Both duplicate paths were
dead (the one in `insert_batch`'s Get phase and the re-check inside the insert
CAS retry loop), so both were changed. The matched slot is recorded during the
scan (`found_slot`) and the store happens in the validated `else if (found)`
branch rather than at the commented-out location inside the scan loop: the
version re-check immediately above is what establishes that `found_slot` still
belongs to this key. Same one store per duplicate op either way.

**`scripts/prefetch_control.sh`** -- no longer calls `sudo` itself; the caller
provides privilege. Tool lookup now hard-fails instead of expanding to empty,
and the script reads MSR 0x1a4 back after writing and exits non-zero if the
value did not land, so the silent-no-op failure mode cannot recur. Because
sudo's `secure_path` drops msr-tools from PATH (even under `sudo -E`), the
invocation is now:

    sudo env PATH="$PATH" scripts/prefetch_control.sh off

`collect_data_intel.py`'s `set_prefetcher()` was updated to match, and `sh()`
already passes `check=True`, so a failed prefetcher change now aborts the run
instead of letting it collect under the wrong state.

### Effect, fill 10, prefetchers off, insert-only

| table            | Mops | DRAM rd B/op | DRAM wr B/op |
|------------------|-----:|-------------:|-------------:|
| dramblast        | 2675 |         76.8 |         65.3 |
| dlht **before**  | 4169 |         78.2 |      **5.2** |
| dlht **after**   | 2542 |         77.6 |     **65.5** |

dlht now moves a dirty line per op like everything else, and dramblast leads at
10% fill. The duplicate-fraction sweep from section 4 flattens accordingly:

| insert-factor | duplicates | dlht before | dlht after |
|--------------:|-----------:|------------:|-----------:|
|             1 |         0% |        1883 |       1888 |
|             2 |        50% |        2236 |       2132 |
|             5 |        80% |        3416 |       2251 |
|            20 |        95% |        3910 |       2473 |
|           100 |        99% |        4024 |       2536 |

The residual 1888 -> 2536 rise is real rather than an artifact: dlht's
fresh-insert path costs two CASes plus the state machine, so the duplicate path
is genuinely cheaper for it. dramblast shows the same trend at +5% (2538 ->
2672); dlht's is larger because its insert is heavier, which is a property of
the table and belongs in the measurement.

### Re-collection

`intel/intel-6548y_uniform.json` was re-collected in full after the fix (155
runs, 0 failures, same flags and prefetcher settings as before). Insert Mops:

| fill | dramblast | dramhit | folklore | dlht before -> after |
|-----:|----------:|--------:|---------:|---------------------:|
|   10 |      2675 |    2612 |     2044 |    3102 -> 2208 (-29%) |
|   20 |      2626 |    2553 |     1903 |    2886 -> 2109 (-27%) |
|   30 |      2608 |    2511 |     1825 |    2557 -> 1927 (-25%) |
|   40 |      2584 |    2462 |     1727 |    2299 -> 1753 (-24%) |

The other three tables moved by at most 2% (run-to-run noise) and dlht's *lookup*
numbers by at most 5%, which is the control this fix needed: only dlht's insert
path was touched, and only dlht's insert numbers moved.

dlht no longer leads anywhere. It now sits below both DRAMHiT tables at every
fill and converges with folklore by 40%, which is what the traffic accounting in
section 3 predicts once it pays the same dirty line per op as everyone else.

## Reproducing

    # traffic per op, one table, insert phase only
    perf stat -a -e cycles,instructions,uncore_imc/cas_count_read/,uncore_imc/cas_count_write/ \
      sudo build/dramhit --mode 11 --ht-type 10 --ht-size 536870912 --ht-fill 10 \
        --num-threads 128 --numa-split 1 --batch-len 32 --find_queue 64 \
        --no-prefetch 0 --hw-pref 0 --insert-factor 100 --read-factor 0 \
        --skew 0.01 --seed 1775762440565610239

    # the reversal: same command with --insert-factor 1
    # prefetcher state:
    sudo env PATH="$PATH" scripts/prefetch_control.sh on|off
