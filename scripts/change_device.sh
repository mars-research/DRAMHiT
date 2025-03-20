#!/bin/bash

# README: this script can help when you run out of primary disk space 
# you can point this to any path and create corresponding tmp on your large disk on cloud lab
# for example, /dev/nvme0n1p1 only has 16 GB memory on cloudlab but /dev/nvme0n1p4 has ~700 gigs
# On boot typically /opt/mnt/ is mounted on /dev/nvme0n1p4

# so let us say your home directory is taking up space, check by du utility
# ./this_script <home_dir> /dev/nvme0n1p4 /opt/mnt/backup/
# should make sure the storage on this disk correctly transfered.

# Ensure we have the correct number of arguments
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <old_dir> <new_dev> <tmp_dir>"
  exit 1
fi

# Input arguments
old_dir="$1"
new_dev="$2"
tmp_dir="$3"

# Check if old_dir exists
if [ ! -d "$old_dir" ]; then
  echo "Error: Directory '$old_dir' does not exist."
  exit 1
fi

# Check if tmp_dir exists and is writable
if [ ! -d "$tmp_dir" ] || [ ! -w "$tmp_dir" ]; then
  echo "Error: Temporary directory '$tmp_dir' does not exist or is not writable."
  exit 1
fi

# Check if new_dev is a valid device
if [ ! -b "$new_dev" ]; then
  echo "Error: Device '$new_dev' is not a valid block device."
  exit 1
fi

# Step 1: Backup old_dir to tmp_dir using rsync
echo "Backing up '$old_dir' to '$tmp_dir'..."
rsync -a --progress "$old_dir" "$tmp_dir/"
if [ $? -ne 0 ]; then
  echo "Error: Failed to backup '$old_dir' to '$tmp_dir'."
  exit 1
fi

# Step 2: Remove old_dir
echo "Removing '$old_dir'..."
rm -rf "$old_dir"
if [ $? -ne 0 ]; then
  echo "Error: Failed to remove '$old_dir'."
  exit 1
fi

# Step 3: Create the old_dir again
echo "Recreating '$old_dir'..."
mkdir -p "$old_dir"
if [ $? -ne 0 ]; then
  echo "Error: Failed to recreate '$old_dir'."
  exit 1
fi

# Step 4: Mount the new device to old_dir
echo "Mounting '$new_dev' to '$old_dir'..."
mount "$new_dev" "$old_dir"
if [ $? -ne 0 ]; then
  echo "Error: Failed to mount '$new_dev' to '$old_dir'."
  exit 1
fi

# Step 5: Restore data from tmp_dir to old_dir
echo "Restoring data from '$tmp_dir' to '$old_dir'..."
rsync -a --progress "$tmp_dir/" "$old_dir/"
if [ $? -ne 0 ]; then
  echo "Error: Failed to restore data from '$tmp_dir' to '$old_dir'."
  exit 1
fi

# Step 6: Clean up temporary files
echo "Cleaning up temporary files..."
rm -rf "$tmp_dir"
if [ $? -ne 0 ]; then
  echo "Error: Failed to remove temporary directory '$tmp_dir'."
  exit 1
fi

# Success message
echo "Operation completed successfully. '$old_dir' has been moved to '$new_dev' and data restored."

