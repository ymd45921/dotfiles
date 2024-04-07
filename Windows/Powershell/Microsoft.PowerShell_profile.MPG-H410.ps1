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
$UE_PROJECT_ROOT = Join-Path $env:USERPROFILE "Documents\Unreal Projects"

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

# Fuctions related to WSL2 and SSH
function Set-WslPortProxy {
    param([string]$Port='2222');
    $local:WSL_HOSTNAME = $(Get-WslIP)
    $local:WSLL_SSH_PORT = $(wsl cat /etc/ssh/sshd_config | Select-String -Pattern 'Port (\d+)' | ForEach-Object { $_.Matches.Groups[1].Value })
    netsh interface portproxy set v4tov4 listenport=$Port listenaddress=0.0.0.0 connectport=$local:WSLL_SSH_PORT connectaddress=$local:WSL_HOSTNAME
    netsh advfirewall firewall add rule name=”Open Port $Port for WSL2” dir=in action=allow protocol=TCP localport=$Port
}
function Start-WslSshd {
    wsl sudo service ssh start
    Set-WslPortProxy
}

# Cmdlets about Unreal Engine Projects
function Get-UEProjectPath {
    param([string]$Project);
    $ProjectInfo = [PSCustomObject]@{
        Name = $null
        Directory = $null
        ProjectFile = $null
        SolutionFile = $null
    } # note: should not modified unless ensure the project exists.
    if (Test-Path $Project) { # input as a file or directory
        if (-not (Get-Item $Project).PSIsContainer) {
            $FileExtension = (Get-Item $Project).Extension
            if ($FileExtension -eq ".sln") {
                # todo: try find related .uproject file
                throw "Not implemented yet"
            } elseif ($FileExtension -ne ".uproject") {
                throw "Invalid project file '$Project'"
            }
            $Project = (Get-Item $Project).DirectoryName
        }
    } elseif ($Project -match '[\\/]') {
        # input is an invalid path, do not search
        if ($Project -match '\.uproject$') {
            $Project = (Get-Item $Project).DirectoryName
            if (-not (Test-Path $Project)) {
                throw "Invalid project path '$Project'"
            }
        }
    } else { # todo: search project in an universal search path?
        $Project = $Project -replace '\.uproject$'
        $Project = Join-Path $UE_PROJECT_ROOT $Project
        if (-not (Test-Path $Project)) {
            throw "Project directory '$Project' not found"
        }
    }
    # info: $Project is a directory may contain .uproject file
    $BaseName = (Get-Item $Project).BaseName
    $Project = (Get-Item $Project).FullName
    if (Test-Path (Join-Path $Project "$BaseName.uproject")) {
        $ProjectInfo.ProjectFile = Join-Path $Project "$BaseName.uproject"
        $ProjectInfo.Name = $BaseName
        $ProjectInfo.Directory = $Project
    } else {
        $uprojects = Get-ChildItem -Path $Project -Filter *.uproject
        if ($uprojects.Count -eq 1) {
            $ProjectInfo.ProjectFile = $uprojects[0].FullName
            $ProjectInfo.Name = $uprojects[0].BaseName
            $ProjectInfo.Directory = $uprojects[0].DirectoryName
        } elseif ($uprojects.Count -gt 1) {
            throw "Too many .uproject files found in '$Project'"
        } else {
            throw "No .uproject file found in '$Project'"
        }
    }
    $Solution = Join-Path $Project "$BaseName.sln"
    if (Test-Path $Solution) {
        $ProjectInfo.SolutionFile = $Solution
    }
    return $ProjectInfo
}
function Open-UEProject {
    param([string]$Project, [string]$Command = 'Start-Process');
    $ProjectInfo = Get-UEProjectPath -Project $Project
    $CommandInfo = Get-Command $Command
    $CommandID = [System.IO.Path]::GetFileNameWithoutExtension($CommandInfo.Path).ToLower()
    $CommandCanOpenUProject = @( 'start-process',  'rider', 'unrealeditor' )
    $CommandCanOpenSolution = @( 'start-process', 'devenv', 'rider' )
    $CommandCanOpenDirectory = @( 'start-process', 'code', 'explorer', 'code-insiders', 'codium', 'devenv', 'rider', 'clion', 'unrealeditor' )
    if (($ProjectInfo.ProjectFile -ne $null) -and ($CommandCanOpenUProject -contains $CommandID)) {
        & $Command $ProjectInfo.ProjectFile
    } elseif (($ProjectInfo.SolutionFile -ne $null) -and ($CommandCanOpenSolution -contains $CommandID)) {
        & $Command $ProjectInfo.SolutionFile
    } elseif ($CommandCanOpenDirectory -contains $CommandID) {
        & $Command $ProjectInfo.Directory
    } else {
        throw "Command '$Command' is not supported for project '$Project'"
    }
}
Set-Alias ue Open-UEProject