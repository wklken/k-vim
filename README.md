k-vim
=======================

> VERSION: 7.0

> LAST_UPDATE_TIME: 2014-03-15

> PS: 年前答应的版本梳理完毕,拖延了，额，一个月....-_-#


> 有任何问题提issues

# 目标

> Just a Better Vim Config. Keep it Simple.

    1.结构及配置划分良好
    2.全中文注释
    3.高度可配置修改
    4.一键安装少折腾
    5.保持简单

适用人群：

    有一定基础的 vimer

### vim基本用法

推荐: 耗子叔的 [简明vim练级攻略](http://coolshell.cn/articles/5426.html)

或者,玩游戏 [vim大冒险](http://vim-adventures.com/)

学习步骤:

    1.进入退出，模式切换，插入删除复制粘贴等基本操作

    2.学会快速移动跳转

    3.学会如何进行选中

    4.学会进行文本对象操作

    5.学会批量重复操作

    6.学会vim批量替换

    ------------
    6.学会使用插件，完成补全，注释，文本快速录入操作等

    7.学会宏 []

### k-vim使用说明

1. 能熟练使用原生vim,最好先熟悉了再来使用插件扩展

2. 插件配置

        1.可以在vimrc.bundles中查看到每个插件的配置
        2.所列插件默认安装的，需要针对自身需求，增加或删除配置
        3.本README.md仅介绍插件简单功能和用法，可以在github中搜索查看详细的用法和配置
        4.每个插件配置后面跟了一些键位修改的配置[用法在下面介绍中]，可以根据自己习惯修改

        ps.平时用python/golang多些，其他语言根据自身需求添加到 vimrc.bundles->语言相关中

3. `fork`一份, 然后参照安装步骤进行安装

    根据自己使用语言和自身习惯，对配置进行自定义修改

    之后，维护自身配置，后续可以在任意地方安装，`一库在手，天下我有 `，:)

    要关注`k-vim`的更新，github点`Star`，thx a lot!

4. 建议

        1.插件不是越多越好，多了可能会拖慢vim打开速度

            可以尝试注掉所有插件，根据使用需求逐一加入
            需要多思考自己使用过程中的不便之处，寻找对应解决方案

        2.二八定律

            关注可以最大提升自己生产力的20%插件，具体要亲自实践
            有什么问题,先看插件文档说明->代码选项->github上的issues->google it
            你遇到的问题,一定别人也遇到了,大部分可解决,少部分无解….


        3.不要复杂化vim

   文章: [不要复杂化vim](http://www.kunli.info/2013/08/13/vim/)|[七个高效文本编辑习惯](http://blog.jobbole.com/44891/)



欢迎推荐好用更酷的插件配置:)

我的配置也会不定期更新，thx

后面图片有点多，展示有点慢，截得不是很专业，耐心看完:)

---------------------------------

---------------------------------

# 截图

solarized主题

![solarized](https://github.com/wklken/gallery/blob/master/vim/solarized.png?raw=true)

molokai主题

![molokai](https://github.com/wklken/gallery/blob/master/vim/molokai.png?raw=true)

---------------------------------

---------------------------------

# 安装步骤

1. clone到本地,配置到linux个人目录（如果是从linux_config过来的，不需要clone）

        git clone https://github.com/wklken/k-vim.git

2. 安装依赖包

        # ubuntu
        sudo apt-get install ctags
        sudo apt-get install build-essential cmake python-dev  #编译YCM自动补全插件依赖

        # centos
        sudo yum install python-devel.x86_64
        sudo yum groupinstall 'Development Tools'

        # mac
        #brew install ctags

        #使用python需要
        sudo pip install pyflakes
        sudo pip install pylint
        sudo pip install pep8

3. 安装插件

        cd k-vim/
        #注意原先装过重装时，不要到~/.vim下执行(这是软连接指向k-vim真是目录)，必须到k-vim原生目录执行

        sh -x install.sh

        #会进入安装插件的列表，目前30+个插件，一一安装是从github clone的，完全取决于网速

        #安装完插件后，会自动编译YCM，注意，可能编译失败（缺少某些依赖包,暂不支持mac osx 10.9）
        失败的话手动编译吧，看第4步 编译自动补全YouCompleteMe （这步耗时也有点长，但绝对值得）

        install.sh
        本质上做的事情
        1.将vimrc/vim文件夹软链接到$HOME，编程系统vim配置
        2.git clone安装vundle（clone到bundle目录下）
        3.通过vundle安装其他所有插件（相当于进入vimrc, 命令行执行:BundleInstall）,从github全部搞到本地
        4.编译需要手动编译的插件，eg.YCM

4. 可能遇到的问题:

    - 编译自动补全YouCompleteMe

    [文档](https://github.com/Valloric/YouCompleteMe)

    这个插件需要Vim 7.3.584,所以,如果vim版本太低,需要[编译安装](https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source)

    - 相对行号

    vimrc中配置,如果不习惯,可以去掉,[相关参考](http://jeffkreeftmeijer.com/2012/relative-line-numbers-in-vim-for-super-fast-movement/)

    - 配置主题

    到vimrc中修改colortheme,可以使用molokai(用惯sublimetext2的童鞋很熟悉)

    默认配置的是[solarized dark主题](https://github.com/altercation/vim-colors-solarized)

    想要修改终端配色为solarized可以参考 [这里](https://github.com/sigurdga/gnome-terminal-colors-solarized)

5. 安装/卸载/更新插件：

    可以自定义安装某些插件，或者删除对自己无用的插件(插件太多可能导致vim打开过慢)

    安装新插件

        1. vimrc.bundles中配置对应插件 bundle
            Bundle 'fholgado/minibufexpl.vim'
        2. 命令行模式，执行:
            :BundleInstall

    更新插件

        命令行模式，执行:
        :BundleUpdate

    删除插件

        1. vimrc.bundles中注释或删除对应插件bundle配置行(行首加一个双引号),保存退出即可
            "Bundle 'fholgado/minibufexpl.vim'

        物理上删除插件，第一步执行保存退出后，再次进入vim
        2.命令行模式，执行: (会物理上删除插件文件)
            :BundleClean

6. 给mac用户

   可以使用mac vim

   首先，安装最新mac vim ,可以正常打开

   然后(需要sudo)

        mv /usr/bin/vim /usr/bin/vim.bk
        ln -s /usr/local/bin/mvim /usr/bin/vim

   最后，在.bashrc/.bash_profile中加入

        alias vi='mvim -v'
        alias vim='mvim -v'

   配置完成

7. 冲突和问题排查

    插件很多，并且其默认快捷键或者配置可能发生冲突

    当加入新插件发现有冲突或者展现有问题

    请排除法进行排查：注掉所有插件或配置，然后二分法逐一恢复，可以定位到出现问题的插件或配置,修改其配置或键位即可

8. 旧版本用户

    旧版本用户更新代码后需执行

        1.bash install.sh [多了一个软连接.vimrc.bundles]
          or
          ln -s PATH-TO-k-vim/vimrc.bundles ~/.vimrc.bundles
        2.插件安装和更新 :BundleInstall 和 :BundleUpdate

---------------------------------

---------------------------------

# 自定义快捷键

    1. 可以自己修改vimrc中配置，决定是否开启鼠标

    set mouse-=a           " 鼠标暂不启用, 键盘党....
    set mouse=a            " 开启鼠标

    2. 可以自己修改vimrc决定是否使用方向键进行上下左右移动，默认打开，可以注解
    hjkl  上下左右

    map <Left> <Nop>
    map <Right> <Nop>
    map <Up> <Nop>
    map <Down> <Nop>

    3. 上排F功能键

    F1 废弃这个键,防止调出系统帮助
    F2 set nu/nonu,行号开关，用于鼠标复制代码用
    F3 set list/nolist,显示可打印字符开关
    F4 set wrap/nowrap,换行开关
    F5 set paste/nopaste,粘贴模式paste_mode开关,用于有格式的代码粘贴
    F6 syntax on/off,语法开关，关闭语法可以加快大文件的展示

    4. 分屏移动

    ctrl + jkhl 进行上下左右窗口跳转,不需要ctrl+w+jkhl

    5. 搜索
    <space> 空格，进入搜索状态
    /       同上
    ,/      去除匹配高亮

    6. buffer/tab相关
    <- / -> 前后buffer

    , + tn  新tab
    , + to  tabonly
    , + tc  close
    , + tm  tab move
    , + te  new tab edit

    7. 按键修改
    Y   =y$   复制到行尾
    U   =Ctrl-r
    , + sa    select all,全选
    , + v     选中段落
    kj        代替ESC
    kj        <Esc>，不用到角落去按esc了
    t         新起一行，下面，不进入插入模式
    T         新起一行，上面
    , + q     :q，退出vim


    优化:
    1. j/k 对于换行展示移动更友好
    2. HL 修改成 ^$, 更方便在同行移动
    3. ; 修改成 : ，一键进入命令行模式，不需要按shift
    4. 命令行模式 ctrl+a/e 到开始结尾
    5. <和> 代码缩进后自动再次选中
    6. 对py文件，保存自动去行尾空白，打开自动加行首代码


---------------------------------

---------------------------------

# 插件部分

> 基础

1. ####插件管理 [gmarik/vundle](https://github.com/gmarik/vundle)

    必装,用于管理所有插件
    命令行模式下管理命令:

        :BundleInstall     install
        :BundleInstall!    update
        :BundleClean       remove plugin not in list

1. ####多语言语法检查 [scrooloose/syntastic](https://github.com/scrooloose/syntastic)

    建议安装，静态语法及风格检查,支持多种语言

    修改了下标记一列的背景色,原有的背景色在solarized下太难看了…..

    演示

    ![syntastic](https://github.com/wklken/gallery/blob/master/vim/syntastic.png?raw=true)

> 自动补全

1. ####代码自动补全 [Valloric/YouCompleteMe](https://github.com/Valloric/YouCompleteMe)

    必装，强烈推荐(YCM是我目前用到的最好的自动补全插件)

    需要编译这个插件(见github文档)

    这个需要自己去看官方的配置方式,演示在官方github有

    需要Vim 7.3.584 以上版本([如何编译vim](https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source))

    这个插件包含了以下几个插件功能,所以不需要装下面:

        clang_complete
        AutoComplPop
        Supertab
        neocomplcache
        jedi(对python的补全)

    快捷键:

        ,gd  跳到声明位置, 仅 filetypes: c, cpp, objc, objcpp, python 有效


2. ####代码片段快速插入 [SirVer/ultisnips](https://github.com/SirVer/ultisnips) +[honza/vim-snippets](https://github.com/honza/vim-snippets)

    注意：如果是之前安装的k-vim，更新后发现报错，是ultisnips版本问题 执行:BundleUpdate即可

    必装，效率杀手锏，快速插入自定义的代码片段

    代码片段集合，有缺陷

    自动补全加这个,高效必备, 针对各种语言已经带了一份配置了，可以到安装目录下查看具体，我有针对性补全一份，在snippets目录下，可自行修改

    演示

    ![ultisnips](https://github.com/wklken/gallery/blob/master/vim/utilsnips.gif?raw=true)


4. ####引号配对补全 [Raimondi/delimitMate](https://github.com/Raimondi/delimitMate)

    必装，输入引号,括号时,自动补全

    对python的docstring 三引号做了处理(只处理""", '''暂时没配，可以自己加)

    演示

    ![delimitmate](https://github.com/wklken/gallery/blob/master/vim/delimate.gif?raw=true)


5. ####html/xml标签配对补全 [docunext/closetag.vim]()


> 快速编码

2. ####快速注释 [scrooloose/nerdcommenter](https://github.com/scrooloose/nerdcommenter)

    必装，另一个大大提升效率的地方，快速批量加减注释

        [d] shift+v+方向键选中(默认当前行)
            ->  ,cc  加上注释
            -> ,cu 解开注释

    演示

    ![nerdcommenter](https://github.com/wklken/gallery/blob/master/vim/nerdcomment.gif?raw=true)


3. ####快速编辑 [tpope/vim-surround](https://github.com/tpope/vim-surround) +[tpope/vim-repeat](https://github.com/tpope/vim-repeat)

    必装，很给力的功能，快速给词加环绕符号,例如引号

    repeat进行增强,'.'可以重复命令

        [d]
        cs"' [inside]
        "Hello world!" -> 'Hello world!'
        ds"
        "Hello world!" -> Hello world!
        ysiw"
        Hello -> "Hello"

    演示

    ![surround](https://github.com/wklken/gallery/blob/master/vim/surround.gif?raw=true)


3. ####去行尾空格 [bronson/vim-trailing-whitespace](https://github.com/bronson/vim-trailing-whitespace)

    将代码行最后无效的空格标红

        [sd] ,空格    去掉当前行末尾空格

> 快速移动

1. ####位置跳转[Lokaltog/vim-easymotion](https://github.com/Lokaltog/vim-easymotion)

    必装，效率提升杀手锏，跳转到光标后任意位置

    配置(我的leader键配置 let g:mapleader = ',')

        ,, + w  跳转
        ,, + fe  查找'e',快速跳转定位到某个字符位置

    演示

    ![easy_motion](https://github.com/wklken/gallery/blob/master/vim/easymotion.gif?raw=true)

2. ####符号匹配跳转[vim-scripts/matchit.zip](https://github.com/vim-scripts/matchit.zip)

    选装

    % 匹配成对的标签，跳转

3. ####mark跳转 [kshenoy/vim-signature](https://github.com/kshenoy/vim-signature)


> 快速选中

6. ####区块伸缩 [terryma/vim-expand-region](https://github.com/terryma/vim-expand-region)

    视图模式下可伸缩选中部分，用于快速选中某些块

        [sd]
        = 增加选中范围(+/=按键)
        - 减少选中范围(_/-按键)

    演示（直接取链到其github图)

    ![expand-region](https://raw.github.com/terryma/vim-expand-region/master/expand-region.gif)


7. ####多光标选中编辑 [vim-multiple-cursors](https://github.com/terryma/vim-multiple-cursors)

    多光标批量操作

        [sd]
        ctrl + m 开始选择
        ctrl + p 向上取消
        ctrl + x 跳过
        esc   退出

    演示(官方演示图)

    ![multiple-cursors](https://raw.github.com/terryma/vim-multiple-cursors/master/assets/example1.gif)

> 功能相关

1. ####搜索 [kien/ctrlp.vim](https://github.com/kien/ctrlp.vim)

    文件搜索,ack/Command-T需要依赖于外部包,不喜欢有太多依赖的,除非十分强大, 具体 [文档](http://kien.github.io/ctrlp.vim/)

        [sd] ,p  打开ctrlp搜索
        [sd] ,f  相当于mru功能，show recently opened files

        ctrl + j/k 进行上下移动

    演示

    ![ctrip](https://github.com/wklken/gallery/blob/master/vim/ctrlp.gif?raw=true)

2. ####git [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive)

    git插件

    不是很习惯,所以用的次数太少,目前和现有配置快捷键有冲突,尚未解决

3. ####文件时光机 [sjl/gundo.vim](https://github.com/sjl/gundo.vim)

    编辑文件时光机

        [sd] ,h  查看文件编辑历史

> 显示增强


1. ####状态栏增强 [Lokaltog/vim-powerline](https://github.com/Lokaltog/vim-powerline)

    演示

    ![powerline](https://github.com/wklken/gallery/blob/master/vim/powerline.png?raw=true)

2. ####括号上色高亮 [kien/rainbow_parentheses.vim](https://github.com/kien/rainbow_parentheses.vim)

    演示

    ![rainbow](https://github.com/wklken/gallery/blob/master/vim/rainbow_parentheses.png?raw=true)

> 显示增强-主题

4. ####[altercation/vim-colors-solarized](https://github.com/altercation/vim-colors-solarized)

   经典主题,目前我使用的,看起来舒服

5. ####[tomasr/molokai](https://github.com/tomasr/molokai)

   用sublime text2的同学应该很熟悉, 另一个主题,可选,偶尔换换味道

默认值提供solarized和molokai主题，其他主题需自行配置安装

> 快速导航

1. ####目录树 [scrooloose/nerdtree](https://github.com/scrooloose/nerdtree)

    必装,开启目录树导航

        [sd]
            ,n  打开 关闭树形目录结构

            在nerdtree窗口常用操作：(小写当前，大写root)
            x.......Close the current nodes parent收起当前目录树
            R.......Recursively refresh the current root刷新根目录树
            r.......Recursively refresh the current directory刷新当前目录
            P.......Jump to the root node
            p.......Jump to current nodes parent
            K.......Jump up inside directories at the current tree depth  到同目录第一个节点
            J.......Jump down inside directories at the current tree depth 最后一个节点
            o.......Open files, directories and bookmarks
            i.......Open selected file in a split window上下分屏
            s.......Open selected file in a new vsplit左右分屏

    演示

    ![thenerdtree](https://github.com/wklken/gallery/blob/master/vim/thenerdtree.gif?raw=true)

2. ####Buffer [fholgado/minibufexpl.vim](https://github.com/fholgado/minibufexpl.vim)

    必装，buffer管理, 可以查找其他同类插件

        [sd]
            <Tab>  切换buffer
            左右方向键  切换buffer
            ,bn   切到后一个
            ,bp   切到前一个
            ,bd   关闭当前buffer

2. ####Tag [majutsushi/tagbar](https://github.com/majutsushi/tagbar)

    必装,标签导航,纬度和taglist不同

         [sd] <F9> 打开

    演示

    ![tagbar](https://github.com/wklken/gallery/blob/master/vim/tagbar.gif?raw=true)

3. ####Tag [vim-scripts/taglist.vim](https://github.com/vim-scripts/taglist.vim)

    根据需要安装,需要安装依赖ctags

         [sd] <F8>打开

    演示:

    ![taglist](https://github.com/wklken/gallery/blob/master/vim/taglist.png?raw=true)

> 语言相关- 需要自定义编辑确认是否保留(默认打开)

1. ####Python

    语法高亮[python-syntax](https://github.com/hdima/python-syntax)

    使用Python建议安装，python语法高亮,就是python.vim,在github,有维护和更新

    语法检查[kevinw/pyflakes-vim](https://github.com/kevinw/pyflakes-vim)

    虽然这个的作者推荐使用syntastic,但是这个插件对于pythoner还是很需要的

    因为有一个特牛的功能,fly check,即,编码时在buffer状态就能动态查错标记,弥补syntastic只能保存和打开时检查语法错误的不足

    演示

    ![pyflakes](https://github.com/wklken/gallery/blob/master/vim/pyflakes.png?raw=true)

2. ####Golang

    Go语言自动补全[Blackrush/vim-gocode]()

3. ####Markdown

    [plasticboy/vim-markdown](https://github.com/plasticboy/vim-markdown)

    markdown语法,编辑md文件

4. ####HTML/JS/JQUERY/CSS

    [pangloss/vim-javascript](https://github.com/pangloss/vim-javascript)

    偶尔会看看js,频率不高

    [maksimr/vim-jsbeautify](https://github.com/maksimr/vim-jsbeautify) 未配置

    js/html/css 格式化

    [nono/jquery.vim](https://github.com/nono/jquery.vim)

    jquery高亮

    [elzr/vim-json](https://github.com/elzr/vim-json)

    json高亮,未配置

    [kchmck/vim-coffee-script](https://github.com/kchmck/vim-coffee-script)

    coffeescript,未配置

    [groenewege/vim-less](https://github.com/groenewege/vim-less)

    less,未配置

    [emmet](https://github.com/mattn/emmet-vim)

    zencoding,未配置

    [gorodinskiy/vim-coloresque](https://github.com/gorodinskiy/vim-coloresque) 配置 |
    [vim-css-color](https://github.com/ap/vim-css-color) 未配置
    css颜色展示

5. ####Jinja2

    [Glench/Vim-Jinja2-Syntax](https://github.com/Glench/Vim-Jinja2-Syntax)

    jinja2 语法高亮

6. ####Ruby

    [tpope/vim-rails](https://github.com/tpope/vim-rails)
    未配置

7. ####PHP

    [spf13/PIV](https://github.com/spf13/PIV)
    未配置

    [arnaud-lb/vim-php-namespace](https://github.com/arnaud-lb/vim-php-namespace)
    未配置

8. ####非语言语法高亮

    [evanmiller/nginx-vim-syntax](https://github.com/evanmiller/nginx-vim-syntax)
    nginx

> 其他

1. ####平滑滚动

    [terryma/vim-smooth-scroll](https://github.com/terryma/vim-smooth-scroll)
    未配置

2. ####多人协作，结对编程

    [FredKSchott/CoVim](https://github.com/FredKSchott/CoVim)
    未配置

3. ####单行多行变换

    [AndrewRadev/splitjoin.vim](https://github.com/AndrewRadev/splitjoin.vim)
    未配置

4. ####TODO关键字列表

    [vim-scripts/TaskList.vim](https://github.com/vim-scripts/TaskList.vim)
    未配置

---------------------------------

---------------------------------

### Update Log

2014-06-11 创建:

    vim配置

2014-03-15更新：

    1.更全的注释
    2.更合理文件结构和配置布局
    3.分离插件配置到vimrc.bundles
    4.更强大的代码补全
    5.去掉一些无用信息

TODO:

    1.
    Taglist有没有必要存在?


    2.
    增加一些语言类的插件配置

    3.
    代码格式化
    https://github.com/godlygeek/tabular

    4.
    代码缩进展示-准备加入
    https://github.com/nathanaelkane/vim-indent-guides

    5.
    非paste模式下
    黏贴的时候，不要自动补全加括号

    6.
    比较
    kana/vim-smartinput 和delimate
    gundo 和 mbbill/undotree [spf13]
    ctrlp 和 fuzzyfinder 及Shougo/unite.vim
    powerline和'bling/vim-airline' [spf13]
    nerdcommenter commentary comment https://github.com/tpope/vim-commentary

    7.
    有价值的
    git https://github.com/airblade/vim-gitgutter

    https://github.com/michaeljsmith/vim-indent-object

    剪贴板共享-准备加入
    https://github.com/vim-scripts/YankRing.vim

    8.
    待使用确认
    函数参数位置调整 https://github.com/PeterRincker/vim-argumentative
    shell https://github.com/vim-scripts/Conque-Shell

    https://github.com/mhinz/vim-signify

    tpope   Bundle 'tpope/vim-bundler'
            Bundle 'tpope/vim-cucumber'
            Bundle 'tpope/vim-endwise'
            Bundle 'tpope/vim-pastie'
            Bundle 'tpope/vim-ragtag'
            Bundle 'tpope/vim-rails'
            Bundle 'tpope/vim-vividchalk'
            tpope/vim-sensible
    vim preview https://github.com/greyblake/vim-preview
    bufferline https://github.com/bling/vim-bufferline
    https://github.com/osyo-manga/vim-over
    更强大的命令行替换 https://github.com/tpope/vim-abolish
    how about https://github.com/klen/python-mode
    writing room https://github.com/junegunn/goyo.vim & https://github.com/amix/vim-zenroom2
    python-imports.vim
    fast than c tag https://github.com/tacahiroy/ctrlp-funky
    https://github.com/tpope/vim-unimpaired
    vim-speeddating
    speeddating.vim: use CTRL-A/CTRL-X to increment dates, times, and more
    easybuffer.vim
    easybuffer.vim - vim plugin to quickly switch between buffers
    https://github.com/jaredly/vim-debug/
    https://github.com/suan/vim-instant-markdown
    https://github.com/msanders/cocoa.vim
    https://github.com/fatih/vim-go
    https://github.com/itchyny/lightline.vim
    https://github.com/vim-scripts/cmdline-completion
    https://github.com/myusuf3/numbers.vim

    "showmarks
    Bundle 'vim-scripts/ShowMarks'
    "markbrowser
    Bundle 'vim-scripts/Marks-Browser'

    vim-scripts/Conque-Shell
    shell https://github.com/Shougo/vimshell.vim
    iterm2+vim https://github.com/sjl/vitality.vim

    text-object 插件做什么用的？
    https://github.com/kana/vim-textobj-user

### Inspire

1. vimrc文件布局`vimrc+vimrc.bundles`配置方式参考 [maximum-awesome](https://github.com/square/maximum-awesome)

2. install.sh 参考`spf13-vim` 的`bootstrap.sh` [spf13-vim](https://github.com/spf13/spf13-vim)

2. 插件管理使用[Vundle](https://github.com/gmarik/Vundle.vim)

3. 自动补全 [YCM](https://github.com/Valloric/YouCompleteMe)

### Resources

1. [Google+](https://plus.google.com/communities/105049811056605918816)

2. [vimbits](http://www.vimbits.com/bits?sort=top)

3. [Learning vim the hard way](http://learnvimscriptthehardway.stevelosh.com/)

4. [Seven habits of effective text editing](http://www.moolenaar.net/habits.html)

5. [openvim tutorial](http://www.openvim.com/tutorial.html)

6. [vim genius](http://www.vimgenius.com/)

------------------------

------------------------

The End!

wklken (凌岳/pythoner/vim党预备党员)

Email: wklken@yeah.net

Github: https://github.com/wklken

Blog: [http://www.wklken.me](http://www.wklken.me)

2013-06-11 于深圳

