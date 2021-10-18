let
  nixpkgs = import ./nixpkgs.nix;
  pkgs = import nixpkgs {
    overlays = [
    ];
  };
in pkgs.mkShell {
  buildInputs = with pkgs; [
    cmake
    ninja

    numactl
    zlib
    boost
    gtest

    msr-tools
    gdb
    linuxPackages.perf
    (pkgs.writeScriptBin "sperf" ''
      sudo ${linuxPackages.perf}/bin/perf "$@"
    '')
  ];
  nativeBuildInputs = with pkgs; [
    gcc11
  ];
}