

FILE_NAME=output.txt
./collect_amd.sh 3250  single-local 64 r &> $FILE_NAME
./collect_amd.sh 3250  single-local 64 rw &>> $FILE_NAME
./collect_amd.sh 3250  single-local 64 stream_rw &>> $FILE_NAME
./collect_amd.sh 3250  single-local 64 ratio &>> $FILE_NAME