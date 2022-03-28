# Generate the histogram from an input file
import numpy as np
import matplotlib.pyplot as plt
import subprocess
from estimate_zipf import estimate_zipf

SAMPLE_RATE=0.5

def run_subprocess(cmd):
    print(f'Running <{cmd}>')
    return subprocess.check_output(cmd, shell=True)

def gen_values(K, inpath, outpath):
    print(f'Generating K={K} from {input} to {outpath}')

    # Config build
    build_dir = f'build/example'
    build_cmd = f'cmake -S . -B {build_dir} -G Ninja -DBUILD_EXAMPLE=ON -DKMER_LEN={K} > {outpath}.cmake.log'
    run_subprocess(build_cmd)
    
    # Build
    run_subprocess(f'ninja -C {build_dir} > {outpath}.build.log')

    # Run dumper
    return run_subprocess(f'{build_dir}/examples/dump_kmer_hash --input_file={inpath} --output_file="" --sample_rate={SAMPLE_RATE}')

def hist_from_values(data, title, outputfile, skew):
  # Load data
  print(f'Loading data with size {len(data)}')
  nums = np.frombuffer(data, dtype=np.uint64)
  print(f"Finish load data; size of data: {len(nums)}")

  # Gen histo
  hist, _ = np.histogram(nums, 2000)
  hist[::-1].sort()
  if skew:
    # Calc skew
    print(f"Estimating skew")
    skew = estimate_zipf(nums)
    print(f'Skew={skew}')
    title += f' Skew={skew}'
  
  # Plot histo
  plt.bar(np.arange(len(hist)), hist)
  plt.title(title)
  fig = plt.gcf()
  fig.set_size_inches(20, 20)
  fig.savefig(outputfile)
  fig.clf()

  # Plot log-log
  plt.scatter(np.arange(len(hist)), hist)
  plt.title(f'Log-log {title}')
  # plt.xscale('log')
  plt.yscale('log')
  fig = plt.gcf()
  fig.set_size_inches(20, 20)
  fig.savefig(f'{outputfile}_loglog.jpg')
  fig.clf()

  plt.clf()

if __name__ == "__main__":
  INPUT_DIR = "../memfs"
  INPUT_FILE = "SRR077487.2.fastq"
  # INPUT_FILE = "SRR072006.fastq"
  INPUT_PATH = f'{INPUT_DIR}/{INPUT_FILE}'
  OUTDIR = f"out/hist/{INPUT_FILE}"
  # Ks = range(4, 33)
  Ks = [9]
  for K in Ks:
    # Create output directory
    outdir = f'{OUTDIR}/{K}'
    run_subprocess(f"mkdir -p {outdir}")

    # Generate values
    values = gen_values(K, INPUT_PATH, f'{outdir}/values')

    # Generate histogram
    hist_from_values(values, f'Histogram K={K} file={INPUT_FILE}', f'{outdir}/histo.jpg', skew=False)
