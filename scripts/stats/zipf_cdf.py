import subprocess

OUTDIR = "out/zipf_cdf"

def run_subprocess(cmd):
    print(f'Running <{cmd}>')
    return subprocess.check_output(cmd, shell=True)

def gen_cdf(skew, outfile):
    # Run dumper
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

  skews = [0.2, 0.5, 0.8]
  for skew in skews:
    gen_cdf(skew, f'{OUTDIR}/cdf_{skew:.2f}.csv')

