#!/bin/bash

if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should not be run as root. Run it as your regular user."
    exit 1
fi

# Toggle desktop icons only
DESKTOP_DIR="$HOME/Desktop"
HIDDEN_DIR="$HOME/.desktop_hidden"
STATE_FILE="$HOME/.desktop_icons_state"

# Check current state
if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE" 2>/dev/null)" = "hidden" ]; then
    # Currently hidden - restore icons
    echo "Restoring desktop icons..."
    
    # Restore icons (files and directories)
    if [ -d "$HIDDEN_DIR" ] && [ "$(ls -A "$HIDDEN_DIR" 2>/dev/null)" ]; then
        # Move all files and directories back
        mv "$HIDDEN_DIR"/* "$DESKTOP_DIR"/ 2>/dev/null
        echo "✓ Restored $(ls -1 "$DESKTOP_DIR"/*.desktop 2>/dev/null | wc -l) desktop items and $(find "$DESKTOP_DIR" -maxdepth 1 -type d ! -name '.' ! -name '..' | wc -l) directories"
        rmdir "$HIDDEN_DIR" 2>/dev/null
    fi
    
    # Clear state
    rm -f "$STATE_FILE"
    
    echo ""
    echo "✓ Desktop icons restored!"
else
    # Currently visible - hide icons
    echo "Hiding desktop icons..."
    
    # Create hidden directory
    mkdir -p "$HIDDEN_DIR"
    
    # Hide icons (exclude only position files)
    if [ "$(ls -A "$DESKTOP_DIR" 2>/dev/null)" ]; then
        # Move all visible files except hidden position files
        find "$DESKTOP_DIR" -maxdepth 1 -type f ! -name '.*' -exec mv {} "$HIDDEN_DIR"/ \; 2>/dev/null
        
        # Also handle directories like NAS-Controls (but not the Desktop directory itself)
        find "$DESKTOP_DIR" -maxdepth 1 -type d ! -name '.*' ! -name '.' ! -name '..' ! -name 'Desktop' -exec mv {} "$HIDDEN_DIR"/ \; 2>/dev/null
        
        echo "✓ Hidden $(find "$HIDDEN_DIR" -maxdepth 1 | wc -l) desktop items"
    else
        echo "✓ Desktop already clean"
    fi
    
    # Set state
    echo "hidden" > "$STATE_FILE"
    
    echo ""
    echo "✓ Desktop icons hidden!"
fi
