from scipy.optimize import minimize
from scipy import special
import numpy as np
import matplotlib.pyplot as plt
from collections import Counter

size = 100

def estimate_zipf(arr):
  N = len(arr)
  one_to_N = np.arange(1, N+1)
  p = arr / np.sum(arr)
  lzipf = lambda s: -s * np.log(one_to_N) - np.log(np.sum(1/np.power(one_to_N, s)))
  min_f = lambda s: np.sum(np.power(np.log(p) - lzipf(s[0]), 2))
  return minimize(min_f, np.array([0.5]))

def cross_check(a):
  arr = np.random.zipf(a, size * 10000)
  arr = Counter(arr)
  arr = np.array([x[1] for x in arr.most_common()])
  estimated_a = estimate_zipf(arr).x[0]
  print(f"Expected: {a:.2f}, actual: {estimated_a:.2f}")


def plot_zipf(file):
  arr = np.fromfile(file, dtype=int, sep='\n')[:size]
  estimated = estimate_zipf(arr)
  a = estimated.x[0]
  print(f'a is estimated to be {a:.2f}')

  x = np.arange(1., float(size))
  y = x**(-a) / special.zetac(a)
  plt.plot(x, y/max(y), linewidth=2, color='r', label='estimated zipf')
  plt.bar(np.arange(1,size+1), arr/max(arr), label='input')
  plt.savefig('hist.jpg')

if __name__ == "__main__":
  plot_zipf('../hist')
  cross_check(1.5)
  cross_check(2)
