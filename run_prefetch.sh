
#!/bin/bash

RESULT_FILE="result.txt"
META="1024,9,3.60"

echo "$META" > "$RESULT_FILE"

run_and_log() {
    local compile_cmd="$1"
    local run_cmd="$2"

    echo "Compile: $compile_cmd" | tee -a "$RESULT_FILE"
    eval "$compile_cmd" 2>&1 | tee -a "$RESULT_FILE"

    echo "Run: $run_cmd" | tee -a "$RESULT_FILE"
    eval "$run_cmd" 2>&1 | tee -a "$RESULT_FILE"

    echo "----" >> "$RESULT_FILE"
}

run_and_log "gcc -O1 prefetch_test.c -DLOAD_TEST -o prefetch" "./prefetch 100 1024"
run_and_log "gcc -O1 prefetch_test.c -DLOAD_TEST -DCONFLICT_PREFETCH -o prefetch" "./prefetch 100 1024"
run_and_log "gcc -O1 prefetch_test.c -DLOAD_TEST -DNONCONFLICT_PREFETCH -o prefetch" "./prefetch 100 1024"
run_and_log "gcc -O1 prefetch_test.c -DSTORE_TEST -o prefetch" "./prefetch 100 1024"
run_and_log "gcc -O1 prefetch_test.c -DSTORE_TEST -DCONFLICT_PREFETCH -o prefetch" "./prefetch 100 1024"
run_and_log "gcc -O1 prefetch_test.c -DSTORE_TEST -DNONCONFLICT_PREFETCH -o prefetch" "./prefetch 100 1024"

