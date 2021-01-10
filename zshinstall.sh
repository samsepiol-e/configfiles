#!/bin/sh
set -e

THEME=powerlevel10k/powerlevel10k
PLUGINS="https://github.com/zsh-users/zsh-autosuggestions "

while getopts ":t:p::" opt; do
    case ${opt} in
        t)  THEME=$OPTARG
            ;;
        p)  PLUGINS="${PLUGINS}$OPTARG "
            ;;
        \?)
            echo "Invalid option: $OPTARG" 1>&2
            ;;
        :)
            echo "Invalid option: $OPTARG requires an argument" 1>&2
            ;;
    esac
done
shift $((OPTIND -1))

check_dist() {
    (
        . /etc/os-release
        echo $ID
    )
}

check_version() {
    (
        . /etc/os-release
        echo $VERSION_ID
    )
}

install_dependencies() {
    DIST=`check_dist`
    VERSION=`check_version`
    if [ "`id -u`" = "0" ]; then
        Sudo=''
    elif which sudo; then
        Sudo='sudo'
    else
        echo "sudo command not found."
        return
    fi
    echo "Installing dependencies"
    if [ -z "$DIST" ]; then
      echo "Installing for MacOS"
      $Sudo brew update
      $Sudo brew install git curl zsh
    else
      case $DIST in
	arch)
        echo "iInstalling dependencies for Arch Linux"
	  $Sudo pacman -Syu
	  $Sudo pacman -Syy
	  $Sudo pacman -S curl git zsh
	  ;;
	debian)
        echo "Installing dependencies for Debian"
	  $Sudo apt-get update
	  $Sudo apt-get -y install git curl zsh locales locales-all
	  $Sudo locale-gen en_US.UTF-8
      esac
    fi
}

zshrc_template() {
    _HOME=$1;
    _THEME=$2;
    shift 2
    _PLUGINS=$*;

    cat <<EOM
export LANG='en_US.UTF-8'
export LANGUAGE='en_US:en'
export LC_ALL='en_US.UTF-8'
export "TERM=xterm-256color"
export ZSH="$_HOME/.oh-my-zsh"

ZSH_THEME="${_THEME}"
plugins=($_PLUGINS)

EOM
    printf "\nsource \$ZSH/oh-my-zsh.sh\n"
}

powerline10k_config() {
    cat <<EOM
POWERLEVEL10K_SHORTEN_DIR_LENGTH=2
POWERLEVEL10K_MODE='awesome-fontconfig'
EOM
}

install_dependencies

cd /tmp

# Install On-My-Zsh
if [ ! -d $HOME/.oh-my-zsh ]; then
    sh -c "$(curl https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" --unattended
fi

# Generate plugin list
plugin_list=""
for plugin in $PLUGINS; do
    if [ "`echo $plugin | grep -E '^http.*'`" != "" ]; then
        plugin_name=`basename $plugin`
        git clone $plugin $HOME/.oh-my-zsh/custom/plugins/$plugin_name
    else
        plugin_name=$plugin
    fi
    plugin_list="${plugin_list}$plugin_name "
done

# Handle themes
if [ "`echo $THEME | grep -E '^http.*'`" != "" ]; then
    theme_repo=`basename $THEME`
    THEME_DIR="$HOME/.oh-my-zsh/custom/themes/$theme_repo"
    git clone $THEME $THEME_DIR
    theme_name=`cd $THEME_DIR; ls *.zsh-theme | head -1` 
    theme_name="${theme_name%.zsh-theme}"
    THEME="$theme_repo/$theme_name"
fi

# Generate .zshrc
zshrc_template "$HOME" "$THEME" "$plugin_list" > $HOME/.zshrc

# Install powerlevel10k if no other theme was specified
if [ "$THEME" = "powerlevel10k/powerlevel10k" ]; then
    git clone https://github.com/romkatv/powerlevel10k $HOME/.oh-my-zsh/custom/themes/powerlevel10k
    powerline10k_config >> $HOME/.zshrc
fi
