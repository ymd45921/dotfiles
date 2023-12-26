OMD_DIR=~/Documents/my-dotfiles
alias omd="code $OMD_DIR"
alias acm="code ~/Documents/Electric-Circus"
alias restore-omd="$OMD_DIR/Linux/Ubuntu/recover.sh"
alias backup-omd="$OMD_DIR/Linux/Ubuntu/backup.sh"
alias omd-restore="$OMD_DIR/Linux/Ubuntu/recover.sh"
alias omd-backup="$OMD_DIR/Linux/Ubuntu/backup.sh"
alias start-e5renew="sudo docker run -d --restart=always -p 1066:1066 --name RenewX gladtbam/ms365_e5_renewx:latest"
alias restart-e5renew="sudo docker restart RenewX"
alias set-e5renew="sudo docker update --restart=always RenewX"
alias e5renew="restart-e5renew"
alias e5renewx="restart-e5renew"