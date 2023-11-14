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