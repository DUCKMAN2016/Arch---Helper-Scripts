#!/bin/bash
# Audio output switcher script
# Switches between different audio outputs

echo "=== Audio Output Switcher ==="
echo ""
echo "Current default sink:"
pactl get-default-sink
echo ""

echo "Available audio outputs:"
echo "1) GPU HDMI 1 (alsa_output.pci-0000_01_00.1.hdmi-stereo)"
echo "2) GPU HDMI 2 (alsa_output.pci-0000_01_00.1.hdmi-stereo-extra1) [Current]"
echo "3) Motherboard HDMI (alsa_output.pci-0000_00_14.2.hdmi-stereo)"
echo "4) Blue Yeti Analog (alsa_output.usb-Blue_Microphones_Yeti_Stereo_Microphone_REV8-00.analog-stereo)"
echo "5) List all available sinks"
echo "6) Test current output"
echo ""

read -p "Select output (1-6): " choice

case $choice in
    1)
        echo "Switching to GPU HDMI 1..."
        pactl set-card-profile alsa_card.pci-0000_01_00.1 output:hdmi-stereo
        pactl set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo
        echo "Testing audio..."
        paplay /usr/share/sounds/freedesktop/stereo/bell.oga
        ;;
    2)
        echo "Switching to GPU HDMI 2..."
        pactl set-card-profile alsa_card.pci-0000_01_00.1 output:hdmi-stereo-extra1
        pactl set-default-sink alsa_output.pci-0000_01_00.1.hdmi-stereo-extra1
        echo "Testing audio..."
        paplay /usr/share/sounds/freedesktop/stereo/bell.oga
        ;;
    3)
        echo "Switching to Motherboard HDMI..."
        pactl set-default-sink alsa_output.pci-0000_00_14.2.hdmi-stereo
        echo "Testing audio..."
        paplay /usr/share/sounds/freedesktop/stereo/bell.oga
        ;;
    4)
        echo "Switching to Blue Yeti Analog..."
        pactl set-default-sink alsa_output.usb-Blue_Microphones_Yeti_Stereo_Microphone_REV8-00.analog-stereo
        echo "Testing audio..."
        paplay /usr/share/sounds/freedesktop/stereo/bell.oga
        ;;
    5)
        echo "Available sinks:"
        pactl list sinks short
        ;;
    6)
        echo "Testing current output..."
        paplay /usr/share/sounds/freedesktop/stereo/bell.oga
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
