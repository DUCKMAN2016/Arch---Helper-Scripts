#!/bin/bash

# System Control Panel - Creates a persistent floating window with system controls
if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should not be run as root. Run it as your regular user."
    exit 1
fi

# Check if already running
PID_FILE="/tmp/system_control_panel.pid"
if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE" 2>/dev/null)" 2>/dev/null; then
    echo "System Control Panel is already running. Bringing to front..."
    # Bring existing window to front
    wmctrl -a "System Control Panel" 2>/dev/null
    exit 0
fi

# Write PID file
echo $$ > "$PID_FILE"

# Cleanup function
cleanup() {
    rm -f "$PID_FILE"
    exit 0
}

# Trap cleanup on exit
trap cleanup EXIT INT TERM

# Main loop - keep panel open until user cancels
while true; do
    # Create the main dialog
    RESULT=$(kdialog --title "System Control Panel" --menu "Choose action:" \
        "logout" "🚪 Logout" \
        "poweroff" "🔌 Power Off" \
        "reboot" "🔄 Reboot" \
        "toggleapps" "📱 Toggle Open Apps" \
        "toggleicons" "🖥️ Toggle Desktop Icons" \
        "refresh" "🔄 Refresh Desktop" \
        "desktoppeek" "👁️ Desktop Peek" \
        "exit" "❌ Exit Panel" \
        --geometry 300x450)

    # Execute based on selection
    case "$RESULT" in
        "logout")
            # TODO: Replace with your logout command
            qdbus org.kde.ksmserver /KSMServer logout 0 0 0 2>/dev/null || echo "Logout command not available"
            sleep 3
            ;;
        "poweroff")
            poweroff &
            ;;
        "reboot")
            reboot &
            ;;
        "toggleapps")
            "$HOME/.local/bin/kde-desktop-tools/utilities/toggle_open_apps.sh"
            ;;
        "toggleicons")
            "$HOME/.local/bin/kde-desktop-tools/utilities/toggle_desktop_icons.sh"
            ;;
        "refresh")
            "$HOME/.local/bin/kde-desktop-tools/utilities/refresh-desktop.sh"
            ;;
        "desktoppeek")
            "$HOME/.local/bin/kde-desktop-tools/desktop-peek/desktop_peek_unified.sh"
            ;;
        "exit")
            echo "Exiting System Control Panel"
            exit 0
            ;;
        *)
            echo "Cancelled or closed"
            exit 0
            ;;
    esac
    
    # Small delay before showing menu again
    sleep 0.5
done
