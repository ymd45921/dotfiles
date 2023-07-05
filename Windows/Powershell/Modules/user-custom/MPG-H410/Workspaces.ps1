### Constant
$BlogRepoDir = 'D:\Personal\Temp\blog\Hexo-ymd45921'
$UpyunSyncDir = Join-Path -Path $OneDriveRoot -ChildPath '/应用/upyun/'

### Alias for command related to specific tools
function SyncUpyunDefaultBucket {upx sync $UpyunSyncDir /}
function GetUpyunDefaultBucket {upx get / $UpyunSyncDir}
Set-Alias backup-upyun GetUpyunDefaultBucket
function StartLocalImageServer {serve $UpyunSyncDir -p 80}
Set-Alias img-shiraha StartLocalImageServer

### Alias for workspace shortcuts
function OpenBlogRepoWorkspace {code $BlogRepoDir}
Set-Alias blog OpenBlogRepoWorkspace
function OpenRustOfficialBook {serve D:\Personal\Downloads\trpl-zh-cn-gh-pages -p 6374}
Set-Alias rustbook OpenRustOfficialBook