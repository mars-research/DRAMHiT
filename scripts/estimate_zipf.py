from scipy.optimize import minimize
from scipy import special
import numpy as np
import matplotlib.pyplot as plt
import math

size = 100

def estimate_zipf(arr):
  N = len(arr)
  one_to_N = np.arange(1, N+1)
  p = arr / np.sum(arr)
  lzipf = lambda s: -s * np.log(one_to_N) - np.log(np.sum(1/np.power(one_to_N, s)))
  min_f = lambda s: np.sum(np.power(np.log(p) - lzipf(s[0]), 2))
  return minimize(min_f, np.array([0.5]))

arr = np.fromfile('../hist', dtype=int, sep='\n')[:size]
estimated = estimate_zipf(arr)
print(estimated)

a = estimated.x[0]
x = np.arange(1., float(size))
y = x**(-a) / special.zetac(a)
plt.plot(x, y/max(y), linewidth=2, color='r')
plt.bar(np.arange(1,size+1), arr/max(arr))
plt.savefig('hist.jpg')