
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

clean:
	rm -rf map amd_re intel_re imc_probe
