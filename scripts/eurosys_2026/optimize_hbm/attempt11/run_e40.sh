#!/usr/bin/env bash
# E40: hyperthreading. Phase 1: siblings online (idle ones spin in the POLL idle loop). Phase 2: node-0 siblings
# (cpus 64..126 even) offline = true one thread per core; restored (online, 2.7 GHz, prefetchers off) on exit.
# Core events in user mode only (--cpus user), so the kernel poll loop is not counted.
set -euo pipefail
cd "$(dirname "$0")/../bwgap"
SIB=$(seq 64 2 126)
restore() {
  for c in $SIB; do echo 1 | sudo tee /sys/devices/system/cpu/cpu$c/online >/dev/null; done
  for c in $SIB; do
    echo 2700000 | sudo tee /sys/devices/system/cpu/cpu$c/cpufreq/scaling_max_freq >/dev/null
    echo 2700000 | sudo tee /sys/devices/system/cpu/cpu$c/cpufreq/scaling_min_freq >/dev/null
    sudo env PATH="$PATH" wrmsr -p $c 0x1a4 0x2f
  done
  echo "[restore] online: $(cat /sys/devices/system/cpu/online); 0x1a4: $(sudo env PATH="$PATH" rdmsr -a 0x1a4 | sort | uniq -c | tr -s ' ')"
}
SETS="base fb td"
P1="bw_t1 bw_t1_t32 bw_t1_t32_la128 a20_t64_q128_f10 a20_t32_q128_f10 a20_t32_q256_f10 a20_t64_q128_f90 a20_t32_q128_f90 a20_t32_q256_f90"
P2="bw_t1_t32 bw_t1_t32_la128 a20_t32_q128_f10 a20_t32_q256_f10 a20_t32_q128_f90 a20_t32_q256_f90"
if [[ "${PHASE:-12}" == *1* ]]; then
  for s in $SETS; do
    cs=$([ $s = base ] && echo "" || echo "--core-set $s")
    python3 run_stream.py --reps 2 --cpus user $cs --workloads $P1 --out E40_ht/online_$s
  done
fi
if [[ "${PHASE:-12}" == *2* ]]; then
  trap restore EXIT
  for c in $SIB; do echo 0 | sudo tee /sys/devices/system/cpu/cpu$c/online >/dev/null; done
  echo "[offline] online cpus: $(cat /sys/devices/system/cpu/online)"
  for s in $SETS; do
    cs=$([ $s = base ] && echo "" || echo "--core-set $s")
    python3 run_stream.py --reps 2 --cpus user $cs --workloads $P2 --out E40_ht/offline_$s
  done
fi
echo E40_DONE
