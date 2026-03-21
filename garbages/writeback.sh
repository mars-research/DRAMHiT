 perf=/usr/bin/perf
 rm a.out
gcc -O1 -pthread -lnuma writeback.c -I/opt/intel/oneapi/vtune/latest/include /opt/intel/oneapi/vtune/latest/lib64/libittnotify.a
 sudo $perf stat -I 1000 -e "unc_m2m_directory_lookup.state_a, unc_m2m_directory_lookup.state_i, unc_m2m_directory_lookup.state_s" -- ./a.out


# gcc -O1 -pthread -lnuma writeback.c -I/opt/intel/oneapi/vtune/latest/include /opt/intel/oneapi/vtune/latest/lib64/libittnotify.a