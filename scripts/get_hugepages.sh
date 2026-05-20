#!/bin/bash

# ==========================================
# CONFIGURATION
# ==========================================
# Leave 2GB (2097152 KB) per NUMA node for the OS and regular processes.
SAFE_BUFFER_KB=$((2 * 1024 * 1024))
MOUNT_POINT="/mnt/huge"

# Enable THP
echo always | sudo tee /sys/kernel/mm/transparent_hugepage/enabled &> /dev/null
echo always | sudo tee /sys/kernel/mm/transparent_hugepage/defrag  &> /dev/null

# ==========================================
# DYNAMIC ALLOCATION PER NODE
# ==========================================
for node_path in /sys/devices/system/node/node[0-9]*; do
  n=$(basename ${node_path} | sed 's/node//')

  # 1. Get Free memory and CPU count for this specific node
  MEM_FREE_KB=$(awk '/MemFree/ {print $4}' /sys/devices/system/node/node${n}/meminfo)
  NUM_CPUS=$(ls -1d /sys/devices/system/node/node${n}/cpu[0-9]* 2>/dev/null | wc -l)

  if [[ -z "$MEM_FREE_KB" ]]; then
    echo "Could not read memory for node ${n}, skipping."
    continue
  fi

  # 2. Calculate safe target memory pool for hugepages
  if [[ "$MEM_FREE_KB" -gt "$SAFE_BUFFER_KB" ]]; then
    TARGET_KB=$((MEM_FREE_KB - SAFE_BUFFER_KB))
  else
    TARGET_KB=0
  fi

  # 3. Determine 1GB target (1 per CPU, capped by available safe memory)
  MAX_1GB_POSSIBLE=$((TARGET_KB / 1048576))

  if [[ ${NUM_CPUS} -le ${MAX_1GB_POSSIBLE} ]]; then
    TARGET_1GB_PAGES=${NUM_CPUS}
  else
    TARGET_1GB_PAGES=${MAX_1GB_POSSIBLE}
    echo "Warning: Node ${n} only has space for ${MAX_1GB_POSSIBLE} x 1GB pages (requested ${NUM_CPUS})."
  fi

  echo "Node ${n} (CPUs: ${NUM_CPUS} | Free Mem: $((MEM_FREE_KB / 1024)) MB)"
  echo " -> Attempting to reserve ${TARGET_1GB_PAGES} x 1GB pages..."
  echo ${TARGET_1GB_PAGES} | sudo tee "/sys/devices/system/node/node${n}/hugepages/hugepages-1048576kB/nr_hugepages" &> /dev/null

  # 4. Check ACTUAL allocated 1GB pages (runtime fragmentation often prevents 1GB allocations)
  ACTUAL_1GB=$(cat "/sys/devices/system/node/node${n}/hugepages/hugepages-1048576kB/nr_hugepages")

  # 5. Calculate remaining space based on what actually allocated, fill rest with 2MB pages
  USED_BY_1GB_KB=$((ACTUAL_1GB * 1048576))
  REM_KB_FOR_2MB=$((TARGET_KB - USED_BY_1GB_KB))
  NUM_2MB_PAGES=$((REM_KB_FOR_2MB / 2048))

  echo " -> Actual 1GB allocated: ${ACTUAL_1GB}. Filling remainder with ${NUM_2MB_PAGES} x 2MB pages..."
  echo ${NUM_2MB_PAGES} | sudo tee "/sys/devices/system/node/node${n}/hugepages/hugepages-2048kB/nr_hugepages" &> /dev/null
  echo "----------------------------------------"
done

# ==========================================
# MOUNT & PERMISSIONS
# ==========================================
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
  GROUP=$(getent group | grep ${SUDO_GID} | cut -d':' -f1)
fi

echo "Chowning ${MOUNT_POINT} to ${USER}:${GROUP}"
sudo chown -R ${USER}:${GROUP} ${MOUNT_POINT}

# ==========================================
# FINAL VERIFICATION
# ==========================================
echo "========================================"
echo "Total Reserved memory across all nodes:"
echo "2MiB pages: $(cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages)"
echo "1GiB pages: $(cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages)"
