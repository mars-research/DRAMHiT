# Compiler and flags
CC = gcc
CFLAGS = -O3
LDFLAGS = -lpthread -lnuma
BUILD_DIR = build

# Define all target binaries inside the build/ directory
BANDWIDTH_RAND  = $(BUILD_DIR)/bandwidth_rand
BANDWIDTH_SEQ   = $(BUILD_DIR)/bandwidth_seq

PREFETCH_RAND_BIND    = $(BUILD_DIR)/prefetch_rand_bind
PREFETCH_RAND_NONBIND = $(BUILD_DIR)/prefetch_rand_nonbind
PREFETCH_SEQ_BIND     = $(BUILD_DIR)/prefetch_seq_bind
PREFETCH_SEQ_NONBIND  = $(BUILD_DIR)/prefetch_seq_nonbind

BATCH_TEST = $(BUILD_DIR)/batch_test
LATENCY    = $(BUILD_DIR)/latency

# List of all targets
TARGETS = $(BANDWIDTH_RAND) $(BANDWIDTH_SEQ) \
          $(PREFETCH_RAND_BIND) $(PREFETCH_RAND_NONBIND) \
          $(PREFETCH_SEQ_BIND) $(PREFETCH_SEQ_NONBIND) \
          $(BATCH_TEST) $(LATENCY)

.PHONY: all clean directories

# Default rule to build everything
all: directories $(TARGETS)

# Create the build directory if it doesn't exist
directories:
	mkdir -p $(BUILD_DIR)

# --- Bandwidth Targets ---
$(BANDWIDTH_RAND): bandwidth.c
	$(CC) $(CFLAGS) $< $(LDFLAGS) -o $@ -DRANDOM

$(BANDWIDTH_SEQ): bandwidth.c
	$(CC) $(CFLAGS) $< $(LDFLAGS) -o $@ -DSEQUENTIAL

# --- Prefetch Targets (4 configurations) ---
$(PREFETCH_RAND_BIND): prefetch_test.c
	$(CC) $(CFLAGS) $< $(LDFLAGS) -o $@ -DRANDOM

$(PREFETCH_RAND_NONBIND): prefetch_test.c
	$(CC) $(CFLAGS) $< $(LDFLAGS) -o $@ -DRANDOM -DNON_BINDING

$(PREFETCH_SEQ_BIND): prefetch_test.c
	$(CC) $(CFLAGS) $< $(LDFLAGS) -o $@ -DSEQUENTIAL

$(PREFETCH_SEQ_NONBIND): prefetch_test.c
	$(CC) $(CFLAGS) $< $(LDFLAGS) -o $@ -DSEQUENTIAL -DNON_BINDING

# --- Batch and Latency Targets ---
$(BATCH_TEST): batch_test.c
	$(CC) $(CFLAGS) $< $(LDFLAGS) -o $@

$(LATENCY): latency.c
	$(CC) $(CFLAGS) $< $(LDFLAGS) -o $@

# Clean rule to wipe the build directory
clean:
	rm -rf $(BUILD_DIR)
