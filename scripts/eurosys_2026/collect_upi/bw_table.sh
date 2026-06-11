# if [ "$test" = "r" ]; then
# workload=0
# elif [ "$test" = "seq_r" ]; then
# workload=1
# elif [ "$test" = "rw" ]; then
# workload=2
# elif [ "$test" = "ratio" ]; then
# workload=3
# elif [ "$test" = "seq_rw" ]; then
# workload=4
# elif [ "$test" = "stream_rw" ]; then
# workload=5
# elif [ "$test" = "cas" ]; then
# workload=6
# fi




FILE_NAME=output.txt
#!/bin/bash

if [ "$#" -ne 1 ]; then
     echo "Usage: ./collect.sh <amd|intel> ʕ•ᴥ•ʔ"
     exit 1
fi

if [ "$1" = "amd" ]; then
    ./collect.sh 3250 single-local 64 amd r &>  "$FILE_NAME"
    ./collect.sh 3250 single-local 64 amd rw &>> "$FILE_NAME"
    ./collect.sh 3250 single-local 64 amd seq_r &>> "$FILE_NAME"
    ./collect.sh 3250 single-local 64 amd seq_rw &>> "$FILE_NAME"
else
    # Single Local
    # ./collect.sh 2500 single-local 64 intel r &>  "$FILE_NAME"
    # ./collect.sh 2500 single-local 64 intel rw &>> "$FILE_NAME"
    # ./collect.sh 2500 single-local 64 intel seq_r &>> "$FILE_NAME"
    # ./collect.sh 2500 single-local 64 intel seq_rw &>> "$FILE_NAME"
    # Single Remote
    # ./collect.sh 2500 single-remote 64 intel r &>  "$FILE_NAME"
    # ./collect.sh 2500 single-remote 64 intel rw &>> "$FILE_NAME"
    # ./collect.sh 2500 single-remote 64 intel seq_r &>> "$FILE_NAME"
    # ./collect.sh 2500 single-remote 64 intel seq_rw &>> "$FILE_NAME"
    # Single MIXED
    # ./collect.sh 2500 mixed 64 intel r &>  "$FILE_NAME"
    # ./collect.sh 2500 mixed 64 intel rw &>> "$FILE_NAME"
    # ./collect.sh 2500 mixed 64 intel seq_r &>> "$FILE_NAME"
    # ./collect.sh 2500 mixed 64 intel seq_rw &>> "$FILE_NAME"

    #   DUAL SOCKET
    # Single Local
    # ./collect.sh 2500 all-local 128 intel r &>  "$FILE_NAME"
    # ./collect.sh 2500 all-local 128 intel rw &>> "$FILE_NAME"
    # ./collect.sh 2500 all-local 128 intel seq_r &>> "$FILE_NAME"
    # ./collect.sh 2500 all-local 128 intel seq_rw &>> "$FILE_NAME"
    # Single Remote
    # ./collect.sh 2500 all-remote 128 intel r &>  "$FILE_NAME"
    # ./collect.sh 2500 all-remote 128 intel rw &>> "$FILE_NAME"
    # ./collect.sh 2500 all-remote 128 intel seq_r &>> "$FILE_NAME"
    # ./collect.sh 2500 all-remote 128 intel seq_rw &>> "$FILE_NAME"
    # # Single MIXED
    # ./collect.sh 2500 even 64 intel r &>  "$FILE_NAME"
    # ./collect.sh 2500 even 64 intel rw &>> "$FILE_NAME"
    # ./collect.sh 2500 even 64 intel seq_r &>> "$FILE_NAME"
    # ./collect.sh 2500 even 64 intel seq_rw &>> "$FILE_NAME"
    

    # intel's pmu events report memory transactions, ie, 64 bytes each, normalize to GBs
  awk '
    /unc_m_cas_count\.(all|rd|wr)/ {
        count = $2
        gsub(/,/, "", count)
        gbs = count * 64 / 1000000000.0
        printf "%12s %10.3f GB/s %s\n", $1, gbs, $3
        next
    }
    { print }
    ' "$FILE_NAME" > "${FILE_NAME}.gbs"
fi