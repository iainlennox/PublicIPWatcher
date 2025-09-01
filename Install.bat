@echo off
title PublicIPWatcher - Installation
setlocal enabledelayedexpansion

echo.
echo ========================================
echo   PublicIPWatcher Installation
echo ========================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running as Administrator: YES
) else (
    echo Running as Administrator: NO
    echo.
    echo NOTICE: Running without administrator privileges.
    echo The installer will install to your user directory.
    echo.
    pause
)

REM Define installation directory
set "INSTALL_DIR=%LOCALAPPDATA%\PublicIPWatcher"
set "EXECUTABLE=IPNotification.exe"

echo Installation directory: %INSTALL_DIR%
echo.

REM Check if executable exists in current directory
if not exist "%EXECUTABLE%" (
    echo ERROR: %EXECUTABLE% not found in current directory!
    echo.
    echo Please ensure you have extracted the PublicIPWatcher ZIP file
    echo and are running this installer from the same folder as %EXECUTABLE%.
    echo.
    pause
    exit /b 1
)

REM Create installation directory
echo Creating installation directory...
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
    if errorlevel 1 (
        echo ERROR: Failed to create installation directory!
        pause
        exit /b 1
    )
    echo Directory created successfully.
) else (
    echo Directory already exists.
)

REM Stop existing process if running
echo Checking for running PublicIPWatcher processes...
tasklist /FI "IMAGENAME eq IPNotification.exe" 2>NUL | find /I /N "IPNotification.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo Found running PublicIPWatcher process. Attempting to stop...
    taskkill /F /IM "IPNotification.exe" >NUL 2>&1
    timeout /t 2 >NUL
    echo Process stopped.
)

REM Copy executable
echo Copying %EXECUTABLE% to installation directory...
copy "%EXECUTABLE%" "%INSTALL_DIR%\%EXECUTABLE%" >NUL
if errorlevel 1 (
    echo ERROR: Failed to copy executable!
    pause
    exit /b 1
)
echo File copied successfully.

REM Create startup shortcut
echo Creating startup shortcut...
set "STARTUP_DIR=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "SHORTCUT_PATH=%STARTUP_DIR%\PublicIPWatcher.lnk"

REM Create VBScript to create shortcut
echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\CreateShortcut.vbs"
echo sLinkFile = "%SHORTCUT_PATH%" >> "%TEMP%\CreateShortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\CreateShortcut.vbs"
echo oLink.TargetPath = "%INSTALL_DIR%\%EXECUTABLE%" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.WorkingDirectory = "%INSTALL_DIR%" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Description = "PublicIPWatcher - Monitor your public IP address" >> "%TEMP%\CreateShortcut.vbs"
echo oLink.Save >> "%TEMP%\CreateShortcut.vbs"

cscript //nologo "%TEMP%\CreateShortcut.vbs"
del "%TEMP%\CreateShortcut.vbs"

if exist "%SHORTCUT_PATH%" (
    echo Startup shortcut created successfully.
) else (
    echo WARNING: Failed to create startup shortcut.
)

REM Create desktop shortcut
echo Creating desktop shortcut...
set "DESKTOP_SHORTCUT=%USERPROFILE%\Desktop\PublicIPWatcher.lnk"

echo Set oWS = WScript.CreateObject("WScript.Shell") > "%TEMP%\CreateDesktopShortcut.vbs"
echo sLinkFile = "%DESKTOP_SHORTCUT%" >> "%TEMP%\CreateDesktopShortcut.vbs"
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> "%TEMP%\CreateDesktopShortcut.vbs"
echo oLink.TargetPath = "%INSTALL_DIR%\%EXECUTABLE%" >> "%TEMP%\CreateDesktopShortcut.vbs"
echo oLink.WorkingDirectory = "%INSTALL_DIR%" >> "%TEMP%\CreateDesktopShortcut.vbs"
echo oLink.Description = "PublicIPWatcher - Monitor your public IP address" >> "%TEMP%\CreateDesktopShortcut.vbs"
echo oLink.Save >> "%TEMP%\CreateDesktopShortcut.vbs"

cscript //nologo "%TEMP%\CreateDesktopShortcut.vbs"
del "%TEMP%\CreateDesktopShortcut.vbs"

if exist "%DESKTOP_SHORTCUT%" (
    echo Desktop shortcut created successfully.
) else (
    echo WARNING: Failed to create desktop shortcut.
)

REM Add to Windows registry for uninstall
echo Adding uninstall information to Windows registry...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\PublicIPWatcher" /v "DisplayName" /t REG_SZ /d "PublicIPWatcher" /f >NUL
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\PublicIPWatcher" /v "UninstallString" /t REG_SZ /d "\"%INSTALL_DIR%\Uninstall.bat\"" /f >NUL
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\PublicIPWatcher" /v "DisplayIcon" /t REG_SZ /d "\"%INSTALL_DIR%\%EXECUTABLE%\"" /f >NUL
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\PublicIPWatcher" /v "DisplayVersion" /t REG_SZ /d "1.1.1" /f >NUL
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\PublicIPWatcher" /v "Publisher" /t REG_SZ /d "PublicIPWatcher" /f >NUL
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\PublicIPWatcher" /v "InstallLocation" /t REG_SZ /d "%INSTALL_DIR%" /f >NUL

REM Copy uninstall script
echo Copying uninstall script...
if exist "Uninstall.bat" (
    copy "Uninstall.bat" "%INSTALL_DIR%\Uninstall.bat" >NUL
) else (
    echo WARNING: Uninstall.bat not found in current directory.
)

echo.
echo ========================================
echo   Installation Complete!
echo ========================================
echo.
echo PublicIPWatcher has been installed to:
echo %INSTALL_DIR%
echo.
echo Shortcuts created:
echo - Desktop: %DESKTOP_SHORTCUT%
echo - Startup: %SHORTCUT_PATH%
echo.
echo The application will start automatically with Windows.
echo You can also start it manually from the desktop shortcut.
echo.
echo To uninstall, use "Add or Remove Programs" in Windows Settings
echo or run the uninstall script from the installation directory.
echo.

REM Ask if user wants to start the application now
set /p "START_NOW=Start PublicIPWatcher now? (Y/N): "
if /i "%START_NOW%"=="Y" (
    echo Starting PublicIPWatcher...
    start "" "%INSTALL_DIR%\%EXECUTABLE%"
)

echo.
echo Installation completed successfully!
pause
