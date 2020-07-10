## Build

* Prerequisites
```
sudo apt install libnuma-dev libboost-program-options1.65*
```
* Build
```
make
```
* Build (with -O0)
```
make OPT=no
```

* Before running
- Set all cpus to run at a constant frequency
```
./scripts/constant_freq.sh
```
- Enable/disable hyperthreading based on the configuration you wish to run
```
./scripts/toggle_hyperthreading.sh
```
- Enable hugepages (both 2MiB and 1GiB)
```
./scripts/enable_hugepages.sh
```
- Additionally, if you want to disable hardware prefetching
```
# Disable hardware prefetcher (on all CPUs)
sudo rdmsr -a 0x1a4
sudo wrmsr -a 0x1a4 0xf
# Disable hardware prefetcher (on core 0)
sudo wrmsr -p 0 0x1a4 0xf
```
- Fetch and build papi
```
./scripts/install_papi.sh
```

* Run
```
./kmercounter
```

* Run with papi
```
LD_LIBRARY_PATH=/local/devel/kmer-counting-hash-table/papi/src/install/lib ./kmercounter
```

### Memory tests (c240g5)

* MLC on a single core on node 0
```
sudo mlc --max_bandwidth -m2
```
gives
```
Bandwidths are in MB/sec (1 MB/sec = 1,000,000 Bytes/sec)
Using all the threads from each core if Hyper-threading is enabled
Using traffic with the following read-write ratios
ALL Reads        :      12784.90
3:1 Reads-Writes :      17304.65
2:1 Reads-Writes :      18633.20
1:1 Reads-Writes :      23189.84
Stream-triad like:      12281.78
```
cycles per cacheline (64B)

```
64 / (12.7 / 2.2)
11.08
```
c2420g5 has: https://ark.intel.com/content/www/us/en/ark/products/123550/intel-xeon-silver-4114-processor-13-75m-cache-2-20-ghz.html
This processor supports a maximum of 6 channels of DDR4-2400 memory type.
```
2400 MT/s * 8 (bytes per transaction) * 6 (num channels)
= 115.2 GB/s (Theoretical peak memory bandwidth)
```
On a 2 socket machine the above number should be doubled.

However, in our machine, only 3 channels are populated per socket, that puts at
115.2 GB/s peak theoretical bandwidth on 240g5. `dmidecode` provides all the
information about how DIMM slots are organized.
```
sudo dmidecode -t memory | grep -o "Size"
```
A sample output:

```
Handle 0x004A, DMI type 17, 40 bytes
Memory Device                                 
        Array Handle: 0x0042
        Error Information Handle: Not Provided
        Total Width: 72 bits     
        Data Width: 64 bits 
        Size: 32 GB
        Form Factor: DIMM
        Set: None                            
        Locator: DIMM_J1
        Bank Locator: NODE 1 CHANNEL 2 DIMM 0
        Type: DDR4    
        Type Detail: Synchronous
        Speed: 2666 MT/s      
        Manufacturer: 0x2C00
        Serial Number: 17DBB67C
        Asset Tag: DIMM_J1_AssetTag
        Part Number: 36ASF4G72PZ-2G6D1 
        Rank: 2               
        Configured Clock Speed: 2400 MT/s
        Minimum Voltage: 1.2 V   
        Maximum Voltage: 1.2 V
        Configured Voltage: 1.2 V   
```
From the above output, we infer that a 2R DDR4 DIMM module is plugged onto a
slot in `Node 1, Channel 2, DIMM 0`.

Running `mlc` on all cores gives us:

```
$: ./mlc --max_bandwidth
Intel(R) Memory Latency Checker - v3.8
Command line parameters: --max_bandwidth

Using buffer size of 292.969MiB/thread for reads and an additional 292.969MiB/thread for writes

Measuring Maximum Memory Bandwidths for the system
Will take several minutes to complete as multiple injection rates will be tried to get the best bandwidth
Bandwidths are in MB/sec (1 MB/sec = 1,000,000 Bytes/sec)
Using all the threads from each core if Hyper-threading is enabled
Using traffic with the following read-write ratios
ALL Reads        :      105708.75
3:1 Reads-Writes :      95421.94
2:1 Reads-Writes :      93474.24
1:1 Reads-Writes :      87606.77
Stream-triad like:      93994.61
```

From the above, we can assume that we would achieve half the bandwidth if we
run only on single numa node utilizing 3 memory channels. Let's compute how
many cycles it would take to access a cacheline.

```
Time to access a cacheline (with 6 channels) = 1/(bandwidth / cacheline_size)
1/((87.6 *1e9) / 64)
7.30593607305936e-10

Time to access a cacheline (with 3 channels) = 1/( 0.5 * bandwidth / cacheline_size)
1/((87.6 * 0.5 * 1e9) / 64)
1.461187214611872e-09

Cycles to access a cacheline = Time to access a cacheline / cycle_time
1.46 / (1 / 2.2)
3.2
```

On this machine, it would take us 0.73 nanoseconds to access a cacheline if all
6 channels are in operation and 1.46 ns (or 3.2 cycles) if we use 3 memory channels.

If we use N threads, t0 to tN-1, inorder to saturate the memory controller,
each thread would have to generate a request every (N * cycles to access a
cacheline).

For 10 threads,
```
10 * 3.2
32 cycles
```

In our prefetch test, we first read a cacheline and write it too. In a steady
state, this written cacheline would eventually be written back to memory. This
generates 2 memory transactions (read and a write). If so, every thread would
have to generate a request every (N * 2 * cycles to access a cacheline) to
saturate the memory controller.

```
10 * 3.2 * 2 (two transactions, 1 read + 1 write)
64 cycles
```

From our prefetch test on 10 threads, we see,

```
===============================================================
Thread  0: 1044381060 cycles (474.718678 ms) for 16777216 insertions (62 cycles/insert) { fill: 16777216 of 67108864 (25.000000 %) }
Thread  1: 1047834886 cycles (476.288599 ms) for 16777216 insertions (62 cycles/insert) { fill: 16777216 of 67108864 (25.000000 %) }
Thread  2: 1047092692 cycles (475.951238 ms) for 16777216 insertions (62 cycles/insert) { fill: 16777216 of 67108864 (25.000000 %) }
Thread  3: 1045516784 cycles (475.234916 ms) for 16777216 insertions (62 cycles/insert) { fill: 16777216 of 67108864 (25.000000 %) }
Thread  4: 1042763072 cycles (473.983229 ms) for 16777216 insertions (62 cycles/insert) { fill: 16777216 of 67108864 (25.000000 %) }
Thread  5: 1044608724 cycles (474.822161 ms) for 16777216 insertions (62 cycles/insert) { fill: 16777216 of 67108864 (25.000000 %) }
Thread  6: 1045463722 cycles (475.210797 ms) for 16777216 insertions (62 cycles/insert) { fill: 16777216 of 67108864 (25.000000 %) }
Thread  7: 1045160726 cycles (475.073071 ms) for 16777216 insertions (62 cycles/insert) { fill: 16777216 of 67108864 (25.000000 %) }
Thread  8: 1048397138 cycles (476.544168 ms) for 16777216 insertions (62 cycles/insert) { fill: 16777216 of 67108864 (25.000000 %) }
Thread  9: 1049346762 cycles (476.975815 ms) for 16777216 insertions (62 cycles/insert) { fill: 16777216 of 67108864 (25.000000 %) }
===============================================================
Average  : 1046056556 cycles (475.480267 ms) for 16777216 insertions (62 cycles/insert)
===============================================================
Total  : 10460565566 cycles (4754.802672 ms) for 167772160 insertions
===============================================================
```

To improve the memory bandwidth, we have to choose a machine that has more
number of memory channels. cl6420 on cloudlab Clemson has all 6 channels
populated on both the sockets, thus giving us twice the memory bandwidth of
c240g5.

### Memory tests (cl6420)

* MLC on a single core on node 0
```
sudo mlc --max_bandwidth -m1
```
gives

```
sudo ../mlc/Linux/mlc -m1 --max_bandwidth
Intel(R) Memory Latency Checker - v3.8
Command line parameters: -m1 --max_bandwidth

Using buffer size of 183.105MiB/thread for reads and an additional 183.105MiB/thread for writes

Measuring Maximum Memory Bandwidths for the system
Will take several minutes to complete as multiple injection rates will be tried to get the best bandwidth
Bandwidths are in MB/sec (1 MB/sec = 1,000,000 Bytes/sec)
Using all the threads from each core if Hyper-threading is enabled
Using traffic with the following read-write ratios
ALL Reads        :      10648.99
3:1 Reads-Writes :      15490.19
2:1 Reads-Writes :      16782.59
1:1 Reads-Writes :      18387.13
Stream-triad like:      12107.25

```

cycles per cacheline (64B)

```
cycles per cacheline = bytes_per_cachline * cycles_per_byte
cycles_per_byte = (bytes_per_sec / num_cycles_per_sec)

64/(10.6/2.6)
15.698113207547172
```
cl6420 has: https://ark.intel.com/content/www/us/en/ark/products/120487/intel-xeon-gold-6142-processor-22m-cache-2-60-ghz.html 
This processor supports a maximum of 6 channels of DDR4-2666 memory type.
```
2666 MT/s * 8 (bytes per transaction) * 6 (num channels)
= 127.9 GB/s (Theoretical peak memory bandwidth)
```
On a 2 socket machine the above number should be doubled (255.9 GB/s).

In cl6420 node, all 6 channels are populated per socket, that puts at
255.9 GB/s peak theoretical bandwidth. `dmidecode` provides all the
information about how DIMM slots are organized.
```
sudo dmidecode -t memory | grep -o "Size"
```
A sample output:

```
Handle 0x110D, DMI type 17, 40 bytes
Memory Device
        Array Handle: 0x1000
        Error Information Handle: Not Provided
        Total Width: 72 bits
        Data Width: 64 bits
        Size: 32 GB
        Form Factor: DIMM
        Set: 3
        Locator: B6
        Bank Locator: Not Specified
        Type: DDR4
        Type Detail: Synchronous Registered (Buffered)
        Speed: 2666 MT/s
        Manufacturer: 00AD00B300AD
        Serial Number: 51F9A4D6
        Asset Tag: 01173051
        Part Number: HMA84GR7AFR4N-VK
        Rank: 2
        Configured Clock Speed: 2666 MT/s
        Minimum Voltage: 1.2 V
        Maximum Voltage: 1.2 V
        Configured Voltage: 1.2 V

```
From the above output, we infer that a 2R DDR4 DIMM module is plugged onto one
of the slots.

Running `mlc` on all cores gives us:

```
$: ./mlc --max_bandwidth
Intel(R) Memory Latency Checker - v3.8
Command line parameters: --max_bandwidth

Using buffer size of 183.105MiB/thread for reads and an additional 183.105MiB/thread for writes

Measuring Maximum Memory Bandwidths for the system
Will take several minutes to complete as multiple injection rates will be tried to get the best bandwidth
Bandwidths are in MB/sec (1 MB/sec = 1,000,000 Bytes/sec)
Using all the threads from each core if Hyper-threading is enabled
Using traffic with the following read-write ratios
ALL Reads        :      222193.84
3:1 Reads-Writes :      196230.57
2:1 Reads-Writes :      195072.77
1:1 Reads-Writes :      190857.08
Stream-triad like:      178478.20
```

From the above, we can assume that we would achieve half the bandwidth if we
run only on single numa node utilizing 3 memory channels. Let's compute how
many cycles it would take to access a cacheline.

```
Time to access a cacheline (with 12 channels) = 1/(bandwidth / cacheline_size)
1/((190.8 *1e9) / 64)
3.3542976939203353e-10

Time to access a cacheline (with 6 channels) = 1/( 0.5 * bandwidth / cacheline_size)
1/((190.8 * 0.5 * 1e9) / 64)
6.708595387840671e-10

Cycles to access a cacheline = Time to access a cacheline / cycle_time
0.67 / (1 / 2.6)
1.7
```

On this machine, it would take us 0.33 nanoseconds to access a cacheline if all
12 channels are in operation and 0.67 ns (or 1.7 cycles) if we use 6 memory
channels (i.e., one node).

If we use N threads, t0 to tN-1, inorder to saturate the memory controller,
each thread would have to generate a request every (N * cycles to access a
cacheline).

For 16 threads(in one node),
```
16 * 1.7
27.2 cycles
```

In our prefetch test, we first read a cacheline and write it too. In a steady
state, this written cacheline would eventually be written back to memory. This
generates 2 memory transactions (read and a write). If so, every thread would
have to generate a request every (N * 2 * cycles to access a cacheline) to
saturate the memory controller.

```
16 * 1.7 * 2 (two transactions, 1 read + 1 write)
54.4 cycles
```

From our prefetch test on 16 threads (with both hw and sw prefetchers OFF), we see,

```
NUM inserts 16777216
[INFO] Quick stats: thread 15, Prefetch stride: 64, cycles per insertion:54
[INFO] Quick stats: thread 9, Prefetch stride: 64, cycles per insertion:54
[INFO] Quick stats: thread 6, Prefetch stride: 64, cycles per insertion:54
[INFO] Quick stats: thread 7, Prefetch stride: 64, cycles per insertion:54
[INFO] Quick stats: thread 10, Prefetch stride: 64, cycles per insertion:54
[INFO] Quick stats: thread 2, Prefetch stride: 64, cycles per insertion:54
[INFO] Quick stats: thread 5, Prefetch stride: 64, cycles per insertion:54
[INFO] Quick stats: thread 13, Prefetch stride: 64, cycles per insertion:54
[INFO] Quick stats: thread 4, Prefetch stride: 64, cycles per insertion:54
[INFO] Quick stats: thread 8, Prefetch stride: 64, cycles per insertion:54
[INFO] Quick stats: thread 1, Prefetch stride: 64, cycles per insertion:54
[INFO] Quick stats: thread 12, Prefetch stride: 64, cycles per insertion:54
[INFO] Quick stats: thread 3, Prefetch stride: 64, cycles per insertion:54
[INFO] Quick stats: thread 11, Prefetch stride: 64, cycles per insertion:54
[INFO] Quick stats: thread 0, Prefetch stride: 64, cycles per insertion:54
[INFO] Quick stats: thread 14, Prefetch stride: 64, cycles per insertion:56
=>skx_unc_imc0::UNC_M_CAS_COUNT:RD 44286868
=>skx_unc_imc1::UNC_M_CAS_COUNT:RD 44283996
=>skx_unc_imc2::UNC_M_CAS_COUNT:RD 44280812
=>skx_unc_imc3::UNC_M_CAS_COUNT:RD 44272559
=>skx_unc_imc4::UNC_M_CAS_COUNT:RD 44268849
=>skx_unc_imc5::UNC_M_CAS_COUNT:RD 44265273
--------------------------------------------
TOTAL skx_unc_imc0::UNC_M_CAS_COUNT:RD: 265658357
--------------------------------------------
=>skx_unc_imc0::UNC_M_CAS_COUNT:WR 44267791
=>skx_unc_imc1::UNC_M_CAS_COUNT:WR 44264057
=>skx_unc_imc2::UNC_M_CAS_COUNT:WR 44259917
=>skx_unc_imc3::UNC_M_CAS_COUNT:WR 44253822
=>skx_unc_imc4::UNC_M_CAS_COUNT:WR 44249469
=>skx_unc_imc5::UNC_M_CAS_COUNT:WR 44245554
--------------------------------------------
TOTAL skx_unc_imc0::UNC_M_CAS_COUNT:WR: 265540610
--------------------------------------------
===============================================================
Thread  0: 917915128 cycles (417.234162 ms) for 16777216 insertions (54 cycles/insert)
Thread  1: 916058708 cycles (416.390334 ms) for 16777216 insertions (54 cycles/insert)
Thread  2: 915586180 cycles (416.175549 ms) for 16777216 insertions (54 cycles/insert)
Thread  3: 916361258 cycles (416.527857 ms) for 16777216 insertions (54 cycles/insert)
Thread  4: 915491132 cycles (416.132345 ms) for 16777216 insertions (54 cycles/insert)
Thread  5: 915316820 cycles (416.053112 ms) for 16777216 insertions (54 cycles/insert)
Thread  6: 914274816 cycles (415.579474 ms) for 16777216 insertions (54 cycles/insert)
Thread  7: 914915930 cycles (415.870890 ms) for 16777216 insertions (54 cycles/insert)
Thread  8: 915847370 cycles (416.294271 ms) for 16777216 insertions (54 cycles/insert)
Thread  9: 914089266 cycles (415.495133 ms) for 16777216 insertions (54 cycles/insert)
Thread 10: 915857192 cycles (416.298736 ms) for 16777216 insertions (54 cycles/insert)
Thread 11: 917043202 cycles (416.837832 ms) for 16777216 insertions (54 cycles/insert)
Thread 12: 916455792 cycles (416.570827 ms) for 16777216 insertions (54 cycles/insert)
Thread 13: 914253846 cycles (415.569942 ms) for 16777216 insertions (54 cycles/insert)
Thread 14: 941337176 cycles (427.880547 ms) for 16777216 insertions (56 cycles/insert)
Thread 15: 910853378 cycles (414.024275 ms) for 16777216 insertions (54 cycles/insert)
===============================================================
Average  : 916978574 cycles (416.808455 ms) for 16777216 insertions (54 cycles/insert) (fill = 25 %)
```

### Links
* [Understanding memory bandwidth](https://lenovopress.com/lp0501.pdf)

* [All about memory organization](https://frankdenneman.nl/2015/02/18/memory-tech-primer-memory-subsystem-organization/)

* [Sample FASTQ files](https://figshare.com/articles/MOESM1_of_Gerbil_a_fast_and_memory-efficient_k-mer_counter_with_GPU-support/4806346/1)
