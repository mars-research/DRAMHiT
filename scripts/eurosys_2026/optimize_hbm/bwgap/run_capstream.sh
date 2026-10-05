#!/usr/bin/env bash
# E11: package power at a fixed core clock, interval-stream method (find-phase intervals only), 3 interleaved reps per cap.
set -u
cd "$(dirname "$0")"
for cap in 1800 2200 2700; do
  python3 run_stream.py --reps 3 --cap $cap --read-factor 400 --workloads bw_t1 bw_double24 dramhit_rck_f10 --out E11_cap$cap > logs/E11_cap$cap.run.log 2>&1
done
python3 ../fbfull/cpufreq_cap.py restore > logs/E11_restore.txt 2>&1
echo ALL_DONE > logs/chain_e11.done
