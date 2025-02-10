#!/bin/bash

echo "Removing PolicyKit annoyances..."

# Backup original configs
sudo mkdir -p /etc/polkit-1/rules.d.backup
sudo cp -r /etc/polkit-1/rules.d/* /etc/polkit-1/rules.d.backup/ 2>/dev/null

# Create a rule to allow any local user to do anything without password
echo '/* Allow members of the wheel group to execute any actions
 * without password authentication, similar to "sudo NOPASSWD:"
 */
polkit.addRule(function(action, subject) {
    if (subject.local) {
        return polkit.Result.YES;
    }
});' | sudo tee /etc/polkit-1/rules.d/49-nopasswd_global.rules

# Create rules for specific common actions
echo '/* Allow users to mount drives without authentication */
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.udisks2.filesystem-mount" ||
        action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
        action.id == "org.freedesktop.udisks2.filesystem-unmount-others" ||
        action.id == "org.freedesktop.udisks.filesystem-mount" ||
        action.id == "org.freedesktop.udisks.filesystem-mount-system" ||
        action.id == "org.freedesktop.udisks.filesystem-unmount-others") {
        return polkit.Result.YES;
    }
});' | sudo tee /etc/polkit-1/rules.d/10-udisks.rules

# Network Manager without password
echo '/* Allow users to modify network settings without authentication */
polkit.addRule(function(action, subject) {
    if (action.id.indexOf("org.freedesktop.NetworkManager.") == 0) {
        return polkit.Result.YES;
    }
});' | sudo tee /etc/polkit-1/rules.d/10-networkmanager.rules

# Power management without password
echo '/* Allow users to suspend/hibernate/shutdown without authentication */
polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.login1.power-off" ||
        action.id == "org.freedesktop.login1.reboot" ||
        action.id == "org.freedesktop.login1.suspend" ||
        action.id == "org.freedesktop.login1.hibernate") {
        return polkit.Result.YES;
    }
});' | sudo tee /etc/polkit-1/rules.d/10-power.rules

# Package management without password (if using PackageKit)
echo '/* Allow users to install/remove packages without authentication */
polkit.addRule(function(action, subject) {
    if (action.id.indexOf("org.freedesktop.packagekit.") == 0) {
        return polkit.Result.YES;
    }
});' | sudo tee /etc/polkit-1/rules.d/10-packagekit.rules

# Restart polkit to apply changes
sudo systemctl restart polkit

echo "PolicyKit has been neutered!"
echo "Changes made:"
echo "✓ Allowed all local users to perform admin tasks"
echo "✓ Removed authentication for mounting drives"
echo "✓ Removed authentication for network management"
echo "✓ Removed authentication for power management"
echo "✓ Removed authentication for package management"
echo ""
echo "Original rules backed up to /etc/polkit-1/rules.d.backup/"
echo "Note: Some desktop environments might need a restart to apply all changes."