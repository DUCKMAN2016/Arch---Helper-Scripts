#!/bin/bash

# Make all desktop files executable
chmod +x ~/Desktop/*.desktop 2>/dev/null

# Kill any existing plasma processes
kquitapp6 plasmashell 2>/dev/null
sleep 1
killall plasmashell 2>/dev/null
sleep 2

# Try multiple methods to restart plasma
echo "Starting Plasma with method 1..."
DISPLAY=:0 nohup plasmashell > /dev/null 2>&1 &
sleep 3

# Check if plasma is running
if pgrep plasmashell > /dev/null; then
    echo "✅ Plasma started successfully!"
else
    echo "❌ First attempt failed, trying method 2..."
    DISPLAY=:0 nohup kstart6 plasmashell > /dev/null 2>&1 &
    sleep 3
    
    # Check again
    if pgrep plasmashell > /dev/null; then
        echo "✅ Plasma started successfully with method 2!"
    else
        echo "❌ Second attempt failed, trying method 3..."
        DISPLAY=:0 nohup dbus-launch plasmashell > /dev/null 2>&1 &
        sleep 3
        
        # Final check
        if pgrep plasmashell > /dev/null; then
            echo "✅ Plasma started successfully with method 3!"
        else
            echo "❌ All attempts to restart Plasma failed."
            echo "You may need to log out and log back in."
        fi
    fi
fi

echo "Desktop refresh completed."

# Show a notification
if command -v notify-send > /dev/null; then
    notify-send -a "Desktop Refresh" "Plasma has been refreshed" -i "view-refresh"
fi

