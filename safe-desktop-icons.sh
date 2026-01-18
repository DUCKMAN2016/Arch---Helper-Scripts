#!/bin/bash

if [ "$EUID" -eq 0 ]; then
    echo "Error: This script should not be run as root. Run it as your regular user."
    exit 1
fi

# Safe Desktop Icon Position Management
# This script saves/restores desktop icon positions WITHOUT restarting plasmashell

PLASMA_CONFIG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
BACKUP_DIR="$HOME/.config/desktop-icon-backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🖥️  Safe Desktop Icon Position Manager${NC}"
echo "=================================="

# Create backup directory
mkdir -p "$BACKUP_DIR"

save_positions() {
    echo -e "${GREEN}💾 Saving current desktop icon positions...${NC}"
    
    # Backup the entire plasma config
    cp "$PLASMA_CONFIG" "$BACKUP_DIR/plasma-desktop-backup-$TIMESTAMP.conf"
    
    # Extract just the position data
    if [ -f "$PLASMA_CONFIG" ]; then
        # Extract Containment positions
        grep -A 100 "\[Containments\]" "$PLASMA_CONFIG" | grep -B 100 "\[Containments\]\|\[Applets\]" | grep -E "(position|Alignment|itemIndex)" > "$BACKUP_DIR/positions-$TIMESTAMP.txt"
        
        echo -e "${GREEN}✓ Positions saved to backup-$TIMESTAMP.conf${NC}"
        echo -e "${GREEN}✓ Position data extracted to positions-$TIMESTAMP.txt${NC}"
        
        # Create a simple reference file
        echo "# Desktop Icon Position Backup" > "$BACKUP_DIR/desktop_positions_$TIMESTAMP.md"
        echo "**Created:** $(date)" >> "$BACKUP_DIR/desktop_positions_$TIMESTAMP.md"
        echo "**Backup File:** plasma-desktop-backup-$TIMESTAMP.conf" >> "$BACKUP_DIR/desktop_positions_$TIMESTAMP.md"
        echo "" >> "$BACKUP_DIR/desktop_positions_$TIMESTAMP.md"
        echo "## Restoration Instructions:" >> "$BACKUP_DIR/desktop_positions_$TIMESTAMP.md"
        echo "1. Copy the backup file to: $PLASMA_CONFIG" >> "$BACKUP_DIR/desktop_positions_$TIMESTAMP.md"
        echo "2. Logout and login again (or restart plasmashell)" >> "$BACKUP_DIR/desktop_positions_$TIMESTAMP.md"
        echo "" >> "$BACKUP_DIR/desktop_positions_$TIMESTAMP.md"
        
        echo -e "${GREEN}✓ Documentation created: desktop_positions_$TIMESTAMP.md${NC}"
    else
        echo -e "${RED}❌ Plasma config file not found: $PLASMA_CONFIG${NC}"
        return 1
    fi
}

restore_positions() {
    echo -e "${GREEN}🔄 Restoring desktop icon positions...${NC}"
    
    # List available backups
    echo ""
    echo "Available backups:"
    echo "=================="
    ls -1 "$BACKUP_DIR"/plasma-desktop-backup-*.conf 2>/dev/null | while read -r file; do
        basename=$(basename "$file")
        timestamp=$(echo "$basename" | sed 's/plasma-desktop-backup-\(.*\)\.conf/\1/')
        echo "  $timestamp"
    done
    echo "=================="
    
    echo -n "Enter backup timestamp (or 'latest' for most recent): "
    read -r backup_choice
    
    if [ "$backup_choice" = "latest" ]; then
        # Get the most recent backup
        latest_backup=$(ls -t "$BACKUP_DIR"/plasma-desktop-backup-*.conf 2>/dev/null | head -1)
        if [ -n "$latest_backup" ]; then
            backup_file="$latest_backup"
            echo -e "${BLUE}Using latest backup: $(basename "$backup_file")${NC}"
        else
            echo -e "${RED}❌ No backups found!${NC}"
            return 1
        fi
    else
        backup_file="$BACKUP_DIR/plasma-desktop-backup-$backup_choice.conf"
    fi
    
    if [ -f "$backup_file" ]; then
        echo -e "${YELLOW}⚠️  This will replace your current desktop layout.${NC}"
        echo -n "Are you sure you want to continue? (y/N): "
        read -r confirm
        
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            # Create a backup of current config before restoring
            cp "$PLASMA_CONFIG" "$BACKUP_DIR/plasma-desktop-backup-before-restore-$TIMESTAMP.conf"
            
            # Restore the backup
            cp "$backup_file" "$PLASMA_CONFIG"
            
            echo -e "${GREEN}✓ Desktop positions restored from backup${NC}"
            echo -e "${YELLOW}📝 Current positions backed up to: plasma-desktop-backup-before-restore-$TIMESTAMP.conf${NC}"
            echo ""
            echo -e "${BLUE}🔄 To apply changes, you need to restart Plasma:${NC}"
            echo "  1. Press Ctrl+Alt+F2 to switch to a TTY"
            echo "  2. Login and run: kquitapp5 plasmashell && plasmashell"
            echo "  3. Or simply logout and login again"
            echo ""
            echo -n "Would you like to restart Plasma now? (y/N): "
            read -r restart_plasma
            
            if [[ "$restart_plasma" =~ ^[Yy]$ ]]; then
                echo -e "${BLUE}Restarting Plasma...${NC}"
                kquitapp5 plasmashell && plasmashell &
                echo -e "${GREEN}✓ Plasma restarted${NC}"
            fi
        else
            echo -e "${YELLOW}❌ Restoration cancelled${NC}"
        fi
    else
        echo -e "${RED}❌ Backup file not found: $backup_file${NC}"
        return 1
    fi
}

list_backups() {
    echo ""
    echo "Available Desktop Position Backups:"
    echo "=================================="
    
    if [ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        for file in "$BACKUP_DIR"/plasma-desktop-backup-*.conf; do
            if [ -f "$file" ]; then
                basename=$(basename "$file")
                timestamp=$(echo "$basename" | sed 's/plasma-desktop-backup-\(.*\)\.conf/\1/')
                file_size=$(du -h "$file" | cut -f1)
                mod_date=$(stat -c %y "$file" | cut -d' ' -f1,2 | cut -d'.' -f1)
                
                echo "  📅 $timestamp"
                echo "     📁 $basename"
                echo "     📊 Size: $file_size"
                echo "     🕒 Modified: $mod_date"
                echo ""
            fi
        done
    else
        echo "  No backups found."
    fi
    echo "=================================="
}

cleanup_old_backups() {
    echo -e "${BLUE}🧹 Cleaning up old backups...${NC}"
    
    # Count current backups
    backup_count=$(ls -1 "$BACKUP_DIR"/plasma-desktop-backup-*.conf 2>/dev/null | wc -l)
    echo "Current backup count: $backup_count"
    
    if [ "$backup_count" -gt 10 ]; then
        echo -e "${YELLOW}More than 10 backups found. Removing oldest backups...${NC}"
        
        # List backups by date and remove oldest ones (keep only 10 most recent)
        ls -t "$BACKUP_DIR"/plasma-desktop-backup-*.conf | tail -n +11 | while read -r old_backup; do
            echo -e "${YELLOW}Removing old backup: $(basename "$old_backup")${NC}"
            rm "$old_backup"
            
            # Also remove corresponding position files
            base_name=$(basename "$old_backup" .conf)
            rm -f "$BACKUP_DIR/positions-${base_name#plasma-desktop-backup-}.txt"
            rm -f "$BACKUP_DIR/desktop_positions_${base_name#plasma-desktop-backup-}.md"
        done
        
        echo -e "${GREEN}✓ Cleanup completed${NC}"
    else
        echo -e "${GREEN}✓ Backup count is acceptable (≤10)${NC}"
    fi
}

show_help() {
    echo ""
    echo "Safe Desktop Icon Position Manager"
    echo "=================================="
    echo ""
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  save      Save current desktop icon positions"
    echo "  restore   Restore desktop icon positions from backup"
    echo "  list      List all available backups"
    echo "  cleanup   Clean up old backups (keep only 10 most recent)"
    echo "  help      Show this help message"
    echo ""
    echo "Interactive mode (no arguments):"
    echo "  Run the script without arguments for an interactive menu"
    echo ""
    echo "Files are stored in: $BACKUP_DIR"
    echo ""
}

# Interactive menu
show_menu() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           Safe Desktop Icon Position Manager                ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║  1. Save Current Positions                                    ║"
    echo "║  2. Restore Positions                                        ║"
    echo "║  3. List All Backups                                         ║"
    echo "║  4. Clean Up Old Backups                                     ║"
    echo "║  5. Help                                                     ║"
    echo "║  x/q. Exit                                                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
}

# Main script logic
main() {
    # Check if we're in a KDE Plasma environment
    if [ -z "$KDE_SESSION_VERSION" ]; then
        echo -e "${YELLOW}⚠️  Warning: This script is designed for KDE Plasma desktop${NC}"
        echo -e "${YELLOW}   It may not work properly in other desktop environments${NC}"
        echo ""
    fi
    
    # Check if plasma config exists
    if [ ! -f "$PLASMA_CONFIG" ]; then
        echo -e "${RED}❌ Plasma config file not found: $PLASMA_CONFIG${NC}"
        echo -e "${RED}   Are you sure you're running KDE Plasma?${NC}"
        exit 1
    fi
    
    # Command line argument handling
    case "${1:-}" in
        save)
            save_positions
            ;;
        restore)
            restore_positions
            ;;
        list)
            list_backups
            ;;
        cleanup)
            cleanup_old_backups
            ;;
        help|--help|-h)
            show_help
            ;;
        "")
            # Interactive mode
            while true; do
                show_menu
                echo -n "Select an option (1-5, x, q): "
                read -r choice
                
                case $choice in
                    1)
                        save_positions
                        ;;
                    2)
                        restore_positions
                        ;;
                    3)
                        list_backups
                        ;;
                    4)
                        cleanup_old_backups
                        ;;
                    5)
                        show_help
                        ;;
                    x|q)
                        echo -e "${GREEN}👋 Goodbye!${NC}"
                        exit 0
                        ;;
                    *)
                        echo -e "${RED}❌ Invalid option. Please select 1-5, x, or q.${NC}"
                        ;;
                esac
                
                echo ""
                echo -n "Press Enter to continue..."
                read -r
            done
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
}

# Start the script
main "$@"
