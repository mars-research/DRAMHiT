#!/usr/bin/env bash
# The whole measurement session after the first 3 reps of E2 (which were run by
# `python3 run_totals.py --set core --reps 3`). Pool and prefetcher state are NOT touched here
# (see README / report: one 'reserve_hugepages.sh reset; n2_12gb_17408mb n0_0gb_8192mb n1_0gb_8192mb').
set -u
cd "$(dirname "$0")"
python3 run_totals.py --set core --start-rep 4 --reps 5   > logs/E2_core_reps45.run.log 2>&1
python3 run_stream.py --reps 5                            > logs/E1_stream.run.log 2>&1
python3 run_totals.py --set ladder --reps 2               > logs/E4_ladder.run.log 2>&1
./run_sampling.sh                                         > logs/E3_sampling.run.log 2>&1
./env_snapshot.sh                                         > logs/env_end.txt 2>&1
echo ALL_DONE > logs/chain.done
