OneDriveRoot=/home/$(whoami)/OneDrive
Home=/home/$(whoami)

mount_onedrive() {
    if df -h | grep -q "$OneDriveRoot"; then
        fusermount -qzu $OneDriveRoot
    fi
    rclone mount OneDrive:/ $OneDriveRoot --vfs-cache-mode full --copy-links --daemon
}

tar_backup_system() {
    sudo tar -cvpjf "$1" --exclude="$1" --exclude=/lost+found --exclude=/proc --exclude=/run    \
        --exclude=/dev --exclude=/tmp --exclude=/media --exclude="$OneDriveRoot"                \
        --exclude="$Home/.cache" --exclude="$Home/.ccache" --exclude="$Home/.gvfs"              \
        --exclude="$Home/.Private" --exclude="$Home/.var/app/*/cache" --exclude=/sys            \
        --exclude=/var/cache --exclude=/mnt --exclude=/var/log --exclude=/swapfile              \
        --exclude="/snap/*/*/.cache" --exclude="$Home/.local/share/Trash"                       \
        /
}

create_desktop_shortcut() {
    if [ "$#" -eq 0 ]; then
        echo "Usage: create_desktop_shortcut <target_path> <shortcut_name>"
        return 1
    fi
    if [ ! -e "$1" ]; then
        echo "Error: Target file does not exist."
        return 1
    fi
    resolved_path=$(realpath "$1")
    executable_name=$(basename "$resolved_path")
    desktop_path="$HOME/Desktop"
    if [ ! -d "$desktop_path" ]; then
        if [ ! -e "$HOME/桌面" ]; then
            echo "Error: Desktop path does not exist."
            return 1
        else
            ln -s "$HOME/桌面" "$desktop_path"
        fi
    fi
    shortcut_path="$desktop_path/$2.desktop"

    # ? any tool like appimaged?
    echo "[Desktop Entry]
    Type=Application
    Name=$2
    Exec=$resolved_path
    Terminal=false
    Icon=$resolved_path.png" > "$shortcut_path"

    echo "Desktop shortcut created: $shortcut_path"
}
