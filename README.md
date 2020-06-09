# Enable 2MB pages

echo always > /sys/kernel/mm/transparent_hugepage/enabled
echo always > /sys/kernel/mm/transparent_hugepage/defrag

# Enable 1GB pages
https://www.kernel.org/doc/html/latest/admin-guide/mm/hugetlbpage.html

# Dynamically reserve 1GB pages (40GBs on node0)
echo 40 > /sys/devices/system/node/node0/hugepages/hugepages-1048576kB/nr_hugepages
sudo mount -t hugetlbfs nodev /mnt/huge

# Check how many pages are allocated

watch cat /sys/kernel/mm/hugepages/hugepages-1048576kB/*


# Disable hardware prefetcher (on all CPUs)
sudo rdmsr -a 0x1a4
sudo wrmsr -a 0x1a4 0xf

# Disable hardware prefetcher (on core 0)
sudo wrmsr -p 0 0x1a4 0xf

