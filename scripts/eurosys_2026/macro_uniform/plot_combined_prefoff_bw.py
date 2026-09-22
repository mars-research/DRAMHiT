#!/usr/bin/env python3
"""Throughput + bandwidth, hw prefetcher off, all three machines side by side.

One 1x3 figure per phase (amd-9354p | intel-6548y | intel-max9462 hbm), each
panel drawn by plot_data_bw.draw. Every machine names its pref-off runs its
own way, so each is mapped onto the plain table name first; that way one
legend and one colour per table cover all three panels.

    python3 plot_combined_prefoff_bw.py
    -> combined_uniform_prefoff_bw_set.png, combined_uniform_prefoff_bw_get.png
"""

import json
from pathlib import Path

import plot_data_bw as pb
from plot_data_bw import ps

SCRIPT_DIR = Path(__file__).resolve().parent

# (label, json, {plain name: that json's pref-off series}, {phase: ceiling})
MACHINES = [
    ("amd-9354p", "amd/amd-9354p_uniform.json",
     {"cas": "cas", "cas23": "cas23", "folklore": "folklore",
      "dlht": "dlht", "dlht_batch16": "dlht_batch16"},
     pb.CEILINGS_AMD_9354P),
    ("intel-6548y", "intel/intel-6548y_uniform.json",
     {"cas": "cas", "cas23": "cas23", "folklore": "folklore_nopref",
      "dlht": "dlht_nopref", "dlht_batch16": "dlht_batch16"},
     {"set": pb.DEFAULT_CEILING_GBPS, "get": pb.DEFAULT_CEILING_GBPS}),
    ("intel-max9462 (hbm)", "intel_hbm/intel-max9462-hbm_uniform.json",
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


def main():
    ps.configure_style()
    palette = ps.configure_palette()
    styles = ps.styles_for(TABLES, palette)

    panels = []
    for label, path, mapping, ceilings in MACHINES:
        data = remap(pb.load(SCRIPT_DIR / path), mapping)
        panels.append((label, data, ceilings or hbm_ceilings()))

    for phase, phase_label in pb.PHASES:
        fig, axes = ps.get_subplots(1, len(panels), plot_w=5)
        for ax, (label, data, ceilings) in zip(axes, panels):
            limits = pb.axis_limits(data, ceilings)[phase]
            xticks = sorted({f for n in TABLES
                             for f in data["tables"][n]["fills"]})
            title = pb.title_for(data, f"{label}: {phase_label}",
                                 "hw prefetcher off")
            pb.draw(ax, pb.frame(data, phase), TABLES, title, palette,
                    xticks, ceilings[phase], limits, styles)
        ps.add_legend(fig, palette, TABLES, ncol=len(TABLES), styles=styles)
        pb.metric_legend(fig, 0.93)
        ps.save(fig, SCRIPT_DIR / f"combined_uniform_prefoff_bw_{phase}.png",
                legend_top=0.87)


if __name__ == "__main__":
    main()
