
USER=$(logname)
HOME_DIR=$(getent passwd "$USER" | cut -d: -f6)
sudo apt update
sudo apt install -y direnv
mkdir -p "$HOME_DIR/.config/nix"
echo "experimental-features = nix-command flakes" >"$HOME_DIR/.config/nix/nix.conf"
echo 'eval "$(direnv hook bash)"' >>"$HOME_DIR/.bashrc"


