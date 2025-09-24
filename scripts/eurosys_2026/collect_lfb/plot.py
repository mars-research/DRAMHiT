
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker

# Read CSV
df = pd.read_csv("results.csv")

# Set figure size
plt.figure(figsize=(4, 4), constrained_layout=True)

# Seaborn theme
sns.set_theme(style="whitegrid")

# Create line plot
sns.lineplot(data=df, x="batch_sz", y="cycles_per_op", marker="o")

# Set labels and title
plt.xlabel("Batch Size")
plt.ylabel("Cycles per Operation")

# Set x and y limits starting at 0 and ending at max value
##plt.xlim(4)
#plt.ylim(0)
# Enable grid at tick positions
#plt.grid(True, which="major", axis="both")

# Save figure as PDF
plt.savefig("lfb.pdf")
