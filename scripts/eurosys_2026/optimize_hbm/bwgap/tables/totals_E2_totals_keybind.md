## Per-line costs, differential totals (E2_totals_keybind), median (min–max) over reps

| workload | reps | lines/s (G) | decimal GB/s of lines | core GHz | instr/line | cycles/line | IPC | HBM rd lines/line | HBM wr lines/line |
|---|---|---|---|---|---|---|---|---|---|
| dramhit_new_keys_ddr_f10 | 3 | 4.155 (4.122–4.257) | 265.9 (263.8–272.4) | 2.275 (2.060–2.321) | 55.8 (55.8–55.8) | 32.41 (31.64–32.82) | 1.72 (1.70–1.76) | 0.960 (0.959–0.960) | 0.000 (0.000–0.001) |
| dramhit_new_keys_hbm_f10 | 3 | 4.156 (3.884–4.224) | 266.0 (248.6–270.4) | 2.311 (2.134–2.312) | 55.8 (55.8–55.8) | 33.20 (32.80–34.14) | 1.68 (1.63–1.70) | 1.085 (1.085–1.085) | 0.000 (0.000–0.001) |
| dramhit_rck_orig_f10 | 3 | 4.087 (4.070–4.248) | 261.6 (260.5–271.8) | 2.163 (2.123–2.237) | 55.8 (55.3–55.8) | 31.67 (31.59–32.16) | 1.75 (1.73–1.76) | 0.960 (0.959–0.960) | 0.000 (0.000–0.000) |

Cross-check, per workload (median): cycles/line computed two ways
(a) delta cycles / delta lines, (b) 64 threads x core GHz / lines per second:

- dramhit_new_keys_ddr_f10: (a) 32.41  (b) 34.20
- dramhit_new_keys_hbm_f10: (a) 33.20  (b) 35.17
- dramhit_rck_orig_f10: (a) 31.67  (b) 33.71
