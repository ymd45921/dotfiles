### Workspaces: oh-my-dotfiles
$OhMyDotfilesDir = 'A:\Source\my-dotfiles'
function Backup-OhMyDotfiles {&(Join-Path $OhMyDotfilesDir "Windows/backup.ps1")}
function Restore-OhMyDotfiles {&(Join-Path $OhMyDotfilesDir "Windows/recover.ps1")}
Set-Alias omd-backup Backup-OhMyDotfiles
Set-Alias omd-recover Restore-OhMyDotfiles
Set-Alias omd-restore Restore-OhMyDotfiles
Set-Alias backup-omd Backup-OhMyDotfiles
Set-Alias restore-omd Restore-OhMyDotfiles