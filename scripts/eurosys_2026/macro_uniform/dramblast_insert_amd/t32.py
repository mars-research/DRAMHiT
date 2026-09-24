import sys, json, statistics
from pathlib import Path
sys.path.insert(0, '/opt/DRAMHiT/scripts/eurosys_2026/macro_uniform')
import collect_data_amd as c
OUT = Path(sys.argv[1]); REPS = 5; FILL = 70
c.set_prefetcher("off")
res = {}
for nt, n in ((32, 3), (64, 3), (32, 2), (64, 2)):   # interleaved so drift hits both equally
    c.NUM_THREADS = nt
    cmd = c.dramhit_cmd(c.TABLES["cas"], FILL)
    for _ in range(n):
        idx = len(res.get(nt, [])) + 1
        m, err = c.run_point(cmd, OUT / f"t{nt}_fill{FILL}_rep{idx}.log")
        if err: print(nt, err); continue
        res.setdefault(nt, []).append(m)
        b = m["bw"].get("set", {}); g = m["bw"].get("get", {})
        print(f"t{nt} rep{idx} set {m['set_mops']:.0f} get {m['get_mops']:.0f} | set bw {b.get('gbps')} ({b.get('rd_gbps')}/{b.get('wr_gbps')}) get bw {g.get('gbps')}", flush=True)
c.set_prefetcher("on")
summary = {}
for nt, ms in res.items():
    summary[nt] = {k: statistics.median(v) for k, v in {
        "set_mops": [m["set_mops"] for m in ms], "get_mops": [m["get_mops"] for m in ms],
        "set_bw": [m["bw"]["set"]["gbps"] for m in ms], "set_rd": [m["bw"]["set"]["rd_gbps"] for m in ms],
        "set_wr": [m["bw"]["set"]["wr_gbps"] for m in ms], "get_bw": [m["bw"]["get"]["gbps"] for m in ms]}.items()}
    summary[nt]["n"] = len(ms)
    summary[nt]["set_samples"] = [m["set_mops"] for m in ms]
print(json.dumps(summary, indent=1))
(OUT / "summary.json").write_text(json.dumps({"raw": {k: v for k, v in res.items()}, "summary": summary}, indent=1))
