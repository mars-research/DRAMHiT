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
      defaultPackage = packages.dramhit;
      packages.dramhit = pkgs.callPackage ./build_package.nix {
        # override any parameters here
        inherit stdenv gtest;
        cmakeFlags = [];
      };
      devShells.prod = mkShell {
        inputsFrom = [
          packages.dramhit
        ];
        buildInputs = with pkgs; [
          msr-tools
        ];
        NIX_CFLAGS_COMPILE = "-march=native";
        NIX_ENFORCE_NO_NATIVE=0;
      };
      devShells.build = mkShell {
        inputsFrom = [
          devShells.prod
        ];
        nativeBuildInputs = with pkgs; [ 
          clang_14
          llvmPackages_14.libllvm
          gcc11
          pkg-config
        ];
        buildInputs = with pkgs; [
          openssl
          cmake
          ninja
        ];  
        NIX_CFLAGS_COMPILE = "-march=native";
        NIX_ENFORCE_NO_NATIVE=0;
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
          bc  
          ripgrep
          # Python packages for evals plotting.
          python310
          python310Packages.numpy
          python310Packages.scipy
          python310Packages.matplotlib
        ];  
        NIX_CFLAGS_COMPILE = "-march=native";
        NIX_ENFORCE_NO_NATIVE=0;
      };
    }
  );
}
