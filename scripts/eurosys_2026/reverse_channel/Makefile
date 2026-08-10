
mapping_test: mapping_test.c
	gcc -lnuma mapping_test.c -o map

amd_re: reversed_amd.c
	gcc -lnuma reversed_amd.c -o amd_re

intel_re: reversed_intel.c
	gcc -lnuma reversed_intel.c -o intel_re

clean:
	rm -rf map amd_re intel_re
