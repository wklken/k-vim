k-vim
=======================

> VERSION: 9.0

> LAST_UPDATE_TIME: 2015-05-02

> 本次更新: 更强大的搜索, 快速运行等


详细 [更新日志](https://github.com/wklken/k-vim/blob/master/UPDATE_LOG.md)

# 目标

> Just a Better Vim Config. Keep it Simple.

    0. 保持简单
    1. 结构划分良好, 中文注释
    2. 高度可配置修改
    3. 一键安装少折腾
    4. 更加符合直觉的键位操作(*)

适用人群：

    有一定基础的 vimer

**PS**: 服务器端无插件`k-vim`简化版本, 有需要可以安装(curl直接设置vimrc即可)[vim-for-server](https://github.com/wklken/vim-for-server)

### k-vim使用说明

1. 最好能熟练使用原生vim各类操作之后, 再来使用插件扩展

2. `fork`一份(需要的话顺带`star`关注更新), 然后参照安装步骤进行安装, 可以根据自身习惯进行自定义修改

3. 目前主要关注后端`python`, `golang`以及将要入坑的`ruby`, 偶尔写写`js/jquery`, 但是主体配置基本是通用的. 可以根据语言体系自己加配置(vimrc.bundles)

4. 插件不是越多越好, 二八定律

5. 欢迎大家推荐好用的资源, 不限于插件/主题/ppt/文章/视频等, 也希望大家能一起完善这份配置


## 疑问解决步骤

你遇到的问题,一定别人也遇到了

1. 首先明确问题, 可以用`二分法`排查出问题的插件或配置语句
2. 确认按照文档步骤执行的操作
3. 如果是对应插件的问题, 请到插件github主页查看文档及issues
4. google大法
5. 提issues


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

        # ctags, ag(the_silver_searcher)

        2.1 系统依赖

        # ubuntu
        sudo apt-get install ctags
        sudo apt-get install build-essential cmake python-dev  #编译YCM自动补全插件依赖
        sudo apt-get install silversearcher-ag

        # centos
        sudo yum install python-devel.x86_64
        sudo yum groupinstall 'Development Tools'
        sudo rpm -Uvh http://download.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm
        sudo yum install the_silver_searcher
        sudo yum install cmake

        # mac
        brew install ctags
        brew install the_silver_searcher


        2.2 使用Python
        sudo pip install pyflakes
        sudo pip install pylint
        sudo pip install pep8

        2.3 如果使用Javascript, 不需要的跳过
        # 安装jshint和jslint,用于javascript语法检查
        # 需要nodejs支持,各个系统安装见文档 https://github.com/joyent/node/wiki/Installing-Node.js-via-package-manager

        #ubuntu
        sudo apt-get install nodejs npm
        sudo npm install -g jslint
        sudo npm install jshint -g

        #mac
        brew install node
        npm install jshint -g
        npm install jslint -g


3. 安装

        3.1 进入目录
        # 注意原先装过的童鞋, 重装时，不要到~/.vim下执行(这是软连接指向k-vim真是目录)，必须到k-vim原生目录执行

        cd k-vim/

        3.2 执行安装
        # 会进入安装插件的列表，目前30+个插件，一一安装是从github clone的，完全取决于网速, 之后会自动编译 YCM, 编译失败的话需要手动编译, 见第4步

        sh -x install.sh


4. 可能遇到的问题:


    - 编译自动补全YouCompleteMe(耗时略长, 但绝对值得)


            cd ~/.vim/bundle/YouCompleteMe
            ./install.sh --clang-completer


    有任何问题见YCM[文档](https://github.com/Valloric/YouCompleteMe)

    这个插件需要Vim 7.3.584,所以,如果vim版本太低,需要[编译安装](https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source)


    - 相对行号

    vimrc中配置,如果不习惯,可以去掉,[相关参考](http://jeffkreeftmeijer.com/2012/relative-line-numbers-in-vim-for-super-fast-movement/)

    - 配置主题

    到vimrc中修改colortheme,可以使用molokai(用惯sublimetext2的童鞋很熟悉)

    默认配置的是[solarized dark主题](https://github.com/altercation/vim-colors-solarized)

    想要修改终端配色为solarized可以参考 [这里](https://github.com/sigurdga/gnome-terminal-colors-solarized)

    如果是mac原生terminal, 可以参考这里的配置 [issue104](https://github.com/wklken/k-vim/issues/104)

    - Go语言不能自动补全/tagbar

    依赖 [gotags](https://github.com/jstemmer/gotags)和 [gocode](https://github.com/nsf/gocode), 需要安装配置好, 并-> `$GOPATH` -> `$PATH`, `which`命令能正确返回

        which gotags
        which gocode

    - Javascript不能自动补全
    `vimrc.bundles`中`marijnh/tern_for_vim`默认没有打开, 需要打开安装插件, 需要依赖nodejs&npm, 具体见文档 [tern_for_vim](https://github.com/marijnh/tern_for_vim)

    - Macvim

            安装最新mac vim ,可以正常打开

            需要sudo
            mv /usr/bin/vim /usr/bin/vim.bk
            ln -s /usr/local/bin/mvim /usr/bin/vim

            在.bashrc/.bash_profile中加入
                alias vi='mvim -v'
                alias vim='mvim -v'


    - 其他问题: 键位/展现等存在问题, 使用`二分法`缩小范围, 排查到问题根源, 修改配置


5. 安装/卸载/更新插件：

    安装新插件

        1. vimrc.bundles中配置对应插件
            Bundle 'xxx/xxxx'
        2. 命令行模式，执行:
            :BundleInstall

    更新插件(注意如果YCM更新, 可能需要重编译, 否则自动补全可能失效)

        命令行模式，执行:
        :BundleUpdate

    删除插件

        1. vimrc.bundles中注释或删除对应插件bundle配置行(行首加一个双引号)
        2.命令行模式，执行: (会物理上删除插件文件)
            :BundleClean



---------------------------------

---------------------------------

# 自定义快捷键

    注意, 以下 `,` 代表<leader>
    1. 可以自己修改vimrc中配置，决定是否开启鼠标

    set mouse-=a           " 鼠标暂不启用, 键盘党....
    set mouse=a            " 开启鼠标

    2. 退出vim后，内容显示在终端屏幕, 可以用于查看和复制, 如果不需要可以关掉
       好处：误删什么的，如果以前屏幕打开，可以找回....惨痛的经历

    set t_ti= t_te=

    3. 可以自己修改vimrc决定是否使用方向键进行上下左右移动，默认关闭，强迫自己用 hjkl，可以注解
    hjkl  上下左右

    map <Left> <Nop>
    map <Right> <Nop>
    map <Up> <Nop>
    map <Down> <Nop>

    4. 上排F功能键

    F1 废弃这个键,防止调出系统帮助
    F2 set nu/nonu,行号开关，用于鼠标复制代码用
    F3 set list/nolist,显示可打印字符开关
    F4 set wrap/nowrap,换行开关
    F5 set paste/nopaste,粘贴模式paste_mode开关,用于有格式的代码粘贴
    F6 syntax on/off,语法开关，关闭语法可以加快大文件的展示

    F9 tagbar
    F10 运行当前文件(quickrun)

    5. 分屏移动

    ctrl + j/k/h/l   进行上下左右窗口跳转,不需要ctrl+w+jkhl

    6. 搜索
    <space> 空格，进入搜索状态
    /       同上
    ,/      去除匹配高亮

    (交换了#/* 号键功能, 更符合直觉, 其实是离左手更近)
    #       正向查找光标下的词
    *       反向查找光标下的词

    优化搜索保证结果在屏幕中间

    7. tab操作(重点推)
    ctrl+t 新建一个tab

    (hjkl)
    ,th    切第1个tab
    ,tl    切最后一个tab
    ,tj    下一个tab
    ,tk    前一个tab

    ,tn    下一个tab(next)
    ,tp    前一个tab(previous)

    ,td    关闭tab
    ,te    tabedit
    ,tm    tabm

    ,1     切第1个tab
    ,2     切第2个tab
    ...
    ,9     切第9个tab
    ,0     切最后一个tab

    ,tt 最近使用两个tab之间切换
    (可修改配置位 ctrl+o,  但是ctrl+o/i为系统光标相关快捷键, 故不采用)

    8. buffer操作(不建议, 建议使用ctrlspace插件来操作)
    [b    前一个buffer
    ]b    后一个buffer
    <-    前一个buffer
    ->    后一个buffer


    9. 按键修改
    Y         =y$   复制到行尾
    U         =Ctrl-r
    ,sa       select all,全选
    ,v        选中段落
    kj        代替<Esc>，不用到角落去按esc了

    ,q     :q，退出vim
    ,w     :w, 保存当前文件

    ctrl+n    相对/绝对行号切换
    <enter>   normal模式下回车选中当前项



    更多优化:
        1. j/k 对于换行展示移动更友好
        2. HL 修改成 ^$, 更方便在同行移动
        3. ; 修改成 : ，一键进入命令行模式，不需要按shift
        4. 命令行模式 ctrl+a/e 到开始结尾
        5. <和> 代码缩进后自动再次选中, 方便多次缩进, esc退出
        6. 对py文件，保存自动去行尾空白，打开自动加行首代码
        7. 交换#/*号功能,#号为正向查找,*反向
        8. `w!!`强制保存, 即使readonly
        9. 去掉错误输入提示
        10. 交换`和', '能跳转到准确行列位置
        11. python/ruby 等, 保存时自动去行尾空白
        12. 统一所有分屏打开的操作位v/s[nerdtree/ctrlspace] (特殊ctrlp ctrl+v/x)
        13. `,zz`       代码折叠toggle

---------------------------------

---------------------------------

# 插件部分

简介及演示(blog外链)

- [vundle](http://www.wklken.me/posts/2015/06/07/vim-plugin-vundle.html)
- [easymotion](http://www.wklken.me/posts/2015/06/07/vim-plugin-easymotion.html)
- [signature](http://www.wklken.me/posts/2015/06/07/vim-plugin-signature.html)
- [multiple-cursors](http://www.wklken.me/posts/2015/06/07/vim-plugin-multiplecursors.html)
- [easyalign](http://www.wklken.me/posts/2015/06/07/vim-plugin-easyalign.html)
- [matchit](http://www.wklken.me/posts/2015/06/07/vim-plugin-matchit.html)
- [delimitmate](http://www.wklken.me/posts/2015/06/07/vim-plugin-delimitmate.html)
- [syntastic](http://www.wklken.me/posts/2015/06/07/vim-plugin-syntastic.html)
- [rainbowparentheses](http://www.wklken.me/posts/2015/06/07/vim-plugin-rainbowparentheses.html)
- [nerdcommenter](http://www.wklken.me/posts/2015/06/07/vim-plugin-nerdcommenter.html)
- [tagbar](http://www.wklken.me/posts/2015/06/07/vim-plugin-tagbar.html)
- [theme](http://www.wklken.me/posts/2015/06/07/vim-plugin-theme.html)
- [airline](http://www.wklken.me/posts/2015/06/07/vim-plugin-airline.html)
- [ctrlp](http://www.wklken.me/posts/2015/06/07/vim-plugin-ctrlp.html)
- [closetag](http://www.wklken.me/posts/2015/06/07/vim-plugin-closetag.html)
- [trailing-whitespace](http://www.wklken.me/posts/2015/06/07/vim-plugin-trailing-whitespace.html)
- [quick-run](http://www.wklken.me/posts/2015/06/13/vim-plugin-quickrun.html)
- [expand-region](http://www.wklken.me/posts/2015/06/13/vim-plugin-expandregion.html)
- [gundo](http://www.wklken.me/posts/2015/06/13/vim-plugin-gundo.html)
- [surround & repeat](http://www.wklken.me/posts/2015/06/13/vim-plugin-surround-repeat.html)


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

        ,s  列出/隐藏当前文件所有错误列表

    演示

    ![syntastic](https://github.com/wklken/gallery/blob/master/vim/syntastic.png?raw=true)


> 自动补全

1. ####代码自动补全 [Valloric/YouCompleteMe](https://github.com/Valloric/YouCompleteMe)

    必装，强烈推荐(YCM是我目前用到的最好的自动补全插件)

    这个插件包含了以下几个插件功能,所以不需要装下面:

        clang_complete
        AutoComplPop
        Supertab
        neocomplcache
        jedi(对python的补全)

    敲两个字符后弹出提示, 支持各语言标准库补全

    快捷键:

        ctrl+j 选择下一个补全
        ctrl+k 选择上一个补全

        ctrl+n 选择下一个补全
        ctrl+p 选择上一个补全
        回车    选中
        ,jd  跳转到函数定义, 分屏打开一个buffer(非常有用!!!!!!!!!)
        ,gd  跳到声明位置, 仅 filetypes: c, cpp, objc, objcpp, python 有效(比较少用)

    演示(官方截图)

    ![ycm](https://camo.githubusercontent.com/1f3f922431d5363224b20e99467ff28b04e810e2/687474703a2f2f692e696d6775722e636f6d2f304f50346f6f642e676966)



2. ####代码片段快速插入 [SirVer/ultisnips](https://github.com/SirVer/ultisnips) +[honza/vim-snippets](https://github.com/honza/vim-snippets)

    必装，效率杀手锏，快速插入自定义的代码片段, 高效必备

    YCM 自动补全会弹提示

        ctrl+j 上一个
        ctrl+k 下一个

        ctrl+n 上一个
        ctrl+p 下一个
        <tab>  使用片段 -> expand to codes
        ,us    编辑对应文件类型的代码片段

    演示

    ![ultisnips](https://github.com/wklken/gallery/blob/master/vim/utilsnips.gif?raw=true)


4. ####引号配对补全 [Raimondi/delimitMate](https://github.com/Raimondi/delimitMate)

    必装，输入引号,括号时,自动补全

    对python的docstring 三引号做了处理(只处理""", '''暂时没配，可以自己加)

    演示

    ![delimitmate](https://github.com/wklken/gallery/blob/master/vim/delimate.gif?raw=true)

    附:同类插件 [kana/vim-smartinput](https://github.com/kana/vim-smartinput)


5. ####html/xml标签配对补全 [docunext/closetag.vim](https://github.com/docunext/closetag.vim)


> 快速编码

2. ####快速注释 [scrooloose/nerdcommenter](https://github.com/scrooloose/nerdcommenter)

    必装，另一个大大提升效率的地方，快速批量加减注释[会自动补一个空格]

        [d] shift+v+方向键选中(默认当前行)
            -> ,cc      加上注释
            -> ,cu      解开注释
            -> ,c<space> 加上/解开注释
            -> ,cy      先复制再注解, p可以粘贴未注释前的代码

    演示

    ![nerdcommenter](https://github.com/wklken/gallery/blob/master/vim/nerdcomment.gif?raw=true)


    附:注释还有其他两种插件可选[tcomment](https://github.com/tomtom/tcomment_vim) 和[tpope/vim-commentary](https://github.com/tpope/vim-commentary)


3. ####快速编辑 [tpope/vim-surround](https://github.com/tpope/vim-surround) +[tpope/vim-repeat](https://github.com/tpope/vim-repeat)

    必装，很给力的功能，快速给词加环绕符号,例如引号, 注意(括号, 左括号会加空格, 右括号不会)

    repeat进行增强,'.'可以重复使用命令 (ys=you surround)

        [d]
        cs"'
        "Hello world!" -> 'Hello world!'

        ds"
        "Hello world!" -> Hello world!

        ysiw"
        Hello -> "Hello"

        yss"
        Hello world -> "Hello world"

        cst"
        <a>abc</a>  -> "abc"

        veeS"
        hello world -> "hello world"

        ys$" 当前到行尾, 引号引住



    演示

    ![surround](https://github.com/wklken/gallery/blob/master/vim/surround.gif?raw=true)

4. ####快速运行 [vim-quickrun](https://github.com/thinca/vim-quickrun)

        F10或<leader>r  快速运行当前文件


3. ####去行尾空格 [bronson/vim-trailing-whitespace](https://github.com/bronson/vim-trailing-whitespace)

    将代码行最后无效的空格标红

        [sd] ,空格    去掉当前行末尾空格

4. ####赋值语句代码对齐 [junegunn/vim-easy-align](https://github.com/junegunn/vim-easy-align)

    将代码,或者json等, 根据表达式符号进行对齐,具体见例子 [examples](https://github.com/junegunn/vim-easy-align/blob/master/EXAMPLES.md)

        [sd]  可以选中多行,不选中默认操作当前行
            ,a= 对齐等号表达
            ,a: 对齐冒号表达式(json/map等)
            ,a<space>  首个空格对齐
            ,a2<space> 第二个空格对齐
            ,a*<space> 所有空格依次对齐


    同类插件 [tabular](https://github.com/godlygeek/tabular)

> 快速移动

1. ####位置跳转[Lokaltog/vim-easymotion](https://github.com/Lokaltog/vim-easymotion)

    必装，效率提升杀手锏，跳转到光标后任意位置

    easymothion主要用于快速查找跳转, 今天看了支持jk快速跳转(支持多字母搜索跳转不过我认为太重了)

    配置(我的leader键配置 let g:mapleader = ',')

        ,, + w  跳转
        ,, + fe  查找'e',快速跳转定位到某个字符位置
        ,,j      快速决定移动到下面哪行(比用行号/j移动快)
        ,,k      快速移动到上面哪行
        ,,l      本行, 向后快速移动
        ,,h      本行, 向前快速移动
        ,,.      重复上一次easymotion命令

    演示

    ![easy_motion](https://github.com/wklken/gallery/blob/master/vim/easymotion.gif?raw=true)

2. ####符号匹配跳转[vim-scripts/matchit.zip](https://github.com/vim-scripts/matchit.zip)

    必装

    % 匹配成对的标签，跳转

3. ####mark跳转 [kshenoy/vim-signature](https://github.com/kshenoy/vim-signature)

    必装, 快速打标签, 随时跳回标签位置(修复python自动去除空白函数和该插件冲突的问题)


        m[a-zA-Z]   打标签
        '[a-zA-Z]   跳转到标签位置
        '. 最后一次变更的地方
        '' 跳回来的地方

        m<space>    去除所有标签

> 快速选中

6. ####区块伸缩 [terryma/vim-expand-region](https://github.com/terryma/vim-expand-region)

    视图模式下可伸缩选中部分，用于快速选中某些块

        [sd]
        v 增加选中范围
        V 减少选中范围

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

> 文本对象扩展

1. 自定义文本对象 [kana/vim-textobj-user.git](https://github.com/kana/vim-textobj-user.git)

   后面几个扩展对象的依赖

   更多其他扩展,见 [wiki](https://github.com/kana/vim-textobj-user/wiki)

   PS: 特希望有一个扩展支持 '' "" [] {} ()

2. 行文本对象 [kana/vim-textobj-line](https://github.com/kana/vim-textobj-line)

   增加文本对象: l

        dal
        yal
        cil

3. 缩进文本对象 [kana/vim-textobj-indent.git](https://github.com/kana/vim-textobj-indent.git)

   增加文本对象: i

   相同缩进属于同一块,对python很有用

        dai
        yai
        cii

4. 文件文本对象 [kana/vim-textobj-entire.git](https://github.com/kana/vim-textobj-entire.git)

   增加文本对象: e

        dae
        yae
        cie



> 功能相关

1. ####搜索 [kien/ctrlp.vim](https://github.com/kien/ctrlp.vim)

    文件搜索,ack/Command-T需要依赖于外部包,不喜欢有太多依赖的,除非十分强大, 具体 [文档](http://kien.github.io/ctrlp.vim/)

        [sd] ,p  打开ctrlp搜索
        [sd] ,f  相当于mru功能，show recently opened files

        ctrl + j/k 进行上下移动
        ctrl + x/v 分屏打开该文件 [重要**]
        ctrl + t   在新tab中打开该文件

    演示

    ![ctrip](https://github.com/wklken/gallery/blob/master/vim/ctrlp.gif?raw=true)

    插件:
    当前文件快速函数搜索:[tacahiroy/ctrlp-funky](https://github.com/tacahiroy/ctrlp-funky)

    解决问题:使用tagbar当函数比较多的时候,移动耗时较长,使用快速搜索快很多

        ,fu   进入当前文件函数搜索
        ,fU   搜索光标下单词对应函数

2. ####全局搜索插件(类sumlimetext) [dyng/ctrlsf.vim](https://github.com/dyng/ctrlsf.vim)

    解决了重构代码时需要修改多处的问题

        光标移动到单词, 按\ 进入全局搜索

        进入左侧后的操作:

                    O, 打开
                    <C-o> 水平分屏打开
                    t - 在tab中打开(建议)
                    T - Like t but focus CtrlSF window instead of opened new tab.
                    q - Quit CtrlSF window.


2. ####git 常用操作 [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive)

    git插件, 编辑文件时进行一些diff操作,例如diff

    不是很习惯,所以用的次数太少,目前和现有配置快捷键有冲突,尚未解决

        [sd]
        ,ge   = git diff edit[gd被ycm占用了]

    没有配置其他快捷键,可以参照github,自己增加修改映射

2. ####git状态 [airblade/vim-gitgutter](https://github.com/airblade/vim-gitgutter)

    git,在同一个文件内,通过标记和高亮,显示本次文件变更点

        [sd]
        ,gs   = show diff status [gd被ycm占用了]

    ![gitgutter](https://raw.githubusercontent.com/airblade/vim-gitgutter/master/screenshot.png)

3. ####文件时光机 [sjl/gundo.vim](https://github.com/sjl/gundo.vim)

    编辑文件时光机

        [sd] ,h  查看文件编辑历史

    附:同类插件 [mbbill/undotree](https://github.com/mbbill/undotree)

> 显示增强


1. ####状态栏增强 [bling/vim-airline](https://github.com/bling/vim-airline)

    之前使用powerline, 用airline替换, powerline的配置注释,需要的自行解开

    演示

    ![airline](https://raw.githubusercontent.com/wiki/bling/vim-airline/screenshots/demo.gif)

2. ####括号上色高亮 [kien/rainbow_parentheses.vim](https://github.com/kien/rainbow_parentheses.vim)

    演示

    ![rainbow](https://github.com/wklken/gallery/blob/master/vim/rainbow_parentheses.png?raw=true)

> 显示增强-主题

4. ####[altercation/vim-colors-solarized](https://github.com/altercation/vim-colors-solarized)

   经典主题,目前我使用的,看起来舒服

5. ####[tomasr/molokai](https://github.com/tomasr/molokai)

   用sublime text2的同学应该很熟悉, 另一个主题,可选,偶尔换换味道

6. ####[chriskempson/vim-tomorrow-theme](https://github.com/chriskempson/vim-tomorrow-theme)

   另一款经典主题

默认值提供solarized和molokai主题，其他主题需自行配置安装

> 快速导航

1. ####目录树 [scrooloose/nerdtree](https://github.com/scrooloose/nerdtree)

    必装,开启目录树导航

        [sd]
            ,n  打开 关闭树形目录结构

            在nerdtree窗口常用操作：(小写当前，大写root)
            x.......收起当前目录树
            X.......递归收起当前目录树
            r.......刷新当前目录
            R.......刷新根目录树

            p.......跳到当前节点的父节点
            P.......跳到root节点
            k/j.....上下移动
            K.......到同目录第一个节点
            J.......最后一个节点

            o.......Open files, directories and bookmarks

            s.......split上下分屏[原来是i, 改键]
            v.......vsplit左右分屏[原来是s, 改键]

            c.......将当前目录设为根节点
            q.......关闭

    nerdtree配合tab非常赞, i/s 可以在右侧分屏打开

    演示

    ![thenerdtree](https://github.com/wklken/gallery/blob/master/vim/thenerdtree.gif?raw=true)

2. ####目录树tab增强 [jistr/vim-nerdtree-tabs](https://github.com/jistr/vim-nerdtree-tabs)

    选装, 多个tab时, 保持nerdtree一致

    Just one NERDTree

3. ####tab/buffer导航增强 [vim-ctrlspace](https://github.com/szw/vim-ctrlspace)

    必装, 多buffer/多tab, 方便的查看列表, 操作, 切换, 与nerdtree/tabs完美配合, 很强大, 目前只使用基础功能, 后续根据需要再完善

    注意: 有些人的ctrl+space被占用的, 配一个leader快捷键(下面是默认配置)

          let g:ctrlspace_default_mapping_key="<C-Space>"

    (同时可以看看文档前面部分针对tab的快捷键)

          ctrl+<space> 得到当前tab的buffer列表
          j/k     上下移动
          回车     跳转到
          v/V     vsp分屏打开, v会进入对应文件, V会保留在ctrlspace区域
          s/S     sp分屏打开

          l       展示/关闭tab列表
              j/k 或 [/] 上下移动
              =   给tab命名
              -   Move the current tab to the left (decrease its number)
              +   Move the current tab to the right (increase its number)
              Backspace Go back to Buffer List

          L   Jump to Tab List in Search Mode

          esc/q   close the list

    演示

    ![ctrlspace](https://github.com/wklken/gallery/blob/master/vim/ctrlspace.gif?raw=true)

    官方视频

<p align="center">
<a href="https://www.youtube.com/watch?v=U1hbGJm3J0g">
<img alt="Vim-CtrlSpace 4.0 Demo"
src="https://raw.github.com/szw/vim-ctrlspace/master/gfx/screen_small.png" />
</a>
</p>




4. ####Tag [majutsushi/tagbar](https://github.com/majutsushi/tagbar)

    必装,标签导航,纬度和taglist不同, taglist的替代者

    tagbar针对而一些语言的文档https://github.com/majutsushi/tagbar/wiki

    注意:之前版本有装taglist,决定用tagbar替代,taglist的配置注解未删除,需要的自行打开

         [sd] <F9> 打开

    演示

    ![tagbar](https://github.com/wklken/gallery/blob/master/vim/tagbar.gif?raw=true)


> 语言相关- 需要自定义编辑确认是否保留(默认打开)

1. ####Python

    Vim as a Python IDE, but much more than that!

    语法高亮[python-syntax](https://github.com/hdima/python-syntax)

    使用Python建议安装，python语法高亮,就是python.vim,在github,有维护和更新

    语法检查[kevinw/pyflakes-vim](https://github.com/kevinw/pyflakes-vim)

    虽然这个的作者推荐使用syntastic,但是这个插件对于pythoner还是很需要的

    因为有一个特牛的功能,fly check,即,编码时在buffer状态就能动态查错标记,弥补syntastic只能保存和打开时检查语法错误的不足

    演示

    ![pyflakes](https://github.com/wklken/gallery/blob/master/vim/pyflakes.png?raw=true)

2. ####Golang

    Go语言自动补全[Blackrush/vim-gocode](https://github.com/Blackrush/vim-gocode)

    安装gocode之后 ,配置这个插件

        `which gocode` (add $GOPATH/bin to you $PATH)

    另一个插件[觉得太过庞大没有使用,golang开发者可以配置试用下] [fatih/vim-go](https://github.com/fatih/vim-go) [介绍](http://blog.gopheracademy.com/vimgo-development-environment)


3. ####Markdown

    [plasticboy/vim-markdown](https://github.com/plasticboy/vim-markdown)

    markdown语法,编辑md文件

4. ####HTML/JS/JQUERY/CSS

    [jelera/vim-javascript-syntax](https://github.com/jelera/vim-javascript-syntax) js语法高亮
    [pangloss/vim-javascript](https://github.com/pangloss/vim-javascript) 缩进等

    [marijnh/tern_for_vim](https://github.com/marijnh/tern_for_vim) 配合ycm进行js/jquery自动补全,需要安装 tern_for_vim 并配置, 文档  [ternjs](http://ternjs.net/)

        cd ~/.vim/bundle/tern_for_vim && npm install

    [maksimr/vim-jsbeautify](https://github.com/maksimr/vim-jsbeautify)  js/html/css 格式化, 未配置

    [nono/jquery.vim](https://github.com/nono/jquery.vim) jquery高亮

    [elzr/vim-json](https://github.com/elzr/vim-json) json高亮,未配置

    [kchmck/vim-coffee-script](https://github.com/kchmck/vim-coffee-script) coffeescript,未配置

    [groenewege/vim-less](https://github.com/groenewege/vim-less) less,未配置

    [emmet](https://github.com/mattn/emmet-vim) zencoding,未配置

    [gorodinskiy/vim-coloresque](https://github.com/gorodinskiy/vim-coloresque) 配置 |
    [vim-css-color](https://github.com/ap/vim-css-color) 未配置
    css颜色展示

5. ####Jinja2

    [Glench/Vim-Jinja2-Syntax](https://github.com/Glench/Vim-Jinja2-Syntax)

    jinja2 语法高亮

6. ####Ruby

    可以参考tpope的插件列表,很多跟ruby相关

    [tpope/vim-rails](https://github.com/tpope/vim-rails) 未配置
    [nelstrom/vim-textobj-rubyblock](https://github.com/nelstrom/vim-textobj-ruby)

    这个有坑, 暂未搞定
    [tpope/vim-endwise](https://github.com/tpope/vim-endwise) 未配置,自动加end

7. ####PHP

    [spf13/PIV](https://github.com/spf13/PIV) 未配置

    [arnaud-lb/vim-php-namespace](https://github.com/arnaud-lb/vim-php-namespace) 未配置

8. ####非语言语法高亮

    [evanmiller/nginx-vim-syntax](https://github.com/evanmiller/nginx-vim-syntax) 未配置


---------------------------------

---------------------------------

### Update Log

详细 [更新日志](https://github.com/wklken/k-vim/blob/master/UPDATE_LOG.md)


version 9.1 [待发布]

    1. 增加 leader+w 保存文件

    2. 解决在insert mode粘贴代码缩进错乱问题(以前需要:set paste . 即k-vim中F5快捷键)

    3. add plugin for tmux: christoomey/vim-tmux-navigator

version: 9.0

    1. 新增依赖ag(the_silver_searcher)

    安装 [the_silver_searcher](https://github.com/ggreer/the_silver_searcher#installing)

    具体见文档

    2. 引入 thinca/vim-quickrun

        2.1 以message的方式展示, 同原先的F10行为, 按回车过掉消息
        2.2    F10 运行 / ,r  运行

    2. 引入dyng/ctrlsf.vim, 类似 sublimetext的全局搜索

        2.1 依赖于ag的全局搜索
        2.2 将光标挪到单词, 快捷键\  - 进入全局搜索, 移入分屏界面, o/t/T/q操作


    3. 代码折叠

        3.1 <leader>zz 折叠/打开所有代码toggle(本次新增配置)
        3.2 za 当前光标所在区域折叠toggle(vim默认的)

    4. syntastic语法检查

        4.1 修正语法检查错误高亮, 精确到具体错误单词
        4.2 开启python的pep8, 允许忽略某些warning, vimrc.bundles: line 40
        4.3 <leader>s  打开当前文件所有语法错误列表(新增配置)

    5.  easymotion

        5.1 <leader><leader>.  重复上一次easymotion命令, 更高效(新增配置)

    6. 修改RainbowParentheses, 防止黑色括号出现

    7. 修改vim-expand-region快捷键

        7.1 v 扩增选中范围
        7.2 V 缩小选中范围

    8. 新增主题tomorrow


### TODO

1. 语言插件集合, 语法增强 https://github.com/sheerun/vim-polyglot

### Contributors

thx a lot. 可以给我提pull request:)

查看详情 [git-contributors](https://github.com/wklken/k-vim/graphs/contributors)


### Inspire

1. vimrc文件布局`vimrc+vimrc.bundles`配置方式参考 [maximum-awesome](https://github.com/square/maximum-awesome)

2. install.sh 参考`spf13-vim` 的`bootstrap.sh` [spf13-vim](https://github.com/spf13/spf13-vim)

2. 插件管理使用[Vundle](https://github.com/gmarik/Vundle.vim)

3. 自动补全 [YCM](https://github.com/Valloric/YouCompleteMe)

4. 插件挑选 [VimAwesome](http://vimawesome.com/)

### Resources

[链接](http://www.wklken.me/posts/2014/10/03/vim-resources.html)

### Donation

如果你认为对你有所帮助, You can Buy me a coffee:)

![donation](https://raw.githubusercontent.com/wklken/gallery/master/donation/donation.png)

------------------------
------------------------

The End!

wklken (凌岳/pythoner/vim党预备党员)

Email: wklken@yeah.net

Github: https://github.com/wklken

Blog: [http://www.wklken.me](http://www.wklken.me)

2013-06-11 于深圳

