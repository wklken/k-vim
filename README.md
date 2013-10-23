k-vim
======================

### vim插件分类及快捷键

> 给人一条Vim 命令，他能折腾一晚上；告诉他怎么自定义Vim 命令，他能捣腾一辈子
>
> 生命不息,折腾不止 (╯‵□′)╯︵┻━┻)
>
> 编辑器之神 = 生产力(效率为王) + 性感(界面快捷键) + 装x神器

### vim基本用法

初学者: [vim训练稿](http://blog.csdn.net/wklken/article/details/7533272)
几年前的三月份,第一次正儿八经开始使用vim,后来整理了一份,对着敲几遍,训练稿

推荐: 耗子叔的 [简明vim练级攻略](http://coolshell.cn/articles/5426.html)

或者,玩游戏 [vim大冒险](http://vim-adventures.com/)

### 使用说明


1. 能熟练使用原生vim,最好先熟悉了再来使用插件扩展

2. 以下插件,仅介绍用途优点等,可以在github中搜索查看详细用途和配置

   当前vim使用配置,在vimrc中查看

   快捷键为插件默认/或者当前配置vimrc定义的,如果需要修改,查看vimrc中对插件配置进行修改 [sd]标记的为自定义 [d]标记的为默认快捷键


3. 由于平时会使用python和golang,所以语言方面的配置偏向于这两个

   其它的可以参照网上配置(通用的插件可以配置,其他具体语言插件可以自己配置加入)

4. fork一份

   根据自己使用的语言，自身习惯进行修改

   有些插件用不到，可以注释删除，有些插件没有，可以自行添加（vundle很强大只要github上有都能配置），有些插件快捷键等可以自己去进一步了解

          建议：插件不是越多越好，可以尝试注掉所有插件，然后根据自己使用遇到的问题和需求，逐一加入

   得到一份符合自己习惯的vim配置，后续能在任何地方进行一键配置

          二八定律,关注可以最大提升自身生产力的那20%插件,具体要亲自实践
          有什么问题,先看插件文档说明->代码选项->github上的issues->google it
          你遇到的问题,一定别人也遇到了,大部分可解决,少部分无解….

   文章: [不要复杂化vim](http://www.kunli.info/2013/08/13/vim/)

   欢迎推荐好用更酷的插件配置:)

   我的配置也会不定期更新，thx

PS: 这个vim配置是我的[linux_config](https://github.com/wklken/linux_config)下一部分，如果需要，可以参考，主要是用于一键配置环境

--------------

### 配置步骤

1. clone到本地,配置到linux个人目录（如果是从linux_config过来的，不需要clone）

        git clone https://github.com/wklken/k-vim.git

2. 安装依赖包

        sudo apt-get install ctags
        sudo apt-get install build-essential cmake python-dev  #编译YCM自动补全插件依赖

        #brew install ctags     (mac用户)

        #使用python需要
        sudo pip install pyflakes
        sudo pip install pylint
        sudo pip install pep8

3. 安装插件

        cd k-vim/

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

   * 编译自动补全YouCompleteMe

   [文档](https://github.com/Valloric/YouCompleteMe)

   这个插件需要Vim 7.3.584,所以,如果vim版本太低,需要[编译安装](https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source)

   * 相对行号

   vimrc中配置,如果不习惯,可以去掉,[相关参考](http://jeffkreeftmeijer.com/2012/relative-line-numbers-in-vim-for-super-fast-movement/)

   * 配置主题

   到vimrc中修改colortheme,可以使用molokai(用惯sublimetext2的童鞋很熟悉)

   默认配置的是[solarized dark主题](https://github.com/altercation/vim-colors-solarized)

   想要修改终端配色为solarized可以参考 [这里](https://github.com/sigurdga/gnome-terminal-colors-solarized)


---------------------

### 其他

5. 安装/卸载/更新插件：

   可能发现打开vim很慢，可能是插件有点多了，这个配置插件全开

   去掉某些自己用不到的插件: 编辑vimrc，注释掉插件对应Bundle行即可(加一个双引号),保存退出即可

        "Bundle 'fholgado/minibufexpl.vim'

   如果想从物理上清除（删除插件文件），注释保存后再次进入vim

   命令行模式，执行:

        :BundleClean

   如果要安装新插件，在vimrc中加入bundle，然后执行

        :BundleInstall

   更新插件

        :BundleUpdate

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

   排除法进行排查：注掉所有插件或配置，然后二分法逐一恢复，可以定位到出现问题的插件或配置

-------------

### 截图

solarized主题

![solarized](https://github.com/wklken/gallery/blob/master/vim/solarized.png?raw=true)

molokai主题

![molokai](https://github.com/wklken/gallery/blob/master/vim/molokai.png?raw=true)

-------------

### 自定义快捷键说明

    F1  关掉，防止跳出帮助
    F2  set nu/nonu
    F3  set list/nolist
    F4  set wrap/nowrap
    F5  set paste/nopaste
    F6  syntax on/off
    空格 /开启查找
    Y   =y$   复制到行尾
    w!!  以sudo的权限保存
    kj   <Esc>，不用到角落去按esc了
    t    新起一行，下面，不进入插入模式
    T    新起一行，上面
    ,sa   全选(select all)
    hjkl  上下左右，强迫使用，要解开的自己改
    ctrl + jkhl 进行上下左右窗口跳转,不需要ctrl+w+jkhl

    ,tn  new tab
    ,tc  tab close
    ,to  tab only
    ,tm  tab move
    ,te  new tab edit
    ctrl+n  相对行号绝对行号变换，默认用相对行号
    5j/5k  在相对行号模式下，往上移动5行 往下移动5行

    ,y 展示历史剪贴板
    ,yc 清空
    yy/dd -> p -> ctrl+p可以替换非最近一次剪贴内容

    ,p 开启文件搜索 ctrlp
    ,/ 去除匹配高亮

--------------------

### 插件及其快捷键说明

图片有点多，展示有点慢，截得不是很专业，耐心看完:)

> 插件管理

1. ####[gmarik/vundle](https://github.com/gmarik/vundle)

    必装,用于管理所有插件

    命令行模式下管理命令:

        :BundleInstall     install
        :BundleInstall!    update
        :BundleClean       remove plugin not in list


> 导航及搜索

1. ####[scrooloose/nerdtree](https://github.com/scrooloose/nerdtree)

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

2. ####[fholgado/minibufexpl.vim](https://github.com/fholgado/minibufexpl.vim)

   必装，buffer管理, 可以查找其他同类插件

        [sd]
            <Tab>  切换buffer
            左右方向键  切换buffer
            ,bn   切到后一个
            ,bp   切到前一个
            ,bd   关闭当前buffer

2. ####[majutsushi/tagbar](https://github.com/majutsushi/tagbar)

   必装,标签导航,纬度和taglist不同

        [sd] <F9> 打开

   演示

   ![tagbar](https://github.com/wklken/gallery/blob/master/vim/tagbar.gif?raw=true)

3. ####[vim-scripts/taglist.vim](https://github.com/vim-scripts/taglist.vim)

   必装

        [sd] <F8>打开

   演示:

   ![taglist](https://github.com/wklken/gallery/blob/master/vim/taglist.png?raw=true)

4. ####[kien/ctrlp.vim](https://github.com/hdima/python-syntax)

   文件搜索,ack/Command-T需要依赖于外部包,不喜欢有太多依赖的,除非十分强大, 具体 [文档](http://kien.github.io/ctrlp.vim/)

        [sd] ,p  打开ctrlp搜索
        [sd] ,f  相当于mru功能，show recently opened files

        ctrl + j/k 进行上下移动

   演示

   ![ctrip](https://github.com/wklken/gallery/blob/master/vim/ctrlp.gif?raw=true)

> 显示增强

    被动技能,无快捷键

1. ####[Lokaltog/vim-powerline](https://github.com/Lokaltog/vim-powerline)

   必装，状态栏美观

   演示

   ![powerline](https://github.com/wklken/gallery/blob/master/vim/powerline.png?raw=true)

2. ####[kien/rainbow_parentheses.vim](https://github.com/kien/rainbow_parentheses.vim)

   必装,括号高亮

   演示

   ![rainbow](https://github.com/wklken/gallery/blob/master/vim/rainbow_parentheses.png?raw=true)

3. ####[Yggdroot/indentLine](https://github.com/Yggdroot/indentLine)

   选装,装不装看个人喜好了,缩进标识

   另一个类似的,整块背景色的的,[nathanaelkane/vim-indent-guides](https://github.com/nathanaelkane/vim-indent-guides),自选吧, 看来看去还是st2的好看,唉

   调整颜色和solarized一致,不至于太显眼影响注意力,可以根据自己主题设置颜色([颜色](http://vim.wikia.com/wiki/Xterm256_color_names_for_console_Vim?file=Xterm-color-table.png))

   演示:

   ![indentline](https://github.com/wklken/gallery/blob/master/vim/indentline.png?raw=true)

4. ####[bronson/vim-trailing-whitespace](https://github.com/bronson/vim-trailing-whitespace)

   将代码行最后无效的空格标红

        [sd] ,空格    去掉当前行末尾空格


4. ####[altercation/vim-colors-solarized](https://github.com/altercation/vim-colors-solarized)

   经典主题,目前我使用的,看起来舒服

5. ####[tomasr/molokai](https://github.com/tomasr/molokai)

   用sublime text2的同学应该很熟悉, 另一个主题,可选,偶尔换换味道

> 快速移动

    主动技能,需要快捷键

1. ####[Lokaltog/vim-easymotion](https://github.com/Lokaltog/vim-easymotion)

   必装，效率提升杀手锏，跳转到光标后任意位置

   配置(我的leader键配置 let g:mapleader = ',')

        ,, + w  跳转
        ,, + fe  查找'e',快速跳转定位到某个字符位置

   演示

   ![easy_motion](https://github.com/wklken/gallery/blob/master/vim/easymotion.gif?raw=true)

2. ####[vim-scripts/matchit.zip](https://github.com/vim-scripts/matchit.zip)

   选装

   % 匹配成对的标签，跳转

> 自动补全及快速编辑

    主动技能,需要快捷键,高效编辑无上利器


1. ####[Valloric/YouCompleteMe](https://github.com/Valloric/YouCompleteMe)

   必装，强烈推荐

   YCM是我目前用到的最好的自动补全插件,我只能说，用这个写代码太舒畅了

   需要编译这个插件(见github文档)

   这个需要自己去看官方的配置方式,演示在官方github有

   需要Vim 7.3.584 以上版本([如何编译vim](https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source))

   这个插件包含了以下四个插件功能,所以不需要装下面四个

        clang_complete
        AutoComplPop
        Supertab
        neocomplcache
        jedi(对python的补全)

   快捷键:

        ,gd  跳到声明位置, 仅 filetypes: c, cpp, objc, objcpp, python 有效

2. ####[SirVer/ultisnips](https://github.com/SirVer/ultisnips)

   必装，效率杀手锏，快速插入自定义的代码片段

   自动补全加这个,高效必备, 针对各种语言已经带了一份配置了，可以到安装目录下查看具体，我有针对性补全一份，在snippets目录下，可自行修改

   演示

   ![ultisnips](https://github.com/wklken/gallery/blob/master/vim/utilsnips.gif?raw=true)

2. ####[scrooloose/nerdcommenter](https://github.com/scrooloose/nerdcommenter)

   必装，另一个大大提升效率的地方，快速批量加减注释

        [d] shift+v+方向键选中(默认当前行)   ->  ,cc  加上注释  -> ,cu 解开注释

   演示

   ![nerdcommenter](https://github.com/wklken/gallery/blob/master/vim/nerdcomment.gif?raw=true)

3. ####[tpope/vim-surround](https://github.com/tpope/vim-surround)

   必装，很给力的功能，快速给词加环绕符号,例如引号

   [tpope/vim-repeat](https://github.com/tpope/vim-repeat)

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

4. ####[Raimondi/delimitMate](https://github.com/Raimondi/delimitMate)

   必装，输入引号,括号时,自动补全

   对python的docstring 三引号做了处理(只处理""", '''暂时没配，可以自己加)

   演示

   ![delimitmate](https://github.com/wklken/gallery/blob/master/vim/delimate.gif?raw=true)

5. ####[godlygeek/tabular](https://github.com/godlygeek/tabular)

   选装，代码格式化用的，code alignment

        [sd]
        ,a=  按等号切分格式化
        ,a:  按逗号切分格式化

6. ####[terryma/vim-expand-region](https://github.com/terryma/vim-expand-region)

   选装，visual mode selection
   视图模式下可伸缩选中部分，用于快速选中某些块

        [sd]
        = 增加选中范围(+/=按键)
        - 减少选中范围(_/-按键)

   演示（直接取链到其github图)

   ![expand-region](https://raw.github.com/terryma/vim-expand-region/master/expand-region.gif)

7. ####[vim-multiple-cursors](https://github.com/terryma/vim-multiple-cursors)

   选装，多光标批量操作

        [sd]
        ctrl + m 开始选择
        ctrl + p 向上取消
        ctrl + x 跳过
        esc   退出

   演示(官方演示图)

   ![multiple-cursors](https://raw.github.com/terryma/vim-multiple-cursors/master/assets/example1.gif)

> 语法检查

1. ####[scrooloose/syntastic](https://github.com/scrooloose/syntastic)

   建议安装，静态语法及风格检查,支持多种语言

   修改了下标记一列的背景色,原有的背景色在solarized下太难看了…..

   演示

   ![syntastic](https://github.com/wklken/gallery/blob/master/vim/syntastic.png?raw=true)

2. ####[kevinw/pyflakes-vim](https://github.com/kevinw/pyflakes-vim)

   虽然这个的作者推荐使用syntastic,但是这个插件对于pythoner还是很需要的

   因为有一个特牛的功能,fly check,即,编码时在buffer状态就能动态查错标记,弥补syntastic只能保存和打开时检查语法错误的不足

   演示
   ![pyflakes](https://github.com/wklken/gallery/blob/master/vim/pyflakes.png?raw=true)

> 具体语言

    主要是python  其它语言以及前端的,用得少没有研究使用过
    python   golang   markdown
    需要其它语言支持的,可以到github上捞,上面很多流行的vim配置,eg. spf13-vim
    以下均为选装，根据自己需要

1. ####[python-syntax](https://github.com/hdima/python-syntax)

   使用Python建议安装，python语法高亮,就是python.vim,在github,有维护和更新

4. ####[jnwhiteh/vim-golang](https://github.com/jnwhiteh/vim-golang)

   使用golang建议安装， golang语法高亮

   golang刚入门使用,项目中还没正式开始,目前很多golang的手册有配置vim的介绍,后续有需求再弄

5. ####[plasticboy/vim-markdown](https://github.com/plasticboy/vim-markdown)

   markdown语法,编辑md文件

6. ####[pangloss/vim-javascript](https://github.com/pangloss/vim-javascript)

   偶尔会看看js,频率不高

7. ####[nono/jquery.vim](https://github.com/nono/jquery.vim)

   jquery高亮

5. ####[thiderman/nginx-vim-syntax](https://github.com/thiderman/nginx-vim-syntax)

   nginx配置文件语法高亮,常常配置服务器很有用

6. ####[Glench/Vim-Jinja2-Syntax](https://github.com/Glench/Vim-Jinja2-Syntax)

   jinja2 语法高亮


> 其它扩展增强

    根据自身需求自取配置,不需要的话自己注解

1. ####[vim-scripts/TaskList.vim](https://github.com/vim-scripts/TaskList.vim)

   查看并快速跳转到代码中的TODO列表

   重构代码时一般通读,标记修改位置,非常实用

        [sd]
        ,td 打开todo列表

   演示

   ![tasklist](https://github.com/wklken/gallery/blob/master/vim/tasklist.gif?raw=true)

2. ####[tpope/vim-fugitive](https://github.com/tpope/vim-fugitive)

   git插件

   不是很习惯,所以用的次数太少,目前和现有配置快捷键有冲突,尚未解决


3. ####[sjl/gundo.vim](https://github.com/sjl/gundo.vim)

   编辑文件时光机

        [sd] ,h  查看文件编辑历史

> 待考察的

1. ####sjl/vitality.vim

2. ####vim-scripts/Conque-Shell

3. ####vim-scripts/YankRing.vim

4. ####vim-scripts/auto.git

5. ####[AndrewRadev/splitjoin.vim](https://github.com/AndrewRadev/splitjoin.vim)

------------------------

The End!

wklken (凌岳/pythoner/vim党预备党员)

Email: wklken@yeah.net

Github: https://github.com/wklken

Blog: http://wklken.me

2013-06-11 于深圳
