`lscpu`:
```
...
CPU(s):                             128
On-line CPU(s) list:                0-127
Thread(s) per core:                 2
Core(s) per socket:                 32
Socket(s):                          2
NUMA node(s):                       2
Vendor ID:                          GenuineIntel
CPU family:                         6
Model:                              207
Model name:                         INTEL(R) XEON(R) GOLD 6548Y+
Stepping:                           2
CPU MHz:                            2500.000
CPU max MHz:                        4100.0000
CPU min MHz:                        800.0000
BogoMIPS:                           5000.00
Virtualization:                     VT-x
L1d cache:                          3 MiB
L1i cache:                          2 MiB
L2 cache:                           128 MiB
L3 cache:                           120 MiB
NUMA node0 CPU(s):                  0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,120,122,124,126
NUMA node1 CPU(s):                  1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47,49,51,53,55,57,59,61,63,65,67,69,71,73,75,77,79,81,83,85,87,89,91,93,95,97,99,101,103,105,107,109,111,113,115,117,119,121,123,125,127
```
vendor link: https://www.intel.com/content/www/us/en/products/sku/237564/intel-xeon-gold-6548y-processor-60m-cache-2-50-ghz/specifications.html

`dram info`: sudo dmidecode --type 17
```
        Size: 16384 MB
        ...
        Speed: 5600 MT/s
        ...
        Configured Memory Speed: 5200 MT/s
```
memory type: ddr5 5200 MT/s

Cloudlab info : https://www.utah.cloudlab.us/portal/show-node.php?node_id=flex13&_gl=1*1kw662c*_ga*MTA5NDg2MTc0My4xNzI4NjA3MTU2*_ga_6W2Y02FJX6*czE3NDk1MDg0NzIkbzMzMyRnMSR0MTc0OTUxMTEzMCRqNTIkbDAkaDA.
```
hw_mem_size 	262144
```
sudo dmidecode --type 17 | grep 'Speed: 5600 MT/s' |wc
     16      48     288
 262144/16384 = 16

8 memory channels per socket, so all channels populated

>5200 MT/s * 8 bytes (64 bit bus width)
41600

> 41600 * 8 (channels per socket)
332800

since requests are per cacheline, and a cacheline is 64 bytes. Also convert from MT
>(332800 * 10**6)/64
5_200_000_000 cachelines per second needed to saturate 1 socket

To achieve this with 64 threads at 2.5Ghz
> (64* (2.5*10**9) )/5_200_000_000
30.76923076923077 


likewise for 2 sockets, 
> 41600 * 16 (our mem channels double)
665600
> (665600 *10**6) / 64
10_400_000_000
>(128* (2.5*10**9) )/10_400_000_000
30.76923076923077

*In conclusion around 31 cycles are needed to saturate theoretical bandwidth on 1 socket*

mlc random read and huge pages
> sudo ./tools/mlc/mlc --bandwidth_matrix -h -U
                Numa node
Numa node            0       1
       0        251892.1        120674.2
       1        122146.0        249701.9
mlc random huge pages sequential
> sudo ./tools/mlc/mlc --bandwidth_matrix -h
                Numa node
Numa node            0       1
       0        258759.4        121034.4
       1        121826.0        256925.2
 
convert random read mlc to bytes
> 251892.1(mb/s) * 10**6
251892100000
convert to cachelines:
> 251892100000/64
3_935_814_062.5

so to saturate 1 socket
> (64* (2.5*10**9) )/3_935_814_062.5
40.65232692887153
