# Generate the histogram from an input file
import numpy as np
import matplotlib.pyplot as plt
import subprocess

def run_subprocess(cmd):
    print(f'Running <{cmd}>')
    subprocess.run(cmd, check=True, shell=True)

def gen_values(K, inpath, outpath):
    print(f'Generating K={K} from {input} to {outpath}')

    # Config build
    build_dir = f'build/example'
    build_cmd = f'cmake -S . -B {build_dir} -G Ninja -DBUILD_EXAMPLE=ON > {outpath}.cmake.log'
    run_subprocess(build_cmd)
    
    # Build
    run_subprocess(f'ninja -C {build_dir} > {outpath}.build.log')

    # Run dumper
    run_subprocess(f'{build_dir}/examples/dump_kmer_hash --input_file={inpath} --output_file={outpath} > {outpath}.log')

def hist_from_values(inputfile, title, outputfile):
  with open(inputfile, 'rb') as f:
    print(f'Loading data from {inputfile}')
    nums = f.read()
    nums = np.frombuffer(nums, dtype=np.uint64)
    print(f"Finish load data from {inputfile}")
    print(f"{len(np.unique(nums))} unique elements")
    hist, _ = np.histogram(nums, 200)
    hist[::-1].sort()
    plt.bar(np.arange(len(hist)), hist)
    plt.title(title)
    plt.savefig(outputfile)


if __name__ == "__main__":
  INPUT = "../memfs/SRR077487.2.fastq"
  OUTDIR = "out/hist"
  Ks = range(4, 33)
  for K in Ks:
    outdir = f'{OUTDIR}/{K}'
    run_subprocess(f"mkdir -p {outdir}")

    value_file = f'{outdir}/values'
    gen_values(K, INPUT, value_file)
    hist_from_values(value_file, f'Histogram K={K} file={INPUT}', f'{value_file}.jpg')

