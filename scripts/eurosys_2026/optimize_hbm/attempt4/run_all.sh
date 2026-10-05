#!/usr/bin/env bash
# Attempt 4: variants interleaved rep-major on one hugepage pool, with energy and mesh clock.
#   attempt4/run_all.sh [reps]
# name:binary:batch_len  (binary relative to attempt3/ or attempt4/)
set -eu
HERE=$(cd "$(dirname "$0")" && pwd)
cd "$HERE/.."
REPS=${1:-3}
CONFIGS="base:attempt3/base:16 rc:attempt4/rc4:16 rck:attempt4/rck:16 rcp:attempt4/rcp:16 rckp:attempt4/rckp:16 rckp_b32:attempt4/rckp:32 rckp_b64:attempt4/rckp:64"
hp=""
for rep in $(seq 1 "$REPS"); do
  for c in $CONFIGS; do
    name=${c%%:*}; rest=${c#*:}; bin=${rest%%:*}; bl=${rest##*:}
    echo "=== rep $rep / $REPS: $name (batch $bl)"
    python3 run_uniform_hbm.py --config baseline --energy --reps 1 --fill 10 --fill 50 --fill 90 \
      --batch-len "$bl" $hp --binary "$PWD/$bin/dramhit" --tag "a4_${name}_r${rep}"
    hp="--no-hugepages"
  done
done
echo "[OK] all runs done"
