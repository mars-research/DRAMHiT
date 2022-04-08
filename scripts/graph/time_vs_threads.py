import re
import subprocess

BUILD_DIR = 'build/tmp'

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
            

def run_test(run_args, outpath):
    # Run kvstore
    run_subprocess(f'{BUILD_DIR}/kvstore {run_args} > {outpath}')

    # Extract cycle count
    return get_insert_cycle_and_throughput(outpath)

# Do stuff for K
def run_test_suite(ht_type, K, build_args, run_args, num_prods, outpath):
    print(f"Running test suite for {ht_type} K={K}")

    # Config build
    build_cmd = f'cmake -S . -B {BUILD_DIR} -G Ninja {build_args} -DKMER_LEN={K} > {outpath}.cmake.log'
    run_subprocess(build_cmd)
    
    # Build
    run_subprocess(f'ninja -C {BUILD_DIR} > {outpath}.build.log')

    # Run tests
    cycles = []
    throughputs = []
    for num_prod in num_prods:
        cycle, throughput = run_test(f'{run_args} --nprod {num_prod} --ncons 32', f'{outpath}/nprod_{num_prod}')
        cycles.append(cycle)
        throughputs.append(throughput)

    # Print result
    print(f"Finished running test suite for {ht_type} K={K}")
    print('Cycles')
    for cycle in cycles:
        print(cycle)
    print('throughput')
    for throughput in throughputs:
        print(throughput)

if __name__ == '__main__':
    Ks = [5, 10, 15]
    NUM_CONS = list(range(10, 33))
    OUTPATH = 'out/vary_threads'
    FASTQ_FILE = '../memfs/SRR077487.2.fastq'
    # FASTQ_FILE = '../memfs/SRR072006.fastq'
    # FASTQ_FILE = '../memfs/1seq.fastq'

    # Run PartitionedHT
    ht_type = 'PARTITIONEDHT'    
    for K in Ks:
        outpath = f'{OUTPATH}/{ht_type}/K_{K}'
        run_subprocess(f'mkdir -p {outpath}')
        build_args = f'-DBQUEUE=ON'
        run_args = f'--mode=8 --ht-type=1 --in-file={FASTQ_FILE}'
        run_test_suite(ht_type, K, build_args, run_args, NUM_CONS, outpath)

    