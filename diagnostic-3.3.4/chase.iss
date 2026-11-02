#ifndef AppVersion
  #error AppVersion must be supplied by the build script
#endif
#ifndef PayloadDir
  #error PayloadDir must be supplied by the build script
#endif
#ifndef OutputDir
  #error OutputDir must be supplied by the build script
#endif

[Setup]
#ifdef InstallerTestMode
AppId={{C1C726BB-6D89-43DD-98D2-4937AEF91E0C}
DefaultGroupName=Chase Installer QA
UninstallDisplayName=Chase Installer QA
#else
AppId={{09F54F87-2500-4B02-9DE6-2792B2F3A699}
DefaultGroupName=Chase
#endif
AppName=Chase Windows 11 Diagnostic
AppVersion={#AppVersion}
AppPublisher=Chase
SetupIconFile={#PayloadDir}\chase.ico
DefaultDirName={localappdata}\Programs\Chase
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
#ifdef InstallerTestMode
MinVersion=10.0
#else
MinVersion=10.0.22000
#endif
DisableProgramGroupPage=yes
DisableDirPage=yes
UsePreviousAppDir=yes
UninstallDisplayIcon={app}\Chase.exe
OutputDir={#OutputDir}
OutputBaseFilename=Chase-Setup-{#AppVersion}-windows11-x64
Compression=lzma2
SolidCompression=yes
CloseApplications=no
RestartApplications=no
SetupLogging=yes
WizardStyle=modern

[Tasks]
Name: desktopicon; Description: "Create a desktop shortcut"; GroupDescription: "Shortcuts:"; Flags: unchecked

[Files]
Source: "{#PayloadDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[InstallDelete]
; Replace only the generated runtime bundle. Athlete data is outside {app}.
Type: filesandordirs; Name: "{app}\_internal"

[Icons]
Name: "{group}\Chase"; Filename: "{app}\Chase.exe"; IconFilename: "{app}\chase.ico"
Name: "{group}\Stop Chase"; Filename: "{app}\Chase.exe"; Parameters: "--stop"; IconFilename: "{app}\chase.ico"
Name: "{group}\Chase logs"; Filename: "{app}\Chase.exe"; Parameters: "--diagnostics"; IconFilename: "{app}\chase.ico"
Name: "{group}\Chase data"; Filename: "{localappdata}\Chase\data"
Name: "{autodesktop}\Chase"; Filename: "{app}\Chase.exe"; Tasks: desktopicon; IconFilename: "{app}\chase.ico"

[Run]
Filename: "{app}\Chase.exe"; Description: "Open Chase in your browser"; Flags: nowait postinstall skipifsilent

[Code]
var
  UpdateMarker: String;

function StopInstalledChase(TargetVersion: String): String;
var
  ResultCode: Integer;
  Parameters: String;
  Detail: AnsiString;
begin
  Result := '';
  if not FileExists(ExpandConstant('{app}\Chase.exe')) then exit;
  Parameters := '--prepare-update --silent';
  if TargetVersion <> '' then Parameters := Parameters + ' --target-version ' + TargetVersion;
  if not Exec(ExpandConstant('{app}\Chase.exe'), Parameters, ExpandConstant('{app}'), SW_HIDE, ewWaitUntilTerminated, ResultCode) then begin
    Result := 'Chase could not prepare for installation. Close Chase and retry.';
    exit;
  end;
  if ResultCode <> 0 then begin
    Detail := '';
    LoadStringFromFile(ExpandConstant('{localappdata}\Chase\logs\installer-status.txt'), Detail);
    Result := 'Chase cannot be updated yet. Finish or cancel active work, then retry.';
    if Detail <> '' then Result := Detail;
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
var
  AppFolder, DataFolder: String;
begin
  AppFolder := Lowercase(RemoveBackslashUnlessRoot(ExpandConstant('{app}')));
  DataFolder := Lowercase(ExpandConstant('{localappdata}\Chase\data'));
  if (AppFolder = DataFolder) or (Pos(AppFolder + '\', DataFolder + '\') = 1) or (Pos(DataFolder + '\', AppFolder + '\') = 1) then begin
    Result := 'Choose an application installation folder separate from Chase data.';
    exit;
  end;
  UpdateMarker := ExpandConstant('{app}\.installing');
  ForceDirectories(ExpandConstant('{app}'));
  if not SaveStringToFile(UpdateMarker, 'Chase installer is running', False) then begin
    Result := 'The installation folder is not writable.';
    exit;
  end;
  Result := StopInstalledChase('{#AppVersion}');
  if Result <> '' then DeleteFile(UpdateMarker);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if CurStep = ssPostInstall then DeleteFile(UpdateMarker);
end;

procedure DeinitializeSetup();
begin
  if UpdateMarker <> '' then DeleteFile(UpdateMarker);
end;

function InitializeUninstall(): Boolean;
var
  Error: String;
begin
  UpdateMarker := ExpandConstant('{app}\.installing');
  if not SaveStringToFile(UpdateMarker, 'Chase uninstaller is running', False) then begin
    Result := False;
    exit;
  end;
  Error := StopInstalledChase('');
  Result := Error = '';
  if not Result then DeleteFile(UpdateMarker);
  if not Result and not UninstallSilent then MsgBox(Error, mbError, MB_OK);
end;

procedure DeinitializeUninstall();
begin
  if UpdateMarker <> '' then DeleteFile(UpdateMarker);
end;