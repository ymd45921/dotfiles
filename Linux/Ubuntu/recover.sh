# chmod +x first
JoinPath() {
  dir="$1"
  name="$2"
  dir="${dir%/}"
  echo "$dir/$name"
}
__dir=`dirname $0`

cp $(JoinPath $__dir "zsh/.zshrc") ~/.zshrc 
cp $(JoinPath $__dir "zsh/.bashrc") ~/.bashrc
rsync -aq $(JoinPath $__dir "zsh/.oh-my-zsh/custom") ~/.oh-my-zsh/