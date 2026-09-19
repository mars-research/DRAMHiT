"""Drive imc_probe under `perf stat -I` and cut the counter series down to the
program's own access-loop window.

Why the window matters: imc_probe memsets and flushes the whole 1 GiB page
before it starts, and that init traffic is spread over all 8 controllers. A
whole-run `perf stat` therefore shows traffic on every channel no matter how
good the hash is. The program prints CLOCK_MONOTONIC marks around the access
loop and we keep only the intervals that fall strictly inside it.

perf's interval clock and our CLOCK_MONOTONIC differ by however long perf took
to get going, so a margin is dropped at each end and the result is checked
against the program's own bandwidth number -- if the window were misaligned the
two would not agree.
"""
import re, subprocess, time

PROBE = "./imc_probe"
NCH = 8
# socket 0, one thread per physical core. Node 0 on this box is the EVEN cpus,
# and 0..62 are the first smt thread of each of the 32 cores (64..126 are their
# siblings), so this list is 32 distinct cores with no smt sharing.
SOCKET0_CORES = list(range(0, 64, 2))

# label -> perf event spec inside uncore_imc_N/.../, verified against
# `perf list --details` on this machine (EMR, family 6 model 207).
EVENTS = {
    "cas_rd":   "cas_count_read",
    "cas_wr":   "cas_count_write",
    "ticks":    "clockticks",
    "rpq_ins0": "event=0x10,umask=0x1",   # unc_m_rpq_inserts.pch0
    "rpq_ins1": "event=0x10,umask=0x2",   # unc_m_rpq_inserts.pch1
    "rpq_occ0": "event=0x80",             # unc_m_rpq_occupancy_pch0
    "rpq_occ1": "event=0x81",             # unc_m_rpq_occupancy_pch1
}

# The kernel exports a .scale/.unit for cas_count_read|write, so perf prints
# those pre-scaled to MiB while clockticks and the RPQ events come through as
# raw counts with an empty unit. Reading the value and ignoring the unit field
# silently mixes MiB and counts.
UNIT = {"": 1.0, "B": 1.0, "Bytes": 1.0,
        "KiB": 1024.0, "MiB": 1024.0 ** 2, "GiB": 1024.0 ** 3}


def _evstr(labels):
    return ",".join(f"uncore_imc_{i}/{EVENTS[l]}/" for l in labels for i in range(NCH))


def run(target_imc, threads, iters, labels, interval_ms=100, margin=0.35):
    """Run the probe on `threads` socket-0 cores and return per-channel totals
    over the access loop, keyed (channel, label)."""
    cpus = ",".join(str(c) for c in SOCKET0_CORES[:threads])
    cmd = ["sudo", "perf", "stat", "-C", "0", "-x,", "-I", str(interval_ms),
           "-e", _evstr(labels), "--",
           PROBE, str(target_imc), str(threads), str(iters), cpus]

    t0 = time.monotonic()
    p = subprocess.run(cmd, capture_output=True, text=True)
    prog, perf = p.stdout, p.stderr
    if p.returncode != 0:
        raise RuntimeError(f"probe failed rc={p.returncode}\n{prog}\n{perf[:2000]}")

    info = {}
    for k in ("phys_base", "lines", "bw", "sec", "phys_1gb_aligned", "bytes"):
        m = re.search(rf"^{k}\s+(\S+)", prog, re.M)
        if m:
            info[k] = m.group(1)
    ls = float(re.search(r"MARK loop_start\s+([\d.]+)", prog).group(1))
    le = float(re.search(r"MARK loop_end\s+([\d.]+)", prog).group(1))

    spec2label = {EVENTS[l]: l for l in labels}
    # -x, rows: <elapsed>,<value>,<unit>,<event>,<runtime>,<pct>,...
    # The event field carries the raw spec, commas and all, so it cannot be
    # split on ',' -- pull it out with a regex over the whole line instead.
    rowre = re.compile(r"^([\d.]+),([^,]*),([^,]*),uncore_imc_(\d+)/(.+?)/,")
    rows = []
    for line in perf.splitlines():
        m = rowre.match(line)
        if not m:
            continue
        el, raw, unit, ch, spec = m.groups()
        if spec not in spec2label:
            continue
        if unit.strip() not in UNIT:
            raise RuntimeError(f"unhandled perf unit {unit!r} in: {line}")
        try:
            val = float(raw) if raw not in ("", "<not counted>", "<not supported>") else 0.0
        except ValueError:
            continue
        rows.append((float(el), int(ch), spec2label[spec], val * UNIT[unit.strip()]))

    # cut to the loop window, expressed in perf's elapsed clock
    lo, hi = (ls - t0) + margin, (le - t0) - margin
    keep = [r for r in rows if lo <= r[0] <= hi]
    if not keep:
        raise RuntimeError(f"no perf intervals inside the loop window "
                           f"(loop was {le-ls:.2f}s; raise iterations)")

    # Each interval row timestamped E accounts for the dt of counting that ENDS
    # at E, so N rows cover N*dt of time, not span[-1]-span[0] = (N-1)*dt.
    # Getting this wrong understates the window and inflates every derived rate
    # by N/(N-1) -- ~3% at 33 intervals.
    span = sorted({r[0] for r in keep})
    dt = interval_ms / 1000.0
    window = (span[-1] - span[0]) + dt if len(span) > 1 else dt

    tot = {(ch, l): 0.0 for ch in range(NCH) for l in labels}
    for _, ch, l, val in keep:
        tot[(ch, l)] += val

    return {"info": info, "totals": tot, "window": window,
            "n_intervals": len(span), "loop_sec": le - ls,
            "bw_prog": float(info.get("bw", "nan")),
            "sec_prog": float(info.get("sec", "nan")),
            "prog_stdout": prog}
