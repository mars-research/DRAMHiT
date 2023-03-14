import re
import subprocess

OUTPATH = 'out/hashjoin'
BUILD_DIR = f'build/hashjoin'

def run_subprocess(cmd):
  print(f'Running <{cmd}>')
  subprocess.run(cmd, check=True, shell=True)

def get_find_cycle_and_throughput(file):
  with open(file, 'r') as f:
    text = f.read()
    cycles = int(re.search(
      r'Average  : .* cycles for .* finds \((?P<cycles>(?:[0-9]*)) cycles/find\)', text)['cycles'])
    throughput = float(re.search(
    r'Number of finds per sec \(Mops/s\): (?P<mops>(?:[0-9]*\.[0-9]*)|inf)', text)['mops'])
    return (cycles, throughput)
      

def run_test(dramhit_args, outpath):
  # Run dramhit
  run_subprocess(f'{BUILD_DIR}/dramhit {dramhit_args} > {outpath}')

  # Extract cycle count
  return get_find_cycle_and_throughput(outpath)

if __name__ == '__main__':
  # Config build
  run_subprocess(f'mkdir -p {OUTPATH}')
  build_cmd = f'cmake -S . -B {BUILD_DIR} -G Ninja -DBUILD_EXAMPLE=ON > {OUTPATH}/cmake.log'
  run_subprocess(build_cmd)
  
  # Build
  run_subprocess(f'ninja -C {BUILD_DIR} > {OUTPATH}/build.log')

  # Datasize in milion keys for both R and S.
  ONE_MILLION = int(1E6)
  # ONE_MILLION = 1
  data_sizes = [128 * (2**i) for i in range(8)]

  # Run CASHT++
  cycles = []
  test_type = 'CASHTPP'
  run_subprocess(f'mkdir -p {OUTPATH}/{test_type}')
  dramhit_args = f'--num-threads=64 --mode=12 --ht-type=3 --numa-split=1'
  for data_size in data_sizes:
    # Generate dataset
    print(f'Running size={data_size}')
    run_subprocess(f'mkdir -p {OUTPATH}/{data_size}')
    run_subprocess(f'{BUILD_DIR}/examples/generate_dataset --num_keys={data_size * ONE_MILLION} > {OUTPATH}/{data_size}/gen.log')

    # Run testes 
    outpath = f'{OUTPATH}/{data_size}/{test_type}'
    run_subprocess(f'mkdir -p {outpath}')

    rtn = run_test(dramhit_args, f'{OUTPATH}/{data_size}.log')
    print(f'cycles {rtn}')
    cycles.append(rtn)
  print(f'{test_type}: {cycles}')

  