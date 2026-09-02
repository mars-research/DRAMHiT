#!/usr/bin/env python3
"""Plot throughput vs relation_size for all hash-join hashtables + radix join.

Reads the per-config JSON files produced by run_single_join.py
(--param-name relation_size) and overlays them on one chart.
"""

import json
from pathlib import Path

import matplotlib.pyplot as plt

SCRIPT_DIR = Path(__file__).resolve().parent

CONFIGS = [
    ("intel_hbm_single_hash_cas_relation_size.json", "Hash Join (cas)", "o", "-"),
    ("intel_hbm_single_hash_cas23_relation_size.json", "Hash Join (cas23)", "o", "-"),
    ("intel_hbm_single_hash_dlht_relation_size.json", "Hash Join (dlht)", "o", "-"),
    ("intel_hbm_single_hash_folklore_relation_size.json", "Hash Join (folklore)", "o", "-"),
    ("intel_hbm_single_radix_relation_size.json", "Radix Join", "s", "--"),
]

RECORD_BYTES = 16


def records_to_gib(records):
    return records * RECORD_BYTES / (1024 ** 3)


def main():
    plt.figure(figsize=(10, 6))

    x_gib = None
    for filename, label, marker, linestyle in CONFIGS:
        path = SCRIPT_DIR / filename
        if not path.exists():
            print(f"[!] skipping missing {filename}")
            continue

        with open(path) as f:
            data = json.load(f)

        param_values = data["param_values"]
        throughput = data["throughput_mops"]
        x_gib = [records_to_gib(v) for v in param_values]

        # Drop failed runs (recorded as 0.0) so they don't get plotted as real data points.
        plot_x = [x for x, y in zip(x_gib, throughput) if y > 0]
        plot_y = [y for y in throughput if y > 0]

        color = "black" if "Radix" in label else None
        plt.plot(
            plot_x,
            plot_y,
            label=label,
            marker=marker,
            linestyle=linestyle,
            linewidth=2,
            color=color,
        )

    plt.title("Join Performance vs. Relation Size (R = S, single NUMA node)", fontsize=14)
    plt.xlabel("Relation Size (GiB)", fontsize=12)
    plt.ylabel("Throughput (Mops)", fontsize=12)
    plt.xscale("log", base=2)
    if x_gib:
        ax = plt.gca()
        ax.set_xticks(x_gib)
        ax.set_xticklabels([str(int(v)) if v == int(v) else str(v) for v in x_gib])
        ax.minorticks_off()
    plt.ylim(bottom=0)
    plt.grid(True, linestyle="--", alpha=0.7)
    plt.legend(fontsize=10)
    plt.tight_layout()

    out_path = SCRIPT_DIR / "intel_hbm_single_relation_size.png"
    plt.savefig(out_path, dpi=300)
    print(f"[*] Plot saved to {out_path}")


if __name__ == "__main__":
    main()
