#!/bin/bash

# Windows-like Experience Setup Script
# Part of the unfuck-linux project

set -e

echo "Setting up Windows-like experience..."

# Install core Windows-equivalent applications
pacman -S --needed --noconfirm \
    libreoffice-fresh \
    vlc \
    firefox \
    thunderbird \
    gimp \
    steam \
    lutris \
    wine \
    winetricks \
    gamemode \
    obs-studio \
    qbittorrent

# Install Microsoft compatibility
pacman -S --needed --noconfirm \
    ttf-ms-fonts \
    ttf-vista-fonts \
    wine-mono \
    wine-gecko \
    samba \
    gvfs-smb

# Install multimedia support
pacman -S --needed --noconfirm \
    gst-plugins-base \
    gst-plugins-good \
    gst-plugins-bad \
    gst-plugins-ugly \
    gst-libav \
    ffmpeg \
    ffmpegthumbnailer

# Install gaming support
pacman -S --needed --noconfirm \
    nvidia-dkms \
    nvidia-utils \
    nvidia-settings \
    lib32-nvidia-utils \
    vulkan-icd-loader \
    lib32-vulkan-icd-loader \
    steam-native-runtime

# Configure KDE for Windows-like experience
echo "Configuring KDE for Windows-like experience..."

# Windows-like desktop behavior
kwriteconfig5 --file ~/.config/kwinrc --group Windows --key Placement "Smart"
kwriteconfig5 --file ~/.config/kdeglobals --group KDE --key SingleClick false
kwriteconfig5 --file ~/.config/kdeglobals --group General --key fixed "Segoe UI,10,-1,5,50,0,0,0,0,0"

# Windows-like keyboard shortcuts
kwriteconfig5 --file ~/.config/kglobalshortcutsrc --group kwin --key "Switch to Desktop 1" "Meta+1,none,none"
kwriteconfig5 --file ~/.config/kglobalshortcutsrc --group kwin --key "Switch to Desktop 2" "Meta+2,none,none"
kwriteconfig5 --file ~/.config/kglobalshortcutsrc --group kwin --key "Show Desktop" "Meta+D,none,none"

# Configure taskbar
kwriteconfig5 --file ~/.config/plasma-org.kde.plasma.desktop-appletsrc --group Containments --group 1 --group General --key location "bottom"

# Set up automatic updates
systemctl enable --now pamac-daemon.service
pamac-manager --enable-aur
pamac-manager --enable-snap
pamac-manager --enable-flatpak

# Configure GRUB for fast boot
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i 's/GRUB_TIMEOUT_STYLE=menu/GRUB_TIMEOUT_STYLE=hidden/' /etc/default/grub
update-grub

# Enable gaming services
systemctl enable --now nvidia-suspend.service
systemctl enable --now nvidia-hibernate.service
systemctl enable --now nvidia-resume.service

# Configure Windows-like power management
echo "Configuring power management..."
sed -i 's/HandleLidSwitch=suspend/HandleLidSwitch=ignore/' /etc/systemd/logind.conf
systemctl restart systemd-logind

# Enable printer support
systemctl enable --now cups.service
pacman -S --needed --noconfirm \
    cups-pdf \
    system-config-printer

# Set up Windows-like file associations
xdg-mime default org.kde.dolphin.desktop inode/directory
xdg-mime default org.kde.kate.desktop text/plain
xdg-mime default org.kde.gwenview.desktop image/jpeg image/png image/gif

echo "Windows-like experience setup complete!"
