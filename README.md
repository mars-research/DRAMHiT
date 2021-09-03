## Build

<!--TODO: @David expand on this readme-->

- Make sure submodules have been cloned
- Follow instruction in papi/INSTALL.txt to install a copy of papi (including shared library), if PAPI will be enabled later
- Project builds with cmake
    - Common options:
        - VTUNE (ON/OFF)
        - BQUEUE (ON/OFF)
        - PAPI (ON/OFF)
        - BRANCH ("" / simd / cmov)
