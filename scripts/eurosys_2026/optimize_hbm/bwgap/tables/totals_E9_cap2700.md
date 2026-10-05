## Per-line costs, differential totals (E9_cap2700), median (min–max) over reps

| workload | reps | lines/s (G) | decimal GB/s of lines | core GHz | instr/line | cycles/line | IPC | HBM rd lines/line | HBM wr lines/line |
|---|---|---|---|---|---|---|---|---|---|
| bw_t1 | 2 | 6.105 (6.058–6.153) | 390.7 (387.7–393.8) | 2.525 (2.504–2.546) | 14.0 (14.0–14.0) | 25.79 (25.76–25.81) | 0.54 (0.54–0.54) | 0.998 (0.998–0.998) | 0.000 (-0.000–0.000) |
| dramhit_rck_f10 | 2 | 4.151 (4.127–4.174) | 265.6 (264.2–267.1) | 2.153 (2.126–2.181) | 55.8 (55.3–56.2) | 31.56 (31.43–31.69) | 1.77 (1.76–1.77) | 0.960 (0.960–0.960) | 0.000 (0.000–0.001) |

Cross-check, per workload (median): cycles/line computed two ways
(a) delta cycles / delta lines, (b) 64 threads x core GHz / lines per second:

- bw_t1: (a) 25.79  (b) 26.47
- dramhit_rck_f10: (a) 31.56  (b) 33.20
