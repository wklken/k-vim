#!/bin/bash
# refer  spf13-vim bootstrap.sh`
BASEDIR=$(dirname $0)
cd $BASEDIR
CURRENT_DIR=`pwd`

lnif() {
    if [ -e "$1" ]; then
        ln -sf "$1" "$2"
    fi
}

# 支持javascript自动补全, 需要安装.vimrc.bundles中 marijnh/tern_for_vim 且使用npm安装之
# for javascript tern
lnif $CURRENT_DIR/others/tern-project $HOME/.tern-project

lnif $HOME/.vim/bundle/tern_for_vim/after/ftplugin/javascript_tern.vim $HOME/.vim/bundle/tern_for_vim/after/ftplugin/html_tern.vim


