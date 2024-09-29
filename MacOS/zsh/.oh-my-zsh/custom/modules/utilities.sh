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

function convert_video_to_gif() {
    if [[ -z $1 ]]; then
        echo "No input file."
        return 1
    fi
    local input_file="$1"
    local output_file="$2"
    if [[ -z $2 ]]; then
        if [[ -e "./output.gif" ]]; then
            echo "Default output file is exist."
            return 1
        fi
        output_file="output.gif"
    fi
    ffmpeg -i $input_file -c:v gif -loop 0 $output_file
}

alias mp42gif="convert_video_to_gif"

try_enable_python_venv() {
    if [[ -e "venv" ]]; then
        source venv/bin/activate
    elif [[ -e ".venv" ]]; then 
        source .venv/bin/activate
    else 
        echo "No Python virtual environment found."
    fi
}

alias venv="try_enable_python_venv"

zsh_print_color256_palette() {
    for code in {000..255}; do 
        print -nP -- "%F{$code}$code %f"; 
        [ $((${code} % 16)) -eq 15 ] && echo; 
    done
}
bash_print_color256_palette() {
    for code in {0..255}; do 
        echo -n "[38;05;${code}m $(printf %03d $code)"; 
        [ $((${code} % 16)) -eq 15 ] && echo; 
    done
}