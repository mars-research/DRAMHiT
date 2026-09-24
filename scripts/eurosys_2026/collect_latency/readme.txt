Description:

Latency program populated a 1gb array with random indices (so it is a linked list)
Each element is a indices for next accessed cacheline. The sequence is
randomly generated. The goal here is to bypass OOO cpu and hw prefetcher.

Prepare:

1gb hugepages and some amount of 2mb pages
../../enable_hugepages.sh 1 1024

enable constant frequency and turbo.
../../const_freq.sh


Usage: ./latency <mem_numa_node> <cpu_numa_node> <iterations> <loaded: 0=idle|1=mem node|2=all nodes>

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
AMD EPYC 9354P (1 socket, 32C/64T, NPS4 -> 4 NUMA nodes, TSC 3.25 GHz)
Collect: ./run_amd.sh   (raw output in amd_results/)
Table:   python3 generate_tex_tbl_amd.py -> tbl-amd-latency.tex

idle:
local:            ~339 cycles per cacheline (~104 ns)
remote, near node: ~367-371 cycles per cacheline (~113 ns)  (0<->1, 2<->3)
remote, far node:  ~377-381 cycles per cacheline (~117 ns)

loaded=2 (all nodes loaded, 62 loaders each hitting its own local memory, ~122 GB/s):
local:             ~621-630 cycles per cacheline (~191-194 ns)
remote, near node: ~683-684 cycles per cacheline (~210 ns)
remote, far node:  ~698-701 cycles per cacheline (~215 ns)

loaded=1 (loaders only on memory node; NOT a fair local vs remote comparison,
remote requests appear to be served ahead of local ones under saturation):
local:  ~635 cycles per cacheline (~195 ns)
remote: ~572-589 cycles per cacheline (~176-181 ns)

mlc --latency_matrix -r (ns, row=cpu node, col=mem node):
       0      1      2      3
0  105.0  113.1  117.7  117.4
1  114.0  105.1  118.4  117.7
2  117.7  117.3  105.1  113.1
3  117.7  117.3  114.0  104.8

mlc --idle_latency: 105.2 ns (341.9 clocks)
mlc --loaded_latency (whole package, read-only): 1600 ns @ 292 GB/s (delay 0),
  ~576 ns @ 292 GB/s (delay 2), 178 ns @ 245 GB/s (delay 100), ~118 ns unloaded
