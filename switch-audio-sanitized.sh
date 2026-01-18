#!/bin/bash
# Audio output switcher script
# Switches between different audio outputs

echo "=== Audio Output Switcher ==="
echo ""
echo "Current default sink:"
pactl get-default-sink
echo ""

echo "Available audio outputs:"
echo "1) HDMI Output 1"
echo "2) HDMI Output 2"
echo "3) DisplayPort/Other HDMI"
echo "4) USB Audio Device"
echo "5) List all available sinks"
echo "6) Test current output"
echo ""

read -p "Select output (1-6): " choice

case $choice in
    1)
        echo "Switching to HDMI Output 1..."
        # Users should replace these with their actual sink names
        # Run 'pactl list sinks short' to get your sink names
        pactl set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo 2>/dev/null || echo "Sink not found - please update script with your sink name"
        echo "Testing audio..."
        paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null || echo "Audio test failed"
        ;;
    2)
        echo "Switching to HDMI Output 2..."
        pactl set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo-extra1 2>/dev/null || echo "Sink not found - please update script with your sink name"
        echo "Testing audio..."
        paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null || echo "Audio test failed"
        ;;
    3)
        echo "Switching to DisplayPort/Other HDMI..."
        pactl set-default-sink alsa_output.pci-0000_00_14.2.hdmi-stereo 2>/dev/null || echo "Sink not found - please update script with your sink name"
        echo "Testing audio..."
        paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null || echo "Audio test failed"
        ;;
    4)
        echo "Switching to USB Audio Device..."
        pactl set-default-sink alsa_output.usb-Blue_Microphones_Yeti_Stereo_Microphone_REV8-00.analog-stereo 2>/dev/null || echo "Sink not found - please update script with your sink name"
        echo "Testing audio..."
        paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null || echo "Audio test failed"
        ;;
    5)
        echo "Available sinks:"
        pactl list sinks short
        echo ""
        echo "To customize this script, replace the sink names in the script above"
        echo "with your actual sink names from this list"
        ;;
    6)
        echo "Testing current output..."
        paplay /usr/share/sounds/freedesktop/stereo/bell.oga 2>/dev/null || echo "Audio test failed"
        echo "Did you hear the bell sound?"
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "Current default sink:"
pactl get-default-sink
echo ""
echo "Volume:"
pactl get-sink-volume @DEFAULT_SINK@
echo "Mute status:"
pactl get-sink-mute @DEFAULT_SINK@
