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

declare -a system_localized_folders=(\
    "Applications" "Library" "Users" "System" "Volumes" \
    "Public" "Pictures" "Movies" "Music" "Downloads" "Documents" "Desktop" \
)   # TODO: 其他的系统文件夹
set_folder_localname() {
    if [[ -z $1 ]]; then
        echo "No folder name provided."
        return 1
    fi
    local dir_name=$1
    if [[ dir_name != *".localized" ]]; then
        if [[ " ${system_localized_folders[@]} " =~ " $(basename $dir_name) " ]]; then
            if [[ ! -d $dir_name ]]; then
                echo "The folder $dir_name is not found."
                return 1
            fi
            touch $dir_name/.localized
            return 0
        fi
        dir_name="$dir_name.localized"
    fi
    if [[ ! -d $dir_name ]]; then
        echo "The folder $dir_name is not found."
        return 1
    fi
    local folder_name=$(basename $dir_name .localized)

    local local_name=$2
    if [[ -z $local_name ]]; then
        return 0
    fi

    mkdir -p $dir_name/.localized
    local region_name="zh_CN"
    if [[ ! -z $3 ]]; then 
        region_name=$3
    fi
    if [[ -e $dir_name/.localized/$region_name.strings ]]; then
        echo "The localized name file $dir_name/.localized/$region_name.strings is already exist."
        mv $dir_name/.localized/$region_name.strings $dir_name/.localized/$region_name.strings.bak
        echo "The original file has been backuped to $dir_name/.localized/$region_name.strings.bak."
    fi

    # TODO: 更好的修改 plist 文件的方法
    local xml_content="<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">
<plist version=\"1.0\">
    <dict>
        <key>$folder_name</key>
        <string>$local_name</string>
    </dict>
</plist>"
    echo $xml_content > $dir_name/.localized/$region_name.strings
}
alias localname="set_folder_localname"