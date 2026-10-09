#!/usr/bin/env python3
"""E1: the as-shipped comparison. Interleaved repetitions of three workloads, each under
`perf stat -a --per-socket -I 200`, raw output kept.

    python3 run_stream.py [--reps 5] [--workloads bw_t1 bw_double24 dramhit_rck_f10] [--reserve]

Order is rep-major (rep 1: every workload, rep 2: every workload, ...), so drift during the
session spreads over all workloads. Logs: logs/E1_stream/<workload>_r<k>/{cmd.txt,combined.log,meta.json}.
The 1 GiB + 2 MiB hugepage pool is NOT re-reserved between runs (--reserve does it once, first).
"""
import argparse
import subprocess
import sys
from pathlib import Path

import runlib as r

WORKLOADS = {
    "bw_t1":           lambda: r.bw_cmd("t1", pad=0),
    "bw_t1_c2200":     lambda: r.bw_cmd("t1", pad=0),     # same program; run with --cap 2200 (core clock held at 2.2 GHz)
    "bw_double24":     lambda: r.bw_cmd("double", pad=24, near=8),
    "dramhit_rck_f10": lambda: r.dramhit_cmd(fill=10),
    "dramhit_rck_f90": lambda: r.dramhit_cmd(fill=90),
    # attempt6 build = rck + harness change: local key partitions bound to HBM when numa_split == 10
    "dramhit_keyshbm_f10": lambda: r.dramhit_cmd(fill=10, binary=str(r.OPT / "attempt6" / "ddrhbm" / "dramhit")),
    "dramhit_keysddr_f10": lambda: "env NO_KEY_BIND=1 " + r.dramhit_cmd(fill=10, binary=str(r.OPT / "attempt6" / "ddrhbm" / "dramhit")),
    # E5 mimic stages (bw_double built up toward the find loop); stages 1-4 keep their 64 keys in L1,
    # stage 5 streams dramblast's 0.84 M x 8 B keys per thread: MIMIC_KEY_NODE=2 puts them in HBM, 0 in DDR
    **{f"mimic_s{s}": (lambda s=s: r.bw_cmd("mimic", pad=0, stage=s)) for s in (1, 2, 3, 4)},
    "mimic_s5_keyshbm": lambda: "env MIMIC_KEY_NODE=2 " + r.bw_cmd("mimic", pad=0, stage=5),
    "mimic_s5_keysddr": lambda: "env MIMIC_KEY_NODE=0 " + r.bw_cmd("mimic", pad=0, stage=5),
    # 32 threads = one per core (cpus 0..62 even; their siblings 64..126 stay idle)
    "bw_t1_t32":     lambda: r.bw_cmd("t1", pad=0, threads=32),
    "mimic_s4_t32":  lambda: r.bw_cmd("mimic", pad=0, stage=4, threads=32),
    # 16-thread versions (low system load): is the per-miss time difference core-local?
    "bw_t1_t16":     lambda: r.bw_cmd("t1", pad=0, threads=16),
    "mimic_s2_t16":  lambda: r.bw_cmd("mimic", pad=0, stage=2, threads=16),
    "mimic_s4_t16":  lambda: r.bw_cmd("mimic", pad=0, stage=4, threads=16),
    # bw_t1 with a shorter prefetch lookahead (fewer misses in flight): its latency-vs-bandwidth curve
    **{f"bw_t1_la{la}": (lambda la=la: r.bw_cmd("t1", pad=0, lookahead=la)) for la in (4, 8, 12, 16, 24, 32, 48)},
    # attempt10 sweep: DEEP_VECTORIZATION over find-queue length x batch length (key prefetch 64 ahead, t2)
    **{f"a10_dv_q{fq}_b{bl}": (lambda fq=fq, bl=bl: "env KEY_PF_DIST=64 KEY_PF_HINT=t2 " + r.dramhit_cmd(
        fill=10, find_queue=fq, batch_len=bl, binary=str(r.OPT / "attempt10" / "deepvec" / "dramhit")))
       for fq in (32, 64, 128, 256) for bl in (16, 32, 64)},
    **{f"a10_{v}_q{fq}_b{bl}": (lambda v=v, fq=fq, bl=bl: "env KEY_PF_DIST=64 KEY_PF_HINT=t2 " + r.dramhit_cmd(
        fill=10, find_queue=fq, batch_len=bl, binary=str(r.OPT / "attempt10" / v / "dramhit")))
       for v in ("deepvec", "deepvec_sp") for fq, bl in ((128, 64), (64, 32))},
    # E23 fill sweep: deep vectorization vs the same build without it (queue 128, batch 64, key prefetch 64 t2);
    # read factor scaled with fill so the find phase stays ~5 s (finds = fill x capacity x read factor)
    **{f"a11_{v}_f{f}": (lambda v=v, f=f: "env KEY_PF_DIST=64 KEY_PF_HINT=t2 " + r.dramhit_cmd(
        fill=f, read_factor=(4000 + f // 2) // f, find_queue=128, batch_len=64,
        binary=str(r.OPT / "attempt10" / v / "dramhit")))
       for v in ("q16", "deepvec", "ig", "igr") for f in range(10, 100, 10)},
    # E26: deep pop/push (rewritten DEEP_VECTORIZATION), find queue x batch length at fill 10 and 90
    **{f"a12_{v}_q{fq}_b{bl}_f{f}": (lambda v=v, fq=fq, bl=bl, f=f: "env KEY_PF_DIST=64 KEY_PF_HINT=t2 " + r.dramhit_cmd(
        fill=f, read_factor=(4000 + f // 2) // f, find_queue=fq, batch_len=bl,
        binary=str(r.OPT / "attempt10" / v / "dramhit")))
       for v in ("q16", "deepvec", "deepvec_pretrim") for fq in (32, 64, 128, 256) for bl in (16, 32, 64, 128, 256) for f in (10, 90)},
    # E29: L1 prefetch distance of the deep find path (attempt10/pf<d>), batch 64
    **{f"a13_pf{d}_q{fq}_f{f}": (lambda d=d, fq=fq, f=f: "env KEY_PF_DIST=64 KEY_PF_HINT=t2 " + r.dramhit_cmd(
        fill=f, read_factor=(4000 + f // 2) // f, find_queue=fq, batch_len=64,
        binary=str(r.OPT / "attempt10" / f"pf{d}" / "dramhit")))
       for d in (8, 16, 24, 32) for fq in (64, 128) for f in (10, 90)},
    # E30: SIMD multiplicative hash (HASHER=mult) vs crc; deep (distance 24) and scalar, queue 128 / batch 64
    **{f"a14_{v}_f{f}": (lambda v=v, f=f: "env KEY_PF_DIST=64 KEY_PF_HINT=t2 " + r.dramhit_cmd(
        fill=f, read_factor=(4000 + f // 2) // f, find_queue=128, batch_len=64,
        binary=str(r.OPT / "attempt10" / v / "dramhit")))
       for v in ("dc24", "dm24", "dm24s", "qc", "qm") for f in (10, 50, 90)},
    # E31: current deep build (distance 24) vs scalar, fill 10..90, queue 128 / batch 64
    **{f"a15_{v}_f{f}": (lambda v=v, f=f: "env KEY_PF_DIST=64 KEY_PF_HINT=t2 " + r.dramhit_cmd(
        fill=f, read_factor=(4000 + f // 2) // f, find_queue=128, batch_len=64,
        binary=str(r.OPT / "attempt10" / v / "dramhit")))
       for v in ("dc24", "qc", "dc24s", "qcs", "dc24s_kid") for f in range(10, 100, 10)},
    "a10_q16_q64_b16": lambda: "env KEY_PF_DIST=64 KEY_PF_HINT=t2 " + r.dramhit_cmd(
        fill=10, find_queue=64, batch_len=16, binary=str(r.OPT / "attempt10" / "q16" / "dramhit")),
    # attempt9: 16 B find-queue entries / 4-entry block push+pop; all with the best key prefetch (64 ahead, t2)
    **{f"a9_{v}": (lambda v=v: "env KEY_PF_DIST=64 KEY_PF_HINT=t2 " + r.dramhit_cmd(fill=10, binary=str(r.OPT / "attempt9" / v / "dramhit")))
       for v in ("base", "q16", "q16x", "q16v", "v4")},
    # attempt8: find key-stream prefetch placement (env knobs in zipfian_test.cpp), keys in HBM
    **{f"a8_{n}": (lambda e=e: (f"env {e} " if e else "") + r.dramhit_cmd(fill=10, binary=str(r.OPT / "attempt8" / "dramhit")))
       for n, e in [("base", ""), ("off", "KEY_PF_DIST=0"),
                    ("d32", "KEY_PF_DIST=32"), ("d64", "KEY_PF_DIST=64"), ("d128", "KEY_PF_DIST=128"), ("d256", "KEY_PF_DIST=256"),
                    ("d64t2", "KEY_PF_DIST=64 KEY_PF_HINT=t2"), ("d128t2", "KEY_PF_DIST=128 KEY_PF_HINT=t2"),
                    ("b64", "KEY_PF_DIST=64 KEY_PF_MODE=batch"), ("b128", "KEY_PF_DIST=128 KEY_PF_MODE=batch")]},
    # attempt7: deep-vectorization variants of the find fast path (keys-in-HBM harness)
    **{f"a7_{v}_f10": (lambda v=v: r.dramhit_cmd(fill=10, binary=str(r.OPT / "attempt7" / v / "dramhit")))
       for v in ("base", "emb", "vec4s", "vec4")},
}

def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--reps", type=int, default=5)
    ap.add_argument("--start-rep", type=int, default=1)
    ap.add_argument("--workloads", nargs="+", default=["bw_t1", "bw_double24", "dramhit_rck_f10"], choices=list(WORKLOADS))
    ap.add_argument("--interval-ms", type=int, default=200)
    ap.add_argument("--reserve", action="store_true")
    ap.add_argument("--out", default="E1_stream")
    ap.add_argument("--cap", type=int, help="cpufreq cap (MHz) on node 0 cpus, restored after")
    ap.add_argument("--cha-set", choices=list(r.CHA_SETS), help="extra uncore CHA events (runlib.CHA_SETS)")
    ap.add_argument("--core-set", choices=list(r.CORE_SETS), help="replace the 4 programmable core events (runlib.CORE_SETS)")
    ap.add_argument("--cpus", help='"user": core events in user mode only (idle cpus spin in the kernel poll loop)')
    ap.add_argument("--mesh", type=int, help="pin socket-0 uncore (mesh) clock: sysfs min = max = MHz, restored after")
    ap.add_argument("--read-factor", type=int, default=100, help="dramhit find passes (longer find phase = more intervals)")
    a = ap.parse_args()
    if a.reserve:
        r.reserve_pool()
    base = r.HERE / "logs" / a.out
    import contextlib
    sys.path.insert(0, str(r.OPT / "fbfull"))
    from cpufreq_cap import capped
    with (capped(a.cap) if a.cap else contextlib.nullcontext()), \
         (r.mesh_pinned(a.mesh) if a.mesh else contextlib.nullcontext()):
        for rep in range(a.start_rep, a.reps + 1):
            for w in a.workloads:
                d = base / f"{w}_r{rep}"
                print(f"[{a.out}] rep {rep}/{a.reps}  {w}", flush=True)
                cmd = WORKLOADS[w]()
                if "--read-factor 100" in cmd:
                    cmd = cmd.replace("--read-factor 100", f"--read-factor {a.read_factor}")
                r.run_stream(cmd, d, w, a.interval_ms, a.cha_set, a.core_set, a.cpus)
    print("[OK]")

if __name__ == "__main__":
    main()
