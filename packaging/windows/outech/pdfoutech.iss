; PdfOutech installer for Windows x64 (Inno Setup 6). Per-user install, no administrator rights.
;   ISCC /DAppVersion=0.7.1 /DBinDir=..\..\..\target\release pdfoutech.iss
; Output: dist\release\pdfoutech-<version>-windows-x64-setup.exe

#ifndef AppVersion
  #define AppVersion "0.7.1"
#endif
#ifndef BinDir
  #define BinDir "..\..\..\target\release"
#endif
#define Root "..\..\.."

[Setup]
AppId={{CD2691B2-816B-4906-B179-1276B54C4F47}
AppName=PdfOutech
AppVersion={#AppVersion}
AppPublisher=Outech
DefaultDirName={autopf}\PdfOutech
DefaultGroupName=PdfOutech
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
LicenseFile={#Root}\LICENSE-MIT
SetupIconFile={#Root}\assets\app-icon\pdfcraft.ico
UninstallDisplayIcon={app}\pdfoutech.exe
OutputDir={#Root}\dist\release
OutputBaseFilename=pdfoutech-{#AppVersion}-windows-x64-setup
Compression=lzma2
SolidCompression=yes
WizardStyle=modern

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"
Name: "claude"; Description: "Link PdfOutech with Claude (adds its MCP connector to the Claude desktop app)"

[Files]
Source: "{#BinDir}\pdfoutech.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#BinDir}\pdfoutech-cli.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "link-claude.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#Root}\assets\app-icon\pdfcraft.ico"; DestDir: "{app}"; DestName: "pdfoutech.ico"; Flags: ignoreversion
Source: "{#Root}\LICENSE-MIT"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#Root}\LICENSE-APACHE"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#Root}\NOTICE"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\PdfOutech"; Filename: "{app}\pdfoutech.exe"; IconFilename: "{app}\pdfoutech.ico"
Name: "{group}\Link PdfOutech with Claude"; Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -NoExit -File ""{app}\link-claude.ps1"""; IconFilename: "{app}\pdfoutech.ico"
Name: "{autodesktop}\PdfOutech"; Filename: "{app}\pdfoutech.exe"; IconFilename: "{app}\pdfoutech.ico"; Tasks: desktopicon

[Run]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\link-claude.ps1"" -Quiet"; Flags: runhidden; Tasks: claude
Filename: "{app}\pdfoutech.exe"; Description: "Launch PdfOutech"; Flags: nowait postinstall skipifsilent

[UninstallRun]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\link-claude.ps1"" -Unlink -Quiet"; Flags: runhidden; RunOnceId: "UnlinkClaude"
