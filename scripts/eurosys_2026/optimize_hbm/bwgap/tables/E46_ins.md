## E46_ins: insert phase vs 1r1w bound (`logs/E46_ins`; reps 5, 5, 5, 5, 5)

| metric | **bw_t1_w (1r1w)** | dvs_p3 insert, q128 / b16 | **deep insert (`dvi_hs24`), q128 / b16** | **deep insert cleaned (`dvk`), harness key pf 64 t2** | `dvk128` (16 B hash store), key pf 64 t2 |
|---|---|---|---|---|---|
| HBM GB/s (rd + wr, controllers) | 627.7 [646.9; 600.4–647.7] | 452.8 [455.8; 437.2–459.5] | 498.7 [497.8; 487.2–505.9] | 526.2 [525.3; 518.8–530.4] | 525.7 [525.9; 511.0–529.7] |
| HBM read / write GB/s | 323.4 / 323.4 | 241.8 / 214.0 | 264.1 / 233.7 | 278.7 / 246.6 | 279.0 / 246.9 |
| core GHz | 2.284 [2.290; 2.256–2.310] | 2.085 [2.093; 2.044–2.133] | 2.040 [2.031; 2.011–2.093] | 1.954 [1.954; 1.904–1.996] | 1.957 [1.958; 1.907–1.986] |
| mesh GHz | 1.713 | 1.614 | 1.594 | 1.544 | 1.546 |
| IPC | 0.48 | 1.71 | 1.38 | 1.46 | 1.47 |
| instr rate per thread (G/s) | 1.11 | 3.63 | 2.84 | 2.84 | 2.88 |
| package W | 347.9 | 349.0 | 349.9 | 348.8 | 348.1 |
| xq full % / fb_full % | 84.5 / 86.4 | 7.3 / 57.2 | 34.8 / 66.0 | 60.3 / 67.6 | 60.5 / 66.9 |
| program lines (inserts) per s (G) | 5.011 | 3.440 | 3.788 | 3.965 | 3.962 |
| window from program (s) | 5.36 | 6.24 | 5.67 | 5.42 | 5.42 |
| energy per program line (nJ) | 69.4 | 101.5 | 92.1 | 87.9 | 88.0 |
| energy per HBM line (nJ) | 34.4 | 49.0 | 44.9 | 42.4 | 42.5 |
| HBM lines per program line (rd + wr) | 2.015 (1.008 + 1.008) | 2.076 (1.101 + 0.975) | 2.055 (1.090 + 0.965) | 2.073 (1.100 + 0.973) | 2.072 (1.099 + 0.973) |
| instr per HBM line | 7.1 | 32.6 | 23.3 | 22.1 | 22.3 |
| cycles per HBM line (64 × core GHz ÷ HBM lines/s) | 14.6 | 19.0 | 16.9 | 15.2 | 15.3 |
| cycles per program line | 29.4 | 39.5 | 34.7 | 31.6 | 31.6 |
| steady intervals per rep | 14 | 18 | 16 | 15 | 15 |

### Prediction check against `bw_t1_w` (per-rep ratios, reps 2–5, medians)

| step | HBM GB/s ratio | clock ratio | active-cpu ratio | cycles-per-line effect (1 / ratio) | model | residual |
|---|---|---|---|---|---|---|
| bw_t1_w → dvs_p3 insert, q128 / b16 | 0.709 | 0.919 | 1.000 | 0.762 | 0.703 | +1.1 % |
| bw_t1_w → **deep insert (`dvi_hs24`), q128 / b16** | 0.782 | 0.898 | 1.000 | 0.860 | 0.772 | +0.5 % |
| bw_t1_w → **deep insert cleaned (`dvk`), harness key pf 64 t2** | 0.819 | 0.859 | 1.000 | 0.943 | 0.809 | +1.3 % |
| bw_t1_w → `dvk128` (16 B hash store), key pf 64 t2 | 0.818 | 0.861 | 1.000 | 0.940 | 0.810 | +1.0 % |
