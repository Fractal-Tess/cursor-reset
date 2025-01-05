<p align="center">
  <img src="./public/cursorreset.webp" alt="Cursor Trial Reset Tool Logo">
</p>

# Cursor Trial Reset Tool

A utility tool that helps manage Cursor editor's device identification system by resetting stored device IDs.

## How It Works

The tool generates new random device identifiers for Cursor, which allows the system to recognize your device as new.

## Usage

### Linux/macOS (Bash)

```bash
# Download and run the script
curl -O https://raw.githubusercontent.com/fractal-tess/cursor-reset/main/reset.sh
chmod +x reset.sh
./reset.sh
```

### Windows (PowerShell)

```powershell
# Download and run the script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/fractal-tess/cursor-reset/main/reset.ps1" -OutFile "reset.ps1"
.\reset.ps1
```

## Configuration Location

The configuration file for each operating system is located at:

- **Windows**: `%APPDATA%\Cursor\User\globalStorage\storage.json`
- **macOS**: `~/Library/Application Support/Cursor/User/globalStorage/storage.json`
- **Linux**: `~/.config/Cursor/User/globalStorage/storage.json`

## Disclaimer

The author of this tool is not responsible for any misuse or damage caused by the use of this tool. Users are solely responsible for their actions and must ensure they comply with all applicable laws and regulations.
