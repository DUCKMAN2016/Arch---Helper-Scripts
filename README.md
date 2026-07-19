# KDE Desktop Tools

A collection of useful scripts for KDE Plasma desktop management and automation. These scripts help you customize your desktop experience with easy-to-use tools for common tasks.

## 🚀 Features

### 🖥️ Desktop Peek Suite
Clean up your desktop instantly with one click! Perfect for presentations, screen recordings, or just a tidy workspace.
- One-click toggle: Hide/show desktop icons and minimize/restore all windows
- Visual feedback: Desktop notifications show current state
- Multi-monitor support: Works across all connected displays
- Safe operation: Files are moved to hidden directory, never deleted

### 🎛️ System Control Panel
A floating GUI panel for quick access to common system controls:
- Power management (shutdown, reboot, logout)
- Desktop controls (toggle icons, refresh, peek mode)
- Clean, intuitive interface with emoji icons
- Persistent window that stays open until you close it

### 🛠️ Utility Scripts
- **Audio Switcher**: Quickly switch between audio output devices
- **Window Center**: Center windows (great for gaming/emulators)
- **Icon Toggle**: Show/hide desktop icons
- **Desktop Refresh**: Refresh the desktop display
- **App Toggle**: Minimize/restore all open applications

## 📦 Installation

### Quick Install
```bash
# Clone the repository
git clone https://github.com/DUCKMAN2016/Arch---Helper-Scripts.git
cd Arch---Helper-Scripts

# Run the installer
./install.sh
```

### Manual Install
```bash
# Copy scripts to local bin
mkdir -p ~/.local/bin/kde-desktop-tools
cp -r * ~/.local/bin/kde-desktop-tools/

# Make scripts executable
chmod +x ~/.local/bin/kde-desktop-tools/**/*.sh

# Add to PATH (add to ~/.bashrc or ~/.zshrc)
export PATH="$HOME/.local/bin/kde-desktop-tools:$PATH"
```

## 🎯 Usage

### Desktop Peek (Most Popular)
```bash
# One-click desktop cleanup
./desktop-peek/desktop_peek_unified.sh

# Or use the desktop launcher after installation
```

### System Control Panel
```bash
# Launch the GUI control panel
./system-controls/system_control_panel.sh

# Customize paths in the script to match your setup
```

### Utilities
```bash
# Switch audio outputs
./utilities/switch-audio.sh

# Center a window (customize WINDOW_NAME)
./utilities/center-mame-window.sh

# Toggle desktop icons
./utilities/toggle_desktop_icons.sh

# Refresh desktop
./utilities/refresh-desktop.sh

# Toggle open applications
./utilities/toggle_open_apps.sh
```

## 🔧 Requirements

### System Requirements
- KDE Plasma desktop environment
- Linux/Unix-based operating system
- Bash shell

### Dependencies
The installer automatically checks for these dependencies:
- `wmctrl` - Window management
- `xdotool` - Window automation
- `notify-send` - Desktop notifications (sends installation status alerts)
- `kdialog` - KDE dialogs

Upon completion, the installer will send a system desktop notification (using `notify-send` if available) informing you whether the installation succeeded fully or if there are missing dependencies.

**Install dependencies on Arch/CachyOS:**
```bash
sudo pacman -S wmctrl xdotool libnotify kde-cli-tools
```

**Install dependencies on Ubuntu/Debian:**
```bash
sudo apt install wmctrl xdotool libnotify-bin kde-cli-tools
```

## 📁 Repository Structure

```
kde-desktop-tools/
├── desktop-peek/              # Desktop cleanup tools
│   └── desktop_peek_unified.sh    # ⭐ One-click toggle (recommended)
├── system-controls/           # GUI control panel
│   └── system_control_panel.sh     # Floating control center
├── utilities/                 # Helper scripts
│   ├── switch-audio.sh            # Audio output switcher
│   ├── center-mame-window.sh      # Window positioning
│   ├── toggle_desktop_icons.sh    # Icon visibility toggle
│   ├── refresh-desktop.sh         # Desktop refresh
│   └── toggle_open_apps.sh        # Window minimizer
├── install.sh                 # Automated installer
├── README.md                  # This file
└── LICENSE                    # MIT License
```

## 🎨 Customization

### Audio Switcher
Edit `utilities/switch-audio.sh` to add your specific audio devices:
```bash
# Run 'pactl list sinks short' to get your device names
# Replace the example sink names with your actual devices
```

### Window Center
Edit `utilities/center-mame-window.sh`:
```bash
# Set WINDOW_NAME to match your target window
WINDOW_NAME="YourWindowName"  # e.g., "MAME", "DOSBox", "RetroArch"
```

### System Control Panel
Edit `system-controls/system_control_panel.sh`:
```bash
# Update the TODO sections with your actual script paths
# Example: ~/Scripts/toggle_open_apps.sh
```

## 🐛 Troubleshooting

### Scripts Not Working
1. **Check permissions**: Make sure scripts are executable (`chmod +x script.sh`)
2. **Check dependencies**: Run the installer to verify all dependencies are installed
3. **Check KDE version**: These scripts are tested with KDE Plasma 5.x and 6.x

### Desktop Peek Issues
1. **Icons not hiding**: Check that your Desktop folder is at `~/Desktop`
2. **Windows not minimizing**: Ensure `xdotool` is installed and working
3. **No notifications**: Install `libnotify` for desktop notifications

### Audio Switcher Problems
1. **Sink not found**: Run `pactl list sinks short` and update script with your sink names
2. **No audio test**: Ensure `/usr/share/sounds/freedesktop/stereo/bell.oga` exists

### Window Center Issues
1. **Window not found**: Update `WINDOW_NAME` variable to match your target window
2. **Permission denied**: Make sure script can access X11 display

## 🤝 Contributing

Contributions are welcome! Please:

1. **Test thoroughly** on multiple systems
2. **Remove personal information** from paths and configurations
3. **Document changes** in script comments
4. **Follow existing style** (colored output, error handling)
5. **Include help documentation**

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌟 Show Your Support

If you find these tools helpful:
- ⭐ Star this repository
- 🐛 Report issues or feature requests
- 🔄 Fork and contribute improvements
- 📢 Share with others who might benefit

## 🎬 Perfect For

- **Presentations**: Instantly clean desktop before screen sharing
- **Content Creators**: Clean background for recordings
- **Productivity**: Quick access to system controls
- **Customization**: Personalize your KDE experience
- **Gaming**: Window positioning and desktop management

---

*Made with ❤️ for the KDE Plasma community*
