#!/bin/bash

echo "Setting up sane system defaults..."

# Detect desktop environment
if [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
    # KDE Settings
    echo "Configuring KDE..."
    
    # Disable file selection click policy
    kwriteconfig5 --file kdeglobals --group KDE --key SingleClick false
    
    # Enable auto-mount
    kwriteconfig5 --file kded5rc --group Module-device_automounter --key autoload true
    
    # Disable that annoying logout confirmation
    kwriteconfig5 --file ksmserverrc --group General --key confirmLogout false
    
    # Disable session restore
    kwriteconfig5 --file ksmserverrc --group General --key loginMode default
    
    # Speed up animations
    kwriteconfig5 --file kdeglobals --group KDE --key AnimationDurationFactor 0.5

elif [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
    # GNOME Settings
    echo "Configuring GNOME..."
    
    # Enable minimize/maximize buttons
    gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
    
    # Faster animations
    gsettings set org.gnome.desktop.interface enable-animations true
    gsettings set org.gnome.desktop.interface animation-speed 0.5
    
    # Show battery percentage
    gsettings set org.gnome.desktop.interface show-battery-percentage true
    
    # Enable auto-mount
    gsettings set org.gnome.desktop.media-handling automount true
    gsettings set org.gnome.desktop.media-handling automount-open true
fi

# Global Settings

# Set reasonable file associations
xdg-mime default org.kde.kate.desktop text/plain
xdg-mime default org.kde.kate.desktop text/x-python
xdg-mime default org.kde.kate.desktop text/x-c++src
xdg-mime default firefox.desktop x-scheme-handler/http
xdg-mime default firefox.desktop x-scheme-handler/https

# Create common directories
mkdir -p ~/Development ~/Downloads/temp

# Set up better bash history
echo '
# Better bash history
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth
shopt -s histappend' >> ~/.bashrc

# Set up better terminal colors
echo '
# Better colors
force_color_prompt=yes
PS1="\[\033[38;5;11m\]\u\[$(tput sgr0)\]\[\033[38;5;15m\]@\h:\[$(tput sgr0)\]\[\033[38;5;6m\]\w\\$\[$(tput sgr0)\] "' >> ~/.bashrc

# Better default umask for new files
echo "umask 022" >> ~/.profile

echo "Sane defaults have been configured!"