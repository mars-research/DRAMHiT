#!/usr/bin/env bash

# prefetch_control_hbm.sh, not prefetch_control.sh: on this part 0xf leaves a
# prefetcher running (bit 5), which triples the memory traffic of a sequential
# access pattern while still reporting "all prefetchers off". See the header of
# that script for the measurement.
./scripts/enable_msr_safe.sh && \
./scripts/constant_freq.sh 2.7GHZ && \
./scripts/enable_hugepages.sh 8 4096 && \
./scripts/prefetch_control_hbm.sh off
