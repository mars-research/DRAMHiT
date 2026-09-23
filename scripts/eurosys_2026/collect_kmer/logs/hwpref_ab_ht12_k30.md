# HW prefetchers on vs off -- dramblast-p (ht-type 12), k=30

Intel Xeon Gold 6548Y+, snoop mode, 2.5 GHz pinned, turbo off. Same run shape as
the 18 Sep sweep: `--mode 4 --ht-type 12 --ht-size 2147483648 --find_queue 64
--numa-split 3 --nprod 64 --ncons 64 --insert-factor 1`, hugepage pool already in
the partitioned shape. Data: `hwpref_ab_ht12_k30.csv`.

## How the toggle was done

NOT with `--hw-pref`. That flag is inert in this tree: `Application.cpp:794` is
behind `#ifdef HARDCODE_PREFETCH_H14A`, and that macro is defined nowhere, so
the MSR write never compiles in. The toggle here is `wrmsr -a 0x1a4`:

  * `0x0` -- L2 streamer, L2 adjacent-line, DCU, DCU-IP all ENABLED
  * `0xf` -- all four DISABLED

`rdmsr -a 0x1a4` was read back on all 128 cpus before every run and recorded in
the csv, so each number is attributable to the prefetcher state it actually ran
under rather than to the flag it was passed.

## Result -- blocked arms (the honest comparison)

  prefetchers OFF   n=5  mean 1889.4  sd  8.2   (sweep's own off baseline: 1905.8 sd 10.8)
  prefetchers ON    n=5  mean 2397.2  sd 54.3

  delta +507.8 set_mops = +26.9%
  Welch t = 20.7; exact permutation p = 0.008; complete separation
  (slowest on-run 2304 > fastest off-run 1895)

Turning the hardware prefetchers ON makes dramblast-p ~27% FASTER at k=30.

## Why there are two sets of numbers in the csv

The first pass interleaved the conditions (off,on,off,on,...) to spread any
drift across both arms. That backfired: it put every off-run except the first
immediately after an on-run, and those off-runs came back at 1751 sd 141 --
8% low and 13x noisier than the sweep's 1906 sd 11 for the identical point.
Blocking the runs put them straight back at 1889 sd 8, so the depression was an
after-effect of the preceding on-run (or of the MSR write itself), not a
property of the off condition. The interleaved arm is kept in the csv because it
is what was measured, but the blocked arms are the ones to quote. Reading the
interleaved pass alone would have overstated the effect as +36.9%.

## What this means for the sweep

Every one of the 460 runs in `intel_snoop_full_sweep_summary.csv` was taken with
prefetchers OFF. At least for dramblast-p at k=30, that choice costs ~27%, so
the sweep is not a ceiling for this variant. Whether the other three variants
move the same way, and by how much across k, is NOT measured here -- this is one
point on one ht-type.
