#!/usr/bin/env bash
# sudo apt update && sudo apt install msr-tools
./scripts/disable_turbo_msr_amd.sh && \
./scripts/enable_hugepages.sh 8 4092 && \
./scripts/prefetch_control_amd.sh off && \
./scripts/amd-perf-setup.sh
# to check cpu freq: grep "MHz" /proc/cpuinfo
