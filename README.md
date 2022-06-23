# KVStore
[![Build and Test](https://github.com/mars-research/kmer-counting-hash-table/actions/workflows/build.yml/badge.svg)](https://github.com/mars-research/kmer-counting-hash-table/actions/workflows/build.yml)

## Build

### Download the source
```
git clone git@github.com:mars-research/kmer-counting-hash-table.git --recursive
cd kmer-counting-hash-table
```

### Install dependencies

#### Optional 1(recommended): Nix shell.
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

### Setup the machine

#### Option 1(recommended): Express setup 
- Apply constant frequency, enable hugepages, and disable hardware prefetching.
```
./scripts/setup.sh
```

#### Option 2: Maunal setup

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

### Build
* Setup build directory
```
cmake -S . -B build
```

* Build
```
cmake --build build/
```

### Run
```
./build/kmercounter
```

### Test
Run all tests.
```
ctest --test-dir=build
```

Run individual test binary. For example, the hashmap test:
```
./build/unittests/hashmap_test
```
