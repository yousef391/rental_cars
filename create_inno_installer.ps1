# CarRental Pro - Inno Setup Installer Creation Script
# This script creates a Windows installer using Inno Setup

# Prerequisites:
# 1. Install Inno Setup from: https://jrsoftware.org/isdl.php
# 2. Add Inno Setup to your PATH

Write-Host "Creating Inno Setup Installer for CarRental Pro..." -ForegroundColor Green

# Create Inno Setup script
$innoScript = @"
[Setup]
AppName=CarRental Pro
AppVersion=1.0.0
AppPublisher=CarRental Pro
AppPublisherURL=https://carrentalpro.com
AppSupportURL=https://carrentalpro.com/support
AppUpdatesURL=https://carrentalpro.com/updates
DefaultDirName={autopf}\CarRental Pro
DefaultGroupName=CarRental Pro
AllowNoIcons=yes
LicenseFile=LICENSE.txt
OutputDir=website\downloads
OutputBaseFilename=CarRentalPro-Setup
SetupIconFile=assets\app_icon.ico
Compression=lzma
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\CarRental Pro"; Filename: "{app}\offline_rent_car.exe"
Name: "{group}\{cm:UninstallProgram,CarRental Pro}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\CarRental Pro"; Filename: "{app}\offline_rent_car.exe"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\CarRental Pro"; Filename: "{app}\offline_rent_car.exe"; Tasks: quicklaunchicon

[Run]
Filename: "{app}\offline_rent_car.exe"; Description: "{cm:LaunchProgram,CarRental Pro}"; Flags: nowait postinstall skipifsilent

[Code]
function InitializeSetup(): Boolean;
begin
  Result := True;
end;
"@

# Save Inno Setup script
$innoScript | Out-File -FilePath "setup.iss" -Encoding UTF8

Write-Host "Inno Setup script created: setup.iss" -ForegroundColor Yellow

Write-Host "`nTo create the installer:" -ForegroundColor Cyan
Write-Host "1. Install Inno Setup from: https://jrsoftware.org/isdl.php" -ForegroundColor White
Write-Host "2. Add Inno Setup to your PATH" -ForegroundColor White
Write-Host "3. Run: iscc setup.iss" -ForegroundColor White
Write-Host "4. The installer will be created as: website\downloads\CarRentalPro-Setup.exe" -ForegroundColor White

Write-Host "`nNote: You'll need an app icon file at: assets\app_icon.ico" -ForegroundColor Yellow 