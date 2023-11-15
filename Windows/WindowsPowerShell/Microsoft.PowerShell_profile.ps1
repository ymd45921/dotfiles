### 核心功能
$PowershellCoreProfile = Join-Path $env:USERPROFILE "/Documents/Powershell/Microsoft.Powershell_profile.ps1"
function Test-AdminPrivilege {
    ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
} 
# * Windows Powershell 中不包含 Test-Administrator
Set-Alias Test-Administrator Test-AdminPrivilege
if (Test-Administrator) {
    Set-ExecutionPolicy -Scope AllUsers -ExecutionPolicy RemoteSigned
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
} else {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
}
function Set-Proxy {
    $Env:http_proxy="$HttpProxy";
    $Env:https_proxy="$HttpProxy";
    $Env:all_proxy="$HttpProxy";
}
function Test-ModuleImported {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    $importedModules = Get-Module | Select-Object -ExpandProperty Name
    return $importedModules -contains $Name
}
function Start-AdminTerminal {
    Start-Process wt -Verb runAs
}
function Get-FileMD5 {
    param([string]$Path); 
    return (Get-FileHash -Path $Path -Algorithm MD5).Hash
}
function Import-CoreProfile {
    . $PowershellCoreProfile
}
function Get-CommandLocation {
    param([string]$CommandName);
    $Command = Get-Command $CommandName;
    $Command.Source
}
function Get-NowDateAndTime {
    $now = (Get-Date -format "yyyy-MM-dd HH:mm:ss")
    Set-Clipboard $now
    return $now
}


### 核心别名
Set-Alias Test-Module Test-ModuleImported
Set-Alias test-admin Test-AdminPrivilege
Set-Alias md5 Get-FileMD5
Set-Alias sha256 Get-FileSHA256
Set-Alias open Start-Process
Set-Alias where-cmd Get-CommandLocation
Set-Alias su Start-AdminTerminal
Set-Alias is-admin Test-Administrator
Set-Alias now Get-NowDateAndTime
Set-Alias reboot Restart-Computer
Set-Alias alias Set-Alias
Set-Alias verbs Get-Verb
Set-Alias proxy Set-Proxy
Set-Alias reload $PROFILE