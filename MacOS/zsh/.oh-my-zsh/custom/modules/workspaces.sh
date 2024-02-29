### Workspaces definitions
DEVELOPER_ROOT=~/Developer
MY_WORKSPACES_ROOT=~/Developer/Source
OMD_DIR=$MY_WORKSPACES_ROOT/dotfiles
ACM_DIR=$MY_WORKSPACES_ROOT/Electric-Circus
BLOG_ROOT=$MY_WORKSPACES_ROOT/blog
BLOG_DIR=$BLOG_ROOT/Hexo-ymd45921

### Workspaces aliases
alias mpg="ssh lsz.ddns.net"
alias wsl="ssh lsz.ddns.net -p 2222"
alias omd="code $OMD_DIR"
alias acm="code $ACM_DIR"
alias restore-omd="$OMD_DIR/MacOS/recover.sh"
alias backup-omd="$OMD_DIR/MacOS/backup.sh"
alias omd-restore="$OMD_DIR/MacOS/recover.sh"
alias omd-backup="$OMD_DIR/MacOS/backup.sh"
alias blog="code $BLOG_DIR"