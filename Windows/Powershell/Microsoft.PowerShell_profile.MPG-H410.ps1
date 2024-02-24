### Initialize Oh-My-Posh Ver 3
$OhMyPosh3Theme = Join-Path $PwshProfileDir '\themes\chips-modifiled.omp.json'
oh-my-posh init pwsh --config $OhMyPosh3Theme | Invoke-Expression
### Initialize Oh-My-Posh Ver 2
# Import-Module posh-git
# Import-Module oh-my-posh
# Set-Theme robbyrussell

### Set Environment Path
$MSYS2_HOME = 'C:\Apps\msys64'

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
