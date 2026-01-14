#!/bin/bash

if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should not be run as root. Run it as your regular user."
    exit 1
fi

# Toggle desktop peek - single script to hide/show everything
# This script checks current state and toggles between peek and normal

DESKTOP_DIR="$HOME/Desktop"
HIDDEN_DIR="$HOME/.desktop_hidden"
STATE_FILE="$HOME/.desktop_peek_state"
WINDOW_LIST="$HOME/.desktop_peek_windows"

# Check current state
if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE" 2>/dev/null)" = "hidden" ]; then
    # Currently hidden - restore everything
    echo "Restoring desktop..."
    
    # Trigger KDE's built-in Peek at Desktop (restore windows)
    wmctrl -k off 2>/dev/null
    echo "✓ Windows restored"
    
    # Small delay
    sleep 0.3
    
    # Restore icons
    if [ -d "$HIDDEN_DIR" ] && [ "$(ls -A "$HIDDEN_DIR" 2>/dev/null)" ]; then
        mv "$HIDDEN_DIR"/* "$DESKTOP_DIR"/ 2>/dev/null
        echo "✓ Restored $(ls -1 "$DESKTOP_DIR" 2>/dev/null | wc -l) desktop items"
        rmdir "$HIDDEN_DIR" 2>/dev/null
    fi
    
    # Clear state
    rm -f "$STATE_FILE"
    
    echo ""
    echo "✓ Desktop fully restored!"
else
    # Currently normal - peek at desktop
    echo "Peeking at desktop..."
    
    # Create hidden directory
    mkdir -p "$HIDDEN_DIR"
    
    # Hide icons
    if [ "$(ls -A "$DESKTOP_DIR" 2>/dev/null)" ]; then
        mv "$DESKTOP_DIR"/* "$HIDDEN_DIR"/ 2>/dev/null
        echo "✓ Hidden $(ls -1 "$HIDDEN_DIR" | wc -l) desktop items"
    else
        echo "✓ Desktop already clean"
    fi
    
    # Trigger KDE's built-in Peek at Desktop (minimize all windows)
    wmctrl -k on 2>/dev/null
    echo "✓ All windows minimized across all monitors"
    
    # Add delay to prevent auto-restore
    sleep 0.5
    
    # Set state
    echo "hidden" > "$STATE_FILE"
    
    echo ""
    echo "✓ Desktop peek active!"
fi
