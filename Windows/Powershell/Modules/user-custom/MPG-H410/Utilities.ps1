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