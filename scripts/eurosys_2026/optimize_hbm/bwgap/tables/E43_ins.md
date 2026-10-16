## E43_ins: insert phase vs 1r1w bound (`logs/E43_ins`; reps 5, 5, 5, 5)

| metric | **bw_t1_w (1r1w)** | dramblast insert, dvs_p3, q128 / b64 | **deep insert (`dvi_hs24`), q128 / b16** | deep insert (`dvi_hs24`), q128 / b64 |
|---|---|---|---|---|
| HBM GB/s (rd + wr, controllers) | 616.0 [617.1; 601.8–646.6] | 444.4 [443.8; 442.0–446.4] | 499.6 [501.0; 496.6–501.5] | 489.4 [489.8; 486.5–491.4] |
| HBM read / write GB/s | 308.5 / 308.5 | 235.5 / 208.4 | 265.8 / 235.2 | 259.9 / 229.9 |
| core GHz | 2.311 [2.305; 2.284–2.329] | 2.141 [2.142; 2.120–2.161] | 2.031 [2.038; 1.993–2.059] | 2.130 [2.142; 2.103–2.145] |
| mesh GHz | 1.718 | 1.644 | 1.596 | 1.641 |
| IPC | 0.46 | 1.61 | 1.40 | 1.20 |
| instr rate per thread (G/s) | 1.06 | 3.44 | 2.85 | 2.55 |
| package W | 348.6 | 349.0 | 349.2 | 349.1 |
| xq full % / fb_full % | 86.5 / 87.4 | 5.7 / 51.8 | 34.9 / 66.0 | 30.4 / 60.3 |
| program lines (inserts) per s (G) | 4.821 | 3.323 | 3.783 | 3.695 |
| window from program (s) | 5.57 | 6.46 | 5.68 | 5.81 |
| energy per program line (nJ) | 72.2 | 105.0 | 92.0 | 94.5 |
| energy per HBM line (nJ) | 36.1 | 50.1 | 44.7 | 45.7 |
| HBM lines per program line (rd + wr) | 2.014 (1.007 + 1.007) | 2.085 (1.106 + 0.979) | 2.055 (1.090 + 0.965) | 2.063 (1.095 + 0.969) |
| instr per HBM line | 7.0 | 31.8 | 23.3 | 21.4 |
| cycles per HBM line (64 × core GHz ÷ HBM lines/s) | 15.4 | 19.8 | 16.7 | 17.9 |
| cycles per program line | 30.8 | 41.3 | 34.2 | 36.9 |
| steady intervals per rep | 15 | 20 | 16 | 17 |

### Prediction check against `bw_t1_w` (per-rep ratios, reps 2–5, medians)

| step | HBM GB/s ratio | clock ratio | active-cpu ratio | cycles-per-line effect (1 / ratio) | model | residual |
|---|---|---|---|---|---|---|
| bw_t1_w → dramblast insert, dvs_p3, q128 / b64 | 0.726 | 0.923 | 1.000 | 0.785 | 0.724 | +0.3 % |
| bw_t1_w → **deep insert (`dvi_hs24`), q128 / b16** | 0.816 | 0.873 | 1.000 | 0.935 | 0.813 | +0.7 % |
| bw_t1_w → deep insert (`dvi_hs24`), q128 / b64 | 0.800 | 0.924 | 1.000 | 0.868 | 0.797 | +0.4 % |
