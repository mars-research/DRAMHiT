#!/usr/bin/env bash
# E15: why does time per miss rise when instructions are added? Uncore-side (CHA) latency, request mix,
# coherence/writeback traffic, unpinned; then the same workloads with socket-0 mesh pinned to 1.6 GHz.
set -e
cd "$(dirname "$0")"
W="bw_t1 mimic_s2 mimic_s4 a7_base_f10"
for s in lat mix coh; do
  python3 run_stream.py --reps 2 --interval-ms 100 --read-factor 400 --cha-set $s --workloads $W --out E15_cha_$s
done
python3 run_stream.py --reps 3 --interval-ms 100 --read-factor 400 --cha-set lat --mesh 1600 --workloads $W --out E15_mesh1600
cat /sys/devices/system/cpu/intel_uncore_frequency/package_00_die_00/{min,max}_freq_khz
