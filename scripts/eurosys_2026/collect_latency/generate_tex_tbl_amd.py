#!/usr/bin/env python3
"""Build LaTeX table from amd_results/ (latency.c + mlc latency matrix)."""
import re
from pathlib import Path

RES = Path(__file__).parent / "amd_results"
NODES = range(4)
TSC_GHZ = 3.25  # EPYC 9354P base/TSC frequency


def latency_c(mem, cpu, loaded):
    txt = (RES / f"latency_mem{mem}_cpu{cpu}_loaded{loaded}.txt").read_text()
    return float(re.search(r"Sample Mean.*\(([\d.]+) cycles/cacheline", txt).group(1))


def mlc_matrix(name):
    lines = (RES / name).read_text().splitlines()
    mat = {}
    for l in lines:
        f = l.split()
        if len(f) == 5 and f[0].isdigit():
            mat[int(f[0])] = [float(x) for x in f[1:]]
    return mat  # mat[cpu_node][mem_node]


idle = {(c, m): latency_c(m, c, 0) for c in NODES for m in NODES}
load = {(c, m): latency_c(m, c, 1) for c in NODES for m in NODES}
mlc = mlc_matrix("mlc_latency_matrix_rand.txt")


def row(c, d, fmt):
    return " & ".join(fmt(d(c, m)) for m in NODES)


body = []
for c in NODES:
    cells = [
        row(c, lambda c, m: idle[c, m] / TSC_GHZ, lambda v: f"{v:.1f}"),
        row(c, lambda c, m: load[c, m] / TSC_GHZ, lambda v: f"{v:.1f}"),
        row(c, lambda c, m: mlc[c][m], lambda v: f"{v:.1f}"),
    ]
    body.append(f"CPU node {c} & " + " & ".join(cells) + " \\\\\n\\hline")

hdr_nodes = " & ".join(["0", "1", "2", "3"] * 3)
tex = r"""\begin{table*}[t] \centering \small \setlength{\tabcolsep}{5pt}
\renewcommand{\arraystretch}{1.2}

\begin{tabular}{|l|cccc|cccc||cccc|}
\hline

& \multicolumn{4}{c|}{\textbf{Idle (ns)}}
& \multicolumn{4}{c||}{\textbf{Loaded (ns)}}
& \multicolumn{4}{c|}{\textbf{MLC Idle (ns)}} \\
\cline{2-13}

Memory node & """ + hdr_nodes + r""" \\
\hline\hline
""" + "\n".join(body) + r"""

\end{tabular}

\caption{AMD EPYC 9354P (1 socket, NPS4) pointer-chase latency per cacheline. Idle/Loaded: \texttt{latency.c} (1\,GB random permutation, TSC cycles converted to ns at """ + f"{TSC_GHZ}" + r"""\,GHz); Loaded: one loader thread per hyperthread on the memory node (14 when local, since the latency core is excluded; 16 when remote). MLC: \texttt{mlc --latency\_matrix -r}.}
\label{tab:amd-latency}
\end{table*}
"""
out = Path(__file__).parent / "tbl-amd-latency.tex"
out.write_text(tex)
print(tex)
