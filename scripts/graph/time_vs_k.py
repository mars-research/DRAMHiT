import re
import subprocess

def run_subprocess(cmd):
    print(f'Running <{cmd}>')
    subprocess.run(cmd, check=True, shell=True)

def get_insert_cycle_and_throughput(file):
    with open(file, 'r') as f:
        text = f.read()
        cycles = int(re.search(
            r'Average  : .* cycles \(.* ms\) for .* insertions \((?P<cycles>(?:[0-9]*)) cycles/insert\) \(fill = .* %\)', text)['cycles'])
        throughput = float(re.search(
        r'Number of insertions per sec \(Mops/s\): (?P<mops>(?:[0-9]*\.[0-9]*)|inf)', text)['mops'])
        return (cycles, throughput)
            

def run_test(extra_build_args, extra_dramhit_args, outpath):
    # Config build
    build_dir = f'build/tmp'
    build_cmd = f'cmake -S . -B {build_dir} -G Ninja {extra_build_args} > {outpath}.cmake.log'
    run_subprocess(build_cmd)
    
    # Build
    run_subprocess(f'ninja -C {build_dir} > {outpath}.build.log')

    # Run dramhit
    run_subprocess(f'{build_dir}/dramhit {extra_dramhit_args} > {outpath}')

    # Extract cycle count
    return get_insert_cycle_and_throughput(outpath)

if __name__ == '__main__':
    Ks = list(range(4, 33))
    # Ks = [15] * 10
    OUTPATH = 'out'
    FASTQ_FILE = '../memfs/SRR077487.2.fastq'
    # FASTQ_FILE = '../memfs/SRR072006.fastq'

    # Run CASHT++
    casht_cycles = []
    test_type = 'CASHT'
    run_subprocess(f'mkdir -p {OUTPATH}/{test_type}')
    for K in Ks:
        print(f'Running {test_type} K={K}')
        build_args = f'-DBQUEUE=OFF -DKMER_LEN={K}'
        dramhit_args = f'--num-threads=64 --mode=6 --ht-type=3 --numa-split=1 --in-file={FASTQ_FILE}'
        rtn = run_test(build_args, dramhit_args, f'{OUTPATH}/{test_type}/{K}.log')
        print(f'cycles {rtn}')
        casht_cycles.append(rtn)
    print(f'{test_type}: {casht_cycles}')

    # Run CASHT++ 32
    casht32_cycles = []
    test_type = 'CASHT'
    run_subprocess(f'mkdir -p {OUTPATH}/{test_type}')
    for K in Ks:
        print(f'Running {test_type} K={K}')
        build_args = f'-DBQUEUE=OFF -DKMER_LEN={K}'
        dramhit_args = f'--num-threads=32 --mode=6 --ht-type=3 --numa-split=1 --in-file={FASTQ_FILE}'
        rtn = run_test(build_args, dramhit_args, f'{OUTPATH}/{test_type}/{K}.log')
        print(f'cycles {rtn}')
        casht32_cycles.append(rtn)
    print(f'{test_type}: {casht32_cycles}')

    # Run PartitionedHT
    partitionedht_cycles = []
    test_type = 'PARTITIONEDHT'
    run_subprocess(f'mkdir -p {OUTPATH}/{test_type}')
    for K in Ks:
        print(f'Running {test_type} K={K}')
        build_args = f'-DBQUEUE=ON -DKMER_LEN={K}'
        dramhit_args = f'--nprod 32 --ncons 32 --mode=8 --ht-type=1 --in-file={FASTQ_FILE}'
        rtn = run_test(build_args, dramhit_args, f'{OUTPATH}/{test_type}/{K}.log')
        print(f'cycles {rtn}')
        partitionedht_cycles.append(rtn)
    print(f'{test_type}: {partitionedht_cycles}')

    