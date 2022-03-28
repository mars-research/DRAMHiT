let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  lockedPkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/${lock.nodes.nixpkgs.locked.rev}.tar.gz";
    sha256 = lock.nodes.nixpkgs.locked.narHash;
  }) {};
in {
  pkgs ? lockedPkgs,
  cmakeFlags ? [],
}: let
  lib = pkgs.lib;
  stdenv = pkgs.stdenv;
  abseil-cpp-17 = pkgs.abseil-cpp.override {
    cxxStandard = "17";
  };
in stdenv.mkDerivation {
  name = "kvstore";
  version = "0.1.0";

  inherit cmakeFlags;

  src = lib.cleanSourceWith {
    filter = name: type: !(type == "directory" && baseNameOf name == "build");
    src = lib.cleanSourceWith {
      filter = lib.cleanSourceFilter;
      src = ./.;
    };
  };

  nativeBuildInputs = with pkgs; [
    cmake
    ninja
    python310
  ];

  buildInputs = with pkgs; [
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
    cp kvstore $out/bin/
    find auto-tests/ -executable -type f -exec cp {} $out/bin/ \;
  '';
}

