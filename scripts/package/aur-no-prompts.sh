#!/bin/bash

echo "Making AUR less annoying..."

# Check if we're on an Arch-based system
if ! command -v pacman &> /dev/null; then
    echo "This script is for Arch-based systems only!"
    exit 1
fi

# Install yay if not present
if ! command -v yay &> /dev/null; then
    echo "Installing yay..."
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd - > /dev/null
    rm -rf /tmp/yay
fi

# Configure yay for less annoyance
echo "Configuring yay..."

# Create yay config if it doesn't exist
mkdir -p ~/.config/yay

# Set up no-bullshit config
echo '{
    "aururl": "https://aur.archlinux.org",
    "buildDir": "$HOME/.cache/yay",
    "editor": "",
    "editorflags": "",
    "makepkgbin": "makepkg",
    "makepkgconf": "",
    "pacmanbin": "pacman",
    "pacmanconf": "/etc/pacman.conf",
    "redownload": "no",
    "rebuild": "no",
    "answerclean": "None",
    "answerdiff": "None",
    "answeredit": "None",
    "answerupgrade": "None",
    "gitflags": "",
    "removemake": "yes",
    "sudobin": "sudo",
    "sudoflags": "",
    "requestsplitn": 150,
    "sortby": "votes",
    "searchby": "name-desc",
    "batflags": "",
    "git": {
        "fetch": true,
        "sudo": true
    },
    "gpg": {
        "program": "gpg",
        "flags": null
    },
    "completionrefreshtime": 7,
    "bottomup": true,
    "sudoloop": true,
    "timeupdate": false,
    "devel": false,
    "cleanAfter": true,
    "provides": true,
    "pgpfetch": true,
    "upgrademenu": true,
    "cleanmenu": true,
    "diffmenu": false,
    "editmenu": false,
    "combinedupgrade": true,
    "useask": false,
    "batchinstall": true,
    "savegraph": null
}' > ~/.config/yay/config.json

# Make makepkg faster and less annoying
sudo sed -i 's/^#MAKEFLAGS=.*/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf
sudo sed -i 's/^COMPRESSXZ=.*/COMPRESSXZ=(xz -c -z - --threads=0)/' /etc/makepkg.conf

# Create convenient aliases
echo '
# AUR aliases
alias yeet="yay -S --noconfirm"
alias yolo="yay -Syu --noconfirm"
alias yoink="yay -Rns"' >> ~/.bashrc

echo "AUR has been unfucked!"
echo "Changes made:"
echo "✓ Installed/configured yay"
echo "✓ Disabled all confirmation prompts"
echo "✓ Optimized makepkg settings"
echo "✓ Added convenient aliases:"
echo "  - yeet: Install package without prompts"
echo "  - yolo: Update everything without prompts"
echo "  - yoink: Remove package and dependencies"
echo ""
echo "You may need to restart your terminal for aliases to work."