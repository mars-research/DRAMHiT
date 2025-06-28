#!/usr/bin/env python3
import sys
import csv

# Read data from stdin
x = []
y = []

for row in csv.reader(sys.stdin):
    print(row)
    if not row or row[0].startswith('#'):
        continue
    try:
        x.append(float(row[0]))
        y.append(float(row[1]))
    except (ValueError, IndexError):
        continue

# Determine plot size
width = 60
height = 20

# Normalize data
min_x, max_x = min(x), max(x)
min_y, max_y = min(y), max(y)

def scale(val, min_val, max_val, target_size):
    if max_val == min_val:
        return 0
    return int((val - min_val) / (max_val - min_val) * (target_size - 1))

# Create blank plot grid
grid = [[' ' for _ in range(width)] for _ in range(height)]

# Plot points
for xi, yi in zip(x, y):
    col = scale(xi, min_x, max_x, width)
    row = height - 1 - scale(yi, min_y, max_y, height)
    if 0 <= row < height and 0 <= col < width:
        grid[row][col] = '*'

# Print the grid
print(f"Y: [{min_y:.2f} ... {max_y:.2f}]")
for row in grid:
    print(''.join(row))
print(f"X: [{min_x:.2f} ... {max_x:.2f}]")
