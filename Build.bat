@echo off
title PublicIPWatcher Build and Deploy
echo.
echo ========================================
echo   Building PublicIPWatcher
echo ========================================
echo.

cd /d "%~dp0"

REM Clean previous builds
echo Cleaning previous builds...
if exist Deploy rmdir /S /Q Deploy
mkdir Deploy

REM Build and publish
echo Building self-contained executable...
dotnet publish IPNotification\IPNotification.csproj -c Release -r win-x64 --self-contained true -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -p:PublishTrimmed=false -o Deploy

if errorlevel 1 (
    echo.
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo ========================================
echo   Build Complete!
echo ========================================
echo.
echo Output location: Deploy\
echo Main executable: Deploy\IPNotification.exe
echo.

REM Show file size
for %%F in (Deploy\IPNotification.exe) do (
    echo File size: %%~zF bytes
)

echo.
echo You can now distribute the IPNotification.exe file.
echo It's a self-contained executable that doesn't require .NET installation.
echo.
pause