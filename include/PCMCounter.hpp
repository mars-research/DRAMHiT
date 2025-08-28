#pragma once

#include <string>

#include "cpucounters.h"
namespace pcm {
class PCMCounters {
 public:
  static constexpr double GB_IN_BYTES = (1 << 30);
  CoreCounterState *cstates1;
  CoreCounterState *cstates2;
  SocketCounterState *sktstates1;
  SocketCounterState *sktstates2;
  SystemCounterState sstate1;
  SystemCounterState sstate2;
  PCM *pcm;

  uint64_t cycles;
  

  // init pcm
  PCMCounters() {}

  void clean() { pcm->cleanup(); }

  void init() {
    pcm = pcm::PCM::getInstance();

    int error = pcm->program();

    if (error == PCM::ErrorCode::PMUBusy) {
      pcm->resetPMU();
      error = pcm->program();
    }

    if (error != pcm::PCM::Success) {
      printf("Failed to program pcm\n");
      pcm->cleanup();
      exit(-1);
    }

    cstates1 = new CoreCounterState[pcm->getNumCores()];
    cstates2 = new CoreCounterState[pcm->getNumCores()];
    sktstates1 = new SocketCounterState[pcm->getNumSockets()];
    sktstates2 = new SocketCounterState[pcm->getNumSockets()];
  }

  // clean up
  //~PCMCounters() {  }

  // save all start state
  void start() {
    sstate1 = getSystemCounterState();
    int i = 0;
    for (i = 0; i < pcm->getNumSockets(); ++i)
      sktstates1[i] = getSocketCounterState(i);
    for (i = 0; i < pcm->getNumCores(); ++i)
      cstates1[i] = getCoreCounterState(i);

    cycles = RDTSC_START();
  }

    // save all end state
  void stop() {
    cycles = RDTSC_START() - cycles;

    sstate2 = getSystemCounterState();
    int i = 0;
    for (i = 0; i < pcm->getNumSockets(); ++i)
      sktstates2[i] = getSocketCounterState(i);
    for (i = 0; i < pcm->getNumCores(); ++i)
      cstates2[i] = getCoreCounterState(i);
  }


  void start_socket() {
    int i = 0;
    for (i = 0; i < pcm->getNumSockets(); ++i)
      sktstates1[i] = getSocketCounterState(i);
  }

  void stop_socket() {

    int i = 0;
    for (i = 0; i < pcm->getNumSockets(); ++i)
      sktstates2[i] = getSocketCounterState(i);
  }

  double calculate_bw_gbs(double bytes,double sec) {
    return (bytes / GB_IN_BYTES) / sec;
  }

  double get_bw(uint64_t duration) 
  {
    double freq;
    double sec;
    uint64_t rbytes = 0;
    uint64_t wbytes = 0;
    uint64_t trbytes = 0;
    uint64_t twbytes = 0;
    for (int i = 0; i < pcm->getNumSockets(); ++i) {
      freq = getAverageFrequency(sktstates1[i], sktstates2[i]);
      sec = duration / freq;
      rbytes = getBytesReadFromMC(sktstates1[i], sktstates2[i]);
      wbytes = getBytesWrittenToMC(sktstates1[i], sktstates2[i]);
      trbytes += rbytes;
      twbytes += wbytes;
    }
    return calculate_bw_gbs(twbytes+trbytes, sec); 
  }


  void print_bw(uint64_t duration) {
    double freq;
    double sec;
    uint64_t rbytes = 0;
    uint64_t wbytes = 0;
    uint64_t trbytes = 0;
    uint64_t twbytes = 0;
    for (int i = 0; i < pcm->getNumSockets(); ++i) {
      freq = getAverageFrequency(sktstates1[i], sktstates2[i]);
      sec = duration / freq;
      rbytes = getBytesReadFromMC(sktstates1[i], sktstates2[i]);
      wbytes = getBytesWrittenToMC(sktstates1[i], sktstates2[i]);
      trbytes += rbytes;
      twbytes += wbytes;
      printf("MC %d, write bw: %.3f, read bw: %.3f\n", i,
             calculate_bw_gbs(wbytes, sec), calculate_bw_gbs(rbytes, sec),
             rbytes, wbytes, sec);
    }
    printf("{write_bw: %.3f, read_bw: %.3f}\n",
           calculate_bw_gbs(twbytes, sec), calculate_bw_gbs(trbytes, sec));

  }

  template <class CounterStateType>
  inline void print_tma(std::string header, const CounterStateType &before,
                        const CounterStateType &after) {
    std::cout << header << "\n"
              << " IPC " << getCoreIPC(before, after) << "\n"
              << " Ref cycles " << getRefCycles(before, after) << "\n"
              << " TSC " << getInvariantTSC(before, after) << "\n"
              << " Retired " << getInstructionsRetired(before, after) << "\n"
              << " L2 miss " << getL2CacheMisses(before, after) << "\n"
              << " L2 hit " << getL2CacheHits(before, after) << "\n"
              << "\n <<<<< TMA view with Pipeline slot >>>>> \n"
              << " Retiring " << getRetiring(before, after) << "\n"
              << " Frontend bound " << getFrontendBound(before, after) << "\n"
              << " Backend bound " << getBackendBound(before, after) << "\n"
              << " ------> Memory bound " << getMemoryBound(before, after)
              << "\n"
              << " ------> Core bound " << getCoreBound(before, after) << "\n"
              << " Bad speculation bound " << getBadSpeculation(before, after)
              << "\n"
              << " ------> Branch mispredict bound "
              << getBranchMispredictionBound(before, after) << "\n"
              << " ------> Machine clears bound "
              << getMachineClearsBound(before, after) << "\n";
  }

  void readout(bool cores, bool sockets, bool system) {
    int i = 0;

    std::cout << "Cycles: " << this->cycles << std::endl;

    if (cores) {
      for (i = 0; i < pcm->getNumCores(); ++i) {
        print_tma("Core ", cstates1[1], cstates2[i]);
      }
    }

    if (sockets) {
      for (i = 0; i < pcm->getNumSockets(); ++i) {
        double freq = getAverageFrequency(sktstates1[i], sktstates2[i]);
        double sec = cycles / freq;
        std::cout << " MC SOCKET " << i << "\n"
                  << " Read  "
                  << getBytesReadFromMC(sktstates1[i], sktstates2[i]) /
                         double(1024ULL * 1024ULL * 1024ULL) / sec
                  << "GB/s \n"
                     " Write "
                  << getBytesWrittenToMC(sktstates1[i], sktstates2[i]) /
                         double(1024ULL * 1024ULL * 1024ULL) / sec
                  << "GB/s \n";
      }
    }

    if (system) {
      print_tma("System ", sstate1, sstate2);
    }
  }
};

}  // namespace pcm
