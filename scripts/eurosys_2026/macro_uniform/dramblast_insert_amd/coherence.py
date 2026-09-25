"""Where do insert-path L1 fills come from? Tests whether cross-CCX cache-to-cache
transfers (true coherence traffic) are a meaningful share.

    python3 coherence.py <logdir>

pw_enq (one prefetchw at enqueue) fetches each bucket line from its origin straight
into L1, so ls_sw_pf_dc_fills.<source> gives the origin split. base is included too;
there most prefetchw fills come from local L2 (the t1 prefetch landed first).
"""
import sys, subprocess, json, re
from pathlib import Path
OUTD = Path(sys.argv[1]); OUTD.mkdir(exist_ok=True)
sys.argv = [sys.argv[0], str(OUTD)]
import mlp
from variants2 import window  # same windowing as the §6 tables
HERE = Path(__file__).resolve().parent
SRC = ["local_l2", "local_ccx", "near_cache", "far_cache", "dram_io_near", "dram_io_far"]
SETS = [["ls_sw_pf_dc_fills." + s for s in SRC[:3]] + ["ls_not_halted_cyc"],
        ["ls_sw_pf_dc_fills." + s for s in SRC[3:]] + ["ls_dmnd_fills_from_sys.near_cache",
                                                       "ls_dmnd_fills_from_sys.far_cache"]]
BINS = {"base": "/opt/DRAMHiT/build/dramhit", "pw_enq": str(HERE / "build_pw/dramhit")}
subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "off"], check=True, capture_output=True)
res = []
for fill in (10, 70):
  for nt in (32, 64):
    for name, b in BINS.items():
      tot, ins = {}, []
      for i, ev in enumerate(SETS):
        cmd = mlp.dramhit(nt, fill, 64); cmd[0] = b
        full = ["sudo", "perf", "stat", "-I", "100", "-x", ",", "-a", "-e", ",".join(ev), "--"] + cmd
        p = subprocess.run(full, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        (OUTD / f"coh_{name}_f{fill}_t{nt}_s{i}.log").write_text(p.stdout)
        t, dur = window(p.stdout)
        mops = float(re.findall(r"set_mops\s*:\s*([\d.]+)", p.stdout)[-1])
        n = mops * 1e6 * dur
        for e in ev: tot[e] = t[e] / n       # per insert, from that run's own window
      pf = {s: tot["ls_sw_pf_dc_fills." + s] for s in SRC}
      allpf = sum(pf.values())
      r = dict(bin=name, fill=fill, nt=nt,
               pf_fills_per_insert=allpf, **{f"pf_{s}": pf[s] / allpf for s in SRC},
               other_ccx_per_insert=pf["near_cache"] + pf["far_cache"]
                   + tot["ls_dmnd_fills_from_sys.near_cache"] + tot["ls_dmnd_fills_from_sys.far_cache"])
      res.append(r)
      print(f"{name:6} f{fill} t{nt}  pf fills/insert {allpf:.2f} | "
            + "  ".join(f"{s} {100*pf[s]/allpf:5.2f}%" for s in SRC)
            + f" | from another CCX's cache: {100*r['other_ccx_per_insert']:.2f}% of inserts", flush=True)
subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "on"], check=True, capture_output=True)
(HERE / "results" / "coherence.json").write_text(json.dumps(res, indent=1))
