#!/bin/bash

echo "Setting up development environment without the BS..."

# Remove python external management restrictions first
echo "Removing Python restrictions..."
sudo rm -f /usr/lib/python*/EXTERNALLY-MANAGED
sudo rm -f /usr/lib/python*/*/EXTERNALLY-MANAGED
sudo find /usr/lib/python* -name "EXTERNALLY-MANAGED" -delete 2>/dev/null

# Fix pip.conf directory issue and set up aggressive pip configs
echo "Configuring pip..."
sudo rm -rf /etc/pip.conf
sudo rm -rf ~/.config/pip
mkdir -p ~/.config/pip

# Create comprehensive pip config
PIP_CONFIG='[global]
break-system-packages = true
no-virtualenv = true
no-warn-script-location = true
no-warn-conflicts = true
disable-pip-version-check = true
no-python-version-warning = true
no-index-url = false
timeout = 1000
trusted-host = 
    pypi.python.org
    pypi.org
    files.pythonhosted.org
retries = 10
use-deprecated = legacy-resolver'

# Apply pip config both user-wide and system-wide
echo "$PIP_CONFIG" | sudo tee /etc/pip.conf > ~/.config/pip/pip.conf

# Set up aggressive environment variables in multiple places
ENV_VARS='export PIP_DISABLE_PIP_VERSION_CHECK=1
export PIP_NO_WARN_SCRIPT_LOCATION=1
export PIP_BREAK_SYSTEM_PACKAGES=1
export PIP_NO_PYTHON_VERSION_WARNING=1
export PIP_USE_DEPRECATED=legacy-resolver
export PYTHONWARNINGS="ignore"
export PIP_REQUIRE_VIRTUALENV=false
export PYTHONDONTWRITEBYTECODE=1  # Prevent creation of .pyc files
export PYTHONUNBUFFERED=1  # Prevent Python from buffering stdout/stderr'

# Add environment variables to all possible shell configs
echo "$ENV_VARS" >> ~/.bashrc
echo "$ENV_VARS" >> ~/.profile
[ -f ~/.zshrc ] && echo "$ENV_VARS" >> ~/.zshrc

# Configure git for convenience
echo "Configuring git..."
git config --global credential.helper store
git config --global pull.rebase false
git config --global core.editor "nano"
git config --global init.defaultBranch main
git config --global push.autoSetupRemote true  # Auto set push upstream

# VSCode without telemetry and restrictions
if command -v code &> /dev/null; then
    echo "Configuring VSCode..."
    mkdir -p ~/.config/Code/User/
    echo '{
    "telemetry.enableTelemetry": false,
    "telemetry.enableCrashReporter": false,
    "update.mode": "manual",
    "security.workspace.trust.enabled": false,
    "extensions.autoUpdate": false,
    "python.terminal.activateEnvironment": false,
    "python.defaultInterpreterPath": "/usr/bin/python3",
    "python.analysis.autoImportCompletions": true,
    "python.analysis.typeCheckingMode": "off",
    "python.linting.enabled": false
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
echo "Installing development tools..."
sudo pacman -Sy --noconfirm base-devel git curl wget

# NPM without root
echo "Configuring NPM..."
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc

# Python development conveniences with force flags
echo "Setting up Python aliases..."
echo 'alias py="python3"
alias pip="pip3 --break-system-packages"
alias pip3="pip3 --break-system-packages"
alias pytest="python3 -m pytest"
alias pyinstall="pip3 install --break-system-packages --user"
alias pipuninstall="pip3 uninstall --break-system-packages"
alias piplist="pip3 list --break-system-packages"' >> ~/.bashrc

# Rust without prompts
if ! command -v rustc &> /dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

# Better terminal tools
echo "Installing terminal tools..."
sudo pacman -S --noconfirm htop ripgrep fd bat

# Create better aliases for development
echo "Setting up convenience aliases..."
echo '
# Development aliases
alias g="git"
alias gst="git status"
alias gd="git diff"
alias gc="git commit"
alias gp="git push"
alias gl="git pull"
alias gf="git fetch"
alias grb="git rebase"

# Better ls
alias ll="ls -lah"
alias la="ls -A"

# Quick directory navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Better grep
alias grep="grep --color=auto"

# Python virtual environment (when you actually need it)
alias mkenv="python3 -m venv ./venv"
alias activate="source ./venv/bin/activate"

# System
alias update="sudo pacman -Syu --noconfirm && yay -Syu --noconfirm"
alias clean="sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null || echo No orphans to remove"' >> ~/.bashrc

# Double-check Python restrictions are gone
sudo rm -f /usr/lib/python*/EXTERNALLY-MANAGED
sudo rm -f /usr/lib/python*/*/EXTERNALLY-MANAGED

# Apply changes to current session
source ~/.bashrc

echo "Development environment setup complete! All restrictions have been removed."
echo "NOTE: You may need to log out and back in for some changes to take effect."
echo "      Docker will work after a restart."