"""One extra column for report §12.3: the same metrics and formulas as analyze_100ms.py (steady = t >= 1.0 s,
boundary intervals dropped; median of all steady intervals [median of per-rep medians; min-max of per-rep medians]),
for one workload of any run directory.  usage: col_e12.py <logs dir> <workload>"""
import sys, statistics as st
import runlib as r
from analyze_100ms import intervals
M = st.median
base, n = r.HERE / "logs" / sys.argv[1], sys.argv[2]
reps = []
for d in sorted(base.glob(f"{n}_r*")):
    meta, prog, iv, is_bw = intervals(d)
    steady = [x for x in iv if x["t_rel"] >= 1.0]
    lines_s = prog["get_mops"] * 1e6
    reps.append(dict(steady=steady, lines_s=lines_s, window=prog["find_ops"] / lines_s))
def stat(k, p):
    per = [M([x[k] for x in rep["steady"]]) for rep in reps]
    allv = M([x[k] for rep in reps for x in rep["steady"]])
    return f"{allv:.{p}f} [{M(per):.{p}f}; {min(per):.{p}f}–{max(per):.{p}f}]", allv
print("reps", len(reps), "steady intervals/rep", [len(x["steady"]) for x in reps])
for k, p in [("hbm_gbps", 1), ("core_ghz", 3), ("mesh_ghz", 3), ("ipc", 2), ("instr_gps_per_thread", 2), ("pkg_w", 1), ("xq_pct", 1), ("fb_pct", 1)]:
    print(k, stat(k, p)[0])
print("lines/s (G)", f"{M([x['lines_s'] for x in reps]) / 1e9:.3f}")
print("window (s)", f"{M([x['window'] for x in reps]):.2f}")
print("energy per program line (nJ)", f"{M([M([x['pkg_w'] for x in rep['steady']]) / rep['lines_s'] * 1e9 for rep in reps]):.1f}")
print("energy per HBM line (nJ)", f"{M([M([x['pkg_w'] / (x['hbm_gbps'] * 1e9 / 64) * 1e9 for x in rep['steady']]) for rep in reps]):.1f}")
print("HBM lines per program line", f"{M([M([x['hbm_gbps'] for x in rep['steady']]) * 1e9 / (rep['lines_s'] * 64) for rep in reps]):.3f}")
print("cycles per HBM line", f"{M([M([64 * x['core_ghz'] * 1e9 / (x['hbm_gbps'] * 1e9 / 64) for x in rep['steady']]) for rep in reps]):.1f}")
