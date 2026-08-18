#!/usr/bin/env python3

from pathlib import Path
import sys
import matplotlib as mpl
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns


def configure_style():
    """Configures the base matplotlib fonts and seaborn style."""
    rc_fonts = {
        "text.usetex": True,
        "font.family": "serif",
        "font.serif": ["Linux Libertine O"],
        "font.weight": "bold",
    }
    mpl.rcParams.update(rc_fonts)
    sns.set_context("paper")
    sns.set_style("whitegrid")


def configure_palette(unique_ids):
    """Generates a reversed rocket palette and returns it."""
    n_colors = max(len(unique_ids), 1)
    custom_palette = sns.color_palette("rocket", n_colors=n_colors)[::-1]
    return custom_palette


def plot_single_csv(csv_path: Path, output_dir: Path):
    """Reads a CSV file and generates a 1x1 line plot with a legend placed on top."""
    df = pd.read_csv(csv_path)

    # Validate required columns
    required = {"mode", "batch_size", "median"}
    if not required.issubset(df.columns):
        print(
            f"Skipping {csv_path.name}: Missing required columns {required - set(df.columns)}"
        )
        return

    # Determine unique modes and configure palette
    unique_modes = df["mode"].unique()
    palette = configure_palette(unique_modes)

    # Create 1x1 figure
    fig, ax = plt.subplots(figsize=(6, 4.5))

    # Plot batch_size vs median grouped by mode
    sns.lineplot(
        data=df,
        x="batch_size",
        y="median",
        hue="mode",
        marker="o",
        palette=palette,
        ax=ax,
    )

    # Format axes
    ax.set_xlabel("Batch Size")
    ax.set_ylabel("Median")
    ax.set_ylim(bottom=0)
    ax.grid(True, which="major", axis="both", linestyle="--")

    # Move legend above the plot area
    num_modes = len(unique_modes)
    sns.move_legend(
        ax,
        loc="lower center",
        bbox_to_anchor=(0.5, 1.02),
        ncol=num_modes if num_modes <= 4 else 3,
        title="",
        frameon=False,
    )

    # Save plot
    output_file = output_dir / f"{csv_path.stem}.png"
    plt.savefig(output_file, dpi=300, bbox_inches="tight")
    plt.close(fig)
    print(f"Generated plot: {output_file}")


def process_directory(input_dir: str, output_dir: str = None):
    """Processes all CSV files in input_dir and saves plots to output_dir."""
    configure_style()

    in_path = Path(input_dir)
    out_path = Path(output_dir) if output_dir else in_path

    out_path.mkdir(parents=True, exist_ok=True)

    csv_files = sorted(list(in_path.glob("*.csv")))
    if not csv_files:
        print(f"No CSV files found in directory: {input_dir}")
        return

    for csv_file in csv_files:
        plot_single_csv(csv_file, out_path)


if __name__ == "__main__":
    # Usage: python script.py <input_directory> [optional_output_directory]
    input_directory = sys.argv[1] if len(sys.argv) > 1 else "."
    output_directory = sys.argv[2] if len(sys.argv) > 2 else input_directory

    process_directory(input_directory, output_directory)
