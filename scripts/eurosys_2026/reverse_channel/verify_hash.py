#!/usr/bin/env python3
"""Verify the reverse-engineered Intel iMC hash against the hardware's own
per-controller CAS counters.

Two claims are checked, and the second is the one that matters:

  1. concentration -- the lines the hash assigns to a channel really do all go
     to ONE memory controller. Measured as the share of socket-0 read CAS that
     lands on the busiest uncore_imc unit.

  2. bijection -- sweeping the predicted channel k = 0..7 lights up 8 DISTINCT
     controllers. Checking only k=0 (as reversed_intel.c does) cannot tell a
     correct hash from one that, say, has two of its output bits swapped: any
     such hash still picks a set of lines that is confined to one channel.
     Only the full sweep pins down the function.

A third, free check: the reads are clflushopt'd clean lines, so DRAM writes
should be ~0. Write traffic would mean the loop is not measuring what it claims.
"""
import sys
from common import run, NCH

THREADS = int(sys.argv[1]) if len(sys.argv) > 1 else 8
ITERS   = int(sys.argv[2]) if len(sys.argv) > 2 else 60
EV = ["cas_count_read", "cas_count_write"]

print(f"[*] verifying hash: {THREADS} threads, {ITERS} iterations, socket 0, hw prefetch OFF\n")

rows = []
for k in range(NCH):
    r = run(k, THREADS, ITERS, EV)
    rd = [r["totals"][(c, "cas_count_read")] for c in range(NCH)]
    wr = [r["totals"][(c, "cas_count_write")] for c in range(NCH)]
    tr, tw = sum(rd), sum(wr)
    top = max(range(NCH), key=lambda c: rd[c])
    share = rd[top] / tr if tr else 0.0

    # perf counts CAS commands; cas_count_read is already scaled to bytes by the
    # kernel's .scale (64 B per CAS), so compare bytes/s against the program.
    bw_perf = tr / r["window"] / 1e9 if r["window"] else float("nan")

    rows.append(dict(k=k, top=top, share=share, rd=rd, bw_perf=bw_perf,
                     bw_prog=r["bw_prog"], wr_share=(tw / tr if tr else 0.0),
                     lines=r["info"].get("lines"), phys=r["info"].get("phys_base"),
                     aligned=r["info"].get("phys_1gb_aligned"),
                     nint=r["n_intervals"]))
    print(f"  predicted iMC {k} -> uncore_imc_{top}  "
          f"{share*100:6.2f}% of read CAS   "
          f"bw perf {bw_perf:6.2f} / prog {r['bw_prog']:6.2f} GB/s   "
          f"lines={r['info'].get('lines')}  intervals={r['n_intervals']}")

print("\n--- per-channel read CAS distribution (GB in window) ---")
print("pred |" + "".join(f"  imc{c:<6}" for c in range(NCH)))
for r in rows:
    print(f" {r['k']}   |" + "".join(f" {v/1e9:8.2f}" for v in r["rd"]))

mapping = {r["k"]: r["top"] for r in rows}
bijective = len(set(mapping.values())) == NCH
min_share = min(r["share"] for r in rows)
max_wr    = max(r["wr_share"] for r in rows)
bw_err    = max(abs(r["bw_perf"] - r["bw_prog"]) / r["bw_prog"] for r in rows)

print("\n--- verdict ---")
print(f"phys base            : {rows[0]['phys']}  (1GiB-aligned: {rows[0]['aligned']})")
print(f"lines per channel    : {rows[0]['lines']}  (1/8 of 16777216 = 2097152)")
print(f"predicted -> measured: {mapping}")
print(f"bijective (8 distinct controllers): {bijective}")
print(f"worst-case concentration          : {min_share*100:.2f}%")
print(f"worst-case write/read CAS ratio   : {max_wr*100:.3f}%")
print(f"worst-case perf-vs-program bw err : {bw_err*100:.2f}%")

ok = bijective and min_share > 0.97 and max_wr < 0.02 and bw_err < 0.10
print("\nRESULT:", "PASS" if ok else "FAIL")
sys.exit(0 if ok else 1)
