#!/bin/bash
set -e
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir/../pcm" || exit
cmake -S . -B ./build
cmake --build ./build --parallel
