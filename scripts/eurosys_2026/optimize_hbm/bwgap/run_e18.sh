#!/usr/bin/env bash
# E18: execution-port utilisation per core (both hyperthreads share the ports); 64 threads and 1 per core
set -e
cd "$(dirname "$0")"
for s in ports_a ports_b; do
  python3 run_stream.py --reps 2 --interval-ms 100 --read-factor 400 --core-set $s --workloads bw_t1 mimic_s1 mimic_s2 mimic_s3 mimic_s4 a7_base_f10 --out E18_$s
  python3 run_stream.py --reps 2 --interval-ms 100 --core-set $s --cpus user --workloads bw_t1_t32 mimic_s4_t32 --out E18_$s
done
