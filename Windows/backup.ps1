### Items to copy
$PowershellCoreProfileDir = "$env:userprofile\Documents\Powershell"
$PowershellProfileDir = "$env:userprofile\Documents\WindowsPowershell"
$TerminalSettingsPath = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

### Tools
function New-DirectoryRecursively {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    if (-not (Test-Path -Path $Path -PathType Container)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}


### Run copy
Copy-Item -Path $PowershellCoreProfileDir -Destination $PSScriptRoot -Recurse -Force
Copy-Item -Path $PowershellProfileDir -Destination $PSScriptRoot -Recurse -Force
New-DirectoryRecursively -Path (Join-Path $PSScriptRoot "/Terminal/$env:COMPUTERNAME/")
Copy-Item -Path $TerminalSettingsPath -Destination (Join-Path $PSScriptRoot "/Terminal/$env:COMPUTERNAME/") -Force

if ($MSYS2_HOME -ne $null) {
    $msys2_userprofile = Join-Path $MSYS2_HOME "/home/$env:USERNAME"
    $msys2_backup_root = Join-Path $PSScriptRoot "/MSYS2/$env:COMPUTERNAME"
    New-DirectoryRecursively -Path $(Join-Path $msys2_backup_root "zsh/host_userprofile")
    Copy-Item -Path $(Join-Path $msys2_userprofile ".zshrc") -Destination $(Join-Path $msys2_backup_root "zsh/.zshrc") -Force
    if (Test-Path $(Join-Path $msys2_userprofile ".p10k.zsh")) {
        Copy-Item -Path $(Join-Path $msys2_userprofile ".p10k.zsh") -Destination $(Join-Path $msys2_backup_root "zsh/.p10k.zsh") -Force
    }
    # Copy-Item -Path $(Join-Path $env:USERPROFILE ".zshrc") -Destination $(Join-Path $msys2_backup_root "zsh/host_userprofile/.zshenv") -Force
}