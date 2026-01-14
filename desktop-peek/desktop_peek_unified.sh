#!/bin/bash
# Unified Desktop Peek - Single click to toggle everything
# Combines icon hiding with KDE's built-in Peek at Desktop

DESKTOP_DIR="$HOME/Desktop"
HIDDEN_DIR="$HOME/.desktop_hidden"
STATE_FILE="$HOME/.desktop_peek_state"

# Check current state
if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE" 2>/dev/null)" = "hidden" ]; then
    # Currently hidden - restore everything
    
    # Trigger KDE's built-in Peek at Desktop (restore windows)
    xdotool key Super+d 2>/dev/null
    
    # Small delay
    sleep 0.2
    
    # Restore icons
    if [ -d "$HIDDEN_DIR" ] && [ "$(ls -A "$HIDDEN_DIR" 2>/dev/null)" ]; then
        mv "$HIDDEN_DIR"/* "$DESKTOP_DIR"/ 2>/dev/null
        rmdir "$HIDDEN_DIR" 2>/dev/null
    fi
    
    # Clear state
    rm -f "$STATE_FILE"
    
    # Send notification
    notify-send "Desktop Restored" "Icons and windows are back" -i view-visible -t 2000 2>/dev/null
    
else
    # Currently normal - peek at desktop
    
    # Create hidden directory
    mkdir -p "$HIDDEN_DIR"
    
    # Hide icons
    if [ "$(ls -A "$DESKTOP_DIR" 2>/dev/null)" ]; then
        mv "$DESKTOP_DIR"/* "$HIDDEN_DIR"/ 2>/dev/null
    fi
    
    # Trigger KDE's built-in Peek at Desktop (minimize all windows)
    xdotool key Super+d 2>/dev/null
    
    # Set state
    echo "hidden" > "$STATE_FILE"
    
    # Send notification
    notify-send "Desktop Peek Active" "Clean desktop view enabled" -i view-hidden -t 2000 2>/dev/null
fi
