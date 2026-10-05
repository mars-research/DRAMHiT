"""Shared helpers for the bandwidth-gap measurements (report-bwgap.md).

Everything that touches the machine or parses perf output lives here, so that the runners
(run_stream.py, run_totals.py) and the analysis (analyze_gap.py) use identical definitions.

Definitions used throughout
  line     bandwidth_rand: one loop iteration = one 64 B cache-line access.
           dramhit:        one find (one `find_ops`) of the uniform benchmark.
  core GHz 2.7 * cycles / ref-cycles (ref-cycles tick at the 2.7 GHz TSC rate).
  GB       decimal (1e9 B) everywhere, EXCEPT in bandwidth_rand's own printed "GB/s", which is
           GiB/s (bytes / 2^30). Convert with GIB = 2**30 / 1e9 = 1.0737 before comparing.
"""
import json
import os
import re
import statistics as st
import subprocess
import time
from collections import defaultdict
from pathlib import Path

HERE = Path(__file__).resolve().parent
OPT = HERE.parent
REPO = OPT.parents[2]
DRAMHIT = OPT / "attempt4" / "rck" / "dramhit"
BW = {100: HERE / "bin" / "bandwidth_rand_it100", 200: HERE / "bin" / "bandwidth_rand_it200"}
BWM = {100: HERE / "bin" / "bandwidth_rand_mimic_it100", 200: HERE / "bin" / "bandwidth_rand_mimic_it200"}
REF_GHZ = 2.7
GIB = 2 ** 30 / 1e9
PATH = os.environ["PATH"]
SEED = 1775762440565610239


# ---------------------------------------------------------------- machine state helpers
def rdmsr(cpu, reg, field=None):
    cmd = ["sudo", "env", f"PATH={PATH}", "rdmsr", "-p", str(cpu)]
    cmd += ["-f", field, "-d", reg] if field else ["-c", reg]
    return subprocess.run(cmd, capture_output=True, text=True).stdout.strip()


def margin_c():
    v = rdmsr(0, "0x1b1", "22:16")
    return int(v) if v.isdigit() else None


def cooldown(min_margin=12, timeout=180):
    """Wait until the package is >= min_margin C below TjMax. Returns the margin seen."""
    t0, m = time.time(), None
    while time.time() - t0 < timeout:
        m = margin_c()
        if m is None or m >= min_margin:
            return m
        time.sleep(3)
    raise SystemExit(f"package did not cool to a {min_margin} C margin in {timeout} s (last {m})")


def reserve_pool():
    """One pool for every program: 12 x 1 GiB pages + 17 GiB of 2 MiB pages on HBM node 2."""
    sh = "/opt/DRAMHiT/scripts/reserve_hugepages.sh"
    subprocess.run([sh, "reset"], stdout=subprocess.DEVNULL, check=True)
    subprocess.run([sh, "n2_12gb_17408mb", "n0_0gb_8192mb", "n1_0gb_8192mb"],
                   stdout=subprocess.DEVNULL, check=True)
    subprocess.run(f'sudo env PATH="{PATH}" /opt/DRAMHiT/scripts/prefetch_control_hbm.sh off',
                   shell=True, stdout=subprocess.DEVNULL, check=True)


# ---------------------------------------------------------------- commands
def dramhit_cmd(fill=10, read_factor=100, find_queue=64, batch_len=16, binary=DRAMHIT):
    return (f"{binary} --mode 11 --ht-type 3 --ht-size 536870912 --ht-fill {fill} --num-threads 64 "
            f"--numa-split 10 --np_cpu_node_msk 1 --np_mem_node_msk 4 --np_mem_local 0 "
            f"--batch-len {batch_len} --find_queue {find_queue} --no-prefetch 0 --hw-pref 0 "
            f"--insert-factor 100 --read-factor {read_factor} --skew 0.01 --seed {SEED}")


def bw_cmd(inst, iters=100, threads=64, mem="256mb", pad=0, near=8, lookahead=64, stage=None):
    exe = BWM[iters] if stage else BW[iters]      # mimic mode needs the build with -stage
    extra = f" -stage {stage}" if stage else ""
    return (f"{exe} -m {mem} -pattern n0a2t{threads} -freq {REF_GHZ} -inst {inst} "
            f"-pad {pad} -near {near} -lookahead {lookahead}{extra} -mode r")


def hbm_events():
    pat = re.compile(r"uncore_hbm_(\d+)$")
    boxes = sorted(int(m.group(1)) for m in (pat.match(p.name) for p in Path("/sys/devices").glob("uncore_hbm_*")) if m)
    enc = {"rd": "event=0x05,umask=0xcf", "wr": "event=0x05,umask=0xf0"}
    return ",".join(f"uncore_hbm_{i}/{e},name=mem_{n}/" for i in boxes for n, e in enc.items())


# core events for the interval stream: 3 fixed counters + 4 programmable, so nothing is
# multiplexed (the parser asserts 100% running)
STREAM_CORE = ["cycles", "instructions", "ref-cycles", "l1d_pend_miss.fb_full",
               "offcore_requests_outstanding.data_rd", "offcore_requests.data_rd", "xq.full_cycles"]
CHA_CLK = "uncore_cha_0/event=0x01,name=clk_cha/"
ENERGY = "power/energy-pkg/"


# ---------------------------------------------------------------- running
def save_meta(logdir, **kw):
    logdir.mkdir(parents=True, exist_ok=True)
    (logdir / "meta.json").write_text(json.dumps(kw, indent=1, default=str))


def run_stream(cmd, logdir, label, interval_ms=200):
    """perf stat -a --per-socket -I 200 -x, ... -- cmd ; everything (perf rows AND the
    program's own output) goes, interleaved in arrival order, into combined.log."""
    m = cooldown()
    events = ",".join(STREAM_CORE + [ENERGY, hbm_events(), CHA_CLK])
    full = f"sudo perf stat -a --per-socket -I {interval_ms} -x, -e {events} -- {cmd}"
    logdir.mkdir(parents=True, exist_ok=True)
    (logdir / "cmd.txt").write_text(full + "\n")
    t0 = time.time()
    out = subprocess.run(full, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True).stdout
    (logdir / "combined.log").write_text(out)
    save_meta(logdir, label=label, kind="stream", cmd=cmd, margin_before_c=m,
              wall_s=round(time.time() - t0, 1), started=time.strftime("%Y-%m-%dT%H:%M:%S"))
    return out


def run_totals(cmd, logdir, label, iters=None):
    """Whole-process totals of user-mode instructions, cycles and ref-cycles for socket 0, plus
    HBM read/write CAS counts. perf's own table goes to perf.csv, the program's output to
    program.out (two files, no interleaving needed: no phase windows are used)."""
    m = cooldown()
    events = f"instructions:u,cycles:u,ref-cycles:u,power/energy-pkg/,{hbm_events()}"
    logdir.mkdir(parents=True, exist_ok=True)
    full = (f"sudo perf stat -a --per-socket -x, -e {events} -o {logdir}/perf.csv -- {cmd} "
            f"> {logdir}/program.out 2>&1")
    (logdir / "cmd.txt").write_text(full + "\n")
    t0 = time.time()
    subprocess.run(full, shell=True)
    save_meta(logdir, label=label, kind="totals", cmd=cmd, iters=iters, margin_before_c=m,
              wall_s=round(time.time() - t0, 1), started=time.strftime("%Y-%m-%dT%H:%M:%S"))


# ---------------------------------------------------------------- parsing: program output
def parse_program(text):
    d = {}
    m = re.search(r"find_ops\s*:\s*(\d+),\s*found\s*:\s*(\d+)", text)
    if m:
        d["find_ops"], d["found"] = int(m.group(1)), int(m.group(2))
    for k in ("set_mops", "get_mops"):
        m = re.findall(rf"{k}\s*:\s*(\d+)", text)
        if m:
            d[k] = int(m[-1])
    m = re.search(r"Total memory allocated across all threads:\s*(\d+)\s*MB", text)
    if m:
        d["alloc_mb"] = int(m.group(1))
    m = re.search(r"Time Taken\s*:\s*([\d.]+)\s*seconds", text)
    if m:
        d["time_s"] = float(m.group(1))
    m = re.search(r"Bandwidth\s*:\s*([\d.]+)\s*GB/s", text)
    if m:
        d["bw_printed_gibps"] = float(m.group(1))
    m = re.search(r"Total Data Proc\s*:\s*([\d.]+)\s*GB", text)
    if m:
        d["data_printed_gib"] = float(m.group(1))
    return d


def bw_lines(d, iters):
    """Exact number of 64 B accesses: total allocated bytes / 64 x NUM_ITERATIONS."""
    return d["alloc_mb"] * 2 ** 20 // 64 * iters


# ---------------------------------------------------------------- parsing: perf -x output
def parse_totals(path):
    """-> {event: summed count over socket-0 rows} from a `perf stat -a --per-socket -x,` file."""
    tot = defaultdict(float)
    for line in Path(path).read_text().splitlines():
        p = line.split(",")
        if len(p) < 6 or p[0] != "S0":
            continue
        try:
            tot[p[4]] += float(p[2])
        except ValueError:
            pass            # "<not counted>"
    return dict(tot)


def parse_stream(path, markers):
    """Interleaved perf -I rows + program lines -> per phase, per interval socket-0 values.

    markers: [(substring, phase_name_or_None)]; a row belongs to the phase named by the last
    marker seen before it. Returns (phases, info) where phases[name] is a list of dicts
    {t, dt, cnt{event: count}, hbm_rd_B, hbm_wr_B, clk_cha_ghz, joules} for every interval
    (boundary intervals included; the caller decides what to drop) and info holds consistency
    information (marker line numbers, minimum %running seen)."""
    phase, rows, info = None, defaultdict(lambda: defaultdict(lambda: defaultdict(float))), {"markers": []}
    hbm = defaultdict(lambda: defaultdict(lambda: [0.0, 0.0, 0.0, 0.0, 0]))   # phase->ts->[rd,wr,ns_rd,ns_wr,n]
    clk, run_min, order, prev_ts, dts = {}, 100.0, defaultdict(list), 0.0, {}
    for n, line in enumerate(Path(path).read_text().splitlines()):
        hit = False
        for mark, name in markers:
            if mark in line:
                phase = name
                info["markers"].append((n, mark, round(prev_ts, 3)))
                hit = True
                break
        p = line.strip().split(",")
        if hit or len(p) < 7 or not p[0][:1].isdigit():
            continue
        try:
            ts = float(p[0])
        except ValueError:
            continue
        prev_ts = max(prev_ts, ts)
        if p[1].strip() != "S0" or "<not" in line or phase is None:
            continue
        ev = p[5].strip()
        try:
            cnt, ns = float(p[3]), float(p[6])
            run_min = min(run_min, float(p[7]))
        except (ValueError, IndexError):
            continue
        if ev in ("mem_rd", "mem_wr"):
            h = hbm[phase][ts]
            h[0 if ev == "mem_rd" else 1] += cnt
            h[2 if ev == "mem_rd" else 3] += ns
            h[4] += 1
        elif ev == "clk_cha":
            clk[(phase, ts)] = cnt / ns
        else:
            rows[phase][ts][ev] += cnt
    info["min_running_pct"] = run_min
    out, last = {}, defaultdict(float)
    for ph, byts in rows.items():
        lst, prev = [], None
        for ts in sorted(byts):
            h = hbm[ph].get(ts)
            r = {"t": ts, "cnt": dict(byts[ts]),
                 "clk_cha_ghz": clk.get((ph, ts))}
            if h and h[4]:
                r["hbm_rd_B"] = 32 * h[0]
                r["hbm_wr_B"] = 32 * h[1]
                r["hbm_ns"] = (h[2] + h[3]) / h[4]           # mean per-row time enabled, ns
            lst.append(r)
        out[ph] = lst
    # interval length: difference of consecutive timestamps in the whole stream
    return out, info


def settled(lst):
    """Drop the first and last interval of a phase (they straddle a marker)."""
    return lst[1:-1] if len(lst) > 4 else lst
