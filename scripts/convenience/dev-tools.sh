#!/bin/bash

echo "Setting up development environment without the BS..."

# Disable pip venv warnings
mkdir -p ~/.config/pip
echo "[global]
no-virtualenv = true
no-warn-script-location = true
no-warn-conflicts = true" > ~/.config/pip/pip.conf

# Set environment variable to disable venv warnings
echo 'export PIP_REQUIRE_VIRTUALENV=false' >> ~/.bashrc

# Configure git for convenience
git config --global credential.helper store
git config --global pull.rebase false
git config --global core.editor "nano"
git config --global init.defaultBranch main

# VSCode without telemetry
if command -v code &> /dev/null; then
    echo "Configuring VSCode..."
    mkdir -p ~/.config/Code/User/
    echo '{
    "telemetry.enableTelemetry": false,
    "telemetry.enableCrashReporter": false,
    "update.mode": "manual",
    "security.workspace.trust.enabled": false,
    "extensions.autoUpdate": false
}' > ~/.config/Code/User/settings.json
fi

# Docker without sudo
if command -v docker &> /dev/null; then
    echo "Configuring Docker..."
    sudo groupadd docker 2>/dev/null
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
fi

# Install basic dev tools without prompts
sudo pacman -Sy --noconfirm base-devel git curl wget

# NPM without root
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc

# Python development conveniences
echo 'alias py="python3"
alias pip="pip3"
alias pytest="python3 -m pytest"
alias pyinstall="pip3 install --user"' >> ~/.bashrc

# Rust without prompts
if ! command -v rustc &> /dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# Better terminal tools
sudo pacman -S --noconfirm htop ripgrep fd bat

# Create better aliases for development
echo '
# Development aliases
alias g="git"
alias gst="git status"
alias gd="git diff"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"

# Better ls
alias ll="ls -lah"
alias la="ls -A"

# Quick directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Better grep
alias grep="grep --color=auto"' >> ~/.bashrc

echo "Development environment setup complete! Log out and back in for all changes to take effect."