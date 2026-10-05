## As-shipped interval stream (settled intervals; first and last of the phase dropped), median (min–max) over reps

| metric | bw_double24 | bw_t1 | dramhit_rck_f10 |
|---|---|---|---|
| lines/s (G) [program] | 5.686 (5.626–5.716) | 6.192 (6.143–6.204) | 4.263 (4.157–4.351) |
| HBM GB/s [controllers] | 365.3 (361.3–367.3) | 400.9 (397.7–401.8) | 276.8 (274.5–280.4) |
| core GHz | 2.369 (2.323–2.390) | 2.567 (2.531–2.571) | 2.181 (2.153–2.201) |
| mesh GHz | 1.755 (1.735–1.765) | 1.863 (1.840–1.869) | 1.662 (1.644–1.701) |
| IPC | 1.92 (1.92–1.94) | 0.54 (0.54–0.54) | 1.74 (1.70–1.79) |
| package W | 348.8 (348.6–349.2) | 349.1 (348.7–349.8) | 347.7 (346.9–351.2) |
| xq full % | 27.9 (26.3–28.5) | 67.1 (67.1–67.2) | 16.2 (15.8–19.4) |
| fb_full % | 64.8 (64.4–64.9) | 67.6 (67.6–67.6) | 54.7 (53.2–57.4) |
| L2-miss outstanding / thread | 26.5 (26.0–26.9) | 25.2 (24.3–25.3) | 26.2 (25.9–27.3) |
| cycles/line [from rate] | 26.67 (26.43–26.77) | 26.53 (26.36–26.53) | 32.67 (32.31–33.15) |

Same, bandwidth_rand restricted to t >= 1.2 s into its window (after the ~1 s unthrottled burst):

| metric | bw_double24 | bw_t1 | dramhit_rck_f10 |
|---|---|---|---|
| lines/s (G) [program] | 5.686 (5.626–5.716) | 6.192 (6.143–6.204) | 4.263 (4.157–4.351) |
| HBM GB/s [controllers] | 364.9 (361.3–367.1) | 400.8 (397.5–401.8) | 276.8 (274.5–280.4) |
| core GHz | 2.371 (2.322–2.390) | 2.554 (2.512–2.556) | 2.181 (2.153–2.201) |
| mesh GHz | 1.754 (1.735–1.764) | 1.861 (1.838–1.868) | 1.662 (1.644–1.701) |
| IPC | 1.93 (1.92–1.94) | 0.54 (0.54–0.54) | 1.74 (1.70–1.79) |
| package W | 348.7 (347.1–349.0) | 348.1 (347.6–349.1) | 347.7 (346.9–351.2) |
| xq full % | 27.7 (26.1–28.3) | 67.4 (67.4–67.4) | 16.2 (15.8–19.4) |
| fb_full % | 64.8 (64.4–64.9) | 67.6 (67.6–67.6) | 54.7 (53.2–57.4) |
| L2-miss outstanding / thread | 27.9 (27.2–28.3) | 25.7 (25.3–25.9) | 26.2 (25.9–27.3) |
| cycles/line [from rate] | 26.68 (26.42–26.76) | 26.37 (26.17–26.40) | 32.67 (32.31–33.15) |

Consistency checks (per workload, first rep): window length from perf rows vs the program's own, intervals used, min %running:

- bw_double24: rows 4.27 s, program 4.73 s, intervals 10/12, min running 100%
- bw_t1: rows 3.91 s, program 4.37 s, intervals 9/11, min running 100%
- dramhit_rck_f10: rows 1.18 s, program 1.26 s, intervals 4/4, min running 100%
