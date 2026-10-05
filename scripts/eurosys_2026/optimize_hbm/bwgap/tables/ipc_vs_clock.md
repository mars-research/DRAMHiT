| cap | workload | IPC | core GHz | instr rate (G/s/thread) | HBM GB/s | mesh GHz | pkg W |
|---|---|---|---|---|---|---|---|
| 1800 | bw_double24 | 2.26 | 1.796 | 4.07 | 326 | 2.034 | 350 |
| 1800 | bw_t1 | 0.71 | 1.796 | 1.28 | 372 | 2.055 | 348 |
| 1800 | dramhit_rck_f10 | 1.98 | 1.796 | 3.56 | 252 | 1.886 | 348 |
| 2200 | bw_double24 | 2.03 | 2.193 | 4.45 | 356 | 1.852 | 350 |
| 2200 | bw_t1 | 0.63 | 2.194 | 1.38 | 401 | 1.958 | 350 |
| 2200 | dramhit_rck_f10 | 1.76 | 2.121 | 3.73 | 264 | 1.658 | 348 |
| 2700 | bw_double24 | 1.92 | 2.319 | 4.46 | 356 | 1.728 | 349 |
| 2700 | bw_t1 | 0.52 | 2.522 | 1.30 | 376 | 1.838 | 349 |
| 2700 | dramhit_rck_f10 | 1.72 | 2.177 | 3.75 | 264 | 1.660 | 349 |
mesh ~ IPC only: R2=0.08  rmse=135 MHz  coefs=[ 1.944 -0.061]
mesh ~ core GHz only: R2=0.31  rmse=117 MHz  coefs=[ 2.527 -0.321]
mesh ~ HBM only: R2=0.27  rmse=120 MHz  coefs=[1.401e+00 1.000e-03]
mesh ~ IPC + core GHz: R2=0.55  rmse=94 MHz  coefs=[ 2.916 -0.115 -0.424]
mesh ~ IPC + HBM + core GHz: R2=0.88  rmse=48 MHz  coefs=[ 2.274e+00 -2.400e-02  2.000e-03 -4.920e-01]
mesh ~ IPC*GHz + HBM + core GHz: R2=0.90  rmse=45 MHz  coefs=[ 2.283e+00 -1.800e-02  2.000e-03 -4.750e-01]
