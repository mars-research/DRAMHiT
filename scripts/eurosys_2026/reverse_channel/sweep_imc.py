#!/usr/bin/env python3
"""Thread sweep against ONE memory controller on socket 0.

Drives 1..16 cores, all on socket 0 and all on distinct physical cores, over
only the cachelines the reverse-engineered hash assigns to a single iMC (see
verify_hash.py for the check that they really do land there), and records the
controller's delivered bandwidth together with its Read Pending Queue
occupancy and insertion rate.

Two perf passes per point, because the iMC PMU has 4 general counters per box
and the six events wanted here multiplex down to 66%:

  pass A  cas_count_read + clockticks
  pass B  rpq_inserts.pch{0,1} + rpq_occupancy_pch{0,1}      (exactly 4)

DDR5 splits each channel into two sub-channels, so every RPQ event comes in a
pch0/pch1 pair and both halves have to be added up to describe the channel.

Occupancy is an accumulator: it adds the current queue depth every iMC clock,
so occupancy/clockticks is the time-averaged number of entries resident. The
clock rate comes from pass A and is a constant of the part, not of the load.
"""
import csv, math, sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from common import run, NCH, SOCKET0_CORES

TARGET_IMC = 0
MAX_THREADS = 16
REPS = 3
TARGET_LOOP_SEC = 3.5
BYTES_PER_ITER = 2097152 * 64          # lines on one channel * 64 B
PASS_A = ["cas_rd", "ticks"]
PASS_B = ["rpq_ins0", "rpq_ins1", "rpq_occ0", "rpq_occ1"]
OUT = Path(__file__).resolve().parent / "imc_thread_sweep.csv"


def iters_for(threads):
    """Enough iterations that the access loop runs ~TARGET_LOOP_SEC, so the
    100 ms perf intervals give a few tens of samples inside the window."""
    bw_est = min(6.0e9 * threads, 34.0e9)          # one channel saturates ~33 GB/s
    return max(40, math.ceil(TARGET_LOOP_SEC * bw_est / BYTES_PER_ITER))


def main():
    rows = []
    for threads in range(1, MAX_THREADS + 1):
        it = iters_for(threads)
        for rep in range(REPS):
            a = run(TARGET_IMC, threads, it, PASS_A)
            b = run(TARGET_IMC, threads, it, PASS_B)

            rd = [a["totals"][(c, "cas_rd")] for c in range(NCH)]
            tgt_bytes = rd[TARGET_IMC]
            conc = tgt_bytes / sum(rd) if sum(rd) else float("nan")

            tick_rate = a["totals"][(TARGET_IMC, "ticks")] / a["window"]

            ins = b["totals"][(TARGET_IMC, "rpq_ins0")] + b["totals"][(TARGET_IMC, "rpq_ins1")]
            occ0 = b["totals"][(TARGET_IMC, "rpq_occ0")]
            occ1 = b["totals"][(TARGET_IMC, "rpq_occ1")]
            ticks_b = tick_rate * b["window"]      # clock is load-independent

            r = dict(
                threads=threads, rep=rep, iters=it,
                bw_prog_gbs=a["bw_prog"],
                bw_perf_gbs=tgt_bytes / a["window"] / 1e9,
                concentration=conc,
                imc_clock_ghz=tick_rate / 1e9,
                rpq_ins_rate_mps=ins / b["window"] / 1e6,
                rpq_occ_pch0=occ0 / ticks_b,
                rpq_occ_pch1=occ1 / ticks_b,
                rpq_occ_chan=(occ0 + occ1) / ticks_b,
                # Little's law on the queue: mean entries / arrival rate, in iMC
                # clocks. A read that sits in the RPQ longer is one the DRAM
                # could not retire, so this is the controller's own queueing delay.
                rpq_lat_cycles=(occ0 + occ1) / ins if ins else float("nan"),
                window_a=a["window"], window_b=b["window"],
            )
            rows.append(r)
            print(f"  t={threads:2d} rep={rep}  bw={r['bw_prog_gbs']:6.2f} GB/s "
                  f"(perf {r['bw_perf_gbs']:6.2f}, conc {conc*100:5.2f}%)  "
                  f"rpq ins={r['rpq_ins_rate_mps']:7.1f} M/s  "
                  f"occ={r['rpq_occ_chan']:6.2f}  lat={r['rpq_lat_cycles']:5.1f} clk",
                  flush=True)

    with OUT.open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0].keys()))
        w.writeheader()
        w.writerows(rows)
    print(f"\n[*] wrote {OUT}  ({len(rows)} rows)")


if __name__ == "__main__":
    print(f"[*] socket-0 cores used: {SOCKET0_CORES[:MAX_THREADS]}")
    print(f"[*] target controller: uncore_imc_{TARGET_IMC}, hw prefetch OFF\n")
    main()
