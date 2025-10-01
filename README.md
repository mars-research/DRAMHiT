# DRAMHiT

## Build

### Download the source
```
git clone git@github.com:mars-research/DRAMHiT.git --recursive
```

### Install dependencies

Install nix
```
curl -L https://nixos.org/nix/install | sh
```

Setup direnv (recommended for development)
```
sudo apt install direnv
echo 'eval "$(direnv hook bash)"' >>"$HOME_DIR/.bashrc"
```

or alternatively, use 
```
nix develop --extra-experimental-features nix-command --extra-experimental-features flakes
```
command to manually enter nix development shell

### Setup the machine
```
./scripts/setup.sh
```

### Build
* Build
```
cmake -S . -B build 
cmake --build build/
```

### Configure build with ccmake (optional)

On command line, install and start ccmake. 

```
sudo apt install cmake-curses-gui
ccmake ./build
```


