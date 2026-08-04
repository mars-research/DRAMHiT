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
