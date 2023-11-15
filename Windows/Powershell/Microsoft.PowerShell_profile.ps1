### Constants variables and computed presets
$UserProfile = $env:USERPROFILE;
$MixinProxyPort = '7890'
$WsaAdbPort = '58526'
$Socks5Proxy = 'socks5://127.0.0.1:7890'
$HttpProxy = 'http://127.0.0.1:7890'
$FiddlerProxyPort = '8888'
$OneDriveRoot = $env:OneDrive   # $env:OneDriveConsumer
$PwshProfileDir = $PSScriptRoot
$CustomModulesDir = Join-Path $PSScriptRoot '\Modules\user-custom'
$LocalCustomModulesDir = Join-Path $CustomModulesDir $env:COMPUTERNAME
# $WinNetIPinWSL = $(Get-NetIPAddress -InterfaceAlias 'vEthernet (WSL)' -AddressFamily IPV4)

### Initialize Oh-My-Posh Ver 3
$OhMyPosh3Theme = Join-Path $PwshProfileDir '\themes\chips-modifiled.omp.json'
oh-my-posh init pwsh --config $OhMyPosh3Theme | Invoke-Expression
### Initialize Oh-My-Posh Ver 2
# Import-Module posh-git
# Import-Module oh-my-posh
# Set-Theme robbyrussell

### Alias for configure Powershell profile
function PwshProfile {open $profile}
function ShowProfileMember {$profile | Get-Member}
function OpenProfileDir {explorer $PwshProfileDir}
Set-Alias ps-prof PwshProfile
Set-Alias profile $profile

### Alias for setting proxy
function SetGitProxySocks5 {git config --global http.proxy $Socks5Proxy; git config --global https.proxy $Socks5Proxy}
function SetYarnProxyHttp {yarn config set proxy $HttpProxy; yarn config set https-proxy $HttpProxy}
function SetNpmProxyHttp {npm config set proxy $HttpProxy; npm config set https-proxy $HttpProxy}
function SetPnpmProxyHttp {pnpm config set proxy $HttpProxy; pnpm config set https-proxy $HttpProxy}
function RemoveYarnProxy {yarn config delete proxy; yarn config delete https-proxy}
function RemoveNpmProxy {npm config delete proxy; npm config delete https-proxy}
function RemovePnpmProxy {pnpm config delete proxy; pnpm config delete https-proxy}
# function SetWsaProxyLegacy {adb connect 127.0.0.1:$WsaAdbPort; adb shell settings put global http_proxy "$($WinNetIPinWSL.IPAddress):$MixinProxyPort"}
function GetWsaNetHostIP {adb connect 127.0.0.1:$WsaAdbPort | Out-Null; adb shell echo '`ip route list match 0 table all scope global | cut -F3`'}
function SetWsaProxy {adb connect 127.0.0.1:$WsaAdbPort; adb shell settings put global http_proxy "$(GetWsaNetHostIP):$MixinProxyPort"}
function RemoveWsaProxy {adb connect 127.0.0.1:$WsaAdbPort; adb shell settings put global http_proxy :0}
function SetWsaFiddler {adb connect 127.0.0.1:$WsaAdbPort; adb shell settings put global http_proxy "$(GetWsaNetHostIP):$FiddlerProxyPort"}
function Set-Proxy {$Env:http_proxy="$HttpProxy";$Env:https_proxy="$HttpProxy";$Env:all_proxy="$HttpProxy"}
Set-Alias Set-TerminalProxy Set-Proxy
Set-Alias yarn-proxy SetYarnProxyHttp
Set-Alias npm-proxy SetNpmProxyHttp
Set-Alias pnpm-proxy SetPnpmProxyHttp
Set-Alias git-proxy SetGitProxySocks5
Set-Alias wsa-proxy SetWsaProxy
Set-Alias wsa-fiddler SetWsaFiddler
Set-Alias proxy Set-Proxy

### Alias for utilities
Set-Alias reboot Restart-Computer
Set-Alias alias Set-Alias
Set-Alias getcmd Get-Command # `where` ?
Set-Alias test-admin Test-AdminPrivilege
Set-Alias show-verb Get-Verb # Has default alias "verb"
Set-Alias verbs Get-Verb
Set-Alias hash Get-FileHash

### Alias for scripts and functions
function ShowWlanBssid {netsh wlan show networks mode=bssid}
Set-Alias wlan-bssid ShowWlanBssid
function Get-NowDateAndTime {Get-Date -format "yyyy-MM-dd HH:mm:ss"}
function Get-NowDateAndTimeAndWeekday {Get-Date -format "yyyy-MM-dd HH:mm:ss dddd"}
function Get-NowDateAndTimeThenCopyToClipboard {Get-NowDateAndTime | Set-Clipboard}
function Get-AppOneDriveSyncPath {param([string]$AppName); return (Join-Path $OneDriveRoot $AppName)}
Set-Alias now Get-NowDateAndTime
Set-Alias cp-now Get-NowDateAndTimeThenCopyToClipboard
function AdbConnectWsa {adb connect 127.0.0.1:$WsaAdbPort}
Set-Alias adb-wsa AdbConnectWsa
function StartOpenSSHServer {Start-Service sshd}
function StopOpenSSHServer {Stop-Service sshd}
function RestartOpenSSHServer {Restart-Service sshd}
Set-Alias sshd-start StartOpenSSHServer
Set-Alias sshd-stop StopOpenSSHServer
Set-Alias sshd-restart RestartOpenSSHServer
function Get-CommandLocation {param([string]$CommandName);$Command = Get-Command $CommandName;$Command.Source}
Set-Alias where-cmd Get-CommandLocation
Set-Alias open Start-Process # emulate Mac open; open = Start-Process = explorer
function Stop-ApplicationByDir {param([string]$Path); Get-Process | Where-Object {$_.Path -eq $Path} | Stop-Process}
Set-Alias shut Stop-ApplicationByDir
function Test-AdminPrivilege {([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)} # Test-Administrator
Set-Alias is-admin Test-AdminPrivilege
function Start-AdminTerminal {Start-Process wt -Verb runAs} # Will open a new window. Any solution?
Set-Alias su Start-AdminTerminal
function Set-PowerShellExecutionPolicy {Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned}
function Get-FileMD5 {param([string]$Path); return (Get-FileHash -Path $Path -Algorithm MD5).Hash}
function Get-FileSHA1 {param([string]$Path); return (Get-FileHash -Path $Path -Algorithm SHA1).Hash}
function Get-FileSHA256 {param([string]$Path); return (Get-FileHash -Path $Path -Algorithm SHA256).Hash}
Set-Alias md5 Get-FileMD5
Set-Alias sha1 Get-FileSHA1
Set-Alias sha256 Get-FileSHA256
function Test-ModuleImported {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    $importedModules = Get-Module | Select-Object -ExpandProperty Name
    return $importedModules -contains $Name
}
Set-Alias Test-Module Test-ModuleImported
function Get-FileHashes {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [string]$FilePath, 
        [Parameter(Position=1, ValueFromRemainingArguments=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Algorithms
    )
    $hashAlgorithms = $Algorithms
    $hashes = @{}
    foreach ($algorithm in $hashAlgorithms) {
        $hash = (Get-FileHash -Path $FilePath -Algorithm $algorithm).Hash
        $hashes[$algorithm] = $hash
    }
    $hashes['Path'] = $FilePath
    $hashesObject = [PSCustomObject]$hashes
    return $hashesObject
}
function Invoke-CommandAsAdmin { # ! not work
    param([Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Command)
    Start-Process pwsh -Verb runAs -ArgumentList '-ExecutionPolicy Bypass -Command `"Invoke-Expression -Command ""$Command""`" '
}

### Load customized user scripts and modules
function Invoke-CustomModules {
    param([string]$Path,[switch]$Verbose);
    $CustomModules = Get-ChildItem -Path $Path -Filter *.ps1;
    if ($Verbose) {Write-Host $CustomModules}
    foreach ($module in $CustomModules) {. $module.FullName}
}
function Initialize-CustomModules {
    . Invoke-CustomModules -Path $CustomModulesDir
    . Invoke-CustomModules -Path $LocalCustomModulesDir
}
. Initialize-CustomModules
Set-Alias reload $profile