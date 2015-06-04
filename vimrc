"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if exists("b:did_indent")
    finish
endif
let b:did_indent = 1
function! GoogleCppIndent()
    let l:cline_num = line('.')
    let l:orig_indent = cindent(l:cline_num)
    if l:orig_indent == 0 | return 0 | endif
    let l:pline_num = prevnonblank(l:cline_num - 1)
    let l:pline = getline(l:pline_num)
    if l:pline =~# '^\s*template' | return l:pline_indent | endif
    if l:orig_indent != &shiftwidth | return l:orig_indent | endif
    let l:in_comment = 0
    let l:pline_num = prevnonblank(l:cline_num - 1)
    while l:pline_num > -1
        let l:pline = getline(l:pline_num)
        let l:pline_indent = indent(l:pline_num)

        if l:in_comment == 0 && l:pline =~ '^.\{-}\(/\*.\{-}\)\@<!\*/'
            let l:in_comment = 1
        elseif l:in_comment == 1
            if l:pline =~ '/\*\(.\{-}\*/\)\@!'
                let l:in_comment = 0
            endif
        elseif l:pline_indent == 0
            if l:pline !~# '\(#define\)\|\(^\s*//\)\|\(^\s*{\)'
                if l:pline =~# '^\s*namespace.*'
                    return 0
                else
                    return l:orig_indent
                endif
            elseif l:pline =~# '\\$'
                return l:orig_indent
            endif
        else
            return l:orig_indent
        endif

        let l:pline_num = prevnonblank(l:pline_num - 1)
    endwhile
    return l:orig_indent
endfunction
set shiftwidth=2
set tabstop=2
set softtabstop=2
set expandtab
set wrap
set cindent
set cinoptions=h1,l1,g1,t0,i2,+2,(2,w1,W4
set indentexpr=GoogleCppIndent()
let b:undo_indent = "setl sw< ts< sts< et< tw< wrap< cin< cino< inde<"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
set fenc=utf-8
set encoding=utf-8
set nocp
set helplang=en
set history=300
set nu!
set autoread
let mapleader = ","
let g:mapleader = ","
set cmdheight=1
set ru
set hls
set is
syntax on
set backspace=indent,eol,start
set whichwrap+=<,>,h,l
set lbr
set magic
set noerrorbells
set novisualbell
set wrap
nmap <leader>h <c-w>h
nmap <leader>j <c-w>j
nmap <leader>k <c-w>k
nmap <leader>l <c-w>l
imap <C-a> <Esc>:A<CR>
nmap <C-a> :A<CR>
imap <leader>o <esc>:only<cr>
nmap <leader>o :only<cr>
imap <leader>q <esc>:q!<cr>
nmap <leader>q :q!<cr>
imap <c-b> <left>
imap <c-f> <right>
imap <c-k> <esc>
nmap <c-n> :%s/\s\+$//ge<cr>
nmap <c-m> :noh<cr>
nmap <C-h> :w!<cr>
set tags=tags;
set autochdir
set list
set listchars=tab:>-,trail:-
set ignorecase
set noswapfile


""""""""""""""""""""""""""""""""""""""""
" auto completion for pair brace
""""""""""""""""
  inoremap ( ()<ESC>i
  inoremap ) <c-r>=ClosePair(')')<CR>
  inoremap { {<CR>}<ESC>kA<CR>
  inoremap } <c-r>=ClosePair('}')<CR>
  inoremap [ []<ESC>i
  inoremap ] <c-r>=ClosePair(']')<CR>
  " inoremap < <><ESC>i
  inoremap > <c-r>=ClosePair('>')<CR>
  inoremap " ""<ESC>i
  inoremap ' ''<ESC>i
  inoremap ,, <ESC>la
  function ClosePair(char)
    if getline('.')[col('.') - 1] == a:char
      return "\<Right>"
    else
      return a:char
    endif
  endfunction

  """""""""""""""""""""
  " cpplint
  """""""""""""""""
  map <F4> <ESC>:!cpplint.py %<cr>

"================================ nathan add ====================
" install Vundle bundles
if filereadable(expand("~/.vimrc.bundles"))
  source ~/.vimrc.bundles
endif

" F5 粘贴模式paste_mode开关,用于有格式的代码粘贴
set pastetoggle=<F5>

"Smart way to move between windows 分屏窗口移动
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
nnoremap <C-y> 5<C-y>
nnoremap <C-e> 5<C-e>

" Go to home and end using capitalized directions
noremap H ^
noremap L $

" 去掉搜索高亮
noremap <silent><leader>/ :nohls<CR>

" ------- 选中及操作改键

"Reselect visual block after indent/outdent.调整缩进后自动选中，方便再次操作
vnoremap < <gv
vnoremap > >gv

" kj 替换 Esc
inoremap kj <Esc>

" remap U to <C-r> for easier redo
nnoremap U <C-r>

" 保存python文件时删除多余空格
fun! <SID>StripTrailingWhitespaces()
 " let l = line(".")
 " let c = col(".")
 " %s/\s\+$//e
 " call cursor(l, c)
endfun
autocmd FileType c,cc,cpp,.thrift,py autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

" 定义函数AutoSetFileHead，自动插入文件头
autocmd BufNewFile *.sh,*.py exec ":call AutoSetFileHead()"
function! AutoSetFileHead()
  " "如果文件类型为.sh文件
  " if &filetype == 'sh'
      " call setline(1, "\#!/bin/bash")
  " endif

  " "如果文件类型为python
  " if &filetype == 'python'
      " call setline(1, "\#!/usr/bin/env python")
      " call append(1, "\# encoding: utf-8")
  " endif

  " normal G
  " normal o
  " normal o
endfunc

function! Blade(...)
" let l:old_makeprg = &makeprg setlocal makeprg=blade execute "make " . join(a:000) let &makeprg=old_makeprg
endfunction
command! -complete=dir -nargs=* Blade call Blade('<args>')

" set t_ti= t_te=

 """""" copy to buffer
 vmap <C-c> :w! ~/.vimbuffer<CR>
 nmap <C-c> :.w! ~/.vimbuffer<CR>

 " paste from buffer
 map <C-p> :r ~/.vimbuffer<CR>

" 进入搜索Use sane regexes"
nnoremap / /\v
vnoremap / /\v

