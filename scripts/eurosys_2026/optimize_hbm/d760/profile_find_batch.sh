#!/usr/bin/env bash
# Share of find-phase cycles spent in CASHashTable::find_batch (vs the harness: key stream, loop, etc.).
# perf record of the same command as run_ground_truth.py; the report is restricted to the steady find
# phase = [first find_batch sample + 0.5 s, last find_batch sample - 0.5 s].
#   ./profile_find_batch.sh 10 70
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HERE/prof"
for F in "${@:-10 70}"; do
  P="$HERE/prof/f$F"
  CMD=$(cd "$HERE" && python3 -c "import run_ground_truth as r; print(r.dramhit_cmd($F))")
  sudo perf record -q -F 999 -e cycles -o "$P.data" -- $CMD > "$P.run.txt" 2>&1
  sudo chown "$USER" "$P.data"
  grep -q "find_ops : \([0-9]*\), found : \1" "$P.run.txt" || { echo "found != find_ops"; exit 1; }
  read T0 T1 < <(perf script -i "$P.data" -F time,ip,sym 2>/dev/null | awk '/::find_batch/ {t=$1; sub(":","",t); if(!a) a=t; b=t} END {printf "%.6f %.6f\n", a+0.5, b-0.5}')
  echo "fill $F: find window $T0 .. $T1"
  perf report -i "$P.data" --time "$T0,$T1" --no-children --sort sym --stdio 2>/dev/null \
    | grep -v "^#" | grep -v "^$" | sed -n 1,15p | tee "$P.sym.txt"
done
