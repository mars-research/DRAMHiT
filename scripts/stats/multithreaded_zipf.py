from multiprocessing import Pool
from estimate_zipf import plot_zipf
from scipy import stats
import subprocess
import numpy as np

OUTDIR = "out/zipf_est"

def run_subprocess(cmd):
    print(f'Running <{cmd}>')
    return subprocess.check_output(cmd, shell=True)

def gen_freqs(num_thread, skew):
    # Run dumper
    return run_subprocess(f'{build_dir}/examples/dump_zipf_freq --output_file="" --skew={skew} --num_threads={num_thread}')

def dump_and_mle(num_thread, skew, output):
  # Generate zipfian
  data = gen_freqs(num_thread, skew)
  freqs = np.frombuffer(data, dtype=np.uint64)
  print(f"Received frequencies with stats {stats.describe(freqs)}.")

  a = plot_zipf(freqs, f'num_thread={num_thread} skew={skew}', output)
  print(f'a={a:.2f} for num_thread={num_thread} skew={skew}')


if __name__ == "__main__":
  # Setup output dir
  run_subprocess(f"mkdir -p {OUTDIR}")

  # Config build
  build_dir = f'build/example'
  build_cmd = f'cmake -S . -B {build_dir} -G Ninja -DBUILD_EXAMPLE=ON > {OUTDIR}/cmake.log'
  run_subprocess(build_cmd)
  
  # Build
  run_subprocess(f'ninja -C {build_dir} > {OUTDIR}/build.log')


  # Run jobs
  pool = Pool(8)
  skews = [1.09]
  num_threads = [1, 4, 16, 64]
  for skew in skews:
    for num_thread in num_threads:
      pool.apply_async(dump_and_mle, args=(num_thread, skew, f'{OUTDIR}/{num_thread}_{skew:.3f}.jpg'))
  pool.close()
  pool.join()
