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
  PCMCounters() {
    pcm = pcm::PCM::getInstance();

    int error = pcm->program();

    if(error == PCM::ErrorCode::PMUBusy)
    {
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
  ~PCMCounters() { pcm->cleanup(); }

  // save all start state
  void start() {
    sstate1 = getSystemCounterState();
    int i = 0;
    for (i = 0; i < pcm->getNumSockets(); ++i)
      sktstates1[i] = getSocketCounterState(i);
    for (i = 0; i < pcm->getNumCores(); ++i)
      cstates1[i] = getCoreCounterState(i);

    cycles = RDTSCP(); 
    
  }

  // save all end state
  void stop() {

    cycles = RDTSCP() - cycles; 

    sstate2 = getSystemCounterState();
    int i = 0;
    for (i = 0; i < pcm->getNumSockets(); ++i)
      sktstates2[i] = getSocketCounterState(i);
    for (i = 0; i < pcm->getNumCores(); ++i)
      cstates2[i] = getCoreCounterState(i);
  }



  template <class CounterStateType>
  inline void print_tma(std::string header,const CounterStateType & before, const CounterStateType & after) 
  {
      std::cout << header << "\n"
                << " IPC "<< getCoreIPC(before, after) << "\n"
                << " Ref cycles " << getRefCycles(before, after) << "\n"
                << " TSC " << getInvariantTSC(before, after) << "\n"
                << " Retired " << getInstructionsRetired(before, after) << "\n"
                << " L2 miss " << getL2CacheMisses(before, after) << "\n"
                << " L2 hit " << getL2CacheHits(before, after) << "\n"
                << "\n <<<<< TMA view with Pipeline slot >>>>> \n" 
                << " Retiring " << getRetiring(before, after) << "\n"
                << " Frontend bound " << getFrontendBound(before, after) << "\n"
                << " Backend bound " << getBackendBound(before, after) << "\n"
                << " ------> Memory bound " << getMemoryBound(before, after) << "\n"
                << " ------> Core bound " << getCoreBound(before, after) << "\n"
                << " Bad speculation bound " << getBadSpeculation(before, after) << "\n"
                << " ------> Branch mispredict bound " << getBranchMispredictionBound(before, after) << "\n"
                << " ------> Machine clears bound " << getMachineClearsBound(before, after) << "\n";
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
