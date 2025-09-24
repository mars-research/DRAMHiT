#sudo rm -rf /etc/profile.d/nix.sh.backup-before-nix /etc/zshrc.backup-before-nix /etc/bashrc.backup-before-nix /etc/zsh/zshrc.backup-before-nix /etc/bash.bashrc.backup-before-nix
#yes | sh <(curl -L https://nixos.org/nix/install) --daemon
sudo apt remove intel-oneapi-vtune

# sudo apt remove intel-oneapi-vtune
# gcc -O1 -pthread -lnuma -march=native -o numa_test numa_test.c -I/opt/intel/oneapi/vtune/latest/include /opt/intel/oneapi/vtune/latest/lib64/libittnotify.a