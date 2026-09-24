import sys, json, subprocess
sys.argv = [sys.argv[0], sys.argv[1]]
import mlp
from pathlib import Path
SETS = {
 "A": ["ls_not_halted_cyc", "de_no_dispatch_per_slot.no_ops_from_frontend",
       "de_no_dispatch_per_slot.backend_stalls", "ex_ret_ops", "de_src_op_disp.all"],
 "B": ["ls_not_halted_cyc", "ex_no_retire.load_not_complete", "ex_no_retire.not_complete",
       "de_no_dispatch_per_slot.smt_contention", "ex_ret_instr"],
}
DH = ("test insert start", "test insert end"); BW = ("Start perf collection", "End perf collection")
cases = [("cas_t32", mlp.dramhit(32, 10, 64), DH), ("cas_t64", mlp.dramhit(64, 10, 64), DH),
         ("bwr_t32", mlp.bwr(32), BW), ("bwr_t64", mlp.bwr(64), BW)]
subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "off"], check=True, capture_output=True)
import re
from collections import defaultdict
def totals(log, marks):
    inside, per, win = False, defaultdict(lambda: defaultdict(float)), {}
    for line in open(log):
        if marks[0] in line: inside = True
        elif marks[1] in line: inside = False
        f = line.split(",")
        if len(f) < 6: continue
        try: ts = float(f[0]); v = float(f[1])
        except ValueError: continue
        per[ts][re.sub(r"_b\d+$", "", f[3].strip())] += v; win.setdefault(ts, inside)
    tot = defaultdict(float)
    for t in [t for t in sorted(per) if win[t]][1:-1]:
        for k, v in per[t].items(): tot[k] += v
    return tot
out = {}
for tag, cmd, marks in cases:
    t = {}
    for s, ev in SETS.items():
        full = ["sudo", "perf", "stat", "-I", "100", "-x", ",", "-a", "-e", ",".join(ev), "--"] + cmd
        p = subprocess.run(full, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        log = Path(sys.argv[1]) / f"td_{tag}_{s}.log"; log.write_text(p.stdout)
        tot = totals(log, marks)
        t[s] = tot
    A, B = t["A"], t["B"]
    slots = 6 * A["ls_not_halted_cyc"]
    fe = A["de_no_dispatch_per_slot.no_ops_from_frontend"] / slots
    be = A["de_no_dispatch_per_slot.backend_stalls"] / slots
    ret = A["ex_ret_ops"] / slots
    bad = (A["de_src_op_disp.all"] - A["ex_ret_ops"]) / slots
    smt = B["de_no_dispatch_per_slot.smt_contention"] / (6 * B["ls_not_halted_cyc"])
    memfrac = B["ex_no_retire.load_not_complete"] / B["ex_no_retire.not_complete"]
    r = dict(retiring=ret, frontend=fe, bad_spec=bad, backend=be, smt_contention=smt,
             backend_memory=be * memfrac, backend_cpu=be * (1 - memfrac),
             ops_per_instr=A["ex_ret_ops"] / B["ex_ret_instr"] * B["ls_not_halted_cyc"] / A["ls_not_halted_cyc"])
    out[tag] = r
    print(tag, "  ".join(f"{k} {v:.3f}" for k, v in r.items()), flush=True)
subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "on"], check=True, capture_output=True)
(Path(sys.argv[1]) / "topdown.json").write_text(json.dumps(out, indent=1))
