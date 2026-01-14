#!/bin/bash

# Center MAME window using KDE window manager
# This script waits for MAME to launch and then centers the window

WINDOW_NAME="DEC Rainbow"
MAX_WAIT=10
WAIT_COUNT=0

echo "Waiting for MAME window to appear..."

# Wait for the window to appear
while [ $WAIT_COUNT -lt $MAX_WAIT ]; do
    # Try to find the window using qdbus (KDE)
    WINDOW_ID=$(qdbus org.kde.KWin /KWin queryWindowIds 2>/dev/null | while read id; do
        NAME=$(qdbus org.kde.KWin /KWin getWindowInfo $id 2>/dev/null | grep "name:" | cut -d: -f2)
        if [[ "$NAME" == *"$WINDOW_NAME"* ]]; then
            echo $id
            break
        fi
    done)
    
    if [ -n "$WINDOW_ID" ]; then
        echo "Found MAME window: $WINDOW_ID"
        
        # Get screen geometry
        SCREEN_GEOM=$(xrandr 2>/dev/null | grep " connected" | head -1 | grep -oP '\d+x\d+\+\d+\+\d+')
        if [ -z "$SCREEN_GEOM" ]; then
            # Fallback to default screen size
            SCREEN_WIDTH=1920
            SCREEN_HEIGHT=1080
            SCREEN_X=0
            SCREEN_Y=0
        else
            SCREEN_WIDTH=$(echo $SCREEN_GEOM | cut -d'x' -f1)
            SCREEN_HEIGHT=$(echo $SCREEN_GEOM | cut -d'+' -f1 | cut -d'x' -f2)
            SCREEN_X=$(echo $SCREEN_GEOM | cut -d'+' -f2)
            SCREEN_Y=$(echo $SCREEN_GEOM | cut -d'+' -f3)
        fi
        
        # MAME window is typically 1024x768
        WINDOW_WIDTH=1024
        WINDOW_HEIGHT=768
        
        # Calculate center position
        X=$(( SCREEN_X + (SCREEN_WIDTH - WINDOW_WIDTH) / 2 ))
        Y=$(( SCREEN_Y + (SCREEN_HEIGHT - WINDOW_HEIGHT) / 2 ))
        
        echo "Screen geometry: ${SCREEN_WIDTH}x${SCREEN_HEIGHT}+${SCREEN_X}+${SCREEN_Y}"
        echo "Centering window to: ${X}+${Y}"
        
        # Use kwin_x11 to move the window
        qdbus org.kde.KWin /KWin moveWindow $WINDOW_ID $X $Y 2>/dev/null
        
        # Alternative: use xdotool if available
        if command -v xdotool &> /dev/null; then
            xdotool windowmove $WINDOW_ID $X $Y 2>/dev/null
        fi
        
        echo "Window centered!"
        exit 0
    fi
    
    WAIT_COUNT=$((WAIT_COUNT + 1))
    sleep 0.5
done

echo "Timeout: Could not find MAME window after ${MAX_WAIT} seconds"
exit 1
