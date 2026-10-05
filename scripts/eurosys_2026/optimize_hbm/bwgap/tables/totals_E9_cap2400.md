## Per-line costs, differential totals (E9_cap2400), median (min–max) over reps

| workload | reps | lines/s (G) | decimal GB/s of lines | core GHz | instr/line | cycles/line | IPC | HBM rd lines/line | HBM wr lines/line |
|---|---|---|---|---|---|---|---|---|---|
| bw_t1 | 2 | 6.200 (6.146–6.253) | 396.8 (393.4–400.2) | 2.395 (2.392–2.398) | 14.0 (14.0–14.0) | 24.10 (23.92–24.28) | 0.58 (0.58–0.59) | 0.998 (0.998–0.998) | -0.000 (-0.000–0.000) |
| dramhit_rck_f10 | 2 | 4.251 (4.239–4.262) | 272.0 (271.3–272.8) | 2.229 (2.216–2.241) | 55.8 (55.8–55.8) | 31.99 (31.92–32.05) | 1.74 (1.74–1.75) | 0.960 (0.960–0.960) | 0.000 (0.000–0.001) |

Cross-check, per workload (median): cycles/line computed two ways
(a) delta cycles / delta lines, (b) 64 threads x core GHz / lines per second:

- bw_t1: (a) 24.10  (b) 24.72
- dramhit_rck_f10: (a) 31.99  (b) 33.55
