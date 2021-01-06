#!/bin/bash

sudo ./scripts/constant_freq.sh
#sudo ./scripts/toggle_hyperthreading.sh
sudo ./scripts/enable_hugepages.sh


#export PAPI_DIR=/users/mdemirev/kmer-counting-hash-table/install
#export PATH=${PAPI_DIR}/bin:$PATH
#export LD_LIBRARY_PATH=${PAPI_DIR}/lib:$LD_LIBRARY_PATH