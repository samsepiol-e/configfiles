#!/bin/sh
set -eu

PLUGINS="https://github.com/zsh-users/zsh-autosuggestions "

while getopts ":p::" opt; do
    case ${opt} in
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


zshrc_template() {
    _HOME=$1; shift; 
    _PLUGINS=$*;

    cat <<EOM
export LANG='en_US.UTF-8'
export LANGUAGE='en_US:en'
export LC_ALL='en_US.UTF-8'
export TERM=xterm

export ZSH="$_HOME/.oh-my-zsh"

plugins=($_PLUGINS)

EOM
}


cd /tmp


plugin_list=""
for plugin in $PLUGINS; do
    if [ "`echo $plugin | grep -E '^http.*'`" != "" ]; then
        plugin_name=`basename $plugin`
        CLONEDIR=$HOME/.oh-my-zsh/custom/plugins/$plugin_name
        if [ ! -d "$CLONEDIR" ] ; then
            git clone $plugin $CLONEDIR
        else
            echo "Git Clone failed. Directory already exists"
        fi
    else
        plugin_name=$plugin
    fi
    plugin_list="${plugin_list}$plugin_name "
done

zshrc_template "$HOME" "$plugin_list" > $HOME/.zshrc
