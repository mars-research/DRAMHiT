# Generate the histogram from an input file
import numpy as np
import matplotlib.pyplot as plt
from collections import Counter

with open("hashes.data", 'rb') as f:
  nums = f.read()
  nums = np.frombuffer(nums, dtype=np.uint64)
  # hist, _ = np.histogram(nums, 1000)
  # hist[::-1].sort()
  hist = Counter(nums).most_common()
  hist = [v for k,v in hist]
  plt.bar(np.arange(len(hist)), hist)
  plt.title("Histogram")
  plt.savefig('hash_hist.jpg')