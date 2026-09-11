CFLAGS = -O2 -march=native -pthread

probe_idiom: probe_idiom.c
	gcc $(CFLAGS) -o $@ $<

# the inner loops must contain no integer division, or the divide latency
# swamps the difference the benchmark is trying to measure
check-nodiv: probe_idiom
	@n=$$(objdump -d probe_idiom | awk '/<worker>:/{g=1} g&&/^$$/{exit} g' \
	      | grep -cE '\bdivq?|\bidivq?'); \
	 echo "division instructions in worker(): $$n"; \
	 test "$$n" -eq 0

# simd4 must compile to the same sequence as CASHashTable::find_batch
check-codegen: probe_idiom
	@echo "vector ops in probe_idiom:"; \
	 objdump -d probe_idiom | grep -E "vpbroadcastq|vmovdqa64|vpcmpequq|kortestb|kmovb"

clean:
	rm -f probe_idiom
.PHONY: check-nodiv check-codegen clean
