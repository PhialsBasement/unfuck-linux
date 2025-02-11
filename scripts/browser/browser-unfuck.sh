#!/bin/bash

echo "Making browsers stop treating you like a child..."

# Firefox config
if [ -d ~/.mozilla/firefox ]; then
    echo "Configuring Firefox..."
    
    # Find all Firefox profiles
    find ~/.mozilla/firefox -name "*.default*" -type d | while read -r profile; do
        echo "Fixing profile: $profile"
        
        # Create or update user.js with our settings
        cat >> "$profile/user.js" << 'EOF'
// Download restrictions
user_pref("browser.download.always_ask_before_handling_new_types", false);
user_pref("browser.download.manager.addToRecentDocs", true);
user_pref("browser.download.useDownloadDir", true);
user_pref("browser.download.improvements_to_download_panel", true);

// Security warnings
user_pref("browser.safebrowsing.downloads.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.enabled", false);
user_pref("browser.download.forbid_open_with", false);

// Executable files
user_pref("browser.download.forbid_open_with", false);
user_pref("network.file.disable_unc_paths", false);

// Direct opening of files
user_pref("helpers.private_mime_types_file", "");
user_pref("browser.helperApps.deleteTempFileOnExit", false);

// MIME type handling
user_pref("browser.download.viewableInternally.enabledTypes", "");
user_pref("browser.helperApps.neverAsk.saveToDisk", "application/x-executable,application/x-debian-package,application/x-rpm,application/x-redhat-package-manager,application/x-perl,application/x-python,application/x-ruby,application/x-shellscript,application/java-archive");
EOF
    done
fi

# Chrome/Chromium config
for chrome_dir in ~/.config/google-chrome ~/.config/chromium; do
    if [ -d "$chrome_dir" ]; then
        echo "Configuring ${chrome_dir##*/}..."
        
        # Create policies directory if it doesn't exist
        sudo mkdir -p "/etc/chromium/policies/managed"
        
        # Set up policies to allow downloads
        echo '{
    "DownloadRestrictions": 0,
    "SafeBrowsingEnabled": false,
    "AllowFileSelectionDialogs": true,
    "DefaultDownloadDirectory": "${HOME}/Downloads",
    "PromptForDownloadLocation": false,
    "AutoOpenAllowedForURLs": ["*"],
    "AutoOpenFileTypes": [
        "exe", "deb", "rpm", "sh", "run", "AppImage",
        "bin", "dmg", "iso", "msi", "pkg", "py", "pl"
    ]
}' | sudo tee "/etc/chromium/policies/managed/unfuck_downloads.json"

        # Link policies for Chrome if it exists
        if [ "${chrome_dir##*/}" = "google-chrome" ]; then
            sudo mkdir -p "/etc/google-chrome/policies/managed"
            sudo ln -sf "/etc/chromium/policies/managed/unfuck_downloads.json" \
                       "/etc/google-chrome/policies/managed/unfuck_downloads.json"
        fi
    fi
done

# Set up proper file associations
echo "Setting up file associations..."

# Common executable types
for type in "application/x-executable" "application/x-shellscript" "application/x-python" \
           "application/x-perl" "application/x-ruby" "text/x-python" "text/x-script.python"; do
    xdg-mime default org.kde.konsole.desktop "$type"
done

# Archive types
for type in "application/x-compressed-tar" "application/x-bzip-compressed-tar" \
           "application/x-xz-compressed-tar" "application/zip" "application/x-7z-compressed"; do
    xdg-mime default org.kde.ark.desktop "$type"
done

# Make downloads directory actually usable
echo "Configuring Downloads directory..."
mkdir -p ~/Downloads
chmod 755 ~/Downloads

# Set up auto-execution for downloaded files
cat > ~/.config/autostart/downloads-fix.desktop << EOF
[Desktop Entry]
Type=Application
Name=Downloads Fix
Exec=find ~/Downloads -type f -exec chmod +x {} \;
Terminal=false
NoDisplay=true
X-GNOME-Autostart-enabled=true
EOF
chmod +x ~/.config/autostart/downloads-fix.desktop

# Set up inotify watcher for Downloads directory
echo "Setting up automatic executable bits for Downloads..."
cat > ~/.config/systemd/user/downloads-watch.service << EOF
[Unit]
Description=Watch Downloads directory and make files executable

[Service]
ExecStart=/bin/sh -c 'while inotifywait -e close_write ~/Downloads; do find ~/Downloads -type f -exec chmod +x {} \; ; done'
Restart=always

[Install]
WantedBy=default.target
EOF

# Enable the service
systemctl --user daemon-reload
systemctl --user enable --now downloads-watch.service

echo "Browser restrictions removed!"
echo "Changes made:"
echo "✓ Disabled Firefox download warnings"
echo "✓ Removed Chrome/Chromium restrictions"
echo "✓ Set up proper file associations"
echo "✓ Made Downloads directory auto-execute files"
echo ""
echo "You may need to restart your browsers for all changes to take effect."