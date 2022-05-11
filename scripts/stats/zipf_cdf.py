import subprocess
from multiprocessing.pool import Pool

OUTDIR = "out/zipf_cdf"

def run_subprocess(cmd):
    print(f'Running <{cmd}>')
    return subprocess.check_output(cmd, shell=True)

def gen_cdf(skew):
    # Run dumper
    outfile = f'{OUTDIR}/cdf_{skew:.2f}.csv'
    return run_subprocess(f'{build_dir}/examples/dump_zipf_cdf --output_file="{outfile}" --skew={skew}')


if __name__ == "__main__":
  # Setup output dir
  run_subprocess(f"mkdir -p {OUTDIR}")

  # Config build
  build_dir = f'build/example'
  build_cmd = f'cmake -S . -B {build_dir} -G Ninja -DBUILD_EXAMPLE=ON > {OUTDIR}/cmake.log'
  run_subprocess(build_cmd)
  
  # Build
  run_subprocess(f'ninja -C {build_dir} > {OUTDIR}/build.log')

  # RUn jobs
  pool = Pool(8)
  skews = [0.8 + 0.01 * i for i in range(20)]
  pool.map(gen_cdf, skews)
  pool.close()
  pool.join()

