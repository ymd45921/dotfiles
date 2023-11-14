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

### Install fonts for current user
function Install-FontsForCurrentUser {
    [CmdletBinding()]
    Param (
        [string[]]$Files,
        [string]$File
    )
    $objShell = New-Object -ComObject Shell.Application
    $Fonts = $objShell.NameSpace(20)
    If (!($Files -eq $null)){  Get-ChildItem "$Files\*.ttf" | ForEach-Object {$Fonts.CopyHere($_.FullName)} }
    ElseIf (!($File -eq $null)){ $Fonts.CopyHere($File) }
}
Set-Alias Install-Fonts Install-FontsForCurrentUser
Set-Alias Add-Fonts Install-FontsForCurrentUser

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