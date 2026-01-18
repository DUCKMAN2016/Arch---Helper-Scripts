#!/bin/bash

if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should not be run as root. Run it as your regular user."
    exit 1
fi

# Refresh desktop display
echo "Refreshing desktop..."

# Method 1: KDE Plasma refresh
qdbus org.kde.plasmashell /PlasmaShell evaluateScript "
var allDesktops = desktops();
for (i=0;i<allDesktops.length;i++) {
    d = allDesktops[i];
    d.reloadConfig();
}
" 2>/dev/null

# Method 2: Force desktop refresh
kquitapp5 plasmashell 2>/dev/null && sleep 1 && plasmashell & 2>/dev/null

# Method 3: Update desktop database
update-desktop-database ~/.local/share/applications 2>/dev/null

# Method 4: Refresh desktop icons
dbus-send --type=method_call --dest=org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.showInteractiveConsole 2>/dev/null

echo "Desktop refresh completed!"
