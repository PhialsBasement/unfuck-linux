#!/bin/bash

echo "Starting complete system unfucking process..."

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR/.."

# Function to run script with error handling
run_script() {
    echo "Running $1..."
    if [ -f "$1" ]; then
        chmod +x "$1"
        if ! "$1"; then
            echo "Warning: $1 failed, continuing anyway..."
        fi
    else
        echo "Warning: $1 not found, skipping..."
    fi
    echo "----------------------------------------"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please don't run this script as root. It will ask for sudo when needed."
    exit 1
fi

# Check for required commands
for cmd in sudo chmod kwriteconfig5 git; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: Required command '$cmd' not found. Please install it first."
        exit 1
    fi
done

echo "Beginning system unfucking sequence..."
echo "This will remove unnecessary security restrictions and set up sane defaults."
echo "Your system will be much more usable after this."
echo "----------------------------------------"

# Security removal scripts
run_script "security/remove-kwallet.sh"
run_script "security/passwordless-sudo.sh"
run_script "security/auto-exec.sh"

# Convenience scripts
run_script "convenience/sane-defaults.sh"
run_script "convenience/dev-tools.sh"

# Additional tweaks
echo "Applying additional system tweaks..."

# Disable session restore prompts
if [ -f ~/.config/ksmserverrc ]; then
    sed -i 's/restoreSession=true/restoreSession=false/g' ~/.config/ksmserverrc
fi

# Speed up package downloads
if [ -f /etc/pacman.conf ]; then
    sudo sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 10/g' /etc/pacman.conf
fi

# Enable all mirrors for faster downloads
if [ -f /etc/pacman.d/mirrorlist ]; then
    sudo sed -i 's/^#Server/Server/g' /etc/pacman.d/mirrorlist
fi

echo "System unfucking complete! Please log out and back in for all changes to take effect."
echo ""
echo "Your system should now:"
echo "✓ Not ask for passwords constantly"
echo "✓ Have sane default settings"
echo "✓ Have a proper development environment"
echo "✓ Be actually usable as a desktop OS"
echo ""
echo "If you run into any issues, check the GitHub repo for troubleshooting."
echo "Remember: A system that's hard to use isn't more secure, it's just annoying."