#!/bin/bash

echo "Setting up user-space permissions safely..."

# IMPORTANT: This script only touches user directories, not system files
# It will not break SSL certificates or system permissions

# Set a reasonable umask for new files
echo "umask 022" >> ~/.profile

# Fix ONLY user-owned directories in home
echo "Fixing permissions for user-owned files only..."
find ~ -user $USER -type d -exec chmod 755 {} \;
find ~ -user $USER -type f -exec chmod 644 {} \;

# Fix specific user directories that commonly need different permissions
echo "Setting up common directory permissions..."

# Development directories
if [ -d ~/Development ]; then
    chmod 755 ~/Development
    find ~/Development -user $USER -type f -name "*.sh" -exec chmod +x {} \;
    find ~/Development -user $USER -type f -name "*.py" -exec chmod +x {} \;
fi

# SSH directory (if owned by user)
if [ -d ~/.ssh ]; then
    if [ $(stat -c "%U" ~/.ssh) = $USER ]; then
        chmod 700 ~/.ssh
        find ~/.ssh -user $USER -type f -name "id_*" ! -name "*.pub" -exec chmod 600 {} \;
        find ~/.ssh -user $USER -type f -name "*.pub" -exec chmod 644 {} \;
    fi
fi

# Local bin directory
if [ -d ~/.local/bin ]; then
    chmod 755 ~/.local/bin
    find ~/.local/bin -user $USER -type f -exec chmod +x {} \;
fi

# Add safe permission management aliases
echo '
# Permission management aliases (SAFE VERSION)
alias fix-my-scripts="find . -user $USER \( -name \"*.sh\" -o -name \"*.py\" \) -exec chmod +x {} \;"
alias check-perms="stat -c \"%A %U:%G %n\""' >> ~/.bashrc

echo "User permissions have been safely updated!"
echo "Changes made:"
echo "✓ Set default umask for new files"
echo "✓ Fixed permissions for user-owned files only"
echo "✓ Set up development directory permissions"
echo "✓ Fixed SSH key permissions (if user-owned)"
echo "✓ Added safe permission management aliases"
echo ""
echo "NOTE: This script only modified files you own."
echo "System files and SSL certificates were not touched."
echo "Added aliases:"
echo "  - fix-my-scripts: Make your scripts executable"
echo "  - check-perms: Check permissions of a file"