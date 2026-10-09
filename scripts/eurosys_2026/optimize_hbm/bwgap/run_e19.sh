#!/usr/bin/env bash
# E19: find key-stream prefetch placement sweep (attempt8 binary), fill 10, keys in HBM
set -e
cd "$(dirname "$0")"
A="a8_base a8_off a8_d32 a8_d64 a8_d128 a8_d256 a8_d64t2 a8_d128t2 a8_b64 a8_b128"
python3 run_stream.py --reps 3 --interval-ms 100 --read-factor 400 --workloads $A --out E19_keypf
python3 run_stream.py --reps 2 --interval-ms 100 --read-factor 400 --core-set swpf --workloads a8_base a8_off a8_d64 a8_d128 a8_b128 --out E19_keypf_swpf
