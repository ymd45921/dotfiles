$MyProfile = Join-Path $(Split-Path $PSScriptRoot)  "PowerShell\Microsoft.PowerShell_profile.ps1"
$_this = Join-Path $PSScriptRoot $MyInvocation.MyCommand
# if (($PSVersionTable.PSEdition -ne "Core") -or
#     (-not $(Test-Administrator))) {
#     Write-Error "This script requires Powershell Core and admin privilege."
#     Start-Process pwsh -Verb runAs -ArgumentList "$_this" 
# }

### Load profiles
. $MyProfile
proxy
$FontDir = tmpdir $("MyFonts$"+$(timestamp))
$oldDir = $(Get-Location).Path
cd $FontDir

$NerdFonts = @(
    'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/CodeNewRoman.zip',
    'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/ComicShannsMono.zip',
    'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraCode.zip',
    'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/FiraMono.zip',
    'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip',
    'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip',
    'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Meslo.zip',
    'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Noto.zip',
    'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/SourceCodePro.zip',
    'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Ubuntu.zip',
    'https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/UbuntuMono.zip'
)
$PublicFonts = @(
    'https://github.com/tonsky/FiraCode/releases/download/6.2/Fira_Code_v6.2.zip'
)
# todo: build own ppa and complete this scripts
$PpaFonts = @(
    'https://github.com/45921/ppa/raw/main/PingFang-SC/PINGFANG%20BOLD.TTF',
    'https://github.com/45921/ppa/raw/main/PingFang-SC/PINGFANG%20BOLD.TTF',
    'https://github.com/45921/ppa/raw/main/PingFang-SC/PINGFANG%20BOLD.TTF',
    'https://github.com/45921/ppa/raw/main/PingFang-SC/PINGFANG%20BOLD.TTF',
    'https://github.com/45921/ppa/raw/main/PingFang-SC/PINGFANG%20BOLD.TTF',
    'https://github.com/45921/ppa/raw/main/PingFang-SC/PINGFANG%20BOLD.TTF'
)

$AllFonts = $NerdFonts + $PublicFonts
foreach ($url in $PublicFonts) {
    echo "Start downloading $url ..."
    $dir = download $url $FontDir
    $_fontname = [System.IO.Path]::GetFileNameWithoutExtension((Split-Path $dir -Leaf)) # Or $(Get-Item $dir).BaseName
    extract $dir $(Join-Path $FontDir $_fontname)
    echo "Installing $_fontname ..."
    Install-FontsForCurrentUser $(Join-Path $FontDir $_fontname)
}

cd $oldDir