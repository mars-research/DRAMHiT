## Per-line costs, differential totals (E9_cap2000), median (min–max) over reps

| workload | reps | lines/s (G) | decimal GB/s of lines | core GHz | instr/line | cycles/line | IPC | HBM rd lines/line | HBM wr lines/line |
|---|---|---|---|---|---|---|---|---|---|
| bw_t1 | 2 | 6.183 (6.144–6.221) | 395.7 (393.2–398.2) | 1.995 (1.995–1.995) | 14.0 (14.0–14.0) | 20.20 (20.06–20.34) | 0.69 (0.69–0.70) | 0.998 (0.998–0.998) | 0.000 (-0.000–0.001) |
| dramhit_rck_f10 | 2 | 4.079 (4.059–4.099) | 261.1 (259.8–262.3) | 2.005 (2.002–2.009) | 55.5 (55.3–55.8) | 29.68 (29.44–29.92) | 1.87 (1.86–1.88) | 0.960 (0.960–0.960) | 0.000 (0.000–0.001) |

Cross-check, per workload (median): cycles/line computed two ways
(a) delta cycles / delta lines, (b) 64 threads x core GHz / lines per second:

- bw_t1: (a) 20.20  (b) 20.65
- dramhit_rck_f10: (a) 29.68  (b) 31.46
