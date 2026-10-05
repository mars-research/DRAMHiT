#!/usr/bin/env bash
# Profile one dramblast uniform HBM run (64 threads on node 0, table on node 2).
#
#   ./perf_profile.sh <dramhit binary> <fill> <out dir>
#
# Samples cycles, instructions and mispredicted branches at fixed periods, so
# samples * period gives an absolute count for each symbol. find_batch and
# insert_batch are separate symbols (CAS_NO_ABSTRACT=OFF), which separates the
# two phases without phase markers. Writes:
#   <out>/perf.data          raw samples
#   <out>/run.log            dramhit output (mops, find_ops)
#   <out>/report.txt         sample counts per symbol, per event
#   <out>/annotate_{find,insert}_{cycles,misp}.txt
#                            find_batch / insert_batch annotated per event
set -eu
BIN=$1; FILL=$2; OUT=$3
mkdir -p "$OUT"
REPORT_ONLY=${REPORT_ONLY:-0}

CYC_P=10000019
INS_P=10000019
BRM_P=100003

if [ "$REPORT_ONLY" = 0 ]; then
sudo env PATH="$PATH" /opt/DRAMHiT/scripts/prefetch_control_hbm.sh off >/dev/null

sudo perf record -o "$OUT/perf.data" \
  -e cycles/period=$CYC_P/pp,instructions/period=$INS_P/,br_misp_retired.all_branches/period=$BRM_P/pp \
  -- "$BIN" --mode 11 --ht-type 3 --ht-size 536870912 --ht-fill "$FILL" \
  --num-threads 64 --numa-split 10 --np_cpu_node_msk 1 --np_mem_node_msk 4 --np_mem_local 0 \
  --batch-len 16 --find_queue 64 --no-prefetch 0 --hw-pref 0 --insert-factor 100 --read-factor 100 \
  --skew 0.01 --seed 1775762440565610239 > "$OUT/run.log" 2>&1
sudo chown "$(id -u):$(id -g)" "$OUT/perf.data"
fi

report() {  # $1 = out dir; re-runnable on an existing perf.data
  {
    echo "# periods: cycles $CYC_P, instructions $INS_P, br_misp_retired.all_branches $BRM_P"
    grep -E "set_mops|get_mops|find_ops" "$1/run.log" || true
    perf report -i "$1/perf.data" --stdio -n --sort sym --percent-limit 1 2>/dev/null \
      | grep -E "^# Samples|^# Event count|%" || true
  } > "$1/report.txt"
  perf annotate -i "$1/perf.data" --stdio --no-source > "$1/annotate_all.txt" 2>/dev/null || true
  "$(dirname "$0")/split_annotate.py" "$1/annotate_all.txt" "$1"
}
report "$OUT"
echo "done: $OUT"
