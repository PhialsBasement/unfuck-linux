#!/bin/bash

echo "Fixing wallpaper permissions because apparently that's a security risk now..."

# Common wallpaper directories
WALLPAPER_DIRS=(
    "/usr/share/backgrounds"
    "/usr/share/wallpapers"
    "$HOME/.local/share/backgrounds"
    "$HOME/.local/share/wallpapers"
)

for dir in "${WALLPAPER_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "Fixing permissions for $dir"
        sudo chmod -R 755 "$dir"
        sudo chown -R $USER:$USER "$HOME/.local/share/backgrounds" 2>/dev/null
        sudo chown -R $USER:$USER "$HOME/.local/share/wallpapers" 2>/dev/null
    fi
done

# Fix KDE wallpaper settings if present
if command -v kwriteconfig5 &> /dev/null; then
    kwriteconfig5 --file plasma-org.kde.plasma.desktop-appletsrc --group Containments --group wallpaper --key "userswallpapers" ""
fi

# Fix GNOME wallpaper settings if present
if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.background picture-options 'zoom'
    gsettings reset org.gnome.desktop.background picture-uri
fi

echo "Wallpaper permissions fixed. You can now change your background without a PhD in cybersecurity!"