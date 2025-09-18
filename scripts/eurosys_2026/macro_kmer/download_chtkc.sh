#!/bin/bash

set -eo pipefail

MOUNT_DIR=/opt

clone_chtkc() {
  if [ ! -d ${MOUNT_DIR}/chtkc ]; then
    echo "Cloning chtkc..."
    pushd ${MOUNT_DIR}
    git clone https://github.com/mars-research/chtkc.git --branch kmer-eval
    popd;
  else
    echo "chtkc dir not empty! skipping..."
  fi
}
build_chtkc() {
  if [ -d ${MOUNT_DIR}/chtkc ]; then
    pushd ${MOUNT_DIR}/chtkc
    mkdir build
    cd build
    cmake ..
    make
    popd;
  else
    echo "chtkc dir doesn't exist, skipping..."
  fi
}

clone_chtkc;
build_chtkc;