### Constants variables and computed presets
$UserProfile = $env:USERPROFILE;
$MixinProxyPort = '7890'
$WsaAdbPort = '58526'
$Socks5Proxy = 'socks5://127.0.0.1:7890'
$HttpProxy = 'http://127.0.0.1:7890'
$FiddlerProxyPort = '8888'
$OneDriveRoot = $env:OneDrive   # $env:OneDriveConsumer
$PwshProfileDir = $PSScriptRoot
$CustomModulesDir = Join-Path $PwshProfileDir '\Modules\user-custom'
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
function PwshProfile {notepad $profile}
function PwshProfileCode {code $profile}
function ShowProfileMember {$profile | Get-Member}
function OpenProfileDir {explorer $PwshProfileDir}
Set-Alias ps-prof PwshProfile
Set-Alias settings PwshProfile
Set-Alias config PwshProfile
Set-Alias profile PwshProfileCode

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
Set-Alias yarn-proxy SetYarnProxyHttp
Set-Alias npm-proxy SetNpmProxyHttp
Set-Alias pnpm-proxy SetPnpmProxyHttp
Set-Alias git-proxy SetGitProxySocks5
Set-Alias wsa-proxy SetWsaProxy
Set-Alias wsa-fiddler SetWsaFiddler

### Alias for utilities
Set-Alias reboot Restart-Computer
Set-Alias alias Set-Alias
Set-Alias getcmd Get-Command # `where` ?

### Alias for scripts and functions
function ShowWlanBssid {netsh wlan show networks mode=bssid}
Set-Alias wlan-bssid ShowWlanBssid
function GetNowDateAndTime {Get-Date -format "yyyy-MM-dd HH:mm:ss"}
function GetNowDateAndTimeAndWeekday {Get-Date -format "yyyy-MM-dd HH:mm:ss dddd"}
function GetNowDateAndTimeThenCopyToClipboard {GetNowDateAndTime | Set-Clipboard}
Set-Alias now GetNowDateAndTime
Set-Alias cp-now GetNowDateAndTimeThenCopyToClipboard
function AdbConnectWsa {adb connect 127.0.0.1:$WsaAdbPort}
Set-Alias adb-wsa AdbConnectWsa
function StartOpenSSHServer {Start-Service sshd}
function StopOpenSSHServer {Stop-Service sshd}
function RestartOpenSSHServer {Restart-Service sshd}
Set-Alias start-sshd StartOpenSSHServer
Set-Alias stop-sshd StopOpenSSHServer
Set-Alias restart-sshd RestartOpenSSHServer
function Get-CommandLocation {param([string]$CommandName);$Command = Get-Command $CommandName;$Command.Source}
Set-Alias where-cmd Get-CommandLocation

### Load customized user scripts and modules
function Invoke-CustomModules {
    param([string]$Path,[switch]$Verbose);
    $CustomModules = Get-ChildItem -Path $Path -Filter *.ps1;
    if ($Verbose) {Write-Host $CustomModules}
    foreach ($module in $CustomModules) {. $module.FullName}
}
. Invoke-CustomModules -Path $CustomModulesDir
. Invoke-CustomModules -Path $LocalCustomModulesDir