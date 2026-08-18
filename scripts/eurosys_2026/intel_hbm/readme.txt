


facts:

1. hbm bandwidth test.
using different prefetch inst results in different memory bandwidth.
- t0 350gb/s
- t1 400gb/s


2. prefetchT1 stalls cpu if continously issued at 16.

for fact 2, explanation is prefetcht1 allocate lfb, and stalls, then
by lfb model math and the above fact, you can only increase
throughput if we increase lfb size or reduce memory latency.

if lfb size have increased due to prefetchT1, then how are we wil bottlneck at some higher number for prefetchT1.
so the only explanation is that prefetchT1 reduces latency by 30 cycles. This is
a little too high....

3. hyperthreading increases bandwidth

If we believe hyperthreads does not increase lfb size, then why does it increase system bandwidth.

l1d_pend_miss.fb_full
l1d.replacement
l1d_pend_miss.pending
l1d_pend_miss.pending_cycles
  l1d.replacement
       [Counts the number of cache lines replaced in L1 data cache]
  l1d_pend_miss.fb_full
       [Number of cycles a demand request has waited due to L1D Fill Buffer (FB) unavailability]
  l1d_pend_miss.fb_full_periods
       [Number of phases a demand request has waited due to L1D Fill Buffer (FB) unavailability]
  l1d_pend_miss.l2_stalls
       [Number of cycles a demand request has waited due to L1D due to lack of L2 resources]
  l1d_pend_miss.pending
       [Number of L1D misses that are outstanding]
  l1d_pend_miss.pending_cycles
       [Cycles with L1D load Misses outstanding]
  l2_rqsts.all_demand_miss
       [Demand requests that miss L2 cache]
  l2_rqsts.all_demand_references
       [Demand requests to L2 cache]
  l2_rqsts.swpf_hit
       [SW prefetch requests that hit L2 cache]
  l2_rqsts.swpf_miss
       [SW prefetch requests that miss L2 cache]
  mem_load_retired.l1_hit
       [Retired load instructions with L1 cache hits as data sources Supports address when precise (Precise event)]
  mem_load_retired.l1_miss
       [Retired load instructions missed L1 cache as data sources Supports address when precise (Precise event)]
  mem_load_retired.l2_hit
       [Retired load instructions with L2 cache hits as data sources Supports address when precise (Precise event)]
  mem_load_retired.l2_miss
       [Retired load instructions missed L2 cache as data sources Supports address when precise (Precise event)]
  sw_prefetch_access.t0
       [Number of PREFETCHT0 instructions executed]
  sw_prefetch_access.t1_t2
       [Number of PREFETCHT1 or PREFETCHT2 instructions executed]



Configuration: Binding, Random

PrefetchT1
prefetch test.
single thread:
./prefetch_test_rand_bind 3 100000000 1 2
  Cycles/Op:    16.79
hyperthread:
./prefetch_test_rand_bind 3 100000000 2 2
  Cycles/Op:    22.48

Throughput test:
No hyperthreading:
./benchmark_rand -m 128m -pattern "n0a2t32" -inst t0
    Average cycle per operation: 18.27 cycles/op
    Predicted peak banwidth: 364.22 GB/s
With hyperthreading:
./benchmark_rand -m 128m -pattern "n0a2t64" -inst t1
    Average cycle per operation: 28.59 cycles/op
    peak banwidth: 465.64 GB/s


PrefetchT0
prefetch test
single thread:
./prefetch_test_rand_bind 2 100000000 1 2
  Cycles/Op:    16.72
hyperthread:
./prefetch_test_rand_bind 2 100000000 2 2
  Cycles/Op:    27.00

Throughput test

No Hyperthreading:
./benchmark_rand -m 128m -pattern "n0a2t32" -inst t0
    Average cycle per operation: 18.55 cycles/op
    Predicted peak banwidth: 358.76 GB/s
With hyperthreading:
./benchmark_rand -m 128m -pattern "n0a2t64" -inst t0
    Average cycle per operation: 33.65 cycles/op
    Predicted peak banwidth: 395.58 GB/s
