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
make PAPI=yes
# require sudo to monitor performance counters
sudo ./kmercounter
```
