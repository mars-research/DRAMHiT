## As-shipped interval stream (settled intervals; first and last of the phase dropped), median (min–max) over reps

| metric | bw_double24 | bw_t1 | dramhit_rck_f10 |
|---|---|---|---|
| lines/s (G) [program] | 5.536 (5.445–5.537) | 6.219 (6.086–6.247) | 4.154 (4.130–4.186) |
| HBM GB/s [controllers] | 356.3 (350.6–357.2) | 401.8 (390.1–404.7) | 263.6 (261.7–265.3) |
| core GHz | 2.180 (2.171–2.185) | 2.194 (2.191–2.194) | 2.121 (2.113–2.127) |
| mesh GHz | 1.844 (1.804–1.883) | 1.963 (1.952–1.995) | 1.658 (1.627–1.699) |
| IPC | 2.04 (2.02–2.04) | 0.63 (0.62–0.64) | 1.76 (1.75–1.76) |
| package W | 349.5 (348.7–350.1) | 351.9 (350.5–352.0) | 348.3 (348.3–348.5) |
| xq full % | 14.6 (13.6–17.1) | 61.7 (61.4–62.2) | 13.2 (12.7–13.9) |
| fb_full % | 62.1 (61.9–62.6) | 66.8 (66.7–66.8) | 53.9 (53.8–54.0) |
| L2-miss outstanding / thread | 26.3 (26.1–26.7) | 24.5 (24.0–25.3) | 27.1 (26.6–27.3) |
| cycles/line [from rate] | 25.25 (25.20–25.52) | 22.58 (22.48–23.03) | 32.68 (32.52–32.74) |

Same, bandwidth_rand restricted to t >= 1.2 s into its window (after the ~1 s unthrottled burst):

| metric | bw_double24 | bw_t1 | dramhit_rck_f10 |
|---|---|---|---|
| lines/s (G) [program] | 5.536 (5.445–5.537) | 6.219 (6.086–6.247) | 4.154 (4.130–4.186) |
| HBM GB/s [controllers] | 356.4 (350.8–357.3) | 401.3 (389.5–403.4) | 263.6 (261.7–265.3) |
| core GHz | 2.193 (2.189–2.194) | 2.194 (2.194–2.194) | 2.121 (2.113–2.127) |
| mesh GHz | 1.852 (1.800–1.888) | 1.958 (1.940–1.983) | 1.658 (1.627–1.699) |
| IPC | 2.03 (2.00–2.03) | 0.63 (0.61–0.63) | 1.76 (1.75–1.76) |
| package W | 349.5 (349.5–350.0) | 350.2 (349.7–350.9) | 348.3 (348.3–348.5) |
| xq full % | 15.2 (13.8–18.4) | 62.2 (62.0–62.6) | 13.2 (12.7–13.9) |
| fb_full % | 62.3 (62.0–63.0) | 66.8 (66.6–66.9) | 53.9 (53.8–54.0) |
| L2-miss outstanding / thread | 27.9 (27.4–28.0) | 25.5 (25.2–25.9) | 27.1 (26.6–27.3) |
| cycles/line [from rate] | 25.36 (25.35–25.73) | 22.58 (22.48–23.07) | 32.68 (32.52–32.74) |

Consistency checks (per workload, first rep): window length from perf rows vs the program's own, intervals used, min %running:

- bw_double24: rows 4.65 s, program 4.85 s, intervals 11/13, min running 100%
- bw_t1: rows 3.89 s, program 4.30 s, intervals 9/11, min running 100%
- dramhit_rck_f10: rows 4.78 s, program 5.13 s, intervals 12/14, min running 100%
