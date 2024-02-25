### Items to copy
$PowershellCoreBackup = Join-Path $PSScriptRoot "/Powershell"
$PowershellBackup = Join-Path $PSScriptRoot "/WindowsPowershell"
$UserDocumentsDir = "$env:userprofile\Documents"
$TerminalBackup = Join-Path $PSScriptRoot "/Terminal/$env:COMPUTERNAME/settings.json"
$TerminalDestination = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
$SshdConfigBackup = Join-Path $PSScriptRoot "/ssh/$env:COMPUTERNAME/sshd_config"
$SshdConfigDestination = Join-Path $env:ProgramData "ssh\sshd_config"


### Run copy
Copy-Item -Path $PowershellCoreBackup -Destination $UserDocumentsDir -Recurse -Force
Copy-Item -Path $PowershellBackup -Destination $UserDocumentsDir -Recurse -Force
Copy-Item -Path $TerminalBackup -Destination $TerminalDestination -Force
Copy-Item -Path $SshdConfigBackup -Destination $SshdConfigDestination -Force

# // TODO: recover msys2

### Try refresh profile
. $profile