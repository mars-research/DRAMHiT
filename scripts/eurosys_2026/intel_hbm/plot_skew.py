#!/usr/bin/env python3
"""Regenerate intel_hbm_single_skew.png from intel_hbm_single_skew.json.

The all-cpu radix join sweep (run_single_join.py --join-type radix
--cpu-scope all --param-name skew) is overlaid on top when its own json is
present, so the one-socket and whole-machine radix curves sit on the same
axes as the hash joins.
"""

import json
from pathlib import Path

import matplotlib.pyplot as plt

SCRIPT_DIR = Path(__file__).resolve().parent
JSON_PATH = SCRIPT_DIR / "intel_hbm_single_skew.json"
ALLCPU_JSON_PATH = SCRIPT_DIR / "intel_hbm_allcpu_radix_skew.json"
PNG_PATH = SCRIPT_DIR / "intel_hbm_single_skew.png"


def plot_allcpu_radix():
    """Overlay the 128-thread, hbm-local radix join if it has been collected."""
    if not ALLCPU_JSON_PATH.exists():
        print(f"[!] skipping missing {ALLCPU_JSON_PATH.name}")
        return

    with open(ALLCPU_JSON_PATH) as f:
        data = json.load(f)

    # Failed runs are recorded as 0.0; don't draw them as real data points.
    points = [
        (x, y) for x, y in zip(data["param_values"], data["throughput_mops"]) if y > 0
    ]
    if not points:
        print(f"[!] {ALLCPU_JSON_PATH.name} has no successful runs")
        return

    threads = data.get("num_threads", 128)
    plt.plot(
        [x for x, _ in points],
        [y for _, y in points],
        label=f"Radix Join (all cpus, {threads}t, local HBM)",
        marker="^",
        color="tab:gray",
        linewidth=2,
        linestyle=":",
    )


def main():
    with open(JSON_PATH) as f:
        data = json.load(f)

    param_name = data["param_name"]
    param_values = data["param_values"]

    plt.figure(figsize=(10, 6))

    for variant_name, throughput in data["hash_join_throughput"].items():
        plt.plot(
            param_values,
            throughput,
            label=f"Hash Join ({variant_name})",
            marker="o",
            linewidth=2,
        )

    if data.get("radix_join_throughput"):
        plt.plot(
            param_values,
            data["radix_join_throughput"],
            label="Radix Join (Prefetch ON)",
            marker="s",
            color="black",
            linewidth=2,
            linestyle="--",
        )

    plot_allcpu_radix()

    plt.title(f"Join Performance vs. {param_name.capitalize()}", fontsize=14)
    plt.xlabel(param_name, fontsize=12)
    plt.ylabel("Throughput (Mops)", fontsize=12)
    plt.grid(True, linestyle="--", alpha=0.7)
    # Leave headroom above the fastest curve so the legend sits over empty
    # space instead of over the all-cpu radix line.
    ax = plt.gca()
    _, y_top = ax.get_ylim()
    ax.set_ylim(top=y_top * 1.12)
    plt.legend(fontsize=9, loc="upper right")
    plt.tight_layout()

    plt.savefig(PNG_PATH, dpi=300)
    print(f"[*] Plot saved to {PNG_PATH}")


if __name__ == "__main__":
    main()
