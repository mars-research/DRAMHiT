#!/usr/bin/env python3
"""Does the package power limit (PL1) control the uncore mesh clock?  Staged, with abort.

    python3 pl1_check.py [--workload spin_scalar_32] [--levels 350 335 325 315 350] [--reps 2]

Sets socket 0's PL1 through /sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw
in steps and, at each level, runs a memory-free spin from uncore_sweep.CONFIGS (default:
scalar integer ops on 32 threads of node 0, ~327 W, mesh untouched at stock) under
uncore_sweep.run(), i.e. one perf stream with package power, core clock, mesh clock and
(zero) HBM traffic at 100 ms. Alongside, per run:
  throttled   delta of MSR 0x613 (PKG_PERF_STATUS, 1/1024 s ticks) / run time
  ratio621    mean of live reads of MSR 0x621 (current uncore ratio, x100 MHz)
  margin      lowest degrees-below-TjMax seen (MSR 0x1b1 bits 22:16), polled every 0.4 s
Safety:
  - only socket 0's PL1 is changed; levels are limited to 305..420 W (305 is just under the
    ~312 W the package draws idle with C-states off, 420 is PL2, left alone)
  - a monitor thread kills the workload and aborts if the margin to TjMax is <= 5 C
  - PL1 is restored to its original value in a finally block (and on SIGTERM), then MSR
    0x610 is compared bit for bit with its value at the start
  - restore_pl1.sh does the same restore by hand
History: the first version raised PL1 under the heavy 512-bit spin and its temperature abort
fired at the STOCK 350 W (margin 12 C -> 5 C within a few seconds), so raising PL1 under dense
512-bit work is not safe on this machine. Lowering PL1 under a cool workload is.
--dramhit adds, per level, one dramhit find/insert run (attempt4/rck, fill 10, --energy).
"""
import argparse
import json
import os
import signal
import statistics as st
import subprocess
import sys
import threading
import time
from pathlib import Path

import license_sweep as ls
import uncore_sweep as us

HERE = Path(__file__).resolve().parent
OUT = HERE / "results" / "pl1"        # overridden by --out
PL1_PATH = "/sys/class/powercap/intel-rapl:0/constraint_0_power_limit_uw"
MIN_MARGIN_C = 5
PATH = os.environ["PATH"]


def rdmsr(cpu, reg, field=None):
    cmd = ["sudo", "env", f"PATH={PATH}", "rdmsr", "-p", str(cpu)]
    cmd += ["-f", field, "-d", reg] if field else ["-c", reg]
    return subprocess.run(cmd, capture_output=True, text=True).stdout.strip()


def read_pl1_w():
    return int(Path(PL1_PATH).read_text()) / 1e6


def set_pl1_w(w):
    subprocess.run(["sudo", "tee", PL1_PATH], input=str(int(round(w * 1e6))), text=True,
                   stdout=subprocess.DEVNULL, check=True)
    got = read_pl1_w()
    if abs(got - w) > 0.5:
        raise SystemExit(f"PL1 write not accepted: asked {w} W, read back {got} W")


class Monitor(threading.Thread):
    """Poll temperature margin, live uncore ratio and the throttled-time counter."""

    def __init__(self):
        super().__init__(daemon=True)
        self.stop, self.abort = threading.Event(), False
        self.margins, self.ratios = [], []

    def run(self):
        while not self.stop.is_set():
            m = rdmsr(0, "0x1b1", "22:16")
            r = rdmsr(0, "0x621")
            if m.isdigit():
                self.margins.append(int(m))
                if int(m) <= MIN_MARGIN_C:
                    self.abort = True
                    subprocess.run(["sudo", "pkill", "-x", "spin"])
                    subprocess.run(["sudo", "pkill", "-x", "dramhit"])
                    subprocess.run(["sudo", "pkill", "-x", "bandwidth_rand"])
                    return
            if r:
                self.ratios.append(int(r, 16) & 0x7F)
            self.stop.wait(0.4)


def tick_seconds():
    return 1 / (1 << ((int(rdmsr(0, "0x606"), 16) >> 16) & 0xF))


def wait_cool(min_margin=10, timeout=90):
    """Let the package cool to >= min_margin C below TjMax before a run starts."""
    t0, m = time.time(), None
    while time.time() - t0 < timeout:
        v = rdmsr(0, "0x1b1", "22:16")
        if v.isdigit():
            m = int(v)
            if m >= min_margin:
                return m
        time.sleep(3)
    raise SystemExit(f"package did not cool to a {min_margin} C margin within {timeout}s (last {m})")


def one_spin(level, rep, label="spin_zmmheavy_64"):
    time.sleep(us.PAUSE_S)
    wait_cool()
    t0, w0 = int(rdmsr(0, "0x613"), 16), time.time()
    mon = Monitor()
    mon.start()
    res = us.run(label, rep)
    mon.stop.set()
    mon.join()
    el = time.time() - w0
    t1 = int(rdmsr(0, "0x613"), 16)
    res.update({"pl1_w": level, "elapsed_s": round(el, 1),
                "throttled_frac": round(((t1 - t0) & 0xFFFFFFFF) * tick_seconds() / el, 3),
                "ratio621_mean": round(st.mean(mon.ratios), 1) if mon.ratios else None,
                "min_margin_c": min(mon.margins) if mon.margins else None,
                "aborted": mon.abort})
    return res


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--workload", default="spin_scalar_32", choices=list(us.CONFIGS))
    ap.add_argument("--levels", type=float, nargs="+", default=[350, 335, 325, 315, 350])
    ap.add_argument("--mem", default="256mb", help="bandwidth_rand -m per thread (longer runs = more settled data)")
    ap.add_argument("--out", default="pl1", help="results/<out>/ for the json and logs")
    ap.add_argument("--reps", type=int, default=2)
    ap.add_argument("--dramhit", action="store_true")
    args = ap.parse_args()
    if max(args.levels) > 420 or min(args.levels) < 305:
        raise SystemExit("levels must be within 305..420 W")

    global OUT
    OUT = HERE / "results" / args.out
    OUT.mkdir(parents=True, exist_ok=True)
    us.OUT = OUT
    us.MEM_PER_THREAD = args.mem
    needs_hugepages = us.CONFIGS[args.workload][0] == "mem"
    reserve_mb = us.CONFIGS[args.workload][2] * int(args.mem[:-2]) + 1024
    if needs_hugepages:
        # bandwidth_rand wants 2 MB pages on the HBM node; the dramhit reservation is put
        # back in the finally block below.
        subprocess.run(f'sudo env PATH="$PATH" {ls.PREFETCH} off', shell=True, check=True,
                       stdout=subprocess.DEVNULL)
        subprocess.run(f"{ls.HUGE} reset && {ls.HUGE} n2_0gb_{reserve_mb}mb n0_0gb_2048mb",
                       shell=True, check=True, stdout=subprocess.DEVNULL)
    orig_w, orig_msr = read_pl1_w(), rdmsr(0, "0x610")
    margin0 = int(rdmsr(0, "0x1b1", "22:16"))
    print(f"start: PL1 {orig_w:.0f} W, MSR 0x610 = 0x{orig_msr}, margin to TjMax {margin0} C", flush=True)
    if margin0 <= MIN_MARGIN_C + 3:
        raise SystemExit("package already too close to TjMax; not starting")
    signal.signal(signal.SIGTERM, lambda *a: sys.exit(143))

    results = []
    try:
        for level in args.levels:
            set_pl1_w(level)
            print(f"\n--- PL1 = {level:.0f} W (read back {read_pl1_w():.0f}) ---", flush=True)
            for rep in range(1, args.reps + 1):
                r = one_spin(level, rep, args.workload)
                results.append(r)
                print(f"{args.workload} rep{rep}: pkg {r['pkg_w']} W | core {r['core_ghz']} GHz | "
                      f"mesh {r['cha_ghz']} GHz (min {r['cha_min_ghz']:.2f}) | live 0x621 {r['ratio621_mean']} | "
                      f"throttled {r['throttled_frac'] * 100:.0f}% | margin {r['min_margin_c']} C"
                      f"{' | ABORTED' if r['aborted'] else ''}", flush=True)
                (OUT / "pl1_check.json").write_text(json.dumps(results, indent=1))
                if r["aborted"]:
                    raise SystemExit("temperature margin reached the abort threshold")
            if args.dramhit:
                tag = f"pl1_{int(level)}W"
                t0 = int(rdmsr(0, "0x613"), 16)
                w0 = time.time()
                mon = Monitor()
                mon.start()
                p = subprocess.run(
                    [sys.executable, str(HERE.parent / "run_uniform_hbm.py"), "--config", "baseline",
                     "--energy", "--reps", "1", "--fill", "10", "--no-hugepages", "--binary",
                     str(HERE.parent / "attempt4" / "rck" / "dramhit"), "--tag", tag],
                    capture_output=True, text=True)
                mon.stop.set()
                mon.join()
                lines = [l for l in p.stdout.splitlines() if "energy fill" in l or "=>" in l]
                el = time.time() - w0
                t1 = int(rdmsr(0, "0x613"), 16)
                print("dramhit rck fill 10 (n=1):", *lines, sep="\n  ", flush=True)
                print(f"  throttled {((t1 - t0) & 0xFFFFFFFF) * tick_seconds() / el * 100:.0f}% of the run, "
                      f"min margin {min(mon.margins) if mon.margins else None} C", flush=True)
                results.append({"pl1_w": level, "dramhit_lines": lines,
                                "min_margin_c": min(mon.margins) if mon.margins else None})
                if mon.abort:
                    raise SystemExit("temperature margin reached the abort threshold (dramhit)")
    finally:
        set_pl1_w(orig_w)
        now = rdmsr(0, "0x610")
        print(f"\nrestored PL1 to {read_pl1_w():.0f} W; MSR 0x610 now 0x{now} "
              f"({'identical to' if now == orig_msr else 'DIFFERS FROM'} the start value 0x{orig_msr})", flush=True)
        if needs_hugepages:
            subprocess.run(f"{ls.HUGE} reset && {ls.HUGE} {ls.DRAMHIT_RESERVATION}",
                           shell=True, stdout=subprocess.DEVNULL)
        (OUT / "pl1_check.json").write_text(json.dumps(results, indent=1))


if __name__ == "__main__":
    main()
