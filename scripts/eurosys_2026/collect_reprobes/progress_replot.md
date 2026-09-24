# Progress: replot with repeats (JOSH_TODO.md)

Goal: cut the noise in the reprobe/throughput sweep by measuring every point
several times, storing median + all samples, and plotting the spread.

- [x] Read JOSH_TODO.md, collect_data.py, plot_merge.py,
      ../macro_uniform/collect_data_intel.py, ../macro_uniform/plot_data_bw.py
- [x] Rewrite collect_data.py in the collect_data_intel.py structure
- [x] Dry-run + short smoke test (linear, fills 70/90, 2 reps: fill-90 get spread 8.3%)
- [x] Full Intel DDR collection (180 runs, 0 failures; log in intel_ddr/collect.log) -> intel-ddr.json (new file; no existing json touched)
- [x] plot_merge.py: read the new json, draw min/max band when samples exist
- [x] Replot -> reprobes_reps.pdf (reprobes.pdf left as is), with intel-ddr.json + intel-hbm.json + amd-r6615.json

## What changed in collect_data.py
- Same structure as ../macro_uniform/collect_data_intel.py: constants block,
  build/run/parse helpers, per-point repeats, json saved after every point,
  per-run logs in intel_ddr/logs/<variant>/fillNN_repN.log, --dry-run,
  --variant/--fill/--reps/--no-build.
- REPS=5; json keeps the median (`get_mops`, `reprobe_factor`, ...) and every
  sample (`get_samples`, `reprobe_factor_samples`, ...).
- Likely noise sources removed: every cmake option that affects the measured
  path is pinned (the build dir was left at DRAMHiT_VARIANT=2025_INLINE, which
  forces bucketization + SIMD on), hardware prefetcher set off explicitly
  (never set before), and the found == find_ops check rejects bad runs.
- Only the 128-thread numa-split-1 sweep plot_merge.py draws; the 64-thread
  policy-4 sweep is not re-collected.
- Refuses to overwrite its output json without --force. Default output is
  intel-ddr.json (new file).

## What changed in plot_merge.py
- Reads both layouts: the new dict json (median + min/max band from
  `get_samples`, like plot_data_bw.py) and the old flat lists (no band).
- Legacy output checked byte-identical to before for
  intel-paper.json intel-hbm.json amd-r6615.json.

## Results: Intel DDR, 128 threads, 5 reps (median get Mops)

| fill | linear | +bucket | +bucket+simd | +bucket+simd+uniform |
| ---- | ------ | ------- | ------------ | -------------------- |
| 70%  | 3039   | 3172    | 3614         | 3753 (+23.5% vs linear) |
| 90%  | 1817   | 1863    | 1927         | 2841                 |

Old single-run numbers at 70% were 3172 / 3316 / 3762 / 4019, so all four are
3-7% lower in the new data. The order of the variants hasn't changed.

- Min-max spread over the 5 reps is still 0.4-11% for a single point (worst:
  linear+bucket and +simd at 90%, ~11%). So each run is still noisy, but the
  median is stable enough that the curves no longer cross by accident.
- The full scheme is the tightest (mostly under 2%).
- Reprobe factors match the old data exactly (linear 1.2917 at 70%). They are
  identical across reps, except for one 1e-4 difference at 90% uniform.
- `build/` is left configured as linear+bucket+simd+uniform with CALC_STATS=ON.
- Next: re-run HBM and AMD with the same collector (change CPUFREQ_MHZ /
  NUM_THREADS / NUMA_SPLIT / DEFAULT_OUT).
