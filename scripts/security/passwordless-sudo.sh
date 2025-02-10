#!/bin/bash

# Enable passwordless sudo after login

echo "Setting up passwordless sudo..."

# Backup sudoers file
sudo cp /etc/sudoers /etc/sudoers.bak

# Create new sudoers file for the user
echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/nopasswd

# Set proper permissions
sudo chmod 440 /etc/sudoers.d/nopasswd

# Disable sudo lecture
sudo touch ~/.sudo_as_admin_successful

# Optional: Remove sudo timeout
echo "Defaults timestamp_timeout=-1" | sudo tee -a /etc/sudoers.d/notimeout
sudo chmod 440 /etc/sudoers.d/notimeout

echo "Passwordless sudo enabled. No more pointless password prompts!"
echo "Original sudoers file backed up to /etc/sudoers.bak"