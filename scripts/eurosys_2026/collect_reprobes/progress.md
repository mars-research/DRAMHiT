# Progress — JOSH_TODO.md

Task: implement `plot_merge.py` per `../PLOTTING.md`, modelled on
`../collect_prefetches/plot_merge.py`, plus one reprobe-factor panel.
Run: `python plot_merge.py intel-paper.json intel-hbm.json amd-r6615.json test.pdf`

- [x] Read TODO, PLOTTING.md, paper_style.py, collect_prefetches/plot_merge.py, plot_data.py
- [x] Inspect data (variants, 9 fills, 1 run per point, NUMA policies, reprobe factors)
- [x] Write plot_merge.py
- [x] Run -> test.pdf generated, layout checked visually

## Notes
- Layout: 1x4 panels. Reprobe-factor panel first, then three Mops-vs-fill panels (Intel DDR, Intel HBM, AMD DDR;
  shared y range from 0, full x sweep).
- Series are probing variants, named as in plot_data.py's LEGEND_REMAP, with
  their own palette at the size of a fixed
  `PROBE_ORDER = [linear, linear+uniform, linear+bucket, linear+bucket+simd,
  linear+bucket+simd+uniform]` (PLOTTING.md §1).
- `linear+uniform` exists only in intel-paper.json, so only the Intel DDR panel
  has it (it's on the reprobe panel too).
- Reprobe factor is **identical on all three machines** (fixed seed, same
  layout), so it's drawn once, taking each variant from the first file that has it.
  The y axis starts at 1 (1 = hit on first probe).
- `linear+bucket` and `linear+bucket+simd` have exactly the same reprobe curve
  (SIMD changes how a bucket is scanned, not which slots are probed). On the
  reprobe panel the simd one is dashed and drawn on top; they still mostly overlap.
- Machine detected from `CPUFREQ_MHZ` (2500 Intel DDR, 2700 HBM, 3250 AMD).
- NUMA policy pinned per machine: Intel DDR 1 (128 threads, dual socket, same as
  collect_prefetches / collect_inline), HBM 10, AMD 1 (both 64 threads).
  intel-paper.json also has a policy-4 (64 thread) sweep; change
  `NUMA_POLICY["Intel DDR"]` to 4 to use it.
- One run per point, so the min/max band draws nothing.

## Performance overview: 70% fill (get Mops, 8 GiB table)

| machine (threads) | linear | linear+uniform | +bucket | +bucket+simd | +bucket+simd+uniform | full vs linear |
| ----------------- | ------ | -------------- | ------- | ------------ | -------------------- | -------------- |
| Intel DDR (128)   | 3172   | 3069           | 3316    | 3762         | 4019                 | +26.7%         |
| Intel HBM (64)    | 1918   | —              | 1835    | 2682         | 2701                 | +40.8%         |
| AMD DDR (64)      | 2940   | —              | 2903    | 3533         | 3655                 | +24.3%         |

Reprobe factor at 70% (all machines): linear 1.292, linear+uniform 1.316,
+bucket 1.190, +bucket+simd 1.190, +bucket+simd+uniform 1.141.

Bucketing by itself barely helps throughput (DDR +4.5%, HBM -4.3%, AMD -1.3%)
even though it cuts reprobes. SIMD is where the gain comes from (+13–46% over
branched bucket). Uniform probing only helps once bucketing is on.
