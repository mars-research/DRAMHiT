#!/usr/bin/env python3
"""Regenerate intel_hbm_single_skew.png from intel_hbm_single_skew.json."""

import json
from pathlib import Path

import matplotlib.pyplot as plt

SCRIPT_DIR = Path(__file__).resolve().parent
JSON_PATH = SCRIPT_DIR / "intel_hbm_single_skew.json"
PNG_PATH = SCRIPT_DIR / "intel_hbm_single_skew.png"


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

    plt.title(f"Join Performance vs. {param_name.capitalize()}", fontsize=14)
    plt.xlabel(param_name, fontsize=12)
    plt.ylabel("Throughput (Mops)", fontsize=12)
    plt.grid(True, linestyle="--", alpha=0.7)
    plt.legend(fontsize=9)
    plt.tight_layout()

    plt.savefig(PNG_PATH, dpi=300)
    print(f"[*] Plot saved to {PNG_PATH}")


if __name__ == "__main__":
    main()
