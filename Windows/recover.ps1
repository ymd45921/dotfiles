### Items to copy
$PowershellBackup = Join-Path $PSScriptRoot "/Powershell"
$TerminalBackup = Join-Path $PSScriptRoot "/Terminal/settings.json"
$TerminalDestination = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"


### Run copy
Copy-Item -Path $PowershellBackup -Destination (Split-Path (Split-Path $PROFILE)) -Recurse -Force
Copy-Item -Path $TerminalBackup -Destination $TerminalDestination -Force