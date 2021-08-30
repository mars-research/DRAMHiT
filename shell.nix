let
  nixpkgs = builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/f641b66ceb34664f4b92d688916472f843921fd3.tar.gz";
    sha256 = "1hglx3c5qbng9j6bcrb5c2wip2c0qxdylbqm4iz23b2s7h787qsk";
  };
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

    gdb
    linuxPackages.perf
    (pkgs.writeScriptBin "sperf" ''
      sudo ${linuxPackages.perf}/bin/perf "$@"
    '')
  ];
  nativeBuildInputs = with pkgs; [
    gcc11
    pkg-config 
  ];
}