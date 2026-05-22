#!/usr/bin/env bash
# Assign arguments to variables with defaults
# If $1 is empty, use 25000; if $2 is empty, use 100
NUM_2MB_PAGES_PERNODE=${2:-40000}
NUM_1GB_PAGES_PERNODE=${1:-32}

# Output the values to confirm
echo "NUM_2MB_PAGES_PERNODE set to: $NUM_2MB_PAGES_PERNODE"
echo "NUM_1GB_PAGES_PERNODE set to: $NUM_1GB_PAGES_PERNODE"

# Enable 2MB pages
echo always | sudo tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null
echo always | sudo tee /sys/kernel/mm/transparent_hugepage/defrag  > /dev/null

# NEW: Drop caches and compact memory to fight fragmentation before allocating
echo "Compacting memory to help allocate contiguous hugepages..."
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
echo 1 | sudo tee /proc/sys/vm/compact_memory > /dev/null

NODE_START=$(cat /sys/devices/system/node/online | cut -d'-' -f1)
NODE_END=$(cat /sys/devices/system/node/online | cut -d'-' -f2)

# Reserve hugepages
for n in $(seq ${NODE_START} ${NODE_END}); do
  echo "Reserving hugepages for node ${n}..."
  echo ${NUM_1GB_PAGES_PERNODE} | sudo tee "/sys/devices/system/node/node${n}/hugepages/hugepages-1048576kB/nr_hugepages" > /dev/null
  echo ${NUM_2MB_PAGES_PERNODE} | sudo tee "/sys/devices/system/node/node${n}/hugepages/hugepages-2048kB/nr_hugepages" > /dev/null
done

MOUNT_POINT="/mnt/huge"

if [ ! -d ${MOUNT_POINT} ]; then
  sudo mkdir -p ${MOUNT_POINT}
fi

# NEW: Only mount if it isn't already mounted
if ! mountpoint -q ${MOUNT_POINT}; then
  sudo mount -t hugetlbfs nodev ${MOUNT_POINT}
fi

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

# Check how many pages are actually allocated
echo "Reserved memory (System Total):"
echo "2MiB pages: $(cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages)"
echo "1GiB pages: $(cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages)"
