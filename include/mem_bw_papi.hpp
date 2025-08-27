#pragma once

#include <vector>

#include "PapiEvent.hpp"

namespace kmercounter {

class MemoryBwCounters {
 public:
  const std::string imc_box = "emr_unc_imc";
  const std::string cas_rd = "UNC_M_CAS_COUNT:RD";
  const std::string cas_wr = "UNC_M_CAS_COUNT:WR";

  // XXX: I don't know how to get this from an API
  const std::uint64_t NUM_MEMORY_CHANNELS = 6;

  static constexpr double CYCLES_PER_SEC = (2.5 * 1000 * 1000 * 1000);
  static constexpr double MB_IN_BYTES = (1 << 20);

  // TODO: get this from NUMA API
  uint32_t num_nodes;

  std::vector<PapiEvent *> imc_read;
  std::vector<PapiEvent *> imc_write;

  std::uint64_t read_bw;
  std::uint64_t write_bw;

  std::uint64_t start_ts;
  std::uint64_t stop_ts;

  MemoryBwCounters(std::uint64_t num_nodes) : num_nodes(num_nodes) {
    PLOGI.printf("Initializing memory bw counters");
    for (std::uint64_t i{}; i < num_nodes; i++) {
      PapiEvent *read_event = new PapiEvent(NUM_MEMORY_CHANNELS);
      read_event->init_event(i);
      read_event->add_event(cas_rd, imc_box);

      PapiEvent *write_event = new PapiEvent(NUM_MEMORY_CHANNELS);
      write_event->init_event(i);
      write_event->add_event(cas_wr, imc_box);

      imc_read.push_back(read_event);
      imc_write.push_back(write_event);
    }
  }

  void start() {
    for (auto &event : imc_read) {
      event->start();
    }
    for (auto &event : imc_write) {
      event->start();
    }
    start_ts = RDTSC_START();
    PLOGI.printf("Starting Mem bw counters");
  }

  void stop() {
    for (auto &event : imc_read) {
      auto counter = event->stop();
      read_bw += counter;
      PLOGI.printf("counter value %" PRIu64 " | read_bw %" PRIu64 "", counter, read_bw);
    }
    for (auto &event : imc_write) {
      write_bw += event->stop();
    }
    stop_ts = RDTSCP();
  }

  void compute_mem_bw() {
    double bw_duration = stop_ts - start_ts;
    double bw_duration_secs = bw_duration / CYCLES_PER_SEC;

    PLOGI.printf("BW duration %f (secs %f)", bw_duration, bw_duration_secs);
    PLOGI.printf("Total read BW %f MiB/s",
                 (read_bw * 64 / MB_IN_BYTES) / bw_duration_secs);
    PLOGI.printf("Total write BW %f MiB/s",
                 (write_bw * 64 / MB_IN_BYTES) / bw_duration_secs);
  }
};

}  // namespace kmercounter
