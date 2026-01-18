#!/bin/bash
# NordVPN Installation Script for Arch Linux
# Created by AI Assistant

set -e  # Exit on any error

echo "=== NordVPN Installation Script ==="
echo "This script will install NordVPN with GUI support."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root. Please run as a regular user."
    exit 1
fi

# Check if paru or yay is available
if ! command -v paru &> /dev/null && ! command -v yay &> /dev/null; then
    print_error "Neither paru nor yay is installed. Please install an AUR helper first."
    exit 1
fi

# Use paru if available, otherwise yay
AUR_HELPER="paru"
if ! command -v paru &> /dev/null; then
    AUR_HELPER="yay"
fi

print_status "Starting NordVPN installation using $AUR_HELPER..."

# Step 1: Install NordVPN CLI
print_status "Installing NordVPN CLI tool..."
if ! sudo -n true 2>/dev/null; then
    print_warning "Sudo password required for package installation..."
fi

$AUR_HELPER -S --noconfirm nordvpn-bin

if [ $? -eq 0 ]; then
    print_success "NordVPN CLI installed successfully!"
else
    print_error "Failed to install NordVPN CLI"
    exit 1
fi

# Step 2: Install recommended GUI
print_status "Installing recommended GUI (nordvpn-gui)..."
$AUR_HELPER -S --noconfirm nordvpn-gui

if [ $? -eq 0 ]; then
    print_success "nordvpn-gui installed successfully!"
    gui_installed=true
else
    print_warning "Failed to install nordvpn-gui, continuing without GUI"
    gui_installed=false
fi

# Step 3: Enable and start NordVPN service
print_status "Enabling NordVPN service..."
sudo systemctl enable --now nordvpnd

if [ $? -eq 0 ]; then
    print_success "NordVPN service enabled and started!"
else
    print_error "Failed to enable NordVPN service"
    exit 1
fi

# Step 4: Add user to nordvpn group
print_status "Adding user to nordvpn group..."
sudo gpasswd -a $USER nordvpn

if [ $? -eq 0 ]; then
    print_success "User added to nordvpn group!"
else
    print_error "Failed to add user to nordvpn group"
    exit 1
fi

# Step 5: Create desktop entry for GUI if installed
if [[ $gui_installed == true ]]; then
    print_status "Creating desktop entry for nordvpn-gui..."
    DESKTOP_ENTRY="$HOME/.local/share/applications/nordvpn-gui.desktop"
    mkdir -p "$(dirname "$DESKTOP_ENTRY")"
    
    cat > "$DESKTOP_ENTRY" << EOF
[Desktop Entry]
Name=NordVPN GUI
Comment=NordVPN GUI Client
Exec=nordvpn-gui
Icon=network-vpn
Type=Application
Categories=Network;Security;
Keywords=vpn;nordvpn;security;network;
EOF

    chmod +x "$DESKTOP_ENTRY"
    update-desktop-database "$HOME/.local/share/applications"
    print_success "Desktop entry created for nordvpn-gui!"
fi

# Step 6: Display next steps
echo ""
echo "=== Installation Complete! ==="
print_success "NordVPN has been installed successfully!"
echo ""
print_warning "IMPORTANT: You need to restart your system for the nordvpn group to take effect."
echo ""
print_status "After restart, you can:"
echo "  • Login to NordVPN: nordvpn login"
echo "  • Connect to VPN: nordvpn connect"
echo "  • Check status: nordvpn status"
echo "  • Disconnect: nordvpn disconnect"
echo ""
if [[ $gui_installed == true ]]; then
    print_status "Launch GUI from applications menu or run: nordvpn-gui"
fi
echo ""
read -p "Would you like to restart now? (y/N): " restart_choice
if [[ $restart_choice =~ ^[Yy]$ ]]; then
    print_status "Restarting system..."
    sudo reboot
else
    print_warning "Please restart your system manually when ready."
fi
