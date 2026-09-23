# Why dramblast-p shows "unstable" points (e.g. k=18)

Short answer: k=18 is not unstable. About 2.8% of partitioned runs collapse to a
low fixed throughput, at random k and random repeat, and a min-max band over 5
repeats turns one such run into a band that swallows the whole point.

## It is not a property of any k

    dramblast-p, k=18, 5 repeats
      prefetchers ON   [1496, 2602, 2626, 2636, 2647]   spread 43.8%
      prefetchers OFF  [1944, 1981, 1982, 1986, 1988]   spread  2.2%

The same k is one of the WORST points in one sweep and one of the most stable in
the other. A fresh 20-repeat rerun of exactly that point (k=18, prefetchers on)
gave 2423..2629, sd 59, spread 7.9%, and ZERO collapses. The k value is not what
is unstable.

The unstable k differ between sweeps, which is what you would expect of a random
event and not of a property of k:

      prefetchers OFF, dramblast-p  collapses at k = 10, 11, 23, 24, 29, 31
      prefetchers ON,  dramblast-p  collapses at k = 18, 27

## The rate, and why it looks worse than it is

    partitioned runs (ht 1 + ht 12, both sweeps)  460
    collapsed runs (<90% of the point's median)    13  = 2.8% per run
    (variant, k) points                             92
    points containing at least one collapse         13  = 14%

A 2.8% per-run event contaminates 14% of points because a point is 5 runs:
1 - (1 - 0.028)^5 = 13%, against 14% observed. The plot's min-max band is drawn
from the extremes, so a single bad run in five sets the entire visible band --
the figure makes a 3% event look like a 14% one.

## What the collapse is

Discrete, not proportional. Collapsed runs land near the same ABSOLUTE
throughput (~1450-1580 set_mops) whatever the k and whatever the prefetcher
state, while the healthy mode sits at ~2600 (prefetchers on) or ~1980 (off).
In the collapsed mode the prefetcher setting stops mattering, which says the run
is limited by something that dominates both.

    k=18 slow run   set_cycles 106   set_mops 1496
    k=18 fast run   set_cycles  61   set_mops 2602

The timed insert region really is 1.74x slower (5.12 s vs 3.07 s of wall clock
between last producer staged and last consumer done). It is not a reporting
artifact.

## Ruled out, by diffing a collapsed run against a healthy one

  * different work -- both staged exactly 7242767615 kmers
  * NUMA misplacement -- all 64 table binds and all 64 staging arenas landed on
    the node local to their cpu in BOTH runs; 32/32 per node either way
  * page class -- every staging arena was "1 x 1GB + 30 x 2MB" and every table
    "256 2mb pages" in both
  * mbind failures -- none in either
  * a straggler consumer -- all 64 consumers finish within 0.03 s of each other
    in both runs, so the slowdown is uniform across consumers, not one laggard
  * anything else the log records -- with timestamps, pids, addresses and digits
    normalised away, the two logs are structurally IDENTICAL; only the timings
    and the final mops line differ

Root cause is therefore NOT identified. It is something not visible in the logs:
scheduling/SMT interleaving, uncore or mesh frequency, or external interference.

## Structural context worth knowing

This machine pairs cpu i with cpu i+64 as the two hyperthreads of one physical
core, for every i in 0..63:

    producers  cpus 0-63    first  hyperthread of all 64 physical cores
    consumers  cpus 64-127  second hyperthread of the SAME 64 physical cores

So `--nprod 64 --ncons 64` under queue policy 3 is not 128 cores' worth of work;
it is 64 physical cores, each running a producer and its consumer as SMT
siblings competing for one core's execution resources, L1/L2 and prefetchers.
That is very likely why the partitioned path is the one that cares about the
hardware prefetchers at all (+23-35%, against +0.4% and -3% for the global
tables), and it is a plausible home for a bimodal scheduling effect.

## Practical suggestion

Report the median, or trim the extremes, rather than a min-max band over 5
repeats -- the healthy mode is tight (sd ~60 on 2600, ~2%) and the collapses are
a separate population. If the collapses matter in their own right, they need
more repeats and a per-run record of uncore frequency and involuntary context
switches, neither of which the current logs capture.
