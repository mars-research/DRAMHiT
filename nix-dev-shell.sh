#!/bin/bash

# Step 1 & 2: Detect if Nix is installed, if not, install it
if ! command -v nix &> /dev/null; then
    echo "Nix is not detected. Installing Nix..."
    curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --no-daemon
else
    echo "Nix is already installed."
fi

# Step 3: Load the Nix environment script
# Using $HOME makes this script portable to other users/systems
NIX_ENV_SCRIPT="$HOME/.nix-profile/etc/profile.d/nix.sh"

if [ -f "$NIX_ENV_SCRIPT" ]; then
    echo "Loading Nix environment..."
    . "$NIX_ENV_SCRIPT"
elif [ -f "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh" ]; then
    # Fallback for multi-user installations just in case
    echo "Loading Nix multi-user environment..."
    . "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
else
    echo "Warning: Could not find the Nix environment script to source."
fi

# Step 4: Enter nix develop shell
echo "Entering Nix develop shell..."
nix develop --extra-experimental-features flakes --extra-experimental-features nix-command

