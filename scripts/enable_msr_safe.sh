#!/bin/bash

pushd ../tools/msr-safe
make && \
sudo insmod msr-safe.ko && \
sudo sh -c "cat allowlists/al_kvstore > /dev/cpu/msr_allowlist"
popd
