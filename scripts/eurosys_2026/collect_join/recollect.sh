#!/usr/bin/env bash
#
# Recollect the AMD EPYC 9354P (NPS4) join data.
#
#   ./recollect.sh                          # everything: 5 joins x 2 sweeps
#   ./recollect.sh --build                  # rebuild dramhit first, then everything
#   ./recollect.sh n4_cas                   # just cas, both sweeps
#   ./recollect.sh -- skew                  # every join, skew only
#   ./recollect.sh n4_cas n4_radix -- skew  # those two joins, skew only
#   ./recollect.sh --force                  # redo sets that are already complete
#   ./recollect.sh --reps 3                 # override the spec's reps (5)
#   ./recollect.sh --dry-run                # print budgets + command lines, run nothing
#
# Each (join, sweep) pair is a separate run_join.py process, so the job is
# resumable: a pair whose json already has every point at full reps is skipped
# unless --force. Every pair reserves its own hugepages and sets the hardware
# prefetcher per the spec, so pairs are independent and order does not matter.
#
# Needs passwordless sudo (hugepage reservation + prefetch MSR writes) and the
# nix dev shell for cmake if --build is used.
set -uo pipefail
cd "$(dirname "$0")"

SPEC=amd-9354p.json
DATA_DIR=amd_nps4
ALL_RUNS=(n4_cas n4_cas23 n4_dlht n4_folklore n4_radix)
ALL_PARAMS=(relation_size skew)
LOGDIR=${LOGDIR:-./recollect_logs}

BUILD=0 FORCE=0 DRY="" REPS=""
RUNS=() PARAMS=() seen_sep=0
while [ $# -gt 0 ]; do
  case "$1" in
    --build)   BUILD=1 ;;
    --force)   FORCE=1 ;;
    --dry-run) DRY="--dry-run" ;;
    --reps)    shift; REPS="--reps $1" ;;
    --)        seen_sep=1 ;;
    -h|--help) sed -n '2,30p' "$0"; exit 0 ;;
    *)         if [ "$seen_sep" -eq 0 ]; then RUNS+=("$1"); else PARAMS+=("$1"); fi ;;
  esac
  shift
done
[ "${#RUNS[@]}"   -eq 0 ] && RUNS=("${ALL_RUNS[@]}")
[ "${#PARAMS[@]}" -eq 0 ] && PARAMS=("${ALL_PARAMS[@]}")

mkdir -p "$LOGDIR"

if [ "$BUILD" -eq 1 ]; then
  echo "=== rebuilding dramhit (flags come from $SPEC) ==="
  rm -rf ../../../build
  cmake -S ../../.. -B ../../../build \
    -DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON -DBRANCH=simd \
    -DPREFETCH=DOUBLE -DUNIFORM_PROBING=ON -DGROWT=ON \
    -DCPUFREQ_MHZ=3250 || exit 1
  cmake --build ../../../build -j "$(nproc)" || exit 1
fi

# Is this pair already collected at full reps?
complete() {
  python3 - "$1" "$2" "$SPEC" "$DATA_DIR" <<'PY'
import json, sys, pathlib
run, param, spec_path, data_dir = sys.argv[1:5]
spec = json.loads(pathlib.Path(spec_path).read_text())
want_reps = int(spec.get("reps", 1))
params = dict(spec["params"])
for r in spec["runs"]:
    if r["name"] == run:
        params.update(r.get("params", {}))
want_pts = len(params.get(param, []))
p = pathlib.Path(data_dir) / param / f"{spec['machine']}_{run}_{param}.json"
if not p.exists() or want_pts == 0:
    sys.exit(1)
d = json.loads(p.read_text())
s = d.get("throughput_samples") or []
ok = len(s) == want_pts and all(len(x) >= want_reps for x in s)
sys.exit(0 if ok else 1)
PY
}

SUMMARY=() rc_any=0
for param in "${PARAMS[@]}"; do
  for run in "${RUNS[@]}"; do
    if [ -z "$DRY" ] && [ "$FORCE" -eq 0 ] && complete "$run" "$param"; then
      echo "=== SKIP $run / $param (already complete; --force to redo) ==="
      SUMMARY+=("$run/$param -> skipped (complete)")
      continue
    fi
    log="$LOGDIR/${run}_${param}.log"
    echo "=========================================================="
    echo "=== $run / $param   ($(date '+%H:%M:%S'))   log: $log"
    echo "=========================================================="
    python3 -u run_join.py "$SPEC" --run "$run" --param "$param" $REPS $DRY 2>&1 | tee "$log"
    rc=${PIPESTATUS[0]}
    [ "$rc" -ne 0 ] && rc_any=1
    SUMMARY+=("$run/$param -> rc=$rc")
  done
done

echo; echo "=== SUMMARY ==="
for l in "${SUMMARY[@]}"; do echo "  $l"; done
echo
echo "plot with:  nix develop --command python3 plot_data.py $DATA_DIR"
exit $rc_any
