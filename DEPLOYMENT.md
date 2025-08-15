# PublicIPWatcher - Complete Installation Guide

## Quick Deployment Options

### Option 1: Single File Executable (Recommended for most users)

1. **Build the self-contained executable:**
   ```bash
   dotnet publish IPNotification\IPNotification.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -o Deploy
   ```

2. **Run the PowerShell deployment script:**
   ```powershell
   .\Deploy.ps1 -Release
   ```

3. **Or use the batch file:**
   ```cmd
   Build.bat
   ```

### Option 2: Manual Installation Steps

1. **Copy the executable** to your desired location (e.g., `%LOCALAPPDATA%\PublicIPWatcher\`)
2. **Create a Start Menu shortcut** (optional)
3. **Run the application** - it will appear in the system tray

### Option 3: Professional Windows Installer

For enterprise deployment, you can create an MSI installer using:
- **WiX Toolset** (free, Microsoft-supported)
- **NSIS** (free, lightweight)
- **Inno Setup** (free, popular)
- **Advanced Installer** (commercial)

## Deployment Files Created

After running the deployment script, you'll get:

```
Deploy/
??? IPNotification.exe                    # Main executable (~50MB, self-contained)
??? PublicIPWatcher-Installer/           # Installation package
    ??? IPNotification.exe               # Application executable
    ??? Install.bat                      # Installation script
    ??? Uninstall.bat                   # Uninstallation script
    ??? README.txt                      # User instructions
```

## Distribution Methods

### For Individual Users:
- **Single file**: Just distribute `IPNotification.exe`
- **Installation package**: Distribute the `PublicIPWatcher-Installer` folder
- **ZIP file**: Use the generated ZIP package

### For Enterprise/Multiple Computers:
- **Network deployment**: Place on shared drive
- **Group Policy**: Deploy via Software Installation
- **SCCM/Intune**: Package for enterprise management
- **Silent installation**: Use command-line parameters

## Installation Locations

- **Executable**: `%LOCALAPPDATA%\PublicIPWatcher\IPNotification.exe`
- **Settings**: `%APPDATA%\IPNotification\` (user.config)
- **Logs**: `%LOCALAPPDATA%\PublicIPWatcher\app.log`
- **Registry**: `HKCU\Software\Microsoft\Windows\CurrentVersion\Run` (if startup enabled)

## Uninstallation

### Automatic:
- Run `Uninstall.bat` from the installation package
- Or use "Add or Remove Programs" if MSI installer was used

### Manual:
1. Stop the application (right-click tray icon ? Exit)
2. Delete the installation folder
3. Remove the startup registry entry (if enabled)
4. Delete Start Menu shortcuts

## Command Line Options

The application supports these startup parameters:
- `/silent` - Start minimized to tray (default behavior)
- `/nocheck` - Skip initial IP check
- `/interval:X` - Set check interval to X minutes

## Troubleshooting

### Common Issues:
1. **"Already running" message**: Check system tray for existing instance
2. **Configuration errors**: Delete `user.config` file to reset settings
3. **Network timeouts**: Check firewall and internet connection
4. **Startup issues**: Verify registry entry in Run key

### Log Files:
Check `%LOCALAPPDATA%\PublicIPWatcher\app.log` for detailed error information.

## Requirements

- **OS**: Windows 10 version 1809 or later, Windows 11
- **Architecture**: x64 (64-bit)
- **.NET**: Not required (self-contained)
- **RAM**: 50MB
- **Disk**: 50MB free space
- **Network**: Internet connection for IP checking

## Security Notes

- Application runs with user privileges (no admin required)
- Only connects to `api.ipify.org` and `ifconfig.me/ip`
- No data collection or telemetry
- Settings stored locally only
- Open source code available for audit