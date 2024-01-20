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
function Confirm-AdbExists { if (-not $(Get-Command "adb" -ErrorAction SilentlyContinue)) { winget install --id Google.PlatformTools --source winget; exit } } # todo: refresh-env is need!
function GetWsaNetHostIP {Confirm-AdbExists; adb connect 127.0.0.1:$WsaAdbPort | Out-Null; adb shell echo '`ip route list match 0 table all scope global | cut -F3`'}
function SetWsaProxy {Confirm-AdbExists; adb connect 127.0.0.1:$WsaAdbPort; adb shell settings put global http_proxy "$(GetWsaNetHostIP):$MixinProxyPort"}
function RemoveWsaProxy {Confirm-AdbExists; adb connect 127.0.0.1:$WsaAdbPort; adb shell settings put global http_proxy :0}
function SetWsaFiddler {Confirm-AdbExists; adb connect 127.0.0.1:$WsaAdbPort; adb shell settings put global http_proxy "$(GetWsaNetHostIP):$FiddlerProxyPort"}
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
Set-Alias webrq Invoke-WebRequest
Set-Alias exar Expand-Archive
Set-Alias extract Expand-Archive

### Alias for scripts and functions
function ShowWlanBssid {netsh wlan show networks mode=bssid}
Set-Alias wlan-bssid ShowWlanBssid
function Get-NowDateAndTime {Get-Date -format "yyyy-MM-dd HH:mm:ss"}
function Get-NowDateAndTimeAndWeekday {Get-Date -format "yyyy-MM-dd HH:mm:ss dddd"}
function Get-NowDateAndTimeThenCopyToClipboard {Get-NowDateAndTime | Set-Clipboard}
function Get-AppOneDriveSyncPath {param([string]$AppName); return (Join-Path $OneDriveRoot $AppName)}
function Get-TimeStamp { return (Get-Date).ToUniversalTime().Ticks }
Set-Alias now Get-NowDateAndTime
Set-Alias cp-now Get-NowDateAndTimeThenCopyToClipboard
Set-Alias timestamp Get-TimeStamp
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
function Get-RelativePath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$BasePath = ""
    )
    if ($BasePath.length -eq 0) {
        return Resolve-Path $Path -Relative
    } else {
        $_dir = $(Get-Location).Path
        Set-Location $BasePath
        if (-not $?) { Set-Location $_dir }
        $_ret = Resolve-Path $Path -Relative
        Set-Location $_dir
        return $_ret
    }
}
function Start-Download {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,
        [string]$To = $null,
        [System.Int32]$RetryCount = 3 
    )
    if (($To -eq $null) -or ($To.length -eq 0)) {
        $out = Join-Path $(Get-Location).Path [System.IO.Path]::GetFileName($Url)
    } else { $out = $To }
    while ($RetryCount -gt 0) {
        $RetryCount = $RetryCount - 1
        curl.exe -LJ $Url -o $out
        if ($LASTEXITCODE -eq 0) { break } # (-not $?)
        elseif ($RetryCount -ne 0) {
            Write-Host "curl.exe exit with code $LASTEXITCODE, retrying remains $RetryCount times..."
        } else { $out = ""; Write-Error "Download failed." } # Set $? = $false
    }
    return $out
}
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
function Invoke-ScriptIfExists {
    param([Parameter(Mandatory = $true)][string]$Path,[switch]$Verbose = $false);
    if (Test-Path $Path) {
        if ($Verbose) {Write-Host "Invoke script $Path"}
        . $Path
    }

}
. Initialize-CustomModules
. Invoke-ScriptIfExists -Path $PwshProfileDir\Microsoft.PowerShell_profile.$env:COMPUTERNAME.ps1
Set-Alias reload $profile