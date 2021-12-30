#!/usr/bin/env bash

sudo ./scripts/constant_freq.sh
 ./scripts/prefetch_control.sh off
sudo ./scripts/enable_hugepages.sh
make clean && make -j
sudo ./scripts/toggle_hyperthreading.sh off
for i in 1 2 4 8 16 32;do ./kmercounter --mode=6 --ht-fill=75 --num-threads ${i} --ht-type=3 |& tee "kmercounter_fig78_casht++_t${i}.log"; done
sudo ./scripts/toggle_hyperthreading.sh
for i in 64;do ./kmercounter --mode=6 --ht-fill=75 --num-threads ${i} --ht-type=3 |& tee "kmercounter_fig78_casht++_t${i}.log"; done
sudo ./scripts/toggle_hyperthreading.sh off
make clean && make -j PREFETCH=no
for i in 1 2 4 8 16 32;do ./kmercounter --mode=6 --ht-fill=75 --num-threads ${i} --ht-type=3 |& tee "kmercounter_fig78_casht_t${i}.log"; done
sudo ./scripts/toggle_hyperthreading.sh
for i in 64;do ./kmercounter --mode=6 --ht-fill=75 --num-threads ${i} --ht-type=3 |& tee "kmercounter_fig78_casht_t${i}.log"; done

