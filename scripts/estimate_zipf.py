from scipy.optimize import minimize
from scipy import special
import numpy as np
import matplotlib.pyplot as plt
from collections import Counter
from multiprocessing import cpu_count
import subprocess

size = 100

def estimate_zipf(arr):
  N = len(arr)
  one_to_N = np.arange(1, N+1)
  p = arr / np.sum(arr)
  lzipf = lambda s: -s * np.log(one_to_N) - np.log(np.sum(1/np.power(one_to_N, s)))
  min_f = lambda s: np.sum(np.power(np.log(p) - lzipf(s[0]), 2))
  result = minimize(min_f, np.array([0.5]))
  return result.x[0]

def cross_check(a):
  arr = np.random.zipf(a, size * 10000)
  arr = Counter(arr)
  arr = np.array([x[1] for x in arr.most_common()])
  estimated_a = estimate_zipf(arr)
  print(f"Expected: {a:.2f}, actual: {estimated_a:.2f}")

def plot_zipf(file, title, output):
  arr = np.genfromtxt(open(file, 'r'), dtype=int, delimiter=' ')[:,1]
  a = estimate_zipf(arr)

  # Plot regression line
  x = np.arange(1.,size+1.)
  y = x**(-a) / special.zetac(a)
  y = np.abs(y)
  y = y*max(arr)
  plt.plot(x, y, linewidth=2, color='r', label=f'zipf(a={a:.2f})')
  # Plot actual data
  y = sorted(arr, reverse=True)
  y = y[:size]
  plt.bar(x, y, label='input')
  # Finalize image
  plt.legend()
  plt.title(title)
  plt.savefig(output)
  return a

def zipf_from_kmer(file, k, output):
  # Count kmer
  cmd = f'jellyfish count -m {k} -s 1G -t {cpu_count()} -C {file}'
  print(f"Counting kmer: {cmd}")
  args = ['bash', '-c', cmd]
  subprocess.run(args).check_returncode()

  # Get histogram
  histo_file = f'{file}_{k}mer.histo'
  cmd = f'jellyfish histo mer_counts.jf > {histo_file}'
  print(f"Generating histogram: {cmd}")
  args = ['bash', '-c', cmd]
  subprocess.run(args).check_returncode()

  a = plot_zipf(histo_file, f'{k}-mer histogram from {file}', output)
  print(f'a={a} for K={k} in {file}')


if __name__ == "__main__":
  homo_file = '../SRR077487.2.fastq'
  K = [15, 21, 31, 63]
  for k in K:
    zipf_from_kmer(homo_file, k, f'homo_{k}.jpg')
