# chmod +x first, then zsh -c ./MacOS/backup.sh 

function JoinPath() {
  local dir="$1"
  local name="$2"
  dir="${dir%/}"    # 移除目录路径末尾的斜杠
  echo "$dir/$name"
}

__dir=`dirname $0`

cp ~/.zshrc $(JoinPath $__dir "zsh/.zshrc")
cp ~/.zprofile $(JoinPath $__dir "zsh/.zprofile")
cp ~/.p10k.zsh $(JoinPath $__dir "zsh/.p10k.zsh")
# rsync -aq --exclude='.git' ~/.oh-my-zsh $(JoinPath `dirname $0` "zsh/") # -v for verbose output and -q for quiet
rsync -aq --exclude='.git' ~/.oh-my-zsh/custom $(JoinPath $__dir "zsh/.oh-my-zsh/")
