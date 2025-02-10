#!/bin/bash

echo "Removing pacman password requirements..."

# Create sudoers directory if it doesn't exist
sudo mkdir -p /etc/sudoers.d

# Create pacman rule
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/pacman" | sudo tee /etc/sudoers.d/02-pacman-nopass

# Set correct permissions
sudo chmod 440 /etc/sudoers.d/02-pacman-nopass

echo "Done! Pacman now works without password prompts."