import json
import sys

# ==========================================
# CONFIGURATION & MAPPING TABLES
# ==========================================

# File paths for your JSON files
DIR_JSON_FILE = "intel_dir_bandwidth.json"
SNOOP_JSON_FILE = "intel_snoop_bandwidth.json"

# The key you want to extract (change to 'program_bandwidth_GBps' if needed)
BANDWIDTH_KEY = "program_bandwidth_GBps"

# Map the LaTeX row headers to your JSON 'test_pattern' values
PATTERN_MAP = {
    "Random Read":     "rand_r",
    "Random 1R1W":     "rand_rw", # Change this if your JSON uses a different string
    "Sequential Read": "seq_r",
    "Sequential 1R1W": "seq_rw"
}

# Map the LaTeX column segments to your JSON 'numa_policy' values
# Note: "dual-even" is mapped to "Dual Mixed" as you requested.
POLICY_MAP = {
    "Single Remote": "single-remote",
    "Single Local":  "single-local",
    "Single Mixed":  "single-mixed",
    "Dual Remote":   "dual-remote",
    "Dual Local":    "dual-local",
    "Dual Mixed":    "dual-even"
}

# The exact order the columns appear in the LaTeX table
COLUMN_ORDER = [
    "Single Remote",
    "Single Local",
    "Single Mixed",
    "Dual Remote",
    "Dual Local",
    "Dual Mixed"
]

# ==========================================
# LATEX TEMPLATES
# ==========================================

LATEX_HEADER = r"""\begin{table*}[t] \centering \small \setlength{\tabcolsep}{4pt}
\renewcommand{\arraystretch}{1.15}

\resizebox{\textwidth}{!}{%
\begin{tabular}{|l|cc|cc|cc||cc|cc|cc||c|}
\hline

Configuration
&
\multicolumn{6}{c||}{\textbf{Single Socket}}
& \multicolumn{6}{c||}{\textbf{Dual Socket}}
& \multicolumn{1}{c|}{\textbf{AMD Single Socket}} \\
\cline{2-14}

&
\multicolumn{2}{c|}{Remote} &
\multicolumn{2}{c|}{Local} &
\multicolumn{2}{c||}{Mixed} &
\multicolumn{2}{c|}{Remote} &
\multicolumn{2}{c|}{Local} &
\multicolumn{2}{c||}{Mixed} &
Local \\
\hline

\textbf{Bandwidth GB/s (CB)}
&
snoop & dir &
snoop & dir &
snoop & dir &
snoop & dir &
snoop & dir &
snoop & dir &
\\
\hline\hline

Theoretical R
& 332.8 (31) & 332.8 (31) & 332.8 (31) & 332.8 (31) & 332.8 (31) & 332.8 (31) \
& 665.6 (31) & 665.6 (31) & 665.6 (31) & 665.6 (31) & 665.6 (31) & 665.6 (31) & 460.8 (29) \\
\hline"""

LATEX_FOOTER = r"""\end{tabular}%
}

\caption{Bandwidth (GB/s) across socket configurations and access patterns.}
\label{tab:bandwidth}
\end{table*}"""

# ==========================================
# MAIN SCRIPT LOGIC
# ==========================================

def load_data(filepath):
    try:
        with open(filepath, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Warning: Could not find {filepath}. Proceeding with empty data for this file.")
        return []

def build_lookup_db(raw_data):
    """Converts the list of JSON objects into a dictionary keyed by (pattern, policy)."""
    db = {}
    for entry in raw_data:
        pattern = entry.get("test_pattern")
        policy = entry.get("numa_policy")
        val = entry.get(BANDWIDTH_KEY, "")
        if pattern and policy:
            db[(pattern, policy)] = val
    return db

def main():
    # Load and index the data
    dir_data = build_lookup_db(load_data(DIR_JSON_FILE))
    snoop_data = build_lookup_db(load_data(SNOOP_JSON_FILE))

    print(LATEX_HEADER)

    # Generate rows based on the defined patterns
    for row_label, pattern_key in PATTERN_MAP.items():
        row_values = [row_label]

        # Loop through the columns in order to extract snoop then dir
        for policy_name in COLUMN_ORDER:
            policy_key = POLICY_MAP[policy_name]

            # Fetch values, defaulting to an empty string if the exact run isn't in the JSON
            snoop_val = snoop_data.get((pattern_key, policy_key), "")
            dir_val = dir_data.get((pattern_key, policy_key), "")

            row_values.append(str(snoop_val))
            row_values.append(str(dir_val))

        # Add the blank entry for the AMD column at the end
        row_values.append("")

        # Format the row for LaTeX and print it
        latex_row = " & ".join(row_values) + r" \\"
        print(latex_row)
        print(r"\hline")

    print(LATEX_FOOTER)

if __name__ == "__main__":
    main()
