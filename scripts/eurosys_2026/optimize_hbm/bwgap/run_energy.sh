#!/usr/bin/env bash
# E8/E9: energy per line vs core clock. E8: natural clocks, many workloads. E9: cpufreq cap sweep on two workloads.
set -u
cd "$(dirname "$0")"
python3 run_totals.py --set energy --reps 3 --out E8_energy > logs/E8_energy.run.log 2>&1
for cap in 1800 2000 2200 2400 2700; do
  python3 run_totals.py --set capsweep --reps 2 --cap $cap --out E9_cap$cap > logs/E9_cap$cap.run.log 2>&1
done
python3 ../fbfull/cpufreq_cap.py restore > logs/E9_restore.txt 2>&1
echo ALL_DONE > logs/chain_energy.done
