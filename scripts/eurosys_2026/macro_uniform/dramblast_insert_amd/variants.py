import sys, subprocess, json, re, statistics
from pathlib import Path
OUTD = Path(sys.argv[1]); OUTD.mkdir(exist_ok=True)
sys.argv = [sys.argv[0], str(OUTD)]
import mlp, topdown_helpers as th
SP = Path(__file__).resolve().parent
BINS = {"base": "/opt/DRAMHiT/build/dramhit", "pw_enq": str(SP / "build_pw/dramhit"),
        "dist16": str(SP / "build_d16/dramhit"), "dist32": str(SP / "build_d32/dramhit")}
EV = ["ls_not_halted_cyc", "de_dis_dispatch_token_stalls1.store_queue_rsrc_stall",
      "ls_alloc_mab_count", "ls_sw_pf_dc_fills.local_l2", "ls_sw_pf_dc_fills.all"] + mlp.UMC
DH = ("test insert start", "test insert end")
subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "off"], check=True, capture_output=True)
res = []
for rep in (1, 2):
  for fill in (10, 70):
    for nt in (32, 64):
      for name, b in BINS.items():
        cmd = mlp.dramhit(nt, fill, 64); cmd[0] = b
        full = ["sudo", "perf", "stat", "-I", "100", "-x", ",", "-a", "-e", ",".join(EV), "--"] + cmd
        p = subprocess.run(full, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
        log = OUTD / f"{name}_f{fill}_t{nt}_r{rep}.log"; log.write_text(p.stdout)
        t = th.totals(log, DH)
        # duration from perf timestamps inside window
        ts = sorted({float(l.split(",")[0]) for l in p.stdout.splitlines() if re.match(r"^\s*[\d.]+,", l)})
        mops = float(re.findall(r"set_mops\s*:\s*([\d.]+)", p.stdout)[-1])
        c = t["ls_not_halted_cyc"]
        r = dict(bin=name, fill=fill, nt=nt, rep=rep, mops=mops,
                 sq_stall=t[EV[1]] / c, mab=t[EV[2]] / c,
                 swpf_l2=t[EV[3]] / max(t[EV[4]], 1), rw_lines=(t["rd"], t["wr"]), cyc=c)
        res.append(r)
        print(json.dumps(r), flush=True)
subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "on"], check=True, capture_output=True)
(OUTD / "variants.json").write_text(json.dumps(res, indent=1))
