#!/bin/bash

rm -rf build
mkdir -p build
rm dramhit.log
nix-shell --command "cd build && cmake -DAGGR=ON -DBQ_KMER_TEST=ON ../ && make -j $(nproc)"
sudo ./scripts/min-setup.sh
nix-shell --command "./run_test.sh kmer_radix"
