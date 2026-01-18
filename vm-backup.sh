#!/bin/bash

# VirtualBox VM Backup Script
# Supports cloning and OVA export with VM selection

# Ensure we're running in bash for proper signal handling
if [ -z "$BASH_VERSION" ]; then
    echo "Re-executing with bash for proper compatibility..."
    exec bash "$0" "$@"
fi

# Default backup directory - can be overridden by environment variable
BACKUP_DIR="${VM_BACKUP_DIR:-$HOME/VM-Backups}"
LOG_FILE="$BACKUP_DIR/backup.log"
DATE=$(date +%Y%m%d_%H%M%S)

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Function to log messages
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to display VM list
list_vms() {
    echo "Available VirtualBox VMs:"
    echo "========================"
    VBoxManage list vms | nl -nln | while read num line; do
        vm_name=$(echo "$line" | cut -d'"' -f2)
        vm_uuid=$(echo "$line" | cut -d'{' -f2 | cut -d'}' -f1)
        state=$(VBoxManage showvminfo "$vm_name" 2>/dev/null | grep "State" | cut -d':' -f2 | xargs)
        printf "%2d. %-25s %s\n" "$num" "$vm_name" "($state)"
    done
    echo "========================"
}

# Function to get VM name by number
get_vm_name() {
    local vm_num=$1
    VBoxManage list vms | sed -n "${vm_num}p" | cut -d'"' -f2
}

# Function to backup VM as clone
backup_clone() {
    local vm_name=$1
    local clone_name="${vm_name}_clone_$DATE"
    
    log_message "Starting clone backup of VM: $vm_name"
    log_message "Clone name: $clone_name"
    
    # Stop VM if running
    if VBoxManage showvminfo "$vm_name" | grep -q "running"; then
        log_message "Stopping VM: $vm_name"
        VBoxManage controlvm "$vm_name" acpipowerbutton
        sleep 5
        # Force shutdown if still running
        if VBoxManage showvminfo "$vm_name" | grep -q "running"; then
            log_message "Force shutting down VM: $vm_name"
            VBoxManage controlvm "$vm_name" poweroff
            sleep 3
        fi
    fi
    
    # Create clone
    log_message "Creating clone: $clone_name"
    if VBoxManage clonevm "$vm_name" --name "$clone_name" --register; then
        log_message "Successfully created clone: $clone_name"
        
        # Export clone to OVA for portability
        log_message "Exporting clone to OVA: $clone_name.ova"
        if VBoxManage export "$clone_name" -o "$BACKUP_DIR/${clone_name}.ova"; then
            log_message "Successfully exported to: $BACKUP_DIR/${clone_name}.ova"
            
            # Unregister clone (keeping only OVA)
            VBoxManage unregistervm "$clone_name" --delete
            log_message "Unregistered temporary clone: $clone_name"
            
            # Get file sizes
            ova_size=$(du -h "$BACKUP_DIR/${clone_name}.ova" | cut -f1)
            log_message "Backup completed. Size: $ova_size"
            
            echo "✅ Clone backup successful!"
            echo "📁 Location: $BACKUP_DIR/${clone_name}.ova"
            echo "📊 Size: $ova_size"
        else
            log_message "ERROR: Failed to export clone to OVA"
            return 1
        fi
    else
        log_message "ERROR: Failed to create clone"
        return 1
    fi
}

# Function to backup VM as OVA export
backup_ova() {
    local vm_name=$1
    local ova_name="${vm_name}_backup_$DATE"
    
    log_message "Starting OVA export of VM: $vm_name"
    log_message "OVA name: $ova_name.ova"
    
    # Stop VM if running
    if VBoxManage showvminfo "$vm_name" | grep -q "running"; then
        log_message "Stopping VM: $vm_name"
        VBoxManage controlvm "$vm_name" acpipowerbutton
        sleep 5
        # Force shutdown if still running
        if VBoxManage showvminfo "$vm_name" | grep -q "running"; then
            log_message "Force shutting down VM: $vm_name"
            VBoxManage controlvm "$vm_name" poweroff
            sleep 3
        fi
    fi
    
    # Export to OVA
    log_message "Exporting VM to OVA: $ova_name.ova"
    if VBoxManage export "$vm_name" -o "$BACKUP_DIR/${ova_name}.ova"; then
        log_message "Successfully exported to: $BACKUP_DIR/${ova_name}.ova"
        
        # Get file sizes
        ova_size=$(du -h "$BACKUP_DIR/${ova_name}.ova" | cut -f1)
        log_message "OVA backup completed. Size: $ova_size"
        
        echo "✅ OVA backup successful!"
        echo "📁 Location: $BACKUP_DIR/${ova_name}.ova"
        echo "📊 Size: $ova_size"
    else
        log_message "ERROR: Failed to export VM to OVA"
        return 1
    fi
}

# Function to create snapshot
create_snapshot() {
    local vm_name=$1
    local snapshot_name="backup_$DATE"
    
    log_message "Creating snapshot for VM: $vm_name"
    log_message "Snapshot name: $snapshot_name"
    
    if VBoxManage snapshot "$vm_name" take "$snapshot_name" --description "Automated backup snapshot $DATE"; then
        log_message "Successfully created snapshot: $snapshot_name"
        echo "✅ Snapshot created successfully!"
        echo "📸 Snapshot: $snapshot_name"
    else
        log_message "ERROR: Failed to create snapshot"
        return 1
    fi
}

# Function to clean old backups
cleanup_old_backups() {
    local days=${1:-30}
    
    log_message "Cleaning up backups older than $days days"
    
    # Remove old OVA files
    find "$BACKUP_DIR" -name "*.ova" -type f -mtime +$days -exec rm -f {} \;
    
    # Remove old log entries
    find "$BACKUP_DIR" -name "backup.log" -type f -mtime +$days -exec truncate -s 0 {} \;
    
    log_message "Cleanup completed"
}

# Main menu
show_menu() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           VirtualBox VM Backup Tool                          ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║  1. Clone Backup (Recommended)                               ║"
    echo "║  2. OVA Export Backup                                        ║"
    echo "║  3. Create Snapshot                                          ║"
    echo "║  4. List All Backups                                         ║"
    echo "║  5. Clean Old Backups                                        ║"
    echo "║  6. Manage Snapshots                                         ║"
    echo "║  x/q. Exit                                                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
}

# List existing backups
list_backups() {
    echo ""
    echo "Existing Backups:"
    echo "================"
    if [ -d "$BACKUP_DIR" ]; then
        ls -lah "$BACKUP_DIR"/*.ova 2>/dev/null | while read line; do
            echo "$line"
        done
    else
        echo "No backup directory found."
    fi
    echo "================"
}

# Function to manage snapshots
manage_snapshots() {
    echo ""
    echo "Snapshot Management"
    echo "=================="
    
    list_vms
    echo -n "Enter VM number to manage snapshots: "
    read -r vm_num
    
    if [[ "$vm_num" =~ ^[0-9]+$ ]]; then
        vm_name=$(get_vm_name "$vm_num")
        if [ -n "$vm_name" ]; then
            echo ""
            echo "Snapshots for VM: $vm_name"
            echo "========================"
            
            # Get list of snapshots
            snapshots=$(VBoxManage snapshot "$vm_name" list 2>/dev/null)
            if [ -z "$snapshots" ]; then
                echo "No snapshots found for this VM."
                echo "Press Enter to continue..."
                read -r
                return 0
            fi
            
            # Create arrays to store snapshot data
            declare -a snapshot_names
            declare -a snapshot_lines
            line_num=0
            
            # Parse snapshots into arrays
            while IFS= read -r line; do
                if [ -n "$line" ]; then
                    snapshot_lines[$line_num]="$line"
                    snapshot_name=$(echo "$line" | grep -o 'Name: [^(]*' | cut -d' ' -f2- | xargs)
                    snapshot_names[$line_num]="$snapshot_name"
                    echo "$((line_num + 1)). $snapshot_name"
                    ((line_num++))
                fi
            done <<< "$snapshots"
            
            echo "========================"
            
            echo -n "Enter snapshot number to delete (or 0 to cancel): "
            read -r snap_num
            
            if [[ "$snap_num" =~ ^[0-9]+$ ]] && [ "$snap_num" -ne 0 ]; then
                array_index=$((snap_num - 1))
                if [ "$array_index" -ge 0 ] && [ "$array_index" -lt "$line_num" ]; then
                    snapshot_to_delete="${snapshot_names[$array_index]}"
                    if [ -n "$snapshot_to_delete" ]; then
                        echo ""
                        echo "⚠️  WARNING: This will permanently delete snapshot:"
                        echo "   $snapshot_to_delete"
                        echo ""
                        echo -n "Type 'DELETE' to confirm: "
                        read -r confirmation
                        
                        if [ "$confirmation" = "DELETE" ]; then
                            log_message "Deleting snapshot: $snapshot_to_delete from VM: $vm_name"
                            if VBoxManage snapshot "$vm_name" delete "$snapshot_to_delete"; then
                                log_message "Successfully deleted snapshot: $snapshot_to_delete"
                                echo "✅ Snapshot deleted successfully!"
                            else
                                log_message "ERROR: Failed to delete snapshot: $snapshot_to_delete"
                                echo "❌ Failed to delete snapshot!"
                            fi
                        else
                            echo "❌ Deletion cancelled."
                        fi
                    else
                        echo "❌ Invalid snapshot number."
                    fi
                else
                    echo "❌ Invalid snapshot number."
                fi
            else
                echo "❌ Operation cancelled."
            fi
        else
            echo "❌ Invalid VM number selected."
        fi
    else
        echo "❌ Please enter a valid number."
    fi
    echo "Press Enter to continue..."
    read -r
}

# Main script
main() {
    log_message "=== VM Backup Script Started ==="
    
    while true; do
        show_menu
        echo -n "Select an option (1-6, x, q): "
        read -r choice
        
        # Convert to lowercase for case-insensitive comparison
        choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
        
        case $choice in
            1|2|3)
                # VM selection for backup operations
                list_vms
                echo -n "Enter VM number to backup: "
                read -r vm_num
                
                if [[ "$vm_num" =~ ^[0-9]+$ ]]; then
                    vm_name=$(get_vm_name "$vm_num")
                    if [ -n "$vm_name" ]; then
                        case $choice in
                            1)
                                backup_clone "$vm_name"
                                ;;
                            2)
                                backup_ova "$vm_name"
                                ;;
                            3)
                                create_snapshot "$vm_name"
                                ;;
                        esac
                    else
                        echo "❌ Invalid VM number selected."
                    fi
                else
                    echo "❌ Please enter a valid number."
                fi
                ;;
            4)
                list_backups
                ;;
            5)
                echo -n "Delete backups older than how many days? (default: 30): "
                read -r days
                days=${days:-30}
                cleanup_old_backups "$days"
                ;;
            6)
                manage_snapshots
                ;;
            x|q)
                log_message "=== VM Backup Script Ended ==="
                echo "👋 Goodbye!"
                exit 0
                ;;
            *)
                echo "❌ Invalid option. Please select 1-6, x, or q."
                ;;
        esac
        
        # Only show continue prompt if not exiting
        echo ""
        echo -n "Press Enter to continue..."
        read -r
    done
}

# Check if VirtualBox is available
if ! command -v VBoxManage &> /dev/null; then
    echo "❌ Error: VBoxManage not found. Please install VirtualBox."
    exit 1
fi

# Check if there are any VMs
vm_count=$(VBoxManage list vms | wc -l)
if [ "$vm_count" -eq 0 ]; then
    echo "❌ No VirtualBox VMs found."
    exit 1
fi

# Start the script
main
