"""Single-prefetch insert schemes vs the double prefetch, plus stores per insert.

    python3 variants2.py <logdir>      (run ./build_variants.sh first)
"""
import sys, subprocess, json, re
from collections import defaultdict
from pathlib import Path
OUTD = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("logs")
OUTD.mkdir(exist_ok=True)
sys.argv = [sys.argv[0], str(OUTD)]
import mlp
HERE = Path(__file__).resolve().parent
BINS = {"base": "/opt/DRAMHiT/build/dramhit",           # t2 at enqueue + prefetchw 8 ahead
        "pw_enq": str(HERE / "build_pw/dramhit"),       # prefetchw at enqueue only
        "t1only": str(HERE / "build_t1only/dramhit"),   # PREFETCHT1_ONLY: t1 at enqueue only
        "t0only": str(HERE / "build_t0only/dramhit"),   # t0 at enqueue only
        "none": str(HERE / "build_none/dramhit")}       # no insert prefetch
EV = ["ls_not_halted_cyc", "de_dis_dispatch_token_stalls1.store_queue_rsrc_stall",
      "ls_alloc_mab_count", "ls_dmnd_fills_from_sys.all", "ls_dispatch.store_dispatch"] + mlp.UMC
DH = ("test insert start", "test insert end")

def window(text):
    inside, per, win = False, defaultdict(lambda: defaultdict(float)), {}
    for line in text.splitlines():
        if DH[0] in line: inside = True
        elif DH[1] in line: inside = False
        f = line.split(",")
        if len(f) < 6: continue
        try: ts = float(f[0]); v = float(f[1])
        except ValueError: continue
        per[ts][re.sub(r"_b\d+$", "", f[3].strip())] += v; win.setdefault(ts, inside)
    tss = sorted(per); prev = {t: (tss[i - 1] if i else 0.0) for i, t in enumerate(tss)}
    w = [t for t in tss if win[t]][1:-1]
    tot = defaultdict(float)
    for t in w:
        for k, v in per[t].items(): tot[k] += v
    return tot, sum(t - prev[t] for t in w)

def main():
    subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "off"], check=True, capture_output=True)
    res = []
    for rep in (1, 2):
      for fill in (10, 70):
        for nt in (32, 64):
          for name, b in BINS.items():
            cmd = mlp.dramhit(nt, fill, 64); cmd[0] = b
            full = ["sudo", "perf", "stat", "-I", "100", "-x", ",", "-a", "-e", ",".join(EV), "--"] + cmd
            p = subprocess.run(full, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
            (OUTD / f"v2_{name}_f{fill}_t{nt}_r{rep}.log").write_text(p.stdout)
            t, dur = window(p.stdout)
            mops = float(re.findall(r"set_mops\s*:\s*([\d.]+)", p.stdout)[-1])
            c = t["ls_not_halted_cyc"]; inserts = mops * 1e6 * dur
            r = dict(bin=name, fill=fill, nt=nt, rep=rep, mops=mops,
                     gbps=64 * (t["rd"] + t["wr"]) / dur / 1e9,
                     rd=64 * t["rd"] / dur / 1e9, wr=64 * t["wr"] / dur / 1e9,
                     sq_stall=t[EV[1]] / c, mab=t[EV[2]] / c,
                     dmnd_per_insert=t[EV[3]] / inserts, stores_per_insert=t[EV[4]] / inserts)
            res.append(r); print(json.dumps(r), flush=True)
    subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "on"], check=True, capture_output=True)
    (HERE / "results" / "variants2.json").write_text(json.dumps(res, indent=1))


if __name__ == "__main__":
    main()
