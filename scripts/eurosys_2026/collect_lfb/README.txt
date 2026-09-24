Set up machine
## Turn off hw prefetcher

../../prefetch_control.sh off
(Xeon Max / HBM box: sudo env PATH="$PATH" ../../prefetch_control_hbm.sh off)

## Reserve some hugepages

../../enable_hugepages.sh 10 1000

### batch_test

Issue batch amount of memory operations and collect duration of the loop.
By subtracting duration of batch sz n over batch sz n-1, you can approximate the cycle it took to issue nth operation.
Or alternative by divide avg by batch sz , you get cycle per operation.

Modes: 0 load, 1 avx512 load, 2 prefetcht0, 3 prefetcht1, 4 prefetcht2, 5 prefetchnta, 6 prefetchw
-n NODE binds the data array to a numa node.

Build:

gcc batch_test.c -O3 -mcrc32 -lnuma -o batch_test

Run:

./batch_test -h

Scripts:

run_batch_test.py   build, run selected modes, plot
run_intel_hbm.sh    all modes on the HBM box (node 2, cpu 2), writes intel_hbm/batch_<mode>.csv
plot_lfb.py <dir>   plot every csv in <dir>

Data:

amd_batch/    AMD
intel_batch/  Intel d760
intel_hbm/    Intel Xeon Max 9462, data on HBM node 2
