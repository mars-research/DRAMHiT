from scipy.optimize import minimize, Bounds
from scipy import special
from scipy.stats import describe
import numpy as np
import matplotlib.pyplot as plt
from collections import Counter
from multiprocessing import cpu_count
import subprocess

SIZE = 1000

def estimate_zipf(arr):
  arr = arr.astype(np.double)
  arr += 1
  N = len(arr)
  one_to_N = np.arange(1, N+1).astype(np.double)
  p = arr / np.sum(arr)
  lzipf = lambda s: -s * np.log(one_to_N) - np.log(np.sum(1/np.power(one_to_N, s)))
  min_f = lambda s: np.sum(np.power(np.log(p) - lzipf(s[0]), 2))
  bnds = Bounds([0], [np.inf])
  result = minimize(min_f, (0.5), method='SLSQP', bounds=bnds)
  return result.x[0]

def cross_check(a):
  arr = np.random.zipf(a, SIZE * 10000)
  arr = Counter(arr)
  arr = np.array([x[1] for x in arr.most_common()])
  estimated_a = estimate_zipf(arr)
  print(f"Expected: {a:.2f}, actual: {estimated_a:.2f}")

def plot_zipf(expected_skew, arr, title, output):
  # Estimate zipf
  a = estimate_zipf(arr)
  # Plot regression line
  size = min(SIZE, len(arr))
  x = np.arange(1.,size+1.)
  y = x**(-a) / special.zetac(a)
  y = np.abs(y)
  y = y/max(y)
  y = y*max(arr)
  plt.plot(x, y, "--", linewidth=1, color='r', label=f'zipf(a={a:.3f})')
  # Plot expected  
  a = expected_skew
  y = x**(-a) / special.zetac(a)
  y = np.abs(y)
  y = y/max(y)
  y = y*max(arr)
  plt.plot(x, y, "--", linewidth=1, color='g', label=f'zipf(expected_a={a:.3f})')
  # Plot actual data
  y = sorted(arr, reverse=True)
  y = y[:size]
  plt.bar(x, y, label='input')
  # Finalize image
  plt.legend()
  plt.title(title)
  fig = plt.gcf()
  fig.set_size_inches(20, 20)
  plt.savefig(output)
  plt.clf()
  return a

dataset_home='/opt/dataset_memfs/'
dataset_temp='/opt/hist_temp/'
chtkc_build='/local/devel2/chtkc/build/'
COUNT_TOOL='chtkc'

def freq_from_jellyhist(file):
  if COUNT_TOOL == "jellyfish":
    delimiter=' '
  elif COUNT_TOOL == "chtkc":
    delimiter='\t'
  arr = np.genfromtxt(open(file, 'r'), dtype=int, delimiter=delimiter)
  print(file)
  print(arr)
  arr = arr[:,1] # Only take the second column
  return arr

def zipf_from_kmer(file, k, output, tool):

  fastq_name = file.split('/')[-1]
  out_file=dataset_temp + '/' + fastq_name + '.out'

  if tool == "jellyfish":
    cmd = f'jellyfish count -m {k} -s 1G -t {cpu_count()} -C {file}'
  elif tool == "chtkc":
    cmd = f'{chtkc_build}/chtkc count -m 128G -k {k} -t {cpu_count()} --fq {file} -o {out_file}'

  print(f"Counting kmer: {cmd}")
  args = ['bash', '-c', cmd]
  subprocess.run(args).check_returncode()

  # Get histogram
  histo_file = f'{dataset_temp}/{fastq_name}_{k}mer.histo'

  if tool == "jellyfish":
    cmd = f'jellyfish histo mer_counts.jf > {histo_file}'
  elif tool == "chtkc":
    cmd = f'/local/devel2/chtkc/build/chtkc histo {out_file} -o {histo_file}'

  print(f"Generating histogram: {cmd}")
  args = ['bash', '-c', cmd]
  subprocess.run(args).check_returncode()

  freq = freq_from_jellyhist(histo_file)
  a = plot_zipf(0, freq, f'{k}-mer histogram from {file}', output)
  print(f'a={a:.2f} for K={k} in {file}')


if __name__ == "__main__":
  name, file = ['d_mela', '/opt/dataset_memfs/ERR4846928.fastq']
  name1, file1 = ['f_vesca', '/opt/dataset_memfs/SRR1513870.fastq']
  K = list(range(20, 32))
  K = [32]
  for k in K:
    zipf_from_kmer(file, k, f'{name}_{k}.jpg', COUNT_TOOL)
    zipf_from_kmer(file1, k, f'{name1}_{k}.jpg', COUNT_TOOL)
