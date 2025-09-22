import pandas as pd
import json

# Example JSON data for df (json1)
json1_data = [
    {"identifier": "A", "run_config.fill_factor": 0.8, "run_config.numa_policy": "default", "mops": 100, "cycles": 200},
    {"identifier": "B", "run_config.fill_factor": 0.9, "run_config.numa_policy": "interleave", "mops": 150, "cycles": 300},
    {"identifier": "C", "run_config.fill_factor": 0.7, "run_config.numa_policy": "default", "mops": 200, "cycles": 400},
]

# Example JSON data for df2 (json2)
json2_data = [
    # This row matches A, so it should replace it
    {"identifier": "A", "run_config.fill_factor": 0.8, "run_config.numa_policy": "default", "mops": 999, "cycles": 888},
    # This row does not exist in df, should not overwrite anything (or combine_first if desired)
    {"identifier": "D", "run_config.fill_factor": 0.6, "run_config.numa_policy": "default", "mops": 555, "cycles": 666},
]

# Convert to DataFrames
df = pd.json_normalize(json1_data, sep=".")
df2 = pd.json_normalize(json2_data, sep=".")

print("Original df:")
print(df)
print("\ndf2:")
print(df2)

# Define composite keys for multi-condition match
keys = ["identifier", "run_config.fill_factor", "run_config.numa_policy"]

# Set MultiIndex
df.set_index(keys, inplace=True)
df2.set_index(keys, inplace=True)

# Update df with df2
df.update(df2)

# Reset index to see result
df.reset_index(inplace=True)
print("\nUpdated df:")
print(df)
