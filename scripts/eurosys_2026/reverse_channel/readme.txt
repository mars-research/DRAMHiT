
# Mapping test

To build
```
make mapping_test
```

This allow you to test a list of addresses. 




# AMD

reverse engineer amd epyc physical memory address to channel.
result hash function is in reversed_amd.c

```
make amd_re
```

With reversed_amd.c, we can show per memory channel is capable around calculated 38gb/s theorical bandwidht indicated by ddr.

```
perf stat -e amd_umc_0/umc_cas_cmd.rd/,amd_umc_1/umc_cas_cmd.rd/,amd_umc_2/umc_cas_cmd.rd/ -I1 -- ./reverse_amd_band 16
```

# Intel
