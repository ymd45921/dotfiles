OneDriveRoot=/home/$(whoami)/OneDrive
Home=/home/$(whoami)

mount_onedrive() {
    if df -h | grep -q "$OneDriveRoot"; then
        fusermount -qzu $OneDriveRoot
    fi
    rclone mount OneDrive:/ $OneDriveRoot --vfs-cache-mode full --copy-links --daemon
}

# Not run
tar_backup_system() {
    sudo tar -cvpjf "$1" --exclude="$1" --exclude=/lost+found --exclude=/proc --exclude=/run    \
        --exclude=/dev --exclude=/tmp --exclude=/media --exclude="$OneDriveRoot"                \
        --exclude="$Home/.cache" --exclude="$Home/.ccache" --exclude="$Home/.gvfs"              \
        --exclude="$Home/.Private" --exclude="$Home/.var/app/*/cache" --exclude=/sys            \
        --exclude=/var/cache/* --exclude=/mnt --exclude=/var/log --exclude=/swapfile            \
        --exclude="/snap/*/*/.cache" --exclude="$Home/.local/share/Trash"                       \
        /
}