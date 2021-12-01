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
    libarchive
  ];

  buildInputs = with pkgs; [
    numactl
    zlib
    boost
    gtest
  ];
  
  installPhase = ''
    mkdir -p $out/bin
    cp kvstore $out/bin/
    cp auto-tests/test_runner $out/bin/kvstore_test
  '';
}

