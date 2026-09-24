#!/usr/bin/env python3
"""Throughput + bandwidth, hw prefetcher off, all three machines side by side.

One 1x3 figure per phase (amd-9354p | intel-6548y | intel-max9462 hbm), each
panel drawn by plot_data_bw.draw. Every machine names its pref-off runs its
own way, so each is mapped onto the plain table name first; that way one
legend and one colour per table cover all three panels.

The two figures are stacked in the paper, so only the top one (insertion)
carries the legend and the machine titles (the columns line up); table size,
prefetcher setting and phase are in the LaTeX caption.

    python3 plot_combined_prefoff_bw.py
    -> combined_uniform_prefoff_bw_set.png, combined_uniform_prefoff_bw_get.png
"""

import json
from pathlib import Path

from matplotlib.lines import Line2D

import plot_data_bw as pb
from plot_data_bw import ps

SCRIPT_DIR = Path(__file__).resolve().parent

# (label, json, {plain name: that json's pref-off series}, {phase: ceiling})
MACHINES = [
    ("AMD EPYC 9354P", "amd/amd-9354p_uniform.json",
     {"cas": "cas", "cas23": "cas23", "folklore": "folklore",
      "dlht": "dlht", "dlht_batch16": "dlht_batch16"},
     pb.CEILINGS_AMD_9354P),
    ("Intel Xeon Gold 6548Y+", "intel/intel-6548y_uniform.json",
     {"cas": "cas", "cas23": "cas23", "folklore": "folklore_nopref",
      "dlht": "dlht_nopref", "dlht_batch16": "dlht_batch16"},
     {"set": pb.DEFAULT_CEILING_GBPS, "get": pb.DEFAULT_CEILING_GBPS}),
    ("Intel Xeon Max 9462 (HBM)", "intel_hbm/intel-max9462-hbm_uniform.json",
     {"cas": "cas_hwpf_off", "cas23": "cas23_hwpf_off",
      "folklore": "folklore_hwpf_off", "dlht": "dlht_hwpf_off",
      "dlht_batch16": "dlht_b16_hwpf_off"},
     None),  # read from the measured ceiling json below
]

TABLES = ["cas", "cas23", "dlht", "dlht_batch16", "folklore"]


def hbm_ceilings():
    c = json.loads((SCRIPT_DIR / "intel_hbm/intel-max9462-hbm_ceiling.json")
                   .read_text())["phases"]
    return {"set": c["insertion"]["ceiling_gbps"]["0x2f"],
            "get": c["lookup"]["ceiling_gbps"]["0x2f"]}


def remap(data, mapping):
    """Keep only the pref-off series, renamed to the plain table names."""
    out = dict(data)
    out["tables"] = {plain: data["tables"][src]
                     for plain, src in mapping.items()}
    out["plot_order"] = TABLES
    return out


def legend(fig, styles):
    """Tables and the filled/open marker key, in one row above the panels."""
    handles = [Line2D([0], [0], label=ps.display_name(n), **styles[n])
               for n in TABLES]
    handles += [
        Line2D([0], [0], color="0.25", linestyle="none", marker="o",
               markersize=5, label="throughput (left axis)"),
        Line2D([0], [0], color="0.25", linestyle="none", marker="o",
               markersize=5, markerfacecolor="none",
               label="bandwidth (right axis)"),
    ]
    fig.legend(handles=handles, fontsize=8, loc="upper center",
               ncol=len(handles))


def main():
    ps.configure_style()
    palette = ps.configure_palette()
    styles = ps.styles_for(TABLES, palette)

    panels = []
    for label, path, mapping, ceilings in MACHINES:
        data = remap(pb.load(SCRIPT_DIR / path), mapping)
        panels.append((label, data, ceilings or hbm_ceilings()))

    for i, (phase, _) in enumerate(pb.PHASES):
        fig, axes = ps.get_subplots(1, len(panels), plot_w=5)
        for ax, (label, data, ceilings) in zip(axes, panels):
            limits = pb.axis_limits(data, ceilings)[phase]
            xticks = sorted({f for n in TABLES
                             for f in data["tables"][n]["fills"]})
            title = f"{label}, {data['num_threads']} threads" if i == 0 else None
            pb.draw(ax, pb.frame(data, phase), TABLES, title, palette,
                    xticks, ceilings[phase], limits, styles)
        if i == 0:
            legend(fig, styles)
        ps.save(fig, SCRIPT_DIR / f"combined_uniform_prefoff_bw_{phase}.png",
                legend_top=0.9 if i == 0 else 1.0)


if __name__ == "__main__":
    main()
