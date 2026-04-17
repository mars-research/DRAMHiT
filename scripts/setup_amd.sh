#!/usr/bin/env bash

./scripts/enable_msr_safe.sh && \
./scripts/constant_freq_amd.sh 3.25GHZ && \
./scripts/enable_hugepages.sh && \
./scripts/prefetch_control_amd.sh off && \
./scripts/amd-perf-setup.sh
