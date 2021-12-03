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
    abseil-cpp-17 = pkgs.abseil-cpp.override {
      cxxStandard = "17";
    };
    in rec {
      devShells.prod = pkgs.mkShell {
        buildInputs = with pkgs; [
          msr-tools
        ];
        propagatedBuildInputs = with pkgs; [
          abseil-cpp-17
          boost
          numactl
          zlib
          gtest
        ];
        NIX_CFLAGS_COMPILE = "-march=native";
      };
      devShells.build = pkgs.mkShell {
        inputsFrom = [
          devShells.prod
        ];
        buildInputs = with pkgs; [
          cmake
          ninja
        ];  
        NIX_CFLAGS_COMPILE = "-march=native";
      };
      devShell = pkgs.mkShell {
        inputsFrom = [
          devShells.build
        ];
        buildInputs = with pkgs; [
          gdb
          linuxPackages.perf
        ];  
        NIX_CFLAGS_COMPILE = "-march=native";
      };
    }
  );
}
