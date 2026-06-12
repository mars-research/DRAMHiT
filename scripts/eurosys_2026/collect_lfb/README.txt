
### batch_test

Issue batch amount of memory operations and collect duration of the loop.
By subtracting duration of batch sz n over batch sz n-1, you can approximate the cycle it took to issue nth operation.

Build:

gcc batch_test.c -O1 -mcrc32 -o batch_test -D INSTRUCT_TYPE

Run:

./batch_test <min_batch> <max_batch> <sample_size> <output_file_name.csv>


### prefetch_test

Issue a large amount of operations, best used to couple it with some perf counters. This
allows us to estimate LFB/MAB size by directing interpreting perf counter. This program
also is capable of using hyperthreading, so we can gurantee lfb or mab is fully utilized
by the cpu.


To build:

gcc -O3 -mavx512f -pthread prefetch_test.c -o prefetch_test

To run, suggested operation number 1,000,000,000

perf stat -I1000 -e ls_alloc_mab_count -e ls_mab_alloc.all_allocations -e cycles ./prefetch_test <inst-type> <num-operations> <threads>
