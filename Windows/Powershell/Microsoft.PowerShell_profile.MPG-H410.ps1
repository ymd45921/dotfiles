### Initialize Oh-My-Posh Ver 3
$OhMyPosh3Theme = Join-Path $PwshProfileDir '\themes\chips-modifiled.omp.json'
oh-my-posh init pwsh --config $OhMyPosh3Theme | Invoke-Expression
### Initialize Oh-My-Posh Ver 2
# Import-Module posh-git
# Import-Module oh-my-posh
# Set-Theme robbyrussell

### Set Environment Path
$MSYS2_HOME = 'C:\Apps\msys64'
$MSYS2_USERPROFILE = Join-Path $MSYS2_HOME "home\$env:USERNAME"

### Functions related to environment?
### todo: move to generic profile?
function Start-Msys2 {
    param([string]$Shell = 'bash')
    # todo: detect msys2_shell.cmd and support more parameters
    # info: using parameters set?
    $MSYS2_SHELL = Join-Path $MSYS2_HOME msys2_shell.cmd 
    &"$MSYS2_SHELL" -mingw64 -defterm -no-start -use-full-path -here -shell $Shell
}
function Start-Msys2WithZsh {
    Start-Msys2 -Shell zsh
}
Set-Alias msys2 Start-Msys2
Set-Alias zsh Start-Msys2WithZsh

function Reset-Msys2UserProfileSymbolicLink {
    param([switch]$Force = $false);
    $SYMLINK_ITEMS = @('.bashrc', '.bash_profile', '.profile', '.zshrc', '.zprofile', '.p10k.zsh', '.oh-my-zsh');
    for ($i = 0; $i -lt $SYMLINK_ITEMS.Length; $i++) {
        $PROFILE_ITEM = Join-Path $MSYS2_USERPROFILE $SYMLINK_ITEMS[$i]
        $SYMLINK_ITEM = Join-Path $env:USERPROFILE $SYMLINK_ITEMS[$i]
        if (Test-Path $PROFILE_ITEM) {
            if (Test-Path $SYMLINK_ITEM) {
                if ($Force) {
                    Remove-Item $SYMLINK_ITEM
                } else {
                    Write-Host "Symbolic link or file $SYMLINK_ITEM is already exists."
                    continue
                }
            }
            New-Item -ItemType SymbolicLink -Path $SYMLINK_ITEM -Value $PROFILE_ITEM
        }
    }
}