更新日志
================================

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


