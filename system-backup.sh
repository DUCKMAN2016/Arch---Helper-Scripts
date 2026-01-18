#!/bin/bash

# Arch Linux System Backup Script
# Comprehensive backup of system configurations and user data

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Backup configuration
BACKUP_BASE_DIR="${SYSTEM_BACKUP_DIR:-$HOME/system-backups}"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR="$BACKUP_BASE_DIR/backup-$TIMESTAMP"
LOG_FILE="$BACKUP_DIR/backup.log"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1" | tee -a "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    print_error "This script should not be run as root. Please run as a regular user."
    exit 1
fi

echo -e "${BLUE}🔧 Arch Linux System Backup Tool${NC}"
echo "=================================="

# Create backup directory
mkdir -p "$BACKUP_DIR"
print_status "Created backup directory: $BACKUP_DIR"

# Initialize log
log_message "=== System Backup Started ==="
log_message "Backup directory: $BACKUP_DIR"

# Function to backup configuration files
backup_configs() {
    print_status "Backing up system configurations..."
    
    # Create config backup directory
    CONFIG_BACKUP="$BACKUP_DIR/configs"
    mkdir -p "$CONFIG_BACKUP"
    
    # List of configuration files to backup
    config_files=(
        "$HOME/.config/kdeglobals"
        "$HOME/.config/kwinrc"
        "$HOME/.config/plasmarc"
        "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
        "$HOME/.config/konsolerc"
        "$HOME/.config/katerc"
        "$HOME/.config/gtk-3.0/settings.ini"
        "$HOME/.config/gtk-4.0/settings.ini"
        "/etc/fstab"
        "/etc/pacman.conf"
        "/etc/makepkg.conf"
    )
    
    for config_file in "${config_files[@]}"; do
        if [ -f "$config_file" ]; then
            # Create directory structure in backup
            backup_path="$CONFIG_BACKUP$(dirname "$config_file")"
            mkdir -p "$backup_path"
            
            if cp "$config_file" "$backup_path/" 2>/dev/null; then
                print_success "Backed up: $config_file"
            else
                print_warning "Could not backup: $config_file (may need sudo)"
            fi
        fi
    done
}

# Function to backup application configurations
backup_app_configs() {
    print_status "Backing up application configurations..."
    
    APP_CONFIG_BACKUP="$BACKUP_DIR/app-configs"
    mkdir -p "$APP_CONFIG_BACKUP"
    
    # List of application config directories to backup
    app_dirs=(
        "$HOME/.config/Code"
        "$HOME/.config/kate"
        "$HOME/.config/VirtualBox"
        "$HOME/.config/filezilla"
        "$HOME/.config/remmina"
        "$HOME/.config/doublecmd"
        "$HOME/.config/cool-retro-term"
        "$HOME/.config/konsole"
        "$HOME/.config/krita"
        "$HOME/.config/qBittorrent"
        "$HOME/.config/shotcut"
        "$HOME/.config/soundconverter"
        "$HOME/.config/octopi"
        "$HOME/.config/nordvpn-gui"
        "$HOME/.config/obs-studio"
    )
    
    for app_dir in "${app_dirs[@]}"; do
        if [ -d "$app_dir" ]; then
            if cp -r "$app_dir" "$APP_CONFIG_BACKUP/" 2>/dev/null; then
                print_success "Backed up app config: $(basename "$app_dir")"
            else
                print_warning "Could not backup app config: $app_dir"
            fi
        fi
    done
}

# Function to backup user data directories
backup_user_data() {
    print_status "Backing up user data directories..."
    
    USER_DATA_BACKUP="$BACKUP_DIR/user-data"
    mkdir -p "$USER_DATA_BACKUP"
    
    # List of user data directories to backup
    user_dirs=(
        "$HOME/Documents"
        "$HOME/Pictures"
        "$HOME/Music"
        "$HOME/Videos"
        "$HOME/Downloads"
        "$HOME/.local/share/applications"
        "$HOME/.local/share/plasma"
        "$HOME/.local/share/icons"
    )
    
    for user_dir in "${user_dirs[@]}"; do
        if [ -d "$user_dir" ]; then
            # Only backup directory structure and small files
            if rsync -av --include="*/" --include="*.txt" --include="*.md" --include="*.conf" --include="*.json" --exclude="*" "$user_dir/" "$USER_DATA_BACKUP/$(basename "$user_dir")/" 2>/dev/null; then
                print_success "Backed up user data: $(basename "$user_dir")"
            else
                print_warning "Could not backup user data: $user_dir"
            fi
        fi
    done
}

# Function to backup installed packages
backup_packages() {
    print_status "Backing up installed packages..."
    
    PACKAGES_BACKUP="$BACKUP_DIR/packages"
    mkdir -p "$PACKAGES_BACKUP"
    
    # Backup official packages
    if pacman -Qqe > "$PACKAGES_BACKUP/official-packages.txt" 2>/dev/null; then
        print_success "Backed up official packages list"
    else
        print_warning "Could not backup official packages list"
    fi
    
    # Backup AUR packages
    if pacman -Qqme > "$PACKAGES_BACKUP/aur-packages.txt" 2>/dev/null; then
        print_success "Backed up AUR packages list"
    else
        print_warning "Could not backup AUR packages list"
    fi
    
    # Backup foreign packages (alternative method)
    if pacman -Qqm > "$PACKAGES_BACKUP/foreign-packages.txt" 2>/dev/null; then
        print_success "Backed up foreign packages list"
    fi
    
    # Create package installation script
    cat > "$PACKAGES_BACKUP/restore-packages.sh" << 'EOF'
#!/bin/bash
# Package Restoration Script

echo "Restoring packages from backup..."

# Restore official packages
if [ -f "official-packages.txt" ]; then
    echo "Installing official packages..."
    sudo pacman -S --needed - < official-packages.txt
fi

# Restore AUR packages (requires yay or paru)
if [ -f "aur-packages.txt" ]; then
    echo "Installing AUR packages..."
    if command -v yay &> /dev/null; then
        yay -S --needed - < aur-packages.txt
    elif command -v paru &> /dev/null; then
        paru -S --needed - < aur-packages.txt
    else
        echo "Warning: No AUR helper found. Please install yay or paru first."
    fi
fi

echo "Package restoration completed!"
EOF
    
    chmod +x "$PACKAGES_BACKUP/restore-packages.sh"
    print_success "Created package restoration script"
}

# Function to backup system information
backup_system_info() {
    print_status "Backing up system information..."
    
    SYS_INFO_BACKUP="$BACKUP_DIR/system-info"
    mkdir -p "$SYS_INFO_BACKUP"
    
    # System information
    uname -a > "$SYS_INFO_BACKUP/uname.txt"
    lsb_release -a > "$SYS_INFO_BACKUP/lsb-release.txt" 2>/dev/null || echo "No lsb_release available" > "$SYS_INFO_BACKUP/lsb-release.txt"
    cat /etc/os-release > "$SYS_INFO_BACKUP/os-release.txt"
    
    # Hardware information
    lspci > "$SYS_INFO_BACKUP/lspci.txt"
    lsusb > "$SYS_INFO_BACKUP/lsusb.txt"
    lsblk > "$SYS_INFO_BACKUP/lsblk.txt"
    
    # Network information
    ip addr > "$SYS_INFO_BACKUP/ip-addr.txt"
    ip route > "$SYS_INFO_BACKUP/ip-route.txt"
    
    # Environment variables
    env > "$SYS_INFO_BACKUP/environment.txt"
    
    print_success "Backed up system information"
}

# Function to create backup summary
create_summary() {
    print_status "Creating backup summary..."
    
    # Calculate backup size
    backup_size=$(du -sh "$BACKUP_DIR" | cut -f1)
    
    # Create summary file
    cat > "$BACKUP_DIR/README.md" << EOF
# System Backup Summary

**Backup Date:** $(date)
**Backup Size:** $backup_size
**Backup Directory:** $BACKUP_DIR

## Contents

### 1. System Configurations (\`configs/\`)
- KDE Plasma configuration files
- System configuration files
- GTK settings

### 2. Application Configurations (\`app-configs/\`)
- Development tools (VS Code, Kate)
- Virtualization (VirtualBox)
- Network tools (FileZilla, Remmina)
- Media tools (Krita, ShotCut)
- System tools (Octopi, NordVPN)

### 3. User Data (\`user-data/\`)
- Document directory structure
- Configuration files
- Desktop integration files

### 4. Package Information (\`packages/\`)
- List of officially installed packages
- List of AUR packages
- Package restoration script

### 5. System Information (\`system-info/\`)
- Hardware information
- Network configuration
- Environment variables

## Restoration

### 1. Restore Packages
\`\`\`bash
cd packages/
./restore-packages.sh
\`\`\`

### 2. Restore Configurations
\`\`\`bash
# Copy configuration files back to their original locations
cp -r configs/* ~/
cp -r app-configs/* ~/.config/
\`\`\`

### 3. Restore User Data
\`\`\`bash
# Copy user data back to home directory
cp -r user-data/* ~/
\`\`\`

## Notes

- This backup does not include large media files or application data
- Some system files may require sudo to restore
- Test restoration on a test system first if possible
- Keep this backup in a safe location

---

*Generated by Arch Linux System Backup Tool*
EOF
    
    print_success "Created backup summary: $BACKUP_DIR/README.md"
}

# Function to clean old backups
cleanup_old_backups() {
    print_status "Cleaning up old backups..."
    
    # Remove backups older than 30 days (keep only 10 most recent)
    find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "backup-*" -mtime +30 -exec rm -rf {} \; 2>/dev/null || true
    
    # If more than 10 backups exist, remove oldest ones
    backup_count=$(find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "backup-*" | wc -l)
    if [ "$backup_count" -gt 10 ]; then
        find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "backup-*" -printf "%T@ %p\n" | sort -n | head -n -$backup_count | cut -d' ' -f2- | xargs rm -rf 2>/dev/null || true
    fi
    
    print_success "Cleaned up old backups"
}

# Main backup function
perform_backup() {
    print_status "Starting comprehensive system backup..."
    
    backup_configs
    backup_app_configs
    backup_user_data
    backup_packages
    backup_system_info
    create_summary
    cleanup_old_backups
    
    # Calculate final backup size
    final_size=$(du -sh "$BACKUP_DIR" | cut -f1)
    
    echo ""
    echo "=================================="
    print_success "System backup completed successfully!"
    echo "📁 Location: $BACKUP_DIR"
    echo "📊 Size: $final_size"
    echo "📋 Summary: $BACKUP_DIR/README.md"
    echo "=================================="
    
    log_message "=== System Backup Completed ==="
}

# Function to show help
show_help() {
    echo ""
    echo "Arch Linux System Backup Tool"
    echo "============================"
    echo ""
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  backup    Perform full system backup"
    echo "  cleanup   Clean up old backups"
    echo "  help      Show this help message"
    echo ""
    echo "Environment Variables:"
    echo "  SYSTEM_BACKUP_DIR    Override backup directory (default: ~/system-backups)"
    echo ""
    echo "Backup Contents:"
    echo "  - System configurations"
    echo "  - Application settings"
    echo "  - Package lists"
    echo "  - System information"
    echo "  - User data structure"
    echo ""
}

# Main script logic
case "${1:-backup}" in
    backup)
        perform_backup
        ;;
    cleanup)
        cleanup_old_backups
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}❌ Unknown option: $1${NC}"
        show_help
        exit 1
        ;;
esac
