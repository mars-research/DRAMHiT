import sys, subprocess
from pathlib import Path
OUTD = Path(sys.argv[1]); sys.argv = [sys.argv[0], str(OUTD)]
import mlp, topdown_helpers as th
SP = Path(__file__).resolve().parent
EV = ["ls_not_halted_cyc", "ls_pref_instr_disp.all", "ls_inef_sw_pref.all",
      "ls_sw_pf_dc_fills.all", "ls_dmnd_fills_from_sys.all"]
DH = ("test insert start", "test insert end"); BW = ("Start perf collection", "End perf collection")
subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "off"], check=True, capture_output=True)
cases = []
for nt in (32, 64):
    for name, b in (("base", "/opt/DRAMHiT/build/dramhit"), ("pw_enq", str(SP / "build_pw/dramhit"))):
        cmd = mlp.dramhit(nt, 10, 64); cmd[0] = b; cases.append((f"{name}_t{nt}", cmd, DH))
    cases.append((f"bwr_t{nt}", mlp.bwr(nt), BW))
for tag, cmd, marks in cases:
    full = ["sudo", "perf", "stat", "-I", "100", "-x", ",", "-a", "-e", ",".join(EV), "--"] + cmd
    p = subprocess.run(full, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    log = OUTD / f"pf_{tag}.log"; log.write_text(p.stdout)
    t = th.totals(log, marks)
    d, inef, fill, dm = (t[e] for e in EV[1:])
    print(f"{tag:11} swpf issued {d/1e9:6.2f}G  redundant {inef/d:5.1%}  filled {fill/d:5.1%}  DROPPED {(d-inef-fill)/d:5.1%} | demand fills from beyond L2 {dm/1e9:5.2f}G ({dm/max(fill,1):.2f} per swpf fill)", flush=True)
subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "on"], check=True, capture_output=True)
