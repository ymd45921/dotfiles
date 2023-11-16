### Convert videos to GIF (simple)
function Convert-VideoToGIF {
    param(
        [string]$InputFile,
        [string]$Output = "output.gif",
        [int]$Loop = 0
    )
    if (-not $InputFile) {
        Write-Host "No input file."
        return  # Powershell function never stop by non-0?
    }
    if (Test-Path $Output) {
        Write-Host "Default output file already exists."
        return
    }
    ffmpeg -i $InputFile -c:v gif -loop $Loop $Output
}
Set-Alias mp42gif Convert-VideoToGIF

### Add Block Rules for an executable
function Add-FirewallBlockRule {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [string]$Path
    )
    if (-not $Path -and (Test-Path $Name)) {
        $Path = $Name
        $Name = Split-Path -Leaf $Name
    }
    if (Test-Path $Path) {
        $action = "Block"
        $direction = "Outbound", "Inbound"
        if (-not (Test-Administrator)) {
            Write-Error "Adding firewall block rules requires admin privilege."
            # Write-Host "Trying getting admin privilege through UAC and run commands."
            # Invoke-CommandAsAdmin "Add-FirewallBlockRule -Name $Name -Path $Path" 
        } else {
            foreach ($dir in $direction) {
                $rule = New-NetFirewallRule -DisplayName $Name -Direction $dir -Action $action -Program $Path -Enabled True
                if (-not $rule) {Write-Error "Adding firewall block rules failed."; return }
            }
        }
    }
}
Set-Alias Block-AppNetworkAccess Add-FirewallBlockRule
Set-Alias netbl Block-AppNetworkAccess

### Calculate all hashes of a file
function Get-FileAllHash {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [string]$FilePath, 
        [switch]$Print      # cannot access member after formatting
    )
    $hashAlgorithms = @('MD5', 'SHA1', 'SHA256', 'SHA384', 'SHA512')
    $hashesObject = (Get-FileHashes -FilePath $FilePath -Algorithms $hashAlgorithms)
    if ($Print) { return ($hashesObject | Format-Table -AutoSize) }
    return $hashesObject
}
Set-Alias all-hash Get-FileAllHash
Set-Alias hashes Get-FileAllHash

### Compare 2 file by hash
function Compare-FileByHash {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [string]$Path1,
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path $_ -PathType Leaf})]
        [string]$Path2
    )
    $hash1 = (Get-FileHash -Path $Path1).Hash
    $hash2 = (Get-FileHash -Path $Path2).Hash
    $md51 = Get-FileMD5 $Path1
    $md52 = Get-FileMD5 $Path2
    return (($hash1 -eq $hash2) -and ($md51 -eq $md52))
}

### Add exclusion path to Windows Defender
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

### Process output of `winget search --source=msstore`
function Import-WinGet {
    $Name = "Microsoft.WinGet.Client"
    if (-not $(Test-Module $Name)) {
        Import-Module $Name
        if (-not $(Test-Module $Name)) {
            Install-Module $Name -Scope AllUsers
            Import-Module $Name
            if (-not $(Test-Module $Name)) {
                Repair-WinGetPackageManager
                Install-Module $Name -Scope AllUsers
                Import-Module $Name
                return (Test-Module $Name)
            } 
        }
    }
    return $true
}
Set-Alias Install-WinGet Import-WinGet
function Get-AppIdInWinStoreByWinGet {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Search
    )

    # https://github.com/microsoft/winget-cli/issues/3805#issuecomment-1778517008
    # Only Powershell install for machine can use WinGet, not for user (Windows Store)
    if ($(where-cmd pwsh) -ne "C:\Program Files\PowerShell\7\pwsh.exe") {
        Write-Host "Only Powershell install for all users can use WinGet cmdlet."
        Write-Host "Using fallback winget.exe to find..."
        # Has encoding issue...
        $output = winget search "$Search" --source=msstore
        $lines = $output.Trim() -split "`r?`n" | ForEach-Object { $_.Trim() }
        $result = @()
        $foundSeparator = $false
        for ($i = $lines.Count - 1; $i -ge 0; $i--) {
            $line = $lines[$i]
            $columns = $line -split '\s+'
            if ($columns.Count -eq 3) {
                $obj = [PSCustomObject]@{
                    Name = $columns[0]
                    ID = $columns[1]
                    Version = $columns[2]
                }
                $result += $obj
            }
            elseif ($columns[0] -eq '-') {
                $foundSeparator = $true
                break
            }
        }
        if ($foundSeparator) {
            $result = $result | Sort-Object -Property Name
        }
        if ($result.length -gt 1) { return $result[1].ID }
        else { Write-Error "Noting found!" }
    } else {
        try {
            Import-WinGet
            $result = Find-WinGetPackage -Name "$Search" -Source msstore
            if ($result.length -eq 0) {
                Write-Error "Noting found!"
            } else { return $result[0].Id }
        } catch {
            Write-Error $_
        }
    }
}
# Legacy parse winget.exe search msstore output.
# todo Encoding issue. Powershell Desktop CN using US-ASCII
function Format-WingetSearchOutput {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$SearchString
    )
    
    $InputString = winget search "$SearchString" --source=msstore
    $lines = $InputString -split "`r?`n"
    $output = @()

    for ($i = 1; $i -lt $lines.Count; $i++) {
        $line = $lines[$i].Trim()
        if (![string]::IsNullOrEmpty($line)) {
            $cols = $line -split "\s+";
            if ($cols.length -eq 3) {
                if ($cols[1] -ne "ID") {
                    $output += [PSCustomObject]@{
                        Name = $cols[0]
                        ID = $cols[1]
                        Version = $cols[2]
                    }
                }
            }
        }
    }
    $output
}

### Get Random String
function Get-RandomString {
    param([System.Int]$length = 10)
    $characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    $randomString = -join ($characters | Get-Random -Count $length)
    return $randomString
}
Set-Alias randstr Get-RandomString
### Add Temp folder 
function New-TemporaryDirectory {
    param([string]$Name = "", [switch]$TimeStamp = $false)
    if ($Name.length -eq 0) { $Name = "TempFolder$(Get-TimeStamp)" }
    if ($TimeStamp) {$Name += $(Get-TimeStamp)}
    $tempFolderPath = New-Item -ItemType Directory -Path $env:TEMP -Name $Name
    return $tempFolderPath
}
function New-TemporaryDirectoryPath {
    param([string]$Name) 
    return $(New-TemporaryDirectory -Name $Name -TimeStamp).FullName
}
Set-Alias tmpdir New-TemporaryDirectory
### Downloading file without using Invoke-WebRequest
function Start-DownloadFile {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url,
        [string]$Path = $pwd.Path,
        [string]$Name = "",
        [System.Int32]$RetryCount = 3 
    )
    if ($Name.length -eq 0) {
        $Name = [System.IO.Path]::GetFileName($Url)
    }
    $out = Join-Path $Path $Name
    while ($RetryCount -gt 0) {
        $RetryCount = $RetryCount - 1
        curl.exe -LJ $Url -o $out
        if ($LASTEXITCODE -eq 0) { break } # [boolean]$? in Powershell means last COMMAND
        if ($RetryCount -ne 0) {
            Write-Host "curl exit with code $LASTEXITCODE, retrying remains $RetryCount times"
        } else { Write-Error "Download failed." }
    }
    return $out
}
Set-Alias download Start-DownloadFile
Set-Alias webdl Start-DownloadFile
### Install fonts for current user
# Will show system window & Cannot force install
function Install-FontsForCurrentUser {
    [CmdletBinding()]
    Param (
        [Parameter(Position=0, ValueFromRemainingArguments=$true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Paths
    )
    $objShell = New-Object -ComObject Shell.Application
    $Fonts = $objShell.NameSpace(20)
    $installed = @()
    foreach ($Path in $Paths) {
        if ((Get-Item -Path $Path).PSIsContainer) {
            $Files = @()
            $Files += Get-ChildItem -Path $Path -Filter *.ttf -Recurse
            $Files += Get-ChildItem -Path $Path -Filter *.otf -Recurse
            foreach ($File in $Files) {
                $Fonts.CopyHere($File.FullName)
                if ($?) { $installed += $File }
            }
        } else { $Fonts.CopyHere($Path) }
    }
    # If (!($Files -eq $null)){  Get-ChildItem "$Files\*.ttf" | ForEach-Object {$Fonts.CopyHere($_.FullName)} }
    # ElseIf (!($File -eq $null)){ $Fonts.CopyHere($File) }
    if ($installed.length -gt 0) { 
        Write-Host "Installed following fonts: "
        $installed | ForEach-Object { Write-Host $(Get-RelativePath $_.FullName) } 
    }
}
Set-Alias Install-Fonts Install-FontsForCurrentUser
Set-Alias Add-Fonts Install-FontsForCurrentUser

### Get installed applications from registry
# ? Alternative Get-WinGetPackage
function Get-InstalledApps {
    $INSTALLED = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
    $INSTALLED += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
    $INSTALLED | ?{ ($_.DisplayName -ne $null) -and ($_.DisplayName -ne "") } | sort-object -Property DisplayName -Unique | Format-Table -AutoSize
    return $INSTALLED
}
Set-Alias allapp Get-InstalledApps

#######################################################################################################################
#######################################################################################################################
#######################################################################################################################

### Install or remove fonts for all users
# From Internet
# 1. Copy font-file to C:\Windows\Fonts
# 2. Add an entry in HKLM\Software\Microsoft\Windows NT\CurrentVersion\Fonts
function Install-Font {  
    param (  
        [System.IO.FileInfo]$fontFile  
    )  
    try { 

        #get font name
        $gt = [Windows.Media.GlyphTypeface]::new($fontFile.FullName)
        $family = $gt.Win32FamilyNames['en-us']
        if ($null -eq $family) { $family = $gt.Win32FamilyNames.Values.Item(0) }
        $face = $gt.Win32FaceNames['en-us']
        if ($null -eq $face) { $face = $gt.Win32FaceNames.Values.Item(0) }
        $fontName = ("$family $face").Trim() 
            
        switch ($fontFile.Extension) {  
            ".ttf" {$fontName = "$fontName (TrueType)"}  
            ".otf" {$fontName = "$fontName (OpenType)"}  
        }  

        write-host "Installing font: $fontFile with font name '$fontName'"

        If (!(Test-Path ("$($env:windir)\Fonts\" + $fontFile.Name))) {  
            write-host "Copying font: $fontFile"
            Copy-Item -Path $fontFile.FullName -Destination ("$($env:windir)\Fonts\" + $fontFile.Name) -Force 
        } else {  write-host "Font already exists: $fontFile" }

        If (!(Get-ItemProperty -Name $fontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue)) {  
            write-host "Registering font: $fontFile"
            New-ItemProperty -Name $fontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -PropertyType string -Value $fontFile.Name -Force -ErrorAction SilentlyContinue | Out-Null  
        } else {  write-host "Font already registered: $fontFile" }
            
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($oShell) | out-null 
        Remove-Variable oShell               
                
    } catch {            
        write-host "Error installing font: $fontFile. " $_.exception.message
    }
}
function Uninstall-Font {  
    param (  
        [System.IO.FileInfo]$fontFile  
    )       
    try { 
        #get font name
        $gt = [Windows.Media.GlyphTypeface]::new($fontFile.FullName)
        $family = $gt.Win32FamilyNames['en-us']
        if ($null -eq $family) { $family = $gt.Win32FamilyNames.Values.Item(0) }
        $face = $gt.Win32FaceNames['en-us']
        if ($null -eq $face) { $face = $gt.Win32FaceNames.Values.Item(0) }
        $fontName = ("$family $face").Trim()
            
        switch ($fontFile.Extension) {  
            ".ttf" {$fontName = "$fontName (TrueType)"}  
            ".otf" {$fontName = "$fontName (OpenType)"}  
        }  

        write-host "Uninstalling font: $fontFile with font name '$fontName'"

        If (Test-Path ("$($env:windir)\Fonts\" + $fontFile.Name)) {  
            write-host "Removing font: $fontFile"
            Remove-Item -Path "$($env:windir)\Fonts\$($fontFile.Name)" -Force 
        } else {  write-host "Font does not exist: $fontFile" }

        If (Get-ItemProperty -Name $fontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -ErrorAction SilentlyContinue) {  
            write-host "Unregistering font: $fontFile"
            Remove-ItemProperty -Name $fontName -Path "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts" -Force                      
        } else {  write-host "Font not registered: $fontFile" }
            
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($oShell) | out-null 
        Remove-Variable oShell               
                
    } catch {            
        write-host "Error uninstalling font: $fontFile. " $_.exception.message
    }        
}
function Install-AllFontsInDir {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({Test-Path $_})]
        [string]$FontsDir
    )
    foreach ($FontItem in (Get-ChildItem -Path $FontsDir | 
        Where-Object {($_.Name -like '*.ttf') -or ($_.Name -like '*.otf') })) {  
    Install-Font -fontFile $FontItem.FullName  
    }  
}