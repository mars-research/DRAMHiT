#!/bin/bash

USER=${SUDO_USER}

if [[ ${USER} == "" ]]; then
  USER=$(id -u -n)
fi

if [[ ${SUDO_GID} == "" ]]; then
  GROUP=$(id -g -n)
else
  GROUP=$(getent group  | grep ${SUDO_GID} | cut -d':' -f1)
fi

echo ${USER}:${GROUP}
sudo rmmod msr-safe
pushd ../tools/msr-safe
make clean && make && \
sudo insmod msr-safe.ko && \
sudo sh -c "cat allowlists/al_kvstore > /dev/cpu/msr_allowlist" && \
sudo chown ${USER}:${GROUP} /dev/cpu/*/msr_safe
popd
