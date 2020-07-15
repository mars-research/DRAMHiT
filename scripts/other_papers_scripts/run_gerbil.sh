#!/bin/bash
#=========== gerbil

# configure these
ROOT_DIR=/mnt/nvmedrive/
MAX_CPUS=20

# directories
DATA_DIR=${ROOT_DIR}/datasets/
APPS_DIR=${ROOT_DIR}/kmer-counters/
LOCAL_TMP=${ROOT_DIR}/tmp/
OUT_DIR=${ROOT_DIR}/tmp/
LOG_DIR=${ROOT_DIR}/log/

# datasets
dataset=dm
datafile=${DATA_DIR}/${dataset}/${dataset}.fastq

# run commands
TIME_CMD="/usr/bin/time -v"
CACHE_CLEAR_CMD="free && sync && echo 3 > /proc/sys/vm/drop_caches && free"


# executable
APP=gerbil
GERBIL_EXEC=$APPS_DIR/gerbil/build/gerbil

# test
# echo "/usr/bin/numactl --physcpubind=0-20 ${GERBIL_EXEC} -i -k 27 -e 512GB -t 64 -l 1 ${datafile} $LOCAL_TMP ${LOCAL_TMP}/test.out"
# eval "/usr/bin/numactl --physcpubind=0-20 ${GERBIL_EXEC} -i -k 27 -e 512GB -t 64 -l 1 ${datafile} $LOCAL_TMP ${LOCAL_TMP}/test.out >> ${LOG_DIR}/gerbil_uncached.log 2>&1"
# rm ${LOCAL_TMP}/test.out*

# across different nodes
for t in $MAX_CPUS 16 12 8 4; do

  cpu_max_1=$(((t / 2) - 1))
  cpu_max_2=$((10 + (t / 2) - 1))
  echo "cpu_max_1 ${cpu_max_1}"
  echo "cpu_max_2 ${cpu_max_2}"

  CPU_AFFINITY=0-${cpu_max_1},10-${cpu_max_2}
  NUMA_CMD="/usr/bin/numactl --physcpubind=${CPU_AFFINITY}"
  echo $NUMA_CMD

  for iter in 1 2 3; do

    for K in 15 21 31 63; do

      # gerbil.
      outfile=${OUT_DIR}/gerbil-CANONICAL-k${K}-t${t}-${dataset}.$iter.out
      # canonical
      logfile=${LOG_DIR}/gerbil/gerbil-CANONICAL-k${K}-t${t}-${dataset}.$iter.log

      if [ ! -f $logfile ] || [ "$(tail -1 $logfile)" != "COMPLETED" ]; then

        cmd="${NUMA_CMD} ${GERBIL_EXEC} -i -k ${K} -e 512GB -t ${t} -l 1 ${datafile} $LOCAL_TMP $outfile"
        echo "COMMAND (CANONICAL): ${cmd}"
        echo "LOGFILE: ${logfile}"
        echo "$cmd" > $logfile
        exit

        # eval "$CACHE_CLEAR_CMD >> $logfile 2>&1"
        eval "($TIME_CMD $cmd >> $logfile 2>&1) >> $logfile 2>&1"
        echo "COMPLETED" >>$logfile

        rm ${outfile}*
      else
        echo "$logfile exists and COMPLETED.  skipping."
      fi

    done
    #K

  done
  #iter

done

#t
