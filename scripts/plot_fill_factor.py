import matplotlib.pyplot as plt
import sys
import os
import re

def parse_file(file_path):
    set_cycles = []
    get_cycles = []
    set_mops = []
    get_mops = []
    upsert_mops = []
    upsert_cycles = []

    pattern = re.compile(
        r"set_cycles\s*:\s*(\d+\.?\d*)|"
        r"get_cycles\s*:\s*(\d+\.?\d*)|"
        r"set_mops\s*:\s*(\d+\.?\d*)|"
        r"get_mops\s*:\s*(\d+\.?\d*)|"
        r"upsert_mops\s*:\s*(\d+\.?\d*)|"
        r"upsert_cycles\s*:\s*(\d+\.?\d*)"
    )

    with open(file_path, 'r') as f:
        for line in f:
            matches = pattern.findall(line)
            values = {
                "set_cycles": None,
                "get_cycles": None,
                "set_mops": None,
                "get_mops": None,
                "upsert_mops": None,
                "upsert_cycles": None,
            }

            for match in matches:
                if match[0]:
                    values["set_cycles"] = float(match[0])
                if match[1]:
                    values["get_cycles"] = float(match[1])
                if match[2]:
                    values["set_mops"] = float(match[2])
                if match[3]:
                    values["get_mops"] = float(match[3])
                if match[4]:
                    values["upsert_mops"] = float(match[4])
                if match[5]:
                    values["upsert_cycles"] = float(match[5])

            for k in values:
                if values[k] is None:
                    print(f"Missing {k} in line: {line.strip()} from file {file_path}")

            set_cycles.append(values["set_cycles"])
            get_cycles.append(values["get_cycles"])
            set_mops.append(values["set_mops"])
            get_mops.append(values["get_mops"])
            upsert_mops.append(values["upsert_mops"])
            upsert_cycles.append(values["upsert_cycles"])

    return {
        "set_cycles": set_cycles,
        "get_cycles": get_cycles,
        "set_mops": set_mops,
        "get_mops": get_mops,
        "upsert_mops": upsert_mops,
        "upsert_cycles": upsert_cycles,
    }

def plot_metric(metric_data, metric_name, output_file, title, ylabel):
    plt.figure(figsize=(10, 6))
    max_len = max(len(v) for v in metric_data.values())
    x_values = list(range(10, 10 * max_len + 1, 10))

    for label, y_values in metric_data.items():
        plt.plot(x_values[:len(y_values)], y_values, marker='o', label=label)

    plt.xlabel("Hashtable Fill %")
    plt.ylabel(ylabel)
    plt.title(title)
    plt.ylim(bottom=0)
    plt.grid(True, linestyle="--", alpha=0.7)
    plt.legend()
    plt.tight_layout()
    plt.savefig(output_file)
    print(f"{metric_name} plot saved to {output_file}")

def main():
    if len(sys.argv) < 2:
        print("Usage: python script.py <file1> [file2 ...]")
        sys.exit(1)

    metrics = {
        "set_cycles": {},
        "get_cycles": {},
        "set_mops": {},
        "get_mops": {},
        "upsert_mops": {},
        "upsert_cycles": {},
    }

    for file_path in sys.argv[1:]:
        file_name = os.path.basename(file_path)
        parsed = parse_file(file_path)

        for key in metrics:
            metrics[key][file_name] = parsed[key]

    plot_metric(metrics["set_mops"], "set_mops", "set_mops.pdf", "Set MOPS vs Load Factor", "Million Ops/sec")
    plot_metric(metrics["get_mops"], "get_mops", "get_mops.pdf", "Get MOPS vs Load Factor", "Million Ops/sec")
    plot_metric(metrics["set_cycles"], "set_cycles", "set_cycles.pdf", "Set Cycles vs Load Factor", "Cycles per Operation")
    plot_metric(metrics["get_cycles"], "get_cycles", "get_cycles.pdf", "Get Cycles vs Load Factor", "Cycles per Operation")
    plot_metric(metrics["upsert_mops"], "upsert_mops", "upsert_mops.pdf", "Upsert MOPS vs Load Factor", "Million Ops/sec")
    plot_metric(metrics["upsert_cycles"], "upsert_cycles", "upsert_cycles.pdf", "Upsert Cycles vs Load Factor", "Cycles per Operation")

if __name__ == "__main__":
    main()
