#!/usr/bin/env python3
"""Measured HBM ceilings for the uniform panels, counted at the controllers.

The reference lines on the uniform figures used to be one number: 405 GB/s,
the random-access READ ceiling from ../intel_hbm/intel_hbm_cpu_scaling.json.
The lookup panel is read-only, so that is the right line for it -- but the
insertion panel is a read-for-ownership plus a writeback per line, and a
read-only ceiling says nothing about what the machine can sustain for that.

So both are measured here, with machine_stats/bandwidth.c on the same cpu/memory
pairing the benchmark uses (pattern n0a2t64: 64 threads on node 0's cpus against
node 2's HBM, 256 MB per thread = 16 GB live, random access):

    lookup    -mode r -inst t1          prefetcht1, the fastest read instruction
                                        on this part (t0 346, plain load 321,
                                        nta 238 GB/s, all measured here)
    insertion -mode w -inst t1           a store per line: the line is taken
                                        exclusive, dirtied, and written back, so
                                        the traffic is the 1 read + 1 write per
                                        line the insert phase issues (measured
                                        rd:wr is exactly 1:1)
    insertion -mode w -inst prefetchw    the same mix prefetched the way the cas
                                        insert path prefetches it. It is NOT the
                                        maximum -- prefetchw reaches 376 GB/s
                                        against prefetcht1's 618 on this mix,
                                        which is worth knowing given
                                        CAS_PREFETCH_INSERTION uses prefetchw.

Lookahead does NOT matter here, and an early version of this file claimed it
did. Measured interleaved in one session, 3 reps, read: 397 / 396 / 396 / 394
GB/s at lookahead 32 / 64 / 128 / 256, which is inside the run-to-run spread.
The apparent effect was drift between sessions.

What does move the number is which physical pages back the buffer: resetting
and re-reserving the hugepage pool shifts the read result by up to 7% (376
GB/s on one pool against 406 on another, with the program's own report moving
by the same 7%, so it is the machine and not the counters). Runs within one
pool agree to 1-2%. Treat a single number from here as +/- 7% unless the pool
is held fixed, and re-measure both phases together when it changes.

"""
import argparse
import json
import re
import statistics
import subprocess
from collections import defaultdict
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
BIN = SCRIPT_DIR.parent / "machine_stats" / "build" / "bandwidth_rand"
PREFETCH_SCRIPT = "/opt/DRAMHiT/scripts/prefetch_control_hbm.sh"
OUT = SCRIPT_DIR / "intel_hbm" / "intel-max9462-hbm_ceiling.json"

PATTERN = "n0a2t64"          # 64 threads on node 0's cpus, memory on node 2
PER_THREAD = "256mb"         # 16 GB live, as in the cpu-scaling sweep
FREQ = "2.7"
LOOKAHEAD = "64"      # immaterial (see docstring); 64 matches the rest of the repo
REPS = 3
BYTES_PER_CAS = 32
INTERVAL_MS = 100

# phase -> the variants to measure. The first is the ceiling for that panel;
# the rest are there for comparison.
PHASES = {
    "lookup": [{"mode": "r", "inst": "t1"}],
    "insertion": [{"mode": "w", "inst": "t1"},
                  {"mode": "w", "inst": "prefetchw"}],
}


def pmu_boxes():
    pat = re.compile(r"uncore_hbm_(\d+)$")
    return sorted(int(m.group(1)) for m in
                  (pat.match(p.name) for p in Path("/sys/devices").glob("uncore_hbm_*")) if m)


def events():
    enc = {"rd": "event=0x05,umask=0xcf", "wr": "event=0x05,umask=0xf0"}
    return ",".join(f"uncore_hbm_{i}/{e},name=mem_{n}/"
                    for i in pmu_boxes() for n, e in enc.items())


def run(phase, cfg, mask, rep):
    subprocess.run(f'sudo env PATH="$PATH" {PREFETCH_SCRIPT} {mask}',
                   shell=True, check=True, stdout=subprocess.DEVNULL)
    cmd = ["sudo", "perf", "stat", "--per-socket", "-e", events(),
           "-I", str(INTERVAL_MS), "-x", ",", "--",
           str(BIN), "-m", PER_THREAD, "-pattern", PATTERN, "-freq", FREQ,
           "-inst", cfg["inst"], "-lookahead", LOOKAHEAD, "-mode", cfg["mode"]]
    out = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                         text=True).stdout
    (SCRIPT_DIR / "intel_hbm" / "logs" / "ceiling").mkdir(parents=True, exist_ok=True)
    (SCRIPT_DIR / "intel_hbm" / "logs" / "ceiling" /
     f"{phase}_{cfg['inst']}_{mask}_rep{rep}.log").write_text(out)

    # Only the rows between the program's own markers: outside them the threads
    # are still faulting in their chunks, which is real traffic that has nothing
    # to do with the measured loop.
    inwin = False
    acc = defaultdict(lambda: defaultdict(lambda: [0.0, 0.0, 0]))
    for line in out.splitlines():
        if "Start perf collection" in line:
            inwin = True
            continue
        if "End perf collection" in line:
            inwin = False
            continue
        if not inwin:
            continue
        p = line.strip().split(",")
        if len(p) < 7 or not p[0][:1].isdigit() or not p[1].strip().startswith("S"):
            continue
        try:
            ts, count, ev, run_ns = float(p[0]), float(p[3]), p[5].strip(), float(p[6])
        except (ValueError, IndexError):
            continue
        slot = acc[ts][ev]
        slot[0] += count
        slot[1] += run_ns
        slot[2] += 1

    rd, wr = [], []
    ts_sorted = sorted(acc)
    for ts in ts_sorted[1:-1] if len(ts_sorted) > 2 else ts_sorted:
        ev = acc[ts]
        if not {"mem_rd", "mem_wr"} <= set(ev):
            continue
        rates = {}
        for k in ("mem_rd", "mem_wr"):
            c, ns, boxes = ev[k]
            if ns <= 0:
                break
            rates[k] = BYTES_PER_CAS * boxes * c / ns
        else:
            rd.append(rates["mem_rd"])
            wr.append(rates["mem_wr"])
    prog = re.search(r"Bandwidth\s*:\s*([\d.]+)", out)
    if not rd:
        return None
    return {
        "rd_gbps": round(statistics.median(rd), 1),
        "wr_gbps": round(statistics.median(wr), 1),
        "total_gbps": round(statistics.median([r + w for r, w in zip(rd, wr)]), 1),
        "peak_total_gbps": round(max(r + w for r, w in zip(rd, wr)), 1),
        "intervals": len(rd),
        "prog_reported_gbps": float(prog.group(1)) if prog else None,
    }


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--masks", nargs="+", default=["0x2f"],
                    help="MSR 0x1a4 masks to measure under (default: 0x2f, "
                         "the state the prefetcher-off series were collected in)")
    args = ap.parse_args()

    if not BIN.exists():
        raise SystemExit(f"[!] {BIN} not built; run make in machine_stats/")

    results = {"binary": str(BIN), "pattern": PATTERN, "per_thread": PER_THREAD,
               "bytes_per_cas": BYTES_PER_CAS, "phases": {}}
    results["lookahead"] = LOOKAHEAD
    results["reps"] = REPS
    for mask in args.masks:
        for phase, variants in PHASES.items():
            for cfg in variants:
                samples = [run(phase, cfg, mask, r) for r in range(1, REPS + 1)]
                samples = [s for s in samples if s]
                if not samples:
                    print(f"  [!] {phase} {cfg['inst']} @ {mask}: no intervals parsed")
                    continue
                med = {k: round(statistics.median(s[k] for s in samples), 1)
                       for k in ("rd_gbps", "wr_gbps", "total_gbps", "peak_total_gbps")}
                entry = {**cfg, **med,
                         "samples_total_gbps": [s["total_gbps"] for s in samples],
                         "prog_reported_gbps": samples[0]["prog_reported_gbps"]}
                key = f"{cfg['mode']}_{cfg['inst']}"
                results["phases"].setdefault(phase, {}).setdefault(mask, {})[key] = entry
                if cfg is variants[0]:
                    results["phases"][phase].setdefault("ceiling_gbps", {})[mask] = med["total_gbps"]
                print(f"  {phase:10s} mask {mask:5s} -inst {cfg['inst']:9s} -mode {cfg['mode']} | "
                      f"total {med['total_gbps']:6.1f} GB/s (rd {med['rd_gbps']:6.1f} "
                      f"wr {med['wr_gbps']:6.1f}) | peak {med['peak_total_gbps']:6.1f} | "
                      f"runs {[f'{s:.0f}' for s in entry['samples_total_gbps']]} | "
                      f"program says {entry['prog_reported_gbps']}")
    OUT.write_text(json.dumps(results, indent=2))
    print(f"\n[OK] written to {OUT}")


if __name__ == "__main__":
    main()
