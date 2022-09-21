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
      ARGS+=" --ht-size 2097152"
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
    SEQ_START=${MAX_THREADS}
    SEQ_STEP=-1
    SEQ_END=4
  fi

  HWP_ARGS=" --hw-pref ${PREFETCHER}"

  ARGS+=${HWP_ARGS}

  echo "Running ${TEST_TYPE} with args ${ARGS}";

  for run in ${RUNS}; do
    ONCE=0
    for i in $(seq ${SEQ_START} ${SEQ_STEP} ${SEQ_END}); do
      LOG_PREFIX="esys22-logs/${TEST_TYPE}/run${run}/"
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
        echo "Running kvstore with ${ARGS} ${PROD_CONS_ARGS}" > ${LOG_FILE}
        ./build/kvstore ${ARGS} ${PROD_CONS_ARGS} 2>&1 >> ${LOG_FILE}
      else
        LOG_FILE="${LOG_PREFIX}/${i}.log"
        THREAD_ARGS=" --num-threads ${i}"
        echo "Running kvstore with ${ARGS} ${THREAD_ARGS}" > ${LOG_FILE}
        ./build/kvstore ${ARGS} ${THREAD_ARGS} 2>&1 >> ${LOG_FILE}
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
        INS_CYCLES=$(rg "[0-9]+ cycles/insert" -o  ${LOG_FILE} | tail -1 | awk '{print $1}');
        FIND_CYCLES=$(rg "[0-9]+ cycles/find" -o  ${LOG_FILE} | tail -1 | awk '{print $1}');
        INS_MOPS=$(rg "insertions per sec \(Mops/s\)" ${LOG_FILE} | cut -d':' -f2);
        FIND_MOPS=$(rg "finds per sec \(Mops/s\)" ${LOG_FILE} | cut -d':' -f2);
      fi

      if [ ${ONCE} == 0 ]; then
        if [[ "${HT_TYPE}" == "part" ]];then
          printf "nprod-ncons, ins-cycles, ins mops/s, find-cycles, find mops/s\n" | tee -a ${LOG_PREFIX}/summary_run${run}.csv;
        elif [[ "${HT_TYPE}" == "casht_cashtpp" ]];then
          printf "num_threads, set-cycles, casht-set-${HT_SIZE}, get-cycles, casht-get-${HT_SIZE}\n" | tee -a ${LOG_PREFIX}/casht_run${run}.csv;
          printf "num_threads, set-cycles, cashtpp-set-${HT_SIZE}, get-cycles, cashtpp-get-${HT_SIZE}\n" | tee -a ${LOG_PREFIX}/cashtpp_run${run}.csv;
        else
          printf "num_threads, ins-cycles, ins mops/s, find-cycles, find mops/s\n" | tee -a ${LOG_PREFIX}/summary_run${run}.csv;
        fi
        ONCE=1
      fi

      if [[ "${HT_TYPE}" == "part" ]];then
        printf "%s, %s, %.0f, %s, %.0f\n" ${NPROD}-${NCONS} ${INS_CYCLES} $(echo ${INS_MOPS} | bc) ${FIND_CYCLES} $(echo ${FIND_MOPS} | bc) | tee -a ${LOG_PREFIX}/summary_run${run}.csv;
      elif [[ "${HT_TYPE}" == "casht_cashtpp" ]];then
        printf "%s, %s, %.0f, %s, %.0f\n" ${i} ${CASHT_SET_CYCLES} $(echo ${CASHT_SET_MOPS} | bc) ${CASHT_GET_CYCLES} $(echo ${CASHT_GET_MOPS} | bc) | tee -a ${LOG_PREFIX}/casht_run${run}.csv;
        printf "%s, %s, %.0f, %s, %.0f\n" ${i} ${CASHTPP_SET_CYCLES} $(echo ${CASHTPP_SET_MOPS} | bc) ${CASHTPP_GET_CYCLES} $(echo ${CASHTPP_GET_MOPS} | bc) | tee -a ${LOG_PREFIX}/cashtpp_run${run}.csv;
      else
        printf "%s, %s, %.0f, %s, %.0f\n" ${i} ${INS_CYCLES} $(echo ${INS_MOPS} | bc) ${FIND_CYCLES} $(echo ${FIND_MOPS} | bc) | tee -a ${LOG_PREFIX}/summary_run${run}.csv;
      fi
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

for s in 0.01 0.2 0.4 0.6 $(seq 0.8 0.01 1.09); do
   run_test "casht_cashtpp-zipfian-small-${s}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
done

for s in 0.01 0.2 0.4 0.6 $(seq 0.8 0.01 1.09); do
   run_test "casht_cashtpp-zipfian-large-${s}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
done

#for s in 0.2 0.4 0.6 $(seq 0.8 0.01 1.09); do
#  run_test "part-zipfian-small-${s}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_PART}
#  run_test "part-zipfian-large-${s}" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_PART}
#done
#
#run_test "part-zipfian-small-0.01-1:3" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}
#run_test "part-zipfian-large-0.01-1:3" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_CASHT}

#run_test "part-zipfian-small-0.01" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_PART}
#run_test "part-zipfian-large-0.01" ${NUM_RUNS} ${HW_PREF_OFF} ${MAX_THREADS_PART}

## MLC tests
#run_mlc_test "max-bw-all" ${NUM_RUNS} ${MAX_THREADS_CASHT}
# -------
