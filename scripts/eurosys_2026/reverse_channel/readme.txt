
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

## amd_channel_probe: per-controller read vs 1r1w

`make amd_channel_probe`. Same address predicate as reversed_amd.c, plus a 1r1w store
mode, a repeating access loop and explicit cpu pinning, so the steady state lasts long
enough for a `perf stat -I` median to land on it. reversed_amd.c measures the whole run,
which includes the one-shot 1 GiB memset+clflush -- that init spreads over every channel
and is why a whole-run perf stat shows traffic everywhere regardless of the predicate.

Two things it establishes that the older probe cannot, both read off the per-box
counters it prints rather than assumed:

  - the predicate does NOT always select one controller. On this machine in NPS4 it
    isolates a single channel on nodes 1 and 2 (umc4, umc7) but straddles two on node 0
    (umc0 and umc2, evenly), because the hugepage lands at a different 12 MB cycle
    offset. Its "UMC 1" label is not what the hardware does here.
  - a single controller, driven by its own node's 16 cpus, tops out at 33.7 GB/s read
    (88% of the 38.4 GB/s channel peak) and 26.0 GB/s of 1r1w traffic (68%) -- the same
    0.77 read/write asymmetry the whole machine shows, so that asymmetry belongs to the
    controller, not to the fabric. See
    ../collect_scalability/local_interleave_analysis.md section 5.

```
sudo perf stat -a -e amd_umc_4/umc_cas_cmd.rd/,amd_umc_4/umc_cas_cmd.wr/ -I 20 -x, -- \
    ./amd_channel_probe -t 16 -m rw -r 300 -n 1
```

# Intel
