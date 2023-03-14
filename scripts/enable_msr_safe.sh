#!/bin/bash

PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

USER=${SUDO_USER}

if [[ ${USER} == "" ]]; then
  USER=$(id -u -n)
fi

if [[ ${SUDO_GID} == "" ]]; then
  GROUP=$(id -g -n)
else
  GROUP=$(getent group  | grep ${SUDO_GID} | cut -d':' -f1)
fi

build_and_install() {
  sudo rmmod msr-safe &> /dev/null
  make clean && make && \
    sudo insmod msr-safe.ko && \
    sudo sh -c "cat allowlists/al_dramhit > /dev/cpu/msr_allowlist"
}

pushd ${PARENT_PATH}/../tools/msr-safe

build_and_install

echo "Chowning /dev/cpu/*/msr_safe to ${USER}:${GROUP}"
sudo chown ${USER}:${GROUP} /dev/cpu/*/msr_safe

popd
