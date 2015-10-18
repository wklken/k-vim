# Vim configuration
Robbie Cao <robbie.cao@gmail.com>

This is the .vimrc file of Robbie Cao.
Much of it is beneficial for general use, I would recommend
picking out the parts you want and understand.

Major of those config are from:
    - spf13/spf13-vim (https://github.com/spf13/spf13-vim)
    - wklken/k-vim (https://github.com/wklken/k-vim)
Thank spf13 and wklken !

## How to install
1. Clone a copy to your local
    ````
    $ git clone git@github.com:robbie-cao/config-vim.git
    ```` 
2. Install dependence packages
    - ctags, ag(the_silver_searcher)
    - ubuntu
    ```
    $ sudo apt-get install ctags
    $ sudo apt-get install build-essential cmake python-dev  #编译YCM自动补全插件依赖
    $ sudo apt-get install silversearcher-ag
    ```
    - mac
    ```
    $ brew install ctags
    $ brew install the_silver_searcher
    ```
3. Run install.sh
    ``
    $ cd config-vim
    $ ./install.sh --clang-completer
    ```

Enjoy!
