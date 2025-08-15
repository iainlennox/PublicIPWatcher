# PublicIPWatcher Deployment Script
# This script creates a self-contained single-file deployment

param(
    [string]$OutputPath = ".\Deploy",
    [switch]$Release = $false
)

$Configuration = if ($Release) { "Release" } else { "Debug" }

Write-Host "Building PublicIPWatcher for deployment..." -ForegroundColor Green

# Clean and build
dotnet clean IPNotification\IPNotification.csproj -c $Configuration
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# Publish self-contained single file
Write-Host "Publishing self-contained executable..." -ForegroundColor Yellow
dotnet publish IPNotification\IPNotification.csproj `
    -c $Configuration `
    -r win-x64 `
    --self-contained true `
    -p:PublishSingleFile=true `
    -p:IncludeNativeLibrariesForSelfExtract=true `
    -p:PublishTrimmed=false `
    -o $OutputPath

if ($LASTEXITCODE -eq 0) {
    Write-Host "? Deployment successful!" -ForegroundColor Green
    Write-Host "?? Output location: $OutputPath" -ForegroundColor Cyan
    
    $exeFile = Join-Path $OutputPath "IPNotification.exe"
    if (Test-Path $exeFile) {
        $fileInfo = Get-Item $exeFile
        Write-Host "?? Executable: $($fileInfo.Name) ($([math]::Round($fileInfo.Length / 1MB, 2)) MB)" -ForegroundColor Cyan
        
        # Create installer package
        $packagePath = Join-Path $OutputPath "PublicIPWatcher-Installer"
        New-Item -Path $packagePath -ItemType Directory -Force | Out-Null
        
        # Copy executable
        Copy-Item $exeFile -Destination $packagePath
        
        # Create installation script
        $installScript = @"
@echo off
title PublicIPWatcher Installer
echo.
echo ========================================
echo   PublicIPWatcher Installation
echo ========================================
echo.

set "INSTALL_DIR=%LOCALAPPDATA%\PublicIPWatcher"
set "STARTUP_REG=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"

echo Creating installation directory...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo Copying application files...
copy /Y "IPNotification.exe" "%INSTALL_DIR%\" > nul
if errorlevel 1 (
    echo ERROR: Failed to copy application files.
    pause
    exit /b 1
)

echo Creating Start Menu shortcut...
set "SHORTCUT_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs"
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SHORTCUT_DIR%\PublicIPWatcher.lnk'); $s.TargetPath = '%INSTALL_DIR%\IPNotification.exe'; $s.Description = 'Monitor your public IP address'; $s.Save()"

echo.
echo Installation complete!
echo.
echo The application has been installed to: %INSTALL_DIR%
echo A shortcut has been created in the Start Menu.
echo.
echo To start the application now, press 'Y'. To exit, press any other key.
choice /C YN /M "Start PublicIPWatcher now?"
if errorlevel 2 goto :end

echo Starting PublicIPWatcher...
start "" "%INSTALL_DIR%\IPNotification.exe"

:end
echo.
echo Thank you for installing PublicIPWatcher!
pause
"@
        
        $installScript | Out-File -FilePath (Join-Path $packagePath "Install.bat") -Encoding ASCII
        
        # Create uninstall script
        $uninstallScript = @"
@echo off
title PublicIPWatcher Uninstaller
echo.
echo ========================================
echo   PublicIPWatcher Uninstallation
echo ========================================
echo.

set "INSTALL_DIR=%LOCALAPPDATA%\PublicIPWatcher"
set "STARTUP_REG=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"

echo Stopping PublicIPWatcher if running...
taskkill /F /IM IPNotification.exe 2>nul

echo Removing startup entry...
reg delete "%STARTUP_REG%" /v "PublicIPWatcher" /f 2>nul

echo Removing Start Menu shortcut...
del "%APPDATA%\Microsoft\Windows\Start Menu\Programs\PublicIPWatcher.lnk" 2>nul

echo Removing application files...
if exist "%INSTALL_DIR%" (
    rmdir /S /Q "%INSTALL_DIR%"
    echo Application files removed.
) else (
    echo Application directory not found.
)

echo.
echo PublicIPWatcher has been uninstalled.
echo.
pause
"@
        
        $uninstallScript | Out-File -FilePath (Join-Path $packagePath "Uninstall.bat") -Encoding ASCII
        
        # Create README
        $readme = @"
# PublicIPWatcher Installation Package

## Installation
1. Run `Install.bat` as an administrator (right-click ? "Run as administrator")
2. Follow the on-screen instructions
3. The application will be installed to: %LOCALAPPDATA%\PublicIPWatcher
4. A Start Menu shortcut will be created

## Uninstallation
1. Run `Uninstall.bat` as an administrator
2. This will remove all application files and registry entries

## Manual Installation
If you prefer manual installation:
1. Copy `IPNotification.exe` to any folder
2. Run the executable directly
3. Use the tray icon context menu to configure startup options

## Features
- System tray application (no visible window by default)
- Monitors your public IP address every 5 minutes
- Notifies you when your IP changes
- Configurable check interval
- Optional Windows startup integration
- Logs to %LOCALAPPDATA%\PublicIPWatcher\app.log

## Usage
- Right-click the tray icon for options
- Double-click to show status window
- Use "Check Now" for immediate IP check
- Configure check interval in the status window

## Requirements
- Windows 10 or later
- .NET 8 Runtime (included in self-contained version)
- Internet connection for IP checking

## Support
This is a lightweight utility application.
Logs are available in: %LOCALAPPDATA%\PublicIPWatcher\app.log
"@
        
        $readme | Out-File -FilePath (Join-Path $packagePath "README.txt") -Encoding UTF8
        
        # Create ZIP package
        $zipPath = Join-Path $OutputPath "PublicIPWatcher-v1.0.0-Installer.zip"
        if (Get-Command Compress-Archive -ErrorAction SilentlyContinue) {
            Compress-Archive -Path "$packagePath\*" -DestinationPath $zipPath -Force
            Write-Host "?? Installer package created: PublicIPWatcher-v1.0.0-Installer.zip" -ForegroundColor Green
        }
        
        Write-Host ""
        Write-Host "?? Ready to distribute:" -ForegroundColor Green
        Write-Host "   • Single file executable: IPNotification.exe" -ForegroundColor White
        Write-Host "   • Installer package: PublicIPWatcher-Installer\" -ForegroundColor White
        if (Test-Path $zipPath) {
            Write-Host "   • ZIP package: PublicIPWatcher-v1.0.0-Installer.zip" -ForegroundColor White
        }
    }
} else {
    Write-Host "? Deployment failed!" -ForegroundColor Red
    exit 1
}