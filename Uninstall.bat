@echo off
title PublicIPWatcher - Uninstallation
setlocal enabledelayedexpansion

echo.
echo ========================================
echo   PublicIPWatcher Uninstallation
echo ========================================
echo.

REM Define installation directory
set "INSTALL_DIR=%LOCALAPPDATA%\PublicIPWatcher"
set "EXECUTABLE=IPNotification.exe"

echo This will completely remove PublicIPWatcher from your system.
echo.
echo Installation directory: %INSTALL_DIR%
echo.

REM Confirm uninstallation
set /p "CONFIRM=Are you sure you want to uninstall PublicIPWatcher? (Y/N): "
if /i not "%CONFIRM%"=="Y" (
    echo Uninstallation cancelled.
    pause
    exit /b 0
)

echo.
echo Starting uninstallation...

REM Stop running process
echo Stopping PublicIPWatcher if running...
tasklist /FI "IMAGENAME eq IPNotification.exe" 2>NUL | find /I /N "IPNotification.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo Found running PublicIPWatcher process. Stopping...
    taskkill /F /IM "IPNotification.exe" >NUL 2>&1
    timeout /t 2 >NUL
    echo Process stopped.
) else (
    echo No running process found.
)

REM Remove desktop shortcut
echo Removing desktop shortcut...
set "DESKTOP_SHORTCUT=%USERPROFILE%\Desktop\PublicIPWatcher.lnk"
if exist "%DESKTOP_SHORTCUT%" (
    del "%DESKTOP_SHORTCUT%" >NUL 2>&1
    if exist "%DESKTOP_SHORTCUT%" (
        echo WARNING: Failed to remove desktop shortcut.
    ) else (
        echo Desktop shortcut removed.
    )
) else (
    echo Desktop shortcut not found.
)

REM Remove startup shortcut
echo Removing startup shortcut...
set "STARTUP_SHORTCUT=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\PublicIPWatcher.lnk"
if exist "%STARTUP_SHORTCUT%" (
    del "%STARTUP_SHORTCUT%" >NUL 2>&1
    if exist "%STARTUP_SHORTCUT%" (
        echo WARNING: Failed to remove startup shortcut.
    ) else (
        echo Startup shortcut removed.
    )
) else (
    echo Startup shortcut not found.
)

REM Remove from Windows registry
echo Removing from Windows uninstall registry...
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\PublicIPWatcher" /f >NUL 2>&1
echo Registry entries removed.

REM Remove installation directory
echo Removing installation directory...
if exist "%INSTALL_DIR%" (
    REM First try to remove just the files
    if exist "%INSTALL_DIR%\%EXECUTABLE%" (
        del "%INSTALL_DIR%\%EXECUTABLE%" >NUL 2>&1
    )
    if exist "%INSTALL_DIR%\Uninstall.bat" (
        REM Don't delete self yet
        echo Uninstall.bat will be removed after completion.
    )
    
    REM Remove any other files in the directory
    for %%f in ("%INSTALL_DIR%\*") do (
        if not "%%~nxf"=="Uninstall.bat" (
            del "%%f" >NUL 2>&1
        )
    )
    
    echo Installation files removed.
) else (
    echo Installation directory not found.
)

REM Clean up any remaining user data (optional)
echo Removing application settings...
reg delete "HKCU\Software\PublicIPWatcher" /f >NUL 2>&1

echo.
echo ========================================
echo   Uninstallation Complete!
echo ========================================
echo.
echo PublicIPWatcher has been successfully removed from your system.
echo.
echo The following items were removed:
echo - Application files from %INSTALL_DIR%
echo - Desktop shortcut
echo - Startup shortcut  
echo - Windows registry entries
echo - Application settings
echo.

REM Schedule deletion of installation directory and this script
echo Scheduling cleanup of remaining files...
echo @echo off > "%TEMP%\cleanup_publicipwatcher.bat"
echo timeout /t 3 ^>NUL >> "%TEMP%\cleanup_publicipwatcher.bat"
echo rmdir /S /Q "%INSTALL_DIR%" ^>NUL 2^>^&1 >> "%TEMP%\cleanup_publicipwatcher.bat"
echo del "%%~f0" ^>NUL 2^>^&1 >> "%TEMP%\cleanup_publicipwatcher.bat"

echo Cleanup complete!
echo.
echo Thank you for using PublicIPWatcher!
pause

REM Start cleanup script and exit
start /min "" "%TEMP%\cleanup_publicipwatcher.bat"
exit
