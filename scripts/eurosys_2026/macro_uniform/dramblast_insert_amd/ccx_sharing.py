"""Same table, same thread count, threads packed on one CCX vs spread over four.
If the ownership upgrades and the store-queue stall come from lines shared between
CCXs, they should appear only in the spread placement.

    python3 ccx_sharing.py <logdir>
"""
import sys, json, subprocess
from pathlib import Path
sys.argv = [sys.argv[0], sys.argv[1] if len(sys.argv) > 1 else "logs"]
import sq_hypotheses as h
HERE = Path(__file__).resolve().parent
# --numa-split 2 = THREADS_ASSIGN_SEQUENTIAL: 4 threads -> cpus 0-3 = CCX0.
# --numa-split 1 = THREADS_SPLIT_SEPARATE_NODES: 4 threads -> cpus 0,8,16,24 = four CCXs.
# Both leave the table MPOL_INTERLEAVE'd over all nodes (ht_helper.hpp default branch).
def cmd(split):
    c = h.dh("base", 4, 10); c[c.index("--numa-split") + 1] = str(split); return c
subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "off"], check=True, capture_output=True)
res = []
for rep in (1, 2):
    for tag, split in (("4t_one_ccx", 2), ("4t_four_ccx", 1)):
        s, _, ns, _ = h.run(f"{tag}_r{rep}", cmd(split), h.INS, "set", h.STATE, "state")
        t, dur, n, mops = h.run(f"{tag}_r{rep}", cmd(split), h.INS, "set", h.STALL, "stall")
        c = t["ls_not_halted_cyc"]
        r = dict(tag=tag, rep=rep, mops=mops, gbps=64 * (t["rd"] + t["wr"]) / dur / 1e9,
                 sq_full=t[h.STALL[1]] / c, chg_to_x_per_insert=s[h.STATE[0]] / ns,
                 stores_per_insert=t[h.STALL[2]] / n, cyc_per_insert_per_thread=c / n)
        res.append(r)
        print(json.dumps({k: (round(v, 3) if isinstance(v, float) else v) for k, v in r.items()}), flush=True)
subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "on"], check=True, capture_output=True)
(HERE / "results" / "ccx_sharing.json").write_text(json.dumps(res, indent=1))
