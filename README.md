Enable 2MB pages

echo always > /sys/kernel/mm/transparent_hugepage/enabled
echo always > /sys/kernel/mm/transparent_hugepage/defrag

Enable 1GB pages
https://www.kernel.org/doc/html/latest/admin-guide/mm/hugetlbpage.html

echo 40 > /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages