#!/bin/bash

# refer  spf13-vim bootstrap.sh`

BASEDIR=$(dirname $0)
cd $BASEDIR
CURRENT_DIR=`pwd`

lnif() {
    if [ ! -e $2 ] ; then
        ln -s $1 $2
    fi
    if [ -L $2 ] ; then
        ln -sf $1 $2
    fi
}

echo "backing up current vim config"
today=`date +%Y%m%d`
for i in $HOME/.vim $HOME/.vimrc $HOME/.gvimrc; do [ -e $i ] && [ ! -L $i ] && mv $i $i.$today; done
for i in $HOME/.vim $HOME/.vimrc $HOME/.gvimrc; do [ -L $i ] && unlink $i ; done


echo "setting up symlinks"
lnif $CURRENT_DIR/vimrc $HOME/.vimrc
lnif $CURRENT_DIR/ $HOME/.vim


if [ ! -e $CURRENT_DIR/vundle ]; then
    echo "Installing Vundle"
    git clone http://github.com/gmarik/vundle.git $CURRENT_DIR/bundle/vundle
fi


echo "update/install plugins using Vundle"
system_shell=$SHELL
export SHELL="/bin/sh"
vim -u $CURRENT_DIR/vimrc +BundleInstall! +BundleClean +qall
export SHELL=$system_shell



echo "compile YouCompleteMe"
echo "if error,you need to compile it yourself"
cd $CURRENT_DIR/bundle/YouCompleteMe/
bash -x install.sh --clang-completer
#echo "fix YouCompleteMe cpp/ycm/.ycm_extra_conf.py file"
#echo "use hard link"
#echo "back old file"
#cd $CURRENT_DIR/bundle/YouCompleteMe/cpp/ycm/
#mv .ycm_extra_conf.py _ycm_extra_conf.py_old
#ln $CURRENT_DIR/others/YCM-Configure-File/_ycm_extra_conf.py .ycm_extra_conf

#vim bk and undo dir
if [ ! -d ~/bak/vimbk ]
then
    mkdir -p ~/bak/vimbk
fi

if [ ! -d ~/bak/vimundo ]
then
    mkdir -p ~/bak/vimundo
fi

touch two
