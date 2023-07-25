set_brew_tsinghua_source() {
    export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git"
    for tap in core cask{,-fonts,-versions} command-not-found services; do
        brew tap --custom-remote --force-auto-update "homebrew/${tap}" "https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-${tap}.git"
    done
    brew update
}

set_brew_default_source() {
    # brew 程序本身，Homebrew / Linuxbrew 相同
    unset HOMEBREW_BREW_GIT_REMOTE
    git -C "$(brew --repo)" remote set-url origin https://github.com/Homebrew/brew
    # 以下针对 macOS 系统上的 Homebrew
    unset HOMEBREW_API_DOMAIN
    unset HOMEBREW_CORE_GIT_REMOTE
    BREW_TAPS="$(BREW_TAPS="$(brew tap 2>/dev/null)"; echo -n "${BREW_TAPS//$'\n'/:}")"
    for tap in core cask{,-fonts,-versions} command-not-found services; do
        if [[ ":${BREW_TAPS}:" == *":homebrew/${tap}:"* ]]; then  # 只复原已安装的 Tap
            brew tap --custom-remote "homebrew/${tap}" "https://github.com/Homebrew/homebrew-${tap}"
        fi
    done
    # 重新拉取远程
    brew update
}