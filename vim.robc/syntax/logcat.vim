" Vim syntax file
" Language:         logcat
" Maintainer:       Naseer Ahmed <naseer.ahmed@gmail.com>
" Latest Revision:  2009-08-10

if exists("b:current_syntax")
    finish
endif

"Define colors
hi def LogF_color ctermfg=white guifg=white ctermbg=red guibg=red
hi def LogE_color ctermfg=red guifg=red
hi def LogW_color ctermfg=brown guifg=brown
hi def LogI_color ctermfg=blue guifg=blue
hi def LogD_color ctermfg=darkgreen guifg=darkgreen
hi def LogV_color ctermfg=gray guifg=gray

syn match LogF '.* F .*' 
syn match LogE '.* E .*' 
syn match LogW '.* W .*' 
syn match LogI '.* I .*' 
syn match LogD '.* D .*' 
syn match LogV '.* V .*' 

hi def link LogF LogF_color
hi def link LogE LogE_color
hi def link LogW LogW_color
hi def link LogI LogI_color
hi def link LogD LogD_color
hi def link LogV LogV_color
