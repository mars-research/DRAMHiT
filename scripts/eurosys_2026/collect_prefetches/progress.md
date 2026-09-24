# Progress — JOSH_TODO.md

Task: bring `plot_merge.py` in line with `../PLOTTING.md` (paper_style).
Run: `python plot_merge.py intel.json ../intel_hbm/prefetches_hbm.json amd-r6615.json test.pdf`

- [x] Read TODO, PLOTTING.md, paper_style.py, macro_uniform/plot_data.py example
- [x] Inspect data (series, repeats, NUMA policies)
- [x] Rewrite plot_merge.py
- [x] Run and check output -> test.pdf regenerated (usetex on), layout checked visually

## What changed in plot_merge.py
- Prefetch flavours aren't hashtables, so (per PLOTTING.md §1) they get their own
  palette via `configure_palette(n=...)`, built at the size of a fixed
  `PREFETCH_ORDER = [L1, L2, L3, NTA, DOUBLE]`. Colour/legend order is now the
  same in every panel and every run, not dependent on json order.
- Points aggregated to median + min/max per (prefetch, fill) and drawn with
  `ps.draw_band()` + `sns.lineplot` (band is a no-op today: one run per point).
- x axis pinned to the full sweep (`set_xticks`/`set_xlim`), y from 0 with the
  same range on every panel, `ps.tidy()`.
- Panel titles carry machine context: "<machine>, 8 GiB table, 64 threads".
- Dropped the explicit bold title (font.weight is already bold globally),
  `legend_top=0.94` (single row of panels), removed dead palette fallback code.

## Behaviour change to be aware of
- NUMA policy is now explicit per machine (`NUMA_POLICY` dict). intel.json has
  policy 4 (64 thr, single socket) and policy 1 (128 thr, dual socket) with equal
  row counts; the old `mode()` tie-broke to policy 1 (dual socket). Now Intel DDR
  uses policy 4, matching plot_data_intel.py and making all three panels 64
  threads / one node. Intel DDR peak drops from ~4.5k to ~3.3k Mops as a result.
  Change `NUMA_POLICY["Intel DDR"]` to 1 if dual socket was intended.

## Table 1 (original, superseded for Intel DDR): lookup throughput at 70% fill

Mops, get phase, 8 GiB table. **All three machines single socket, 64 threads**
(Intel DDR = intel.json numa_policy 4).

| machine   | L1   |  L2  |  L3  |  NTA | DOUBLE | DOUBLE vs best other | DOUBLE vs NTA |
| --- | --- | ---- | ---- | ---- | ---- | ---- | ---------- |
| Intel DDR | 2666 | 2749 | 2744 | 2230 | 2815 | +2.4% (L2) | +26.2% |
| Intel HBM | 2776 | 2896 | 2902 | 2176 | 3090 | +6.5% (L3) | +42.0% |
| AMD DDR   | 2537 | 3872 | 3827 | 2543 | 3927 | +1.4% (L2) | +54.4% |

One run per point (no repeats), so no variance figures.

## Update: Intel DDR switched to 128 threads (dual socket)

`NUMA_POLICY["Intel DDR"]` changed 4 -> 1, so the Intel DDR panel now draws the
dual-socket, 128-thread sweep from intel.json. Intel HBM (policy 10) and AMD DDR
(policy 1) panels unchanged, both still 64 threads. The shared y-axis top is
still set by AMD (4693 Mops), so the HBM and AMD panels are identical to before.
Regenerated test.pdf.

## Table 2 (current figure): lookup throughput at 70% fill

Mops, get phase, 8 GiB table. **Intel DDR dual socket, 128 threads
(numa_policy 1)**; Intel HBM and AMD DDR single socket, 64 threads (same numbers
as Table 1).

| machine   | threads | L1   |  L2  |  L3  |  NTA | DOUBLE | DOUBLE vs best other | DOUBLE vs NTA |
| --- | --- | --- | ---- | ---- | ---- | ---- | ---- | ---------- |
| Intel DDR | 128 | 3656 | 3757 | 3757 | 3279 | 3849 | +2.4% (L2/L3) | +17.4% |
| Intel HBM | 64  | 2776 | 2896 | 2902 | 2176 | 3090 | +6.5% (L3) | +42.0% |
| AMD DDR   | 64  | 2537 | 3872 | 3827 | 2543 | 3927 | +1.4% (L2) | +54.4% |

One run per point (no repeats), so no variance figures.
