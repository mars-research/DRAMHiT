#!/usr/bin/env bash
set -euo pipefail

LOG_PREFIX="logs/insert_find/"

run_insert_find() {
  key_type=$1
  dry_run=$2
  declare -A httype=( ["casht"]="3" ["partitioned"]="1" ["casht++"]="3")
  #declare -A httype=( ["partitioned"]="1" )
  #declare -A httype=( ["casht"]="3" )
  sudo ./scripts/toggle_hyperthreading.sh off


  for ty in ${!httype[@]}; do 
    MAKE_FLAGS=""
    if [[ $key_type == "kv" ]]; then
      MAKE_FLAGS="AGGR=no "
    fi
    # disable prefetch for casht
    if [[ ${ty} == "casht" ]]; then
      MAKE_FLAGS+="PREFETCH=no "
      echo ${MAKE_FLAGS}
      make clean && make -j ${MAKE_FLAGS}
    # prefetch is already enabled in casht++
    elif [[ ${ty} == "casht++" ]]; then
      echo ${MAKE_FLAGS}
      make clean && make -j ${MAKE_FLAGS}
    # for Partitioned, we use bqueues
    else
      MAKE_FLAGS+="BRANCH=simd BQUEUE=yes"
      echo ${MAKE_FLAGS}
      make clean && make -j ${MAKE_FLAGS}
    fi

    for nt in 1 2 4 8 16 32 64; do
      # turn HT ON for running 64 threaded test
      if [[ $nt == 64 ]] || [[ $ty == "partitioned" && $nt == 32 ]];then
        echo "Turning HT ON"
        sudo ./scripts/toggle_hyperthreading.sh
      fi

      if [[ $ty == "partitioned" ]]; then
        if [[ $nt == 64 ]]; then
          continue
        fi
        nt=$(($nt*2))
      fi

      for i in $(seq 1 5); do
        echo "Running ${key_type} httype $ty|${httype[$ty]} th=${nt} run=$i";
        # change command line parameters to enable bqueues
        if [[ $ty == "partitioned" ]];then
          nprod=$(($nt/2))
          ./kmercounter --mode=8 --ht-fill=75 --nprod ${nprod} --ncons ${nprod} |& tee ${LOG_PREFIX}/${key_type}/uniform-set-get/${ty}/${ty}_${nt}_${i}.log
        else
          ./kmercounter --mode=6 --ht-fill=75 --num-threads ${nt} --ht-type ${httype[$ty]} |& tee ${LOG_PREFIX}/${key_type}/uniform-set-get/${ty}/${ty}_${nt}_${i}.log
        fi
        # Just wait a few seconds before the next test
        sleep 3;
      done
    done
  done
}

# create all the dirs
mkdir -p ${LOG_PREFIX}/{aggr,kv}/uniform-get-set/{casht,casht++,partitioned}

# run insert/find KV type aggregate {uint64_t, counter}
run_insert_find "aggr"

# run insert/find KV type {uint64_t, uint64_t}
run_insert_find "kv"
