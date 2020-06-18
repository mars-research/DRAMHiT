## Build

* Prerequisites
```
sudo apt install libnuma-dev libboost-program-options1.65*
```
* Build
```
make
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
- build papi
```
./scripts/install_papi.sh
make papi
```

* Run
```
./kmercounter
```

* Run with papi
```
make papi
sudo LD_LIBRARY_PATH=/local/devel/kmer-counting-hash-table/papi/src/install/lib ./kmercounter
```

### Memory tests

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

In our machine, only 3 channels are populated per socket, that puts at 115.2 GB/s peak theoretical bandwidth on 240g5.
```
sudo dmidecode -t memory | grep -o "Size"
```
