# Cursor Trial Reset Tool
#
# This script resets the device IDs in Cursor's configuration file to generate a new random device ID.
#

# Ensure we stop on errors
$ErrorActionPreference = "Stop"

# Function to generate a random hex string of specified length
function Get-RandomHex {
    param (
        [Parameter(Mandatory=$true)]
        [int]$Length
    )
    
    $bytes = New-Object byte[] ($Length / 2)
    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
    $rng.GetBytes($bytes)
    $hex = [System.BitConverter]::ToString($bytes) -replace '-',''
    $rng.Dispose()
    return $hex.ToLower()
}

# Function to get the storage file path based on OS
function Get-StorageFile {
    $os = [System.Environment]::OSVersion.Platform
    
    switch ($os) {
        "Win32NT" {
            return Join-Path $env:APPDATA "Cursor\User\globalStorage\storage.json"
        }
        "Unix" {
            if ($IsMacOS) {
                return Join-Path $HOME "Library/Application Support/Cursor/User/globalStorage/storage.json"
            }
            else {
                return Join-Path $HOME ".config/Cursor/User/globalStorage/storage.json"
            }
        }
        default {
            throw "Unsupported operating system: $os"
        }
    }
}

# Function to create a backup of the storage file
function Backup-File {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )
    
    if (Test-Path $FilePath) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupPath = "${FilePath}.backup_${timestamp}"
        Copy-Item -Path $FilePath -Destination $backupPath -Force
    }
}

# Function to reset the cursor ID
function Reset-CursorId {
    $storageFile = Get-StorageFile
    
    # Create parent directories if they don't exist
    $parentDir = Split-Path -Parent $storageFile
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }
    
    # Backup existing file
    Backup-File -FilePath $storageFile
    
    # Generate new IDs
    $machineId = Get-RandomHex -Length 64
    $macMachineId = Get-RandomHex -Length 64
    $devDeviceId = [System.Guid]::NewGuid().ToString()
    
    # Create or update the storage file
    $data = @{}
    if (Test-Path $storageFile) {
        try {
            $content = Get-Content $storageFile -Raw
            if ($content) {
                $data = $content | ConvertFrom-Json -AsHashtable
            }
        }
        catch {
            Write-Warning "Could not parse existing storage file. Creating new one."
        }
    }
    
    # Update the values
    $data["telemetry.machineId"] = $machineId
    $data["telemetry.macMachineId"] = $macMachineId
    $data["telemetry.devDeviceId"] = $devDeviceId
    
    # Write the updated data back to the file
    $data | ConvertTo-Json -Depth 10 | Set-Content -Path $storageFile -Encoding UTF8
    
    # Print the new IDs
    Write-Host "🎉 Device IDs have been successfully reset. The new device IDs are: `n"
    
    @{
        machineId = $machineId
        macMachineId = $macMachineId
        devDeviceId = $devDeviceId
    } | ConvertTo-Json | Write-Host
}

# Main execution
Reset-CursorId 