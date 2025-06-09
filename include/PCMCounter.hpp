#pragma once

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

  void print(SystemCounterState) {}

  void readout(bool cores, bool sockets, bool system) {
    int i = 0;

    if (cores) {
      for (i = 0; i < pcm->getNumCores(); ++i) {
        std::cout << "Core: " << i << "\n"
                  << " Memory bandwidth: "
                  << getLocalMemoryBW(cstates1[i], cstates2[i]) << "\n"
                  << " IPC " << getCoreIPC(cstates1[i], cstates2[i]) << "\n"
                  << " Ref cycle " << getRefCycles(cstates1[i], cstates2[i])
                  << "\n"
                  << " Retired instructions "
                  << getInstructionsRetired(cstates1[i], cstates2[i]) << "\n"
                  << " L2 miss " << getL2CacheMisses(cstates1[i], cstates2[i])
                  << "\n"
                  << " L2 hit " << getL2CacheHits(cstates1[i], cstates2[i])
                  << "\n"
                  << " Frontend bound "
                  << getFrontendBound(cstates1[i], cstates2[i]) << "\n"
                  << " Backend bound "
                  << getBackendBound(cstates1[i], cstates2[i]) << "\n"
                  << " Memory bound "
                  << getMemoryBound(cstates1[i], cstates2[i]) << "\n"
                  << " Branch mispredict bound "
                  << getBranchMispredictionBound(cstates1[i], cstates2[i])
                  << "\n";
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
      std::cout << "System "
                   " IPC "
                << getCoreIPC(sstate1, sstate2) << "\n"
                << " Ref cycles " << getRefCycles(sstate1, sstate2) << "\n"
                << " TSC " << getInvariantTSC(sstate1, sstate2) << "\n"
                << " Retired " << getInstructionsRetired(sstate1, sstate2)
                << "\n"
                << " L2 miss " << getL2CacheMisses(sstate1, sstate2) << "\n"
                << " L2 hit " << getL2CacheHits(sstate1, sstate2) << "\n"
                << " Frontend bound " << getFrontendBound(sstate1, sstate2)
                << "\n"
                << " Backend bound " << getBackendBound(sstate1, sstate2)
                << "\n"
                << " Memory bound " << getMemoryBound(sstate1, sstate2) << "\n"
                << " Branch mispredict bound "
                << getBranchMispredictionBound(sstate1, sstate2) << "\n";
    }
  }
};

}  // namespace pcm
