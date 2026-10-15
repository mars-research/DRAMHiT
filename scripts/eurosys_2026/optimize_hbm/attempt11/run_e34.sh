#!/usr/bin/env bash
# E34: why HBM bandwidth drops at high fill. Deep build (attempt11/dvs), fills 10/50/70/90,
# every core counter set (no multiplexing: one set per run), 2 interleaved reps each.
set -e
cd "$(dirname "$0")/../bwgap"
W="a16_dvs_f10 a16_dvs_f50 a16_dvs_f70 a16_dvs_f90"
python3 run_stream.py --reps 2 --workloads $W --out E34_fill/base
for s in td ports_a ports_b stall fb swpf l2; do
  python3 run_stream.py --reps 2 --workloads $W --core-set $s --out E34_fill/$s
done
echo E34_DONE
