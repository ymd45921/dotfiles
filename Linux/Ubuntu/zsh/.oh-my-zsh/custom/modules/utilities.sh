OneDriveRoot=/home/$(whoami)/OneDrive

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
        /
}