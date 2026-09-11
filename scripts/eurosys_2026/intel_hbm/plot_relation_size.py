#!/usr/bin/env python3
"""Plot throughput vs relation_size for all hash-join hashtables + radix join.

Reads the per-config JSON files produced by run_single_join.py
(--param-name relation_size) and overlays them on one chart.
"""

import json
from pathlib import Path

import matplotlib.pyplot as plt

SCRIPT_DIR = Path(__file__).resolve().parent

# (json file, label, marker, linestyle, color). A color of None leaves the
# line on matplotlib's default cycle, which is what the hash joins use.
CONFIGS = [
    ("intel_hbm_single_hash_cas_relation_size.json", "Hash Join (cas)", "o", "-", None),
    ("intel_hbm_single_hash_cas23_relation_size.json", "Hash Join (cas23)", "o", "-", None),
    ("intel_hbm_single_hash_dlht_relation_size.json", "Hash Join (dlht)", "o", "-", None),
    ("intel_hbm_single_hash_folklore_relation_size.json", "Hash Join (folklore)", "o", "-", None),
    ("intel_hbm_single_radix_relation_size.json", "Radix Join", "s", "--", "black"),
    # 128 threads over both sockets, each thread's partitions and hashtable in
    # its own socket's hbm node (node 0 cpus -> node 2, node 1 cpus -> node 3).
    ("intel_hbm_allcpu_radix_relation_size.json", "Radix Join (all cpus, local HBM)", "^", ":", "tab:gray"),
]

RECORD_BYTES = 16


def records_to_gib(records):
    return records * RECORD_BYTES / (1024 ** 3)


def main():
    plt.figure(figsize=(10, 6))

    x_gib = None
    for filename, label, marker, linestyle, color in CONFIGS:
        path = SCRIPT_DIR / filename
        if not path.exists():
            print(f"[!] skipping missing {filename}")
            continue

        with open(path) as f:
            data = json.load(f)

        param_values = data["param_values"]
        throughput = data["throughput_mops"]
        file_x_gib = [records_to_gib(v) for v in param_values]
        # Ticks come from the longest sweep on the chart, not whichever file
        # happened to be read last.
        if x_gib is None or len(file_x_gib) > len(x_gib):
            x_gib = file_x_gib

        # Drop failed runs (recorded as 0.0) so they don't get plotted as real data points.
        plot_x = [x for x, y in zip(file_x_gib, throughput) if y > 0]
        plot_y = [y for y in throughput if y > 0]

        plt.plot(
            plot_x,
            plot_y,
            label=label,
            marker=marker,
            linestyle=linestyle,
            linewidth=2,
            color=color,
        )

    plt.title("Join Performance vs. Relation Size (R = S)", fontsize=14)
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
    # Lower left is the only corner no curve runs through, now that the
    # all-cpu radix line sits above the hash joins.
    plt.legend(fontsize=10, loc="lower center", ncol=3)
    plt.tight_layout()

    out_path = SCRIPT_DIR / "intel_hbm_single_relation_size.png"
    plt.savefig(out_path, dpi=300)
    print(f"[*] Plot saved to {out_path}")


if __name__ == "__main__":
    main()
