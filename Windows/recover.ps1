### Items to copy
$PowershellCoreBackup = Join-Path $PSScriptRoot "/Powershell"
$PowershellBackup = Join-Path $PSScriptRoot "/WindowsPowershell"
$UserDocumentsDir = "$env:userprofile\Documents"
$TerminalBackup = Join-Path $PSScriptRoot "/Terminal/$env:COMPUTERNAME/settings.json"
$TerminalDestination = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"


### Run copy
Copy-Item -Path $PowershellCoreBackup -Destination $UserDocumentsDir -Recurse -Force
Copy-Item -Path $PowershellBackup -Destination $UserDocumentsDir -Recurse -Force
Copy-Item -Path $TerminalBackup -Destination $TerminalDestination -Force

### Try refresh profile
. $profile