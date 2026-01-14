# KDE Desktop Tools

A collection of useful scripts for KDE Plasma desktop management and automation. These scripts help you customize your desktop experience with easy-to-use tools for common tasks.

## 🚀 Features

### 🖥️ Desktop Peek Suite
Clean up your desktop instantly with one click! Perfect for presentations, screen recordings, or just a tidy workspace.

- **One-click toggle**: Hide/show desktop icons and minimize/restore all windows
- **Visual feedback**: Desktop notifications show current state
- **Multi-monitor support**: Works across all connected displays
- **Safe operation**: Files are moved to hidden directory, never deleted

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

## 📦 Installation

### Quick Install
```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/kde-desktop-tools.git
cd kde-desktop-tools

# Make all scripts executable
chmod +x */*.sh

# Run the installer (optional)
./install.sh
```

### Manual Install
1. Download the scripts you want
2. Make them executable: `chmod +x script_name.sh`
3. Run them from your terminal or create desktop launchers

## 🎯 Usage

### Desktop Peek (Most Popular)
```bash
# One-click desktop cleanup with notifications
./desktop-peek/desktop_peek_unified.sh

# Or use individual scripts
./desktop-peek/hide_desktop_icons.sh
./desktop-peek/show_desktop_icons.sh
./desktop-peek/toggle_desktop_peek.sh
```

### System Control Panel
```bash
./system-controls/system_control_panel.sh
```
*Note: You'll need to customize the paths in this script for your setup.*

### Utilities
```bash
# Switch audio output
./utilities/switch-audio.sh

# Center a window (useful for games/emulators)
./utilities/center-mame-window.sh

# Toggle desktop icons
./utilities/toggle_desktop_icons.sh

# Refresh desktop
./utilities/refresh-desktop.sh
```

## 🔧 Requirements

- **KDE Plasma** (tested on Plasma 6.x)
- **Bash** shell
- **Standard utilities**: `wmctrl`, `xdotool`, `notify-send`, `kdialog`

Install dependencies:
```bash
# Ubuntu/Debian
sudo apt install wmctrl xdotool libnotify-bin kdialog

# Arch/CachyOS
sudo pacman -S wmctrl xdotool libnotify kde-cli-tools

# Fedora
sudo dnf install wmctrl xdotool libnotify kde-cli-tools
```

## 🎨 Desktop Integration

### Create Desktop Launchers
1. Right-click your desktop → "Create New → Link to Application"
2. Set the command to the script path
3. Choose an icon and name
4. Drag to your taskbar for quick access

### Keyboard Shortcuts
1. System Settings → Shortcuts → Custom Shortcuts
2. Add new shortcuts pointing to your favorite scripts
3. Assign key combinations

## 📁 Repository Structure

```
kde-desktop-tools/
├── desktop-peek/          # Desktop cleanup tools
│   ├── desktop_peek_unified.sh    # ⭐ One-click toggle (recommended)
│   ├── toggle_desktop_peek.sh     # Toggle without notifications
│   ├── hide_desktop_icons.sh      # Hide icons only
│   └── show_desktop_icons.sh      # Show icons only
├── system-controls/       # GUI control panel
│   └── system_control_panel.sh    # Floating control center
├── utilities/            # Helper scripts
│   ├── switch-audio.sh            # Audio output switcher
│   ├── center-mame-window.sh      # Window positioning
│   ├── toggle_desktop_icons.sh    # Icon visibility toggle
│   └── refresh-desktop.sh         # Desktop refresh
├── install.sh           # Automated installer
├── README.md           # This file
└── LICENSE             # MIT License
```

## 🎬 Perfect For

- **Presentations**: Instantly clean desktop before screen sharing
- **Content Creators**: Clean background for recordings
- **Productivity**: Quick access to system controls
- **Customization**: Personalize your KDE experience
- **Gaming**: Window positioning and desktop management

## 🔧 Customization

### Desktop Peek
- **Change hidden directory**: Edit `HIDDEN_DIR` variable
- **Modify notifications**: Change `notify-send` commands
- **Keyboard shortcut**: Replace `Super+d` with your preferred shortcut

### System Control Panel
- **Add custom actions**: Edit the menu options in the script
- **Change commands**: Replace TODO comments with your preferred commands
- **Modify appearance**: Adjust `--geometry` and menu items

## 🐛 Troubleshooting

### Scripts Not Working
1. Ensure scripts are executable: `chmod +x script_name.sh`
2. Check dependencies are installed
3. Run as regular user (not root)

### Desktop Peek Issues
- **Icons not hiding**: Check that `~/Desktop` exists
- **Windows not minimizing**: Verify `Super+d` shortcut is assigned in KDE settings
- **Notifications not showing**: Install `libnotify-bin` or equivalent

### System Control Panel
- **Window not appearing**: Install `kdialog`
- **Commands not working**: Customize the TODO sections with your preferred commands

## 🤝 Contributing

Feel free to:
- Report issues
- Suggest improvements
- Submit pull requests
- Share your customizations

## 📄 License

MIT License - Feel free to use, modify, and distribute these scripts.

## 🌟 Show Your Support

If you find these tools useful:
- ⭐ Star this repository
- 🐛 Report issues
- 💡 Suggest features
- 🔄 Share with others

---

**Made with ❤️ for the KDE Plasma community**
