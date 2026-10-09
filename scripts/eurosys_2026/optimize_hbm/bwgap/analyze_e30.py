"""E30: SIMD multiplicative hash (HASHER=mult) vs crc32, deep pop/push (distance 24) and scalar, queue 128 /
batch 64, fills 10/50/90, 3 reps. Buckets read per find ~ HBM read lines per find - 0.125 (the 8 B key stream,
8 keys per line). -> tables/E30.md"""
import statistics as st
import runlib as r
from analyze_gap import DH_MARK
M = st.median
BASE = r.HERE / "logs" / "E30_hash"
NAMES = {"qc": "scalar, crc", "qm": "scalar, mult", "dc24": "deep, crc", "dm24": "deep, mult (SIMD hash)"}


def per_rep(d):
    iv = r.parse_stream(d / "combined.log", DH_MARK)[0]["find"]
    p = r.parse_program((d / "combined.log").read_text())
    assert p["find_ops"] == p["found"], d
    R = [x for k, x in enumerate(iv) if 0 < k < len(iv) - 1 and "hbm_ns" in x and x["t"] - iv[0]["t"] >= 1.0]
    c = lambda x: x["cnt"]
    bw = M([(x["hbm_rd_B"] + x["hbm_wr_B"]) / x["hbm_ns"] for x in R])
    rd = M([x["hbm_rd_B"] / x["hbm_ns"] for x in R])
    ipc = M([c(x)["instructions"] / c(x)["cycles"] for x in R]); g = M([r.REF_GHZ * c(x)["cycles"] / c(x)["ref-cycles"] for x in R])
    return dict(mops=p["get_mops"], set=p["set_mops"], bw=bw, bpf=rd * 1e9 / 64 / (p["get_mops"] * 1e6) - 0.125,
                ipf=ipc * g * 1e9 * 64 / (p["get_mops"] * 1e6), ghz=g)


out = ["## E30: SIMD multiplicative hash vs crc32 (`logs/E30_hash`, queue 128 / batch 64, key prefetch 64 t2, 3 reps)\n",
       "| fill | build | finds/s (M) [min-max] | inserts/s (M) | HBM GB/s | buckets read per find | instr per find | core GHz |",
       "|---|---|---|---|---|---|---|---|"]
for f in (10, 50, 90):
    for v in ("qc", "qm", "dc24", "dm24"):
        reps = [per_rep(d) for d in sorted(BASE.glob(f"a14_{v}_f{f}_r*"))]
        g = lambda k: M([p[k] for p in reps]); mo = [p["mops"] for p in reps]
        out.append(f"| {f} | {NAMES[v]} | {g('mops'):.0f} [{min(mo):.0f}-{max(mo):.0f}] | {g('set'):.0f} | {g('bw'):.1f} | {g('bpf'):.3f} | {g('ipf'):.1f} | {g('ghz'):.3f} |")
txt = "\n".join(out)
(r.HERE / "tables" / "E30.md").write_text(txt + "\n")
print(txt)
