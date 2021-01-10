#!/bin/sh
set -eu

THEME=powerlevel10k/powerlevel10k
while getopts ":t:" opt; do
    case ${opt} in
        t)  THEME=$OPTARG
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

echo "  THEME   = $THEME"

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
    echo "Installing dependencies"
    $sudo brew update
    $sudo brew install git curl zsh
}

zshrc_template() {
    _HOME=$1;
    _THEME=$2;

    cat <<EOM
    export LANG='en_US.UTF-8'
    export LANGUAGE='en_US:en'
    export LC_ALL='en_US.UTF-8'
    export TERM=xterm
    export ZSH="$_HOME/.oh-my-zsh"
    ZSH_THEME="${_THEME}"
    plugins=($_PLUGINS)
    EOM
}

powerline10k_config() {
    cat <<EOM
    POWERLEVEL10K_MODE="awesome-fontconfig"
    EOM
}

install_dependencies

cd /tmp

# Install On-My-Zsh
if [ ! -d $HOME/.oh-my-zsh ]; then
    sh -c "$(curl https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" --unattended
fi


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
zshrc_template "$HOME" "$THEME" > $HOME/.zshrc

# Install powerlevel10k if no other theme was specified
if [ "$THEME" = "powerlevel10k/powerlevel10k" ]; then
    git clone https://github.com/romkatv/powerlevel10k $HOME/.oh-my-zsh/custom/themes/powerlevel10k
    powerline10k_config >> $HOME/.zshrc
fi
#OhMyZsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
#powerlevel10k
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
if cat ~./zshrc | grep ZSH_THEME | grep -v "#": then
  echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' > ~/.zshrc_temp
  cat ~/.zshrc >> ~/.zshrc_temp
  mv ~/.zshrc_temp ~/.zshrc
else
  sed -i '' -E 's/(^ZSH_THEME=).+$/\1"powerlevel10k\/powerlevel10k"/' ~/.zshrc
fi
#zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
sed -i '' -E 's/(^plugins=\().+$/\1zsh-autosuggestions/' ~/.zshrc
