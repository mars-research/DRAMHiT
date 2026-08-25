import json
import os

PATTERNS = [
    "single_remote", "single_local", "single_mixed",
    "dual_remote", "dual_local", "dual_mixed"
]

def get_val(data, pattern, mode, category, socket, event, metric):
    """
    Safely fetch a value from the nested JSON.
    Crucially, this ROUNDS to an integer immediately.
    This ensures that any subsequent sums match the displayed table values.
    """
    try:
        val = data[pattern][mode][category][socket][event][metric]
        return round(val)
    except KeyError:
        return 0

def generate_row(snoop_data, dir_data, mode, metric, row_title, calc_func):
    """Generates a formatted LaTeX row string by executing calc_func for every column."""
    row_values = []
    for pattern in PATTERNS:
        # Snoop column
        val_snoop = calc_func(snoop_data, pattern, mode, metric)
        row_values.append(f"{val_snoop}")
        # Dir column
        val_dir = calc_func(dir_data, pattern, mode, metric)
        row_values.append(f"{val_dir}")

    # Format the LaTeX row
    return f"{row_title:<15} & " + " & ".join(row_values) + " \\\\\n\\hline"

def main():
    print("=== LaTeX Table Generator ===")

    # 1. Get Snoop File
    snoop_file = input("Enter path for the SNOOP JSON file (e.g., snoop_results.json): ").strip()
    if not os.path.exists(snoop_file):
        print(f"Error: Could not find {snoop_file}")
        return

    # 2. Get Directory File
    dir_file = input("Enter path for the DIRECTORY JSON file (e.g., dir_results.json): ").strip()
    if not os.path.exists(dir_file):
        print(f"Error: Could not find {dir_file}")
        return

    # 3. Get Metric
    valid_metrics = ['mid', 'avg', 'min', 'max']
    metric = input("Which metric to extract? (mid, avg, min, max) [default: mid]: ").strip().lower()
    if not metric:
        metric = 'mid'
    elif metric not in valid_metrics:
        print(f"Error: Metric must be one of {valid_metrics}")
        return

    # 4. Get Mode
    valid_modes = ['read', 'write']
    mode = input("Which workload mode to extract? (read, write) [default: read]: ").strip().lower()
    if not mode:
        mode = 'read'
    elif mode not in valid_modes:
        print(f"Error: Mode must be one of {valid_modes}")
        return

    # Load Data
    with open(snoop_file, "r") as f:
        snoop_data = json.load(f)
    with open(dir_file, "r") as f:
        dir_data = json.load(f)

    # --- Calculations ---

    # 1. Base UPI Data (Rounded immediately by get_val)
    upi_data_1_0 = lambda d, p, m, met: get_val(d, p, m, "upi", "S1", "unc_upi_txl_flits.all_data", met)
    upi_data_0_1 = lambda d, p, m, met: get_val(d, p, m, "upi", "S0", "unc_upi_txl_flits.all_data", met)

    upi_nondata_1_0 = lambda d, p, m, met: get_val(d, p, m, "upi", "S1", "unc_upi_txl_flits.non_data", met)
    upi_nondata_0_1 = lambda d, p, m, met: get_val(d, p, m, "upi", "S0", "unc_upi_txl_flits.non_data", met)

    # UPI Totals (Summing the already-rounded table values)
    upi_total_1_0 = lambda d, p, m, met: upi_data_1_0(d, p, m, met) + upi_nondata_1_0(d, p, m, met)
    upi_total_0_1 = lambda d, p, m, met: upi_data_0_1(d, p, m, met) + upi_nondata_0_1(d, p, m, met)
    upi_total_all = lambda d, p, m, met: upi_total_1_0(d, p, m, met) + upi_total_0_1(d, p, m, met)

    # 2. Base Bandwidth Data (Rounded immediately by get_val)
    bw_s0_rd = lambda d, p, m, met: get_val(d, p, m, "bw", "S0", "unc_m_cas_count.rd", met)
    bw_s0_wr = lambda d, p, m, met: get_val(d, p, m, "bw", "S0", "unc_m_cas_count.wr", met)
    bw_s1_rd = lambda d, p, m, met: get_val(d, p, m, "bw", "S1", "unc_m_cas_count.rd", met)
    bw_s1_wr = lambda d, p, m, met: get_val(d, p, m, "bw", "S1", "unc_m_cas_count.wr", met)

    # Bandwidth Totals (Summing the already-rounded table values)
    bw_tot_rd = lambda d, p, m, met: bw_s0_rd(d, p, m, met) + bw_s1_rd(d, p, m, met)
    bw_tot_wr = lambda d, p, m, met: bw_s0_wr(d, p, m, met) + bw_s1_wr(d, p, m, met)
    bw_tot_all = lambda d, p, m, met: bw_tot_rd(d, p, m, met) + bw_tot_wr(d, p, m, met)

    # --- Generate LaTeX String ---
    latex = r"""\begin{table*}[t] \centering \small \setlength{\tabcolsep}{5pt}
\renewcommand{\arraystretch}{1.2}

\begin{tabular}{|l|cc|cc|cc||cc|cc|cc|}
\hline

& \multicolumn{6}{c||}{\textbf{Single Socket}}
& \multicolumn{6}{c|}{\textbf{Dual Socket}} \\
\cline{2-13}

Configuration &
\multicolumn{2}{c|}{Remote} &
\multicolumn{2}{c|}{Local} &
\multicolumn{2}{c||}{Mixed} &
\multicolumn{2}{c|}{Remote} &
\multicolumn{2}{c|}{Local} &
\multicolumn{2}{c|}{Mixed} \\
\hline

& snoop & dir
& snoop & dir
& snoop & dir
& snoop & dir
& snoop & dir
& snoop & dir \\
\hline\hline

\multicolumn{13}{|l|}{\textbf{Data}} \\
\hline
"""
    latex += generate_row(snoop_data, dir_data, mode, metric, "1$\\rightarrow$0", upi_data_1_0) + "\n"
    latex += generate_row(snoop_data, dir_data, mode, metric, "0$\\rightarrow$1", upi_data_0_1) + "\n"

    latex += r"""
\multicolumn{13}{|l|}{\textbf{Nondata}} \\
\hline
"""
    latex += generate_row(snoop_data, dir_data, mode, metric, "1$\\rightarrow$0", upi_nondata_1_0) + "\n"
    latex += generate_row(snoop_data, dir_data, mode, metric, "0$\\rightarrow$1", upi_nondata_0_1) + "\n"

    latex += r"""
\multicolumn{13}{|l|}{\textbf{UPI Total}} \\
\hline
"""
    latex += generate_row(snoop_data, dir_data, mode, metric, "1$\\rightarrow$0", upi_total_1_0) + "\n"
    latex += generate_row(snoop_data, dir_data, mode, metric, "0$\\rightarrow$1", upi_total_0_1) + "\n"
    latex += generate_row(snoop_data, dir_data, mode, metric, "total", upi_total_all) + "\n"

    latex += r"""
\multicolumn{13}{|l|}{\textbf{Bandwidth}} \\
\hline
"""
    latex += generate_row(snoop_data, dir_data, mode, metric, "numa 0 read", bw_s0_rd) + "\n"
    latex += generate_row(snoop_data, dir_data, mode, metric, "numa 0 write", bw_s0_wr) + "\n"
    latex += generate_row(snoop_data, dir_data, mode, metric, "numa 1 read", bw_s1_rd) + "\n"
    latex += generate_row(snoop_data, dir_data, mode, metric, "numa 1 write", bw_s1_wr) + "\n"
    latex += generate_row(snoop_data, dir_data, mode, metric, "total read", bw_tot_rd) + "\n"
    latex += generate_row(snoop_data, dir_data, mode, metric, "total write", bw_tot_wr) + "\n"
    latex += generate_row(snoop_data, dir_data, mode, metric, "total", bw_tot_all) + "\n"

    latex += r"""
\end{tabular}

\caption{D760 UPI traffic breakdown under Random """ + mode.capitalize() + r""" workload}
\label{tab:upi-traffic}
\end{table*}
"""

    print("\nLaTeX Generation Complete! Copy the output below:\n")
    print("=" * 80)
    print(latex)
    print("=" * 80)

    with open("table_output.tex", "w") as f:
        f.write(latex)
    print(f"\nLaTeX successfully saved to table_output.tex")

if __name__ == "__main__":
    main()
