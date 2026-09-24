import sys, json, subprocess
sys.argv = [sys.argv[0], sys.argv[1]]
import mlp
from pathlib import Path
mlp.CORE = ["ls_not_halted_cyc", "ls_alloc_mab_count", "ls_pref_instr_disp.all",
            "ls_sw_pf_dc_fills.local_l2", "ls_sw_pf_dc_fills.all"]
mlp.EV = ",".join(mlp.CORE + mlp.L3 + mlp.UMC)
# re-map derived fields: reuse run() but read extra totals from its log via a small wrapper
orig = mlp.run
def run(tag, cmd, marks):
    r = orig(tag, cmd, marks)
    return r
DH = ("test insert start", "test insert end")
subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "off"], check=True)
for nt in (32, 64):
    for q in (16, 32, 64, 128, 256):
        run(f"q_t{nt}_q{q}", mlp.dramhit(nt, 10, q), DH)
subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "on"], check=True)
