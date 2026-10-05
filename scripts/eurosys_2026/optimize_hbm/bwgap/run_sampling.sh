#!/usr/bin/env bash
# E3 validation: sample retired instructions by address (precise, skid-free `:ppp`) for the
# three programs, one sample per 2,000,003 retired instructions, whole run, all 64 threads.
# The sampled address histogram is used in instr_mix.py to check that every instruction of the
# hot loop executes once per iteration and to weight the memory-dependent / independent split.
set -u
cd "$(dirname "$0")"
mkdir -p logs/E3_sampling
run() {  # name, command
  python3 -c "import runlib; print('margin before', runlib.cooldown())"
  echo "$2" > logs/E3_sampling/$1.cmd
  sudo perf record -e instructions:ppp -c 2000003 -o logs/E3_sampling/$1.data -- $2 > logs/E3_sampling/$1.out 2>&1
  sudo chown "$(id -u):$(id -g)" logs/E3_sampling/$1.data
}
run dramhit_f10 "$(python3 -c "import runlib; print(runlib.dramhit_cmd(fill=10))")"
run bw_t1       "$(python3 -c "import runlib; print(runlib.bw_cmd('t1'))")"
run bw_double24 "$(python3 -c "import runlib; print(runlib.bw_cmd('double', pad=24))")"
echo done
