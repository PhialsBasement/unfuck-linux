#!/bin/bash

echo "Making pacman actually usable..."

# Check if we're on an Arch-based system
if ! command -v pacman &> /dev/null; then
    echo "This script is for Arch-based systems only!"
    exit 1
fi

# Backup original config
sudo cp /etc/pacman.conf /etc/pacman.conf.backup

# Enable parallel downloads
sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 16/' /etc/pacman.conf

# Enable faster compression for packages
sudo sed -i 's/PKGEXT=.pkg.tar.zst/PKGEXT=.pkg.tar/' /etc/makepkg.conf
sudo sed -i 's/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -z - --threads=0)/' /etc/makepkg.conf

# Enable all mirrors
sudo sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist

# Install reflector if not present
if ! command -v reflector &> /dev/null; then
    sudo pacman -Sy --noconfirm reflector
fi

# Update mirrorlist with fastest mirrors
echo "Finding fastest mirrors..."
sudo reflector --latest 20 \
               --sort rate \
               --protocol https \
               --save /etc/pacman.d/mirrorlist

# Enable multilib for 32-bit support
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" | sudo tee -a /etc/pacman.conf
fi

# Disable signature checking for packages (optional, commented out by default)
# sudo sed -i 's/^SigLevel.*/SigLevel = Never/' /etc/pacman.conf

# Clear package cache except for the latest version
sudo paccache -r

# Update package databases
sudo pacman -Sy

echo "Pacman has been optimized for speed!"
echo "Changes made:"
echo "✓ Enabled parallel downloads (16 concurrent)"
echo "✓ Optimized package compression"
echo "✓ Updated to fastest mirrors"
echo "✓ Enabled multilib repository"
echo "✓ Cleaned package cache"
echo ""
echo "Original config backed up to /etc/pacman.conf.backup"