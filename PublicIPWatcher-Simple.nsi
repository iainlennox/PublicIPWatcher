; Simple NSIS Installer for PublicIPWatcher
; Compile with NSIS 3.x: makensis PublicIPWatcher-Simple.nsi

!define APPNAME "PublicIPWatcher"
!define APPVERSION "1.0.0"
!define APPEXE "IPNotification.exe"

Name "${APPNAME}"
OutFile "PublicIPWatcher-Setup-${APPVERSION}.exe"
InstallDir "$LOCALAPPDATA\${APPNAME}"
RequestExecutionLevel user

Page directory
Page instfiles

Section
    SetOutPath $INSTDIR
    File "Deploy\${APPEXE}"
    
    ; Create start menu shortcut
    CreateDirectory "$SMPROGRAMS\${APPNAME}"
    CreateShortcut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\${APPEXE}"
    
    ; Create uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    CreateShortcut "$SMPROGRAMS\${APPNAME}\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
    
    ; Registry for Add/Remove Programs
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$INSTDIR\Uninstall.exe"
    
    MessageBox MB_YESNO "Start ${APPNAME} now?" IDNO NoStart
    Exec "$INSTDIR\${APPEXE}"
    NoStart:
SectionEnd

Section "Uninstall"
    ; Kill the process if running
    nsExec::Exec "taskkill /F /IM ${APPEXE}"
    
    ; Remove files
    Delete "$INSTDIR\${APPEXE}"
    Delete "$INSTDIR\Uninstall.exe"
    RMDir "$INSTDIR"
    
    ; Remove shortcuts
    Delete "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk"
    Delete "$SMPROGRAMS\${APPNAME}\Uninstall.lnk"
    RMDir "$SMPROGRAMS\${APPNAME}"
    
    ; Remove registry
    DeleteRegKey HKCU "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
SectionEnd