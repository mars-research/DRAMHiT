#!/bin/bash

run_test() {
  if [ $# -eq 4 ]; then
    TEST_TYPE=$1
    RUNS=$2
    PREFETCHER=$3
    MAX_THREADS=$4
  fi

  SEQ_START=1
  SEQ_END=${MAX_THREADS}
  SEQ_STEP=1

  echo "Performing ${RUNS} runs";

  HT_TYPE=$(echo ${TEST_TYPE} | awk -F'-' '{print $1}')
  KEY_DIST=$(echo ${TEST_TYPE} | awk -F'-' '{print $2}')
  HT_SIZE=$(echo ${TEST_TYPE} | awk -F'-' '{print $3}')
  SKEW=$(echo ${TEST_TYPE} | awk -F'-' '{print $4}')

  PART_RATIO=$(echo ${TEST_TYPE} | awk -F'-' '{print $5}')

  case ${HT_TYPE} in
    "casht"|"casht_cashtpp")
      ARGS="--ht-type 3 --numa-split 1 --no-prefetch 1"
      if [[ ${HT_TYPE} == "casht_cashtpp" ]]; then
        ARGS+=" --run-both 1"
      fi
      ;;
    "cashtpp")
      ARGS="--ht-type 3 --numa-split 1 --no-prefetch 0"
      ;;
    "part")
      ARGS="--ht-type 1 --numa-split 3"
      START_THREAD=4
      ;;
    *)
      echo "Unknown hashtable type ${HT_TYPE}"
      exit;
  esac

  case ${KEY_DIST} in
    "uniform")
      ARGS+=" --mode 6"
      ;;
    "zipfian")
      if [[ "${HT_TYPE}" == "part" ]];then
        ARGS+=" --mode 8"
      else
        ARGS+=" --mode 11"
      fi
      ;;
    *)
      echo "Unknown key distribution ${KEY_DIST}"
      exit;
  esac

  case ${HT_SIZE} in
    "small")
      ARGS+=" --ht-size 1048576"
      ARGS+=" --insert-factor 500"
      if [[ ${HT_TYPE} == "part" ]];then
        ARGS+=" --no-prefetch 1"
      fi
      ;;
    "large")
      # Large ht size is hard-coded in the sources
      #ARGS+=" --ht-size xyz"
      ;;
    *)
      echo "Unknown ht size ${HT_SIZE}"
      exit;
  esac

  case ${SKEW} in
    0.01)
      echo "Found a valid skew ${SKEW}";
      ARGS+=" --skew ${SKEW}"
      ;;
    0.[2-9]*|1.[0-9]*)
      echo "Found a valid skew ${SKEW}";
      ARGS+=" --skew ${SKEW}"
      if [[ "${HT_TYPE}" == "part" ]];then
        SEQ_START=16
        SEQ_END=16
      else
        SEQ_START=64
        SEQ_END=64
      fi
      ;;
    *)
      echo "Unknown skew value ${SKEW}";
      exit
      ;;
  esac


  if [[ -n "${PART_RATIO}" ]];then
    SEQ_START=4
    SEQ_STEP=1
    SEQ_END=${MAX_THREADS}
  fi

  HWP_ARGS=" --hw-pref ${PREFETCHER}"

  ARGS+=${HWP_ARGS}

  echo "Running ${TEST_TYPE} with args ${ARGS}";

  for run in ${RUNS}; do
    ONCE=0
    for i in $(seq ${SEQ_START} ${SEQ_STEP} ${SEQ_END}); do
      LOG_PREFIX="esys23-ae-${USER}/${TEST_TYPE}/run${run}/"
      if [ ! -d ${LOG_PREFIX} ]; then
        mkdir -p ${LOG_PREFIX}
      fi

      if [[ "${HT_TYPE}" == "part" ]];then
        if [[ -n "${PART_RATIO}" ]];then
          NPROD=$(echo "(${i} + 0.5) * 1/4" | bc)
          NCONS=$(echo "(${i} + 1) * 3/4" | bc)
        else
          NPROD=${i}
          NCONS=$(($(nproc) - ${i}));
        fi

        PROD_CONS_ARGS=" --nprod ${NPROD} --ncons ${NCONS}"
        LOG_FILE="${LOG_PREFIX}/${NPROD}-${NCONS}.log"
        echo "Running dramhit with ${ARGS} ${PROD_CONS_ARGS}" > ${LOG_FILE}
        ./build/dramhit ${ARGS} ${PROD_CONS_ARGS} 2>&1 >> ${LOG_FILE}
      else
        LOG_FILE="${LOG_PREFIX}/${i}.log"
        THREAD_ARGS=" --num-threads ${i}"
        echo "Running dramhit with ${ARGS} ${THREAD_ARGS}" > ${LOG_FILE}
        ./build/dramhit ${ARGS} ${THREAD_ARGS} 2>&1 >> ${LOG_FILE}
      fi

      if [[ "${HT_TYPE}" == "casht_cashtpp" ]];then
        CASHT_SET_CYCLES=$(rg "set_cycles : [0-9]+" -o -m1 ${LOG_FILE} | cut -d':' -f2)
        CASHTPP_SET_CYCLES=$(rg "set_cycles : [0-9]+" -o ${LOG_FILE} | cut -d':' -f2 | tail -1)

        CASHT_GET_CYCLES=$(rg "get_cycles : [0-9]+" -o -m1 ${LOG_FILE} | cut -d':' -f2)
        CASHTPP_GET_CYCLES=$(rg "get_cycles : [0-9]+" -o ${LOG_FILE} | cut -d':' -f2 | tail -1)

        CASHT_SET_MOPS=$(rg "set_mops : [0-9\.]+" -o -m1 ${LOG_FILE} | cut -d':' -f2)
        CASHTPP_SET_MOPS=$(rg "set_mops : [0-9\.]+" -o ${LOG_FILE} | cut -d':' -f2 | tail -1)

        CASHT_GET_MOPS=$(rg "get_mops : [0-9\.]+" -o -m1 ${LOG_FILE} | cut -d':' -f2)
        CASHTPP_GET_MOPS=$(rg "get_mops : [0-9\.]+" -o ${LOG_FILE} | cut -d':' -f2 | tail -1)
      else
        INS_CYCLES=$(rg "set_cycles : [0-9]+" -o -m1 ${LOG_FILE} | cut -d':' -f2)
        FIND_CYCLES=$(rg "get_cycles : [0-9]+" -o -m1 ${LOG_FILE} | cut -d':' -f2)
        INS_MOPS=$(rg "set_mops : [0-9\.]+" -o -m1 ${LOG_FILE} | cut -d':' -f2)
        FIND_MOPS=$(rg "get_mops : [0-9\.]+" -o -m1 ${LOG_FILE} | cut -d':' -f2)
      fi

      if [ ${ONCE} == 0 ]; then
        if [[ "${HT_TYPE}" == "part" ]];then
          printf "nprod-ncons, ins-cycles, ins mops/s, find-cycles, find mops/s\n" | tee -a ${LOG_PREFIX}/part_run${run}.csv;
          # add empty csv lines to plot dummy data for the first few datapoints
          if [[ -n ${PART_RATIO} ]]; then
            for i in $(seq 1 $((${NPROD}+${NCONS}-1))); do
              echo ", , , ," | tee -a ${LOG_PREFIX}/part_run${run}.csv;
            done
          fi
        elif [[ "${HT_TYPE}" == "casht_cashtpp" ]];then
          printf "num_threads, set-cycles, casht-set-${HT_SIZE}, get-cycles, casht-get-${HT_SIZE}\n" | tee -a ${LOG_PREFIX}/casht_run${run}.csv;
          printf "num_threads, set-cycles, cashtpp-set-${HT_SIZE}, get-cycles, cashtpp-get-${HT_SIZE}\n" | tee -a ${LOG_PREFIX}/cashtpp_run${run}.csv;
        else
          printf "num_threads, ins-cycles, ins mops/s, find-cycles, find mops/s\n" | tee -a ${LOG_PREFIX}/summary_run${run}.csv;
        fi
        ONCE=1
      fi

      if [[ "${HT_TYPE}" == "part" ]];then
        printf "%s, %s, %.0f, %s, %.0f\n" ${NPROD}-${NCONS} ${INS_CYCLES} $(echo ${INS_MOPS} | bc) ${FIND_CYCLES} $(echo ${FIND_MOPS} | bc) | tee -a ${LOG_PREFIX}/part_run${run}.csv;
      elif [[ "${HT_TYPE}" == "casht_cashtpp" ]];then
        printf "%s, %s, %.0f, %s, %.0f\n" ${i} ${CASHT_SET_CYCLES} $(echo ${CASHT_SET_MOPS} | bc) ${CASHT_GET_CYCLES} $(echo ${CASHT_GET_MOPS} | bc) | tee -a ${LOG_PREFIX}/casht_run${run}.csv;
        printf "%s, %s, %.0f, %s, %.0f\n" ${i} ${CASHTPP_SET_CYCLES} $(echo ${CASHTPP_SET_MOPS} | bc) ${CASHTPP_GET_CYCLES} $(echo ${CASHTPP_GET_MOPS} | bc) | tee -a ${LOG_PREFIX}/cashtpp_run${run}.csv;
      else
        printf "%s, %s, %.0f, %s, %.0f\n" ${i} ${INS_CYCLES} $(echo ${INS_MOPS} | bc) ${FIND_CYCLES} $(echo ${FIND_MOPS} | bc) | tee -a ${LOG_PREFIX}/summary_run${run}.csv;
      fi
    done
  done
}


DRAMHIT_BASE=/opt/dramhit
DATASET_DIR=${DRAMHIT_BASE}/kmer_dataset

declare -A DATASET_ARRAY
DATASET_ARRAY["dmela"]=${DATASET_DIR}/ERR4846928.fastq
DATASET_ARRAY["fvesca"]=${DATASET_DIR}/SRR1513870.fastq

MAX_K=32

run_kmer_test() {
  if [ $# -eq 4 ]; then
    TEST_TYPE=$1
    RUNS=$2
    PREFETCHER=$3
    MAX_THREADS=$4
  fi

  
  echo  TEST_TYPE $1
  echo  RUNS $2
  echo  PREFETCHER $3
  echo  MAX_THREADS $4
  HT_TYPE=$(echo ${TEST_TYPE} | awk -F'-' '{print $1}')
  MODE=$(echo ${TEST_TYPE} | awk -F'-' '{print $2}')
  GENOME=$(echo ${TEST_TYPE} | awk -F'-' '{print $3}')

  case ${HT_TYPE} in
    "casht")
      ARGS="--ht-type 3 --numa-split 1 --no-prefetch 1"
      ARGS+=" --num-threads ${MAX_THREADS}"
      ;;
    "cashtpp")
      ARGS="--ht-type 3 --numa-split 1 --no-prefetch 0"
      ARGS+=" --num-threads ${MAX_THREADS}"
      ;;
    "part")
      ARGS="--ht-type 1 --numa-split 3 --nprod 32 --ncons 32"
      START_THREAD=4
      ;;
    *)
      echo "Unknown hashtable type ${HT_TYPE}"
      exit;
  esac

  case ${MODE} in
    "kmer")
      ARGS+=" --mode 4"
      ;;
    "kmer_radix")
      ARGS+=" --mode 14"
      ;;
    *)
      echo "Unknown mode ${MODE}"
      exit;
  esac

  FASTA_FILE=${DATASET_ARRAY[${GENOME}]}

  if [ "${GENOME}" == "fvesca" ];then
    ARGS+=" --ht-size 8589934592"
  else
    ARGS+=" --ht-size 4294967296"
  fi

  ARGS+=" --in-file ${FASTA_FILE}"


  for run in ${RUNS}; do
    ONCE=0
    LOG_PREFIX="esys23-ae-${USER}/${TEST_TYPE}/run${run}/"

    for k in $(seq 32 ${MAX_K}); do
      LOG_FILE="${LOG_PREFIX}/k${k}_t${MAX_THREADS}_${GENOME}.log"

      if [ ! -d ${LOG_PREFIX} ]; then
        mkdir -p ${LOG_PREFIX}
      fi

      echo "Running dramhit with ${ARGS} --k ${k}" > ${LOG_FILE}
      ./build/dramhit ${ARGS} --k ${k} 2>&1 >> ${LOG_FILE}

      MOPS=$(rg "set_mops : [0-9\.]+" -o -m1 ${LOG_FILE} | cut -d':' -f2)

      if [ ${ONCE} == 0 ]; then
        printf "k, ${HT_TYPE}-set-${GENOME}-mops\n" | tee -a ${LOG_PREFIX}/summary_${GENOME}.csv;
        ONCE=1
      fi

      echo "${k}, ${MOPS}" | tee -a "${LOG_PREFIX}/summary_${GENOME}.csv"
    done
  done
}

MLC_BIN=/local/devel/mlc/mlc
run_mlc_test() {
  if [ $# -eq 3 ]; then
    TEST_TYPE=$1
    RUNS=$2
    MAX_THREADS=$3
  fi

  case ${TEST_TYPE} in
    "max-bw-all")
      ARGS="--max_bandwidth"
      ;;
    *)
      echo "Unknown test type. exiting"
      exit;
  esac

  for run in ${RUNS}; do
    LOG_PREFIX="esys22-logs/mlc/${TEST_TYPE}/run${run}/"
    if [ ! -d ${LOG_PREFIX} ]; then
      mkdir -p ${LOG_PREFIX}
    fi

    LOG_FILE="${LOG_PREFIX}/${run}.log"

    echo "Running mlc with ${ARGS}"
    sudo ${MLC_BIN} ${ARGS} 2>&1 > ${LOG_FILE}
  done
}

NUM_RUNS=1
MAX_THREADS_CASHT=64
MAX_THREADS_PART=32
MAX_THREADS_BQ=32
HW_PREF_OFF=0

## Small HT
#run_test "casht-zipfian-small-0.01" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
#run_test "cashtpp-zipfian-small-0.01" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
# -------

## Large HT
#run_test "casht-zipfian-large-0.01" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
#run_test "cashtpp-zipfian-large-0.01" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
# -------

## Large HT monotonic
#run_test "casht-uniform-large" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
#run_test "cashtpp-uniform-large" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
# -------

## casht skewed tests
#for s in 0.01 0.2 0.4 0.6 $(seq 0.8 0.01 1.09); do
#   run_test "casht-zipfian-small-${s}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
#   run_test "casht-zipfian-large-${s}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
#done

## cashtpp-skewed
#for s in 0.01 0.2 0.4 0.6 $(seq 0.8 0.01 1.09); do
#  run_test "cashtpp-zipfian-small-${s}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
#  run_test "cashtpp-zipfian-large-${s}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
#done

# AE figs 7-14
run_small_ht_benchmarks() {
  for s in 0.01 0.2 0.4 0.6 $(seq 0.8 0.01 1.09); do
    run_test "casht_cashtpp-zipfian-small-${s}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
  done

  run_test "part-zipfian-small-0.01-1:3" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}

  for s in 0.2 0.4 0.6 $(seq 0.8 0.01 1.09); do
    run_test "part-zipfian-small-${s}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_PART}
  done
}

run_large_ht_benchmarks() {
  for s in 0.01 0.2 0.4 0.6 $(seq 0.8 0.01 1.09); do
    run_test "casht_cashtpp-zipfian-large-${s}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
  done

  run_test "part-zipfian-large-0.01-1:3" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}

  for s in 0.2 0.4 0.6 $(seq 0.8 0.01 1.09); do
    run_test "part-zipfian-large-${s}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_PART}
  done
}

run_ht_benchmarks() {
  run_small_ht_benchmarks;
  run_large_ht_benchmarks;
}

run_kmer_benchmarks() {
  for genome in "fvesca" ; do
    # run_kmer_test "casht-kmer-${genome}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
    # run_kmer_test "cashtpp-kmer-${genome}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
    run_kmer_test "casht-kmer-${genome}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
  done
}

run_kmer_radix_benchmarks() {
  for genome in "fvesca" ; do
    # run_kmer_test "casht-kmer-${genome}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
    # run_kmer_test "cashtpp-kmer-${genome}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
    run_kmer_test "casht-kmer_radix-${genome}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
  done
}

run_cashtpp_batch_benchmarks() {
  HT_SIZE=large
  run=1

  LOG_PREFIX="esys23-ae-${USER}/cashtpp-zipfian-large-0.01-batching/run${run}/"

  if [ ! -d ${LOG_PREFIX} ]; then
    mkdir -p ${LOG_PREFIX}
  fi

  printf "batch_len, set-cycles, cashtpp-set-${HT_SIZE}, get-cycles, cashtpp-get-${HT_SIZE}\n" | tee -a ${LOG_PREFIX}/cashtpp_run${run}.csv;
  for i in 1 2 4 8 16; do
    LOG_FILE="${LOG_PREFIX}/${i}.log"
    ./build/dramhit --ht-type 3 --numa-split 1 --mode 11 --skew 0.01 --hw-pref 0 --num-threads 64 --batch-len ${i} 2>&1 >> ${LOG_FILE};
    CASHTPP_SET_CYCLES=$(rg "set_cycles : [0-9]+" -o ${LOG_FILE} | cut -d':' -f2 | tail -1)
    CASHTPP_GET_CYCLES=$(rg "get_cycles : [0-9]+" -o ${LOG_FILE} | cut -d':' -f2 | tail -1)
    CASHTPP_SET_MOPS=$(rg "set_mops : [0-9\.]+" -o ${LOG_FILE} | cut -d':' -f2 | tail -1)
    CASHTPP_GET_MOPS=$(rg "get_mops : [0-9\.]+" -o ${LOG_FILE} | cut -d':' -f2 | tail -1)
    printf "%s, %s, %.0f, %s, %.0f\n" ${i} ${CASHTPP_SET_CYCLES} $(echo ${CASHTPP_SET_MOPS} | bc) ${CASHTPP_GET_CYCLES} $(echo ${CASHTPP_GET_MOPS} | bc) | tee -a ${LOG_PREFIX}/cashtpp_run${run}.csv;
  done
}

run_part_batch_benchmarks() {
  HT_SIZE=large
  run=1

  LOG_PREFIX="esys23-ae-${USER}/part-zipfian-large-0.01-1:3-batching/run${run}/"

  if [ ! -d ${LOG_PREFIX} ]; then
    mkdir -p ${LOG_PREFIX}
  fi

  printf "batch_len, ins-cycles, ins mops/s, find-cycles, find mops/s\n" | tee -a ${LOG_PREFIX}/part_run${run}.csv;
  for i in 1 2 4 8 16; do
    LOG_FILE="${LOG_PREFIX}/${i}.log"
    ./build/dramhit --ht-type 1 --numa-split 3 --mode 8 --skew 0.01 --hw-pref 0 --nprod 16 --ncons 48 --batch-len ${i} 2>&1 >> ${LOG_FILE}
    PART_SET_CYCLES=$(rg "set_cycles : [0-9]+" -o ${LOG_FILE} | cut -d':' -f2 | tail -1)
    PART_GET_CYCLES=$(rg "get_cycles : [0-9]+" -o ${LOG_FILE} | cut -d':' -f2 | tail -1)
    PART_SET_MOPS=$(rg "set_mops : [0-9\.]+" -o ${LOG_FILE} | cut -d':' -f2 | tail -1)
    PART_GET_MOPS=$(rg "get_mops : [0-9\.]+" -o ${LOG_FILE} | cut -d':' -f2 | tail -1)
    printf "%s, %s, %.0f, %s, %.0f\n" ${i} ${PART_SET_CYCLES} $(echo ${PART_SET_MOPS} | bc) ${PART_GET_CYCLES} $(echo ${PART_GET_MOPS} | bc) | tee -a ${LOG_PREFIX}/part_run${run}.csv;
  done

}

run_batch_benchmarks() {
  run_cashtpp_batch_benchmarks;
  run_part_batch_benchmarks;
}

if [[ $1 == "ht" ]]; then
  run_ht_benchmarks
elif [[ $1 == "kmer" ]]; then
  run_kmer_benchmarks
elif [[ $1 == "kmer_radix" ]]; then
  run_kmer_radix_benchmarks
elif [[ $1 == "batching" ]]; then
  run_batch_benchmarks
fi
