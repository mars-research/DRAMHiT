"""finds/s and instructions per find for every run in a stream directory (1-rep quick checks)."""
import sys, statistics as st
import runlib as r
from analyze_gap import DH_MARK
M = st.median
for d in sorted((r.HERE / "logs" / sys.argv[1]).glob("*_r*")):
    p = r.parse_program((d / "combined.log").read_text())
    iv = r.parse_stream(d / "combined.log", DH_MARK)[0]["find"]
    rows = [x["cnt"] for k, x in enumerate(iv) if 0 < k < len(iv) - 1 and x["t"] - iv[0]["t"] >= 1.0]
    ins = M([c["instructions"] / c["cycles"] for c in rows]); g = M([2.7 * c["cycles"] / c["ref-cycles"] for c in rows])
    print(f"{d.name:24s} {p['get_mops']:5d} M finds/s  {ins * g * 1e9 * 64 / (p['get_mops'] * 1e6):5.1f} instr/find  {'ok' if p['find_ops'] == p['found'] else 'MISMATCH'}")
