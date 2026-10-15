#!/usr/bin/env bash
# E34 profile: perf record (cycles:upp, PEBS, 1 kHz) of the deep build at fills 10/50/70/90.
# Outputs per fill: prof/dvs_f<f>.data, _sym.txt (symbol shares), _fb.txt (find_batch annotate),
# _regions.txt (find_batch samples binned by code region, see regions_e34.py).
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE/../bwgap"
for f in ${@:-10 50 70 90}; do
  CMD=$(python3 -c "import run_stream as s; print(s.WORKLOADS['a16_dvs_f$f']())")
  P="$HERE/prof/dvs_f$f"
  echo "[prof] fill $f"
  sudo perf record -q -F 1000 -e cycles:upp -o "$P.data" -- $CMD > "$P.run.txt" 2>&1
  sudo chown "$USER" "$P.data"
  grep -q "find_ops : \([0-9]*\), found : \1" "$P.run.txt" || { echo "found != find_ops"; exit 1; }
  perf report -i "$P.data" --no-children --sort sym --stdio 2>/dev/null | grep -v "^#" | grep -v "^$" | head -15 > "$P"_sym.txt
  perf script -i "$P.data" -F ip,sym 2>/dev/null | python3 "$HERE/regions_e34.py" "$HERE/dvs/dramhit" > "$P"_regions.txt
  cat "$P"_regions.txt
done
