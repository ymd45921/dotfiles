### Constants variables and computed presets
$UserProfile = $env:USERPROFILE;
$MixinProxyPort = '7890'
$WsaAdbPort = '58526'
$ProxyServer = '127.0.0.1'
$Socks5Proxy = "socks5://${ProxyServer}:7890"
$HttpProxy = "http://${ProxyServer}:7890"
$FiddlerProxyPort = '8888'
$OneDriveRoot = $env:OneDriveConsumer
$PwshProfileDir = $PSScriptRoot
$CustomModulesDir = Join-Path $PSScriptRoot '\Modules\user-custom'
$LocalCustomModulesDir = Join-Path $CustomModulesDir $env:COMPUTERNAME

# path to executables
$OneDriveExecutable = "$env:ProgramFiles\Microsoft OneDrive\OneDrive.exe"
$MsEdgeExecutable = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"

### Utilities to load customized user scripts and modules
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
    param([Parameter(Mandatory = $true)][string]$Path);
    if (Test-Path $Path) { . $Path }

}

### Alias for configure Powershell profile
function Open-Profile {open $profile}
function OpenProfileDir {explorer $PwshProfileDir}
Set-Alias ps-prof Open-Profile
Set-Alias profile $profile

### Alias for setting proxy
function Get-WinNetHostIP {
    $WinNetHostIP = '127.0.0.1'
    try {
        $WinNetHostIP = $(Get-NetIPAddress -InterfaceAlias 'vEthernet (WSL)' -AddressFamily IPV4 -ErrorAction Stop).IPAddress 
    } catch {
        # WSL winnet host is not exists.
    }
    return $WinNetHostIP
}
Set-Alias wslhost Get-WinNetHostIP
function Get-WslIP {
    # wsl.exe -d Ubuntu -e ip addr show eth0 | grep -oP '(?<=inet\s)\d+\.\d+\.\d+\.\d+'
    wsl ifconfig eth0 | Select-String -Pattern 'inet ([\d\.]+)' | ForEach-Object { $_.Matches.Groups[1].Value }
    # wsl hostname -I
}
Set-Alias wslip Get-WslIP
# todo: refactor proxy settings
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
Set-Alias msedge $MsEdgeExecutable # or install from winget
Set-Alias edge $MsEdgeExecutable
Set-Alias onedrive $OneDriveExecutable

### Alias for Programs and Applications
$ProgramFiles = $env:ProgramFiles
$ProgramFilesX86 = ${env:ProgramFiles(x86)}
function Get-CommandPath {
    [CmdletBinding()] # Add Common Parameters like -ErrorAction to function
    param( # ? any other important parameters pass to Get-Command?
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    $Command = Get-Command $Name
    while ($Command.CommandType -eq 'Alias') {
        $Command = Get-Command $Command.Definition
    }
    if ($Command.CommandType -eq 'Application') {
        return $Command.Source
    }
    return $Name # Type is 'Function' or 'Cmdlet'

}
# ! Tooooooo slow
function Find-ProgramPath { # todo: uncompleted logic
    param(
        [string]$ProgramName,
        [string[]]$Hint = @(),
        [switch]$Verbose = $false
    )
    $ProgramPath = Get-CommandPath $ProgramName -ErrorAction SilentlyContinue
    if ($ProgramPath) { return $ProgramPath }
    if ($Hint.Length -eq 0) { $Hint = @($ProgramName) }
    for ($i = 0; $i -lt $Hint.Length; $i++) {
        $ProgramPath = Get-CommandPath $Hint[$i] -ErrorAction SilentlyContinue
        if ($ProgramPath) { return $ProgramPath }
        elseif ($Verbose) { Write-Host "Searching Command $Hint[$i]... Failed." }
    }
    $ExecutableExtensions = $env:PATHEXT.ToLower() -split ';'
    for ($i = 0; $i -lt $Hint.Length; $i++) {
        for ($j = 0; $j -lt $Hint.Length; $j++) {
            for ($k = 0; $k -lt $ExecutableExtensions.Length; $k++) {
                $TestPath = Join-Path $ProgramFiles $Hint[$i] "$Hint[$j]$ExecutableExtensions[$k]"
                $ProgramPath = Get-CommandPath $TestPath -ErrorAction SilentlyContinue
                if ($ProgramPath) { return $ProgramPath }
                $TestPath = Join-Path $ProgramFilesX86 $Hint[$i] "$Hint[$j]$ExecutableExtensions[$k]"
                $ProgramPath = Get-CommandPath $TestPath -ErrorAction SilentlyContinue
                if ($ProgramPath) { return $ProgramPath }
            }
        }
    }
    return $null
}
# ! Also tooooo slow
# $ProgramsToFind = @(
#     @{ 
#         Program = 'WinRAR' 
#         Hint = @('Rar', 'WinRar') 
#         Path = $null
#     },
#     @{ 
#         Program = '7-Zip' 
#         Hint = @('7z', '7-Zip') 
#         Path = $null
#     }
# )
# for ($i = 0; $i -lt $ProgramsToFind.Length; $i++) {
#     $Program = $ProgramsToFind[$i]
#     $Program.Path = Find-ProgramPath -ProgramName $Program.Program -Hint $Program.Hint
#     if ($Program.Path) { 
#         Set-Alias $Program.Program $Program.Path 
#         if ($Program.Hint.Length -gt 0) {
#             Set-Alias $Program.Hint[0] $Program.Path
#         }
#     }
# }
# $Program = $null
# $ProgramsToFind = $null

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
function Start-OpenSSHServer {Start-Service sshd}
function Stop-OpenSSHServer {Stop-Service sshd}
function Restart-OpenSSHServer {Restart-Service sshd}
Set-Alias sshd-start Start-OpenSSHServer
Set-Alias sshd-stop Stop-OpenSSHServer
Set-Alias sshd-restart Restart-OpenSSHServer
function Get-CommandLocation { # temporarily as which
    param([string]$Name); $Command = Get-Command $Name;
    while ($Command.CommandType -eq 'Alias') { $Command = Get-Command $Command.Definition }
    $Command.CommandType -eq 'Application' ? $Command.Source : $Command.Name
}
Set-Alias where-cmd Get-CommandLocation
Set-Alias which Get-CommandLocation
Set-Alias open Start-Process # emulate Mac open; open = Start-Process = explorer
Set-Alias chmod attrib
function Stop-ApplicationByDir {param([string]$Path); Get-Process | Where-Object {$_.Path -eq $Path} | Stop-Process}
Set-Alias shut Stop-ApplicationByDir
function Test-AdminPrivilege {([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)} # Test-Administrator
Set-Alias is-admin Test-AdminPrivilege
function Start-AdminTerminal {Start-Process wt -Verb runAs} # Will open a new window. Any solution?
Set-Alias su Start-AdminTerminal
function Reset-OneDrive {
    # Stop-Process -Name OneDrive -Force; 
    &$OneDriveExecutable /reset
    Start-Process -FilePath $OneDriveExecutable
} # onedrive /reset
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
function Add-WindowsDefenderExclusionRule {
    param(
        [Parameter(Position=0, ValueFromRemainingArguments=$true)]
        [string[]]$Paths
    )
    if (-not $(Test-Administrator)) {
        Write-Error "Adding Windows Defender exclusion rules requires admin privilege."
        return
    }
    $existingExclusions = Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
    foreach ($path in $Paths) {
        if (-not ($existingExclusions -contains $path)) {
            $existingExclusions += $path
        }
    }
    Set-MpPreference -ExclusionPath $existingExclusions
}
function Invoke-CommandAsAdmin { # ! not work
    param([Parameter(Mandatory = $true)][ValidateNotNullOrEmpty()][string]$Command)
    Start-Process pwsh -Verb runAs -ArgumentList '-ExecutionPolicy Bypass -Command `"Invoke-Expression -Command ""$Command""`" '
}
function Close-MonitorAsync {
    Start-Job -ScriptBlock {
        Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class Monitor {
        [DllImport("user32.dll", EntryPoint="SendMessage", CharSet=CharSet.Auto)]
        public static extern IntPtr SendMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);
        public static void TurnOff() {
            SendMessage(-1, 0x0112, 0xF170, 2);
        }
    }
"@
    [Monitor]::TurnOff()
    } | Out-Null
}
function Lock-WorkstationAsync {
    Start-Job -ScriptBlock {
        Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class LockWorkstation {
        [DllImport("user32.dll", EntryPoint="LockWorkStation", CharSet=CharSet.Auto)]
        public static extern bool Lock();
    }
"@
    [LockWorkstation]::Lock()
    } | Out-Null
}
function Lock-WorkstationAndTurnOffMonitor {
    $nircmd = Get-Command -Name nircmd -ErrorAction SilentlyContinue
    if ($null -ne $nircmd) {
        & $nircmd monitor off
    } else {
        Close-MonitorAsync
    }
    rundll32.exe user32.dll,LockWorkStation
}
Set-Alias Lock-Workstation Lock-WorkstationAndTurnOffMonitor
Set-Alias lock Lock-WorkstationAndTurnOffMonitor

. Initialize-CustomModules
. Invoke-ScriptIfExists -Path $PwshProfileDir\Microsoft.PowerShell_profile.$env:COMPUTERNAME.ps1
Set-Alias reload $profile

# Setup-VSCodium
function Install-VSCodium {
    $codium = Get-Command -Name codium -ErrorAction SilentlyContinue
    if ($null -eq $codium) {
        Write-Host 'Installing VSCodium...'
        winget install VSCodium.VSCodium | Out-Null
        $VSCodium = "$env:ProgramFiles\VSCodium\VSCodium.exe"
        if (-not (Test-Path $VSCodium)) {
            $VSCodium = "${env:ProgramFiles(x86)}\VSCodium\VSCodium.exe"
            if (-not (Test-Path $VSCodium)) {
                $VSCodium = "${env:LocalAppData}\Programs\VSCodium\VSCodium.exe"
            }
        }
    } else {
        if ($codium.CommandType -eq 'Alias') {
            $codium = Get-Command $codium.Definition
        } 
        if ($codium.Source -match '\.cmd$') {
            $VSCodium = $(Resolve-Path -RelativeBasePath "$([System.IO.Path]::GetDirectoryName($codium.Source))" -Path "..\VSCodium.exe").Path
        } else { # ? $codium.Source -match '\.exe$'
            $VSCodium = $codium.Source
        }
    }
    if (Test-Path $VSCodium) {
        return $VSCodium
    } else {
        throw "VSCodium installation failed."
    }
}
function Initialize-VSCodium {
    $VSCodium = Install-VSCodium
    $product = Join-Path "$([System.IO.Path]::GetDirectoryName($VSCodium))" "resources\app\product.json"
    if (Test-Path $product) {
        $productJson = Get-Content $product -Raw | ConvertFrom-Json
        $productJson.extensionsGallery = @{
            serviceUrl = 'https://marketplace.visualstudio.com/_apis/public/gallery'
            itemUrl = 'https://marketplace.visualstudio.com/items'
        }
        $productJson | ConvertTo-Json -Depth 10 | Set-Content $product
    }
}

# Simple parser to process *.ini files
function Read-IniFile {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        throw "File not found: $Path"
    }

    $ini = @{}
    $section = ""

    foreach ($line in Get-Content -Path $Path) {
        $line = $line.Trim()
        if ($line -match '^\[(.+)\]$') {
            $section = $matches[1]
            $ini[$section] = @{}
        } elseif ($line -match '^(.*?)=(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $ini[$section][$key] = $value
        }
    }

    return $ini
}
function Format-IniFile {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$Data
    )

    $content = ""
    foreach ($section in $Data.Keys) {
        $content += "[$section]`r`n"
        foreach ($key in $Data[$section].Keys) {
            $content += "$key=$($Data[$section][$key])`r`n"
        }
        $content += "`r`n"
    }
    return $content
}
function Write-IniFile {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [hashtable]$Data,
        [switch]$Force = $false,
        [switch]$Append = $false,
        [ValidateSet(
            "Ascii", "BigEndianUnicode", "Byte", "Default", 
            "OEM", "Unicode", "UTF7", "UTF8", "UTF8BOM", 
            "UTF8NoBOM", "UTF32", IgnoreCase = $true
        )]
        [string]$Encoding = "OEM"
    )

    $content = Format-IniFile -Data $Data
    if ($Append) {
        Add-Content -Path $Path -Value $content -Encoding $Encoding
    } else {
        if ((Test-Path $Path) -and (-not $Force)) {
            throw "File already exists: $Path"
        }
        Set-Content -Path $Path -Value $content -Encoding $Encoding
    }
}
function Write-IniFileByASNI {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [hashtable]$Data,
        [switch]$Force = $false
    )

    $content = Format-IniFile -Data $Data
    if ((Test-Path $Path) -and (-not $Force)) {
        throw "File already exists: $Path"
    }
    # * It's seems OEM option will encode the content to ANSI.
    Set-Content -Path $Path -Value $content -Encoding OEM
}

# Set Localized Name for a folder
function Set-LocalizedFolderName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [Parameter(Mandatory = $true)]
        [string]$Name
    )
    if (-not (Test-Path $Path -PathType Container)) {
        throw "Path is not a directory."
    }
    $desktopIni = Join-Path $Path 'desktop.ini'
    $desktopIniObject = @{}
    if (-not (Test-Path $desktopIni)) {
        New-Item -Path $desktopIni -ItemType File | Out-Null
    } else {
        $desktopIniObject = Read-IniFile -Path $desktopIni
    }
    if (-not $desktopIniObject.ContainsKey('.ShellClassInfo')) {
        $desktopIniObject['.ShellClassInfo'] = @{}
    }
    $desktopIniObject['.ShellClassInfo']['LocalizedResourceName'] = $Name
    Write-IniFileByANSI -Path $desktopIni -Data $desktopIniObject -Force
    $desktopIniAttrib = (Get-ItemProperty -Path $desktopIni -Name Attributes).Attributes
    # ([System.IO.FileAttributes]::System + [System.IO.FileAttributes]::Hidden) = 6
    Set-ItemProperty -Path $desktopIni -Name Attributes -Value ($desktopIniAttrib -bor 6)
}
function Set-DirectoryLocalName {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$Name
    )
    if (-not $Name) {
        $Name = $Path
        $Path = $PWD
    }
    Set-LocalizedFolderName -Path $Path -Name $Name
}
Set-Alias setname Set-DirectoryLocalName

#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58

