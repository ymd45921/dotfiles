### Items to copy
$PowershellCoreProfileDir = Split-Path $PROFILE
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
New-DirectoryRecursively -Path (Join-Path $PSScriptRoot "/Terminal/")
Copy-Item -Path $TerminalSettingsPath -Destination (Join-Path $PSScriptRoot "/Terminal/") -Force