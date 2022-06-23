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
      defaultPackage = packages.kvstore;
      packages.kvstore = pkgs.callPackage ./build_package.nix {
        # override any parameters here
        cmakeFlags = [];
      };
      devShells.prod = pkgs.mkShell {
        inputsFrom = [
          packages.kvstore
        ];
        buildInputs = with pkgs; [
          msr-tools
        ];
        NIX_CFLAGS_COMPILE = "-march=native";
      };
      devShells.build = pkgs.mkShell {
        inputsFrom = [
          devShells.prod
        ];
        nativeBuildInputs = with pkgs; [ 
          gcc11
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
          clang-tools
          act

          # Python packages for evals plotting.
          python310
          python310Packages.numpy
          python310Packages.scipy
          python310Packages.matplotlib
        ];  
        NIX_CFLAGS_COMPILE = "-march=native";
      };
    }
  );
}
