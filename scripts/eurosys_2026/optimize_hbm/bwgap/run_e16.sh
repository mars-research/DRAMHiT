#!/usr/bin/env bash
# E16: die-to-die fabric (MDF) traffic and congestion, CHA ingress rejects; unpinned clocks
set -e
cd "$(dirname "$0")"
W="bw_t1 mimic_s1 mimic_s2 mimic_s4 a7_base_f10"
for s in mdf_ins mdf_cong chaq; do
  python3 run_stream.py --reps 2 --interval-ms 100 --read-factor 400 --cha-set $s --workloads $W --out E16_$s
done
