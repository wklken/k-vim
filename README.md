Vim Config
==========

Manage plugins with bundle:

    git submodule add git@github.com:Raimondi/delimitMate.git
    git submodule add git@github.com:gmarik/Vundle.vim.git
    git submodule add git@github.com:kien/rainbow_parentheses.vim.git
    git submodule add git@github.com:godlygeek/tabular.git
    git submodule add git@github.com:Lokaltog/vim-easymotion.git
    git submodule add git@github.com:bronson/vim-trailing-whitespace.git
    git submodule add git@github.com:Valloric/YouCompleteMe.git

Clone to other place:

    git submodule init
    git submodule update

Steps:
    1, git clone git@github.com:robbie-cao/config-vim.git
    2, git submodule init
    3, git submodule update
    4, cp -fr .vimrc .vim ~
