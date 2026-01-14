#!/bin/bash
# Show all desktop icons and restore windows in KDE Plasma 6
# This script restores desktop files and unminimizes windows

DESKTOP_DIR="$HOME/Desktop"
HIDDEN_DIR="$HOME/.desktop_hidden"
STATE_FILE="$HOME/.desktop_peek_state"
WINDOW_LIST="$HOME/.desktop_peek_windows"

echo "Restoring desktop..."

# Trigger KDE's built-in Peek at Desktop (restore windows)
xdotool key Super+d 2>/dev/null
echo "✓ Windows restored"

# Small delay to let windows restore
sleep 0.3

# Check if hidden directory exists and has files
if [ -d "$HIDDEN_DIR" ] && [ "$(ls -A "$HIDDEN_DIR" 2>/dev/null)" ]; then
    # Move all files back to desktop
    mv "$HIDDEN_DIR"/* "$DESKTOP_DIR"/ 2>/dev/null
    echo "✓ Restored $(ls -1 "$DESKTOP_DIR" 2>/dev/null | wc -l) desktop items"
    # Remove the hidden directory if empty
    rmdir "$HIDDEN_DIR" 2>/dev/null
else
    echo "✓ No hidden desktop items"
fi

# Remove state file
rm -f "$STATE_FILE"

echo ""
echo "✓ Desktop fully restored!"
echo "Run 'hide_desktop_icons.sh' or click 'Peek at Desktop' to hide again."
