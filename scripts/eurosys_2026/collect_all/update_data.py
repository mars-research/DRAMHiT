import pandas as pd
import json
import sys

def update_json(json1_file, json2_file, output_file):
    # Load first JSON
    with open(json1_file, "r") as f:
        data1 = json.load(f)
    df1 = pd.json_normalize(data1, sep=".")

    # Load second JSON
    with open(json2_file, "r") as f:
        data2 = json.load(f)
    df2 = pd.json_normalize(data2, sep=".")

    # Define composite keys for multi-condition match
    keys = ["identifier", "run_cfg.fill_factor", "run_cfg.numa_policy"]

    # Set MultiIndex
    df1.set_index(keys, inplace=True)
    df2.set_index(keys, inplace=True)

    # Update df1 with df2
    df1.update(df2)

    # Reset index
    df1.reset_index(inplace=True)

    # Convert DataFrame back to list of dicts
    updated_data = df1.to_dict(orient="records")

    # Save to output JSON
    with open(output_file, "w") as f:
        json.dump(updated_data, f, indent=4)

    print(f"Updated JSON saved to {output_file}")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python update_json.py <json1_file> <json2_file> <output_file>")
        sys.exit(1)

    json1_file = sys.argv[1]
    json2_file = sys.argv[2]
    output_file = sys.argv[3]

    update_json(json1_file, json2_file, output_file)
