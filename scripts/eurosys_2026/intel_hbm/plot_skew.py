#!/usr/bin/env python3
"""Plot join throughput vs zipf skew for every hashtable + radix join.

Reads intel_hbm_single_skew.json (all single-socket joins in one file, as the
older collector wrote it) and overlays the whole-machine radix sweep from
intel_hbm_allcpu_radix_skew.json when that has been collected. Style follows
../collect_join/plot_data.py so the figures sit together in the paper.
"""

import json
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns

from plot_style import (JOIN_ORDER, add_legend, axis_labels, configure_palette,
                        configure_style, draw_band, get_subplots, series_style,
                        tidy)

SCRIPT_DIR = Path(__file__).resolve().parent
JSON_PATH = SCRIPT_DIR / "intel_hbm_single_skew.json"
ALLCPU_JSON_PATH = SCRIPT_DIR / "intel_hbm_allcpu_radix_skew.json"
OUT_PATH = SCRIPT_DIR / "intel_hbm_single_skew.png"

ALLCPU_NAME = "radix (all cpus)"


def load():
    """Long-form frame of every collected curve: series / skew / mops."""
    data = json.loads(JSON_PATH.read_text())
    rows = []
    names = []

    for name in JOIN_ORDER:
        if name == "radix":
            series = data.get("radix_join_throughput")
        else:
            series = data["hash_join_throughput"].get(name)
        if not series:
            continue
        names.append(name)
        samples = (data.get("throughput_samples") or {}).get(name) or []
        for i, (skew, mops) in enumerate(zip(data["param_values"], series)):
            if mops > 0:
                point = samples[i] if i < len(samples) else None
                rows.append({"series": name, "x": skew, "mops": mops,
                             "lo": min(point) if point else float("nan"),
                             "hi": max(point) if point else float("nan")})

    if ALLCPU_JSON_PATH.exists():
        allcpu = json.loads(ALLCPU_JSON_PATH.read_text())
        names.append(ALLCPU_NAME)
        samples = allcpu.get("throughput_samples") or []
        for i, (skew, mops) in enumerate(zip(allcpu["param_values"],
                                             allcpu["throughput_mops"])):
            if mops > 0:
                point = samples[i] if i < len(samples) else None
                rows.append({"series": ALLCPU_NAME, "x": skew, "mops": mops,
                             "lo": min(point) if point else float("nan"),
                             "hi": max(point) if point else float("nan")})
    else:
        print(f"[!] skipping missing {ALLCPU_JSON_PATH.name}")

    return (pd.DataFrame(rows) if rows else None), names


def main():
    configure_style()
    palette = configure_palette(len(JOIN_ORDER))

    df, names = load()
    if df is None:
        raise SystemExit("[!] no skew data found")

    fig, axes = get_subplots(1, 1)
    ax = axes if not hasattr(axes, "ravel") else axes.ravel()[0]

    for name in names:
        sub = df[df["series"] == name].sort_values("x")
        style = series_style(name, palette)
        draw_band(ax, sub, style)
        sns.lineplot(data=sub, x="x", y="mops", ax=ax, legend=False,
                     linewidth=1.6, **style)

    xlabel, ylabel = axis_labels("skew")
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.set_title("single socket, dotted = all cpus")
    ax.set_ylim(bottom=0)
    tidy(ax)

    add_legend(fig, palette, names, ncol=3)
    plt.tight_layout(rect=[0, 0, 1, 0.90])
    plt.savefig(OUT_PATH, dpi=300)
    plt.close(fig)
    print(f"[OK] Plot saved to {OUT_PATH}")


if __name__ == "__main__":
    main()
