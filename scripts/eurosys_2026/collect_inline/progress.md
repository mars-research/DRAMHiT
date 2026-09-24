# Progress — JOSH_TODO.md

Task: implement `plot_merge.py` per `../PLOTTING.md`, modelled on
`../collect_prefetches/plot_merge.py` (mops only, no counter panels).
Run: `python plot_merge.py intel-paper.json ../intel_hbm/inline-hbm.json amd-r6615.json test.pdf`

- [x] Read TODO, PLOTTING.md, paper_style.py, collect_prefetches/plot_merge.py
- [x] Inspect data (4 variants, 9 fills, 1 run per point, NUMA policies)
- [x] Write plot_merge.py
- [x] Run -> test.pdf generated, layout checked visually

## Notes
- Series are inlining variants, not hashtables, so they get their own palette at
  the size of a fixed `INLINE_ORDER = [Base, Compiler Inline, Manual Inline,
  Manual+Compiler Inline]` (PLOTTING.md §1).
- One panel per machine, get-phase Mops vs fill, median + min/max band
  (band is a no-op: one run per point), y from 0 shared across panels, full x sweep.
- Machine detected from counters: `uops_dispatched.*` -> Intel (HBM if path has
  "hbm"), `ls_dispatch.*` -> AMD.
- NUMA policy pinned per machine. Originally Intel DDR 4, Intel HBM 10, AMD 1,
  so all panels were 64 threads / one node.
- [x] Replot: Intel DDR switched to policy 1 (128 threads, dual socket) from
  intel-paper.json; HBM and AMD panels unchanged (64 threads). test.pdf regenerated.

## Overview (original plot): lookup throughput at 70% fill (Mops, all machines 64 threads, 8 GiB table)

| machine   | Base | Compiler | Manual | Manual+Compiler | M+C vs Base |
| --------- | ---- | -------- | ------ | --------------- | ----------- |
| Intel DDR | 2744 | 2740     | 2861   | 2887            | +5.2%       |
| Intel HBM | 2690 | 2849     | 3134   | 3279            | +21.9%      |
| AMD DDR   | 3725 | 3603     | 3821   | 3974            | +6.7%       |

Compiler-only inlining is flat or slightly worse on DDR machines (-0.1% Intel,
-3.3% AMD); manual inlining is where the gain comes from. One run per point, so
no variance figures.

## Overview (current plot): lookup throughput at 70% fill (Mops, Intel DDR 128 threads, HBM/AMD 64 threads, 8 GiB table)

| machine                | Base | Compiler | Manual | Manual+Compiler | M+C vs Base |
| ---------------------- | ---- | -------- | ------ | --------------- | ----------- |
| Intel DDR (128 thr)    | 4017 | 3953     | 4114   | 4130            | +2.8%       |
| Intel HBM (64 thr)     | 2690 | 2849     | 3134   | 3279            | +21.9%      |
| AMD DDR (64 thr)       | 3725 | 3603     | 3821   | 3974            | +6.7%       |

At 128 threads Intel DDR gains shrink to +2.8% (compiler-only -1.6%); HBM and
AMD rows are identical to the table above.
