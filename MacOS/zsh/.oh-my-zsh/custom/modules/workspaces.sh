### Workspaces definitions
DEVELOPER_ROOT=~/Developer
MY_WORKSPACES_ROOT=~/Developer/Source
OMD_DIR=$MY_WORKSPACES_ROOT/dotfiles
ACM_DIR=$MY_WORKSPACES_ROOT/Electric-Circus
BLOG_ROOT=$MY_WORKSPACES_ROOT/blog
BLOG_DIR=$BLOG_ROOT/Hexo-ymd45921

### External drive definitions
# ! declaration of array is different in bash and zsh
external_drive_paths=("/Volumes/SN740-APFS")
EXTERNAL_DRIVE_PATH=${external_drive_paths[1]}
EXTERNAL_HOME_DIR="$EXTERNAL_DRIVE_PATH/Users/$USER"
EXTERNAL_APP_DIR="$EXTERNAL_DRIVE_PATH/Applications"
EXTERNAL_CLI_DIR="$EXTERNAL_HOME_DIR/Command Line Tools.localized"
run_cli_if_external_mounted() {
    if [[ -d $EXTERNAL_DRIVE_PATH ]]; then
        if [[ -z $1 ]]; then
            echo "No command to execute."
            return 1
        elif [[ ! -x $EXTERNAL_CLI_DIR/$1 ]]; then
            echo "The executable command line tool is not found."
            return 1
        else
            command="$EXTERNAL_CLI_DIR/$1"
            shift
            $command $@
        fi
    else
        echo "External drive '$EXTERNAL_DRIVE_PATH' is not mounted. Cannot execute the command."
        return 1
    fi
}
alias sn740="cd $EXTERNAL_DRIVE_PATH"
alias extd="cd $EXTERNAL_DRIVE_PATH"
alias exthome="cd $EXTERNAL_HOME_DIR"
alias extapp="cd $EXTERNAL_APP_DIR"
alias extcli="cd $EXTERNAL_CLI_DIR"
alias extrun="run_cli_if_external_mounted"

### Workspaces aliases
alias mpg="ssh i@lsz.ddns.net"
alias wsl="ssh nnm@lsz.ddns.net -p 2222"
alias omd="code $OMD_DIR"
alias acm="code $ACM_DIR"
alias restore-omd="$OMD_DIR/MacOS/recover.sh"
alias backup-omd="$OMD_DIR/MacOS/backup.sh"
alias omd-restore="$OMD_DIR/MacOS/recover.sh"
alias omd-backup="$OMD_DIR/MacOS/backup.sh"
alias omd-reload="omd-restore; reload; chomd"
alias blog="code $BLOG_DIR"

### upyun backup settings and tools by upx
UPYUN_BACKUP_DIR="$EXTERNAL_HOME_DIR/Pictures/UpYun-Backup.localized"
UPYUN_UPLOAD_DIR=/blog/auto-upload
UPYUN_LAST_UPLOADED=""
upyun_file_exists() {
    if [[ -z $1 ]]; then
        echo "No file to check."
        return 1
    else
        if [[ $1 != /* ]]; then
            filepath=$UPYUN_UPLOAD_DIR/$1
        else
            filepath=$1
        fi
        output=$(extrun upyun/upx ls $filepath 2>/dev/null)
        return_value=$?
        return $return_value
    fi
}
upload_to_upyun() {
    if [[ -z $1 ]]; then
        echo "No image file to upload."
        return 1
    elif [[ ! -f $1 ]]; then
        echo "The image file is not found."
        return 1
    else
        filename=$(basename $1)
        extname=".${filename##*.}"
        filename="${filename%.*}"
        uploadname="$filename"
        while upyun_file_exists $uploadname$extname; do
            uploadname="$filename-$(date +%Y%m%d%H%M%S)"
        done
        uploadto=$UPYUN_UPLOAD_DIR/$uploadname$extname
        extrun upyun/upx put $1 $uploadto
        if [[ $? -eq 0 ]]; then
            UPYUN_LAST_UPLOADED=$uploadto
            echo "The file $1 has been uploaded to $UPYUN_LAST_UPLOADED."
        fi
    fi
}
alias upyun="extrun upyun/upx"
alias upyun-get="upyun get / $UPYUN_BACKUP_DIR"
alias upyun-sync="upyun sync $UPYUN_BACKUP_DIR /"
alias upyun-backup="upyun-get"
alias upyun-upload="upload_to_upyun"