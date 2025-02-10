#!/bin/bash

echo "Setting up development environment without the BS..."

# Remove python external management restrictions first
sudo rm -f /usr/lib/python*/EXTERNALLY-MANAGED
sudo rm -f /usr/lib/python*/*/EXTERNALLY-MANAGED

# Disable pip venv warnings completely
mkdir -p ~/.config/pip
echo "[global]
break-system-packages = true
no-virtualenv = true
no-warn-script-location = true
no-warn-conflicts = true
disable-pip-version-check = true" > ~/.config/pip/pip.conf

# Also set it system-wide
sudo mkdir -p /etc/pip.conf
sudo cp ~/.config/pip/pip.conf /etc/pip.conf

# Set environment variables to disable ALL warnings
echo 'export PIP_DISABLE_PIP_VERSION_CHECK=1
export PIP_NO_WARN_SCRIPT_LOCATION=1
export PIP_BREAK_SYSTEM_PACKAGES=1
export PIP_NO_PYTHON_VERSION_WARNING=1
export PIP_USE_DEPRECATED=legacy-resolver
export PYTHONWARNINGS="ignore"
export PIP_REQUIRE_VIRTUALENV=false' >> ~/.bashrc

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
    "extensions.autoUpdate": false,
    "python.terminal.activateEnvironment": false
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

# Python development conveniences with force flags
echo 'alias py="python3"
alias pip="pip3 --break-system-packages"
alias pytest="python3 -m pytest"
alias pyinstall="pip3 install --break-system-packages --user"' >> ~/.bashrc

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

# Apply changes to current session
source ~/.bashrc

echo "Development environment setup complete! All restrictions have been removed."