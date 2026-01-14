#!/bin/bash

# KDE Desktop Tools Installer
# Automatically installs scripts and creates desktop launchers

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/bin/kde-desktop-tools"
DESKTOP_DIR="$HOME/.local/share/applications"

echo "🚀 Installing KDE Desktop Tools..."

# Create installation directory
mkdir -p "$INSTALL_DIR"
mkdir -p "$DESKTOP_DIR"

# Copy scripts to installation directory
echo "📁 Installing scripts..."
cp -r "$SCRIPT_DIR"/* "$INSTALL_DIR/"

# Make all scripts executable
echo "🔧 Making scripts executable..."
find "$INSTALL_DIR" -name "*.sh" -exec chmod +x {} \;

# Create desktop launchers
echo "🖥️ Creating desktop launchers..."

# Desktop Peek launcher
cat > "$DESKTOP_DIR/desktop-peek.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Desktop Peek
Comment=Hide desktop icons and minimize windows
Exec=$INSTALL_DIR/desktop-peek/desktop_peek_unified.sh
Icon=view-hidden
Terminal=false
Categories=System;Utility;
EOF

# System Control Panel launcher
cat > "$DESKTOP_DIR/system-control-panel.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=System Control Panel
Comment=GUI control center for system actions
Exec=$INSTALL_DIR/system-controls/system_control_panel.sh
Icon=system-run
Terminal=false
Categories=System;Settings;
EOF

# Audio Switcher launcher
cat > "$DESKTOP_DIR/audio-switcher.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Audio Switcher
Comment=Switch between audio output devices
Exec=$INSTALL_DIR/utilities/switch-audio.sh
Icon=audio-card
Terminal=false
Categories=AudioVideo;Audio;
EOF

# Update desktop database
echo "🔄 Updating desktop database..."
kbuildsycoca6 2>/dev/null || update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true

# Check dependencies
echo "🔍 Checking dependencies..."
MISSING_DEPS=()

for cmd in wmctrl xdotool notify-send kdialog; do
    if ! command -v "$cmd" &> /dev/null; then
        MISSING_DEPS+=("$cmd")
    fi
done

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo "⚠️  Missing dependencies: ${MISSING_DEPS[*]}"
    echo "Please install them using your package manager:"
    echo "  Ubuntu/Debian: sudo apt install ${MISSING_DEPS[*]}"
    echo "  Arch/CachyOS: sudo pacman -S ${MISSING_DEPS[*]}"
    echo "  Fedora: sudo dnf install ${MISSING_DEPS[*]}"
else
    echo "✅ All dependencies found!"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "🎯 Next steps:"
echo "1. Search for 'Desktop Peek' in your application menu"
echo "2. Pin your favorite launchers to the taskbar"
echo "3. Customize the System Control Panel paths (see README)"
echo ""
echo "📚 Documentation: $INSTALL_DIR/README.md"
echo "🔧 Scripts location: $INSTALL_DIR"
echo ""
echo "🌟 Enjoy your enhanced KDE desktop experience!"
