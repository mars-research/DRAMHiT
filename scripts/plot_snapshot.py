import sys
import re
import matplotlib.pyplot as plt
def is_power_of_two(n: int) -> bool:
    return n > 0 and (n & (n - 1)) == 0

# Regex to capture iter and cpo
pattern = re.compile(
    r"Read snapshot iter (?P<iter>\d+), duration \d+, op \d+, cpo (?P<cpo>\d+), mops \d+"
)

iters = []
cpos = []

# Read from stdin
for line in sys.stdin:
    line = line.strip()
    match = pattern.match(line)
    if match:
        it = int(match.group("iter"))
        cpo = int(match.group("cpo"))
        print(f"iter={it}, cpo={cpo}")  # optional debug
        if is_power_of_two(it):
            iters.append(it)
            cpos.append(cpo)

# Make plot
if iters and cpos:
    plt.figure(figsize=(8,5))
    plt.plot(iters, cpos, marker="o")
    plt.xlabel("Iteration")
    plt.ylabel("CPO")
    plt.title("Iteration vs CPO")
    plt.grid(True)
    plt.savefig("iter_vs_cpo.png", dpi=150)
    print("Saved plot as iter_vs_cpo.png")
else:
    print("No matching lines found.")


