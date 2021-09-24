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
cd kmer-counting-hash-table
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
- Enable hugepages (both 2MiB and 1GiB)
```
./scripts/enable_hugepages.sh
```
- Disable hardware prefetching
```
./scripts/prefetch_control.sh off
```
- (Optional)Enable/disable hyperthreading
```
./scripts/toggle_hyperthreading.sh
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
