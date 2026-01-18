#!/bin/bash

if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should not be run as root. Run it as your regular user."
    exit 1
fi

# Toggle open applications (minimize/restore all windows)
echo "Toggling open applications..."

# Check current state
STATE_FILE="$HOME/.toggle_apps_state"

if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE" 2>/dev/null)" = "minimized" ]; then
    # Currently minimized - restore all windows
    echo "Restoring all windows..."
    
    # Restore all windows using KDE window manager
    qdbus org.kde.KWin /KWin unminimizeAll 2>/dev/null
    
    # Alternative method using xdotool
    if command -v xdotool &> /dev/null; then
        xdotool search --onlyvisible --class ".*" windowactivate 2>/dev/null
    fi
    
    # Clear state
    rm -f "$STATE_FILE"
    
    echo "✓ All windows restored!"
else
    # Currently normal - minimize all windows
    echo "Minimizing all windows..."
    
    # Minimize all windows using KDE window manager
    qdbus org.kde.KWin /KWin minimizeAll 2>/dev/null
    
    # Alternative method using xdotool
    if command -v xdotool &> /dev/null; then
        xdotool search --onlyvisible --class ".*" windowminimize 2>/dev/null
    fi
    
    # Set state
    echo "minimized" > "$STATE_FILE"
    
    echo "✓ All windows minimized!"
fi
