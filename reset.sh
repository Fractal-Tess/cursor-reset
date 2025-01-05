#!/usr/bin/env bash

# Cursor Trial Reset Tool
#
# This script resets the device IDs in Cursor's configuration file to generate a new random device ID.
#

set -euo pipefail

# Function to generate a random hex string of specified length
generate_random_hex() {
    local length=$1
    od -An -N $((length/2)) -tx1 /dev/urandom | tr -d ' \n'
}

# Function to generate a UUID v4
generate_uuid() {
    # Fallback UUID generation
    local hex
    hex=$(generate_random_hex 32)
    echo "${hex:0:8}-${hex:8:4}-4${hex:13:3}-${hex:16:4}-${hex:20:12}"
}

# Function to get the storage file path based on OS
get_storage_file() {
    local storage_path=""
    case "$(uname -s)" in
        Darwin)
            storage_path="$HOME/Library/Application Support/Cursor/User/globalStorage/storage.json"
            ;;
        Linux)
            storage_path="$HOME/.config/Cursor/User/globalStorage/storage.json"
            ;;
        MINGW*|CYGWIN*|MSYS*)
            storage_path="$APPDATA/Cursor/User/globalStorage/storage.json"
            ;;
        *)
            echo "Unsupported operating system" >&2
            exit 1
            ;;
    esac
    echo "$storage_path"
}

# Function to create a backup of the storage file
backup_file() {
    local file_path="$1"
    if [ -f "$file_path" ]; then
        local timestamp
        timestamp=$(date '+%Y%m%d_%H%M%S')
        cp "$file_path" "${file_path}.backup_${timestamp}"
    fi
}

# Function to reset the cursor ID
reset_cursor_id() {
    local storage_file
    storage_file=$(get_storage_file)
    
    # Create parent directories if they don't exist
    mkdir -p "$(dirname "$storage_file")"
    
    # Backup existing file
    backup_file "$storage_file"
    
    # Generate new IDs
    local machine_id mac_machine_id dev_device_id
    machine_id=$(generate_random_hex 64)
    mac_machine_id=$(generate_random_hex 64)
    dev_device_id=$(generate_uuid)
    
    # Create or update the storage file
    local json_content='{}'
    if [ -f "$storage_file" ]; then
        json_content=$(cat "$storage_file" 2>/dev/null || echo '{}')
    fi
    
    # Create new JSON with updated values
    local new_json_content
    new_json_content=$(cat << EOF
{
  "telemetry.machineId": "${machine_id}",
  "telemetry.macMachineId": "${mac_machine_id}",
  "telemetry.devDeviceId": "${dev_device_id}"
}
EOF
    )
    
    # Merge JSON manually
    echo "$json_content" | sed 's/}/,/' > "$storage_file"
    echo "$new_json_content" | sed '1d;$d' >> "$storage_file"
    echo "}" >> "$storage_file"
    
    # Print the new IDs
    echo "🎉 Device IDs have been successfully reset. The new device IDs are: "
    echo
    cat << EOF
{
  "machineId": "${machine_id}",
  "macMachineId": "${mac_machine_id}",
  "devDeviceId": "${dev_device_id}"
}
EOF
}

# Main execution
reset_cursor_id 