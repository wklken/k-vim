""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Robbie Cao<robbie.cao@gmail.com>'s vim config
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Environment
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Basics
set nocompatible        " must be first line

" Windows Compatible
" On Windows, also use '.vim' instead of 'vimfiles'; this makes synchronization
" across (heterogeneous) systems easier.
if has('win32') || has('win64')
	set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set to auto read when a file is changed from the outside
set autoread

" Have the mouse enabled all the time.
" When you need to copy from vim, you have to ':set mouse=' first
set mouse=a

" Assume a dark background
set background=dark
" Make arrow and other keys work
if !has('win32') && !has('win64')
	set term=$TERM
endif
" Automatically detect file types.
filetype plugin indent on
" Specify the character encoding used in the script.
scriptencoding utf-8

" Automatically write a file when leaving a modified buffer.
" Turn it off
set noautowrite
" Abbrev. of messages
set shortmess+=filmnrxoOtT
" Better unix/windows compatibility
set viewoptions=folds,options,cursor,unix,slash
" Allow for cursor beyond last character
set virtualedit=onemore
" Store a ton of history (default is 20)
set history=1024

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" UI
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Set colorscheme
colorscheme elflord
" Enable syntax highlight
syntax enable
" Display the current mode
set showmode
" The commandbar is 2 high
set cmdheight=2
" How many tenths of a second to blink
set mat=2
" Imediately show the search result
set is

" Highlight current line
set cursorline
" Highlight background color of current line
hi cursorline guibg=#333333
" Highlight cursor
hi CursorColumn guibg=#333333

if has('cmdline_info')
	" Show the ruler
	set ruler
	set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)
	" Show partial commands in status line and selected
	" characters/lines in visual mode
	set showcmd
endif

if has('statusline')
	set laststatus=2

	" Broken down into easily includeable segments
	set statusline=
	set statusline+=%<%f\                    " Filename
	set statusline+=%w%h%m%r                 " Options
	set statusline+=%{fugitive#statusline()} " Git
	set statusline+=\[%{&ff}/%Y]             " Filetype
	set statusline+=%=%-14.(%l,%c%V%)\%p%%   " Right aligned file nav info
endif

set backspace=indent,eol,start  " Backspace for dummys
set linespace=0                 " No extra spaces between rows
set nu                          " Line numbers on
set showmatch                   " Show matching brackets/parenthesis
set incsearch                   " Find as you type search
set hlsearch                    " Highlight search terms
set winminheight=0              " Windows can be 0 line high
set ignorecase                  " Case insensitive search
set smartcase                   " Case sensitive when uc present
set wildmenu                    " Show list instead of just completing
set wildmode=list:longest,full  " Comand <Tab> completion, list matches, then longest common part, then all.
set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap to
set scrolljump=4                " Lines to scroll when cursor leaves screen
set scrolloff=3                 " Minimum lines to keep above and below cursor
set foldenable                  " Auto fold code
set fdl=1                       " Set fold level
set gdefault                    " The /g flag on :s substitutions by default

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Text and Formatting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nowrap                      " Not wrap long lines, 'set wrap' if need
set autoindent                  " Auto indent
set smartindent                 " Smart indent
set tabstop=8                   " Set <Tab> to 8 spaces
set noexpandtab                 " Tabs are tabs, not spaces
set shiftwidth=8                " Use indents of 8 spaces
set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)

" Only effective when 'encoding' is 'utf-8' or another Unicode encoding
set ambiwidth=double
" <Tab> in front of a line inserts blanks according to
" 'shiftwidth'.  'tabstop' or 'softtabstop' is used in other places
set smarttab
" If on Vim will wrap long lines at a character in 'breakat' rather
" than at the last character that fits on the screen
set lbr
" Maximum width of text that is being inserted.  A longer line will be
" broken after white space to get this width.  A zero value disables this.
set tw=2048
" This option defines the behavior of the selection.  It is only used
" in Visual and Select mode.
set selection=inclusive

" Remove trailing whitespaces and ^M chars
autocmd FileType c,cpp,java,php,js,twig,xml,yml autocmd BufWritePre <buffer> :call setline(1,map(getline(1,"$"),'substitute(v:val,"\\s\\+$","","")'))


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Key (re)Mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" The default Leader is '\', use the following line to change to your favoriate,
" eg, ','
" let mapLeader = ','

" Yank from the cursor to the end of the line, to be consistent with C and D.
nnoremap Y y$

" Change Working Directory to that of the current file
cmap cwd lcd %:p:h
cmap cd. lcd %:p:h

" Visual shifting (does not exit Visual mode)
vnoremap < <gv
vnoremap > >gv

" Fix home and end keybindings for screen, particularly on mac
" - for some reason this fixes the arrow keys too. huh.
map [F $
imap [F $
map [H g0
imap [H g0


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Encoding Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("multi_byte")
	" Set fileencoding priority
	if getfsize(expand("%")) > 0
		set fileencodings=ucs-bom,utf-8,cp936,big5,euc-jp,euc-kr,latin1
	else
		set fileencodings=cp936,big5,euc-jp,euc-kr,latin1
	endif

	" CJK environment detection and corresponding setting
	if v:lang =~ "^zh_CN"
		" Use cp936 to support GBK, euc-cn == gb2312
		set encoding=cp936
		set termencoding=cp936
		set fileencoding=cp936
	elseif v:lang =~ "^zh_TW"
		" cp950, big5 or euc-tw
		" Are they equal to each other?
		set encoding=big5
		set termencoding=big5
		set fileencoding=big5
	elseif v:lang =~ "^ko"
		" Copied from someone's dotfile, untested
		set encoding=euc-kr
		set termencoding=euc-kr
		set fileencoding=euc-kr
	elseif v:lang =~ "^ja_JP"
		" Copied from someone's dotfile, unteste
		set encoding=euc-jp
		set termencoding=euc-jp
		set fileencoding=euc-jp
	endif
	" Detect UTF-8 locale, and replace CJK setting if needed
	if v:lang =~ "utf8$" || v:lang =~ "UTF-8$"
		set encoding=utf-8
		set termencoding=utf-8
		set fileencoding=utf-8
	endif
else
	echoerr "Sorry, this version of (g)vim was not compiled with multi_byte"
endif


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Plugins
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tlist(taglist)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if &diff
	" Don't auto pen when compare two files
	let Tlist_Auto_Open=0
else
	" Auto pen Tlist when open a file
	let Tlist_Auto_Open=1
endif

let Tlist_Auto_Highlight_Tag=1
let Tlist_Use_Right_Window=0
let Tlist_Auto_Update=1
let Tlist_File_Fold_Auto_Close=1
let Tlist_Exit_OnlyWindow=1
let Tlist_Highlight_Tag_On_BufEnter=1
let Tlist_Use_SingleClick=0

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Trinity
"
" This small plugin is just an IDE manager to control the three plugins open and
" close, and build them into a great IDE which works like the Source Insignt
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Open and close all the three plugins on the same time
nmap <Leader>ta   :TrinityToggleAll<CR>
" Open and close the srcexpl.vim separately
nmap <Leader>ts   :TrinityToggleSourceExplorer<CR>
" Open and close the taglist.vim separately
nmap <Leader>tl   :TrinityToggleTagList<CR>
" Open and close the NERD_tree.vim separately
nmap <Leader>tt   :TrinityToggleNERDTree<CR>


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VCSCommand
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" let b:VCSCommandMapPrefix=',v'
" let b:VCSCommandVCSType='git'
nmap <Leader>vs :VCSStatus<CR>
nmap <Leader>vc :VCSCommit<CR>
nmap <Leader>vb :VCSBlame<CR>
nmap <Leader>va :VCSAdd<CR>
nmap <Leader>vd :VCSVimDiff<CR>
nmap <Leader>vl :VCSLog<CR>
nmap <Leader>vu :VCSUpdate<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Buffer Explorer
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <Leader>b :BufExplorer<CR>
nmap <Leader>be :BufExplorer<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" LookupFile
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:LookupFile_MinPatLength = 2               " start search until 2 char input
let g:LookupFile_PreserveLastPattern = 0        " not save last search strin
let g:LookupFile_PreservePatternHistory = 1     " save serach history
let g:LookupFile_AlwaysAcceptFirst = 1          " enter to open first match
let g:LookupFile_AllowNewFiles = 0              " not create file which not exist
let g:LookupFile_ignorecase= 1                  " ignore case to match files
if filereadable("fn.tags")                      " set tag file name
	let g:LookupFile_TagExpr = '"fn.tags"'
endif
nmap <silent> <Leader>lf :LookupFile<cr>
nmap <silent> <Leader>lt :LUTags<cr>
nmap <silent> <Leader>lb :LUBufs<cr>
nmap <silent> <Leader>lp :LUPath<cr>
nmap <silent> <Leader>lw :LUWalk<cr>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Functions
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! InitializeDirectories()
	let separator = "."
	let parent = $HOME
	let prefix = '.vim'
	let dir_list = {
		\ 'backup': 'backupdir',
		\ 'views': 'viewdir',
		\ 'swap': 'directory' }

	for [dirname, settingname] in items(dir_list)
		let directory = parent . '/' . prefix . dirname . "/"
		if exists("*mkdir")
			if !isdirectory(directory)
				call mkdir(directory)
			endif
		endif
		if !isdirectory(directory)
			echo "Warning: Unable to create backup directory: " . directory
			echo "Try: mkdir -p " . directory
		else
			let directory = substitute(directory, " ", "\\\\ ", "")
			exec "set " . settingname . "=" . directory
		endif
	endfor
endfunction
call InitializeDirectories()


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" cscope
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set csprg=/usr/bin/cscope
set cst
set nocsverb
if filereadable("cscope.out")	" db in current dir
	cs add cscope.out
elseif $CSCOPE_DB != ""		" db pointed to by env
	cs add $CSCOPE_DB
endif

" 's'   symbol: find all references to the token under cursor
" 'g'   global: find global definition(s) of the token under cursor
" 'c'   calls:  find all calls to the function name under cursor
" 't'   text:   find all instances of the text under cursor
" 'e'   egrep:  egrep search for the word under cursor
" 'f'   file:   open the filename under cursor
" 'i'   includes: find files that include the filename under cursor
" 'd'   called: find functions that function under cursor calls
map <Leader>s :cs find s <C-R>=expand("<cword>")<CR><CR>
map <Leader>g :cs find g <C-R>=expand("<cword>")<CR><CR>
map <Leader>c :cs find c <C-R>=expand("<cword>")<CR><CR>
map <Leader>t :cs find t <C-R>=expand("<cword>")<CR><CR>
map <Leader>e :cs find e <C-R>=expand("<cword>")<CR><CR>
map <Leader>f :cs find f <C-R>=expand("<cfile>")<CR><CR>
map <Leader>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
map <Leader>d :cs find d <C-R>=expand("<cword>")<CR><CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" ctags
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" For ctags, let it can find the 'tags' file even not in current directory
set tags=tags;/

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Misc
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use local vimrc if available
if filereadable(expand("~/.vimrc.local"))
	source ~/.vimrc.local
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" grep
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
map <Leader>gr :Grep -r <C-R>=expand("<cword>")<CR><CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Android logcat highlight syntax
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
au BufRead,BufNewFile *.logcat set filetype=logcat
au BufRead,BufNewFile aplog* set filetype=logcat

