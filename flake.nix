{
  description = "Kmer counter";

  inputs = {
    mars-std.url = "github:mars-research/mars-std";
  };

  outputs = { self, mars-std, ... }: let
  # System types to support.
  supportedSystems = [ "x86_64-linux" ];

  in mars-std.lib.eachSystem supportedSystems (system: let
    pkgs = mars-std.legacyPackages.${system};
    in {
      devShell = pkgs.mkShell {
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
      };
    }
  );
}
