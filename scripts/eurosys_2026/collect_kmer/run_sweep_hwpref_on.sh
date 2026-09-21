#!/usr/bin/env bash
#
# The k-mer sweep with the hardware prefetchers ON, as a counterpart to the
# prefetchers-off sweep in intel_snoop_full_sweep_summary.csv.
#
# --hw-pref cannot do this. Application.cpp:794 is behind
# HARDCODE_PREFETCH_H14A, which is defined nowhere in the tree, so the flag
# never reaches an MSR. The prefetcher state is therefore set HERE, once, for
# the whole sweep, and held:
#
#   0x1a4 = 0x0   L2 streamer, L2 adjacent-line, DCU, DCU-IP  all ENABLED
#   0x1a4 = 0xf   all four DISABLED   <- the machine's normal state
#
# Because the state lives outside the binary, "were the prefetchers actually on
# for run 312 of 460?" is not answerable from the run's own log. So a sampler
# reads 0x1a4 on all 128 cpus every 2 minutes for the duration and writes it to
# <log-dir>/hwpref_on_msr_samples_<stamp>.log. If anything had flipped the MSR
# mid-sweep -- another user, a stray script -- that file would show it, and the
# affected stretch of runs could be thrown out.
#
# The trap restores 0xf on ANY exit, including a kill: every other measurement
# on this box assumes prefetchers off, so leaving them on would silently
# contaminate whatever ran next.
set -uo pipefail

HERE="$(dirname "$(readlink -f "$0")")"
WRMSR=/nix/store/aaa3g729vj9m40knsaam0cgw3c0pkqi2-msr-tools-1.3/bin/wrmsr
RDMSR=/nix/store/aaa3g729vj9m40knsaam0cgw3c0pkqi2-msr-tools-1.3/bin/rdmsr
STAMP="$(date +%Y%m%d-%H%M%S)"
LOGDIR="${HERE}/logs"
SAMPLES="${LOGDIR}/hwpref_on_msr_samples_${STAMP}.log"
SAMPLER_PID=""

cleanup() {
  [[ -n "$SAMPLER_PID" ]] && kill "$SAMPLER_PID" 2>/dev/null
  echo "[restore] prefetchers -> off (0xf)"
  sudo "$WRMSR" -a 0x1a4 0xf
  echo "[restore] 0x1a4 now: $(sudo "$RDMSR" -a 0x1a4 | sort | uniq -c | tr -s ' ' | tr '\n' ' ')"
}
trap cleanup EXIT INT TERM

echo "[msr] enabling all hardware prefetchers"
sudo "$WRMSR" -a 0x1a4 0x0
seen=$(sudo "$RDMSR" -a 0x1a4 | sort -u | tr -d '\n')
count=$(sudo "$RDMSR" -a 0x1a4 | grep -c '^0$')
echo "[msr] 0x1a4 = 0x${seen} on ${count}/128 cpus"
if [[ "$seen" != "0" || "$count" != "128" ]]; then
  echo "[msr] FAILED to enable on every cpu; aborting rather than collecting a mixed sweep" >&2
  exit 1
fi

( while true; do
    echo "$(date -Is) $(sudo "$RDMSR" -a 0x1a4 | sort | uniq -c | tr -s ' ' | tr '\n' ' ')" >> "$SAMPLES"
    sleep 120
  done ) &
SAMPLER_PID=$!
echo "[msr] sampling 0x1a4 every 120s -> $(basename "$SAMPLES")"

python3 "${HERE}/run_hashtables.py" \
  --ht-types 3 8 1 12 \
  --k $(seq 10 32 | tr '\n' ' ') \
  --repeats 5 \
  --ht-size 2147483648 \
  --num-threads 128 --numa-split-global 1 \
  --nprod 64 --ncons 64 --numa-split-partitioned 3 \
  --no-sudo \
  --csv "${LOGDIR}/intel_snoop_hw_on_full_sweep_summary.csv"
rc=$?

echo "[sweep] run_hashtables.py exited ${rc}"
exit $rc
