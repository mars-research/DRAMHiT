# Script to install and set up Intel VTune Profiler on Linux.
#
# Overview:
# - Adds Intel's APT repository for VTune installation.
# - Installs Intel VTune Profiler.
# - Builds and loads required sampling drivers for profiling.
#
# Notes:
# - Ensure the VTune version matches the version of your VTune GUI.
#   Use `apt-cache policy intel-oneapi-vtune` to find available versions.
# - Replace the group (`dramhit-PG0`) in the sampling driver setup with an appropriate group for your user.
#   Use `groups` to check your user's groups.
# To run:  sudo ./scripts/install_vtune.sh

#Installing vtune (https://www.intel.com/content/www/us/en/docs/vtune-profiler/installation-guide/2025-0/package-managers.html):
wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB

sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB

rm GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB

echo "deb https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list

sudo add-apt-repository "deb https://apt.repos.intel.com/oneapi all main"

sudo apt update

#   Download latest version:
#sudo apt install intel-oneapi-vtune

#   Or install other version since it must match your vtune gui version. Can check available versions with:
#apt-cache policy intel-oneapi-vtune
# My gui app is version 2025, so looked it up with:
# apt-cache policy intel-oneapi-vtune | grep 2025

# Jerry's install version
# sudo apt install -y intel-oneapi-vtune=2025.0.1-14

# Josh's install version
sudo apt install -y intel-oneapi-vtune=2025.0.0-1129

#   Installs in dir:
#/opt/intel/oneapi/vtune/latest/bin64/vtune

#   Install the sampling drivers that came with vtune install (https://www.intel.com/content/www/us/en/docs/vtune-profiler/user-guide/2025-0/build-install-sampling-drivers-for-linux-targets.html):
# Note: group name may vary
cd /opt/mnt/intel/oneapi/vtune/latest/sepdk/src
sudo ./build-driver -ni
groups
sudo ./insmod-sep -r -g redshift-PG0
./insmod-sep -q

#Now to use inside the vtune gui application click the ssh option and fill out your info:
# Example:
#   SSH Destination: 
# USER@clnode199.clemson.cloudlab.us

#   VTune Profiler installation directory:  
# /opt/intel/oneapi/vtune/latest/


#   REMOVING Install
# sudo apt-get remove --purge intel-oneapi-vtune

## Installing from vtune-gui (note it doesn't include event markers library):
#   After 'deploying' from app, install drivers:
#    cd /tmp/vtune_profiler_2025.0.0.629072/sepdk/src
#    sudo ./build-driver 
#    ./insmod-sep -q
#    groups
#    sudo ./insmod-sep -r -g dramhit-PG0
#    ./insmod-sep -q
# go back to home directory...

