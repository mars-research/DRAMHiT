"""Little's-law profile: dramblast insert vs bandwidth_rand 1r1w, same counters."""
import sys, re, json, subprocess, statistics
from collections import defaultdict
from pathlib import Path
OUT = Path(sys.argv[1]); OUT.mkdir(exist_ok=True)
DRAMHIT = "/opt/DRAMHiT/build/dramhit"
BWR = "/opt/DRAMHiT/scripts/eurosys_2026/machine_stats/build/bandwidth_rand"
CORE = ["ls_not_halted_cyc", "ls_alloc_mab_count", "ex_ret_instr",
        "ls_dmnd_fills_from_sys.all", "ls_sw_pf_dc_fills.all"]
L3 = ["l3_xi_sampled_latency.all", "l3_xi_sampled_latency_requests.all"]
UMC = [f"amd_umc_{b}/umc_cas_cmd.{k},name={k}_b{b}/" for b in range(12) for k in ("rd", "wr")]
EV = ",".join(CORE + L3 + UMC)

def dramhit(nt, fill, q, extra=()):
    return [DRAMHIT, "--mode", "11", "--ht-type", "3", "--ht-size", str(1 << 29),
            "--ht-fill", str(fill), "--num-threads", str(nt), "--numa-split", "1",
            "--batch-len", "16", "--find_queue", str(q), "--no-prefetch", "0",
            "--hw-pref", "0", "--insert-factor", "100", "--read-factor", "1",
            "--skew", "0.01", "--seed", "1775762440565610239", *extra]

def bwr(nt, look=64, inst="t1", mode="w"):
    per = nt // 4
    pat = " ".join(f"n{n}a0-3t{per}" for n in range(4))
    return [BWR, "-m", f"{16384 // nt}mb", "-pattern", pat, "-freq", "3.25",
            "-inst", inst, "-lookahead", str(look), "-mode", mode]

def run(tag, cmd, marks):
    full = ["sudo", "perf", "stat", "-I", "100", "-x", ",", "-a", "-e", EV, "--"] + cmd
    p = subprocess.run(full, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    (OUT / f"{tag}.log").write_text(" ".join(full) + "\n" + p.stdout)
    inside, per_ts, win = False, defaultdict(lambda: defaultdict(float)), {}
    mops = re.findall(r"set_mops\s*:\s*([\d.]+)", p.stdout)
    for line in p.stdout.splitlines():
        if marks[0] in line: inside = True
        elif marks[1] in line: inside = False
        f = line.split(",")
        if len(f) < 6: continue
        try: ts = float(f[0]); v = float(f[1])
        except ValueError: continue
        name = f[3].strip()
        name = re.sub(r"_b\d+$", "", name)
        per_ts[ts][name] += v
        per_ts[ts]["run_ns_" + name] = float(f[4])  # last seen
        win.setdefault(ts, inside)
    tss = [t for t in sorted(per_ts) if win[t]][1:-1]
    tot = defaultdict(float)
    for t in tss:
        for k, v in per_ts[t].items(): tot[k] += v
    dur = tss[-1] - tss[0] + 0.1 if tss else float("nan")   # approx; intervals ~0.1 s
    # exact duration from ts deltas
    all_ts = sorted(per_ts); prev = {t: all_ts[i - 1] if i else 0.0 for i, t in enumerate(all_ts)}
    dur = sum(t - prev[t] for t in tss)
    cyc = tot["ls_not_halted_cyc"]
    r = {
        "tag": tag, "secs": round(dur, 2),
        "rd_gbps": 64 * tot["rd"] / dur / 1e9, "wr_gbps": 64 * tot["wr"] / dur / 1e9,
        "mlp_per_thread": tot["ls_alloc_mab_count"] / cyc,
        "ipc": tot["ex_ret_instr"] / cyc,
        "l3_lat_cyc": tot["l3_xi_sampled_latency.all"] / max(tot["l3_xi_sampled_latency_requests.all"], 1),
        "dmnd_fill_per_kcyc": 1000 * tot["ls_dmnd_fills_from_sys.all"] / cyc,
        "swpf_fill_per_kcyc": 1000 * tot["ls_sw_pf_dc_fills.all"] / cyc,
        "busy_cpus": cyc / dur / 3.25e9,
        "instr_g": tot["ex_ret_instr"] / 1e9, "cyc_g": cyc / 1e9,
        "dmnd_fills_g": tot["ls_dmnd_fills_from_sys.all"] / 1e9,
        "swpf_fills_g": tot["ls_sw_pf_dc_fills.all"] / 1e9,
    }
    r["tot_gbps"] = r["rd_gbps"] + r["wr_gbps"]
    if tot.get("ls_sw_pf_dc_fills.local_l2"):
        r["swpf_l2_frac"] = tot["ls_sw_pf_dc_fills.local_l2"] / tot["ls_sw_pf_dc_fills.all"]
    if tot.get("ls_pref_instr_disp.all"):
        r["pf_disp_g"] = tot["ls_pref_instr_disp.all"] / 1e9
    if mops: r["set_mops"] = float(mops[-1])
    print(json.dumps({k: (round(v, 3) if isinstance(v, float) else v) for k, v in r.items()}), flush=True)
    return r

if __name__ == "__main__":
    subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "off"], check=True)
    res = []
    DH = ("test insert start", "test insert end"); BW = ("Start perf collection", "End perf collection")
    plan = [(f"bwr_w_t{nt}", bwr(nt), BW) for nt in (32, 64)]
    plan += [(f"cas_f10_t{nt}_q64", dramhit(nt, 10, 64), DH) for nt in (32, 64)]
    plan += [(f"cas_f70_t{nt}_q64", dramhit(nt, 70, 64), DH) for nt in (32, 64)]
    for tag, cmd, marks in plan:
        res.append(run(tag, cmd, marks))
    subprocess.run(["/opt/DRAMHiT/scripts/prefetch_control_amd.sh", "on"], check=True)
    (OUT / "results.json").write_text(json.dumps(res, indent=1))
