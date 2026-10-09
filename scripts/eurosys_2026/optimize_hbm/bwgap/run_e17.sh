#!/usr/bin/env bash
# E17: core-side resources around software prefetches (fill buffers, L2 miss queue stalls, late prefetches,
# store buffer), 64 threads and one-thread-per-core (32); unpinned clocks
set -e
cd "$(dirname "$0")"
W="bw_t1 mimic_s1 mimic_s2 mimic_s3 mimic_s4 a7_base_f10 bw_t1_t32 mimic_s4_t32"
for s in fb swpf stall l2; do
  python3 run_stream.py --reps 2 --interval-ms 100 --read-factor 400 --core-set $s --workloads $W --out E17_$s
done
