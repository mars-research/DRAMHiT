
import pandas as pd

df = pd.DataFrame(
    [
        {"key": "value1", "key2": "something inline"},
        {"key": "value2", "key2": "other"},
        {"key": "value3", "key2": "inline example"}
    ]
)

key_to_check = "key2"
word = "inline"

# vectorized, fast, case-insensitive, treats NaN as False
mask = df[key_to_check].str.contains(word, case=False, na=False)
df = df[~mask]

print(df)
