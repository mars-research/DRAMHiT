{ lib, stdenv, cmake, ninja, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "gtest";
  version = "1.12.0";

  outputs = [ "out" "dev" ];

  src = fetchFromGitHub {
    owner = "google";
    repo = "googletest";
    rev = "release-${version}";
    hash = "sha256-gDZnsktnZPF+6W+Hb2JHnyd4PoI65CyMTVSlIEAFVaE=";
  };

  patches = [
    ./fix-cmake-config-includedir.patch
  ];

  nativeBuildInputs = [ cmake ninja ];

  cmakeFlags = [ "-DBUILD_SHARED_LIBS=ON" ];

  meta = with lib; {
    description = "Google's framework for writing C++ tests";
    homepage = "https://github.com/google/googletest";
    license = licenses.bsd3;
    platforms = platforms.all;
    maintainers = with maintainers; [ ivan-tkatchev ];
  };
}