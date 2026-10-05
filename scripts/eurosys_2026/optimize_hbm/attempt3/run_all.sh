#!/usr/bin/env bash
# Attempt 3: every variant on one hugepage pool, interleaved rep-major, with energy.
#
#   attempt3/run_all.sh "base l1 l2 ring cmp" "10 50 90" 3
#
# Results: results/a3_<variant>_r<rep>/a3_<variant>_r<rep>_uniform.json (one rep each;
# summarize.py merges them). The pool is reserved once, before the first run, and
# every later run passes --no-hugepages, so variants are never compared across pools
# (a re-reservation moves results by up to ~7%, see report-throttling.md section 4).
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
cd "$HERE/.."
VARIANTS=${1:-"base l1 l2 ring cmp"}
FILLS=${2:-"10 50 90"}
REPS=${3:-3}
fill_args=""; for f in $FILLS; do fill_args="$fill_args --fill $f"; done

hp="" # first run reserves the pool
for rep in $(seq 1 "$REPS"); do
  for v in $VARIANTS; do
    echo "=== rep $rep / $REPS: $v"
    python3 run_uniform_hbm.py --config baseline --energy --reps 1 $fill_args $hp \
      --binary "$HERE/$v/dramhit" --tag "a3_${v}_r${rep}"
    hp="--no-hugepages"
  done
done
echo "[OK] all runs done"
