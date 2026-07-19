#!/bin/bash

# Script to add KDE Desktop Tools actions to the system's right-click context menu (KIO Servicemenus)
# This places a .desktop file in the user's local KIO service menus directory.

set -e

SERVICE_MENU_DIR="$HOME/.local/share/kio/servicemenus"
TARGET_FILE="$SERVICE_MENU_DIR/kde-desktop-tools.desktop"

echo "📂 Creating service menus directory..."
mkdir -p "$SERVICE_MENU_DIR"

echo "✍️ Writing context menu configuration..."
cat > "$TARGET_FILE" << EOF
[Desktop Entry]
Type=Service
ServiceTypes=KonqPopupMenu/Plugin
MimeType=all/all;all/allfiles;inode/directory;
Actions=toggleapps;toggleicons;refresh;desktoppeek;logout;reboot;poweroff;
X-KDE-Submenu=KDE Desktop Tools
X-KDE-Priority=TopLevel

[Desktop Action toggleapps]
Name=Toggle Open Apps
Icon=window-minimize
Exec=sh -c '"\$HOME/.local/bin/kde-desktop-tools/utilities/toggle_open_apps.sh"'

[Desktop Action toggleicons]
Name=Toggle Desktop Icons
Icon=user-desktop
Exec=sh -c '"\$HOME/.local/bin/kde-desktop-tools/utilities/toggle_desktop_icons.sh"'

[Desktop Action refresh]
Name=Refresh Desktop
Icon=view-refresh
Exec=sh -c '"\$HOME/.local/bin/kde-desktop-tools/utilities/refresh-desktop.sh"'

[Desktop Action desktoppeek]
Name=Desktop Peek (Clean Desktop)
Icon=view-hidden
Exec=sh -c '"\$HOME/.local/bin/kde-desktop-tools/desktop-peek/desktop_peek_unified.sh"'

[Desktop Action logout]
Name=Logout Session
Icon=system-log-out
Exec=qdbus org.kde.ksmserver /KSMServer logout 0 0 0

[Desktop Action reboot]
Name=Reboot System
Icon=system-reboot
Exec=systemctl reboot

[Desktop Action poweroff]
Name=Power Off System
Icon=system-shutdown
Exec=systemctl poweroff
EOF

echo "✅ Context menu added successfully!"
echo "📍 Location: $TARGET_FILE"
echo ""
echo "Note: The options will appear under the 'KDE Desktop Tools' submenu when you right-click files or folders in Dolphin."
