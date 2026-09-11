#!/usr/bin/env python3
"""Build/probe phase comparison of cas hash join vs radix join, at one point.

Holds relation size (R = S = 8 GiB) and machine scope (single socket) fixed and
varies two things: the skew, and how the cas hashtable prefetches (a
compile-time choice, hence a rebuild per variant).

--prefetch-builds moves both paths at once via -DPREFETCH:

  DOUBLE  insert: prefetcht1 when the entry is queued + prefetchw when it is
                  dequeued; probe: prefetcht2 queued + prefetcht0 dequeued.
  L1      a single prefetch on each path: prefetchw on insert, prefetcht0 on
          probe.
  NONE    no software prefetch on either path.

--insert-builds instead holds the probe path fixed and moves only the insert
path, via -DCAS_PREFETCH_INSERTION (DOUBLE / PREFETCHW / NONE), which is the
knob for tuning the build phase on its own.

Radix join reads none of that -- its RadixArrayHashTable issues no software
prefetches -- so it is run under every build as a control: its spread across
the three is the run-to-run noise floor for everything else here.

Both joins report their two phases, which is the point of the comparison:
hash join splits into build (inserting R) and probe (looking up S), radix join
into partition (streaming R and S into cache-sized buckets) and join (building
and probing one small table per partition). The phases are compared as cycles
per tuple of R+S, the one denominator both joins share.
"""

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))

import run_single_join as rsj  # noqa: E402  (needs SCRIPT_DIR on the path first)

LOG_ROOT = SCRIPT_DIR / "logs" / "prefetch_phase_compare"
JSON_PATH = SCRIPT_DIR / "intel_hbm_single_prefetch_phases.json"
PNG_PATH = SCRIPT_DIR / "intel_hbm_single_prefetch_phases.png"

CPUFREQ_MHZ = 2700

# One point in the relation-size sweep: R = S = 8 GiB, in 16-byte tuples.
RELATION_SIZE = 8 * rsj.one_gb
SKEWS = [0.1, 1.0]
PREFETCH_BUILDS = ["DOUBLE", "L1", "NONE"]
INSERT_CHOICES = ["DOUBLE", "PREFETCHW", "NONE"]
SCOPE = rsj.CPU_SCOPES["single"]


class Variant:
    """One build: a -DPREFETCH choice plus a -DCAS_PREFETCH_INSERTION choice.

    AUTO means the insert path follows PREFETCH, which is how the knob behaved
    before it existed, so `Variant("DOUBLE")` is the stock build.
    """

    def __init__(self, prefetch, insert="AUTO"):
        self.prefetch = prefetch
        self.insert = insert
        self.label = prefetch if insert == "AUTO" else f"{prefetch}\nins={insert}"
        self.key = prefetch if insert == "AUTO" else f"{prefetch}+ins_{insert}"


CMAKE_BASE = (
    "cmake -S /opt/DRAMHiT/ -B /opt/DRAMHiT/build "
    "-DDRAMHiT_VARIANT=2025_INLINE -DBUCKETIZATION=ON -DBRANCH=simd "
    "-DUNIFORM_PROBING=ON -DGROWT=ON -DCPUFREQ_MHZ=2700"
)

# Phase lines printed by print_stats (src/misc_lib.cpp).
HASH_BUILD_RE = re.compile(r"build_phrase_mops\s*:\s*(\d+),\s*cycle_per_op\s*:\s*(\d+)")
HASH_PROBE_RE = re.compile(r"probe_phrase_mops\s*:\s*(\d+),\s*cycle_per_op\s*:\s*(\d+)")
RADIX_PART_RE = re.compile(
    r"partition phase cycles:\s*(\d+),\s*partition_cycle_per_tuple:\s*(\d+)"
)
RADIX_JOIN_RE = re.compile(r"join phase cycles:\s*(\d+),\s*join_cycle_per_tuple:\s*(\d+)")
TOTAL_RE = re.compile(r"throughput_mops\s*:\s*(\d+).*?duration:\s*(\d+)")


def build_dramhit(variant):
    """Clean rebuild of one variant."""
    print(f"\n[*] === rebuilding with -DPREFETCH={variant.prefetch} "
          f"-DCAS_PREFETCH_INSERTION={variant.insert} ===", flush=True)
    subprocess.run("rm -rf /opt/DRAMHiT/build", shell=True, check=True)
    subprocess.run(f"{CMAKE_BASE} -DPREFETCH={variant.prefetch} "
                   f"-DCAS_PREFETCH_INSERTION={variant.insert}",
                   shell=True, check=True, stdout=subprocess.DEVNULL)
    subprocess.run("cmake --build /opt/DRAMHiT/build -j $(nproc)", shell=True,
                   check=True, stdout=subprocess.DEVNULL)


def run_one(join_type, variant, skew, log_path):
    """Runs one configuration and pulls both phases out of the log."""
    if join_type == "hash":
        ht_variant = dict(rsj.HASH_JOIN_VARIANTS["cas"])
        rsj.set_prefetcher(ht_variant.get("prefetcher", "off"))
        overrides = {k: v for k, v in ht_variant.items() if k != "prefetcher"}
        overrides["skew"] = skew
        cmd = rsj.build_command(rsj.HASH_JOIN_DEFAULTS, "relation_size",
                                RELATION_SIZE, SCOPE, overrides)
    else:
        rsj.set_prefetcher("on")
        cmd = rsj.build_command(rsj.RADIX_JOIN_DEFAULTS, "relation_size",
                                RELATION_SIZE, SCOPE, {"skew": skew})

    print(f"    Running: {' '.join(cmd)}", flush=True)
    result = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                            text=True)
    log_path.parent.mkdir(parents=True, exist_ok=True)
    log_path.write_text(result.stdout)

    out = result.stdout
    threads = SCOPE["num_threads"]
    total_tuples = 2 * RELATION_SIZE  # R + S
    row = {
        "join": "hash_cas" if join_type == "hash" else "radix",
        "variant": variant.key,
        "prefetch": variant.prefetch,
        "cas_prefetch_insertion": variant.insert,
        "skew": skew,
        "log": str(log_path),
    }

    total = TOTAL_RE.search(out)
    if not total:
        print("    -> ERROR: no throughput line; see log", flush=True)
        return None
    row["throughput_mops"] = int(total.group(1))
    row["total_cycles"] = int(total.group(2))

    if join_type == "hash":
        b, p = HASH_BUILD_RE.search(out), HASH_PROBE_RE.search(out)
        if not (b and p):
            print("    -> ERROR: no phase lines; see log", flush=True)
            return None
        # cycle_per_op counts cycles summed over threads per op of that phase;
        # renormalise both phases to cycles per tuple of R+S so the hash and
        # radix phases can be read off the same axis.
        row["phase1_name"], row["phase2_name"] = "build", "probe"
        row["phase1_mops"], row["phase2_mops"] = int(b.group(1)), int(p.group(1))
        row["phase1_cycles_per_own_op"] = int(b.group(2))
        row["phase2_cycles_per_own_op"] = int(p.group(2))
        row["phase1_cycles"] = int(b.group(2)) * RELATION_SIZE // threads
        row["phase2_cycles"] = int(p.group(2)) * RELATION_SIZE // threads
    else:
        part, join = RADIX_PART_RE.search(out), RADIX_JOIN_RE.search(out)
        if not (part and join):
            print("    -> ERROR: no phase lines; see log", flush=True)
            return None
        row["phase1_name"], row["phase2_name"] = "partition", "join"
        row["phase1_cycles"] = int(part.group(1))
        row["phase2_cycles"] = int(join.group(1))
        # Both radix phases stream R+S, so their own-op cost is the normalised one.
        row["phase1_cycles_per_own_op"] = int(part.group(2))
        row["phase2_cycles_per_own_op"] = int(join.group(2))
        row["phase1_mops"] = CPUFREQ_MHZ * total_tuples // max(row["phase1_cycles"], 1)
        row["phase2_mops"] = CPUFREQ_MHZ * total_tuples // max(row["phase2_cycles"], 1)

    for phase in ("phase1", "phase2"):
        row[f"{phase}_cpt"] = row[f"{phase}_cycles"] * threads / total_tuples
    row["total_cpt"] = row["total_cycles"] * threads / total_tuples

    # Self-check the renormalisation: the two phases have to add up to the
    # end-to-end cost, and radix's phases (which already stream R+S) have to
    # land on the cycle-per-tuple figures dramhit printed itself. Either check
    # failing means the thread count or the denominator is wrong, which would
    # otherwise show up only as a plausible-looking but wrong bar.
    phase_sum = row["phase1_cpt"] + row["phase2_cpt"]
    if abs(phase_sum - row["total_cpt"]) > 0.05 * max(row["total_cpt"], 1):
        print(f"    -> WARNING: phases sum to {phase_sum:.1f} but end-to-end is "
              f"{row['total_cpt']:.1f} cyc/tuple", flush=True)
    if join_type != "hash":
        for phase in ("phase1", "phase2"):
            printed = row[f"{phase}_cycles_per_own_op"]
            if abs(row[f"{phase}_cpt"] - printed) > 1.5:
                print(f"    -> WARNING: {row[f'{phase}_name']} computed "
                      f"{row[f'{phase}_cpt']:.1f} but dramhit printed {printed} "
                      f"cyc/tuple", flush=True)

    print(
        f"    -> {row['throughput_mops']} Mops | "
        f"{row['phase1_name']} {row['phase1_cpt']:.1f} cyc/tuple | "
        f"{row['phase2_name']} {row['phase2_cpt']:.1f} cyc/tuple",
        flush=True,
    )
    return row


def print_table(rows):
    print("\n" + "=" * 100)
    print(f"cas hash join vs radix join, R = S = 8 GiB, single socket "
          f"({SCOPE['num_threads']} threads, node 0 cpus, node 2 hbm)")
    print("cycles/tuple are normalised to R+S, so build and probe add up to the total")
    print("=" * 100)
    header = (f"{'join':<10} {'build':<22} {'skew':>5} {'Mops':>7} "
              f"{'phase 1':>22} {'phase 2':>22} {'total cyc/tup':>14}")
    print(header)
    print("-" * 100)
    for r in rows:
        p1 = f"{r['phase1_name']} {r['phase1_cpt']:.1f} ({r['phase1_mops']} Mops)"
        p2 = f"{r['phase2_name']} {r['phase2_cpt']:.1f} ({r['phase2_mops']} Mops)"
        print(f"{r['join']:<10} {r['variant']:<22} {r['skew']:>5} "
              f"{r['throughput_mops']:>7} {p1:>22} {p2:>22} {r['total_cpt']:>14.1f}")
    print("=" * 100 + "\n", flush=True)


def plot(rows, variants):
    fig, axes = plt.subplots(1, len(SKEWS), figsize=(13, 6), sharey=True)
    if len(SKEWS) == 1:
        axes = [axes]

    labels = [f"cas\n{v.label}" for v in variants] + [f"radix\n{v.label}" for v in variants]
    keys = [("hash_cas", v.key) for v in variants] + [("radix", v.key) for v in variants]

    for ax, skew in zip(axes, SKEWS):
        by_key = {(r["join"], r["variant"]): r for r in rows if r["skew"] == skew}
        p1 = [by_key[k]["phase1_cpt"] if k in by_key else 0 for k in keys]
        p2 = [by_key[k]["phase2_cpt"] if k in by_key else 0 for k in keys]

        x = range(len(keys))
        colors = ["tab:blue"] * len(variants) + ["tab:gray"] * len(variants)
        ax.bar(x, p1, color=colors, label="build / partition")
        ax.bar(x, p2, bottom=p1, color=colors, alpha=0.55, hatch="//",
               label="probe / join")

        for i, k in enumerate(keys):
            if k not in by_key:
                continue
            r = by_key[k]
            ax.text(i, p1[i] + p2[i] + 1.5, f"{r['throughput_mops']}\nMops",
                    ha="center", va="bottom", fontsize=8)
            if p1[i] > 6:
                ax.text(i, p1[i] / 2, f"{p1[i]:.0f}", ha="center", va="center",
                        fontsize=8, color="white")
            if p2[i] > 6:
                ax.text(i, p1[i] + p2[i] / 2, f"{p2[i]:.0f}", ha="center",
                        va="center", fontsize=8)

        ax.set_xticks(list(x))
        ax.set_xticklabels(labels, fontsize=9)
        ax.set_title(f"skew = {skew}", fontsize=12)
        ax.grid(True, axis="y", linestyle="--", alpha=0.6)
        ax.set_axisbelow(True)

    axes[0].set_ylabel("Cycles per tuple (R + S)", fontsize=12)
    top = max((r["phase1_cpt"] + r["phase2_cpt"]) for r in rows) if rows else 1
    axes[0].set_ylim(top=top * 1.25)
    handles, lbls = axes[0].get_legend_handles_labels()
    axes[0].legend(handles[:2], lbls[:2], fontsize=9, loc="upper left")
    fig.suptitle("Join phase cost vs prefetch build, R = S = 8 GiB, single socket",
                 fontsize=14)
    fig.tight_layout()
    fig.savefig(PNG_PATH, dpi=300)
    print(f"[*] Plot saved to {PNG_PATH}")


def main(args):
    variants = [Variant(p) for p in args.prefetch_builds]
    variants += [Variant(args.insert_sweep_prefetch, i) for i in args.insert_builds]

    rows = []
    for variant in variants:
        build_dramhit(variant)

        for join_type in ("hash", "radix"):
            defaults = (rsj.HASH_JOIN_DEFAULTS if join_type == "hash"
                        else rsj.RADIX_JOIN_DEFAULTS)
            rsj.reserve_hugepages(join_type, defaults, "relation_size",
                                  [RELATION_SIZE], SCOPE,
                                  hashtable="cas" if join_type == "hash" else None)
            for skew in SKEWS:
                name = "cas" if join_type == "hash" else "radix"
                print(f"\n=== {name} | {variant.key} | skew={skew} ===", flush=True)
                log_path = LOG_ROOT / f"{name}_{variant.key}_skew{skew}.log"
                row = run_one(join_type, variant, skew, log_path)
                if row:
                    rows.append(row)
                    JSON_PATH.write_text(json.dumps(
                        {"relation_size_tuples": RELATION_SIZE,
                         "relation_size_gib": RELATION_SIZE * 16 / (1024 ** 3),
                         "cpu_scope": "single",
                         "num_threads": SCOPE["num_threads"],
                         "cpufreq_mhz": CPUFREQ_MHZ,
                         "runs": rows}, indent=4))

    print_table(rows)
    if rows:
        plot(rows, variants)
    print("COMPARE_DONE")


def parse_args():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prefetch-builds", nargs="*", default=PREFETCH_BUILDS,
                        choices=["DOUBLE", "L1", "L2", "L3", "NTA", "NONE"],
                        help="PREFETCH builds to compare, insert path left on "
                             "AUTO (default: DOUBLE L1 NONE). Pass none of them "
                             "to compare only --insert-builds.")
    parser.add_argument("--insert-builds", nargs="*", default=[],
                        choices=INSERT_CHOICES,
                        help="CAS_PREFETCH_INSERTION choices to compare with "
                             "PREFETCH held fixed, i.e. tuning the build phase "
                             "on its own (default: none).")
    parser.add_argument("--insert-sweep-prefetch", default="DOUBLE",
                        choices=["DOUBLE", "L1", "L2", "L3", "NTA", "NONE"],
                        help="The PREFETCH setting --insert-builds is swept "
                             "against (default: DOUBLE).")
    return parser.parse_args()


if __name__ == "__main__":
    main(parse_args())
