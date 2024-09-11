### Constant
$BlogRepoDir = 'D:\Personal\Temp\blog\Hexo-ymd45921'
$UpyunSyncDir = Join-Path -Path $OneDriveRoot -ChildPath '/应用/upyun/'
$LearnCGDir = '~\Desktop\Learn-CG'
$DownloadsDir = 'D:\Downloads'
$OhMyDotfilesDir = 'C:\Users\i\source\my-dotfiles'

### Alias for command related to specific tools
function SyncUpyunDefaultBucket {upx sync $UpyunSyncDir /}
function GetUpyunDefaultBucket {upx get / $UpyunSyncDir}
Set-Alias backup-upyun GetUpyunDefaultBucket
function StartLocalImageServer {serve $UpyunSyncDir -p 80}
Set-Alias img-shiraha StartLocalImageServer
function Backup-OhMyDotfiles {&(Join-Path $OhMyDotfilesDir "Windows/backup.ps1")}
function Restore-OhMyDotfiles {&(Join-Path $OhMyDotfilesDir "Windows/recover.ps1")}
Set-Alias omd-backup Backup-OhMyDotfiles
Set-Alias omd-recover Restore-OhMyDotfiles
Set-Alias omd-restore Restore-OhMyDotfiles
Set-Alias backup-omd Backup-OhMyDotfiles
Set-Alias restore-omd Restore-OhMyDotfiles

### Alias for workspace shortcuts
function OpenBlogRepoWorkspace {code $BlogRepoDir}
Set-Alias blog OpenBlogRepoWorkspace
function OpenRustOfficialBook {serve D:\Personal\Downloads\Rust中文学习手册 -p 6374}
Set-Alias rustbook OpenRustOfficialBook
function OhMyDotfiles {code $OhMyDotfilesDir}
Set-Alias omd OhMyDotfiles
function OpenLearnCGDir {Set-Location $LearnCGDir}
Set-Alias learncg OpenLearnCGDir
function OpenDownloadsDir {Set-Location $DownloadsDir}
Set-Alias downloads OpenDownloadsDir

### Others
function Start-HearthStone {
    &"C:\Program Files (x86)\LeiGod_Acc\leigod.exe";
    &"C:\Apps\HDT\HearthstoneDeckTracker.exe";
}
Set-Alias 炉石传说，启动！ Start-HearthStone

### Try to load MiaoMiaoTools python tools
# todo: temporary solution, need enhancement.
$MiaoMiaoToolsDIR = 'A:\PycharmProjects\MiaoMiaoTools'
function Load-MiaoMiaoTools {
    if (Test-Path $MiaoMiaoToolsDIR) {
        Set-Location $MiaoMiaoToolsDIR
        & "$MiaoMiaoToolsDIR\.venv\Scripts\activate.ps1"
        # ! activate .venv cause oh-my-posh theme looks weird
    }
}
# ! When pass '-o', it is ambiguous and cannot be avoided.
function Invoke-MiaoMiaoTools {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name,
        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]]$Args
    )
    pwsh.exe -NoExit -Command {
        param($Name, $ArgsToPass)
        Load-MiaoMiaoTools
        if (Test-Path $MiaoMiaoToolsDIR) {
            Set-Location $MiaoMiaoToolsDIR
            python -m $Name @ArgsToPass
        }
        exit
    } -Args $Name, $Args
}
Set-Alias mmtools Invoke-MiaoMiaoTools
function Get-TodaySpotlightWallpapers {
    mmtools SpotlightDownloader --all --output "$env:USERPROFILE\OneDrive\图片\壁纸和主题\Windows 聚焦"
}
