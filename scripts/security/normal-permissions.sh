#!/bin/bash

echo "Setting up sane file permissions..."

# Back up important files
sudo cp /etc/login.defs /etc/login.defs.backup
sudo cp /etc/security/limits.conf /etc/security/limits.conf.backup

# Set a reasonable umask that doesn't break everything
sudo sed -i 's/UMASK.*[0-9]*/UMASK\t\t022/' /etc/login.defs
echo "umask 022" >> ~/.profile

# Fix home directory permissions
chmod 755 ~
find ~ -type d -exec chmod 755 {} \;
find ~ -type f -exec chmod 644 {} \;

# Make sure executable scripts stay executable
find ~ -type f -name "*.sh" -exec chmod +x {} \;
find ~ -type f -name "*.py" -exec chmod +x {} \;

# Fix common directories that often have wrong permissions
for dir in Documents Downloads Pictures Music Videos Desktop; do
    if [ -d ~/$dir ]; then
        chmod 755 ~/$dir
    fi
done

# Fix .ssh directory permissions
if [ -d ~/.ssh ]; then
    chmod 700 ~/.ssh
    chmod 600 ~/.ssh/*
    chmod 644 ~/.ssh/*.pub 2>/dev/null
fi

# Fix common development directories
for dir in .npm .cargo .local/share/npm; do
    if [ -d ~/$dir ]; then
        chmod -R u+rwX,go+rX,go-w ~/$dir
    fi
done

# Set up ACLs for better permission management
sudo pacman -S --needed --noconfirm acl
setfacl -R -m u:$USER:rwX ~/
setfacl -R -m g:$USER:rX ~/

# Fix XDG directories
mkdir -p ~/.local/share ~/.config ~/.cache
chmod 755 ~/.local ~/.local/share ~/.config ~/.cache

# Allow execution in common script directories
for dir in ~/.local/bin ~/bin ~/.cargo/bin; do
    if [ -d $dir ]; then
        chmod 755 $dir
        find $dir -type f -exec chmod +x {} \;
    fi
done

# Fix Steam directory permissions if it exists
if [ -d ~/.steam ]; then
    chmod -R u+rwX,go+rX,go-w ~/.steam
fi

# Make resolv.conf writable by NetworkManager
sudo chattr -i /etc/resolv.conf 2>/dev/null

# Add convenient permission aliases
echo '
# Permission aliases
alias fixperms="find . -type d -exec chmod 755 {} \; && find . -type f -exec chmod 644 {} \;"
alias fixscripts="find . -name \"*.sh\" -o -name \"*.py\" -exec chmod +x {} \;"
alias myfile="sudo chown $USER:$USER"' >> ~/.bashrc

echo "Permissions have been normalized!"
echo "Changes made:"
echo "✓ Set sane umask defaults"
echo "✓ Fixed home directory permissions"
echo "✓ Made scripts executable"
echo "✓ Fixed common directory permissions"
echo "✓ Set up ACLs for better control"
echo "✓ Added convenient aliases:"
echo "  - fixperms: Fix permissions in current directory"
echo "  - fixscripts: Make scripts executable"
echo "  - myfile: Take ownership of files"
echo ""
echo "Original configs backed up with .backup extension"
echo "You may need to log out and back in for all changes to take effect."