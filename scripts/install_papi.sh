#!/usr/bin/env bash
set -euo pipefail

PROJ_ROOT=$(pwd)

PAPI_SRC_DIR=./papi/src


install_papi() {
  if [ ! -d ${PAP_SRC_DIR} ]; then
    echo "Could not locate sources for PAPI dir. Are you running this script from project root?"
    exit;
  fi

  pushd ${PAPI_SRC_DIR}
  ./configure --prefix=$PWD/install
  make -j && make install
  popd

  echo "********   Add this to your bashrc   ********************"
  echo "# Add the LIB dir to PATH";
  echo "export PAPI_DIR=${PWD}/install"
  echo "export PATH=\${PAPI_DIR}/bin:\$PATH"
  echo "export LD_LIBRARY_PATH=\${PAPI_DIR}/lib:\$LD_LIBRARY_PATH"
  echo "*********************************************************"
}

check_papi() {
  if [ ! -d ${PROJ_ROOT}/${PAPI_SRC_DIR} ]; then
    git submodule init && git submodule update
  fi
}

check_papi;
install_papi;
