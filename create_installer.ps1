# CarRental Pro - Windows Installer Creation Script
# This script creates a Windows installer using NSIS

# Prerequisites:
# 1. Install NSIS from: https://nsis.sourceforge.io/Download
# 2. Add NSIS to your PATH

Write-Host "Creating Windows Installer for CarRental Pro..." -ForegroundColor Green

# Create NSIS script
$nsisScript = @"
!include "MUI2.nsh"
!include "FileFunc.nsh"

; Application information
Name "CarRental Pro"
OutFile "CarRentalPro-Setup.exe"
InstallDir "$PROGRAMFILES\CarRental Pro"
InstallDirRegKey HKCU "Software\CarRental Pro" ""

; Request application privileges
RequestExecutionLevel admin

; Interface Settings
!define MUI_ABORTWARNING
!define MUI_ICON "assets\app_icon.ico"
!define MUI_UNICON "assets\app_icon.ico"

; Pages
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

; Languages
!insertmacro MUI_LANGUAGE "English"

; Installer Sections
Section "CarRental Pro" SecMain
    SetOutPath "$INSTDIR"
    
    ; Copy application files
    File /r "build\windows\x64\runner\Release\*.*"
    
    ; Create uninstaller
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    
    ; Create start menu shortcut
    CreateDirectory "$SMPROGRAMS\CarRental Pro"
    CreateShortCut "$SMPROGRAMS\CarRental Pro\CarRental Pro.lnk" "$INSTDIR\offline_rent_car.exe"
    CreateShortCut "$SMPROGRAMS\CarRental Pro\Uninstall.lnk" "$INSTDIR\Uninstall.exe"
    
    ; Create desktop shortcut
    CreateShortCut "$DESKTOP\CarRental Pro.lnk" "$INSTDIR\offline_rent_car.exe"
    
    ; Write registry information
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CarRental Pro" "DisplayName" "CarRental Pro"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CarRental Pro" "UninstallString" "$\"$INSTDIR\Uninstall.exe$\""
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CarRental Pro" "DisplayIcon" "$INSTDIR\offline_rent_car.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CarRental Pro" "Publisher" "CarRental Pro"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CarRental Pro" "DisplayVersion" "1.0.0"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CarRental Pro" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CarRental Pro" "NoRepair" 1
    
    ; Calculate installation size
    ${{GetSize}} "$INSTDIR" "/S=0K" $0 $1 $2
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CarRental Pro" "EstimatedSize" $0
SectionEnd

; Uninstaller Section
Section "Uninstall"
    ; Remove application files
    RMDir /r "$INSTDIR"
    
    ; Remove shortcuts
    Delete "$SMPROGRAMS\CarRental Pro\CarRental Pro.lnk"
    Delete "$SMPROGRAMS\CarRental Pro\Uninstall.lnk"
    RMDir "$SMPROGRAMS\CarRental Pro"
    Delete "$DESKTOP\CarRental Pro.lnk"
    
    ; Remove registry keys
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CarRental Pro"
    DeleteRegKey HKCU "Software\CarRental Pro"
SectionEnd
"@

# Create LICENSE.txt file
$licenseText = @"
CarRental Pro - License Agreement
=================================

MIT License

Copyright (c) 2024 CarRental Pro

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"@

# Save files
$nsisScript | Out-File -FilePath "installer.nsi" -Encoding UTF8
$licenseText | Out-File -FilePath "LICENSE.txt" -Encoding UTF8

Write-Host "NSIS script created: installer.nsi" -ForegroundColor Yellow
Write-Host "License file created: LICENSE.txt" -ForegroundColor Yellow

Write-Host "`nTo create the installer:" -ForegroundColor Cyan
Write-Host "1. Install NSIS from: https://nsis.sourceforge.io/Download" -ForegroundColor White
Write-Host "2. Add NSIS to your PATH" -ForegroundColor White
Write-Host "3. Run: makensis installer.nsi" -ForegroundColor White
Write-Host "4. The installer will be created as: CarRentalPro-Setup.exe" -ForegroundColor White

Write-Host "`nNote: You'll need an app icon file at: assets\app_icon.ico" -ForegroundColor Yellow 