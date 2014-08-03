" *********************************************************************************************
" comments.vim  
" *********************************************************************************************
" Description : Global Plugin to comment and un-comment different 
"               source files in both normal and visual <Shift-V> mode
" Last Change : 26th April, 2006
" Created By  : Jasmeet Singh Anand <jasanand@hotmail.com>
" Version     : 2.2
" Usage       : For VIM 6 -
"               Stick this file in your ~/.vim/plugin directory or 
"               in some other 'plugin' directory that is in your runtime path
"               For VIM 5 -
"               Stick this file somewhere and 'source <path>/comments.vim' it from
"               your ~/.vimrc file
" Note        : I have provided the following key mappings
"               To comment    <Ctrl-C> in both normal and visual <Shift-V> range select mode
"               To un-comment <Ctrl-X> in both normal and visual <Shift-V> range select mode
"               These can be changed based on user's likings or usage
" Contact     : For any comments or bug fixes email me at <jasanand@hotmail.com>
" *********************************************************************************************
 "Modification:
" *********************************************************************************************
" Jasmeet Anand  26th April, 2006 v2.0 
" Fixed C commenting where a single line already had previous comments.
" int x=0; /*this is an x value*/
" Still working on situations like
" Issue A:
" 1 int x=0; /*this
" 2           is 
" 3           an
" 4           x
" 5           value*/
" *********************************************************************************************
" Jasmeet Anand  26th April, 2006 v2.1
" Provided more granule checking for C Code but still working on Issue A
" *********************************************************************************************
" Jasmeet Anand  27th April, 2006 v2.2
" Fixed another minor C code commenting bug
" Provided for .csh, .php, .php2 and .php3 support
" Resolved Issue A with the following logic 
" 1 /* int x=0; */ /*this*/
" 2           /*is*/ 
" 3           /*an*/
" 4           /*x*/
" 5           /*value*/
" However care should be taken when un-commenting it
" in order to retain the previous comments  
" *********************************************************************************************
" Jasmeet Anand  1st May 2006 v2.3
" Provided [:blank:] to accomodate for space and tab characters
" *********************************************************************************************
" Jasmeet Anand  1st May 2006 v2.4
" Provided support for .css as advised by Willem Peter
" *********************************************************************************************
" Jasmeet Anand  2nd May 2006 v2.5
" Removed auto-indenting for .sql, .sh and normal files when un-commenting
" *********************************************************************************************
" Jasmeet Anand  5th June 2006 v2.6
" Added support for .html, .xml, .xthml, .htm, .vim, .vimrc
" files as provided by Jeff Buttars
" *********************************************************************************************
" Smolyar "Rastafarra" Denis 7th June 2007 v2.7
" Added support for .tex
" *********************************************************************************************
" Jasmeet Anand  5th June 2006 v2.8
" Added support for Fortran .f, .F, .f90, .F90, .f95, .F95
" files as provided by Albert Farres
" *********************************************************************************************
" Jasmeet Anand  8th March 2008 v2.9
" Added support for ML, Caml, OCaml .ml, mli, PHP (v.4) .php4, PHP (v.5) .php5
" files as provided by Denis Smolyar
" Added support for noweb (requires only a small enhancement to the tex type)
" as provided by Meik "fuller" Teﬂmer
" Added support for vhdl files provided by Trond Danielsen
" *********************************************************************************************
" Jasmeet Anand 20 th March 2008 v2.10
" Bug fixes for php files as pointed by rastafarra
" *********************************************************************************************
" Jasmeet Anand 29th November 2008 v2.11
" Added support for haskel
" files as provided by Nicolas Martyanoff
" File Format changed to UNIX
" *********************************************************************************************
" Jasmeet Anand 11th January 2009 v2.12
" bug fix for haskel files as prpvided by Jean-Marie
"

" Exit if already loaded
if exists("loaded_comments_plugin")
  finish
endif

let loaded_comments_plugin="v2.10"

" key-mappings for comment line in normal mode
noremap  <silent> <C-C> :call CommentLine()<CR>
" key-mappings for range comment lines in visual <Shift-V> mode
vnoremap <silent> <C-C> :call RangeCommentLine()<CR>

" key-mappings for un-comment line in normal mode
noremap  <silent> <C-X> :call UnCommentLine()<CR>
" key-mappings for range un-comment lines in visual <Shift-V> mode
vnoremap <silent> <C-X> :call RangeUnCommentLine()<CR>

" function to comment line in normal mode
function! CommentLine()
  let file_name = buffer_name("%")

  " for .cpp or .hpp or .java or .C files use //
  if file_name =~ '\.cpp$' || file_name =~ '\.hpp$' || file_name =~ '\.java$' || file_name =~ '\.php[2345]\?$' || file_name =~ '\.C$'
    execute ":silent! normal ^i//\<ESC>==\<down>^"
  " for .c or .h or .pc or .css files use /* */
  elseif file_name =~ '\.c$' || file_name =~ '\.h$' || file_name =~ '\.pc$' || file_name =~ '\.css$' || file_name =~ '\.js$'
    " if there are previous comments on this line ie /* ... */
    if stridx(getline("."), "\/\*") != -1 && stridx(getline("."), "\*\/") != -1
      execute ":silent! normal :nohlsearch\<CR>:s/\\([^\\/\\*]*\\)\\(\\/\\*.*\\*\\/\\)/\\1\\*\\/\\2/\<CR>:s/\\([^[:blank:]]\\+\\)/\\/\\*\\1/\<CR>:nohlsearch\<CR>=="
    " if there is a /* but no */ like line 1 in Issue A above
    elseif stridx(getline("."), "\/\*") != -1 && stridx(getline("."), "\*\/") == -1
      execute ":silent! normal :nohlsearch\<CR>:s/\\(.*\\)\\(\\/\\*.*$\\)/\\/\\*\\1\\*\\/\\2\\*\\//\<CR>:nohlsearch\<CR>=="
    " if there is a */ but no /* like line 5 in Issue A above
    elseif stridx(getline("."), "\/\*") == -1 && stridx(getline("."), "\*\/") != -1
      execute ":silent! normal :nohlsearch\<CR>:s/\\(.*\\*\\/\\)/\\/\\*\\1/\<CR>:nohlsearch\<CR>=="
    " if there are no comments on this line
    elseif stridx(getline("."), "\/\*") == -1 && stridx(getline("."), "\*\/") == -1
      execute ":silent! normal ^i/*\<ESC>$a*/\<ESC>==\<down>^"
    endif
  "for .ml or .mli files use (* *)
  elseif file_name =~ '\.ml$' || file_name =~ '\.mli$'
    if stridx(getline("."), "\(\*") == -1 && stridx(getline("."), "\*)") == -1
      execute ":silent! normal ^i(*\<ESC>$a*)\<ESC>==\<down>^"
    endif
    " .html,.xml,.xthml,.htm
  elseif file_name =~ '\.html$' || file_name =~ '\.htm$' || file_name =~ '\.xml$' || file_name =~ '\.xhtml$' 
    if stridx( getline("."), "\<!--" ) != -1 && stridx( getline("."), "--\>" ) != -1
    elseif stridx( getline("."), "\<!--" ) != -1 && stridx( getline("."), "--\>" ) == -1
        "  open, but a close "
       execute ":silent! normal ^A--\>\<ESC>==\<down>^"
    elseif stridx( getline("."), "\<!--" ) == -1 && stridx( getline("."), "--\>" ) != -1
       execute ":silent! normal ^i\<\!--\<ESC>==\<down>^"
    elseif stridx( getline("."), "\<!--" ) == -1 && stridx( getline("."), "--\>" ) == -1
       execute ":silent! normal ^i\<\!--\<ESC>$a--\>\<ESC>==\<down>^"
    endif
  " for .vim files use "
  elseif file_name =~ '\.vim$' || file_name =~ '\.vimrc$'
	 execute ":silent! normal ^i\"\<ESC>\<down>^"
  " for .sql files use --
  elseif file_name =~ '\.sql$'
    execute ":silent! normal ^i--\<ESC>\<down>^"
  " for .ksh or .sh or .csh or .pl or .pm files use #
  elseif file_name =~ '\.[kc]\?sh$' || file_name =~ '\.pl$' || file_name =~ '\.pm$'
    execute ":silent! normal ^i#\<ESC>\<down>^"
  " for .tex files use %
  elseif file_name =~ '\.tex$' || file_name =~ '\.nw$'
    execute ":silent! normal ^i%\<ESC>\<down>^"
  " for fortran 77 files use C on first column 
  elseif file_name =~ '\.f$' || file_name =~ '\.F$'
    execute ":silent! normal ^gIC\<ESC>\<down>^"
  " for fortran 90/95 files use !
  elseif file_name =~ '\.f90$' || file_name =~ '\.F90$' || file_name =~ '\.f95$' || file_name =~ '\.F95$'
    execute ":silent! normal ^i!\<ESC>\<down>^"
  " for VHDL and Haskell files use -- 
  elseif file_name =~ '\.vhd$' || file_name =~ '\.vhdl$' || file_name =~ '\.hs$'
    execute ":silent! normal ^gI-- \<ESC>\<down>^"
  " for all other files use # 
  else
    execute ":silent! normal ^i#\<ESC>\<down>^"
  endif
endfunction

" function to un-comment line in normal mode
function! UnCommentLine()
  let file_name = buffer_name("%")

  " for .cpp or .hpp or .java or .C files use //
  if file_name =~ '\.cpp$' || file_name =~ '\.hpp$' || file_name =~ '\.java$' || file_name =~ '\.php[2345]\?$' || file_name =~ '\.C$'
    execute ":silent! normal :nohlsearch\<CR>:s/\\/\\///\<CR>:nohlsearch\<CR>=="
  " for .ml or .mli
  elseif file_name =~ '\.ml$' || file_name =~ '\.mli$'
    execute ":silent! normal :nohlsearch\<CR>:s/(\\*//\<CR>:nohlsearch\<CR>"
	execute ":silent! normal :nohlsearch\<CR>:s/\\*)//\<CR>:nohlsearch\<CR>=="
  " for .c or .h or .pc or .css files use /* */
  elseif file_name =~ '\.c$' || file_name =~ '\.h$' || file_name =~ '\.pc$' || file_name =~ '\.css$' || file_name =~ '\.js$'
    execute ":silent! normal :nohlsearch\<CR>:s/\\/\\*//\<CR>:s/\\*\\///\<CR>:nohlsearch\<CR>=="
  " for .vim files use "
  elseif file_name =~ '\.vim$' || file_name =~ '\.vimrc$'
    execute ":silent! normal :nohlsearch\<CR>:s/\\\"//\<CR>:nohlsearch\<CR>"
  " for .sql files use --
  elseif file_name =~ '\.sql$'
    execute ":silent! normal :nohlsearch\<CR>:s/\\-\\-//\<CR>:nohlsearch\<CR>"
  " for .ksh or .sh or .csh or .pl or .pm files use #
  elseif file_name =~ '\.[kc]\?sh$' || file_name =~ '\.pl$' || file_name =~ '\.pm$'
    execute ":silent! normal :nohlsearch\<CR>:s/\\#//\<CR>:nohlsearch\<CR>"
  " for .xml .html .xhtml .htm use <!-- -->
  elseif file_name =~ '\.html$' || file_name =~ '\.htm$' || file_name =~ '\.xml$' || file_name =~ '\.xhtml$' 
    execute ":silent! normal :nohlsearch\<CR>:s/<!--//\<CR>=="
    execute ":silent! normal :nohlsearch\<CR>:s/-->//\<CR>=="
  " for .tex use %
  elseif file_name =~ '\.tex$' || file_name =~ '\.nw$'
    execute ":silent! normal :nohlsearch\<CR>:s/%/\<CR>:nohlsearch\<CR>"
  " for fortran 77 files use C on first column 
  elseif file_name =~ '\.f$' || file_name =~ '\.F$'
    execute ":silent! normal ^x\<ESC>\<down>^"
  " for fortran 90/95 files use !
  elseif file_name =~ '\.f90$' || file_name =~ '\.F90$' || file_name =~ '\.f95$' || file_name =~ '\.F95$'
    execute ":silent! normal :nohlsearch\<CR>:s/!//\<CR>:nohlsearch\<CR>"
  " for VHDL and Haskell files use --
  elseif file_name =~ '\.vhd$' || file_name =~ '\.vhdl$' || file_name =~ '\.hs$'
    execute ":silent! normal :nohlsearch\<CR>:s/-- //\<CR>:nohlsearch\<CR>"
  " for all other files use # 
  else
    execute ":silent! normal :nohlsearch\<CR>:s/\\#//\<CR>:nohlsearch\<CR>"
  endif
endfunction

" function to range comment lines in visual mode
function! RangeCommentLine()
  let file_name = buffer_name("%")

  " for .cpp or .hpp or .java or .C files use //
  if file_name =~ '\.cpp$' || file_name =~ '\.hpp$' || file_name =~ '\.java$' || file_name =~ '\.php[2345]\?$' || file_name =~ '\.C$'
    execute ":silent! normal :s/\\S/\\/\\/\\0/\<CR>:nohlsearch<CR>=="
  " for .c or .h or .pc or .css files use /* */
  elseif file_name =~ '\.c$' || file_name =~ '\.h$' || file_name =~ '\.pc$' || file_name =~ '\.css$' || file_name =~ '\.js$'
    " if there are previous comments on this line ie /* ... */
    if stridx(getline("."), "\/\*") != -1 && stridx(getline("."), "\*\/") != -1
      execute ":silent! normal :nohlsearch\<CR>:s/\\([^\\/\\*]*\\)\\(\\/\\*.*\\*\\/\\)/\\1\\*\\/\\2/\<CR>:s/\\([^[:blank:]]\\+\\)/\\/\\*\\1/\<CR>:nohlsearch\<CR>=="
    " if there is a /* but no */ like line 1 in Issue A above
    elseif stridx(getline("."), "\/\*") != -1 && stridx(getline("."), "\*\/") == -1
      execute ":silent! normal :nohlsearch\<CR>:s/\\(.*\\)\\(\\/\\*.*$\\)/\\/\\*\\1\\*\\/\\2\\*\\//\<CR>:nohlsearch\<CR>=="
    " if there is a */ but no /* like line 5 in Issue A above
    elseif stridx(getline("."), "\/\*") == -1 && stridx(getline("."), "\*\/") != -1
      execute ":silent! normal :nohlsearch\<CR>:s/\\(.*\\*\\/\\)/\\/\\*\\1/\<CR>:nohlsearch\<CR>=="
    " if there are no comments on this line
    elseif stridx(getline("."), "\/\*") == -1 && stridx(getline("."), "\*\/") == -1
      execute ":silent! normal :s/\\(\\S.*$\\)/\\/\\*\\1\\*\\//\<CR>:nohlsearch\<CR>=="
    endif
  " .html,.xml,.xthml,.htm
  elseif file_name =~ '\.html$' || file_name =~ '\.htm$' || file_name =~ '\.xml$' || file_name =~ '\.xhtml$' 
    if stridx( getline("."), "\<!--" ) != -1 && stridx( getline("."), "--\>" ) != -1
    elseif stridx( getline("."), "\<!--" ) != -1 && stridx( getline("."), "--\>" ) == -1
        "  open, but a close "
       execute ":silent! normal ^A--\>\<ESC>==\<down>^"
    elseif stridx( getline("."), "\<!--" ) == -1 && stridx( getline("."), "--\>" ) != -1
       execute ":silent! normal ^i\<\!--\<ESC>==\<down>^"
    elseif stridx( getline("."), "\<!--" ) == -1 && stridx( getline("."), "--\>" ) == -1
       execute ":silent! normal ^i\<\!--\<ESC>$a--\>\<ESC>==\<down>^"
    endif
   " for .ml, .mli files use (* *)
  elseif file_name =~ '\.ml$' || file_name =~ '\.mli'
    if stridx(getline("."), "\(\*") == -1 && stridx(getline("."), "\*)/") == -1
      execute ":silent! normal ^i\(*\<ESC>$a*)\<ESC>==\<down>^"
	endif
  " for .vim files use --
  elseif file_name =~ '\.vim$' || file_name =~ '\.vimrc$'
    execute ":silent! normal :s/\\S/\\\"\\0/\<CR>:nohlsearch<CR>"
  " for .sql files use --
  elseif file_name =~ '\.sql$'
    execute ":silent! normal :s/\\S/\\-\\-\\0/\<CR>:nohlsearch<CR>"
  " for .ksh or .sh or .csh or .pl or .pm files use #
  elseif file_name =~ '\.[kc]\?sh$' || file_name =~ '\.pl$' || file_name =~ '\.pm$'
    execute ":silent! normal :s/\\S/\\#\\0/\<CR>:nohlsearch<CR>"
  " for .tex use %
  elseif file_name =~ '\.tex$' || file_name =~ '\.nw$'
    execute ":silent! normal :s/\\S/\\%\\0/\<CR>:nohlsearch<CR>"
  " for fortran 77 files use C on first column 
  elseif file_name =~ '\.f$' || file_name =~ '\.F$'
    execute ":silent! normal ^gIC\<ESC>\<down>^"
  " for fortran 90/95 files use !
  elseif file_name =~ '\.f90$' || file_name =~ '\.F90$' || file_name =~ '\.f95$' || file_name =~ '\.F95$'
    execute ":silent! normal :s/\\S/!\\0/\<CR>:nohlsearch<CR>"
  " for VHDL and Haskell files use --
  elseif file_name =~ '\.vhd$' || file_name =~ '\.vhdl$' || file_name =~ '\.hs$'
    execute ":silent! normal ^gI-- \<ESC>\<down>^"
  " for all other files use #  
  else
    execute ":silent! normal :s/\\S/\\#\\0/\<CR>:nohlsearch<CR>"
  endif
endfunction

" function to range un-comment lines in visual mode
function! RangeUnCommentLine()
  let file_name = buffer_name("%")

  " for .cpp or .hpp or .java files use //
  if file_name =~ '\.cpp$' || file_name =~ '\.hpp$' || file_name =~ '\.java$' || file_name =~ '\.php[2345]\?$' || file_name =~ '\.C$'
    execute ":silent! normal :s/\\/\\///\<CR>:nohlsearch\<CR>=="
  " for .c or .h or .pc or .css files use /* */
  elseif file_name =~ '\.c$' || file_name =~ '\.h$' || file_name =~ '\.pc$' || file_name =~ '\.css$' || file_name =~ '\.js$'
    execute ":silent! normal :nohlsearch\<CR>:s/\\/\\*//\<CR>:s/\\*\\///\<CR>:nohlsearch\<CR>=="
  " for .vim files use " 
  elseif file_name =~ '\.vim$' || file_name =~ '\.vimrc$'
    execute ":silent! normal :s/\\\"//\<CR>:nohlsearch\<CR>"
  " for .sql files use -- 
  elseif file_name =~ '\.sql$'
    execute ":silent! normal :s/\\-\\-//\<CR>:nohlsearch\<CR>"
  " for .ml .mli
  elseif file_name =~ '\.ml$' || file_name =~ '\.mli$'
    execute ":silent! normal :nohlsearch\<CR>:s/(\\*//\<CR>=="
    execute ":silent! normal :nohlsearch\<CR>:s/\\*)//\<CR>=="
  " for .xml .html .xhtml .htm use <!-- -->
  elseif file_name =~ '\.html$' || file_name =~ '\.htm$' || file_name =~ '\.xml$' || file_name =~ '\.xhtml$' 
    execute ":silent! normal :nohlsearch\<CR>:s/<!--//\<CR>=="
    execute ":silent! normal :nohlsearch\<CR>:s/-->//\<CR>=="
  elseif file_name =~ '\.[kc]\?sh$' || file_name =~ '\.pl$' || file_name =~ '\.pm$'
    execute ":silent! normal :s/\\#//\<CR>:nohlsearch\<CR>"
  " for .tex use %
  elseif file_name =~ '\.tex$' || file_name =~ '\.nw$'
    execute ":silent! normal :s/%/\<CR>:nohlsearch\<CR>"
  " for fortran 77 files use C on first column 
  elseif file_name =~ '\.f$' || file_name =~ '\.F$'
    execute ":silent! normal ^x\<ESC>\<down>^"
  " for fortran 90/95 files use !
  elseif file_name =~ '\.f90$' || file_name =~ '\.F90$' || file_name =~ '\.f95$' || file_name =~ '\.F95$'
    execute ":silent! normal :s/!//\<CR>:nohlsearch\<CR>"
  " for VHDL and Haskell files use --
  elseif file_name =~ '\.vhd$' || file_name =~ '\.vhdl$' || file_name =~ '\.hs$'
    execute ":silent! normal :s/-- //\<CR>:nohlsearch\<CR>"
  " for all other files use # 
  else
    execute ":silent! normal :s/\\#//\<CR>:nohlsearch\<CR>"
  endif
endfunction

