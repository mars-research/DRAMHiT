## As-shipped interval stream (settled intervals; first and last of the phase dropped), median (min–max) over reps

| metric | bw_double24 | bw_t1 | dramhit_rck_f10 |
|---|---|---|---|
| lines/s (G) [program] | 5.067 (4.904–5.087) | 5.792 (5.694–6.111) | 3.984 (3.905–3.990) |
| HBM GB/s [controllers] | 325.5 (315.0–326.2) | 372.2 (367.9–393.6) | 251.9 (248.1–252.1) |
| core GHz | 1.796 (1.796–1.796) | 1.796 (1.796–1.796) | 1.796 (1.796–1.796) |
| mesh GHz | 2.031 (1.964–2.064) | 2.064 (2.003–2.080) | 1.886 (1.831–1.915) |
| IPC | 2.26 (2.19–2.27) | 0.72 (0.71–0.76) | 1.98 (1.95–1.99) |
| package W | 349.3 (348.7–349.5) | 350.8 (349.8–351.1) | 348.4 (347.4–349.1) |
| xq full % | 1.2 (1.0–3.7) | 53.3 (50.2–54.6) | 4.1 (3.7–4.7) |
| fb_full % | 56.0 (55.8–58.3) | 65.2 (65.1–65.4) | 50.3 (49.7–50.4) |
| L2-miss outstanding / thread | 25.1 (25.0–25.4) | 24.7 (24.6–25.5) | 26.8 (26.2–26.9) |
| cycles/line [from rate] | 22.68 (22.60–23.44) | 19.85 (18.81–20.19) | 28.85 (28.81–29.44) |

Same, bandwidth_rand restricted to t >= 1.2 s into its window (after the ~1 s unthrottled burst):

| metric | bw_double24 | bw_t1 | dramhit_rck_f10 |
|---|---|---|---|
| lines/s (G) [program] | 5.067 (4.904–5.087) | 5.792 (5.694–6.111) | 3.984 (3.905–3.990) |
| HBM GB/s [controllers] | 325.6 (315.0–326.3) | 372.1 (367.4–393.5) | 251.9 (248.1–252.1) |
| core GHz | 1.796 (1.796–1.796) | 1.796 (1.796–1.796) | 1.796 (1.796–1.796) |
| mesh GHz | 2.034 (1.967–2.064) | 2.055 (1.989–2.073) | 1.886 (1.831–1.915) |
| IPC | 2.26 (2.19–2.27) | 0.71 (0.70–0.75) | 1.98 (1.95–1.99) |
| package W | 349.8 (348.9–350.5) | 348.3 (348.0–349.2) | 348.4 (347.4–349.1) |
| xq full % | 1.1 (0.9–3.5) | 53.8 (51.0–55.0) | 4.1 (3.7–4.7) |
| fb_full % | 56.0 (55.8–58.3) | 65.2 (65.2–65.5) | 50.3 (49.7–50.4) |
| L2-miss outstanding / thread | 26.9 (26.6–27.0) | 25.8 (25.8–26.3) | 26.8 (26.2–26.9) |
| cycles/line [from rate] | 22.68 (22.60–23.44) | 19.85 (18.81–20.19) | 28.85 (28.81–29.44) |

Consistency checks (per workload, first rep): window length from perf rows vs the program's own, intervals used, min %running:

- bw_double24: rows 5.01 s, program 5.47 s, intervals 12/14, min running 100%
- bw_t1: rows 4.26 s, program 4.71 s, intervals 10/12, min running 100%
- dramhit_rck_f10: rows 5.19 s, program 5.50 s, intervals 14/16, min running 100%
