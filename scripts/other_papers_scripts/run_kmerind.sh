#!/bin/bash
#=========== kmerind

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

# the binary
APP=kmerind
KMERIND_BIN_DIR=${APPS_DIR}/kmerhash/build/bin
EXEC=${KMERIND_BIN_DIR}/testKmerCounter-FASTQ-a4-k31-CANONICAL-DENSEHASH-COUNT-dtIDEN-dhFARM-shFARM

# test
# echo "/usr/bin/mpiexec -np 20 --cpu-set 0-19 $EXEC -O ${LOCAL_TMP}/test.out ${datafile}" > ${LOG_DIR}/kmerind_uncached.log
# eval "/usr/bin/mpiexec -np 20 --cpu-set 0-19 $EXEC -O ${LOCAL_TMP}/test.out ${datafile}" > ${LOG_DIR}/kmerind_uncached.log >> ${LOG_DIR}/kmerind_uncached.log 2>&1

# rm ${LOCALTMP}/test.out*

#drop cache
#eval "sudo /usr/local/crashplan/bin/CrashPlanEngine stop"
#eval "/usr/local/sbin/drop_caches"

# across different nodes
for t in $MAX_CPUS 16 12 8 4; do

  cpu_max_1=$(((t / 2) - 1))
  cpu_max_2=$((10 + (t / 2) - 1))
  echo "cpu_max_1 ${cpu_max_1}"
  echo "cpu_max_2 ${cpu_max_2}"

  CPU_AFFINITY=0-${cpu_max_1},10-${cpu_max_2}
  MPI_CMD="/usr/bin/mpiexec -np ${t} --cpu-set ${CPU_AFFINITY}"
  echo MPI_CMD:$MPI_CMD

  for iter in 1 2 3; do

    for K in 15 21 31 63; do

      for map in RADIXSORT BROBINHOOD; do

        hash=MURMUR64avx

        for EXEC in ${KMERIND_BIN_DIR}/testKmerCounter-FASTQ-a4-k${K}-CANONICAL-${map}-COUNT-dtIDEN-dh${hash}-shCRC32C; do

          exec_name=$(basename ${EXEC})

          logfile=${LOG_DIR}/kmerind/${exec_name}-n1-p${t}-${dataset}.$iter.log
          outfile=${OUT_DIR}/${exec_name}-n1-p${t}-${dataset}.$iter.bin

          # only execute if the file does not exist.
          if [ ! -f $logfile ] || [ "$(tail -1 $logfile)" != "COMPLETED" ]; then

            # command to execute
            cmd="${MPI_CMD} $EXEC -O $outfile -B 6 ${datafile}"
            echo $cmd
            echo "COMMAND" >$logfile
            echo $cmd >>$logfile
            echo "COMMAND: ${cmd}"
            echo "LOGFILE: ${logfile}"

            # call the executable and save the results
            echo "RESULTS" >>$logfile
            eval "($TIME_CMD $cmd >> $logfile 2>&1) >> $logfile 2>&1"

            echo "COMPLETED" >>$logfile
            echo "$exec_name COMPLETED."
            rm ${outfile}*

          else

            echo "$logfile exists and COMPLETED.  skipping."
          fi

        done
        #EXEC

      done

      #map

      #================ Densehash (Kmerind)
      map=DENSEHASH
      hash=FARM

      # kmerind
      for EXEC in ${KMERIND_BIN_DIR}/testKmerCounter-FASTQ-a4-k${K}-CANONICAL-${map}-COUNT-dtIDEN-dh${hash}-sh${hash}; do

        exec_name=$(basename ${EXEC})

        logfile=${logdir}/kmerind/${exec_name}-n1-p${t}-${dataset}.$iter.log
        outfile=${OUT_DIR}/${exec_name}-n1-p${t}-${dataset}.$iter.bin

        # only execute if the file does not exist.
        if [ ! -f $logfile ] || [ "$(tail -1 $logfile)" != "COMPLETED" ]; then

          # command to execute
          cmd="${MPI_CMD} $EXEC -O $outfile -B 6 ${datafile}"
          echo "COMMAND" >$logfile
          echo $cmd >>$logfile
          echo "COMMAND: ${cmd}"
          echo "LOGFILE: ${logfile}"

          # call the executable and save the results
          echo "RESULTS" >>$logfile
          eval "($TIME_CMD $cmd >> $logfile 2>&1) >> $logfile 2>&1"

          echo "COMPLETED" >>$logfile
          echo "$exec_name COMPLETED."
          rm ${outfile}*

        else

          echo "$logfile exists and COMPLETED.  skipping."
        fi

      done
      #EXEC

    done

    #K

  done
  #iter

done

#t
