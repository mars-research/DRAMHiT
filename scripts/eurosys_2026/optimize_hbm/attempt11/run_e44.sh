#!/usr/bin/env bash
# E44: dynamic analysis of the deep insert (attempt11/dvi_hs24) vs dvs_p3, insert phase, q128 / b16, fill 10.
# Every core counter set (one per run, no multiplexing), 2 interleaved reps, then a perf record of dvi_hs24.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE/../bwgap"
W="a22_dvs_p3_q128_b16_f10 a22_dvi_hs24_q128_b16_f10"
for s in td ports_a ports_b stall fb br; do
  python3 run_stream.py --reps 2 --interval-ms 100 --workloads $W --core-set $s --out E44_ctr/$s
done
CMD=$(python3 -c "import run_stream as s; print(s.WORKLOADS['a22_dvi_hs24_q128_b16_f10']())")
P="$HERE/prof/dvi_hs24"
sudo perf record -q -F 1000 -e cycles:upp -o "$P.data" -- $CMD > "$P.run.txt" 2>&1
sudo chown "$USER" "$P.data"
grep -q "find_ops : \([0-9]*\), found : \1" "$P.run.txt" || { echo "found != find_ops"; exit 1; }
perf report -i "$P.data" --no-children --sort sym --stdio 2>/dev/null | grep -v "^#" | grep -v "^$" | head -15 > "$P"_sym.txt
echo E44_DONE
