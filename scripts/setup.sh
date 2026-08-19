#!/usr/bin/env bash

./scripts/enable_msr_safe.sh && \
./scripts/constant_freq.sh 2.5GHZ && \
./scripts/enable_hugepages.sh 8 4096 && \
./scripts/prefetch_control.sh off &&\
./scripts/vtune.sh
