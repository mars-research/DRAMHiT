#!/usr/bin/env bash

# Print usage if no arguments are provided
if [ "$#" -eq 0 ]; then
  echo "Usage: $0 [reset | n<node>_<gb>gb_<mb>mb ...]"
  echo "Example: $0 n0_5gb_100mb n1_0gb_2mb"
  echo "Example: $0 reset"
  exit 1
fi

# ==========================================
# RESET MODE
# ==========================================
if [ "$1" == "reset" ]; then
  echo "Resetting all hugepages to 0 across all nodes..."

  # Loop through all actual node directories to safely handle non-sequential nodes
  for node_path in /sys/devices/system/node/node[0-9]*; do
    if [ -d "$node_path" ]; then
      n=$(basename "$node_path")
      echo "Releasing hugepages on ${n}..."
      echo 0 | sudo tee "$node_path/hugepages/hugepages-1048576kB/nr_hugepages" > /dev/null 2>&1
      echo 0 | sudo tee "$node_path/hugepages/hugepages-2048kB/nr_hugepages" > /dev/null 2>&1
    fi
  done

  echo "Compacting memory..."
  echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
  echo 1 | sudo tee /proc/sys/vm/compact_memory > /dev/null
  echo "Reset complete."
  exit 0
fi

# ==========================================
# ALLOCATION MODE
# ==========================================

# Enable transparent hugepages
echo always | sudo tee /sys/kernel/mm/transparent_hugepage/enabled > /dev/null
echo always | sudo tee /sys/kernel/mm/transparent_hugepage/defrag  > /dev/null

# Drop caches and compact memory to fight fragmentation before allocating
echo "Compacting memory to help allocate contiguous hugepages..."
echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
echo 1 | sudo tee /proc/sys/vm/compact_memory > /dev/null

# Loop through all provided arguments (e.g., n0_5gb_100mb, n1_0gb_2mb)
for arg in "$@"; do
  # Use regex to parse node, gb pages, and mb size
  if [[ $arg =~ ^n([0-9]+)_([0-9]+)gb_([0-9]+)mb$ ]]; then
    node="${BASH_REMATCH[1]}"
    num_1gb_pages="${BASH_REMATCH[2]}"
    total_mb="${BASH_REMATCH[3]}"

    # Calculate number of 2MB pages (Total MB / 2)
    num_2mb_pages=$((total_mb / 2))

    node_path="/sys/devices/system/node/node${node}"

    if [ ! -d "$node_path" ]; then
      echo "Warning: Node $node does not exist ($node_path not found). Skipping."
      continue
    fi

    echo "Node ${node}: Reserving ${num_1gb_pages} 1GB pages, ${num_2mb_pages} 2MB pages..."

    echo ${num_1gb_pages} | sudo tee "${node_path}/hugepages/hugepages-1048576kB/nr_hugepages" > /dev/null
    echo ${num_2mb_pages} | sudo tee "${node_path}/hugepages/hugepages-2048kB/nr_hugepages" > /dev/null
  else
    echo "Warning: Argument '$arg' does not match pattern n<node>_<gb>gb_<mb>mb. Skipping."
  fi
done

# ==========================================
# MOUNT & PERMISSIONS
# ==========================================
MOUNT_POINT="/mnt/huge"

if [ ! -d ${MOUNT_POINT} ]; then
  sudo mkdir -p ${MOUNT_POINT}
fi

# Only mount if it isn't already mounted
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
  # Use awk to safely grab the group name in case of missing matches
  GROUP=$(getent group ${SUDO_GID} | cut -d':' -f1)
  if [[ -z "$GROUP" ]]; then
     GROUP=$(id -g -n)
  fi
fi

echo "Chowning ${MOUNT_POINT} to ${USER}:${GROUP}"
sudo chown -R ${USER}:${GROUP} ${MOUNT_POINT}

# ==========================================
# VERIFICATION
# ==========================================
echo "---------------------------------"
echo "Reserved memory (System Total):"
echo "2MiB pages: $(cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages)"
echo "1GiB pages: $(cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages)"
