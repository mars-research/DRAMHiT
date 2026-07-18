

reverse engineer amd epyc physical memory address to channel.
result hash function is in reversed_amd.c


With reversed_amd.c, we can show per memory channel is capable around calculated 38gb/s theorical bandwidht indicated by ddr.

```
perf stat -e amd_umc_0/umc_cas_cmd.rd/,amd_umc_1/umc_cas_cmd.rd/,amd_umc_2/umc_cas_cmd.rd/ -I1 -- ./reverse_amd_band 16
```

one should plot this with respect to threads.

This shows that, amd IOD is not designed to fully utilize memory bandwidth.
