#!/usr/bin/env bash

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

pushd ${PARENT_PATH}/../tools/msr-safe
make
sudo insmod msr-safe.ko
echo "Chowning /dev/cpu/*/msr_safe to ${USER}:${GROUP}"
sudo chown ${USER}:${GROUP} /dev/cpu/*/msr_safe

# install allowlist for hwpref
cat allowlists/dramhit | sudo tee /dev/cpu/msr_allowlist

popd
