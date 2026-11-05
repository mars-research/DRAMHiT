#!/usr/bin/env python3
"""results.json (+ prof/f<fill>.sym.txt) -> ground_truth.md and ground_truth.json.

Units: "thread-cycles" = core clock cycles of one hardware thread (2.5 GHz, = TSC). 64 threads run on
32 cores (2 per core), so core-cycles per find = thread-cycles / 2 (per-core throughput).
A find_batch call takes batch_len = 64 keys; in steady state it completes 64 finds on average.
"""
import json, re, statistics as st
from pathlib import Path

HERE = Path(__file__).resolve().parent
BATCH = 64
GHZ = 2.5
med = lambda xs: st.median(xs) if xs else float("nan")


def fb_share(fill):
    """fraction of find-phase cycles in CASHashTable::find_batch, from the perf report."""
    p = HERE / "prof" / f"f{fill}.sym.txt"
    if not p.exists():
        return None, []
    rows = []
    for line in p.read_text().splitlines():
        m = re.match(r"\s*([0-9.]+)%\s+\[.\]\s+(.*)", line)
        if m:
            rows.append((float(m.group(1)), m.group(2).strip()))
    fb = sum(pct for pct, s in rows if "::find_batch(" in s)
    return fb / 100.0, rows


def main():
    res = json.loads((HERE / "results.json").read_text())
    out, md = {}, []
    for fill in sorted(k for k in res if k.isdigit()):
        R = res[fill]
        plain = [e["stats"] for e in R.get("plain", [])]
        cpf = [s["thread_cycles_per_find"] for s in plain]
        mops = [s["get_mops"] for s in plain]
        # per-find medians of every event across all counter-set runs
        ev = {}
        for cset, runs in R.items():
            if cset == "plain":
                continue
            for r in runs:
                for e, v in r["per_find"].items():
                    ev.setdefault(e, []).append(v)
        pf = {e: med(v) for e, v in ev.items()}
        g = lambda e: pf.get(e, float("nan"))
        share, rows = fb_share(fill)
        tc = med(cpf)
        d = {
            "fill": int(fill),
            "plain_reps": len(plain),
            "thread_cycles_per_find": tc, "thread_cycles_per_find_reps": cpf,
            "core_cycles_per_find": tc / 2,
            "finds_mops": med(mops), "finds_mops_reps": mops,
            "thread_cycles_per_find_batch_call": tc * BATCH,
            "find_batch_cycle_share": share,
            "find_batch_thread_cycles_per_find": tc * share if share else None,
            "find_batch_thread_cycles_per_call": tc * share * BATCH if share else None,
            "instructions_per_find": g("instructions"),
            "ipc_thread": g("instructions") / g("cycles"),
            "dram_rd_lines_per_find": g("unc_m_cas_count.rd"),
            "dram_wr_lines_per_find": g("unc_m_cas_count.wr"),
            "dram_rd_GBps": g("unc_m_cas_count.rd") * med(mops) * 1e6 * 64 / 1e9,
            "llc_miss_drd_per_find": g("unc_cha_tor_inserts.ia_miss_drd"),
            "llc_miss_drd_latency_ns": g("unc_cha_tor_occupancy.ia_miss_drd") / g("unc_cha_tor_inserts.ia_miss_drd") / GHZ,
            "offcore_data_rd_per_find": g("offcore_requests.data_rd"),
            "offcore_data_rd_latency_cycles": g("offcore_requests_outstanding.data_rd") / g("offcore_requests.data_rd"),
            "l1_pending_misses_avg": g("l1d_pend_miss.pending") / g("cycles"),
            "fb_full_frac_cycles": g("l1d_pend_miss.fb_full") / g("cycles"),
            "stalls_total_frac": g("cycle_activity.stalls_total") / g("cycles"),
            "stalls_l1d_miss_frac": g("cycle_activity.stalls_l1d_miss") / g("cycles"),
            "per_find": pf,
        }
        out[fill] = d
    (HERE / "ground_truth.json").write_text(json.dumps(out, indent=1))

    fills = list(out)
    T = lambda k, fmt="{:.2f}": "| " + k + " | " + " | ".join(
        fmt.format(out[f][k]) if out[f][k] is not None else "–" for f in fills) + " |"
    md += ["# dramblast deep build (dvk_rka) ground truth, d760 socket 0", "",
           "| metric | " + " | ".join(f"fill {f}" for f in fills) + " |", "|---|" + "---|" * len(fills)]
    for k in ["thread_cycles_per_find", "core_cycles_per_find", "finds_mops", "thread_cycles_per_find_batch_call",
              "find_batch_cycle_share", "find_batch_thread_cycles_per_find", "find_batch_thread_cycles_per_call",
              "instructions_per_find", "ipc_thread", "dram_rd_lines_per_find", "dram_wr_lines_per_find",
              "dram_rd_GBps", "llc_miss_drd_per_find", "llc_miss_drd_latency_ns", "offcore_data_rd_per_find",
              "offcore_data_rd_latency_cycles", "l1_pending_misses_avg", "fb_full_frac_cycles",
              "stalls_total_frac", "stalls_l1d_miss_frac"]:
        md.append(T(k, "{:.3f}" if "frac" in k or "share" in k or "ipc" in k else "{:.2f}"))
    md += ["", "## all events, per find (median over runs; core events summed over socket 0's 64 threads)", "",
           "| event | " + " | ".join(f"fill {f}" for f in fills) + " |", "|---|" + "---|" * len(fills)]
    for e in sorted({e for f in fills for e in out[f]["per_find"]}):
        md.append(f"| {e} | " + " | ".join(f"{out[f]['per_find'].get(e, float('nan')):.4f}" for f in fills) + " |")
    (HERE / "ground_truth.md").write_text("\n".join(md) + "\n")
    print("\n".join(md))


if __name__ == "__main__":
    main()
