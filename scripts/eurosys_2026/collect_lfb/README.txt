### batch_test

Issue batch amount of memory operations and collect duration of the loop.
By subtracting duration of batch sz n over batch sz n-1, you can approximate the cycle it took to issue nth operation.
Or alternative by divide avg by batch sz , you get cycle per operation.

Build:

gcc batch_test.c -O1 -mcrc32 -o batch_test

Run:

./batch_test -h

### prefetch_test

Issue a large amount of operations, best used to couple it with some perf counters. This
allows us to estimate LFB/MAB size by directing interpreting perf counter. This program
also is capable of using hyperthreading, so we can gurantee lfb or mab is fully utilized
by the cpu.

To build:

gcc -O3 -mavx512f -pthread prefetch_test.c -o prefetch_test

To run, suggested operation number 1,000,000,000

perf stat -I1000 -e ls_alloc_mab_count -e ls_mab_alloc.all_allocations -e cycles ./prefetch_test <inst-type> <num-operations> <threads>

Note when interpreting counter, note that cycles is aggregated, so hyperthreading needs to divide this by 2.



- From experimental data, we know prefetch to l2 for sure allocate a slot for ls_mab_alloc.

Now the question is that why prefetch to l2 is so helpful in terms of performance improvement.

ls_mab_alloc.all_allocations should be higher because the actually memory access needs to miss l1
for prefetch to l2 instruction.

so prefetch to l2, allocate a slot for ls_mab_alloc, but it does not actually
trigger memory operation, cpu seems to know some way that the cacheline being prefetched
are not used .....

This seems a bit magical. Why ?


We can confirm prefetch to l2 is dropped for non binding operations.

`ls_any_fills_from_sys.all` counter shows number of request filled in cache (actual memory requests).
`ls_mab_alloc.all_allocations` counter shows number of mab entry are allocated.


the data should show following

none bind to bind for prefetch l2, bandwidth drop.
none bind to bind for prefetch l1, no drop.

prefetch l2 bind data, prefetch inst should be half of mab allocation as, read inst causes mab to be allocated, but hit l2.
prefetch l1 bind data, prefetch inst should be the same as mab allocation.
