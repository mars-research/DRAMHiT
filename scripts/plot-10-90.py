import matplotlib.pyplot as plt
import re
import sys

def parse_terminal_output(data):
    datasets = []
    labels = []
    current_label = None

    for line in data.strip().split('\n'):
        if not line.lstrip().startswith('{'):
            current_label = line.strip()
        else:
            matches = re.findall(r'get_mops\s*:\s*([\d.]+)', line)
            if matches:
                if not datasets or current_label != labels[-1]:
                    datasets.append([])
                    labels.append(current_label)
                datasets[-1].append(float(matches[0]))

    return datasets, labels

def main(file_path, output_file):
    with open(file_path, 'r') as f:
        data = f.read()
    
    title_string = "Uniform Lookups (4 Gib)"
    x_axis_string = "Hashtable Fill %"
    y_axis_string = "Million Operations Per Second (MOPS)"
    
    datasets, labels = parse_terminal_output(data)
    x_values = list(range(10, 10 * (len(datasets[0]) + 1), 10))

    plt.figure(figsize=(10, 6))
    for dataset, label in zip(datasets, labels):
        plt.plot(x_values, dataset, marker='o', label=label)

    plt.xlabel(x_axis_string)
    plt.ylabel(y_axis_string)
    plt.title(title_string)
    plt.ylim(0)
    plt.legend()
    plt.grid(True, linestyle="--", alpha=0.7)
    
    plt.savefig(output_file, format='pdf')
    print(f"Plot saved as {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python script.py <file_path> <output_file>")
        sys.exit(1)
    main(sys.argv[1], sys.argv[2])

