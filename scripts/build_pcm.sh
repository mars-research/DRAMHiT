#!/bin/bash
set -e
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir/../pcm" || exit
cmake -S . -B ./build
cmake --build ./build --parallel

# increase fd limit of the system
ulimit -n 65536         # per process
sudo sysctl -w fs.file-max=2097152   # system-wide