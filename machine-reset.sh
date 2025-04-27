# Script to reset machine-id on Linux systems
# Requires root privileges to execute

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

# Backup current machine-id files
echo "Creating backups of machine-id files..."
if [ -f /etc/machine-id ]; then
    cp /etc/machine-id /etc/machine-id.bak
fi

if [ -f /var/lib/dbus/machine-id ]; then
    cp /var/lib/dbus/machine-id /var/lib/dbus/machine-id.bak
fi

# Remove existing machine-id files
echo "Removing existing machine-id files..."
rm -f /etc/machine-id
rm -f /var/lib/dbus/machine-id

# Generate new machine-id
echo "Generating new machine-id..."
systemd-machine-id-setup

# Create symlink for dbus machine-id
if [ ! -f /var/lib/dbus/machine-id ]; then
    echo "Creating symlink for dbus machine-id..."
    ln -s /etc/machine-id /var/lib/dbus/machine-id
fi

# Verify new machine-id was created
if [ -f /etc/machine-id ]; then
    echo "New machine-id generated successfully:"
    cat /etc/machine-id
else
    echo "Error: Failed to generate new machine-id"
    exit 1
fi

echo "Machine ID reset complete. A system reboot is recommended."
