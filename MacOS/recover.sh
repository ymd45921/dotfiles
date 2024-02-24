# chmod +x first, then zsh -c ./MacOS/recover.sh   

function JoinPath() {
  local dir="$1"
  local name="$2"
  dir="${dir%/}"    # 移除目录路径末尾的斜杠
  echo "$dir/$name"
}

__dir=`dirname $0`

cp $(JoinPath $__dir "zsh/.zshrc") ~/.zshrc 
cp $(JoinPath $__dir "zsh/.p10k.zsh") ~/.p10k.zsh
rsync -aq $(JoinPath $__dir "zsh/.oh-my-zsh/custom") ~/.oh-my-zsh/
