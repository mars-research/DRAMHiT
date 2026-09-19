#!/usr/bin/env python3
"""Plot the single-controller thread sweep collected by sweep_imc.py.

Three panels against core count, all for ONE iMC on socket 0:

  bandwidth        what the controller actually delivers
  RPQ occupancy    time-averaged entries resident in the Read Pending Queue
  RPQ insert rate  reads arriving at the controller per second

Read together they say where the knee comes from: bandwidth stops rising while
occupancy keeps climbing, which is the queue absorbing cores the DRAM can no
longer serve faster.

Style comes from ../paper_style.py (see ../PLOTTING.md). The series here are
not hashtables, so the palette is built explicitly at the number of lines drawn
rather than at len(PALETTE_ORDER).

    python3 plot_imc_sweep.py
"""
import sys
from pathlib import Path

import pandas as pd

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR.parent))

import paper_style as ps  # noqa: E402

CSV = SCRIPT_DIR / "imc_thread_sweep.csv"
OUT = SCRIPT_DIR / "imc_thread_sweep.png"

# The sub-channel pair is drawn alongside the channel total on the occupancy
# panel, so that panel needs 3 colours; build one palette at that size and let
# the other panels take slot 0.
PALETTE_N = 3


def band(ax, g, col, style, label=None, scale=1.0):
    """Mean line with a min/max band over the repeats.

    The label goes on the line, never on the fill: handing ax.legend() a bare
    list of strings makes it label whatever artists the axes happens to hold,
    and the fill_between bands are in that list too, so the names slide onto
    the wrong artists.
    """
    m = g[col].mean() * scale
    ax.plot(m.index, m.values, label=label, **style)
    lo, hi = g[col].min() * scale, g[col].max() * scale
    ax.fill_between(m.index, lo.values, hi.values,
                    color=style["color"], alpha=0.18, linewidth=0)


def main():
    df = pd.read_csv(CSV)
    g = df.groupby("threads")

    ps.configure_style()
    pal = ps.configure_palette(PALETTE_N)
    fig, axes = ps.get_subplots(1, 3, plot_w=4.2, plot_h=3.6)

    s0 = {"color": pal[0], "marker": "o", "linestyle": "-", "markersize": 4, "linewidth": 1.6}
    s1 = {"color": pal[1], "marker": "s", "linestyle": "--", "markersize": 3.5, "linewidth": 1.2}
    s2 = {"color": pal[2], "marker": "^", "linestyle": ":", "markersize": 3.5, "linewidth": 1.2}

    # --- bandwidth -----------------------------------------------------------
    ax = axes[0]
    band(ax, g, "bw_prog_gbs", s0)
    ax.set_xlabel("cores (socket 0)")
    ax.set_ylabel("bandwidth (GB/s)")
    ax.set_title("one iMC: delivered read bandwidth", fontsize=9)
    ax.set_ylim(bottom=0)
    ps.tidy(ax)

    # --- RPQ occupancy -------------------------------------------------------
    ax = axes[1]
    band(ax, g, "rpq_occ_chan", s0, label="channel (pch0+pch1)")
    band(ax, g, "rpq_occ_pch0", s1, label="sub-channel 0")
    band(ax, g, "rpq_occ_pch1", s2, label="sub-channel 1")
    ax.set_xlabel("cores (socket 0)")
    ax.set_ylabel("RPQ occupancy (entries)")
    ax.set_title("read pending queue occupancy", fontsize=9)
    ax.set_ylim(bottom=0)
    ax.legend(fontsize=7)
    ps.tidy(ax)

    # --- RPQ insertion rate --------------------------------------------------
    ax = axes[2]
    band(ax, g, "rpq_ins_rate_mps", s0)
    ax.set_xlabel("cores (socket 0)")
    ax.set_ylabel("RPQ inserts (M/s)")
    ax.set_title("read pending queue insertion rate", fontsize=9)
    ax.set_ylim(bottom=0)
    ps.tidy(ax)

    ps.save(fig, OUT, legend_top=0.99)
    print(f"[*] wrote {OUT}")

    # A compact table next to the figure, since the numbers are the point.
    summ = g[["bw_prog_gbs", "rpq_occ_chan", "rpq_ins_rate_mps",
              "rpq_lat_cycles", "concentration"]].mean()
    summ["concentration"] *= 100
    summ.columns = ["bw GB/s", "RPQ occ", "ins M/s", "lat clk", "conc %"]
    print(summ.round(2).to_string())


if __name__ == "__main__":
    main()
