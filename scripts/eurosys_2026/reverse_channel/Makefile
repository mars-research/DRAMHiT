
mapping_test: mapping_test.c
	gcc -lnuma mapping_test.c -o map

amd_re: reversed_amd.c
	gcc -lnuma reversed_amd.c -o amd_re

intel_re: reversed_intel.c
	gcc -lnuma reversed_intel.c -o intel_re

# Instrumented generalisation of reversed_intel.c used by verify_hash.py
# and sweep_imc.py: target channel is an argument, threads take an explicit
# cpu list, and the access loop is bracketed by CLOCK_MONOTONIC marks.
imc_probe: imc_probe.c
	gcc -O3 imc_probe.c -lnuma -lpthread -o imc_probe

# Per-controller read / 1r1w probe. reversed_amd.c's predicate plus a repeating
# access loop, a 1r1w store mode and explicit cpu pinning, so a perf -I median
# lands on the steady state instead of the 1GB init that precedes it.
amd_channel_probe: amd_channel_probe.c
	gcc -O3 -mclflushopt -mavx512f amd_channel_probe.c -lnuma -lpthread -o amd_channel_probe

clean:
	rm -rf map amd_re intel_re imc_probe amd_channel_probe
