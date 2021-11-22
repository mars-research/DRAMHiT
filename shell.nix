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

    msr-tools
    gdb
    linuxPackages.perf
    (pkgs.writeScriptBin "sperf" ''
      sudo ${linuxPackages.perf}/bin/perf "$@"
    '')
  ];
  propagatedBuildInputs = with pkgs; [
    boost
    numactl
    zlib
    gtest
  ];
  nativeBuildInputs = with pkgs; [
    gcc11
  ];
  NIX_CFLAGS_COMPILE = "-march=native";
}
