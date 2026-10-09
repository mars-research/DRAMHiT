#!/usr/bin/env bash
# E20: 16 B find-queue entries (attempt9), fill 10, keys in HBM, key prefetch 64 ahead t2
set -e
cd "$(dirname "$0")"
A="a9_base a9_q16 a9_q16x a9_q16v a9_v4"
python3 run_stream.py --reps 3 --interval-ms 100 --read-factor 400 --workloads $A --out E20_q16
python3 run_stream.py --reps 2 --interval-ms 100 --read-factor 400 --core-set stall --workloads $A --out E20_q16_stall
