Description:

Latency program populated a 1gb array with random indices (so it is a linked list)
Each element is a indices for next accessed cacheline. The sequence is
randomly generated. The goal here is to bypass OOO cpu and hw prefetcher.

Prepare:

1gb hugepages and some amount of 2mb pages
../../enable_hugepages.sh 1 1024

enable constant frequency and turbo.
../../const_freq.sh


Usage: ./latency <mem_numa_node> <cpu_numa_node> <iterations> <loaded: 0|1>

To calulated loaded latency on numa node 0.

./latency 0 0 10 1


## Some data
Intel d760:

idle:
local: 234 cycles per cacheline
remote: 407 cycles per cacheline

loaded:
local: 768 cycles per cacheline
remote: 981 cycles per cahcline


d760-HBM machine:

(idle is same as loaded)
latency:

read:
  364
t0:
  14
t1:
  28

AMD machine:
