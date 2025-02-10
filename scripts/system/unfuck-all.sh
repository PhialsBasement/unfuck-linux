#!/bin/bash

echo "Starting complete system unfucking process..."

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR/.."

# Initialize counters
TOTAL_SCRIPTS=0
COMPLETED_SCRIPTS=0
FAILED_SCRIPTS=0

# Function to run script with error handling
run_script() {
    local script=$1
    TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))
    echo "----------------------------------------"
    echo "Running $script..."
    if [ -f "$script" ]; then
        chmod +x "$script"
        if "$script"; then
            echo "✓ $script completed successfully"
            COMPLETED_SCRIPTS=$((COMPLETED_SCRIPTS + 1))
        else
            echo "✗ $script failed, continuing anyway..."
            FAILED_SCRIPTS=$((FAILED_SCRIPTS + 1))
        fi
    else
        echo "✗ $script not found, skipping..."
        FAILED_SCRIPTS=$((FAILED_SCRIPTS + 1))
    fi
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "Please don't run this script as root. It will ask for sudo when needed."
    exit 1
fi

# Check for required commands
for cmd in sudo chmod git; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: Required command '$cmd' not found. Please install it first."
        exit 1
    fi
done

echo "Beginning system unfucking sequence..."
echo "This will remove unnecessary security restrictions and set up sane defaults."
echo "Your system will be much more usable after this."
echo "----------------------------------------"

# Package management scripts (run first to ensure dependencies)
echo "Phase 1: Unfucking package management..."
run_script "package/pacman-speed.sh"
run_script "package/aur-no-prompts.sh"
run_script "package/dependency-hell-fix.sh"

# Security removal scripts
echo "Phase 2: Removing security theater..."
run_script "security/polkit-begone.sh"
run_script "security/automount-all.sh"
run_script "security/normal-permissions.sh"
run_script "security/remove-kwallet.sh"
run_script "security/passwordless-sudo.sh"
run_script "security/auto-exec.sh"
run_script "security/fix-wallpaper.sh"

# Convenience scripts
echo "Phase 3: Setting up conveniences..."
run_script "convenience/sane-defaults.sh"
run_script "convenience/dev-tools.sh"

# Additional tweaks
echo "Phase 4: Applying final tweaks..."

# Speed up boot by disabling unnecessary services
sudo systemctl disable NetworkManager-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service

# Disable session restore prompts
if [ -f ~/.config/ksmserverrc ]; then
    sed -i 's/restoreSession=true/restoreSession=false/g' ~/.config/ksmserverrc
fi

# Print summary
echo "----------------------------------------"
echo "System unfucking complete!"
echo "----------------------------------------"
echo "Scripts executed: $TOTAL_SCRIPTS"
echo "Successful: $COMPLETED_SCRIPTS"
echo "Failed: $FAILED_SCRIPTS"
echo ""
echo "Your system should now:"
echo "✓ Have fast, no-BS package management"
echo "✓ Not ask for passwords constantly"
echo "✓ Have working automounting"
echo "✓ Have sane file permissions"
echo "✓ Have reasonable system defaults"
echo "✓ Have a proper development environment"
echo "✓ Actually be usable as a desktop OS"
echo ""
echo "Required actions:"
echo "1. Log out and back in for all changes to take effect"
echo "2. Reboot for some system changes to apply"
echo ""
echo "If you run into any issues, check the GitHub repo for troubleshooting."
echo "Remember: A system that's hard to use isn't more secure, it's just annoying."