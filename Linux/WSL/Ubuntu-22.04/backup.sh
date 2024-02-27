# chmod +x first
JoinPath() {
  dir="$1"
  name="$2"
  dir="${dir%/}"
  echo "$dir/$name"
}
__dir=`dirname $0`

cp ~/.zshrc $(JoinPath $__dir zsh/.zshrc)
cp ~/.bashrc $(JoinPath $__dir zsh/.bashrc)
cp ~/.p10k.zsh $(JoinPath $__dir zsh/.p10k.zsh)
rsync -aq --exclude='.git' ~/.oh-my-zsh/custom/modules $(JoinPath $__dir "zsh/.oh-my-zsh/custom/")