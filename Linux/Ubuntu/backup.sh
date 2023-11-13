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
rsync -aq --exclude='.git' ~/.oh-my-zsh/custom $(JoinPath $__dir "zsh/.oh-my-zsh/")
