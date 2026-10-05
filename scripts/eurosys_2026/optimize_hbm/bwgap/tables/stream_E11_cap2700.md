## As-shipped interval stream (settled intervals; first and last of the phase dropped), median (min–max) over reps

| metric | bw_double24 | bw_t1 | dramhit_rck_f10 |
|---|---|---|---|
| lines/s (G) [program] | 5.536 (5.397–5.682) | 5.838 (5.816–6.158) | 4.177 (4.135–4.259) |
| HBM GB/s [controllers] | 355.5 (346.4–364.8) | 376.0 (375.5–398.3) | 263.8 (260.8–268.4) |
| core GHz | 2.312 (2.300–2.363) | 2.520 (2.519–2.546) | 2.177 (2.122–2.203) |
| mesh GHz | 1.728 (1.721–1.753) | 1.840 (1.840–1.854) | 1.660 (1.628–1.684) |
| IPC | 1.92 (1.88–1.93) | 0.52 (0.51–0.54) | 1.72 (1.72–1.74) |
| package W | 349.0 (348.9–349.4) | 349.2 (348.8–350.5) | 348.7 (348.1–349.6) |
| xq full % | 28.6 (27.4–32.6) | 66.1 (66.1–67.2) | 14.8 (14.0–15.1) |
| fb_full % | 64.9 (64.7–65.7) | 66.9 (66.8–67.6) | 54.0 (53.8–54.6) |
| L2-miss outstanding / thread | 27.5 (26.5–27.7) | 25.3 (24.9–25.5) | 27.1 (26.7–27.3) |
| cycles/line [from rate] | 26.73 (26.62–27.27) | 27.62 (26.46–27.73) | 33.10 (32.84–33.35) |

Same, bandwidth_rand restricted to t >= 1.2 s into its window (after the ~1 s unthrottled burst):

| metric | bw_double24 | bw_t1 | dramhit_rck_f10 |
|---|---|---|---|
| lines/s (G) [program] | 5.536 (5.397–5.682) | 5.838 (5.816–6.158) | 4.177 (4.135–4.259) |
| HBM GB/s [controllers] | 355.5 (346.8–364.6) | 376.0 (375.1–398.1) | 263.8 (260.8–268.4) |
| core GHz | 2.319 (2.308–2.363) | 2.522 (2.498–2.539) | 2.177 (2.122–2.203) |
| mesh GHz | 1.728 (1.721–1.753) | 1.838 (1.837–1.847) | 1.660 (1.628–1.684) |
| IPC | 1.92 (1.88–1.93) | 0.52 (0.51–0.54) | 1.72 (1.72–1.74) |
| package W | 348.9 (348.5–349.3) | 348.5 (348.1–350.3) | 348.7 (348.1–349.6) |
| xq full % | 28.5 (27.2–32.8) | 66.2 (66.2–67.4) | 14.8 (14.0–15.1) |
| fb_full % | 64.9 (64.7–65.8) | 66.9 (66.8–67.6) | 54.0 (53.8–54.6) |
| L2-miss outstanding / thread | 28.7 (27.8–28.7) | 26.0 (25.7–26.1) | 27.1 (26.7–27.3) |
| cycles/line [from rate] | 26.81 (26.62–27.38) | 27.49 (26.38–27.64) | 33.10 (32.84–33.35) |

Consistency checks (per workload, first rep): window length from perf rows vs the program's own, intervals used, min %running:

- bw_double24: rows 4.69 s, program 4.97 s, intervals 11/13, min running 100%
- bw_t1: rows 4.25 s, program 4.62 s, intervals 10/12, min running 100%
- dramhit_rck_f10: rows 4.86 s, program 5.19 s, intervals 12/14, min running 100%
