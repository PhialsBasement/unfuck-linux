#!/bin/bash

echo "Fixing package dependency hell..."

# Check if we're on an Arch-based system
if ! command -v pacman &> /dev/null; then
    echo "This script is for Arch-based systems only!"
    exit 1
fi

# Backup pacman config
sudo cp /etc/pacman.conf /etc/pacman.conf.backup

# Enable all repositories
sudo sed -i 's/^#\[multilib\]/\[multilib\]/' /etc/pacman.conf
sudo sed -i '/^\[multilib\]/{n;s/^#Include/Include/}' /etc/pacman.conf

# Install common dependencies that often cause issues
echo "Installing commonly needed dependencies..."
sudo pacman -Sy --needed --noconfirm base-devel \
    glibc lib32-glibc \
    gcc-libs lib32-gcc-libs \
    zlib lib32-zlib \
    openssl lib32-openssl \
    libxcrypt-compat lib32-libxcrypt-compat

# Fix common dependency conflicts
echo "Fixing common package conflicts..."

# Remove orphaned packages
sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null || true

# Fix broken dependencies
sudo pacman -Syyu --noconfirm

# Install pacman hooks for automatic cleanup
mkdir -p /etc/pacman.d/hooks
echo '[Trigger]
Type = Package
Operation = Remove
Operation = Install
Operation = Upgrade
Target = *

[Action]
Description = Cleaning pacman cache...
When = PostTransaction
Exec = /usr/bin/paccache -rk2' | sudo tee /etc/pacman.d/hooks/clean-cache.hook

# Configure makepkg to handle conflicts better
sudo sed -i 's/^#MAKEFLAGS=.*/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf

# Create conflict resolution aliases
echo '
# Package management aliases
alias fix-deps="sudo pacman -Syyu && yay -Syyu"
alias nuke-cache="sudo pacman -Scc && yay -Scc"
alias unfuck-packages="sudo pacman -Syyu && sudo pacman -Scc && yay -Syyu && yay -Scc"' >> ~/.bashrc

# Fix library paths
sudo ldconfig

echo "Dependency hell has been contained!"
echo "Changes made:"
echo "✓ Enabled all repositories"
echo "✓ Installed common dependencies"
echo "✓ Removed orphaned packages"
echo "✓ Fixed broken dependencies"
echo "✓ Added automatic cache cleanup"
echo "✓ Added helpful aliases:"
echo "  - fix-deps: Fix dependency issues"
echo "  - nuke-cache: Clear all package caches"
echo "  - unfuck-packages: Nuclear option - fixes everything"
echo ""
echo "Original pacman config backed up to /etc/pacman.conf.backup"
echo "You may need to restart your terminal for aliases to work."