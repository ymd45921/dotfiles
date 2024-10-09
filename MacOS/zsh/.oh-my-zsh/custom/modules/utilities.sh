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

# ref to @/scripts/color256.sh
alias color256="color256.sh rainbow"
# alias pastel-palettes="color256.sh pastel"
alias "pastel*palettes"="color256.sh pastel"

patch_vscodium() {
    local cmd_path=$(realpath $(which codium))
    local res_path=$(realpath $cmd_path/../..)
    local app_path=$(realpath $res_path/../../..)
    if [[ ! -f $res_path/product.json ]]; then
        echo "No product.json found in $app_path."
        return 1
    fi
    local service_url="https://marketplace.visualstudio.com/_apis/public/gallery"
    local item_url="https://marketplace.visualstudio.com/items"
    local service_key=".extensionsGallery.serviceUrl"
    local item_key=".extensionsGallery.itemUrl"
    # sudo cp -f $res_path/product.json $res_path/product.json.bak
    local patched_json=$(jq "$service_key=\"$service_url\" | $item_key=\"$item_url\"" $res_path/product.json)
    # sudo echo $patched_json > $res_path/product.json
    # * because of SIP, we copy patched json to clipboard and open it in VSCode
    echo $patched_json | sed 's/\\/\\\\/g' | pbcopy
    echo "The patched product.json has been copied to the clipboard. Please patch it manually."
    code $res_path/product.json
}