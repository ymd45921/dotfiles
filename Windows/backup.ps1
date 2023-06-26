$PowershellCoreProfileDir = Split-Path $PROFILE
$Destination = Join-Path $PSScriptRoot "/Powershell"
Copy-Item -Path $PowershellCoreProfileDir -Destination $Destination -Recurse