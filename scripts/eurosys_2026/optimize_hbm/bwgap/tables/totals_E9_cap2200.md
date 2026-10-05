## Per-line costs, differential totals (E9_cap2200), median (min–max) over reps

| workload | reps | lines/s (G) | decimal GB/s of lines | core GHz | instr/line | cycles/line | IPC | HBM rd lines/line | HBM wr lines/line |
|---|---|---|---|---|---|---|---|---|---|
| bw_t1 | 2 | 5.859 (5.692–6.025) | 375.0 (364.3–385.6) | 2.194 (2.193–2.195) | 14.0 (14.0–14.0) | 23.48 (22.81–24.15) | 0.60 (0.58–0.61) | 0.998 (0.998–0.998) | 0.000 (0.000–0.000) |
| dramhit_rck_f10 | 2 | 4.070 (4.048–4.093) | 260.5 (259.1–262.0) | 2.102 (2.069–2.135) | 55.8 (55.8–55.8) | 30.77 (30.13–31.42) | 1.81 (1.77–1.85) | 0.959 (0.959–0.959) | 0.000 (0.000–0.001) |

Cross-check, per workload (median): cycles/line computed two ways
(a) delta cycles / delta lines, (b) 64 threads x core GHz / lines per second:

- bw_t1: (a) 23.48  (b) 23.99
- dramhit_rck_f10: (a) 30.77  (b) 33.05
