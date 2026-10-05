## Per-line costs, differential totals (E9_cap1800), median (min–max) over reps

| workload | reps | lines/s (G) | decimal GB/s of lines | core GHz | instr/line | cycles/line | IPC | HBM rd lines/line | HBM wr lines/line |
|---|---|---|---|---|---|---|---|---|---|
| bw_t1 | 2 | 5.907 (5.723–6.092) | 378.1 (366.3–389.9) | 1.796 (1.796–1.796) | 14.0 (14.0–14.0) | 19.12 (18.51–19.74) | 0.73 (0.71–0.76) | 0.998 (0.998–0.998) | 0.000 (0.000–0.001) |
| dramhit_rck_f10 | 2 | 3.974 (3.939–4.008) | 254.3 (252.1–256.5) | 1.796 (1.792–1.800) | 55.3 (55.3–55.3) | 27.28 (27.10–27.45) | 2.03 (2.01–2.04) | 0.960 (0.960–0.960) | 0.000 (0.000–0.001) |

Cross-check, per workload (median): cycles/line computed two ways
(a) delta cycles / delta lines, (b) 64 threads x core GHz / lines per second:

- bw_t1: (a) 19.12  (b) 19.48
- dramhit_rck_f10: (a) 27.28  (b) 28.93
