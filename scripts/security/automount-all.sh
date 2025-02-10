#!/bin/bash

echo "Setting up automatic mounting for all drives..."

# Back up original configs
sudo cp /etc/fstab /etc/fstab.backup 2>/dev/null
sudo cp /etc/udisks2/mount_options.conf /etc/udisks2/mount_options.conf.backup 2>/dev/null

# Create udisks2 config directory if it doesn't exist
sudo mkdir -p /etc/udisks2

# Configure udisks2 to automount with sensible permissions
echo '[defaults]
auth_no_user_interaction=true
mount_options=nosuid,nodev,nofail,x-gvfs-show,rw
' | sudo tee /etc/udisks2/mount_options.conf

# Install required packages
sudo pacman -S --needed --noconfirm udisks2 udiskie ntfs-3g

# Enable automounting in desktop environments
if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
    # KDE Settings
    kwriteconfig5 --file kded5rc --group Module-device_automounter --key autoload true
    kwriteconfig5 --file kded5rc --group Module-device_automounter --key mount_on_startup true
    kwriteconfig5 --file kded5rc --group Module-device_automounter --key mount_on_plugin true
elif [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
    # GNOME Settings
    gsettings set org.gnome.desktop.media-handling automount true
    gsettings set org.gnome.desktop.media-handling automount-open true
fi

# Set up udiskie to auto-start
mkdir -p ~/.config/autostart
echo '[Desktop Entry]
Type=Application
Name=Udiskie
Comment=Automounter for removable media
Exec=udiskie -ANt
Terminal=false
Categories=System;
X-GNOME-Autostart-enabled=true' > ~/.config/autostart/udiskie.desktop

# Add user to necessary groups
sudo usermod -aG storage,optical $USER

# Configure systemd to handle USB automounting
echo '[Unit]
Description=Mount USB drives

[Mount]
What=%f
Where=%i
Type=auto
Options=defaults,nofail,x-systemd.device-timeout=1ms

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/usb-mount@.service

# Enable udiskie service for current user
systemctl --user enable udiskie
systemctl --user start udiskie

# Add convenient aliases for mounting
echo '
# Mount aliases
alias mount-all="udiskie-mount -a"
alias unmount-all="udiskie-umount -a"' >> ~/.bashrc

echo "Automounting has been enabled!"
echo "Changes made:"
echo "✓ Configured udisks2 for automatic mounting"
echo "✓ Installed necessary automounting tools"
echo "✓ Set up desktop environment automounting"
echo "✓ Added automounting service"
echo "✓ Added convenient aliases:"
echo "  - mount-all: Mount all available drives"
echo "  - unmount-all: Safely unmount all drives"
echo ""
echo "Original configs backed up with .backup extension"
echo "You may need to log out and back in for all changes to take effect."