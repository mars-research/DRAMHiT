#pragma once

#include <fcntl.h>
#include <plog/Log.h>
#include <unistd.h>

#include <iostream>
#include <map>
#include <set>
#include <thread>
#include <tuple>
#include <vector>

class MsrHandler {
 public:
  MsrHandler() {}

  ~MsrHandler() {}

  void msr_close() {
    if (this->msr_safe_loaded) {
      for (const auto& [cpu, fd] : this->dev_msr_fds) {
        close(fd);
      }
    }
  }

  void msr_open() {
    auto nr_cpus = std::thread::hardware_concurrency();

    for (auto cpu = 0u; cpu < nr_cpus; cpu++) {
      std::string file = "/dev/cpu/" + std::to_string(cpu) + "/msr_safe";
      int fd = open(file.c_str(), O_RDWR);
      if (fd < 0) {
        PLOG_VERBOSE.printf("opening %s failed with %d", file.c_str(), errno);
        this->msr_safe_loaded = false;
      } else {
        dev_msr_fds.insert({cpu, fd});
        this->msr_safe_loaded = true;
      }
    }
    if (!this->msr_safe_loaded) {
      PLOG_ERROR.printf(
          "Could not open /dev/cpu/*/msr_safe! msr-safe not loaded?");
    } else {
      PLOG_INFO.printf("msr-safe loaded!");
    }
  }

  std::set<uint64_t> read_msr(uint64_t msr) {
    auto nr_cpus = std::thread::hardware_concurrency();
    std::set<uint64_t> rdmsr_set;
    if (!msr_safe_loaded) {
      goto skip;
    }

    for (auto cpu = 0u; cpu < nr_cpus; cpu++) {
      uint64_t val = 0;
      int ret = read_msr_on_cpu(msr, cpu, &val);
      if (ret > 0) {
        rdmsr_set.insert(val);
      }
    }
  skip:
    return rdmsr_set;
  }

  int read_msr_on_cpu(uint64_t msr, uint32_t cpu, uint64_t* val) {
    auto msr_cpu = dev_msr_fds[cpu];
    int ret = pread(msr_cpu, val, sizeof(*val), msr);
    if (ret != sizeof(val)) {
      PLOG_ERROR.printf("pread failed with errno %d", errno);
    }
    PLOG_VERBOSE.printf("rdmsr %lx on cpu %u = %lx", msr, cpu, val);
    return ret;
  }

  void write_msr(uint64_t msr, uint64_t val) {
    auto nr_cpus = std::thread::hardware_concurrency();
    if (!msr_safe_loaded) {
      return;
    }

    for (auto cpu = 0u; cpu < nr_cpus; cpu++) {
      write_msr_on_cpu(msr, cpu, val);
    }
  }

  int write_msr_on_cpu(uint64_t msr, uint32_t cpu, uint64_t val) {
    auto msr_cpu = dev_msr_fds[cpu];
    int ret = pwrite(msr_cpu, &val, sizeof(val), msr);
    if (ret != sizeof(val)) {
      PLOG_ERROR.printf("pwrite failed with errno %d", errno);
    }
    // PLOG_INFO.printf("wrmsr %lx on cpu %u = %lx", msr, cpu, val);
    return ret;
  }

 private:
  std::map<int, int> dev_msr_fds;
  bool msr_safe_loaded;
};
