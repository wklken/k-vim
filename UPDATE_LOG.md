更新日志
================================

## 2015-05-02

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


注: 8.0后面将开始使用小版本号

## 2014-10-02

version: 8.0

    1. 修复YCM不能自动提示Ultisnips代码片段的问题
       重大问题, 生产力得到再次提升:)
       注意: 自定义snippets, 写错一个, 就会导致YCM不提示所有的snippets

    2. tab增强
       2.1 新增tab操作快捷键, 详见文档
       2.2 增加插件 `jistr/vim-nerdtree-tabs`, 所有tab使用同一个nerdtree
       2.3 增加插件 `szw/vim-ctrlspace`, 更强大的buffer/tab操作-切换
       由于tab增强带来的影响:
       - 去掉了t/T新增一行的快捷键(低频操作, 后续可以考虑配置到其他键位)

    3. 去除`minibuffer`插件
       配置还留着, 需要的自己解开, 但是ctrlspace其实可以完爆这个功能

    4. 优化`scrooloose/nerdcommenter`配置
       注解加空格, 以及新增键位

    5. 增加插件 `kshenoy/vim-signature`
       mark-跳转更加方便, 修复与保存自动去行尾空白功能的冲突

    6. 对齐插件变更, 使用`junegunn/vim-easy-align` 替换掉 `godlygeek/tabular`

    7. 增加插件 `jelera/vim-javascript-syntax`
       更丰富的javascript语法高亮

    8. 去除插件 `gorodinskiy/vim-coloresque`
       这货有坑, 使用频率低 see issue https://github.com/wklken/k-vim/issues/49

    9. 新增自定义snippets
       位置 ~/.vim/UltiSnips/

    10. 修复YCM不能跳转到函数/类等定义处的问题
       ,jd/,gd

    11. 重写README

    12. easymothion
        增加快速hjkl移动快捷键

## 2014-05-07/08

version: 7.0

    1.增加文本对象扩展
    2.去除 taglist
    3.增加 ctrlp 插件 ctrlp-funky用于快速函数搜索跳转
    4.切换 powerline为airline


## 2014-03-15

version: 6.0

    1.更全的注释
    2.更合理文件结构和配置布局
    3.分离插件配置到vimrc.bundles
    4.更强大的代码补全
    5.去掉一些无用信息

## 2013-06-11

version: 5.0

    1. 梳理vim配置, 维护到git
    2. 书写文档, 截图演示


