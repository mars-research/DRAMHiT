"""Tests H1 (bucket store waits for ownership at commit) vs H2 (bookkeeping stores
alone fill the store queue). See amd_dramblast_insert_analysis.md section 9.

    python3 sq_hypotheses.py <logdir>    (needs build_variants.sh builds)
"""
import sys, subprocess, json, re
from pathlib import Path
OUTD = Path(sys.argv[1]); OUTD.mkdir(exist_ok=True)
sys.argv = [sys.argv[0], str(OUTD)]
import mlp
from variants2 import window
HERE = Path(__file__).resolve().parent
B = {"base": "/opt/DRAMHiT/build/dramhit", "t1only": str(HERE / "build_t1only/dramhit"),
     "pw_enq": str(HERE / "build_pw/dramhit"), "t0only": str(HERE / "build_t0only/dramhit"),
     "nostore": str(HERE / "build_nostore/dramhit")}
STATE = ["l2_request_g1.change_to_x", "l2_cache_req_stat.ls_rd_blk_x",
         "l2_cache_req_stat.ls_rd_blk_l_hit_s", "l2_cache_req_stat.ls_rd_blk_l_hit_x",
         "l2_cache_req_stat.ls_rd_blk_c"]
STALL = ["ls_not_halted_cyc", "de_dis_dispatch_token_stalls1.store_queue_rsrc_stall",
         "ls_dispatch.store_dispatch", "ls_st_commit_cancel2.st_commit_cancel_wcb_full", "ex_ret_instr"] + mlp.UMC
INS = ("test insert start", "test insert end"); FND = ("test find start", "test find end")

def dh(b, nt, fill, size=1 << 29, ins=100, rd=1):
    c = mlp.dramhit(nt, fill, 64); c[0] = B[b]
    c[c.index("--ht-size") + 1] = str(size)
    c[c.index("--insert-factor") + 1] = str(ins); c[c.index("--read-factor") + 1] = str(rd)
    return c

CASES = [  # tag, cmd, window, mops key
    ("base_t32",        dh("base", 32, 10),    INS, "set"),
    ("t1only_t32",      dh("t1only", 32, 10),  INS, "set"),
    ("pw_enq_t32",      dh("pw_enq", 32, 10),  INS, "set"),
    ("t0only_t32",      dh("t0only", 32, 10),  INS, "set"),
    ("nostore_t32",     dh("nostore", 32, 10), INS, "set"),
    ("base_t64",        dh("base", 64, 10),    INS, "set"),
    ("nostore_t64",     dh("nostore", 64, 10), INS, "set"),
    ("base_1t_incache", dh("base", 1, 10, size=32768, ins=100000), INS, "set"),
    ("base_1t_dram",    dh("base", 1, 10, ins=5), INS, "set"),
    ("base_t32_find",   dh("base", 32, 10, ins=1, rd=400), FND, "get"),
]

def run(tag, cmd, marks, key, events, sfx):
    full = ["sudo", "perf", "stat", "-I", "100", "-x", ",", "-a", "-e", ",".join(events), "--"] + cmd
    p = subprocess.run(full, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    (OUTD / f"sq_{tag}_{sfx}.log").write_text(p.stdout)
    import variants2
    variants2.DH = marks
    t, dur = window(p.stdout)
    mops = float(re.findall(rf"{key}_mops\s*:\s*([\d.]+)", p.stdout)[-1])
    return t, dur, mops * 1e6 * dur, mops

if __name__ == "__main__":
    subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "off"], check=True, capture_output=True)
    res = []
    for tag, cmd, marks, key in CASES:
        s, _, ns, _ = run(tag, cmd, marks, key, STATE, "state")
        t, dur, nt_, mops = run(tag, cmd, marks, key, STALL, "stall")
        c = t["ls_not_halted_cyc"]
        r = dict(tag=tag, mops=mops,
                 gbps=64 * (t["rd"] + t["wr"]) / dur / 1e9 if dur else 0,
                 sq_full=t[STALL[1]] / c,
                 stores_per_op=t[STALL[2]] / nt_,
                 commit_cancel_per_op=t[STALL[3]] / nt_,
                 instr_per_op=t[STALL[4]] / nt_,
                 chg_to_x_per_op=s[STATE[0]] / ns,
                 l2_store_or_statechg_hit_per_op=s[STATE[1]] / ns,
                 l2_hit_nonmodifiable_per_op=s[STATE[2]] / ns,
                 l2_hit_modifiable_per_op=s[STATE[3]] / ns,
                 l2_miss_per_op=s[STATE[4]] / ns)
        res.append(r)
        print(f"{tag:16} {mops:7.0f} Mops {r['gbps']:6.1f} GB/s | SQ full {r['sq_full']:.2f} | per op: stores {r['stores_per_op']:.1f} "
              f"commit-cancel {r['commit_cancel_per_op']:.3f} | chg_to_x {r['chg_to_x_per_op']:.3f} "
              f"L2 st/chg-hit {r['l2_store_or_statechg_hit_per_op']:.3f} L2 rd-hit nonmod {r['l2_hit_nonmodifiable_per_op']:.3f} "
              f"mod {r['l2_hit_modifiable_per_op']:.3f} L2 miss {r['l2_miss_per_op']:.3f}", flush=True)
    subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "on"], check=True, capture_output=True)
    (HERE / "results" / "sq_hypotheses.json").write_text(json.dumps(res, indent=1))
