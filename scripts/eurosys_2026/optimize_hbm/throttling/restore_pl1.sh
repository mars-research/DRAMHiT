#!/usr/bin/env bash
# Put socket 0's PL1 back to the stock 350 W and show MSR 0x610 (stock value on this machine:
# 0x878d2000158af0). Safe to run any time; use it if pl1_check.py is ever interrupted hard.
set -eu
echo 350000000 | sudo tee /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw >/dev/null
echo "constraint_0 = $(( $(cat /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw) / 1000000 )) W"
printf 'MSR 0x610 = 0x%s (stock 0x878d2000158af0)\n' "$(sudo env PATH="$PATH" rdmsr -p 0 -c 0x610)"
