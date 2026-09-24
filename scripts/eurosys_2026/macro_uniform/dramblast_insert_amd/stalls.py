import sys, subprocess, json
from pathlib import Path
sys.argv = [sys.argv[0], sys.argv[1]]
import mlp, topdown_helpers as th
EV = ["ls_not_halted_cyc", "de_dis_dispatch_token_stalls1.store_queue_rsrc_stall",
      "de_dis_dispatch_token_stalls1.load_queue_rsrc_stall",
      "de_dis_dispatch_token_stalls2.retire_token_stall", "ex_no_retire.not_complete"]
DH = ("test insert start", "test insert end"); BW = ("Start perf collection", "End perf collection")
subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "off"], check=True, capture_output=True)
for tag, cmd, marks in [("cas_t32", mlp.dramhit(32, 10, 64), DH), ("cas_t64", mlp.dramhit(64, 10, 64), DH),
                        ("bwr_t32", mlp.bwr(32), BW), ("bwr_t64", mlp.bwr(64), BW)]:
    full = ["sudo", "perf", "stat", "-I", "100", "-x", ",", "-a", "-e", ",".join(EV), "--"] + cmd
    p = subprocess.run(full, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    log = Path(sys.argv[1]) / f"st_{tag}.log"; log.write_text(p.stdout)
    t = th.totals(log, marks); c = t["ls_not_halted_cyc"]
    print(f"{tag}: cycles with store-queue-full stall {t[EV[1]]/c:.2f}  load-queue-full {t[EV[2]]/c:.2f}  retire(ROB)-full {t[EV[3]]/c:.2f}  oldest-op-incomplete {t[EV[4]]/c:.2f}", flush=True)
subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "on"], check=True, capture_output=True)
