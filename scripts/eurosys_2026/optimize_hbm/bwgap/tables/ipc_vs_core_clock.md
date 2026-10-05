| workload | IPC | core GHz | instr rate (G/s/thread) | HBM GB/s |
|---|---|---|---|---|
| bw_t1 | 0.51 | 2.506 | 1.29 | 368 |
| t1pad_p0 | 0.52 | 2.533 | 1.32 | 376 |
| double_p0 | 0.80 | 2.516 | 2.01 | 400 |
| mimic_s1_p0 | 0.80 | 2.489 | 1.99 | 397 |
| t1pad_p8 | 0.92 | 2.471 | 2.27 | 377 |
| t1pad_p16 | 1.28 | 2.429 | 3.10 | 388 |
| mimic_s2_p0 | 1.34 | 2.344 | 3.15 | 370 |
| double_p8 | 1.47 | 2.355 | 3.47 | 384 |
| t1pad_p24 | 1.51 | 2.514 | 3.80 | 380 |
| dramhit_rck_f10 | 1.72 | 2.321 | 3.98 | 260 |
| mimic_s3_p0 | 1.74 | 2.282 | 3.97 | 326 |
| t1pad_p32 | 1.74 | 2.537 | 4.41 | 369 |
| double_p16 | 1.74 | 2.361 | 4.12 | 376 |
| mimic_s5_p0 | 1.78 | 2.216 | 3.95 | 275 |
| double_p24 | 1.94 | 2.374 | 4.61 | 364 |
| bw_double24 | 1.98 | 2.315 | 4.58 | 367 |
| mimic_s4_p0 | 2.01 | 2.169 | 4.36 | 304 |
| t1pad_p48 | 2.09 | 2.581 | 5.40 | 341 |
| double_p32 | 2.10 | 2.384 | 5.00 | 342 |
| double_p48 | 2.16 | 2.496 | 5.40 | 295 |
core GHz ~ IPC: R2=0.18 rmse=101 MHz coefs=[ 2.548 -0.092]
core GHz ~ instr rate: R2=0.08 rmse=107 MHz coefs=[ 2.504 -0.026]
core GHz ~ HBM GB/s: R2=0.27 rmse=96 MHz coefs=[1.896e+00 1.000e-03]
core GHz ~ IPC + HBM: R2=0.30 rmse=94 MHz coefs=[ 2.074e+00 -4.400e-02  1.000e-03]
corr(IPC, GHz)=-0.43  corr(instr rate, GHz)=-0.29  corr(HBM, GHz)=0.52  corr(IPC,HBM)=-0.55
