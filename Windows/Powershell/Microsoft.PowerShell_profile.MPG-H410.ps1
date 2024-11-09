### Initialize Oh-My-Posh Ver 3
$OhMyPosh3Theme = Join-Path $PwshProfileDir '\themes\chips-modifiled.omp.json'
oh-my-posh init pwsh --config $OhMyPosh3Theme | Invoke-Expression
$env:VIRTUAL_ENV_DISABLE_PROMPT = 1     # to disable python venv prompt before oh-my-posh
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
    while ($CommandInfo.CommandType -eq 'Alias') {
        $CommandInfo = Get-Command $CommandInfo.Definition
    }
    $CommandID = [System.IO.Path]::GetFileNameWithoutExtension($CommandInfo.Name).ToLower()
    $CommandCanOpenUProject = @( 'start-process',  'rider', 'unrealeditor', 'ue4editor' )
    $CommandCanOpenSolution = @( 'start-process', 'devenv', 'rider' )
    $CommandCanOpenDirectory = @( 'start-process', 'code', 'explorer', 'code-insiders', 'codium', 'devenv', 'rider', 'clion', 'unrealeditor', 'set-location' )
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
Set-Alias ue5 "C:\Program Files\Epic Games\UE_5.3\Engine\Binaries\Win64\UnrealEditor.exe"
Set-Alias ue4 "C:\Program Files\Epic Games\UE_4.27\Engine\Binaries\Win64\UE4Editor.exe"

# Backup QQ emoji
function Get-QQEmojiDirectory {
    param([Parameter(Mandatory = $true)][string]$QQ)
    $Dir = Join-Path $env:USERPROFILE "Documents\Tencent Files\$QQ\nt_qq\nt_data\Emoji\personal_emoji"
    if (-not (Test-Path $Dir)) {
        throw "QQ Emoji directory not found for QQ '$QQ'"
    }
    return $Dir
}
function Backup-QQEmoji {
    param([Parameter(Mandatory = $true)][string]$QQ)
    $QQEmojiDir = Get-QQEmojiDirectory -QQ $QQ
    $BackupDir = Join-Path $OneDriveRoot "应用\QQ Emoji Backup\$QQ"
    if (-not (Test-Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir
    }
    $ArchiveFilePath = Join-Path $BackupDir "emoji_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip"
    # todo: universal compress cmdlet using WinRAR and 7z?
    Compress-Archive -Path $QQEmojiDir -DestinationPath $ArchiveFilePath -CompressionLevel Optimal
    Write-Host "Backup stickers of QQ '$QQ' to '$ArchiveFilePath'."
    Write-Host "You can clear cache by 'Clear-QQEmojiCache $QQ'."
}
Set-Alias Backup-QQStickers Backup-QQEmoji
function Remove-QQEmoji {
    param([Parameter(Mandatory = $true)][string]$QQ)
    $QQEmojiDir = Get-QQEmojiDirectory -QQ $QQ
    Remove-Item -Path $QQEmojiDir -Recurse -Force
}
Set-Alias Clear-QQEmojiCache Remove-QQEmoji
Set-Alias Clear-QQStickers Remove-QQEmoji

# Close Monitor and Lock Screen.
function Lock-Screen {
    # Try use NirCmd first because faster and more reliable.
    $nircmd = Get-Command -Name nircmd -ErrorAction SilentlyContinue
    if ($null -ne $nircmd) {
        & $nircmd monitor off
    } else {
        # ref: Microsoft.PowerShell_profile.ps1
        Close-MonitorAsync
    }
}
Set-Alias monitoroff Lock-Screen

# Set folder icon by color
# * Requires INI/desktop.ini functions in Microsoft.PowerShell_profile.ps1
function Set-FolderColor {
    param(
        [string]$Path = $PWD,
        [ValidateSet('None', 'Red', 'Orange', 'Green', 'Cyan', 'Blue', 'Purple', 'Pink', 'Gray', IgnoreCase = $true)]
        [string]$Color = 'None',
        [switch]$Light = $false
    )
    if (-not (Test-Path $Path -PathType Container)) {
        throw "Directory '$Path' not found."
    }
    $desktopIniPath = Join-Path $Path 'desktop.ini'
    $ColorMap = @{
        'None' = 0
        'Red' = 1
        'Orange' = 2
        'Green' = 3
        'Cyan' = 4
        'Blue' = 5
        'Purple' = 6
        'Pink' = 7
        'Gray' = 8
    }
    $ColorIndex = $ColorMap[$Color]
    if ($Color -eq 'Gray') { $Light = -not $Light }
    if ($Light) {
        $ColorIndex += 8
        if ($Color -eq 'None') { $ColorIndex += 9 }
    }
    # * Temporarily hard-coded path for myself
    $IconLibrary = "$OneDriveRoot\图片\图标\库\svg\Onedrive New Colored Folders\WindowsColoredFolders.icl"
    $desktopIniObject = Get-DesktopIniObject -Path $Path -Ensure
    $desktopIniObject['.ShellClassInfo'].IconResource = "$IconLibrary,$ColorIndex"
    Write-IniFileByANSI -Path $desktopIniPath -Data $desktopIniObject -Force -SkipEmpty
    $desktopIniAttrib = (Get-ItemProperty -Path $desktopIniPath -Name Attributes).Attributes
    Set-ItemProperty -Path $desktopIniPath -Name Attributes -Value ($desktopIniAttrib -bor 6)
}
Set-Alias setcolor Set-FolderColor

# Open Unity Hub by proxy
# ! Powershell version not-work.
function Open-UnityHub {
    return & "C:\Apps\Env\UnityHubByProxy.bat"
    $UnityHubPath = 'C:\Program Files\Unity Hub\Unity Hub.exe'
    Start-Job -Name UnityHubByProxy -ScriptBlock {
        $env:HTTP_PROXY = $HttpProxy
        $env:HTTPS_PROXY = $HttpProxy
        & $using:UnityHubPath 
    }
}
Set-Alias unityhub Open-UnityHub

# Enter developer shell for Visual Studio
function Find-VisualStudio {
    $VisualStudioCmd = Get-Command -Name devenv -ErrorAction SilentlyContinue
    if ($null -eq $VisualStudioCmd) {
        $paths = @(
            "$env:ProgramFiles\Microsoft Visual Studio",
            "${env:ProgramFiles(x86)}\Microsoft Visual Studio",
            "$env:SystemDrive\Program Files\Microsoft\VisualStudio",
            "$env:SystemDrive\Program Files (x86)\Microsoft\VisualStudio"
        )
        $versions = @('2022', '2019', '2017')
        $editions = @('Enterprise', 'Professional', 'Community')
        foreach ($version in $versions) {
            foreach ($edition in $editions) {
                foreach ($path in $paths) {
                    $VisualStudioPath = Join-Path $path "$version\$edition\Common7\IDE\devenv.exe"
                    if (Test-Path $VisualStudioPath) {
                        return $VisualStudioPath
                    }
                }
            }
        }
    }
    $VisualStudioPath = $VisualStudioCmd.Source
    return $VisualStudioPath
}
function Enter-VisualStudioShell {
    $VisualStudioPath = Find-VisualStudio
    $VisualStudioDir = [System.IO.Path]::GetDirectoryName($VisualStudioPath)
    if ($null -eq $VisualStudioPath) {
        throw "Visual Studio not found."
    }
    $DevShellDllPath = Join-Path (Split-Path $VisualStudioDir -Parent) 'Tools\Microsoft.VisualStudio.DevShell.dll'
    if (-not (Test-Path $DevShellDllPath)) {
        throw "Visual Studio Developer Command Prompt not found."
    }
    Import-Module $DevShellDllPath
    Enter-VsDevShell b7bd52ef
}
Set-Alias vsdev Enter-VisualStudioShell
Set-Alias DevShell Enter-VisualStudioShell

# Waifu-2x-caffe
$Waifu2xCaffePath = "C:\Apps\waifu2x-caffe\waifu2x-caffe-cui.exe"
function Invoke-Waifu2xCaffeCUI {
    & $Waifu2xCaffePath @args
}
Set-Alias waifu2x Invoke-Waifu2xCaffeCUI