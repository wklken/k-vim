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

echo "Step1: backing up current vim config"
today=`date +%Y%m%d`
for i in $HOME/.vim $HOME/.vimrc $HOME/.gvimrc; do [ -e $i ] && [ ! -L $i ] && mv $i $i.$today; done
for i in $HOME/.vim $HOME/.vimrc $HOME/.gvimrc; do [ -L $i ] && unlink $i ; done


echo "Step2: setting up symlinks"
lnif $CURRENT_DIR/vimrc $HOME/.vimrc
lnif $CURRENT_DIR/vimrc.bundles $HOME/.vimrc.bundles
lnif "$CURRENT_DIR/" "$HOME/.vim"

echo "Step3: install vundle"
if [ ! -e $CURRENT_DIR/bundle/vundle ]; then
    echo "Installing Vundle"
    git clone https://github.com/gmarik/vundle.git $CURRENT_DIR/bundle/vundle
else
    echo "Upgrade Vundle"
    cd "$HOME/.vim/bundle/vundle" && git pull origin master
fi

echo "Step4: update/install plugins using Vundle"
system_shell=$SHELL
export SHELL="/bin/sh"
vim -u $HOME/.vimrc.bundles +BundleInstall! +BundleClean +qall
export SHELL=$system_shell

# add check for vim --version
WARNING=''
VERSION=`vim --version | grep "VIM - Vi IMproved" | grep -o "[0-9]\.[0-9]"`
if [ `echo $VERSION' < 7.4' | bc ` -eq 1 ]
then
    WARNING=$WARNING"To use YouCompleteMe, you need to update Vim to (at least)7.4 version \n"
fi
if [ !  -z `vim --version | grep -o ' -python ' `]
then
    WARNING=$WARNING"Some plugins here need python support, so you need to recompile Vim to add python support\n"
fi
if [ -n "$WARNING" ]
then
    echo 'WARNING: '
    echo -e $WARNING
    echo "Recompile Vim is in need. Please refer to https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source for more"
fi


echo "Step5: compile YouCompleteMe"
echo "It will take a long time, juse be patient!"
echo "If error,you need to compile it yourself"
echo "cd $CURRENT_DIR/bundle/YouCompleteMe/ && bash -x install.sh --clang-completer"
cd $CURRENT_DIR/bundle/YouCompleteMe/
bash -x install.sh --clang-completer

#vim bk and undo dir
if [ ! -d /tmp/vimbk ]
then
    mkdir -p /tmp/vimbk
fi

if [ ! -d /tmp/vimundo ]
then
    mkdir -p /tmp/vimundo
fi

echo "Install Done!"
