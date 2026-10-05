#!/usr/bin/env bash
# Print everything about the machine and the software that can change the numbers in
# report-bwgap.md. Run before and after a measurement session:
#
#   bwgap/env_snapshot.sh > bwgap/logs/env_<label>.txt
#
# It only reads state (the one exception is `sleep 2` while sampling idle package power).
# Needs sudo for the MSR reads; msr-tools (rdmsr) must be on PATH.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../../../.." && pwd)
OPT="$REPO/scripts/eurosys_2026/optimize_hbm"
rd() { sudo env PATH="$PATH" rdmsr -p "$1" -c "$2" 2>/dev/null || echo "n/a"; }
hr() { printf '\n== %s\n' "$1"; }

hr "when / where"
date -u +"%Y-%m-%dT%H:%M:%SZ"; hostname; uname -srvm
hr "cpu"
lscpu | grep -E "Model name|^CPU\(s\)|Thread|Core|Socket|NUMA node|L1d|L2|L3|MHz"
hr "numa"
numactl -H | head -14
hr "software"
perf --version; gcc --version | head -1; python3 --version; cmake --version | head -1
hr "kernel cmdline / thp"
cat /proc/cmdline
echo "thp enabled: $(cat /sys/kernel/mm/transparent_hugepage/enabled)"
hr "cpufreq (node 0 cpus are the benchmark cpus)"
for c in 0 2 64 1; do
  d=/sys/devices/system/cpu/cpu$c/cpufreq
  echo "cpu$c: driver $(cat $d/scaling_driver) governor $(cat $d/scaling_governor) epp $(cat $d/energy_performance_preference 2>/dev/null) min $(cat $d/scaling_min_freq) max $(cat $d/scaling_max_freq) kHz"
done
echo "no_turbo: $(cat /sys/devices/system/cpu/intel_pstate/no_turbo)  pstate status: $(cat /sys/devices/system/cpu/intel_pstate/status)"
echo "cpuidle states disabled (cpu0): $(for s in /sys/devices/system/cpu/cpu0/cpuidle/state*; do echo -n "$(cat $s/name)=$(cat $s/disable) "; done)"
hr "uncore frequency limits (sysfs) and MSRs"
for d in /sys/devices/system/cpu/intel_uncore_frequency/package_*; do echo "$(basename $d): min $(cat $d/min_freq_khz) max $(cat $d/max_freq_khz) kHz"; done
echo "MSR 0x620 uncore ratio limit (cpu0/cpu1): $(rd 0 0x620) / $(rd 1 0x620)"
echo "MSR 0x621 uncore ratio now  (cpu0/cpu1): $(rd 0 0x621) / $(rd 1 0x621)"
hr "hardware prefetchers and power limits"
echo "MSR 0x1a4 (0x2f = all controllable prefetchers off): $(rd 0 0x1a4)"
echo "MSR 0x610 package power limit (stock 0x878d2000158af0): $(rd 0 0x610)"
for z in /sys/class/powercap/intel-rapl:0 /sys/class/powercap/intel-rapl:2; do
  echo "$(basename $z) $(cat $z/name): PL1 $(( $(cat $z/constraint_0_power_limit_uw) / 1000000 )) W, PL2 $(( $(cat $z/constraint_1_power_limit_uw) / 1000000 )) W"
done
hr "thermal"
m=$(sudo env PATH="$PATH" rdmsr -p 0 -f 22:16 -d 0x1b1 2>/dev/null); echo "package margin to TjMax: ${m} C (TjMax 100 C)"
hr "hugepages (kB pages count per node)"
for n in 0 1 2 3; do for sz in 1048576kB 2048kB; do
  echo "node$n ${sz}: $(cat /sys/devices/system/node/node$n/hugepages/hugepages-$sz/nr_hugepages) (free $(cat /sys/devices/system/node/node$n/hugepages/hugepages-$sz/free_hugepages))"; done; done
hr "idle package power, socket 0 and 1 (2 s of perf stat)"
sudo perf stat -a --per-socket -x, -e power/energy-pkg/ -- sleep 2 2>&1 | awk -F, '{printf "%s: %.1f W\n", $1, $3/2}'
hr "other load on the machine"
uptime; ps -eo pcpu,comm --sort=-pcpu | head -4
hr "repo"
cd "$REPO" && git rev-parse HEAD && git log -1 --format='%h %s' && echo "branch: $(git rev-parse --abbrev-ref HEAD)"
echo "--- uncommitted changes (stat) in the files that matter:"
git diff --stat -- include/hashtables/cas_kht.hpp CMakeLists.txt src/tests/zipfian_test.cpp scripts/eurosys_2026/machine_stats/bandwidth.c | tail -6
hr "binaries (md5)"
md5sum "$OPT/attempt4/rck/dramhit" "$OPT"/bwgap/bin/bandwidth_rand_it* 2>/dev/null
