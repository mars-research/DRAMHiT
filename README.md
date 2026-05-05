# DRAMHiT
[![Build and Test](https://github.com/mars-research/DRAMHiT/actions/workflows/build.yml/badge.svg)](https://github.com/mars-research/kmer-counting-hash-table/actions/workflows/build.yml)

### Get Source
```
git clone git@github.com:mars-research/DRAMHiT.git --recursive
```

### Dependencies

Nix manages all project dependencies.
Install nix if your system doesn't have nix
```bash
curl -L https://nixos.org/nix/install | sh
```

Use following script to enter nix development shell
```bash
./nix-dev-shell.sh
```

### Setup the machine

#### Option 1(recommended): Express setup 
- Apply constant frequency, enable hugepages, and disable hardware prefetching.
```
./scripts/setup.sh
```

You alternatively can do similar for amd machine
```
./scripts/setup_amd.sh
```
### Config build
* Setup build directory
```
cmake -S . -B build 
```

Note that above command will not set up build unless 
you provide -DCPUFREQ_MHZ=XXXX

This is the constant frequency of the cpu pinned by 
setup scripts.

### Build
```
cmake --build build/
```

### Configure build with ccmake (optional)

This is cmd line gui tool you can use to see all 
build time configuration if you don't want to 
use standard cmake ways -DVAR.

On command line, install and start ccmake

```
sudo apt install cmake-curses-gui
ccmake ./build
```

### Run
```
./build/dramhit --help
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
