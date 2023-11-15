### 继承主 Profile
$_profile = Join-Path $env:USERPROFILE /Documents/WindowsPowershell/Microsoft.PowerShell_profile.ps1
. $_profile

### 快速备份 & 恢复
$_is_oh_my_dotfiles_proj = ((Split-Path $pwd -Leaf) -eq "my-dotfiles")
function Backup-OhMyDotfiles {
    if ($_is_oh_my_dotfiles_proj) {
        &(Join-Path $pwd "Windows/backup.ps1")
    }
}
function Restore-OhMyDotfiles {
    if ($_is_oh_my_dotfiles_proj) {
        &(Join-Path $pwd "Windows/recover.ps1")
    }
}
Set-Alias omd-backup Backup-OhMyDotfiles
Set-Alias omd-recover Restore-OhMyDotfiles
Set-Alias omd-restore Restore-OhMyDotfiles
Set-Alias backup-omd Backup-OhMyDotfiles
Set-Alias restore-omd Restore-OhMyDotfiles