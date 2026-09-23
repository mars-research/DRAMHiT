# Record `dram_peak_gbps`, not just `dram_gbps`

For anyone re-collecting a core-count sweep on another machine. Two lines of
output per point instead of one, and it fixes an artifact that otherwise looks
like a hardware finding.

## The problem

`bandwidth.c` gives **every thread the same fixed work**. Past one thread per
physical core the placement is unbalanced — at 40 threads on a 32-core socket,
8 cores run two threads and 24 run one — so the paired threads take ~2x as long
and **the machine sits nearly idle for the tail of the run**. The median interval
counts that idle time. The peak does not.

Measured on the Xeon CPU Max 9462, `prefetchnta` reads:

| threads | 32 | **40** | 48 | 64 |
|---|---|---|---|---|
| `dram_gbps` (median) | 244.0 | **63.5** | 125.0 | 229.5 |
| `dram_peak_gbps` | 255.6 | **254.9** | 249.9 | 240.8 |

A 75% hole that is entirely the benchmark's fixed work. It is not noise — all
three reps returned exactly 63.5 — so it survives repetition and looks like a
real collapse on a plot.

How far apart the two run, across 12 series x 12 thread counts:

| | median ratio | worst |
|---|---|---|
| balanced points (t <= 32, and t = 64) | **1.02x** | 1.13x |
| unbalanced points (33..63) | 1.12x | **4.01x** |

So at the balanced points either number is fine. It is only 33..63 that lies,
and that is exactly the region where SMT's contribution is read off.

## What to change

Three edits to a collector following the house pattern
(`collect_cpu_scaling_intel_hbm.py` has them all):

**1. In the per-run parse, keep the max alongside the median.** `rows` is the
list of per-interval `(read, write)` rates inside the markers:

```python
totals = [r + w for r, w in rows]
return {
    "dram_gbps":      round(statistics.median(totals), 1),
    "dram_peak_gbps": round(max(totals), 1),          # <- add
    ...
}
```

**2. Add the list to the series entry** in `collect_series`:

```python
entry = {..., "dram_gbps": [], "dram_peak_gbps": [], ...}
```

**3. Aggregate it across reps** — add the key to the loop that already does the
others:

```python
for key in ("dram_gbps", "dram_peak_gbps", "dram_rd_gbps", "dram_wr_gbps"):
```

Note this takes the **median across reps of each rep's peak**, not the max of
maxima. One lucky interval in one rep should not set the number.

## Verify it worked

```bash
python3 -c "
import json; d=json.load(open('<machine>_cpu_scaling.json'))
e=next(iter(d['series'].values()))
print('peak recorded:', 'dram_peak_gbps' in e and any(e['dram_peak_gbps']))"
```

Then plot it — the shared plotter honours it automatically:

```bash
python3 plot_cpu_scaling_all.py --set reads --metric peak
```

If a machine's json lacks the field, that panel silently falls back to its
median and is labelled `(median: no peak recorded)` in its title, and the run
prints an `[i]` line naming it. A figure whose panels mix the two is comparing
different things, so it says so rather than hiding it.

## When the median is still the right number

- **Balanced sweeps.** If every point puts an equal thread count on every node
  and never half-fills a core, there are no stragglers — the AMD NPS4 sweep is
  built this way and its panel barely moves between the two metrics.
- **Reporting sustained throughput** rather than what the hardware can reach.
  The peak is one 20 ms window; the median is what the workload held.

Record both. They cost nothing, disagree by 2% where it does not matter, and by
4x where it does.
