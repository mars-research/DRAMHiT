# This file contains all the packages for building the repo.
# Change flake.nix to modify the dev shell.

{
  srcPath ? ./.,
  lib,
  stdenv,
  cmakeFlags ? [],
  gcc11, cmake, ninja,
  abseil-cpp,
  numactl,
  zlib,
  boost,
  gtest,
  capstone,
}: let
  abseil-cpp-17 = abseil-cpp.override {
    cxxStandard = "17";
  };
in stdenv.mkDerivation {
  name = "dramhit";
  version = "0.1.0";

  inherit cmakeFlags;

  src = lib.cleanSourceWith {
    filter = name: type: !(type == "directory" && baseNameOf name == "build");
    src = lib.cleanSourceWith {
      filter = lib.cleanSourceFilter;
      src = srcPath;
    };
  };

  nativeBuildInputs = [ 
    gcc11
    cmake
    ninja
  ];

  buildInputs = [
    abseil-cpp-17
    numactl
    zlib
    boost
    gtest
    capstone
  ];

  NIX_CFLAGS_COMPILE = "-march=native";
  
  installPhase = ''
    mkdir -p $out/bin
    cp dramhit $out/bin/
    find unittests/ -executable -type f -exec cp {} $out/bin/ \;
  '';
}

