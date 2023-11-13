OneDriveRoot=/home/$(whoami)/OneDrive

mount_onedrive() {
    if df -h | grep -q "$OneDriveRoot"; then
        fusermount -qzu $OneDriveRoot
    fi
    rclone mount OneDrive:/ $OneDriveRoot --vfs-cache-mode full --copy-links --daemon
}