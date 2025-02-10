#!/bin/bash

# Remove KWallet and prevent it from coming back

echo "Removing KWallet and its configuration..."

# Remove KWallet files
rm -rf ~/.kde4/share/apps/kwallet
rm -rf ~/.local/share/kwalletd

# Disable KWallet
kwriteconfig5 --file kwalletrc --group Wallet --key "Enabled" "false"

# Disable KWallet PAM integration
sudo sed -i 's/auth\s*optional\s*pam_kwallet5.so/# auth optional pam_kwallet5.so/g' /etc/pam.d/login
sudo sed -i 's/session\s*optional\s*pam_kwallet5.so\s*auto_start/# session optional pam_kwallet5.so auto_start/g' /etc/pam.d/login

# Disable it in SDDM if present
if [ -f "/etc/pam.d/sddm" ]; then
    sudo sed -i 's/auth\s*optional\s*pam_kwallet5.so/# auth optional pam_kwallet5.so/g' /etc/pam.d/sddm
    sudo sed -i 's/session\s*optional\s*pam_kwallet5.so\s*auto_start/# session optional pam_kwallet5.so auto_start/g' /etc/pam.d/sddm
fi

# Kill any running KWallet processes
killall kwalletd5 2>/dev/null

echo "KWallet has been removed and disabled. No more password prompts for WiFi!"