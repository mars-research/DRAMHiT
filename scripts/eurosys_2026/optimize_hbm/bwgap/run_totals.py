#!/usr/bin/env python3
"""E2/E4: per-line costs by the differential-totals method.

    python3 run_totals.py --set core   [--reps 3]     # E2: bw t1, bw double+24, dramhit fill 10 / 90
    python3 run_totals.py --set ladder [--reps 2]     # E4: t1pad / t1dpad with N = 0..48

Each workload is run at 1x work and at 2x work (dramhit: --read-factor 100 vs 200;
bandwidth_rand: NUM_ITERATIONS 100 vs 200, two binaries). Whole-process socket-0 totals of
user-mode instructions, cycles and ref-cycles, and of HBM read/write CAS, are taken for each.
The cost per line is the DIFFERENCE between the two runs divided by the difference in work:
setup, allocation and (for dramhit) the whole insert phase are identical in both runs and
cancel, so no phase windows, interval parsing or sampling are involved.
The order alternates between reps (small then large, large then small).
Logs: logs/<out>/<workload>_x<1|2>_r<k>/{cmd.txt,program.out,perf.csv,meta.json}.
"""
import argparse
import runlib as r

def core():
    w = {}
    w["bw_t1"] = (lambda: r.bw_cmd("t1", iters=100), lambda: r.bw_cmd("t1", iters=200), 100, 200)
    w["bw_double24"] = (lambda: r.bw_cmd("double", iters=100, pad=24), lambda: r.bw_cmd("double", iters=200, pad=24), 100, 200)
    for f in (10, 90):
        w[f"dramhit_rck_f{f}"] = ((lambda f=f: r.dramhit_cmd(fill=f, read_factor=100)),
                                  (lambda f=f: r.dramhit_cmd(fill=f, read_factor=200)), None, None)
    return w

def ladder():
    w = {}
    for kind in ("t1pad", "t1dpad"):
        for pad in (0, 8, 16, 24, 32, 48):
            w[f"{kind}_p{pad}"] = ((lambda k=kind, p=pad: r.bw_cmd(k, iters=100, pad=p)),
                                   (lambda k=kind, p=pad: r.bw_cmd(k, iters=200, pad=p)), 100, 200)
    return w

def mimic():
    w = {}
    for stage in (1, 2, 3, 4, 5):
        for pad in (0, 16):
            w[f"mimic_s{stage}_p{pad}"] = ((lambda s=stage, p=pad: r.bw_cmd("mimic", iters=100, pad=p, stage=s)),
                                           (lambda s=stage, p=pad: r.bw_cmd("mimic", iters=200, pad=p, stage=s)), 100, 200)
    return w


def keybind():
    new = str(r.OPT / "attempt6" / "ddrhbm" / "dramhit")
    w = {}
    for name, binary, env in (("rck_orig", str(r.DRAMHIT), ""), ("new_keys_ddr", new, "env NO_KEY_BIND=1 "),
                              ("new_keys_hbm", new, "")):
        w[f"dramhit_{name}_f10"] = ((lambda b=binary, e=env: e + r.dramhit_cmd(fill=10, read_factor=100, binary=b)),
                                    (lambda b=binary, e=env: e + r.dramhit_cmd(fill=10, read_factor=200, binary=b)), None, None)
    return w


def dpad():
    w = {}
    for kind in ("double", "t1pad"):
        for pad in (0, 8, 16, 24, 32, 48):
            w[f"{kind}_p{pad}"] = ((lambda k=kind, p=pad: r.bw_cmd(k, iters=100, pad=p)),
                                   (lambda k=kind, p=pad: r.bw_cmd(k, iters=200, pad=p)), 100, 200)
    return w


def energy():
    w = {}
    for k in ("bw_t1", "bw_double24", "dramhit_rck_f10"):
        w[k] = core()[k]
    w.update(dpad())
    for stage in (1, 2, 3, 4, 5):
        w[f"mimic_s{stage}_p0"] = mimic()[f"mimic_s{stage}_p0"]
    return w


def capsweep():
    c = core()
    return {"bw_t1": c["bw_t1"], "dramhit_rck_f10": c["dramhit_rck_f10"]}


def threads():
    w = {}
    for n in (8, 16, 24, 32, 48, 64):
        w[f"bw_t1_t{n}"] = ((lambda n=n: r.bw_cmd("t1", iters=100, threads=n)),
                            (lambda n=n: r.bw_cmd("t1", iters=200, threads=n)), 100, 200)
    return w


def vec():
    # attempt7: deep-vectorization variants of the find fast path (keys-in-HBM harness)
    w = {}
    for v in ("base", "emb", "vec4s", "vec4"):
        b = str(r.OPT / "attempt7" / v / "dramhit")
        w[f"a7_{v}_f10"] = ((lambda b=b: r.dramhit_cmd(fill=10, read_factor=100, binary=b)),
                            (lambda b=b: r.dramhit_cmd(fill=10, read_factor=200, binary=b)), None, None)
    return w


SETS = {"vec": vec, "threads": threads, "energy": energy, "capsweep": capsweep, "dpad": dpad, "core": core, "ladder": ladder, "mimic": mimic, "keybind": keybind}

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--set", choices=list(SETS), default="core")
    ap.add_argument("--reps", type=int, default=3)
    ap.add_argument("--start-rep", type=int, default=1, help="first rep number (to append reps to an existing set)")
    ap.add_argument("--only", nargs="+")
    ap.add_argument("--reserve", action="store_true")
    ap.add_argument("--out")
    ap.add_argument("--cap", type=int, help="cpufreq cap in MHz on node 0 cpus for the whole run (restored after)")
    a = ap.parse_args()
    if a.reserve:
        r.reserve_pool()
    specs = SETS[a.set]()
    names = a.only or list(specs)
    out = a.out or f"E2_totals_{a.set}"
    base = r.HERE / "logs" / out
    import contextlib, sys
    sys.path.insert(0, str(r.OPT / "fbfull"))
    from cpufreq_cap import capped
    ctx = capped(a.cap) if a.cap else contextlib.nullcontext()
    ctx.__enter__()
    try:
      for rep in range(a.start_rep, a.reps + 1):
        for n in names:
            small, large, i1, i2 = specs[n]
            order = [("x1", small, i1), ("x2", large, i2)]
            if rep % 2 == 0:
                order.reverse()
            for tag, cmd, iters in order:
                print(f"[{out}] rep {rep}/{a.reps}  {n}  {tag}", flush=True)
                r.run_totals(cmd(), base / f"{n}_{tag}_r{rep}", f"{n}_{tag}", iters)
    finally:
      ctx.__exit__(None, None, None)
    print("[OK]")

if __name__ == "__main__":
    main()
