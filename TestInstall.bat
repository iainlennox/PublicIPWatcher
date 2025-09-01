@echo off
title PublicIPWatcher - Installation Test
echo.
echo ========================================
echo   PublicIPWatcher Installation Test
echo ========================================
echo.

echo Current directory: %CD%
echo.

echo Checking for IPNotification.exe in various locations:
echo.

if exist "IPNotification.exe" (
    echo [FOUND] IPNotification.exe in current directory
    dir "IPNotification.exe" | find /v "Directory"
) else (
    echo [NOT FOUND] IPNotification.exe in current directory
)

if exist "release-build\IPNotification.exe" (
    echo [FOUND] IPNotification.exe in release-build directory
    dir "release-build\IPNotification.exe" | find /v "Directory"
) else (
    echo [NOT FOUND] IPNotification.exe in release-build directory
)

if exist "publish\IPNotification.exe" (
    echo [FOUND] IPNotification.exe in publish directory
    dir "publish\IPNotification.exe" | find /v "Directory"
) else (
    echo [NOT FOUND] IPNotification.exe in publish directory
)

if exist "bin\Release\net8.0-windows\win-x64\publish\IPNotification.exe" (
    echo [FOUND] IPNotification.exe in build output directory
    dir "bin\Release\net8.0-windows\win-x64\publish\IPNotification.exe" | find /v "Directory"
) else (
    echo [NOT FOUND] IPNotification.exe in build output directory
)

echo.
echo Listing all .exe files in current directory:
if exist "*.exe" (
    dir "*.exe" /b
) else (
    echo No .exe files found in current directory
)

echo.
echo Listing all files in current directory:
dir /b

echo.
echo ========================================
echo   Test Complete
echo ========================================
echo.
echo If IPNotification.exe was found above, you can run Install.bat
echo If not found, please check your ZIP extraction or build process.
echo.
pause
