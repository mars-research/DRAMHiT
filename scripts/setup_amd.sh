#!/usr/bin/env bash
sudo apt update && sudo apt install msr-tools

./scripts/enable_msr_safe.sh && \
./scripts/constant_freq_amd.sh 3.25GHZ && \
./scripts/enable_hugepages.sh 100 25000 && \
./scripts/prefetch_control_amd.sh off && \
./scripts/amd-perf-setup.sh
