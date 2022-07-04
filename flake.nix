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
    stdenv = pkgs.gcc12.stdenv;
    mkShell = pkgs.mkShell.override {
      inherit stdenv;
    };
    gtest = pkgs.callPackage ./lib/gtest {};
    in rec {
      defaultPackage = packages.kvstore;
      packages.kvstore = pkgs.callPackage ./build_package.nix {
        # override any parameters here
        inherit stdenv gtest;
        cmakeFlags = [];
      };
      devShells.prod = mkShell {
        inputsFrom = [
          packages.kvstore
        ];
        buildInputs = with pkgs; [
          msr-tools
        ];
        NIX_CFLAGS_COMPILE = "-march=native";
      };
      devShells.build = mkShell {
        inputsFrom = [
          devShells.prod
        ];
        nativeBuildInputs = with pkgs; [ 
          clang_14
          llvmPackages_14.libllvm
          gcc11
        ];
        buildInputs = with pkgs; [
          cmake
          ninja
        ];  
        NIX_CFLAGS_COMPILE = "-march=native";
      };
      devShell = mkShell {
        inputsFrom = [
          devShells.build
        ];
        buildInputs = with pkgs; [
          act
          clang-tools
          gdb
          linuxPackages.perf

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
