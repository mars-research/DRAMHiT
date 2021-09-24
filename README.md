# KVStore
[![Build](https://github.com/mars-research/kmer-counting-hash-table/actions/workflows/build.yml/badge.svg)](https://github.com/mars-research/kmer-counting-hash-table/actions/workflows/build.yml)

## Build

### Prerequisites

#### Optional 1: Nix shell(recommended).
If Nix is not installed, install Nix.
```bash
curl -L https://nixos.org/nix/install | sh
```
Use nix shell. 
```bash
nix-shell
```
All the dependencies should be available in the nix shell now.

#### Option 2: Manual installation.
```bash
sudo apt install libnuma-dev libboost-program-options-dev cmake
```
* Getting the source code
```
git clone git@github.com:mars-research/kmer-counting-hash-table.git --recursive
cd git@github.com:mars-research/kmer-counting-hash-table.git 
```
* Setup build directory
```
mkdir build
cd build && cmake ..
```
* Build
```
make -j
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
