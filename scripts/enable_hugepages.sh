#!/usr/bin/env bash

NUM_2MB_PAGES_PERNODE=2048
NUM_1GB_PAGES_PERNODE=128

# Enable 2MB pages
echo always | sudo tee /sys/kernel/mm/transparent_hugepage/enabled &> /dev/null
echo always | sudo tee /sys/kernel/mm/transparent_hugepage/defrag  &> /dev/null

NODE_START=$(cat /sys/devices/system/node/online | cut -d'-' -f1)
NODE_END=$(cat /sys/devices/system/node/online | cut -d'-' -f2)

# https://www.kernel.org/doc/html/latest/admin-guide/mm/hugetlbpage.html
for n in $(seq ${NODE_START} ${NODE_END}); do
  echo "Reserving hugepages for node ${n}";
  echo ${NUM_2MB_PAGES_PERNODE} | sudo tee "/sys/devices/system/node/node${n}/hugepages/hugepages-2048kB/nr_hugepages" &> /dev/null
  echo ${NUM_1GB_PAGES_PERNODE} | sudo tee "/sys/devices/system/node/node${n}/hugepages/hugepages-1048576kB/nr_hugepages" &> /dev/null
done

MOUNT_POINT="/mnt/huge"

if [ ! -d ${MOUNT_POINT} ]; then
  sudo mkdir -p ${MOUNT_POINT}
fi

sudo mount -t hugetlbfs nodev ${MOUNT_POINT}

USER=${SUDO_USER}

if [[ ${USER} == "" ]]; then
  USER=$(id -u -n)
fi

if [[ ${SUDO_GID} == "" ]]; then
  GROUP=$(id -g -n)
else
  GROUP=$(getent group  | grep ${SUDO_GID} | cut -d':' -f1)
fi

echo "Chowning ${MOUNT_POINT} to ${USER}:${GROUP}"

sudo chown -R ${USER}:${GROUP} /mnt/huge

# Check how many pages are allocated
echo "Reserved memory"
echo "2MiB pages: $(cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages)"
echo "1GiB pages: $(cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages)"
