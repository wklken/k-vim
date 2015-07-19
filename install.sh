#!/bin/bash

# refer  spf13-vim bootstrap.sh`
BASEDIR=$(dirname $0)
cd $BASEDIR
CURRENT_DIR=`pwd`
VUNDLE_VIM_URL="https://github.com/VundleVim/Vundle.vim.git"

lnif() {
    if [ -e "$1" ]; then
        ln -sf "$1" "$2"
    fi
}

echo "Step1: backing up current vim config"
today=`date +%Y%m%d`
for i in $HOME/.vim $HOME/.vimrc $HOME/.gvimrc $HOME/.vimrc.bundles; do [ -e $i ] && [ ! -L $i ] && mv $i $i.$today; done
for i in $HOME/.vim $HOME/.vimrc $HOME/.gvimrc $HOME/.vimrc.bundles; do [ -L $i ] && unlink $i ; done


echo "Step2: setting up symlinks"
lnif $CURRENT_DIR/vimrc $HOME/.vimrc
lnif $CURRENT_DIR/vimrc.bundles $HOME/.vimrc.bundles
lnif "$CURRENT_DIR/" "$HOME/.vim"

echo "Step3: install vundle"
# update vundle.vim git repository URL
if [ -d $CURRENT_DIR/bundle/vundle/.git ]; then
    mv $CURRENT_DIR/bundle/vundle $CURRENT_DIR/bundle/Vundle.vim && \
        git remote rm origin && \
        git remote add origin $VUNDLE_VIM_URL
elif [ -d $CURRENT_DIR/bundle/vundle ]; then
    rm -rf $CURRENT_DIR/bundle/vundle
fi

if [ ! -e $CURRENT_DIR/bundle/Vundle.vim ]; then
    echo "Installing Vundle"
    git clone $VUNDLE_VIM_URL $CURRENT_DIR/bundle/Vundle.vim
else
    echo "Upgrade Vundle"
    cd "$HOME/.vim/bundle/Vundle.vim" && git pull origin master
fi

echo "Step4: update/install plugins using Vundle"
system_shell=$SHELL
export SHELL="/bin/sh"
vim -u $HOME/.vimrc.bundles +BundleInstall! +BundleClean +qall
export SHELL=$system_shell


echo "Step5: compile YouCompleteMe"
echo "It will take a long time, just be patient!"
echo "If error,you need to compile it yourself"
echo "cd $CURRENT_DIR/bundle/YouCompleteMe/ && bash -x install.sh --clang-completer"
cd $CURRENT_DIR/bundle/YouCompleteMe/

if [ `which clang` ]   # check system clang
then
    bash -x install.sh --clang-completer --system-libclang   # use system clang
else
    bash -x install.sh --clang-completer
fi


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
