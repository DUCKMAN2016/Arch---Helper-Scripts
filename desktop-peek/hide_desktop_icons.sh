#!/bin/bash
# Hide all desktop icons and minimize all windows in KDE Plasma 6
# This script temporarily moves desktop files and shows desktop

DESKTOP_DIR="$HOME/Desktop"
HIDDEN_DIR="$HOME/.desktop_hidden"
STATE_FILE="$HOME/.desktop_peek_state"
WINDOW_LIST="$HOME/.desktop_peek_windows"

echo "Peeking at desktop..."

# Create hidden directory if it doesn't exist
mkdir -p "$HIDDEN_DIR"

# Check if there are any files on desktop
if [ "$(ls -A "$DESKTOP_DIR" 2>/dev/null)" ]; then
    # Move all desktop files to hidden directory
    mv "$DESKTOP_DIR"/* "$HIDDEN_DIR"/ 2>/dev/null
    echo "✓ Hidden $(ls -1 "$HIDDEN_DIR" | wc -l) desktop items"
else
    echo "✓ Desktop already clean"
fi

# Trigger KDE's built-in Peek at Desktop (minimize all windows)
xdotool key Super+d 2>/dev/null
echo "✓ All windows minimized across all monitors"

# Mark state as hidden
echo "hidden" > "$STATE_FILE"

echo ""
echo "✓ Desktop peek active!"
echo "Run 'show_desktop_icons.sh' or click 'Restore Desktop' to restore."
